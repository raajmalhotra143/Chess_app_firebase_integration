import 'board_state.dart';

class MoveGenerator {
  /// Returns ALL pseudo-legal moves for the given color (may leave king in check)
  static List<ChessMove> generatePseudoMoves(
    BoardState state,
    PieceColor color,
  ) {
    final moves = <ChessMove>[];
    for (int sq = 0; sq < 64; sq++) {
      final piece = state.board[sq];
      if (piece.isEmpty || piece.color != color) continue;
      switch (piece.type) {
        case PieceType.pawn:
          moves.addAll(_pawnMoves(state, sq, color));
          break;
        case PieceType.knight:
          moves.addAll(_knightMoves(state, sq, color));
          break;
        case PieceType.bishop:
          moves.addAll(_slidingMoves(state, sq, color, _bishopDirs));
          break;
        case PieceType.rook:
          moves.addAll(_slidingMoves(state, sq, color, _rookDirs));
          break;
        case PieceType.queen:
          moves.addAll(_slidingMoves(state, sq, color, _allDirs));
          break;
        case PieceType.king:
          moves.addAll(_kingMoves(state, sq, color));
          break;
        default:
          break;
      }
    }
    return moves;
  }

  /// Returns legal moves (pseudo + check filter + castling)
  static List<ChessMove> generateLegalMoves(
    BoardState state,
    PieceColor color,
  ) {
    final pseudo = generatePseudoMoves(state, color);
    final legal = <ChessMove>[];
    for (final move in pseudo) {
      final next = applyMove(state, move);
      if (!isInCheck(next, color)) {
        legal.add(move);
      }
    }
    // Castling
    legal.addAll(_castlingMoves(state, color));
    return legal;
  }

  static bool isInCheck(BoardState state, PieceColor color) {
    final kingSquare = _findKing(state, color);
    if (kingSquare == -1) return false;
    final enemy =
        color == PieceColor.white ? PieceColor.black : PieceColor.white;
    final enemyMoves = generatePseudoMoves(state, enemy);
    return enemyMoves.any((m) => m.to == kingSquare);
  }

  static bool isCheckmate(BoardState state, PieceColor color) {
    return isInCheck(state, color) && generateLegalMoves(state, color).isEmpty;
  }

  static bool isStalemate(BoardState state, PieceColor color) {
    return !isInCheck(state, color) && generateLegalMoves(state, color).isEmpty;
  }

  static int _findKing(BoardState state, PieceColor color) {
    for (int sq = 0; sq < 64; sq++) {
      final p = state.board[sq];
      if (p.type == PieceType.king && p.color == color) return sq;
    }
    return -1;
  }

  // ─── Directions ───────────────────────────────────────
  static const _bishopDirs = [9, 7, -9, -7];
  static const _rookDirs = [8, -8, 1, -1];
  static const _allDirs = [8, -8, 1, -1, 9, 7, -9, -7];
  static const _knightJumps = [17, 15, 10, 6, -17, -15, -10, -6];

  // ─── Pawn Moves ───────────────────────────────────────
  static List<ChessMove> _pawnMoves(
    BoardState state,
    int sq,
    PieceColor color,
  ) {
    final moves = <ChessMove>[];
    final dir = color == PieceColor.white ? 1 : -1;
    final rank = sq ~/ 8;
    final file = sq % 8;
    final startRank = color == PieceColor.white ? 1 : 6;
    final promoRank = color == PieceColor.white ? 7 : 0;

    void addPawnMove(int to) {
      final toRank = to ~/ 8;
      if (toRank == promoRank) {
        for (final p in [
          PieceType.queen,
          PieceType.rook,
          PieceType.bishop,
          PieceType.knight,
        ]) {
          moves.add(ChessMove(from: sq, to: to, promotion: p));
        }
      } else {
        moves.add(ChessMove(from: sq, to: to));
      }
    }

    // Forward
    if (_inBounds(rank + dir, file)) {
      final forward = (rank + dir) * 8 + file;
      if (!state.isOccupied(forward)) {
        addPawnMove(forward);
        // Double push
        if (rank == startRank) {
          final dbl = (rank + dir * 2) * 8 + file;
          if (!state.isOccupied(dbl)) {
            moves.add(ChessMove(from: sq, to: dbl));
          }
        }
      }
    }

    // Captures
    for (final df in [-1, 1]) {
      if (!_inBounds(rank + dir, file + df)) continue;
      final cap = (rank + dir) * 8 + (file + df);
      if (state.isEnemy(cap, color)) addPawnMove(cap);
      // En passant
      if (cap == state.enPassantSquare) {
        moves.add(ChessMove(from: sq, to: cap, isEnPassant: true));
      }
    }
    return moves;
  }

