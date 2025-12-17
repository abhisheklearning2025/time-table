import 'dart:math';
import 'package:flutter/material.dart';

/// Confetti overlay for success celebrations
/// Shows colorful confetti animation on success actions
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    super.key,
    this.onComplete,
  });

  /// Show confetti overlay
  static void show(BuildContext context, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => ConfettiOverlay(onComplete: onComplete),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
      onComplete?.call();
    });
  }

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Create particles
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1,
        color: _getRandomColor(),
        size: _random.nextDouble() * 8 + 4,
        rotation: _random.nextDouble() * 2 * pi,
        velocityX: (_random.nextDouble() - 0.5) * 2,
        velocityY: _random.nextDouble() * 2 + 1,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }

    // Animate
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double velocityX;
  final double velocityY;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.velocityX,
    required this.velocityY,
    required this.rotationSpeed,
  });

  void update(double dt) {
    x += velocityX * dt;
    y += velocityY * dt;
    rotation += rotationSpeed * dt;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Update particle position
      particle.update(0.016); // ~60fps

      // Calculate screen position
      final x = particle.x * size.width;
      final y = particle.y * size.height;

      // Don't draw if off screen
      if (y > size.height) continue;

      // Calculate opacity (fade out near end)
      final opacity = progress < 0.8 ? 1.0 : (1.0 - (progress - 0.8) / 0.2);

      // Draw confetti piece
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
