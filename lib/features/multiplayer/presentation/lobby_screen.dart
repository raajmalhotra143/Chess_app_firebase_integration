import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Text(
                      'Online Multiplayer',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/profile'),
                    icon: const Icon(
                      Icons.person_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/leaderboard'),
                    icon: const Icon(
                      Icons.leaderboard_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Player rating card
            _PlayerRatingCard().animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppDimens.paddingMd),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLg,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppDimens.radius),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radius),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Quick Match'),
                  Tab(text: 'Create Room'),
                  Tab(text: 'Join Room'),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.paddingMd),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [_QuickMatchTab(), _CreateRoomTab(), _JoinRoomTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRatingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingLg),
      padding: const EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1C27), Color(0xFF13131A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: const Center(
              child: Text(
                '♔',
                style: TextStyle(fontSize: 28, color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Player', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    _RatingChip(label: '⚡ 1200', color: AppColors.gold),
                    SizedBox(width: 8),
                    _RatingChip(label: '🎯 45W 12L', color: AppColors.teal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final Color color;
  const _RatingChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuickMatchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      child: Column(
        children: [
          Text(
            'Select Time Control',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimens.paddingLg),
          _TimeControlGrid(),
          const Spacer(),
          ChessGradientButton(
            label: 'FIND OPPONENT',
            icon: Icons.search_rounded,
            onTap: () => context.push('/matchmaking'),
          ),
          const SizedBox(height: AppDimens.paddingMd),
        ],
      ),
    );
  }
}

class _TimeControlGrid extends StatefulWidget {
  @override
  State<_TimeControlGrid> createState() => _TimeControlGridState();
}

class _TimeControlGridState extends State<_TimeControlGrid> {
  int _selected = 1;

  static const _options = [
    _TimeOption('Bullet', '1+0', Icons.bolt_rounded, AppColors.error),
    _TimeOption('Blitz', '3+2', Icons.flash_on_rounded, AppColors.warning),
    _TimeOption('Rapid', '10+0', Icons.timer_rounded, AppColors.teal),
    _TimeOption(
      'Classical',
      '30+0',
      Icons.hourglass_bottom_rounded,
      AppColors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: AppDimens.paddingMd,
      crossAxisSpacing: AppDimens.paddingMd,
      childAspectRatio: 1.6,
      children: List.generate(_options.length, (i) {
        final opt = _options[i];
        final selected = _selected == i;
        return GestureDetector(
          onTap: () => setState(() => _selected = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? opt.color.withValues(alpha: 0.15)
                  : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppDimens.radius),
              border: Border.all(
                color: selected ? opt.color : const Color(0xFF2A2A3A),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(opt.icon, color: opt.color, size: 28),
                const SizedBox(height: 4),
                Text(
                  opt.name,
                  style: TextStyle(
                    color: selected ? opt.color : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  opt.time,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TimeOption {
  final String name;
  final String time;
  final IconData icon;
  final Color color;
  const _TimeOption(this.name, this.time, this.icon, this.color);
}

class _CreateRoomTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              children: [
                const Text('♟', style: TextStyle(fontSize: 48)),
                const SizedBox(height: AppDimens.paddingMd),
                Text(
                  'Create a private room and share the Room ID with your friend.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingLg),
          _TimeControlGrid(),
          const Spacer(),
          ChessGradientButton(
            label: 'CREATE ROOM',
            icon: Icons.add_rounded,
            onTap: () {
              final roomId =
                  'CM${DateTime.now().millisecondsSinceEpoch % 100000}';
              showDialog(
                context: context,
                builder: (_) => _RoomCreatedDialog(roomId: roomId),
              );
            },
          ),
          const SizedBox(height: AppDimens.paddingMd),
        ],
      ),
    );
  }
}

class _RoomCreatedDialog extends StatelessWidget {
  final String roomId;
  const _RoomCreatedDialog({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      title: const Text(
        'Room Created!',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share this Room ID with your opponent:',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.paddingMd),
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              roomId,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Rajdhani',
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.push('/game', extra: {'mode': 'online', 'roomId': roomId});
          },
          child: const Text(
            'WAIT FOR OPPONENT',
            style: TextStyle(color: AppColors.gold),
          ),
        ),
      ],
    );
  }
}

class _JoinRoomTab extends StatelessWidget {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      child: Column(
        children: [
          Text(
            'Join a Room',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimens.paddingLg),
          TextField(
            controller: _ctrl,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Rajdhani',
              fontSize: 24,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Enter Room ID',
              hintStyle: TextStyle(letterSpacing: 2, fontSize: 16),
            ),
            keyboardType: TextInputType.number,
            maxLength: 10,
          ),
          const Spacer(),
          ChessGradientButton(
            label: 'JOIN ROOM',
            icon: Icons.login_rounded,
            onTap: () {
              if (_ctrl.text.isNotEmpty) {
                context.push(
                  '/game',
                  extra: {'mode': 'online', 'roomId': _ctrl.text},
                );
              }
            },
          ),
          const SizedBox(height: AppDimens.paddingMd),
        ],
      ),
    );
  }
}
