import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/board_state.dart';
import '../domain/move_generator.dart';
import '../../ai/domain/ai_isolate_runner.dart';

enum GameStatus { playing, check, checkmate, stalemate, draw, resigned }

enum GameMode { ai, friend, online }

class GameState {
  final BoardState board;
  final GameStatus status;
  final GameMode mode;
  final int aiLevel;
  final List<ChessMove> moveHistory;
  final int? selectedSquare;
  final List<int> legalMovesForSelected;
  final bool isFlipped;
  final bool isThinking;
  final int? lastMoveFrom;
  final int? lastMoveTo;
  final List<BoardState> boardHistory; // for undo

  const GameState({
    required this.board,
    this.status = GameStatus.playing,
    this.mode = GameMode.ai,
    this.aiLevel = 5,
    this.moveHistory = const [],
    this.selectedSquare,
    this.legalMovesForSelected = const [],
    this.isFlipped = false,
    this.isThinking = false,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.boardHistory = const [],
  });

  GameState copyWith({
    BoardState? board,
    GameStatus? status,
    GameMode? mode,
    int? aiLevel,
    List<ChessMove>? moveHistory,
    int? selectedSquare,
    bool clearSelected = false,
    List<int>? legalMovesForSelected,
    bool? isFlipped,
    bool? isThinking,
    int? lastMoveFrom,
    int? lastMoveTo,
    List<BoardState>? boardHistory,
  }) {
    return GameState(
      board: board ?? this.board,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      aiLevel: aiLevel ?? this.aiLevel,
      moveHistory: moveHistory ?? this.moveHistory,
      selectedSquare:
          clearSelected ? null : (selectedSquare ?? this.selectedSquare),
      legalMovesForSelected: clearSelected
          ? []
          : (legalMovesForSelected ?? this.legalMovesForSelected),
      isFlipped: isFlipped ?? this.isFlipped,
      isThinking: isThinking ?? this.isThinking,
      lastMoveFrom: lastMoveFrom ?? this.lastMoveFrom,
      lastMoveTo: lastMoveTo ?? this.lastMoveTo,
      boardHistory: boardHistory ?? this.boardHistory,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(GameMode mode, int aiLevel)
      : super(
          GameState(board: BoardState.initial(), mode: mode, aiLevel: aiLevel),
        );

  void selectSquare(int square) {
    final board = state.board;
    final piece = board.pieceAt(square);

    // If clicking the already-selected square, deselect
    if (state.selectedSquare == square) {
      state = state.copyWith(clearSelected: true);
      return;
    }

    // If a square is already selected, try making a move
    if (state.selectedSquare != null &&
        state.legalMovesForSelected.contains(square)) {
      // Look up the real legal move to preserve promotion/castling/en-passant flags.
      // For promotion there are 4 candidates (Q/R/B/N); we default to queen (first).
      final allLegal = MoveGenerator.generateLegalMoves(
        state.board,
        state.board.turn,
      );
      final move = allLegal.firstWhere(
        (m) => m.from == state.selectedSquare! && m.to == square,
        orElse: () => ChessMove(from: state.selectedSquare!, to: square),
      );
      _makeMove(move);
      return;
    }

    // Select a friendly piece
    if (!piece.isEmpty && piece.color == board.turn) {
      final legalMoves = MoveGenerator.generateLegalMoves(
        board,
        board.turn,
      ).where((m) => m.from == square).map((m) => m.to).toList();
      state = state.copyWith(
        selectedSquare: square,
        legalMovesForSelected: legalMoves,
      );
    }
  }

  void makeMove(ChessMove move) => _makeMove(move);

  void _makeMove(ChessMove move) {
    final history = [...state.boardHistory, state.board];
    final nextBoard = MoveGenerator.applyMove(state.board, move);
    final moveList = [...state.moveHistory, move];

    final currentColor = state.board.turn;
    GameStatus nextStatus = GameStatus.playing;

    if (MoveGenerator.isCheckmate(nextBoard, nextBoard.turn)) {
      nextStatus = GameStatus.checkmate;
    } else if (MoveGenerator.isStalemate(nextBoard, nextBoard.turn)) {
      nextStatus = GameStatus.stalemate;
    } else if (MoveGenerator.isInCheck(nextBoard, nextBoard.turn)) {
      nextStatus = GameStatus.check;
    } else if (nextBoard.halfmoveClock >= 100) {
      nextStatus = GameStatus.draw;
    }

    state = state.copyWith(
      board: nextBoard,
      status: nextStatus,
      moveHistory: moveList,
      clearSelected: true,
      lastMoveFrom: move.from,
      lastMoveTo: move.to,
      boardHistory: history,
    );

    // Trigger AI after human move in AI mode (includes when AI is in check)
    if (state.mode == GameMode.ai &&
        nextStatus != GameStatus.checkmate &&
        nextStatus != GameStatus.stalemate &&
        nextStatus != GameStatus.draw &&
        nextStatus != GameStatus.resigned &&
        nextBoard.turn != currentColor) {
      _triggerAI();
    }
  }

  Future<void> _triggerAI() async {
    state = state.copyWith(isThinking: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final move = await AiIsolateRunner.findBestMove(
      state: state.board,
      level: state.aiLevel,
    );
    if (move != null && mounted) {
      _makeMove(move);
    }
    if (mounted) state = state.copyWith(isThinking: false);
  }

  void flipBoard() => state = state.copyWith(isFlipped: !state.isFlipped);

  void undo() {
    if (state.boardHistory.isEmpty) return;
    final prev = state.boardHistory.last;
    final history = state.boardHistory.sublist(
      0,
      state.boardHistory.length - 1,
    );
    final moves = state.moveHistory.isNotEmpty
        ? state.moveHistory.sublist(0, state.moveHistory.length - 1)
        : <ChessMove>[];
    state = state.copyWith(
      board: prev,
      status: GameStatus.playing,
      boardHistory: history,
      moveHistory: moves,
      clearSelected: true,
      isThinking: false,
    );
  }

  void resign() {
    state = state.copyWith(status: GameStatus.resigned, clearSelected: true);
  }

  void newGame() {
    state = GameState(
      board: BoardState.initial(),
      mode: state.mode,
      aiLevel: state.aiLevel,
    );
  }
}

final gameProvider =
    StateNotifierProvider.family<GameNotifier, GameState, (GameMode, int)>(
  (ref, args) => GameNotifier(args.$1, args.$2),
);
