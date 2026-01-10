import 'package:flutter/material.dart';
import '../theme/neo_colors.dart';

class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double width;
  final double height;
  final IconData? icon;

  const NeoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width = double.infinity,
    this.height = 60,
    this.icon,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // Shadow Layer
            Positioned(
              top: _isPressed ? 0 : 6,
              left: _isPressed ? 0 : 6,
              right: _isPressed ? 0 : -6,
              bottom: _isPressed ? 0 : -6,
              child: Container(
                decoration: BoxDecoration(
                  color: NeoColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Button Layer
            Positioned.fill(
              bottom: _isPressed ? 0 : 6,
              right: _isPressed ? 0 : 6,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color ?? NeoColors.orange,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoColors.black, width: 3),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.textColor ?? NeoColors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.textColor ?? NeoColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
