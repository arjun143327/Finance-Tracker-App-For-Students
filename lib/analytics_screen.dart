import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'theme/neo_colors.dart';
import 'goal_creation_screen.dart';
import 'budget_setup_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedPeriod = 'Month';
  String currentMonth = 'January 2026';

  @override
  Widget build(BuildContext context) {
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
                  _buildTopBar(),
                  const SizedBox(height: 24),
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildTimePeriodTabs(),
                  const SizedBox(height: 24),
                  _buildSpendingTrendChart(),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdown(),
                  const SizedBox(height: 24),
                  _buildSmartInsights(),
                  const SizedBox(height: 24),
                  _buildDailyAverage(),
                  const SizedBox(height: 24),
                  _buildExpenseDistribution(),
                  const SizedBox(height: 24),
                  _buildCompareMonths(),
                  const SizedBox(height: 24),
                  _buildExportButton(),
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

  Widget _buildTopBar() {
    return Container(
      height: 80,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Previous month logic
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.chevron_left, size: 20, color: NeoColors.darkGray),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currentMonth,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.darkGray,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Next month logic
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.chevron_right, size: 20, color: NeoColors.darkGray),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
                const Text(
                  '₹2,500',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.black,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '17% less than last month 📉',
                  style: TextStyle(
                    fontSize: 13,
                    color: NeoColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Income: ₹6,000',
                        style: const TextStyle(fontSize: 11, color: NeoColors.black, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Saved: ₹3,500',
                        style: const TextStyle(fontSize: 11, color: NeoColors.green, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Budget Left: ₹3,500',
                        style: const TextStyle(fontSize: 11, color: NeoColors.orange, fontWeight: FontWeight.w700),
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
        onTap: () {
          setState(() {
            selectedPeriod = label;
          });
        },
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

  Widget _buildSpendingTrendChart() {
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
                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      width: constraints.maxWidth,
                      child: CustomPaint(
                        painter: BarChartPainter(),
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

  Widget _buildCategoryBreakdown() {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = math.min(constraints.maxWidth * 0.4, 140.0);
                return Row(
                  children: [
                    SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(chartSize, chartSize),
                            painter: DonutChartPainter(),
                          ),
                          Center(
                            child: Text(
                              '₹2,500',
                              style: TextStyle(
                                fontSize: math.min(chartSize * 0.13, 18),
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
                        children: [
                          _buildLegendItem('🟧', 'Food', '₹1,175 (47%)', NeoColors.orange),
                          const SizedBox(height: 6),
                          _buildLegendItem('🟦', 'Transport', '₹475 (19%)', NeoColors.blue),
                          const SizedBox(height: 6),
                          _buildLegendItem('🟪', 'Entertain.', '₹625 (25%)', const Color(0xFF9775FA)),
                          const SizedBox(height: 6),
                          _buildLegendItem('🟩', 'Shopping', '₹225 (9%)', NeoColors.green),
                        ],
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

  Widget _buildLegendItem(String emoji, String category, String amount, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
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

  Widget _buildSmartInsights() {
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
          _buildInsightCard(
            '🔥',
            "You're on a 5-day logging streak! Keep it up!",
            const Color(0xFFFFF9E6),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            '⚠️',
            "Transport spending is 97% of budget. Watch out!",
            const Color(0xFFFFE5E5),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            '✨',
            "Great! You've saved ₹500 more than last month",
            const Color(0xFFE8F5E9),
          ),
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

  Widget _buildDailyAverage() {
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
            const Text(
              '₹147/day',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: NeoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Budget allows ₹205/day',
              style: TextStyle(
                fontSize: 13,
                color: NeoColors.green,
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
                widthFactor: 0.72,
                child: Container(color: NeoColors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDistribution() {
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
                    painter: DayOfWeekChartPainter(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareMonths() {
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'December',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NeoColors.gray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: NeoColors.gray.withOpacity(0.3),
                              border: Border.all(color: NeoColors.black, width: 3),
                            ),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  '₹3,200',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: NeoColors.black,
                                  ),
                                ),
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
                        children: [
                          const Text(
                            'January',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NeoColors.gray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: NeoColors.orange,
                              border: Border.all(color: NeoColors.black, width: 3),
                            ),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  '₹2,500',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: NeoColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '-22% this month',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          // Export functionality
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: NeoColors.white,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('📊', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Export Report',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.black,
                ),
              ),
            ],
          ),
        ),
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
          Icon(
            icon,
            size: 26,
            color: isActive ? NeoColors.orange : NeoColors.gray,
          ),
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

// Custom Painter for Bar Chart
class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoColors.orange
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = NeoColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final gridPaint = Paint()
      ..color = NeoColors.gray.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Data for 7 days
    final List<double> data = [350, 280, 420, 310, 480, 390, 270];
    final List<String> labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final double barWidth = (size.width - 60) / 7;
    final double maxValue = 500;
    final double chartHeight = size.height - 40;

    // Draw grid lines
    for (int i = 0; i <= 5; i++) {
      final y = chartHeight - (chartHeight * i / 5);
      canvas.drawLine(
        Offset(30, y),
        Offset(size.width - 10, y),
        gridPaint,
      );
    }

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final x = 35 + i * barWidth;
      final barHeight = (data[i] / maxValue) * chartHeight;
      final y = chartHeight - barHeight;

      // Bar fill
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth - 10, barHeight),
        paint,
      );

      // Bar border
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth - 10, barHeight),
        borderPaint,
      );

      // Labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: NeoColors.darkGray,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: barWidth);
      final textX = x + (barWidth - 10) / 2 - textPainter.width / 2;
      final textY = size.height - 25;
      if (textX >= 0 && textX + textPainter.width <= size.width) {
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }

    // Draw average line (dashed)
    final avgY = chartHeight - (380 / maxValue) * chartHeight;
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    double startX = 30;
    
    final dashedPaint = Paint()
      ..color = NeoColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    while (startX < size.width - 10) {
      canvas.drawLine(
        Offset(startX, avgY),
        Offset(math.min(startX + dashWidth, size.width - 10), avgY),
        dashedPaint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(centerX, centerY) - 10;

    final List<double> percentages = [0.47, 0.19, 0.25, 0.09];
    final List<Color> colors = [
      NeoColors.orange,
      NeoColors.blue,
      const Color(0xFF9775FA),
      NeoColors.green,
    ];

    double startAngle = -math.pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = 2 * math.pi * percentages[i];

      // Fill
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius - 15),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Border
      final borderPaint = Paint()
        ..color = NeoColors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius - 15),
        startAngle,
        sweepAngle,
        false,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Outer circle border
    final outerBorderPaint = Paint()
      ..color = NeoColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(centerX, centerY), radius, outerBorderPaint);
    canvas.drawCircle(Offset(centerX, centerY), radius - 30, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Day of Week Chart
class DayOfWeekChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = NeoColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final List<double> data = [200, 350, 280, 320, 600, 450, 400];
    final List<String> labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final double barWidth = (size.width - 40) / 7;
    final double maxValue = 650;
    final double chartHeight = size.height - 30;

    for (int i = 0; i < data.length; i++) {
      final x = 20 + i * barWidth;
      final barHeight = (data[i] / maxValue) * chartHeight;
      final y = chartHeight - barHeight;
      
      // Highlight Friday (index 4)
      paint.color = i == 4 ? NeoColors.orange : NeoColors.white;

      // Bar fill
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth - 8, barHeight),
        paint,
      );

      // Bar border
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth - 8, barHeight),
        borderPaint,
      );

      // Labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: NeoColors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: barWidth);
      final textX = x + (barWidth - 8) / 2 - textPainter.width / 2;
      final textY = size.height - 20;
      if (textX >= 0 && textX + textPainter.width <= size.width) {
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
