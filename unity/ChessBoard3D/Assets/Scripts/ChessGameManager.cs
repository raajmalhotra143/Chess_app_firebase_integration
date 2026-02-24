using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// ChessGameManager — The main Unity-side chess board controller.
/// 
/// This script must be attached to a GameObject named "ChessGameManager" in your Unity scene.
/// Flutter communicates with this script via postMessage().
/// 
/// Flutter → Unity messages:
///   MovePiece(string move)    — e.g. "e2e4", animates the piece from e2 to e4
///   ResetBoard(string _)      — resets the board to the initial position
///   SetBoardFen(string fen)   — sets the entire board from a FEN string
/// 
/// Unity → Flutter messages:
///   When a player taps/drags a 3D piece, Unity sends the move string back
///   (e.g. "e2e4") via SendMessageToFlutter.
/// </summary>
public class ChessGameManager : MonoBehaviour
{
    [Header("Board Settings")]
    [Tooltip("Size of each square on the board")]
    public float squareSize = 1.0f;

    [Tooltip("Height at which pieces float above the board")]
    public float pieceHeight = 0.05f;

    [Tooltip("Duration of move animation in seconds")]
    public float moveAnimDuration = 0.4f;

    [Tooltip("How high pieces arc during animation")]
    public float moveArcHeight = 0.5f;

    [Header("Prefabs — Assign these in the Unity Editor")]
    [Tooltip("White piece prefabs: Pawn, Knight, Bishop, Rook, Queen, King")]
    public GameObject[] whitePiecePrefabs = new GameObject[6];

    [Tooltip("Black piece prefabs: Pawn, Knight, Bishop, Rook, Queen, King")]
    public GameObject[] blackPiecePrefabs = new GameObject[6];

    [Tooltip("Light square prefab")]
    public GameObject lightSquarePrefab;

    [Tooltip("Dark square prefab")]
    public GameObject darkSquarePrefab;

    [Header("Materials")]
    public Material highlightMaterial;
    public Material selectedMaterial;

    // Internal board representation
    private GameObject[,] _pieces = new GameObject[8, 8];
    private GameObject[,] _squares = new GameObject[8, 8];
    private char[,] _boardChars = new char[8, 8]; // FEN char per square

    // Drag state
    private GameObject _selectedPiece;
    private int _selectedFile = -1;
    private int _selectedRank = -1;
    private bool _isDragging = false;
    private Plane _dragPlane;
    private Camera _mainCamera;

    // ────────────────────────────────────────────────────────────
    //  Unity Lifecycle
    // ────────────────────────────────────────────────────────────

    void Start()
    {
        _mainCamera = Camera.main;
        BuildBoard();
        SetupInitialPosition();
    }

    void Update()
    {
        HandleInput();
    }

    // ────────────────────────────────────────────────────────────
    //  Board Construction
    // ────────────────────────────────────────────────────────────

    void BuildBoard()
    {
        for (int rank = 0; rank < 8; rank++)
        {
            for (int file = 0; file < 8; file++)
            {
                bool isLight = (rank + file) % 2 != 0;
                GameObject prefab = isLight ? lightSquarePrefab : darkSquarePrefab;

                if (prefab == null)
                {
                    // Fallback: create a simple quad if no prefab assigned
                    prefab = GameObject.CreatePrimitive(PrimitiveType.Quad);
                    prefab.transform.rotation = Quaternion.Euler(90, 0, 0);

                    var renderer = prefab.GetComponent<Renderer>();
                    if (renderer != null)
                    {
                        renderer.material.color = isLight
                            ? new Color(0.91f, 0.84f, 0.69f) // #E8D5B0
                            : new Color(0.42f, 0.27f, 0.14f); // #6B4423
                    }
                }

                Vector3 pos = SquareToWorld(file, rank);
                pos.y = 0;
                GameObject sq = Instantiate(prefab, pos, Quaternion.Euler(90, 0, 0), transform);
                sq.transform.localScale = Vector3.one * squareSize;
                sq.name = $"Square_{(char)('a' + file)}{rank + 1}";
                _squares[file, rank] = sq;
            }
        }
    }

    void SetupInitialPosition()
    {
        SetBoardFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    }

