import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';

class AiDifficultyScreen extends StatefulWidget {
  const AiDifficultyScreen({super.key});

  @override
  State<AiDifficultyScreen> createState() => _AiDifficultyScreenState();
}

class _AiDifficultyScreenState extends State<AiDifficultyScreen> {
  int _selectedLevel = 5;

  static const _levels = [
    _LevelInfo('Beginner', 1, 5, AppColors.success, 'Great for new players'),
    _LevelInfo('Casual', 6, 9, AppColors.teal, 'Casual challenge'),
    _LevelInfo('Intermediate', 10, 12, AppColors.blue, 'Solid opponent'),
    _LevelInfo('Advanced', 13, 14, AppColors.warning, 'Tough competition'),
    _LevelInfo('Master', 15, 15, AppColors.error, 'Near unbeatable'),
  ];

  _LevelInfo get _currentTier {
    return _levels.firstWhere(
      (l) => _selectedLevel >= l.minLevel && _selectedLevel <= l.maxLevel,
      orElse: () => _levels.first,
    );
  }

  String get _eloEstimate {
    if (_selectedLevel <= 3) return '~600 ELO';
    if (_selectedLevel <= 5) return '~800 ELO';
    if (_selectedLevel <= 7) return '~1000 ELO';
    if (_selectedLevel <= 9) return '~1200 ELO';
    if (_selectedLevel <= 11) return '~1500 ELO';
    if (_selectedLevel <= 13) return '~1800 ELO';
    if (_selectedLevel == 14) return '~2200 ELO';
    return '~2700+ ELO';
  }

  @override
  Widget build(BuildContext context) {
    final tier = _currentTier;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'AI Difficulty',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLg,
                ),
                child: Column(
                  children: [
                    // Current level display
                    _LevelDisplay(
                      level: _selectedLevel,
                      tier: tier,
                      eloEstimate: _eloEstimate,
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: AppDimens.paddingXl),

                    // Slider
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level 1',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'DIFFICULTY',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    letterSpacing: 2,
                                  ),
                            ),
                            Text(
                              'Level 15',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.paddingSm),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 8,
                            activeTrackColor: tier.color,
                            inactiveTrackColor: AppColors.bgSurface,
                            thumbColor: tier.color,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 14,
                            ),
                            overlayColor: tier.color.withValues(alpha: 0.2),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 24,
                            ),
                          ),
                          child: Slider(
                            value: _selectedLevel.toDouble(),
                            min: 1,
                            max: 15,
                            divisions: 14,
                            onChanged: (v) =>
                                setState(() => _selectedLevel = v.round()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.paddingXl),

                    // Tier grid
                    Text(
                      'DIFFICULTY TIERS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 2,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingMd),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppDimens.paddingMd,
                      crossAxisSpacing: AppDimens.paddingMd,
                      childAspectRatio: 2.5,
                      children: _levels
                          .map(
                            (l) => _TierChip(
                              tier: l,
                              selected: tier == l,
                              onTap: () =>
                                  setState(() => _selectedLevel = l.minLevel),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: AppDimens.paddingXl),

                    // Start button
                    ChessGradientButton(
                      label: 'START GAME',
                      icon: Icons.smart_toy_rounded,
                      onTap: () => context.push(
                        '/game',
                        extra: {'mode': 'ai', 'aiLevel': _selectedLevel},
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelDisplay extends StatelessWidget {
  final int level;
  final _LevelInfo tier;
  final String eloEstimate;

  const _LevelDisplay({
    required this.level,
    required this.tier,
    required this.eloEstimate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: tier.color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: tier.color.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Level number
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: tier.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: tier.color, width: 2),
            ),
            child: Center(
              child: Text(
                '$level',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: tier.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.name,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: tier.color),
                ),
                const SizedBox(height: 4),
                Text(
                  tier.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingSm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: tier.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(
                    eloEstimate,
                    style: TextStyle(
                      color: tier.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  final _LevelInfo tier;
  final bool selected;
  final VoidCallback onTap;

  const _TierChip({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMd,
          vertical: AppDimens.paddingSm,
        ),
        decoration: BoxDecoration(
          color: selected ? tier.color.withValues(alpha: 0.15) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(
            color: selected ? tier.color : const Color(0xFF2A2A3A),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: tier.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tier.name,
                    style: TextStyle(
                      color: selected ? tier.color : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${tier.minLevel}–${tier.maxLevel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelInfo {
  final String name;
  final int minLevel;
  final int maxLevel;
  final Color color;
  final String description;

  const _LevelInfo(
    this.name,
    this.minLevel,
    this.maxLevel,
    this.color,
    this.description,
  );
}
