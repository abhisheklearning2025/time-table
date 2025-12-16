import 'package:flutter/material.dart';

/// Reusable button widget with Gen-Z styling
/// Supports primary, secondary, and outlined styles
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = ButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  /// Primary button (filled with theme color)
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  }) : style = ButtonStyle.primary;

  /// Secondary button (outlined with theme color)
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  }) : style = ButtonStyle.secondary;

  /// Text button (no background)
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  }) : style = ButtonStyle.text;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && !isLoading && onPressed != null;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                style == ButtonStyle.secondary || style == ButtonStyle.text
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
              ),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty)
          Text(text),
      ],
    );

    switch (style) {
      case ButtonStyle.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: buttonChild,
        );
      case ButtonStyle.secondary:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          child: buttonChild,
        );
      case ButtonStyle.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          child: buttonChild,
        );
    }
  }
}

enum ButtonStyle {
  primary,
  secondary,
  text,
}
