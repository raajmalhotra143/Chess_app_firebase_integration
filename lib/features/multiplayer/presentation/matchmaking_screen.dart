import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Pulse animation circle
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160 + 40 * _pulse.value,
                      height: 160 + 40 * _pulse.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.teal.withValues(alpha: 
                          0.05 * (1 - _pulse.value),
                        ),
                      ),
                    ),
                    Container(
                      width: 120 + 20 * _pulse.value,
                      height: 120 + 20 * _pulse.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.teal.withValues(alpha: 
                          0.1 * (1 - _pulse.value),
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.teal.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.teal, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          '♟',
                          style: TextStyle(fontSize: 48, color: AppColors.teal),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppDimens.paddingXl),

            Text(
                  'Finding Opponent...',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: AppColors.teal),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .then()
                .fadeOut(delay: 800.ms, duration: 400.ms),

            const SizedBox(height: AppDimens.paddingSm),

            Text(
              'ELO range: 1100 – 1300',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
              builder: (ctx, snap) {
                final secs = (snap.data ?? 0) + 1;
                return Text(
                  'Searching for ${secs}s',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLg),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
