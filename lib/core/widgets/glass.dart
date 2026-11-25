import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          const Positioned(
            top: -120,
            left: -60,
            child: _GlowOrb(color: Color(0x330A84FF), size: 260),
          ),
          const Positioned(
            bottom: -100,
            right: -40,
            child: _GlowOrb(color: Color(0x335E5CE6), size: 240),
          ),
          const Positioned(
            top: 240,
            right: -80,
            child: _GlowOrb(color: Color(0x2230D158), size: 180),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 22,
    this.blur = 18,
    this.opacity = 0.12,
    this.borderOpacity = 0.20,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Color.fromRGBO(255, 255, 255, opacity),
            border: Border.all(
              color: Color.fromRGBO(255, 255, 255, borderOpacity),
              width: 1,
            ),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.child,
    this.navigationBar,
  });

  final Widget child;
  final ObstructingPreferredSizeWidget? navigationBar;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      navigationBar: navigationBar,
      child: GlassBackground(
        child: SafeArea(bottom: false, child: child),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final bg = destructive
        ? AppColors.danger
        : (filled ? AppColors.accent : const Color(0x00000000));
    final fg = filled || destructive ? CupertinoColors.white : AppColors.accent;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: bg.withOpacity(filled || destructive ? 0.95 : 0.0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: destructive
                  ? AppColors.danger.withOpacity(0.6)
                  : AppColors.accent.withOpacity(filled ? 0.5 : 0.8),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 16,
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