  // ─── Knight Moves ─────────────────────────────────────
  static List<ChessMove> _knightMoves(
    BoardState state,
    int sq,
    PieceColor color,
  ) {
    final moves = <ChessMove>[];
    final rank = sq ~/ 8;
    final file = sq % 8;
    for (final jump in _knightJumps) {
      final to = sq + jump;
      if (to < 0 || to >= 64) continue;
      final tr = to ~/ 8, tf = to % 8;
      if ((tr - rank).abs() + (tf - file).abs() != 3) {
        continue; // board wrap check
      }
      if (!state.isFriend(to, color)) moves.add(ChessMove(from: sq, to: to));
    }
    return moves;
  }

  // ─── Sliding Moves ────────────────────────────────────
  static List<ChessMove> _slidingMoves(
    BoardState state,
    int sq,
    PieceColor color,
    List<int> dirs,
  ) {
    final moves = <ChessMove>[];
    final rank = sq ~/ 8;
    final file = sq % 8;
    for (final dir in dirs) {
      int cr = rank, cf = file;
      while (true) {
        int nr = cr + (dir == 8 || dir == -8 ? (dir > 0 ? 1 : -1) : 0);
        int nf = cf + (dir == 1 || dir == -1 ? (dir > 0 ? 1 : -1) : 0);
        // Diagonal dirs
        if (dir == 9) {
          nr = cr + 1;
          nf = cf + 1;
        }
        if (dir == 7) {
          nr = cr + 1;
          nf = cf - 1;
        }
        if (dir == -9) {
          nr = cr - 1;
          nf = cf - 1;
        }
        if (dir == -7) {
          nr = cr - 1;
          nf = cf + 1;
        }
        if (!_inBounds(nr, nf)) break;
        final to = nr * 8 + nf;
        if (state.isFriend(to, color)) break;
        moves.add(ChessMove(from: sq, to: to));
        if (state.isEnemy(to, color)) break;
        cr = nr;
        cf = nf;
      }
    }
    return moves;
  }

  // ─── King Moves ───────────────────────────────────────
  static List<ChessMove> _kingMoves(
    BoardState state,
    int sq,
    PieceColor color,
  ) {
    final moves = <ChessMove>[];
    final rank = sq ~/ 8;
    final file = sq % 8;
    for (final dir in _allDirs) {
      int nr = rank, nf = file;
      if (dir == 8) nr++;
      if (dir == -8) nr--;
      if (dir == 1) nf++;
      if (dir == -1) nf--;
      if (dir == 9) {
        nr++;
        nf++;
      }
      if (dir == 7) {
        nr++;
        nf--;
      }
      if (dir == -9) {
        nr--;
        nf--;
      }
      if (dir == -7) {
        nr--;
        nf++;
      }
      if (!_inBounds(nr, nf)) continue;
      final to = nr * 8 + nf;
      if (!state.isFriend(to, color)) {
        moves.add(ChessMove(from: sq, to: to));
      }
    }
    return moves;
  }