    // ────────────────────────────────────────────────────────────
    //  Flutter → Unity Messages
    // ────────────────────────────────────────────────────────────

    /// <summary>
    /// Called from Flutter: moves a piece with animation.
    /// move format: "e2e4" or "e7e8q" (with promotion)
    /// </summary>
    public void MovePiece(string move)
    {
        if (move.Length < 4) return;

        int fromFile = move[0] - 'a';
        int fromRank = move[1] - '1';
        int toFile   = move[2] - 'a';
        int toRank   = move[3] - '1';

        if (!IsValidSquare(fromFile, fromRank) || !IsValidSquare(toFile, toRank))
            return;

        GameObject piece = _pieces[fromFile, fromRank];
        if (piece == null) return;

        // Remove captured piece
        if (_pieces[toFile, toRank] != null)
        {
            Destroy(_pieces[toFile, toRank]);
            _pieces[toFile, toRank] = null;
        }

        // Handle castling (king moves 2 squares)
        if (_boardChars[fromFile, fromRank] == 'K' || _boardChars[fromFile, fromRank] == 'k')
        {
            int fileDiff = toFile - fromFile;
            if (Mathf.Abs(fileDiff) == 2)
            {
                // Kingside or queenside castle
                int rookFromFile = fileDiff > 0 ? 7 : 0;
                int rookToFile = fileDiff > 0 ? 5 : 3;
                MovePieceInternal(rookFromFile, fromRank, rookToFile, fromRank);
            }
        }

        // Handle en passant (pawn moves diagonally to empty square)
        if ((_boardChars[fromFile, fromRank] == 'P' || _boardChars[fromFile, fromRank] == 'p')
            && fromFile != toFile && _pieces[toFile, toRank] == null)
        {
            // Remove the captured pawn (on the original rank)
            if (_pieces[toFile, fromRank] != null)
            {
                Destroy(_pieces[toFile, fromRank]);
                _pieces[toFile, fromRank] = null;
                _boardChars[toFile, fromRank] = '.';
            }
        }

        // Handle promotion
        if (move.Length >= 5)
        {
            char promoChar = move[4];
            bool isWhite = char.IsUpper(_boardChars[fromFile, fromRank]);
            _boardChars[fromFile, fromRank] = isWhite ? char.ToUpper(promoChar) : char.ToLower(promoChar);

            // Replace piece with promoted piece
            Destroy(piece);
            piece = SpawnPiece(_boardChars[fromFile, fromRank], toFile, toRank);
            _pieces[fromFile, fromRank] = null;
            _pieces[toFile, toRank] = piece;
            _boardChars[toFile, toRank] = _boardChars[fromFile, fromRank];
            _boardChars[fromFile, fromRank] = '.';
            return;
        }

        // Animate the piece to the new position
        MovePieceInternal(fromFile, fromRank, toFile, toRank);
    }

    void MovePieceInternal(int fromFile, int fromRank, int toFile, int toRank)
    {
        GameObject piece = _pieces[fromFile, fromRank];
        if (piece == null) return;

        _pieces[toFile, toRank] = piece;
        _pieces[fromFile, fromRank] = null;

        _boardChars[toFile, toRank] = _boardChars[fromFile, fromRank];
        _boardChars[fromFile, fromRank] = '.';

        Vector3 targetPos = SquareToWorld(toFile, toRank);
        StartCoroutine(AnimateMove(piece, targetPos));
    }

    IEnumerator AnimateMove(GameObject piece, Vector3 target)
    {
        Vector3 start = piece.transform.position;
        float elapsed = 0f;

        while (elapsed < moveAnimDuration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / moveAnimDuration);

            // Smooth step for horizontal movement
            float smooth = t * t * (3f - 2f * t);
            Vector3 pos = Vector3.Lerp(start, target, smooth);

            // Arc for vertical (parabolic)
            float arc = moveArcHeight * 4f * t * (1f - t);
            pos.y += arc;

            piece.transform.position = pos;
            yield return null;
        }

