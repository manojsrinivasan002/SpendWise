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

  bool isSpikedExpense(ExpenseEntity expense, double currentMonthlyBudget) {
    if (state is! ExpenseLoaded) return false;

    final loadedState = state as ExpenseLoaded;
    final amount = expense.amount;

    // 🚨 1. The Absolute Threat (Bypasses Cold Start & Noise Filters)
    // If this single item eats more than 10% of their whole budget, FLAG IT IMMEDIATELY.
    // Even if it is their very first transaction on the app.
    if (amount > (currentMonthlyBudget * 0.10)) return true;

    // 🛡️ 2. The Noise Filter (The 2% Rule)
    // If the expense is less than 2% of their budget, it's a micro-transaction.
    // Ignore it so we don't annoy the user with false alarms.
    final dynamicMinimum = currentMonthlyBudget * 0.02;
    if (amount < dynamicMinimum) return false;

    // 🛡️ 3. The Cold Start Defense
    // We only reach here if the item is > 2% but < 10% of the budget.
    // Now we need historical averages. If we have less than 5 items, the data is too volatile.
    if (loadedState.expenses.length < 5) return false;

    // 📊 4. The Relative Average Checks
    // Check A: Is it 2.5x higher than their global average?
    if (amount > (loadedState.globalAvg * 2.5)) return true;

    // Check B: Is it 2.0x higher than their usual category average?
    final catAvg = loadedState.categoryAvg[expense.expenseCategory] ?? 0.0;
    if (catAvg > 0 && amount > (catAvg * 2.0)) return true;

    // If it survives all of this, it is a perfectly normal expense.
    return false;
  }
}
