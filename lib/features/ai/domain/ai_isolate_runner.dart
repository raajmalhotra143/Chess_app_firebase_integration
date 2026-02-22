import 'package:flutter/foundation.dart';
import '../domain/chess_ai.dart';
import '../../game/domain/board_state.dart' show BoardState, ChessMove;

/// Runs AI computation off the main thread using Flutter's compute().
/// Works on both native (Isolate) and Flutter Web (Web Worker).
class AiIsolateRunner {
  static Future<ChessMove?> findBestMove({
    required BoardState state,
    required int level,
  }) async {
    return compute(
      _isolateEntry,
      _IsolateMessage(fen: state.toFen(), level: level),
    );
  }

  static ChessMove? _isolateEntry(_IsolateMessage message) {
    final state = BoardState.fromFen(message.fen);
    final ai = ChessAI(level: message.level);
    return ai.findBestMove(state);
  }
}

class _IsolateMessage {
  final String fen;
  final int level;

  const _IsolateMessage({required this.fen, required this.level});
}
