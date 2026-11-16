import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/core/themes/app_theme.dart';

// ── GLASS CARD (dengan real BackdropFilter blur) ─────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? borderColor;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppColors.radiusLg,
    this.borderColor,
    this.gradient,
    this.shadows,
    this.onTap,
    this.blur = 18,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlphaSafe(0.09),
                    Colors.white.withAlphaSafe(0.04),
                  ],
                ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                color: borderColor ?? Colors.white.withAlphaSafe(0.12), width: 1),
            boxShadow: shadows ??
                [
                  BoxShadow(
                      color: Colors.black.withAlphaSafe(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8)),
                ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

// ── NEON BORDER CARD ────────────────────────────────────────
class NeonBorderCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets? padding;
  final double radius;

  const NeonBorderCard(
      {super.key,
      required this.child,
      required this.color,
      this.padding,
      this.radius = AppColors.radiusLg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlphaSafe(0.07),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withAlphaSafe(0.40), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: color.withAlphaSafe(0.18), blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: child,
    );
  }
}

// ── ACCENT BUTTON ───────────────────────────────────────────
class AccentButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final List<Color>? colors;
  final double radius;
  final EdgeInsets? padding;
  final bool isSmall;

  const AccentButton({
    super.key,
    required this.onTap,
    required this.child,
    this.colors,
    this.radius = AppColors.radiusMd,
    this.padding,
    this.isSmall = false,
  });

  @override
  State<AccentButton> createState() => _AccentButtonState();
}

class _AccentButtonState extends State<AccentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors ?? AppColors.gradCyan;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding ??
              EdgeInsets.symmetric(
                  horizontal: widget.isSmall ? 18 : 24,
                  vertical: widget.isSmall ? 11 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: c,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                  color: c.first.withAlphaSafe(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6))
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── SECTION TITLE ────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final Color? accentColor;

  const SectionTitle(this.text,
      {super.key, this.trailing, this.onTrailingTap, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (accentColor ?? AppColors.cyan),
                (accentColor ?? AppColors.cyan).withAlphaSafe(0.2)
              ],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                  color: (accentColor ?? AppColors.cyan).withAlphaSafe(0.6),
                  blurRadius: 8)
            ],
          ),
        ),
        const SizedBox(width: 9),
        Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: (accentColor ?? AppColors.cyan).withAlphaSafe(0.85),
                letterSpacing: .18)),
        if (trailing != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(trailing!,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}

// ── SKY BACKGROUND ───────────────────────────────────────────
Widget skyBackground({required Widget child, List<Color>? colors}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            colors ?? const [AppColors.bg1, AppColors.bg2, AppColors.bg3],
        stops: const [0.0, 0.45, 1.0],
      ),
    ),
    child: child,
  );
}

// ── SHIMMER SKELETON LOADER ──────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerBox(
      {super.key,
      required this.width,
      required this.height,
      this.radius = 12});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _ctrl.value * 3, 0),
              end: Alignment(-0.5 + _ctrl.value * 3, 0),
              colors: [
                Colors.white.withAlphaSafe(0.04),
                Colors.white.withAlphaSafe(0.12),
                Colors.white.withAlphaSafe(0.04),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── SKELETON LOADING CARD ────────────────────────────────────
class WeatherSkeletonLoader extends StatelessWidget {
  const WeatherSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const ShimmerBox(width: 160, height: 28, radius: 8),
            const Spacer(),
            const ShimmerBox(width: 60, height: 20, radius: 10),
          ]),
          const SizedBox(height: 8),
          const ShimmerBox(width: 80, height: 14, radius: 6),
          const SizedBox(height: 28),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              ShimmerBox(width: 130, height: 72, radius: 10),
              SizedBox(height: 10),
              ShimmerBox(width: 100, height: 14, radius: 6),
            ]),
            const Spacer(),
            const ShimmerBox(width: 72, height: 72, radius: 36),
          ]),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
                4,
                (i) => Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                    child: const ShimmerBox(
                        width: 60, height: 14, radius: 6))),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── GLOWING ICON BUTTON ──────────────────────────────────────
class GlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Color? activeColor;
  final double size;

  const GlowIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.activeColor,
    this.size = 18,
  });

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor ?? AppColors.cyan;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.88)
            .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.active
                ? color.withAlphaSafe(0.18)
                : Colors.white.withAlphaSafe(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.active
                  ? color.withAlphaSafe(0.5)
                  : Colors.white.withAlphaSafe(0.10),
            ),
            boxShadow: widget.active
                ? [BoxShadow(color: color.withAlphaSafe(0.25), blurRadius: 12)]
                : null,
          ),
          child: Icon(widget.icon,
              size: widget.size,
              color: widget.active ? color : AppColors.textSub),
        ),
      ),
    );
  }
}

// ── STAT PILL ────────────────────────────────────────────────
class StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const StatPill(
      {super.key,
      required this.emoji,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlphaSafe(0.08),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withAlphaSafe(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: color.withAlphaSafe(0.7))),
      ]),
    );
  }
}

// ── ERROR WIDGET ─────────────────────────────────────────────
class WeatherErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const WeatherErrorWidget({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.red.withAlphaSafe(0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⛈️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.red, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          AccentButton(
            onTap: onRetry,
            colors: const [AppColors.red, AppColors.orange],
            isSmall: true,
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
