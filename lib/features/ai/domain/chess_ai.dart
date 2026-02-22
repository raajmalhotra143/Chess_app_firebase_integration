import '../../game/domain/board_state.dart';
import '../../game/domain/move_generator.dart';

/// Minimax engine with Alpha-Beta Pruning, Piece-Square Tables, Move Ordering
class ChessAI {
  final int level; // 1–15

  ChessAI({required this.level});

  int get _searchDepth {
    if (level <= 3) return 1;
    if (level <= 5) return 2;
    if (level <= 7) return 3;
    if (level <= 9) return 4;
    if (level <= 11) return 5;
    if (level <= 13) return 6;
    if (level == 14) return 7;
    return 9; // level 15
  }

  ChessMove? findBestMove(BoardState state) {
    final moves = MoveGenerator.generateLegalMoves(state, state.turn);
    if (moves.isEmpty) return null;

    if (level <= 2) {
      // Random at very low levels
      moves.shuffle();
      return moves.first;
    }

    ChessMove? best;
    int bestScore = state.turn == PieceColor.white ? -999999 : 999999;

    final orderedMoves = _orderMoves(state, moves);

    for (final move in orderedMoves) {
      final next = MoveGenerator.applyMove(state, move);
      final score = _alphaBeta(
        next,
        _searchDepth - 1,
        -999999,
        999999,
        state.turn == PieceColor.white,
      );
      if (state.turn == PieceColor.white && score > bestScore) {
        bestScore = score;
        best = move;
      } else if (state.turn == PieceColor.black && score < bestScore) {
        bestScore = score;
        best = move;
      }
    }
    return best ?? moves.first;
  }

  int _alphaBeta(
    BoardState state,
    int depth,
    int alpha,
    int beta,
    bool maximizing,
  ) {
    if (depth == 0) return _evaluate(state);
    if (MoveGenerator.isCheckmate(state, state.turn)) {
      return maximizing ? -99000 - depth : 99000 + depth;
    }
    if (MoveGenerator.isStalemate(state, state.turn)) return 0;

    final moves = _orderMoves(
      state,
      MoveGenerator.generateLegalMoves(state, state.turn),
    );

    if (maximizing) {
      int val = -999999;
      for (final move in moves) {
        final next = MoveGenerator.applyMove(state, move);
        val = _max(val, _alphaBeta(next, depth - 1, alpha, beta, false));
        alpha = _max(alpha, val);
        if (val >= beta) break;
      }
      return val;
    } else {
      int val = 999999;
      for (final move in moves) {
        final next = MoveGenerator.applyMove(state, move);
        val = _min(val, _alphaBeta(next, depth - 1, alpha, beta, true));
        beta = _min(beta, val);
        if (val <= alpha) break;
      }
      return val;
    }
  }

  // ─── Move Ordering (MVV-LVA) ──────────────────────────
  List<ChessMove> _orderMoves(BoardState state, List<ChessMove> moves) {
    return moves
      ..sort((a, b) {
        final scoreA = _moveScore(state, a);
        final scoreB = _moveScore(state, b);
        return scoreB.compareTo(scoreA);
      });
  }

  int _moveScore(BoardState state, ChessMove move) {
    int score = 0;
    final victim = state.board[move.to];
    final attacker = state.board[move.from];
    if (!victim.isEmpty) {
      // MVV-LVA
      score += _pieceValue(victim.type) * 10 - _pieceValue(attacker.type);
    }
    if (move.promotion != null) {
      score += _pieceValue(move.promotion!);
    }
    return score;
  }

  // ─── Static Evaluation ────────────────────────────────
  int _evaluate(BoardState state) {
    int score = 0;
    for (int sq = 0; sq < 64; sq++) {
      final p = state.board[sq];
      if (p.isEmpty) continue;
      final val = _pieceValue(p.type) + _pstBonus(p, sq);
      score += p.isWhite ? val : -val;
    }
    return score;
  }

