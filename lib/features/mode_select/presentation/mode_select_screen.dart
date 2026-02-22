import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Subtle chess board bg
          Opacity(
            opacity: 0.04,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                final row = index ~/ 8;
                final col = index % 8;
                final isLight = (row + col) % 2 == 0;
                return Container(
                  color: isLight ? AppColors.boardLight : AppColors.boardDark,
                );
              },
            ),
          ),

          SafeArea(
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
                      const SizedBox(width: AppDimens.paddingSm),
                      Text(
                        'Choose Your Mode',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.paddingLg),

                // Mode cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingLg,
                    ),
                    child: Column(
                      children: [
                        // Online card
                        _ModeCard(
                          title: 'Online Multiplayer',
                          subtitle: 'Play against real opponents worldwide',
                          icon: Icons.wifi_rounded,
                          gradientColors: const [
                            Color(0xFF00C9B1),
                            Color(0xFF004D46),
                          ],
                          borderColor: AppColors.teal,
                          badge: 'ONLINE',
                          onTap: () => context.push('/auth/login'),
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                        const SizedBox(height: AppDimens.paddingLg),

                        // Offline card
                        _ModeCard(
                          title: 'Offline Mode',
                          subtitle: 'Play with AI or a local friend',
                          icon: Icons.sports_esports_rounded,
                          gradientColors: const [
                            Color(0xFFD4AF37),
                            Color(0xFF4A3800),
                          ],
                          borderColor: AppColors.gold,
                          badge: 'OFFLINE',
                          onTap: () => _showOfflineOptions(context),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),

                        const Spacer(),

                        // Stats strip
                        _StatsStrip().animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: AppDimens.paddingLg),
                      ],
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

  void _showOfflineOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      builder: (_) => _OfflineOptionsSheet(context: context),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color borderColor;
  final String badge;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.borderColor,
    required this.badge,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _hovered
            ? Matrix4.diagonal3Values(0.97, 0.97, 1.0)
            : Matrix4.identity(),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: widget.borderColor.withValues(alpha: _hovered ? 0.9 : 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.borderColor.withValues(alpha: _hovered ? 0.3 : 0.1),
              blurRadius: _hovered ? 30 : 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Stack(
            children: [
              // Gradient fill
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.gradientColors[0].withValues(alpha: 0.15),
                      widget.gradientColors[1].withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Glass shimmer top-left arc
              Positioned(
                top: -40,
                left: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.gradientColors[0].withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppDimens.paddingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                widget.gradientColors[0].withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusMd,
                            ),
                            border: Border.all(
                              color: widget.gradientColors[0]
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.gradientColors[0],
                            size: 30,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.paddingSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.gradientColors[0].withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusFull,
                            ),
                            border: Border.all(
                              color: widget.gradientColors[0]
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            widget.badge,
                            style: TextStyle(
                              color: widget.gradientColors[0],
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Arrow indicator bottom-right
              Positioned(
                bottom: AppDimens.paddingMd,
                right: AppDimens.paddingMd,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: widget.gradientColors[0].withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A3A)),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '2M+', label: 'Players'),
          _Divider(),
          _StatItem(value: '50K+', label: 'Games/Day'),
          _Divider(),
          _StatItem(value: '15', label: 'AI Levels'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.goldGradient.createShader(bounds),
          child: Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Rajdhani',
                ),
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: const Color(0xFF2A2A3A));
  }
}

class _OfflineOptionsSheet extends StatelessWidget {
  final BuildContext context;
  const _OfflineOptionsSheet({required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
          ),
          const SizedBox(height: AppDimens.paddingLg),
          Text(
            'Offline Mode',
            style: Theme.of(outerContext).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimens.paddingLg),
          _OfflineOption(
            icon: Icons.smart_toy_rounded,
            title: AppStrings.playAI,
            subtitle: '15 difficulty levels',
            color: AppColors.gold,
            onTap: () {
              Navigator.pop(outerContext);
              context.push('/ai-difficulty');
            },
          ),
          const SizedBox(height: AppDimens.paddingMd),
          _OfflineOption(
            icon: Icons.people_rounded,
            title: AppStrings.playFriend,
            subtitle: 'Same device, two players',
            color: AppColors.teal,
            onTap: () {
              Navigator.pop(outerContext);
              context.push('/game', extra: {'mode': 'friend'});
            },
          ),
          const SizedBox(height: AppDimens.paddingLg),
        ],
      ),
    );
  }
}

class _OfflineOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OfflineOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: AppDimens.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}
