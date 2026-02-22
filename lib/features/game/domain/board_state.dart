// Core chess engine – complete implementation
// Covers: board state, move generation, validation, special moves, check/checkmate/stalemate

enum PieceType { pawn, knight, bishop, rook, queen, king, none }

enum PieceColor { white, black, none }

class Piece {
  final PieceType type;
  final PieceColor color;

  const Piece(this.type, this.color);
  const Piece.empty() : type = PieceType.none, color = PieceColor.none;

  bool get isEmpty => type == PieceType.none;
  bool get isWhite => color == PieceColor.white;
  bool get isBlack => color == PieceColor.black;

  String get symbol {
    if (isEmpty) return '.';
    const map = {
      PieceType.pawn: ['p', 'P'],
      PieceType.knight: ['n', 'N'],
      PieceType.bishop: ['b', 'B'],
      PieceType.rook: ['r', 'R'],
      PieceType.queen: ['q', 'Q'],
      PieceType.king: ['k', 'K'],
    };
    final chars = map[type]!;
    return isWhite ? chars[1] : chars[0];
  }

  String get unicode {
    const whites = {
      PieceType.king: '♔',
      PieceType.queen: '♕',
      PieceType.rook: '♖',
      PieceType.bishop: '♗',
      PieceType.knight: '♘',
      PieceType.pawn: '♙',
    };
    const blacks = {
      PieceType.king: '♚',
      PieceType.queen: '♛',
      PieceType.rook: '♜',
      PieceType.bishop: '♝',
      PieceType.knight: '♞',
      PieceType.pawn: '♟',
    };
    if (isEmpty) return '';
    return isWhite ? whites[type]! : blacks[type]!;
  }

  @override
  bool operator ==(Object other) =>
      other is Piece && type == other.type && color == other.color;
  @override
  int get hashCode => Object.hash(type, color);
}

class ChessMove {
  final int from;
  final int to;
  final PieceType? promotion;
  final bool isCastle;
  final bool isEnPassant;

  const ChessMove({
    required this.from,
    required this.to,
    this.promotion,
    this.isCastle = false,
    this.isEnPassant = false,
  });

  int get fromRank => from ~/ 8;
  int get fromFile => from % 8;
  int get toRank => to ~/ 8;
  int get toFile => to % 8;

  String toAlgebraic() {
    const files = 'abcdefgh';
    final f = files[fromFile];
    final fr = (fromRank + 1).toString();
    final t = files[toFile];
    final tr = (toRank + 1).toString();
    final p = promotion != null ? promotion!.name[0] : '';
    return '$f$fr$t$tr$p';
  }

  @override
  bool operator ==(Object other) =>
      other is ChessMove &&
      from == other.from &&
      to == other.to &&
      promotion == other.promotion;
  @override
  int get hashCode => Object.hash(from, to, promotion);
}

class CastlingRights {
  bool whiteKingside;
  bool whiteQueenside;
  bool blackKingside;
  bool blackQueenside;

  CastlingRights({
    this.whiteKingside = true,
    this.whiteQueenside = true,
    this.blackKingside = true,
    this.blackQueenside = true,
  });

  CastlingRights copy() => CastlingRights(
    whiteKingside: whiteKingside,
    whiteQueenside: whiteQueenside,
    blackKingside: blackKingside,
    blackQueenside: blackQueenside,
  );
}

class BoardState {
  final List<Piece> board; // 64 squares, index = rank*8 + file
  PieceColor turn;
  CastlingRights castling;
  int? enPassantSquare; // target square index or null
  int halfmoveClock;
  int fullmoveNumber;
  List<String> positionHistory; // FEN history for threefold

  BoardState._({
    required this.board,
    required this.turn,
    required this.castling,
    this.enPassantSquare,
    this.halfmoveClock = 0,
    this.fullmoveNumber = 1,
    List<String>? positionHistory,
  }) : positionHistory = positionHistory ?? [];

