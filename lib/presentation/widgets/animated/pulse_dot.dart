import 'package:flutter/material.dart';

/// Animated pulsing dot for current activity indicator
/// Gen-Z style with vibrant colors and smooth animation
class PulseDot extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const PulseDot({
    super.key,
    this.size = 12,
    this.color = Colors.red,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: widget.size / 2,
                spreadRadius: widget.size / 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Row with pulsing dot and text (e.g., "NOW" badge)
class PulseDotLabel extends StatelessWidget {
  final String text;
  final double dotSize;
  final Color dotColor;
  final TextStyle? textStyle;

  const PulseDotLabel({
    super.key,
    required this.text,
    this.dotSize = 8,
    this.dotColor = Colors.red,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = textStyle ??
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: dotColor,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseDot(size: dotSize, color: dotColor),
        const SizedBox(width: 6),
        Text(text, style: defaultTextStyle),
      ],
    );
  }
}
