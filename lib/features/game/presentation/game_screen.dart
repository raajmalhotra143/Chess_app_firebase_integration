import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../game/domain/board_state.dart';
import 'game_provider.dart';

class GameScreen extends ConsumerWidget {
  final String mode;
  final int aiLevel;
  final String? roomId;

  const GameScreen({
    super.key,
    required this.mode,
    this.aiLevel = 5,
    this.roomId,
  });

  GameMode _parseMode(String m) {
    switch (m) {
      case 'friend':
        return GameMode.friend;
      case 'online':
        return GameMode.online;
      default:
        return GameMode.ai;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameMode = _parseMode(mode);
    final args = (gameMode, aiLevel);
    final gameState = ref.watch(gameProvider(args));
    final notifier = ref.read(gameProvider(args).notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _TopBar(
              mode: gameMode,
              aiLevel: aiLevel,
              gameState: gameState,
              notifier: notifier,
            ),

            // Opponent info
            if (gameMode == GameMode.ai)
              _PlayerBar(
                name: 'ChessMate AI (Lv.$aiLevel)',
                elo: _aiElo(aiLevel),
                isBottom: false,
                isThinking: gameState.isThinking,
              ),

            // Evaluation bar (AI mode)
            if (gameMode == GameMode.ai) _EvaluationBar(gameState: gameState),

            // Chess board
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingSm),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ChessBoardWidget(
                      gameState: gameState,
                      onSquareTap: notifier.selectSquare,
                      flipBoard: gameState.isFlipped,
                    ),
                  ),
                ),
              ),
            ),

            // Player info
            const _PlayerBar(
              name: 'You',
              elo: '1200',
              isBottom: true,
              isThinking: false,
            ),

            // Move history chip strip
            _MoveHistoryStrip(moves: gameState.moveHistory),

            // Action buttons
            _ActionButtons(notifier: notifier, gameState: gameState),

            const SizedBox(height: AppDimens.paddingSm),
          ],
        ),
      ),
    );
  }

  String _aiElo(int level) {
    const elos = [
      '600',
      '600',
      '700',
      '800',
      '900',
      '1000',
      '1100',
      '1200',
      '1350',
      '1500',
      '1650',
      '1800',
      '2000',
      '2200',
      '2700',
    ];
    return elos[level.clamp(1, 15) - 1];
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final GameMode mode;
  final int aiLevel;
  final GameState gameState;
  final GameNotifier notifier;

  const _TopBar({
    required this.mode,
    required this.aiLevel,
    required this.gameState,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMd,
        vertical: AppDimens.paddingSm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  mode == GameMode.ai
                      ? 'vs AI  •  Level $aiLevel'
                      : mode == GameMode.friend
                          ? 'vs Friend'
                          : 'Online',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _statusText(gameState.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _statusColor(gameState.status),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: notifier.flipBoard,
            icon: const Icon(
              Icons.sync_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Flip Board',
          ),
        ],
      ),
    );
  }

  String _statusText(GameStatus s) {
    switch (s) {
      case GameStatus.check:
        return '⚡ Check!';
      case GameStatus.checkmate:
        return '♟ Checkmate!';
      case GameStatus.stalemate:
        return '⚖ Stalemate';
      case GameStatus.draw:
        return '🤝 Draw';
      case GameStatus.resigned:
        return '🏳 Resigned';
      default:
        return '${_turnText()} to move';
    }
  }

  String _turnText() =>
      gameState.board.turn == PieceColor.white ? 'White' : 'Black';

  Color _statusColor(GameStatus s) {
    switch (s) {
      case GameStatus.check:
        return AppColors.warning;
      case GameStatus.checkmate:
        return AppColors.error;
      case GameStatus.draw:
      case GameStatus.stalemate:
        return AppColors.textMuted;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ─── Player Bar ───────────────────────────────────────────────────────────────

class _PlayerBar extends StatelessWidget {
  final String name;
  final String elo;
  final bool isBottom;
  final bool isThinking;

  const _PlayerBar({
    required this.name,
    required this.elo,
    required this.isBottom,
    required this.isThinking,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMd,
        vertical: 4,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isBottom
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isBottom
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : AppColors.teal.withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: Text(
                isBottom ? '♔' : '♚',
                style: TextStyle(
                  fontSize: 22,
                  color: isBottom ? AppColors.gold : AppColors.teal,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text('ELO $elo', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (isThinking)
            const _ThinkingIndicator()
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1200.ms, color: AppColors.teal),
        ],
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Thinking…',
            style: TextStyle(color: AppColors.teal, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Evaluation Bar ───────────────────────────────────────────────────────────

class _EvaluationBar extends StatelessWidget {
  final GameState gameState;
  const _EvaluationBar({required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMd,
        vertical: 4,
      ),
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        color: AppColors.bgSurface,
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A3A)),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.5, // TODO: compute actual eval
          child: Container(
            decoration: const BoxDecoration(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ─── Move History Strip ───────────────────────────────────────────────────────

class _MoveHistoryStrip extends StatelessWidget {
  final List<ChessMove> moves;
  const _MoveHistoryStrip({required this.moves});

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd),
        itemCount: moves.length,
        itemBuilder: (ctx, i) {
          final isWhiteTurn = i % 2 == 0;
          return Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isWhiteTurn
                  ? AppColors.gold.withValues(alpha: 0.1)
                  : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(
                color: isWhiteTurn
                    ? AppColors.gold.withValues(alpha: 0.3)
                    : const Color(0xFF2A2A3A),
              ),
            ),
            child: Text(
              '${i % 2 == 0 ? "${i ~/ 2 + 1}. " : ""}${moves[i].toAlgebraic()}',
              style: TextStyle(
                color: isWhiteTurn ? AppColors.gold : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Rajdhani',
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final GameNotifier notifier;
  final GameState gameState;

  const _ActionButtons({required this.notifier, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final isGameOver = gameState.status == GameStatus.checkmate ||
        gameState.status == GameStatus.stalemate ||
        gameState.status == GameStatus.draw ||
        gameState.status == GameStatus.resigned;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMd,
        vertical: AppDimens.paddingSm,
      ),
      child: Row(
        children: isGameOver
            ? [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: notifier.newGame,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.gold,
                    ),
                    label: const Text(
                      'New Game',
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ),
                ),
              ]
            : [
                _ActionBtn(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onTap: notifier.undo,
                ),
                const SizedBox(width: AppDimens.paddingSm),
                _ActionBtn(
                  icon: Icons.flag_rounded,
                  label: 'Resign',
                  onTap: () => _confirmResign(context),
                  color: AppColors.error,
                ),
                const SizedBox(width: AppDimens.paddingSm),
                _ActionBtn(
                  icon: Icons.handshake_rounded,
                  label: 'Draw',
                  onTap: () {},
                  color: AppColors.textSecondary,
                ),
              ],
      ),
    );
  }

  void _confirmResign(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Resign?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to resign this game?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.resign();
            },
            child: const Text(
              'Resign',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimens.radius),
            border: Border.all(color: c.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: c, size: 18),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Chess Board Widget ───────────────────────────────────────────────────────

class ChessBoardWidget extends StatelessWidget {
  final GameState gameState;
  final void Function(int square) onSquareTap;
  final bool flipBoard;

  const ChessBoardWidget({
    super.key,
    required this.gameState,
    required this.onSquareTap,
    this.flipBoard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemCount: 64,
            itemBuilder: (ctx, index) {
              // Convert grid index → board square.
              // Normal:  top-left = rank 7 file 0 (black side at top)
              // Flipped: top-left = rank 0 file 7 (white side at top, rotated 180°)
              final displayRank = flipBoard ? (index ~/ 8) : 7 - (index ~/ 8);
              final displayFile = flipBoard ? 7 - (index % 8) : (index % 8);
              final boardSq = displayRank * 8 + displayFile;

              return _BoardSquare(
                square: boardSq,
                rank: displayRank,
                file: displayFile,
                gameState: gameState,
                onTap: () => onSquareTap(boardSq),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BoardSquare extends StatelessWidget {
  final int square;
  final int rank;
  final int file;
  final GameState gameState;
  final VoidCallback onTap;

  const _BoardSquare({
    required this.square,
    required this.rank,
    required this.file,
    required this.gameState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = (rank + file) % 2 != 0;
    final piece = gameState.board.pieceAt(square);
    final isSelected = gameState.selectedSquare == square;
    final isLegalMove = gameState.legalMovesForSelected.contains(square);
    final isLastFrom = gameState.lastMoveFrom == square;
    final isLastTo = gameState.lastMoveTo == square;

    Color baseColor = isLight ? AppColors.boardLight : AppColors.boardDark;

    // Highlight overlays
    Color? overlay;
    if (isSelected) {
      overlay = AppColors.selectedHighlight;
    } else if (isLastFrom || isLastTo) {
      overlay = AppColors.lastMoveHighlight;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: baseColor,
        child: Stack(
          children: [
            // Overlay tint
            if (overlay != null) Container(color: overlay),

            // Legal move dot / ring
            if (isLegalMove)
              Center(
                child: piece.isEmpty
                    ? Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.moveHighlight,
                          shape: BoxShape.circle,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.teal.withValues(alpha: 0.7),
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
              ),

            // Piece
            if (!piece.isEmpty)
              Center(
                child: Text(
                  piece.unicode,
                  style: TextStyle(
                    fontSize: 34,
                    color: piece.isWhite
                        ? const Color(0xFFF5F0E8)
                        : const Color(0xFF1A1A1A),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),

            // Rank / file labels (border squares)
            if (file == 0)
              Positioned(
                top: 2,
                left: 3,
                child: Text(
                  '${rank + 1}',
                  style: TextStyle(
                    fontSize: 9,
                    color: isLight ? AppColors.boardDark : AppColors.boardLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (rank == 0)
              Positioned(
                bottom: 2,
                right: 3,
                child: Text(
                  'abcdefgh'[file],
                  style: TextStyle(
                    fontSize: 9,
                    color: isLight ? AppColors.boardDark : AppColors.boardLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
