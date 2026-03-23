import 'package:bloc/bloc.dart';
import 'package:spend_wise/core/error/error_mapper.dart';
import 'package:spend_wise/features/expense_tracking/domain/create_expense_usecase.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';
import 'package:spend_wise/features/expense_tracking/domain/usecases/delete_expense_usecase.dart';
import 'package:spend_wise/features/expense_tracking/domain/usecases/parse_chat_expense_usecase.dart';
import 'package:spend_wise/features/expense_tracking/domain/usecases/read_expenses_usecase.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final CreateExpenseUseCase createExpense;
  final ReadExpensesUseCase readExpenses;
  final DeleteExpenseUseCase deleteExpense;
  final ParseChatExpenseUseCase parseChatExpense;

  static const double mockMonthlyBudget = 30000;
  DateTime _currentlySelectedMonth = DateTime.now();

  ExpenseCubit({
    required this.createExpense,
    required this.readExpenses,
    required this.deleteExpense,
    required this.parseChatExpense,
  }) : super(ExpenseInitial()) {
    loadExpenses();
  }

  // TIME NAVIGATION
  void nextMonth() {
    _currentlySelectedMonth = DateTime(
      _currentlySelectedMonth.year,
      _currentlySelectedMonth.month + 1,
      1,
    );
    loadExpenses();
  }

  void previousMonth() {
    _currentlySelectedMonth = DateTime(
      _currentlySelectedMonth.year,
      _currentlySelectedMonth.month - 1,
      1,
    );
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    emit(ExpenseLoading());
    final result = await readExpenses();
    result.fold((failure) => emit(ExpenseError(ErrorMapper.mapFailureToMessage(failure))), (
      expenses,
    ) {
      expenses.sort((a, b) => b.date.compareTo(a.date));
      _emitLoadedStateWithAverages(expenses);
    });
  }

  Future<void> addExpense(String message, ExpenseCategory category) async {
    final parseResult = parseChatExpense(message, category);
    parseResult.fold(
      (failure) {
        emit(ExpenseError(ErrorMapper.mapFailureToMessage(failure)));
      },
      (newExpenseEntity) async {
        emit(ExpenseLoading());
        final saveResult = await createExpense(newExpenseEntity);
        saveResult.fold(
          (failure) => emit(ExpenseError(ErrorMapper.mapFailureToMessage(failure))),
          (_) => loadExpenses(),
        );
      },
    );
  }

  Future<void> removeExpense(String id) async {
    emit(ExpenseLoading());
    final result = await deleteExpense(id);
    result.fold(
      (failure) => emit(ExpenseError(ErrorMapper.mapFailureToMessage(failure))),
      (_) => loadExpenses(),
    );
  }

  void _emitLoadedStateWithAverages(List<ExpenseEntity> expenses) {
    if (expenses.isEmpty) {
      emit(ExpenseLoaded([], 0.0, {}, _currentlySelectedMonth, null));
      return;
    }

    DateTime earliestDate = expenses.last.date;

    double totalSpent = 0;
    Map<ExpenseCategory, double> categorySums = {};
    Map<ExpenseCategory, int> categoryCounts = {};

    for (var exp in expenses) {
      totalSpent += exp.amount;
      categorySums[exp.expenseCategory] = (categorySums[exp.expenseCategory] ?? 0) + exp.amount;
      categoryCounts[exp.expenseCategory] = (categoryCounts[exp.expenseCategory] ?? 0) + 1;
    }

    // 1. To calculate overall avg
    double globalAvg = totalSpent / expenses.length;

    // 2. To calculate category wise avg
    Map<ExpenseCategory, double> catAvgs = {};

    categorySums.forEach((cat, sum) {
      catAvgs[cat] = sum / categoryCounts[cat]!;
    });
    emit(ExpenseLoaded(expenses, globalAvg, catAvgs, _currentlySelectedMonth, earliestDate));
  }

  // 🚨 UPGRADED: Now returns a list of actionable insights!
  List<String>? getAnomalyInsights(ExpenseEntity expense) {
    if (state is! ExpenseLoaded) return null;

    final loadedState = state as ExpenseLoaded;
    final amount = expense.amount;
    List<String> insights = [];

    // Check 1: The Global Average Breach
    if (amount > (loadedState.globalAvg * 2.5) && amount > 500) {
      insights.add(
        "This ₹${amount.toStringAsFixed(0)} expense is 2.5x higher than your usual daily average.",
      );
      insights.add(
        "💡 Tip: Try to have a 'Zero-Spend Day' tomorrow to rebalance your weekly limits.",
      );
    }

    // Check 2: The Category Breach
    final catAvg = loadedState.categoryAvg[expense.expenseCategory] ?? 0.0;
    if (catAvg > 0 && amount > (catAvg * 2.0) && amount > 500) {
      insights.add(
        "You usually spend ₹${catAvg.toStringAsFixed(0)} on ${expense.expenseCategory.displayName}, but you just spiked to ₹${amount.toStringAsFixed(0)}.",
      );
      insights.add(
        "💡 Tip: Consider setting a hard sub-limit for ${expense.expenseCategory.displayName} to stop lifestyle creep.",
      );
    }

    // Check 3: The Total Budget Threat
    if (amount > (mockMonthlyBudget * 0.10)) {
      insights.add(
        "Critical: This single purchase consumed more than 10% of your entire monthly budget.",
      );
      insights.add(
        "💡 Tip: For purchases this large, try applying the '48-Hour Rule' next time before swiping.",
      );
    }

    return insights.isEmpty ? null : insights;
  }
}
