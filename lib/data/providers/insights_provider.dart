import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'user_provider.dart';
import '../models/transaction_model.dart';

class InsightMessage {
  final String title;
  final String message;
  final bool isPositive;

  InsightMessage({
    required this.title,
    required this.message,
    required this.isPositive,
  });
}

// ---------------------------------------------------------------------------
// Insight Engine — accurate behavioral analysis using real transaction data
// ---------------------------------------------------------------------------
final insightsProvider = Provider<List<InsightMessage>>((ref) {
  final txState = ref.watch(transactionsListProvider);
  final profileState = ref.watch(userProfileProvider);

  return txState.maybeWhen(
    data: (transactions) {
      if (transactions.isEmpty) return [];

      final now = DateTime.now();
      final currency = profileState.valueOrNull?.currency ?? '\u20b9';
      final monthlyIncome = profileState.valueOrNull?.income ?? 0.0;

      // ---- Time windows ----
      final thisMonth = transactions.where((t) =>
        t.date.month == now.month && t.date.year == now.year).toList();
      final lastMonthDate = DateTime(now.year, now.month - 1);
      final lastMonth = transactions.where((t) =>
        t.date.month == lastMonthDate.month &&
        t.date.year == lastMonthDate.year).toList();
      final last7 = transactions.where(
        (t) => t.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
      final prev7 = transactions.where((t) =>
        t.date.isAfter(now.subtract(const Duration(days: 14))) &&
        t.date.isBefore(now.subtract(const Duration(days: 7)))).toList();

      // ---- Aggregates ----
      double sumExpenses(List<TransactionModel> list) =>
          list.where((t) => t.type == TransactionType.expense)
              .fold(0.0, (s, t) => s + t.amount);

      double sumIncome(List<TransactionModel> list) =>
          list.where((t) => t.type == TransactionType.income)
              .fold(0.0, (s, t) => s + t.amount);

      Map<String, double> groupByCategory(List<TransactionModel> list) {
        final map = <String, double>{};
        for (final t in list.where((t) => t.type == TransactionType.expense)) {
          map[t.category] = (map[t.category] ?? 0) + t.amount;
        }
        return map;
      }

      final thisMonthSpend  = sumExpenses(thisMonth);
      final lastMonthSpend  = sumExpenses(lastMonth);
      final last7Spend      = sumExpenses(last7);
      final prev7Spend      = sumExpenses(prev7);
      final thisMonthIncome = sumIncome(thisMonth);
      final effectiveIncome = thisMonthIncome > 0 ? thisMonthIncome : monthlyIncome;

      final thisMonthCats = groupByCategory(thisMonth);
      final last7Cats     = groupByCategory(last7);

      final List<InsightMessage> insights = [];

      // ─── 1. Month-over-month spending comparison ───────────────────────────
      if (lastMonthSpend > 0 && thisMonthSpend > 0) {
        final delta = thisMonthSpend - lastMonthSpend;
        final pct   = (delta.abs() / lastMonthSpend * 100).round();
        if (pct >= 5) {
          insights.add(InsightMessage(
            title: delta > 0 ? 'Spending Up This Month' : 'Spending Down This Month',
            message: delta > 0
                ? 'You\'ve spent $currency${thisMonthSpend.toStringAsFixed(0)} so far — '
                  '$pct% more than last month ($currency${lastMonthSpend.toStringAsFixed(0)}).'
                : 'Great discipline! You\'ve spent $pct% less than last month '
                  '($currency${thisMonthSpend.toStringAsFixed(0)} vs $currency${lastMonthSpend.toStringAsFixed(0)}).',
            isPositive: delta < 0,
          ));
        }
      }

      // ─── 2. Weekly spending trend ──────────────────────────────────────────
      if (prev7Spend > 0 && last7Spend > 0) {
        final delta = last7Spend - prev7Spend;
        final pct   = (delta.abs() / prev7Spend * 100).round();
        if (pct >= 10) {
          insights.add(InsightMessage(
            title: delta > 0 ? 'Weekly Spending Increased' : 'Weekly Spending Reduced',
            message: delta > 0
                ? 'You spent $currency${last7Spend.toStringAsFixed(0)} this week — '
                  '$pct% more than the previous 7 days.'
                : 'You spent $currency${last7Spend.toStringAsFixed(0)} this week — '
                  '$pct% less than the previous 7 days. Keep it up!',
            isPositive: delta < 0,
          ));
        }
      }

      // ─── 3. Savings rate this month ────────────────────────────────────────
      if (effectiveIncome > 0 && thisMonthSpend > 0) {
        final savings     = effectiveIncome - thisMonthSpend;
        final savingsRate = (savings / effectiveIncome * 100);
        if (savingsRate >= 0) {
          String msg;
          bool positive;
          if (savingsRate >= 30) {
            msg = 'Excellent! You\'re saving ${savingsRate.round()}% of your income this month. '
                  'That\'s $currency${savings.toStringAsFixed(0)} saved.';
            positive = true;
          } else if (savingsRate >= 10) {
            msg = 'You\'re saving about ${savingsRate.round()}% of your income ($currency${savings.toStringAsFixed(0)}). '
                  'Try to push above 30% for a healthier buffer.';
            positive = true;
          } else {
            msg = 'Your savings rate is only ${savingsRate.round()}% this month. '
                  'Expenses ($currency${thisMonthSpend.toStringAsFixed(0)}) are eating into your income.';
            positive = false;
          }
          insights.add(InsightMessage(
            title: 'Savings Rate',
            message: msg,
            isPositive: positive,
          ));
        } else {
          // Overspending
          insights.add(InsightMessage(
            title: 'Over Budget',
            message: 'Your spending ($currency${thisMonthSpend.toStringAsFixed(0)}) exceeds your income '
                     '($currency${effectiveIncome.toStringAsFixed(0)}) this month by '
                     '$currency${savings.abs().toStringAsFixed(0)}. Review your expenses.',
            isPositive: false,
          ));
        }
      }

      // ─── 4. Top spending category ──────────────────────────────────────────
      if (thisMonthCats.isNotEmpty) {
        final top = thisMonthCats.entries.reduce((a, b) => a.value > b.value ? a : b);
        final share = effectiveIncome > 0
            ? (top.value / effectiveIncome * 100).round()
            : 0;
        final shareText = share > 0 ? ' ($share% of income)' : '';
        insights.add(InsightMessage(
          title: 'Top Category: ${top.key}',
          message: '${top.key} is your biggest expense this month at '
                   '$currency${top.value.toStringAsFixed(0)}$shareText.',
          isPositive: top.value < (effectiveIncome * 0.3),
        ));
      }

      // ─── 5. Category spike alert ───────────────────────────────────────────
      if (last7Cats.isNotEmpty && thisMonthCats.isNotEmpty) {
        for (final entry in last7Cats.entries) {
          final monthlyForCat = thisMonthCats[entry.key] ?? 0;
          // If last 7 days represents more than 60% of this month's spend on a cat
          if (monthlyForCat > 0 && (entry.value / monthlyForCat) > 0.60 && entry.value > 200) {
            insights.add(InsightMessage(
              title: '${entry.key} Spike',
              message: 'You\'ve spent $currency${entry.value.toStringAsFixed(0)} on ${entry.key} '
                       'in the last 7 days — that\'s ${((entry.value / monthlyForCat) * 100).round()}% '
                       'of your monthly ${entry.key} spend.',
              isPositive: false,
            ));
            break; // Only show one spike alert
          }
        }
      }

      // ─── 6. Frequent small transactions ────────────────────────────────────
      final smallTx = last7.where(
        (t) => t.type == TransactionType.expense && t.amount < 200).toList();
      if (smallTx.length >= 5) {
        final smallTotal = smallTx.fold(0.0, (s, t) => s + t.amount);
        insights.add(InsightMessage(
          title: 'Small Spend, Big Impact',
          message: 'You made ${smallTx.length} small purchases (under ${currency}200) '
                   'this week totalling $currency${smallTotal.toStringAsFixed(0)}. '
                   'These micro-expenses add up quickly.',
          isPositive: false,
        ));
      }

      // ─── 7. Income logged this month ───────────────────────────────────────
      if (thisMonthIncome > 0) {
        insights.add(InsightMessage(
          title: 'Income Logged',
          message: 'You\'ve recorded $currency${thisMonthIncome.toStringAsFixed(0)} '
                   'in income this month.',
          isPositive: true,
        ));
      }

      // ─── 8. Zero activity days ─────────────────────────────────────────────
      if (thisMonth.isNotEmpty) {
        final daysWithActivity = thisMonth.map((t) => t.date.day).toSet().length;
        final daysInMonth = now.day; // days elapsed so far
        if (daysInMonth >= 7 && daysWithActivity < daysInMonth ~/ 2) {
          insights.add(InsightMessage(
            title: 'Tracking Gaps',
            message: 'You\'ve only logged expenses on $daysWithActivity of the last '
                     '$daysInMonth days. Consistent logging gives you more accurate insights.',
            isPositive: false,
          ));
        }
      }

      return insights.take(5).toList(); // Show at most 5 insights
    },
    orElse: () => [],
  );
});

// ---------------------------------------------------------------------------
// DailySpend — one data point per day for the chart
// ---------------------------------------------------------------------------
class DailySpend {
  final int day;       // day-of-month
  final double amount; // total expense for that day
  final bool isToday;

  const DailySpend({
    required this.day,
    required this.amount,
    required this.isToday,
  });
}

// Returns the last 30 calendar days with daily expense sums.
final dailySpendingProvider = Provider<List<DailySpend>>((ref) {
  final txState = ref.watch(transactionsListProvider);

  return txState.maybeWhen(
    data: (transactions) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return List.generate(30, (i) {
        // i=0 → 29 days ago, i=29 → today
        final date = today.subtract(Duration(days: 29 - i));
        final dayExpenses = transactions.where((t) {
          final txDay = DateTime(t.date.year, t.date.month, t.date.day);
          return txDay == date && t.type == TransactionType.expense;
        });
        final total = dayExpenses.fold(0.0, (s, t) => s + t.amount);
        return DailySpend(
          day: date.day,
          amount: total,
          isToday: date == today,
        );
      });
    },
    orElse: () => List.generate(
      30,
      (i) => DailySpend(day: i + 1, amount: 0, isToday: false),
    ),
  );
});
