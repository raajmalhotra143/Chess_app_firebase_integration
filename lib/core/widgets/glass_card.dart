import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(borderRadius ?? AppDimens.radiusMd),
        border: Border.all(
          color: borderColor ?? const Color(0xFF2A2A3A),
          width: 1.0,
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFF2A2A3A))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFF2A2A3A))),
      ],
    );
  }
}

class ChessGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final double height;
  final IconData? icon;
  final Color textColor;

  const ChessGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = AppColors.goldGradient,
    this.height = 54,
    this.icon,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'Rajdhani',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
