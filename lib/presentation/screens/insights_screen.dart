import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../widgets/glass_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu_rounded, color: AppColors.textSecondary),
              Text(
                'Insights',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.08),
                child: const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 40),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dining & Groceries',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '14 DAY',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInsightBullet(context, 'Dining spending decreased.', false),
                const SizedBox(height: 8),
                _buildInsightBullet(context, 'Groceries increased by 22%.', true),
                const SizedBox(height: 30),
                // Placeholder for Chart
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: SimpleLineChartPainter(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCategoryInsight(
            context,
            'Transportation',
            'Ride-sharing down 45%.',
            Icons.directions_car_filled_outlined,
          ),
          const SizedBox(height: 20),
          _buildCategoryInsight(
            context,
            'Subscriptions',
            'Save \$280/yr on 4 subscriptions.',
            Icons.autorenew_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBullet(BuildContext context, String text, bool isHighlight) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isHighlight ? AppColors.primary : AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isHighlight ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryInsight(BuildContext context, String title, String subtitle, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.textMuted, size: 28),
        ],
      ),
    );
  }
}

class SimpleLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.2,
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);

    // Draw the dot at the end
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width, size.height * 0.3), 5, dotPaint);

    // Draw dashed secondary line
    final dashPaint = Paint()
      ..color = AppColors.textMuted.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashPath = Path();
    dashPath.moveTo(0, size.height * 0.3);
    dashPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.6,
      size.width,
      size.height * 0.9,
    );

    _drawDashedPath(canvas, dashPath, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double distance = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
