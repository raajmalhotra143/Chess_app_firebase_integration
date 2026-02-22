import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _shimmerController;
  bool _soundEnabled = true;
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Animated chess board background
          _AnimatedChessBackground(controller: _bgController),

          // Dark gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC0A0A0F),
                  Color(0xE60A0A0F),
                  Color(0xFF0A0A0F),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLg,
              ),
              child: Column(
                children: [
                  // Top bar: sound + theme toggles
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.paddingSm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ToggleButton(
                          icon: _soundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          active: _soundEnabled,
                          onTap: () =>
                              setState(() => _soundEnabled = !_soundEnabled),
                        ),
                        const SizedBox(width: AppDimens.paddingSm),
                        _ToggleButton(
                          icon: _darkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          active: _darkMode,
                          onTap: () => setState(() => _darkMode = !_darkMode),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Logo + App name
                  Column(
                    children: [
                      // King piece logo with glow
                      _GlowingKingLogo(shimmer: _shimmerController),
                      const SizedBox(height: AppDimens.paddingMd),

                      // App name
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.goldGradient.createShader(bounds),
                        child: Text(
                          AppStrings.appName.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: Colors.white,
                                letterSpacing: 6,
                                fontSize: 52,
                              ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 200.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: AppDimens.paddingSm),

                      Text(
                        AppStrings.tagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  Column(
                    children: [
                      // Play button
                      Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusMd,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusMd,
                            ),
                            onTap: () => context.push('/mode-select'),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.black,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PLAY NOW',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: AppDimens.paddingMd),

                      // Settings button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/settings'),
                          icon: const Icon(
                            Icons.settings_rounded,
                            size: 20,
                            color: AppColors.gold,
                          ),
                          label: const Text(
                            'SETTINGS',
                            style: TextStyle(
                              color: AppColors.gold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 700.ms),

                      const SizedBox(height: AppDimens.paddingLg),

                      // Version text
                      Text(
                        'v1.0.0  •  ChessMate Pro',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppDimens.paddingMd),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Chess Board Background ────────────────────────────────────────

class _AnimatedChessBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedChessBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ChessBoardPainter(progress: controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _ChessBoardPainter extends CustomPainter {
  final double progress;
  _ChessBoardPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const int squares = 8;
    final double sqSize = size.width / squares;
    final opacity = 0.08 + 0.04 * sin(progress * 2 * pi);

    for (int row = 0; row < squares + 2; row++) {
      for (int col = 0; col < squares; col++) {
        final isLight = (row + col) % 2 == 0;
        final paint = Paint()
          ..color = isLight
              ? AppColors.boardLight.withValues(alpha: opacity)
              : AppColors.boardDark.withValues(alpha: opacity * 0.5);
        canvas.drawRect(
          Rect.fromLTWH(col * sqSize, (row - 1) * sqSize, sqSize, sqSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ChessBoardPainter old) => old.progress != progress;
}

// ─── Glowing King Logo ────────────────────────────────────────────────────

class _GlowingKingLogo extends StatelessWidget {
  final AnimationController shimmer;
  const _GlowingKingLogo({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, _) {
        final glowRadius = 24.0 + 8.0 * sin(shimmer.value * 2 * pi);
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgCard,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.35),
                blurRadius: glowRadius,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '♚',
              style: TextStyle(fontSize: 60, color: AppColors.gold),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 1000.ms)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1));
      },
    );
  }
}

// ─── Toggle Button ─────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              active ? AppColors.gold.withValues(alpha: 0.15) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(
            color: active
                ? AppColors.gold.withValues(alpha: 0.5)
                : const Color(0xFF2A2A3A),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? AppColors.gold : AppColors.textMuted,
        ),
      ),
    );
  }
}
