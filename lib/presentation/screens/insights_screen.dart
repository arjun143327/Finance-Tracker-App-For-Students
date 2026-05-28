import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';
import '../widgets/glass_card.dart';
import '../../data/providers/insights_provider.dart';
import '../../data/providers/currency_budget_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    final dailyData = ref.watch(dailySpendingProvider);
    final currency = ref.watch(currencySymbolProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover trends and patterns in your spending.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 24),

          // ─── Dynamic Spending Chart ────────────────────────────────
          _SpendingChartCard(dailyData: dailyData, currency: currency),
          const SizedBox(height: 20),

          // ─── Insight bullets ──────────────────────────────────────
          if (insights.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '7 DAY',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...insights.map(
                    (insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildInsightBullet(
                          context, insight.message, insight.isPositive),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (insights.isNotEmpty)
              _buildHighlightCard(
                context,
                insights.first.title,
                insights.first.message,
                insights.first.isPositive
                    ? Icons.trending_down_rounded
                    : Icons.trending_up_rounded,
                isPositive: insights.first.isPositive,
              ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInsightBullet(
      BuildContext context, String text, bool isPositive) {
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

  Widget _buildHighlightCard(BuildContext context, String title, String subtitle,
      IconData icon, {required bool isPositive}) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spending Chart Card
// ─────────────────────────────────────────────────────────────────────────────

class _SpendingChartCard extends StatelessWidget {
  final List<DailySpend> dailyData;
  final String currency;

  const _SpendingChartCard({required this.dailyData, required this.currency});

  @override
  Widget build(BuildContext context) {
    final hasData = dailyData.any((d) => d.amount > 0);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '30-Day Spending',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasData
                        ? 'Daily expense trend'
                        : 'No expenses logged yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
              if (hasData)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TODAY',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          if (!hasData)
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Text(
                'Start logging expenses to see your spending chart.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            )
          else
            SizedBox(
              height: 140,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withValues(alpha: 0.06),
                      strokeWidth: 0.8,
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false), // Using our own day labels below
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: AppColors.bgGradientStart.withValues(alpha: 0.85),
                      tooltipRoundedRadius: 12,
                      tooltipBorder: const BorderSide(color: AppColors.primary, width: 1.5),
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final d = dailyData[spot.spotIndex];
                          final dateText = d.isToday ? 'Today' : 'Day ${d.day}';
                          return LineTooltipItem(
                            '$dateText\n',
                            const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w400),
                            children: [
                              TextSpan(
                                text: '$currency${spot.y.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyData.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.amount);
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: AppColors.primary,
                      barWidth: 2.4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false), // Hide dots by default, shown on touch
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.28),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (hasData) ...[
            const SizedBox(height: 16),
            // Day labels strip
            _DayLabelsRow(dailyData: dailyData),
            const SizedBox(height: 16),
            // Stats row
            _StatsRow(dailyData: dailyData, currency: currency),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day labels (shows day-of-month for every 5th day)
// ─────────────────────────────────────────────────────────────────────────────

class _DayLabelsRow extends StatelessWidget {
  final List<DailySpend> dailyData;
  const _DayLabelsRow({required this.dailyData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(dailyData.length, (i) {
        final d = dailyData[i];
        final showLabel = i == 0 ||
            i == dailyData.length - 1 ||
            i % 6 == 0;
        return Expanded(
          child: Text(
            showLabel ? '${d.day}' : '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: d.isToday ? AppColors.primary : AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: d.isToday ? FontWeight.w700 : FontWeight.w300,
                ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats strip — peak, avg, total
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<DailySpend> dailyData;
  final String currency;
  const _StatsRow({required this.dailyData, required this.currency});

  @override
  Widget build(BuildContext context) {
    final activeDays = dailyData.where((d) => d.amount > 0).toList();
    final total = activeDays.fold(0.0, (s, d) => s + d.amount);
    final peak = activeDays.isEmpty
        ? 0.0
        : activeDays.map((d) => d.amount).reduce(math.max);
    final avg = activeDays.isEmpty ? 0.0 : total / activeDays.length;

    return Row(
      children: [
        _stat(context, 'TOTAL', '$currency${total.toStringAsFixed(0)}'),
        _stat(context, 'PEAK', '$currency${peak.toStringAsFixed(0)}'),
        _stat(context, 'AVG/DAY', '$currency${avg.toStringAsFixed(0)}'),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Chart Painter — smooth Catmull-Rom spline with gradient fill
// ─────────────────────────────────────────────────────────────────────────────

class DailySpendingChartPainter extends CustomPainter {
  final List<DailySpend> data;

  DailySpendingChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((d) => d.amount).reduce(math.max);
    if (maxVal <= 0) return;

    final points = _buildPoints(size, maxVal);
    if (points.length < 2) return;

    final linePath = _buildSmoothPath(points);

    // ── Gradient fill under curve ──────────────────────────────
    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.28),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // ── Baseline grid lines ────────────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Main line ─────────────────────────────────────────────
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // ── Dot at each non-zero day ───────────────────────────────
    final dotPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.5);
    final todayDotPaint = Paint()..color = AppColors.primary;
    final todayRingPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final whiteCenter = Paint()..color = AppColors.bgGradientStart;

    for (int i = 0; i < points.length; i++) {
      final d = data[i];
      if (d.amount <= 0) continue;

      final pt = points[i];

      if (d.isToday) {
        // Pulsing ring effect
        canvas.drawCircle(pt, 10, todayRingPaint);
        canvas.drawCircle(pt, 5.5, todayDotPaint);
        canvas.drawCircle(pt, 2.5, whiteCenter);
      } else if (d.amount == maxVal) {
        // Peak dot — slightly larger
        canvas.drawCircle(pt, 4, Paint()..color = AppColors.primaryLight);
        canvas.drawCircle(pt, 2, whiteCenter);
      } else {
        canvas.drawCircle(pt, 2.2, dotPaint);
      }
    }

    // ── Peak value label ──────────────────────────────────────
    final peakIdx =
        data.indexWhere((d) => d.amount == maxVal && d.amount > 0);
    if (peakIdx >= 0) {
      final peakPt = points[peakIdx];
      final labelY = (peakPt.dy - 14).clamp(0.0, size.height - 14);
      _drawLabel(
        canvas,
        data[peakIdx].amount.toStringAsFixed(0),
        Offset(peakPt.dx, labelY),
        AppColors.primaryLight,
      );
    }
  }

  // Catmull-Rom → cubic Bezier smooth path
  Path _buildSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  List<Offset> _buildPoints(Size size, double maxVal) {
    final w = size.width;
    final h = size.height;
    final step = w / (data.length - 1);

    return List.generate(data.length, (i) {
      final x = i * step;
      // clamp to 95% height so dots don't clip at bottom
      final y = h - (data[i].amount / maxVal) * h * 0.88;
      return Offset(x, y);
    });
  }

  void _drawLabel(Canvas canvas, String text, Offset offset, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(offset.dx - textPainter.width / 2, offset.dy),
    );
  }

  @override
  bool shouldRepaint(DailySpendingChartPainter old) => old.data != data;
}
