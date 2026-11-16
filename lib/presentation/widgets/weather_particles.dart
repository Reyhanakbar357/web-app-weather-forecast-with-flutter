import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:weather_app/core/themes/app_theme.dart';

enum WeatherParticleType { rain, snow, stars, clear }

WeatherParticleType getParticleType(String? iconCode) {
  if (iconCode == null) return WeatherParticleType.stars;
  final id = iconCode.length >= 2 ? iconCode.substring(0, 2) : '01';
  switch (id) {
    case '09':
    case '10':
    case '11':
      return WeatherParticleType.rain;
    case '13':
      return WeatherParticleType.snow;
    case '01':
      final isNight = DateTime.now().hour < 6 || DateTime.now().hour > 19;
      return isNight ? WeatherParticleType.stars : WeatherParticleType.clear;
    default:
      return WeatherParticleType.stars;
  }
}

class WeatherParticles extends StatefulWidget {
  final WeatherParticleType type;
  final int count;

  const WeatherParticles({
    super.key,
    required this.type,
    this.count = 60,
  });

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(widget.count, (i) => _Particle.random(_rng, widget.type));
  }

  @override
  void didUpdateWidget(WeatherParticles old) {
    super.didUpdateWidget(old);
    if (old.type != widget.type) _initParticles();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == WeatherParticleType.clear) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: _ParticlePainter(
            particles: _particles,
            progress: _ctrl.value,
            type: widget.type,
          ),
        );
      },
    );
  }
}

class _Particle {
  double x, y, size, speed, opacity, sway;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.sway,
  });

  factory _Particle.random(math.Random rng, WeatherParticleType type) {
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: type == WeatherParticleType.rain
          ? 1 + rng.nextDouble() * 1.5
          : type == WeatherParticleType.snow
              ? 2 + rng.nextDouble() * 4
              : 1 + rng.nextDouble() * 2,
      speed: 0.05 + rng.nextDouble() * 0.12,
      opacity: 0.2 + rng.nextDouble() * 0.65,
      sway: rng.nextDouble() * math.pi * 2,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final WeatherParticleType type;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final py = (p.y + progress * p.speed * 3) % 1.0;
      double px = p.x;

      if (type == WeatherParticleType.snow) {
        px = (p.x + math.sin(p.sway + progress * math.pi * 2) * 0.04) % 1.0;
      } else if (type == WeatherParticleType.stars) {
        final twinkle = 0.4 + 0.6 * math.sin(progress * math.pi * 2 + p.sway);
        final paint = Paint()
          ..color = Colors.white.withAlphaSafe(p.opacity * twinkle)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(p.x * size.width, p.y * size.height), p.size * 0.8, paint);
        continue;
      }

      if (type == WeatherParticleType.rain) {
        final paint = Paint()
          ..color = AppColors.cyan.withAlphaSafe(p.opacity * 0.5)
          ..strokeWidth = p.size
          ..strokeCap = StrokeCap.round;
        final x = px * size.width;
        final y = py * size.height;
        canvas.drawLine(
          Offset(x - 3, y - 10),
          Offset(x + 3, y + 10),
          paint,
        );
      } else if (type == WeatherParticleType.snow) {
        final paint = Paint()
          ..color = Colors.white.withAlphaSafe(p.opacity * 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(px * size.width, py * size.height), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress || old.type != type;
}
