import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'theme/neo_colors.dart';
import 'goal_creation_screen.dart';
import 'budget_setup_screen.dart';
import 'providers/finance_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String selectedPeriod = 'Month';

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: Stack(
        children: [
          // Geometric accents
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: NeoColors.blue,
                border: Border.all(color: NeoColors.black, width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 16,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: NeoColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 2),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(analytics),
                  const SizedBox(height: 24),
                  _buildSummaryCard(analytics),
                  const SizedBox(height: 24),
                  _buildTimePeriodTabs(),
                  const SizedBox(height: 24),
                  _buildSpendingTrendChart(analytics),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdown(analytics),
                  const SizedBox(height: 24),
                  _buildSmartInsights(analytics),
                  const SizedBox(height: 24),
                  _buildDailyAverage(analytics),
                  const SizedBox(height: 24),
                  _buildExpenseDistribution(analytics),
                  const SizedBox(height: 24),
                  _buildCompareMonths(analytics),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(AnalyticsSummary analytics) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            analytics.currentMonthName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NeoColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AnalyticsSummary analytics) {
    final prevSpent = analytics.prevMonthSpent;
    final currSpent = analytics.totalSpent;
    String comparison = '';
    Color compColor = NeoColors.gray;
    if (prevSpent > 0) {
      final diff = ((currSpent - prevSpent) / prevSpent * 100).abs().toStringAsFixed(0);
      if (currSpent < prevSpent) {
        comparison = '$diff% less than last month 📉';
        compColor = NeoColors.green;
      } else if (currSpent > prevSpent) {
        comparison = '$diff% more than last month 📈';
        compColor = NeoColors.red;
      } else {
        comparison = 'Same as last month';
        compColor = NeoColors.gray;
      }
    }

    return Transform.rotate(
      angle: -1.5 * 3.14159 / 180,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: NeoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NeoColors.black, width: 4),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Transform.rotate(
          angle: 1.5 * 3.14159 / 180,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Spent',
                  style: TextStyle(
                    fontSize: 14,
                    color: NeoColors.gray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${analytics.totalSpent.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.black,
                    height: 1,
                  ),
                ),
                if (comparison.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    comparison,
                    style: TextStyle(
                      fontSize: 13,
                      color: compColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Income: ₹${analytics.totalIncome.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11, color: NeoColors.black, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Saved: ₹${(analytics.totalIncome - analytics.totalSpent).clamp(0, double.infinity).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11, color: NeoColors.green, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Budget Left: ₹${analytics.budgetLeft.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: analytics.budgetLeft >= 0 ? NeoColors.orange : NeoColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTab('Week'),
          const SizedBox(width: 12),
          _buildTab('Month'),
          const SizedBox(width: 12),
          _buildTab('Year'),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final isSelected = selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPeriod = label),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? NeoColors.orange : NeoColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NeoColors.black, width: 3),
            boxShadow: [
              BoxShadow(
                color: NeoColors.black,
                offset: Offset(isSelected ? 4 : 2, isSelected ? 4 : 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected ? NeoColors.white : NeoColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingTrendChart(AnalyticsSummary analytics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Trend',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            analytics.dailySpending.isEmpty
                ? 'No data yet'
                : 'Daily breakdown for ${analytics.currentMonthName}',
            style: const TextStyle(fontSize: 12, color: NeoColors.gray),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NeoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NeoColors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: NeoColors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: analytics.dailySpending.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        'Add transactions to see trend',
                        style: TextStyle(color: NeoColors.gray, fontSize: 13),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final now = DateTime.now();
                      return SizedBox(
                        height: 200,
                        width: constraints.maxWidth,
                        child: CustomPaint(
                          painter: DailyBarChartPainter(
                            dailySpending: analytics.dailySpending,
                            daysInMonth: DateUtils.getDaysInMonth(now.year, now.month),
                            today: now.day,
                            dailyAverage: analytics.dailyAverage,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(AnalyticsSummary analytics) {
    final cats = analytics.categoryBreakdown.where((c) => c.amount > 0).take(4).toList();
    final totalSpent = analytics.totalSpent;

    // Colors for donut slices
    const sliceColors = [NeoColors.orange, NeoColors.blue, Color(0xFF9775FA), NeoColors.green];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Spending Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NeoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NeoColors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: NeoColors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: cats.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'No expenses this month yet',
                        style: TextStyle(color: NeoColors.gray, fontSize: 13),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final chartSize = math.min(constraints.maxWidth * 0.4, 140.0);
                      final percentages = cats
                          .map((c) => totalSpent > 0 ? c.amount / totalSpent : 0.0)
                          .toList();

                      return Row(
                        children: [
                          SizedBox(
                            width: chartSize,
                            height: chartSize,
                            child: Stack(
                              children: [
                                CustomPaint(
                                  size: Size(chartSize, chartSize),
                                  painter: DonutChartPainter(percentages: percentages),
                                ),
                                Center(
                                  child: Text(
                                    '₹${totalSpent.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: math.min(chartSize * 0.13, 16),
                                      fontWeight: FontWeight.w900,
                                      color: NeoColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(cats.length, (i) {
                                final cat = cats[i];
                                final pct = totalSpent > 0
                                    ? (cat.amount / totalSpent * 100).toStringAsFixed(0)
                                    : '0';
                                final colorDot = i < sliceColors.length
                                    ? sliceColors[i]
                                    : NeoColors.gray;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _buildLegendItem(
                                    colorDot,
                                    cat.category.split(' ').first,
                                    '₹${cat.amount.toStringAsFixed(0)} ($pct%)',
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String category, String amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: NeoColors.black, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$category $amount',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: NeoColors.darkGray,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartInsights(AnalyticsSummary analytics) {
    final insightStyles = [
      const Color(0xFFFFF9E6), // yellow
      const Color(0xFFFFE5E5), // red
      const Color(0xFFE8F5E9), // green
      const Color(0xFFE3F2FD), // blue
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Insights 💡',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (analytics.smartInsights.isEmpty)
            _buildInsightCard('💡', 'Add transactions to get personalized insights!', insightStyles[0])
          else
            ...List.generate(analytics.smartInsights.length, (i) {
              final insight = analytics.smartInsights[i];
              final bg = insightStyles[i % insightStyles.length];
              // Extract emoji from start of string
              final parts = insight.split(' ');
              final emoji = parts.first;
              final text = parts.skip(1).join(' ');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildInsightCard(emoji, text, bg),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String icon, String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAverage(AnalyticsSummary analytics) {
    final avg = analytics.dailyAverage;
    final budget = analytics.budgetPerDay;
    final pct = budget > 0 ? (avg / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = avg > budget && budget > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NeoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NeoColors.black, width: 4),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Average',
              style: TextStyle(
                fontSize: 14,
                color: NeoColors.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${avg.toStringAsFixed(0)}/day',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: NeoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              budget > 0
                  ? isOverBudget
                      ? 'Over budget! Limit is ₹${budget.toStringAsFixed(0)}/day'
                      : 'Budget allows ₹${budget.toStringAsFixed(0)}/day'
                  : 'Set a budget to see your daily limit',
              style: TextStyle(
                fontSize: 13,
                color: isOverBudget ? NeoColors.red : NeoColors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                border: Border.all(color: NeoColors.black, width: 3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(color: isOverBudget ? NeoColors.red : NeoColors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDistribution(AnalyticsSummary analytics) {
    final dow = analytics.dayOfWeekSpending;
    final maxVal = dow.values.fold(0.0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When do you spend most?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NeoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NeoColors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: NeoColors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: 160,
                  width: constraints.maxWidth,
                  child: CustomPaint(
                    painter: DayOfWeekChartPainter(
                      dayData: dow,
                      maxValue: maxVal > 0 ? maxVal : 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareMonths(AnalyticsSummary analytics) {
    final curr = analytics.totalSpent;
    final prev = analytics.prevMonthSpent;
    final maxVal = math.max(curr, prev);
    final currWidth = maxVal > 0 ? curr / maxVal : 0.0;
    final prevWidth = maxVal > 0 ? prev / maxVal : 0.0;

    String compText = '';
    Color compColor = NeoColors.gray;
    if (prev > 0 && curr > 0) {
      final diff = ((curr - prev) / prev * 100).abs().toStringAsFixed(0);
      if (curr < prev) {
        compText = '-$diff% this month 🎉';
        compColor = NeoColors.green;
      } else {
        compText = '+$diff% this month';
        compColor = NeoColors.red;
      }
    } else if (prev == 0 && curr > 0) {
      compText = 'First month tracking!';
      compColor = NeoColors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compare Months',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NeoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NeoColors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: NeoColors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Prev month
                Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        analytics.prevMonthName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: NeoColors.gray),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        color: const Color(0xFFE5E5E5),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: prevWidth,
                          child: Container(
                            color: NeoColors.gray.withOpacity(0.5),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              prev > 0 ? '₹${prev.toStringAsFixed(0)}' : '—',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeoColors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Current month
                Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        analytics.currentMonthName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeoColors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        color: const Color(0xFFE5E5E5),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: currWidth,
                          child: Container(
                            color: NeoColors.orange,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              curr > 0 ? '₹${curr.toStringAsFixed(0)}' : '—',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeoColors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (compText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    compText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: compColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: NeoColors.white,
        border: Border(top: BorderSide(color: NeoColors.black, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Home", false, () {
            Navigator.pop(context);
          }),
          _buildNavItem(Icons.bar_chart_rounded, "History", true, () {}),
          _buildNavItem(Icons.flag_outlined, "Goals", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoalCreationScreen()),
            );
          }),
          _buildNavItem(Icons.pie_chart_outline, "Budget", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BudgetSetupScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isActive)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                color: NeoColors.orange,
                shape: BoxShape.circle,
              ),
            ),
          Icon(icon, size: 26, color: isActive ? NeoColors.orange : NeoColors.gray),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? NeoColors.orange : NeoColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painters ---

// Bar chart: daily spending for current month
class DailyBarChartPainter extends CustomPainter {
  final Map<int, double> dailySpending;
  final int daysInMonth;
  final int today;
  final double dailyAverage;

  DailyBarChartPainter({
    required this.dailySpending,
    required this.daysInMonth,
    required this.today,
    required this.dailyAverage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Show last 10 days with data (or today's range)
    final activeDays = dailySpending.keys.toList()..sort();
    if (activeDays.isEmpty) return;

    final showDays = activeDays.length > 10 ? activeDays.sublist(activeDays.length - 10) : activeDays;
    final maxVal = dailySpending.values.fold(0.0, (a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = NeoColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final gridPaint = Paint()
      ..color = NeoColors.gray.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double barWidth = (size.width - 40) / showDays.length;
    final double chartHeight = size.height - 35;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(Offset(20, y), Offset(size.width - 10, y), gridPaint);
    }

    for (int i = 0; i < showDays.length; i++) {
      final day = showDays[i];
      final amount = dailySpending[day] ?? 0;
      final x = 20 + i * barWidth;
      final barH = (amount / maxVal) * chartHeight;
      final y = chartHeight - barH;

      paint.color = day == today ? NeoColors.orange : NeoColors.blue.withOpacity(0.7);
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth - 6, barH), paint);
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth - 6, barH), borderPaint);

      // Day label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$day',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: NeoColors.darkGray),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: barWidth);
      textPainter.paint(canvas, Offset(x + (barWidth - 6) / 2 - textPainter.width / 2, size.height - 22));
    }

    // Average dashed line
    if (dailyAverage > 0) {
      final avgY = chartHeight - (dailyAverage / maxVal).clamp(0.0, 1.0) * chartHeight;
      final dashedPaint = Paint()
        ..color = NeoColors.red.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      double startX = 20;
      while (startX < size.width - 10) {
        canvas.drawLine(Offset(startX, avgY), Offset(math.min(startX + 5, size.width - 10), avgY), dashedPaint);
        startX += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DailyBarChartPainter old) =>
      old.dailySpending != dailySpending || old.today != today;
}

// Donut chart with real category percentages
class DonutChartPainter extends CustomPainter {
  final List<double> percentages;

  DonutChartPainter({required this.percentages});

  static const List<Color> _colors = [
    NeoColors.orange,
    NeoColors.blue,
    Color(0xFF9775FA),
    NeoColors.green,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(centerX, centerY) - 10;

    double startAngle = -math.pi / 2;
    final total = percentages.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = 2 * math.pi * percentages[i];
      final color = i < _colors.length ? _colors[i] : NeoColors.gray;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius - 15),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28,
      );

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius - 15),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = NeoColors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      startAngle += sweepAngle;
    }

    // Outer/inner ring borders
    final borderPaint = Paint()
      ..color = NeoColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(centerX, centerY), radius, borderPaint);
    canvas.drawCircle(Offset(centerX, centerY), radius - 30, borderPaint);
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter old) => old.percentages != percentages;
}

// Day of week chart using real data
class DayOfWeekChartPainter extends CustomPainter {
  final Map<String, double> dayData;
  final double maxValue;

  DayOfWeekChartPainter({required this.dayData, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = NeoColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final double barWidth = (size.width - 40) / 7;
    final double chartHeight = size.height - 30;

    // Find highest day
    String? maxDay;
    double maxAmt = 0;
    dayData.forEach((k, v) {
      if (v > maxAmt) { maxAmt = v; maxDay = k; }
    });

    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];
      final amount = dayData[label] ?? 0;
      final x = 20 + i * barWidth;
      final barH = (amount / maxValue) * chartHeight;
      final y = chartHeight - barH;

      paint.color = label == maxDay ? NeoColors.orange : NeoColors.white;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth - 8, barH), paint);
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth - 8, barH), borderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: label.substring(0, 1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeoColors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: barWidth);
      final textX = x + (barWidth - 8) / 2 - textPainter.width / 2;
      textPainter.paint(canvas, Offset(textX, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant DayOfWeekChartPainter old) => old.dayData != dayData;
}
