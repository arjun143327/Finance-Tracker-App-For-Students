import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/finance_providers.dart';
import 'theme/neo_colors.dart';
import 'add_expense_screen.dart';
import 'goal_creation_screen.dart';
import 'budget_setup_screen.dart';
import 'analytics_screen.dart';
import 'transaction_history_screen.dart';
import 'profile_screen.dart';
import 'sign_in_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 16),
                  _buildBudgetCard(),
                  const SizedBox(height: 24),
                  _buildSpendingCategories(),
                  const SizedBox(height: 24),
                  _buildSavingsGoals(),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(),
                ],
              ),
            ),
          ),
          
          // FAB - Bottom Right
          Positioned(
            bottom: 94,
            right: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: NeoColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: NeoColors.black, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: NeoColors.orange.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                    const BoxShadow(
                      color: NeoColors.black,
                      offset: Offset(8, 8),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: NeoColors.white, size: 32),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _showProfileMenu,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: NeoColors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 3),
              ),
              child: const Center(
                child: Text("R", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: NeoColors.white)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hi Rahul!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.darkGray,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              // Streak Badge - Pill Style
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NeoColors.orange, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("🔥", style: TextStyle(fontSize: 12)),
                    SizedBox(width: 4),
                    Text(
                      "5 day streak",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NeoColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: NeoColors.black, width: 2),
                ),
                child: const Icon(Icons.notifications_outlined, size: 24, color: NeoColors.darkGray),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: NeoColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: NeoColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    final summary = ref.watch(summaryProvider);
    final percent = summary.budgetTotal > 0 ? (summary.budgetSpent / summary.budgetTotal) : 0.0;
    final displayPercent = percent > 1.0 ? 1.0 : percent;

    return Transform.rotate(
      angle: -2.5 * 3.14159 / 180, // Card tilted
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: NeoColors.white,
          borderRadius: BorderRadius.circular(24),
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
          angle: 2.5 * 3.14159 / 180, // Content counter-rotation (horizontal)
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoColors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NeoColors.black, width: 2),
                  ),
                  child: const Text(
                    "THIS MONTH",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "₹${summary.budgetSpent.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.darkGray,
                    height: 1,
                  ),
                ),
                Text(
                  "of ₹${summary.budgetTotal.toStringAsFixed(0)} budget",
                  style: const TextStyle(
                    fontSize: 14,
                    color: NeoColors.gray,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                // Progress Bar - 18px, 3px border, sharp corners
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          border: Border.all(color: NeoColors.black, width: 3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: displayPercent,
                          child: Container(color: percent > 1 ? NeoColors.red : NeoColors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${(percent * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: NeoColors.darkGray),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Bottom Row - Pill Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoPill("📅", "${summary.budgetRemaining < 0 ? 'Over!' : 'Left'}", NeoColors.darkGray),
                     // _buildInfoPill can be improved with calculated days left
                    _buildInfoPill("💡", "Avg ₹${summary.dailyAverage.toStringAsFixed(0)}/day", NeoColors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(String emoji, String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: textColor == NeoColors.green 
            ? NeoColors.green.withOpacity(0.1) 
            : NeoColors.gray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildQuickAction("Add Expense", Icons.receipt_long, NeoColors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
          }),
          const SizedBox(width: 12),
          _buildQuickAction("Add Income", Icons.attach_money, NeoColors.green, () {}),
          const SizedBox(width: 12),
          _buildQuickAction("Split Bill", Icons.call_split, const Color(0xFF9775FA), () {}), // Purple
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: NeoColors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: NeoColors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: NeoColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Where'd it go?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.darkGray,
                ),
              ),
              Text(
                "See All →",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NeoColors.orange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildCategorySpendingSection(ref),
        ),
      ],
    );
  }

  Widget _buildCategorySpendingSection(WidgetRef ref) {
    final categorySpending = ref.watch(categorySpendingProvider);
    
    if (categorySpending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NeoColors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: NeoColors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No budget set. Go to Budget Setup!',
            style: TextStyle(
              color: NeoColors.gray,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: categorySpending.map((cat) {
        // Calculate percentage of CATEGORY BUDGET
        final categoryBudget = cat.categoryBudget;
        final percent = categoryBudget > 0 ? cat.amount / categoryBudget : 0.0;
        final percentLeft = categoryBudget > 0 ? ((categoryBudget - cat.amount) / categoryBudget * 100) : 0.0;
        
        // Color based on percentage of category budget used
        Color color;
        if (percent >= 0.9) {
          color = NeoColors.red; // Over 90% of category budget used
        } else if (percent >= 0.7) {
          color = NeoColors.orange; // 70-90% used
        } else {
          color = NeoColors.green; // Under 70%
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCategoryCard(
            cat.emoji,
            cat.category,
            color,
            percent.clamp(0.0, 1.0),
            '₹${cat.amount.toStringAsFixed(0)}',
            '₹${categoryBudget.toStringAsFixed(0)}',
            '${percentLeft.toStringAsFixed(0)}% left',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(String emoji, String name, Color color, double percent, String used, String total, String leftText) {
    return Container(
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: NeoColors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Row(
          children: [
            // Colored Stripe
            Container(width: 5, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: NeoColors.darkGray,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                used,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: NeoColors.darkGray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "of $total",
                                style: const TextStyle(
                                  color: NeoColors.gray,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E5E5),
                              border: Border.all(color: NeoColors.black, width: 2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percent,
                              child: Container(color: color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          leftText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Your Goals",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: NeoColors.darkGray,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildGoalCard("New Phone", "assets/images/goal_phone.png", NeoColors.blue, 0.7),
              const SizedBox(width: 16),
              _buildGoalCard("Trip to Goa", "assets/images/goal_airplane.png", NeoColors.orange, 0.4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(String title, String imagePath, Color color, double percent) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeoColors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 80, errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.flag, size: 40, color: color),
            );
          }),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: NeoColors.darkGray),
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: NeoColors.gray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: NeoColors.black, width: 1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = ref.watch(transactionsProvider);
    final recentTransactions = transactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.darkGray,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                  );
                },
                child: const Text(
                  "See All →",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NeoColors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentTransactions.isEmpty)
             const Text("No transactions yet.", style: TextStyle(color: NeoColors.gray)),
          
          ...recentTransactions.map((tx) {
             return Column(
               children: [
                 _buildTransactionItem(
                    tx.category.startsWith("Food") ? "🍔" : 
                    tx.category.startsWith("Transport") ? "🚌" : "💰", 
                    tx.title, 
                    "${tx.type == 'income' ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}", 
                    DateFormat('MMM d, h:mm a').format(tx.date)
                 ),
                 const SizedBox(height: 12),
               ]
             );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String icon, String title, String amount, String time) {
    final isPositive = amount.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: NeoColors.black.withOpacity(0.08),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: NeoColors.darkGray),
                ),
                Text(
                  time,
                  style: const TextStyle(color: NeoColors.gray, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isPositive ? NeoColors.green : NeoColors.red,
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
          _buildNavItem(Icons.home, "Home", true, () {}),
          _buildNavItem(Icons.bar_chart_rounded, "History", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
            );
          }),
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

  void _showProfileMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: 80,
            left: 24,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: NeoColors.gray, width: 1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: NeoColors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: NeoColors.black, width: 3),
                                ),
                                child: const Center(
                                  child: Text(
                                    "R",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: NeoColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Rahul Kumar",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: NeoColors.black,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "rahul@student.com",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: NeoColors.gray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                );
                              },
                              child: const Text(
                                "View Profile →",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NeoColors.orange,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu Items
                    _buildMenuItem(
                      icon: Icons.settings,
                      label: "Settings",
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                      showArrow: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.bar_chart,
                      label: "Export Data",
                      onTap: () {
                        Navigator.pop(context);
                        // Export data logic
                      },
                      showArrow: true,
                    ),
                    _buildMenuItemWithToggle(
                      icon: Icons.notifications,
                      label: "Notifications",
                      value: true,
                      onChanged: (value) {
                        // Toggle notifications
                      },
                    ),
                    _buildMenuItemWithToggle(
                      icon: Icons.dark_mode,
                      label: "Dark Mode",
                      value: false,
                      onChanged: null, // Disabled - coming soon
                      isDisabled: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      label: "Logout",
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutConfirmation();
                      },
                      showArrow: false,
                      isLogout: true,
                      hasBorder: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showArrow = false,
    bool isLogout = false,
    bool hasBorder = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: NeoColors.white, width: 3),
            bottom: hasBorder 
                ? const BorderSide(color: NeoColors.gray, width: 1) 
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isLogout ? NeoColors.red : NeoColors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isLogout ? FontWeight.w800 : FontWeight.w600,
                  color: isLogout ? NeoColors.red : NeoColors.black,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: NeoColors.gray,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: NeoColors.white, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isDisabled ? NeoColors.gray : NeoColors.black,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDisabled ? NeoColors.gray : NeoColors.black,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: isDisabled ? null : onChanged,
              activeColor: NeoColors.orange,
              activeTrackColor: NeoColors.orange.withOpacity(0.5),
              inactiveThumbColor: NeoColors.gray,
              inactiveTrackColor: NeoColors.gray.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Logout?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: NeoColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeoColors.black, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // Clear session and navigate to sign in
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeoColors.red,
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
                        child: const Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
