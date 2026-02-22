import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Game History'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        itemCount: 20,
        itemBuilder: (ctx, i) {
          final outcomes = ['Win', 'Loss', 'Draw'];
          final colors = [
            AppColors.success,
            AppColors.error,
            AppColors.textSecondary,
          ];
          final out = i % 3;
          return Container(
            margin: const EdgeInsets.only(bottom: AppDimens.paddingMd),
            padding: const EdgeInsets.all(AppDimens.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppDimens.radius),
              border: const Border.fromBorderSide(
                BorderSide(color: Color(0xFF2A2A3A)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors[out].withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '♟',
                      style: TextStyle(fontSize: 22, color: colors[out]),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game #${i + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${20 + i} moves  •  Blitz 3+2',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      outcomes[out],
                      style: TextStyle(
                        color: colors[out],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Feb ${22 - i % 14}, 2026',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const _players = [
    ('Magnus_O', 2841, '🇳🇴'),
    ('Hikaru_N', 2801, '🇺🇸'),
    ('Fabiano_C', 2795, '🇺🇸'),
    ('Ding_L', 2762, '🇨🇳'),
    ('Ian_N', 2756, '🇷🇺'),
    ('Anish_G', 2745, '🇳🇱'),
    ('Wesley_S', 2741, '🇺🇸'),
    ('Levon_A', 2739, '🇦🇲'),
    ('Alireza_F', 2735, '🇫🇷'),
    ('Player', 1200, '🌟'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        itemCount: _players.length,
        itemBuilder: (ctx, i) {
          final (name, elo, flag) = _players[i];
          final isTop3 = i < 3;
          final medals = ['🥇', '🥈', '🥉'];
          final isYou = i == _players.length - 1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: AppDimens.paddingMd),
            padding: const EdgeInsets.all(AppDimens.paddingMd),
            decoration: BoxDecoration(
              color: isYou
                  ? AppColors.gold.withValues(alpha: 0.08)
                  : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppDimens.radius),
              border: Border.all(
                color: isYou
                    ? AppColors.gold.withValues(alpha: 0.4)
                    : const Color(0xFF2A2A3A),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    isTop3 ? medals[i] : '#${i + 1}',
                    style: TextStyle(
                      fontSize: isTop3 ? 22 : 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingMd),
                Text(flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppDimens.paddingSm),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isYou ? AppColors.gold : AppColors.textPrimary,
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                  child: Text(
                    '$elo',
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