  // ─── Castling ─────────────────────────────────────────
  static List<ChessMove> _castlingMoves(BoardState state, PieceColor color) {
    final moves = <ChessMove>[];
    if (isInCheck(state, color)) return moves;
    final isWhite = color == PieceColor.white;
    final rank = isWhite ? 0 : 7;

    // Kingside
    if ((isWhite && state.castling.whiteKingside) ||
        (!isWhite && state.castling.blackKingside)) {
      if (!state.isOccupied(rank * 8 + 5) && !state.isOccupied(rank * 8 + 6)) {
        final pass = applyMove(
          state,
          ChessMove(from: rank * 8 + 4, to: rank * 8 + 5),
        );
        if (!isInCheck(pass, color)) {
          moves.add(
            ChessMove(from: rank * 8 + 4, to: rank * 8 + 6, isCastle: true),
          );
        }
      }
    }

    // Queenside
    if ((isWhite && state.castling.whiteQueenside) ||
        (!isWhite && state.castling.blackQueenside)) {
      if (!state.isOccupied(rank * 8 + 3) &&
          !state.isOccupied(rank * 8 + 2) &&
          !state.isOccupied(rank * 8 + 1)) {
        final pass = applyMove(
          state,
          ChessMove(from: rank * 8 + 4, to: rank * 8 + 3),
        );
        if (!isInCheck(pass, color)) {
          moves.add(
            ChessMove(from: rank * 8 + 4, to: rank * 8 + 2, isCastle: true),
          );
        }
      }
    }
    return moves;
  }

  // ─── Apply Move ───────────────────────────────────────
  static BoardState applyMove(BoardState state, ChessMove move) {
    final next = state.copy();
    final piece = next.board[move.from];
    final isWhite = piece.color == PieceColor.white;

    next.board[move.to] =
        move.promotion != null ? Piece(move.promotion!, piece.color) : piece;
    next.board[move.from] = const Piece.empty();

    // En passant capture
    if (move.isEnPassant) {
      final captureRank = isWhite ? move.toRank - 1 : move.toRank + 1;
      next.board[captureRank * 8 + move.toFile] = const Piece.empty();
    }

    // Castling rook move
    if (move.isCastle) {
      final rank = move.toRank;
      if (move.toFile == 6) {
        // Kingside
        next.board[rank * 8 + 5] = next.board[rank * 8 + 7];
        next.board[rank * 8 + 7] = const Piece.empty();
      } else {
        // Queenside
        next.board[rank * 8 + 3] = next.board[rank * 8 + 0];
        next.board[rank * 8 + 0] = const Piece.empty();
      }
    }

    // Update castling rights
    if (piece.type == PieceType.king) {
      if (isWhite) {
        next.castling.whiteKingside = false;
        next.castling.whiteQueenside = false;
      } else {
        next.castling.blackKingside = false;
        next.castling.blackQueenside = false;
      }
    }
    if (piece.type == PieceType.rook) {
      if (move.from == 0) next.castling.whiteQueenside = false;
      if (move.from == 7) next.castling.whiteKingside = false;
      if (move.from == 56) next.castling.blackQueenside = false;
      if (move.from == 63) next.castling.blackKingside = false;
    }

    // Update en passant
    if (piece.type == PieceType.pawn &&
        (move.toRank - move.fromRank).abs() == 2) {
      next.enPassantSquare =
          ((move.fromRank + move.toRank) ~/ 2) * 8 + move.toFile;
    } else {
      next.enPassantSquare = null;
    }

    // Switch turn
    next.turn = isWhite ? PieceColor.black : PieceColor.white;
    next.halfmoveClock =
        (piece.type == PieceType.pawn || !state.board[move.to].isEmpty)
            ? 0
            : next.halfmoveClock + 1;
    if (!isWhite) next.fullmoveNumber++;

    return next;
  }

  static bool _inBounds(int rank, int file) =>
      rank >= 0 && rank < 8 && file >= 0 && file < 8;
}
