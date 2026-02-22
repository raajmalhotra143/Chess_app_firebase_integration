import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimens.paddingMd),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar & name
              _ProfileHeader().animate().fadeIn(),

              const SizedBox(height: AppDimens.paddingLg),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLg,
                ),
                child: _StatsRow(),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppDimens.paddingLg),

              // ELO card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLg,
                ),
                child: _EloCard(),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppDimens.paddingLg),

              // Recent games
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Games',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimens.paddingMd),
                    ...List.generate(5, (i) => _GameHistoryItem(index: i)),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppDimens.paddingXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(child: Text('♔', style: TextStyle(fontSize: 52))),
        ),
        const SizedBox(height: AppDimens.paddingMd),
        Text('Player', style: Theme.of(context).textTheme.headlineMedium),
        Text(
          'Member since Feb 2026',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _StatBox('45', 'Wins', AppColors.success),
        SizedBox(width: AppDimens.paddingMd),
        _StatBox('12', 'Losses', AppColors.error),
        SizedBox(width: AppDimens.paddingMd),
        _StatBox('8', 'Draws', AppColors.textSecondary),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBox(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: color),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EloCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.gold.withValues(alpha: 0.3),
      backgroundColor: AppColors.gold.withValues(alpha: 0.05),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: AppColors.gold,
            size: 40,
          ),
          const SizedBox(width: AppDimens.paddingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ELO Rating', style: Theme.of(context).textTheme.bodyMedium),
              ShaderMask(
                shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                child: Text(
                  '1200',
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '+125 this month',
                style: TextStyle(color: AppColors.success, fontSize: 12),
              ),
              Text('Top 42%', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameHistoryItem extends StatelessWidget {
  final int index;
  const _GameHistoryItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final outcomes = ['Win', 'Loss', 'Win', 'Draw', 'Win'];
    final colors = [
      AppColors.success,
      AppColors.error,
      AppColors.success,
      AppColors.textSecondary,
      AppColors.success,
    ];
    final modes = [
      'vs AI Lv.10',
      'vs Magnus_O',
      'vs Friend',
      'Online',
      'vs AI Lv.12',
    ];

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors[index].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '♟',
                style: TextStyle(fontSize: 20, color: colors[index]),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modes[index],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${20 + index} moves  •  Feb ${22 - index}, 2026',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            outcomes[index],
            style: TextStyle(
              color: colors[index],
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
