import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _vibration = true;
  bool _showHints = false;
  bool _autoPromotion = false;
  int _boardTheme = 0;
  int _pieceStyle = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'Settings',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader('Sound & Feedback'),
                    _SwitchTile(
                      'Sound Effects',
                      Icons.volume_up_rounded,
                      _sound,
                      (v) => setState(() => _sound = v),
                    ),
                    _SwitchTile(
                      'Vibration',
                      Icons.vibration_rounded,
                      _vibration,
                      (v) => setState(() => _vibration = v),
                    ),
                    const SizedBox(height: AppDimens.paddingLg),
                    const _SectionHeader('Gameplay'),
                    _SwitchTile(
                      'Show Move Hints',
                      Icons.lightbulb_rounded,
                      _showHints,
                      (v) => setState(() => _showHints = v),
                    ),
                    _SwitchTile(
                      'Auto-promote to Queen',
                      Icons.upgrade_rounded,
                      _autoPromotion,
                      (v) => setState(() => _autoPromotion = v),
                    ),
                    const SizedBox(height: AppDimens.paddingLg),
                    const _SectionHeader('Board Theme'),
                    _ThemeSelector(
                      options: const ['Classic', 'Ocean', 'Forest', 'Purple'],
                      colors: const [
                        AppColors.boardDark,
                        Color(0xFF1A4A6B),
                        Color(0xFF1A4A1A),
                        Color(0xFF4A1A6B),
                      ],
                      selected: _boardTheme,
                      onSelect: (i) => setState(() => _boardTheme = i),
                    ),
                    const SizedBox(height: AppDimens.paddingLg),
                    const _SectionHeader('Piece Style'),
                    _ThemeSelector(
                      options: const ['Unicode', 'Flat', 'Classic', 'Neon'],
                      colors: const [
                        AppColors.gold,
                        AppColors.teal,
                        AppColors.blue,
                        AppColors.error,
                      ],
                      selected: _pieceStyle,
                      onSelect: (i) => setState(() => _pieceStyle = i),
                    ),
                    const SizedBox(height: AppDimens.paddingXl),
                    _AccountTile(
                      icon: Icons.history_rounded,
                      label: 'Game History',
                      onTap: () => context.push('/history'),
                    ),
                    _AccountTile(
                      icon: Icons.leaderboard_rounded,
                      label: 'Leaderboard',
                      onTap: () => context.push('/leaderboard'),
                    ),
                    _AccountTile(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      color: AppColors.error,
                      onTap: () => context.go('/welcome'),
                    ),
                    const SizedBox(height: AppDimens.paddingXl),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingMd),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 2,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile(this.label, this.icon, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingSm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimens.paddingMd),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final List<String> options;
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelect;

  const _ThemeSelector({
    required this.options,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.paddingSm,
      children: List.generate(options.length, (i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors[i].withValues(alpha: 0.15)
                  : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              border: Border.all(
                color: isSelected ? colors[i] : const Color(0xFF2A2A3A),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  options[i],
                  style: TextStyle(
                    color: isSelected ? colors[i] : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingMd,
          horizontal: AppDimens.paddingSm,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF2A2A3A))),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: AppDimens.paddingMd),
            Expanded(
              child: Text(label, style: TextStyle(color: c, fontSize: 16)),
            ),
            Icon(Icons.chevron_right_rounded, color: c.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
