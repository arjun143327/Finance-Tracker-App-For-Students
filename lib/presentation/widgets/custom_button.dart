import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: AppColors.bgGradientStart,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ).copyWith(
          overlayColor: MaterialStatePropertyAll(AppColors.primaryLight.withOpacity(0.06)),
          shadowColor: MaterialStatePropertyAll(AppColors.primary.withOpacity(0.14)),
          elevation: const MaterialStatePropertyAll(0),
        ),
        child: Text(label.toUpperCase()),
      ),
    );
  }
}