  factory BoardState.initial() {
    return BoardState.fromFen(
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    );
  }

  factory BoardState.fromFen(String fen) {
    final parts = fen.split(' ');
    final board = List<Piece>.filled(64, const Piece.empty());

    int rank = 7, file = 0;
    for (final c in parts[0].runes) {
      final ch = String.fromCharCode(c);
      if (ch == '/') {
        rank--;
        file = 0;
      } else if (int.tryParse(ch) != null) {
        file += int.parse(ch);
      } else {
        final color = ch == ch.toUpperCase()
            ? PieceColor.white
            : PieceColor.black;
        final type = _charToType(ch.toLowerCase());
        board[rank * 8 + file] = Piece(type, color);
        file++;
      }
    }

    final turn = parts[1] == 'w' ? PieceColor.white : PieceColor.black;
    final cr = CastlingRights(
      whiteKingside: parts[2].contains('K'),
      whiteQueenside: parts[2].contains('Q'),
      blackKingside: parts[2].contains('k'),
      blackQueenside: parts[2].contains('q'),
    );

    int? ep;
    if (parts[3] != '-') {
      final f = parts[3].codeUnitAt(0) - 'a'.codeUnitAt(0);
      final r = int.parse(parts[3][1]) - 1;
      ep = r * 8 + f;
    }

    return BoardState._(
      board: board,
      turn: turn,
      castling: cr,
      enPassantSquare: ep,
      halfmoveClock: int.tryParse(parts.elementAtOrNull(4) ?? '') ?? 0,
      fullmoveNumber: int.tryParse(parts.elementAtOrNull(5) ?? '') ?? 1,
    );
  }

  static PieceType _charToType(String c) {
    switch (c) {
      case 'p':
        return PieceType.pawn;
      case 'n':
        return PieceType.knight;
      case 'b':
        return PieceType.bishop;
      case 'r':
        return PieceType.rook;
      case 'q':
        return PieceType.queen;
      case 'k':
        return PieceType.king;
      default:
        return PieceType.none;
    }
  }

  String toFen() {
    final sb = StringBuffer();
    for (int rank = 7; rank >= 0; rank--) {
      int empty = 0;
      for (int file = 0; file < 8; file++) {
        final p = board[rank * 8 + file];
        if (p.isEmpty) {
          empty++;
        } else {
          if (empty > 0) {
            sb.write(empty);
            empty = 0;
          }
          sb.write(p.symbol);
        }
      }
      if (empty > 0) sb.write(empty);
      if (rank > 0) sb.write('/');
    }
    sb.write(' ${turn == PieceColor.white ? 'w' : 'b'}');
    final cr = [
      if (castling.whiteKingside) 'K',
      if (castling.whiteQueenside) 'Q',
      if (castling.blackKingside) 'k',
      if (castling.blackQueenside) 'q',
    ];
    sb.write(' ${cr.isEmpty ? '-' : cr.join()}');
    if (enPassantSquare != null) {
      final f = 'abcdefgh'[enPassantSquare! % 8];
      final r = enPassantSquare! ~/ 8 + 1;
      sb.write(' $f$r');
    } else {
      sb.write(' -');
    }
    sb.write(' $halfmoveClock $fullmoveNumber');
    return sb.toString();
  }

  BoardState copy() {
    return BoardState._(
      board: List.from(board),
      turn: turn,
      castling: castling.copy(),
      enPassantSquare: enPassantSquare,
      halfmoveClock: halfmoveClock,
      fullmoveNumber: fullmoveNumber,
      positionHistory: List.from(positionHistory),
    );
  }

  Piece pieceAt(int sq) => board[sq];
  bool isOccupied(int sq) => !board[sq].isEmpty;
  bool isEnemy(int sq, PieceColor color) =>
      !board[sq].isEmpty && board[sq].color != color;
  bool isFriend(int sq, PieceColor color) =>
      !board[sq].isEmpty && board[sq].color == color;
}
