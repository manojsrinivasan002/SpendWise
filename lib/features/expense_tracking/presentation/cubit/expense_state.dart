import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final double globalAvg;
  final Map<ExpenseCategory, double> categoryAvg;
  final DateTime selectedMonth;
  final DateTime? earliestExpenseDate;

  const ExpenseLoaded(
    this.expenses,
    this.globalAvg,
    this.categoryAvg,
    this.selectedMonth,
    this.earliestExpenseDate,
  );

  bool get canGoForward {
    final now = DateTime.now();
    return selectedMonth.year < now.year ||
        (selectedMonth.year == now.year && selectedMonth.month < now.month);
  }

  bool get canGoBack {
    if (earliestExpenseDate == null) return false;
    return selectedMonth.year > earliestExpenseDate!.year ||
        (selectedMonth.year == earliestExpenseDate!.year &&
            selectedMonth.month > earliestExpenseDate!.month);
  }

  // FILTER: GET ONLY THIS MONTH EXPENSES
  List<ExpenseEntity> get currentMonthExpenses {
    return expenses.where((expense) {
      return expense.date.year == selectedMonth.year && expense.date.month == selectedMonth.month;
    }).toList();
  }

  // DASHBOARD MATH

  // FORMATTED DATE
  String get formattedCurrentMonth {
    return DateFormat('MMMM yyyy').format(selectedMonth);
  }

  // DAYS LEFT
  int get daysLeftInMonth {
    DateTime now = DateTime.now();
    if (selectedMonth.month != now.month && selectedMonth.year != now.year) {
      return 0;
    }
    int totalDays = DateTime(now.year, now.month + 1, 0).day;
    return totalDays - now.day;
  }

  // TOTAL SPENDINGS
  double get totalSpentThisMonth {
    return currentMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // CALCULATE REMAINING BUDGET
  double getRemainingBudget(double monthlyBudget) {
    return monthlyBudget - totalSpentThisMonth;
  }

  // DAILY SAFE LIMIT
  double getDailySafeLimit(double monthlyBudget) {
    final remaining = getRemainingBudget(monthlyBudget);
    if (remaining <= 0) return 0.0;
    if (daysLeftInMonth == 0) return remaining;
    return remaining / daysLeftInMonth;
  }

  // HEALTH SCORE ALGORITHM
  int getHealthScore(double monthlyBudget) {
    if (monthlyBudget <= 0) return 0;

    DateTime now = DateTime.now();
    int totalDays = DateTime(now.year, now.month + 1, 0).day;

    // calculate days passed in a month
    double timeElapsedRatio = now.day / totalDays;

    double budgetSpentRatio = totalSpentThisMonth / monthlyBudget;

    double difference = budgetSpentRatio / timeElapsedRatio;

    int score = 100 - (difference * 100).toInt();
    return score.clamp(0, 100);
  }

  // CATEGORY SORTER
  List<MapEntry<String, double>> get sortedCatPercentages {
    if (currentMonthExpenses.isEmpty) return [];
    Map<String, double> categoryTotals = {};

    for (var exp in currentMonthExpenses) {
      String catName = exp.expenseCategory.displayName;
      categoryTotals[catName] = (categoryTotals[catName] ?? 0) + exp.amount;
    }
    Map<String, double> percentages = {};

    categoryTotals.forEach((cat, total) {
      percentages[cat] = (total / totalSpentThisMonth) * 100;
    });
    return percentages.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  // STICKY DATE GROUP
  Map<String, List<ExpenseEntity>> get groupedExpenses {
    Map<String, List<ExpenseEntity>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var exp in currentMonthExpenses) {
      final expDate = DateTime(exp.date.year, exp.date.month, exp.date.day);
      String key;

      if (expDate == today) {
        key = "Today";
      } else if (expDate == yesterday) {
        key = "Yesterday";
      } else {
        key = DateFormat('MMMM d, yyyy').format(exp.date);
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(exp);
    }
    return groups;
  }

  @override
  List<Object?> get props => [expenses, globalAvg, categoryAvg, selectedMonth];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
