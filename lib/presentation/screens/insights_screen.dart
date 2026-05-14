import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../widgets/glass_card.dart';
import '../../data/providers/insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);

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
          if (insights.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Not enough data for insights yet.\nKeep logging your expenses!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weekly Summary',
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
                          '7 DAY',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...insights.map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildInsightBullet(context, insight.message, insight.isPositive),
                      )),
                  const SizedBox(height: 20),
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
            // Example of mapping insights to detailed cards if needed,
            // but the PRD focuses on simple text insights. We'll map the first insight as a highlighted card.
            if (insights.isNotEmpty)
              _buildCategoryInsight(
                context,
                insights.first.title,
                insights.first.message,
                insights.first.isPositive ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                isPositive: insights.first.isPositive,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightBullet(BuildContext context, String text, bool isPositive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isPositive ? AppColors.income : AppColors.expense,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryInsight(BuildContext context, String title, String subtitle, IconData icon, {required bool isPositive}) {
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isPositive ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
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