        piece.transform.position = target;
    }

    /// <summary>
    /// Called from Flutter: reset board to initial position.
    /// </summary>
    public void ResetBoard(string _)
    {
        ClearAllPieces();
        SetupInitialPosition();
    }

    /// <summary>
    /// Called from Flutter: set the entire board from a FEN string.
    /// </summary>
    public void SetBoardFen(string fen)
    {
        ClearAllPieces();

        string[] parts = fen.Split(' ');
        string placement = parts[0];
        string[] ranks = placement.Split('/');

        for (int rank = 0; rank < 8; rank++)
        {
            int fenRank = 7 - rank; // FEN starts from rank 8 (index 7)
            if (fenRank < 0 || fenRank >= ranks.Length) continue;

            int file = 0;
            foreach (char c in ranks[rank])
            {
                if (char.IsDigit(c))
                {
                    int emptyCount = c - '0';
                    for (int e = 0; e < emptyCount; e++)
                    {
                        if (file < 8)
                        {
                            _boardChars[file, fenRank] = '.';
                            file++;
                        }
                    }
                }
                else
                {
                    if (file < 8)
                    {
                        _boardChars[file, fenRank] = c;
                        _pieces[file, fenRank] = SpawnPiece(c, file, fenRank);
                        file++;
                    }
                }
            }
        }
    }

    // ────────────────────────────────────────────────────────────
    //  Piece Spawning
    // ────────────────────────────────────────────────────────────

    GameObject SpawnPiece(char fenChar, int file, int rank)
    {
        if (fenChar == '.' || fenChar == ' ') return null;

        bool isWhite = char.IsUpper(fenChar);
        int prefabIndex = PieceCharToIndex(char.ToLower(fenChar));

        if (prefabIndex < 0) return null;

        GameObject[] prefabs = isWhite ? whitePiecePrefabs : blackPiecePrefabs;

        if (prefabs == null || prefabIndex >= prefabs.Length || prefabs[prefabIndex] == null)
        {
            // Fallback: create a simple capsule if no prefab assigned
            GameObject fallback = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            fallback.transform.position = SquareToWorld(file, rank);
            fallback.transform.localScale = Vector3.one * squareSize * 0.35f;
            var renderer = fallback.GetComponent<Renderer>();
            if (renderer != null)
            {
                renderer.material.color = isWhite
                    ? new Color(0.96f, 0.94f, 0.91f) // Cream white
                    : new Color(0.1f, 0.1f, 0.1f);    // Dark
            }
            fallback.name = $"Piece_{fenChar}_{(char)('a' + file)}{rank + 1}";
            return fallback;
        }

        Vector3 pos = SquareToWorld(file, rank);
        GameObject piece = Instantiate(prefabs[prefabIndex], pos, Quaternion.identity, transform);
        piece.name = $"Piece_{fenChar}_{(char)('a' + file)}{rank + 1}";

        // Rotate black pieces to face the other direction
        if (!isWhite)
        {
            piece.transform.rotation = Quaternion.Euler(0, 180, 0);
        }

        return piece;
    }

    int PieceCharToIndex(char c)
    {
        switch (c)
        {
            case 'p': return 0; // Pawn
            case 'n': return 1; // Knight
            case 'b': return 2; // Bishop
            case 'r': return 3; // Rook
            case 'q': return 4; // Queen
            case 'k': return 5; // King
            default: return -1;
        }
    }

    void ClearAllPieces()
    {
        for (int f = 0; f < 8; f++)
        {
            for (int r = 0; r < 8; r++)
            {
                if (_pieces[f, r] != null)
                {
                    Destroy(_pieces[f, r]);
                    _pieces[f, r] = null;
                }
                _boardChars[f, r] = '.';
            }
        }
    }

    // ────────────────────────────────────────────────────────────
    //  Player Input (Touch / Click → select & drag pieces)
    // ────────────────────────────────────────────────────────────

    void HandleInput()
    {
        if (_mainCamera == null) return;

        // Handle touch or mouse
        if (Input.GetMouseButtonDown(0))
        {
            OnPointerDown(Input.mousePosition);
        }
        else if (Input.GetMouseButton(0) && _isDragging)
        {
            OnPointerDrag(Input.mousePosition);
        }
        else if (Input.GetMouseButtonUp(0) && _isDragging)
        {
            OnPointerUp(Input.mousePosition);
        }
    }

    void OnPointerDown(Vector3 screenPos)
    {
        Ray ray = _mainCamera.ScreenPointToRay(screenPos);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            // Check if we hit a piece
            GameObject hitObj = hit.collider.gameObject;

            for (int f = 0; f < 8; f++)
            {
                for (int r = 0; r < 8; r++)
                {
                    if (_pieces[f, r] != null && (_pieces[f, r] == hitObj || _pieces[f, r].transform.IsChildOf(hitObj.transform) || hitObj.transform.IsChildOf(_pieces[f, r].transform)))
                    {
                        _selectedPiece = _pieces[f, r];
                        _selectedFile = f;
                        _selectedRank = r;
                        _isDragging = true;

                        // Create drag plane at piece height
                        _dragPlane = new Plane(Vector3.up, _selectedPiece.transform.position);
                        return;
                    }
                }
            }
        }
    }

    void OnPointerDrag(Vector3 screenPos)
    {
        if (_selectedPiece == null) return;

        Ray ray = _mainCamera.ScreenPointToRay(screenPos);
        float enter;

        if (_dragPlane.Raycast(ray, out enter))
        {
            Vector3 worldPos = ray.GetPoint(enter);
            worldPos.y = pieceHeight + 0.3f; // Lift piece while dragging
            _selectedPiece.transform.position = worldPos;
        }
    }

    void OnPointerUp(Vector3 screenPos)
    {
        if (_selectedPiece == null)
        {
            _isDragging = false;
            return;
        }

        // Determine which square the piece was dropped on
        Vector3 piecePos = _selectedPiece.transform.position;
        int toFile, toRank;
        WorldToSquare(piecePos, out toFile, out toRank);

        if (IsValidSquare(toFile, toRank) && (toFile != _selectedFile || toRank != _selectedRank))
        {
            // Build the move string
            string moveStr = $"{(char)('a' + _selectedFile)}{_selectedRank + 1}{(char)('a' + toFile)}{toRank + 1}";

            // Check for pawn promotion
            char pieceChar = _boardChars[_selectedFile, _selectedRank];
            if ((pieceChar == 'P' && toRank == 7) || (pieceChar == 'p' && toRank == 0))
            {
                moveStr += "q"; // Default to queen promotion
            }

            // Send the move to Flutter for validation
            // Flutter will validate and call MovePiece() back if legal
            SendMoveToFlutter(moveStr);

            // Snap piece back to original position (Flutter will animate if valid)
            _selectedPiece.transform.position = SquareToWorld(_selectedFile, _selectedRank);
        }
        else
        {
            // Invalid drop — snap back
            _selectedPiece.transform.position = SquareToWorld(_selectedFile, _selectedRank);
        }

        _selectedPiece = null;
        _isDragging = false;
    }

    // ────────────────────────────────────────────────────────────
    //  Unity → Flutter Messages
    // ────────────────────────────────────────────────────────────

    void SendMoveToFlutter(string move)
    {
        // flutter_unity_widget intercepts this message
        // and triggers the onUnityMessage callback in Flutter
#if UNITY_ANDROID || UNITY_IOS
        try
        {
            // Use the UnityMessageManager to send data back to Flutter
            UnityMessageManager.Instance.SendMessageToFlutter(move);
        }
        catch (Exception e)
        {
            Debug.LogWarning($"Failed to send message to Flutter: {e.Message}");
        }
#else
        Debug.Log($"[ChessGameManager] Would send to Flutter: {move}");
#endif
    }

    // ────────────────────────────────────────────────────────────
    //  Coordinate Helpers
    // ────────────────────────────────────────────────────────────

    Vector3 SquareToWorld(int file, int rank)
    {
        // Center the board: file 0-7 → x, rank 0-7 → z
        float x = (file - 3.5f) * squareSize;
        float z = (rank - 3.5f) * squareSize;
        return new Vector3(x, pieceHeight, z);
    }

    void WorldToSquare(Vector3 worldPos, out int file, out int rank)
    {
        file = Mathf.RoundToInt(worldPos.x / squareSize + 3.5f);
        rank = Mathf.RoundToInt(worldPos.z / squareSize + 3.5f);
    }

    bool IsValidSquare(int file, int rank)
    {
        return file >= 0 && file < 8 && rank >= 0 && rank < 8;
    }
}