  int _pieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return 100;
      case PieceType.knight:
        return 320;
      case PieceType.bishop:
        return 330;
      case PieceType.rook:
        return 500;
      case PieceType.queen:
        return 900;
      case PieceType.king:
        return 20000;
      default:
        return 0;
    }
  }

  // Piece-Square Tables (white perspective, flipped for black)
  int _pstBonus(Piece piece, int sq) {
    final rank = sq ~/ 8;
    final file = sq % 8;
    final r = piece.isWhite ? rank : 7 - rank;
    final idx = r * 8 + file;

    switch (piece.type) {
      case PieceType.pawn:
        return _pstPawn[idx];
      case PieceType.knight:
        return _pstKnight[idx];
      case PieceType.bishop:
        return _pstBishop[idx];
      case PieceType.rook:
        return _pstRook[idx];
      case PieceType.queen:
        return _pstQueen[idx];
      case PieceType.king:
        return _pstKingMid[idx];
      default:
        return 0;
    }
  }

  static int _max(int a, int b) => a > b ? a : b;
  static int _min(int a, int b) => a < b ? a : b;

  // ─── PST Tables ───────────────────────────────────────
  static const _pstPawn = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    50,
    50,
    50,
    50,
    50,
    50,
    50,
    50,
    10,
    10,
    20,
    30,
    30,
    20,
    10,
    10,
    5,
    5,
    10,
    25,
    25,
    10,
    5,
    5,
    0,
    0,
    0,
    20,
    20,
    0,
    0,
    0,
    5,
    -5,
    -10,
    0,
    0,
    -10,
    -5,
    5,
    5,
    10,
    10,
    -20,
    -20,
    10,
    10,
    5,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ];

  static const _pstKnight = [
    -50,
    -40,
    -30,
    -30,
    -30,
    -30,
    -40,
    -50,
    -40,
    -20,
    0,
    0,
    0,
    0,
    -20,
    -40,
    -30,
    0,
    10,
    15,
    15,
    10,
    0,
    -30,
    -30,
    5,
    15,
    20,
    20,
    15,
    5,
    -30,
    -30,
    0,
    15,
    20,
    20,
    15,
    0,
    -30,
    -30,
    5,
    10,
    15,
    15,
    10,
    5,
    -30,
    -40,
    -20,
    0,
    5,
    5,
    0,
    -20,
    -40,
    -50,
    -40,
    -30,
    -30,
    -30,
    -30,
    -40,
    -50,
  ];

  static const _pstBishop = [
    -20,
    -10,
    -10,
    -10,
    -10,
    -10,
    -10,
    -20,
    -10,
    0,
    0,
    0,
    0,
    0,
    0,
    -10,
    -10,
    0,
    5,
    10,
    10,
    5,
    0,
    -10,
    -10,
    5,
    5,
    10,
    10,
    5,
    5,
    -10,
    -10,
    0,
    10,
    10,
    10,
    10,
    0,
    -10,
    -10,
    10,
    10,
    10,
    10,
    10,
    10,
    -10,
    -10,
    5,
    0,
    0,
    0,
    0,
    5,
    -10,
    -20,
    -10,
    -10,
    -10,
    -10,
    -10,
    -10,
    -20,
  ];

  static const _pstRook = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    5,
    10,
    10,
    10,
    10,
    10,
    10,
    5,
    -5,
    0,
    0,
    0,
    0,
    0,
    0,
    -5,
    -5,
    0,
    0,
    0,
    0,
    0,
    0,
    -5,
    -5,
    0,
    0,
    0,
    0,
    0,
    0,
    -5,
    -5,
    0,
    0,
    0,
    0,
    0,
    0,
    -5,
    -5,
    0,
    0,
    0,
    0,
    0,
    0,
    -5,
    0,
    0,
    0,
    5,
    5,
    0,
    0,
    0,
  ];

  static const _pstQueen = [
    -20,
    -10,
    -10,
    -5,
    -5,
    -10,
    -10,
    -20,
    -10,
    0,
    0,
    0,
    0,
    0,
    0,
    -10,
    -10,
    0,
    5,
    5,
    5,
    5,
    0,
    -10,
    -5,
    0,
    5,
    5,
    5,
    5,
    0,
    -5,
    0,
    0,
    5,
    5,
    5,
    5,
    0,
    -5,
    -10,
    5,
    5,
    5,
    5,
    5,
    0,
    -10,
    -10,
    0,
    5,
    0,
    0,
    0,
    0,
    -10,
    -20,
    -10,
    -10,
    -5,
    -5,
    -10,
    -10,
    -20,
  ];

  static const _pstKingMid = [
    -30,
    -40,
    -40,
    -50,
    -50,
    -40,
    -40,
    -30,
    -30,
    -40,
    -40,
    -50,
    -50,
    -40,
    -40,
    -30,
    -30,
    -40,
    -40,
    -50,
    -50,
    -40,
    -40,
    -30,
    -30,
    -40,
    -40,
    -50,
    -50,
    -40,
    -40,
    -30,
    -20,
    -30,
    -30,
    -40,
    -40,
    -30,
    -30,
    -20,
    -10,
    -20,
    -20,
    -20,
    -20,
    -20,
    -20,
    -10,
    20,
    20,
    0,
    0,
    0,
    0,
    20,
    20,
    20,
    30,
    10,
    0,
    0,
    10,
    30,
    20,
  ];
}
