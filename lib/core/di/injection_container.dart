import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:spend_wise/features/expense_tracking/data/datasouces/expense_local_datasource.dart';
import 'package:spend_wise/features/expense_tracking/data/models/expense_model.dart';
import 'package:spend_wise/features/expense_tracking/data/repo_imp/expense_repo_imp.dart';
import 'package:spend_wise/features/expense_tracking/domain/create_expense_usecase.dart';
import 'package:spend_wise/features/expense_tracking/domain/repo/expense_repo.dart';
import 'package:spend_wise/features/expense_tracking/domain/usecases/delete_expense_usecase.dart';
import 'package:spend_wise/features/expense_tracking/domain/usecases/parse_chat_expense_usecase.dart';
import 'package:spend_wise/features/expense_tracking/domain/usecases/read_expenses_usecase.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_cubit.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // external (database)
  final expenseBox = await Hive.openBox<ExpenseModel>('expensesBox');
  await Hive.openBox('settingsBox');

  // data sources
  sl.registerLazySingleton<ExpenseLocalDatasource>(() => ExpenseLocalDatasourceImp(expenseBox));

  // repositories
  sl.registerLazySingleton<ExpenseRepo>(() => ExpenseRepoImp(sl()));

  // usecases
  sl.registerFactory(() => CreateExpenseUseCase(sl()));
  sl.registerFactory(() => ReadExpensesUseCase(sl()));
  sl.registerFactory(() => DeleteExpenseUseCase(sl()));
  sl.registerFactory(() => ParseChatExpenseUseCase());

  // 5. State Management (Cubits/Blocs)
  sl.registerFactory(
    () => ExpenseCubit(
      createExpense: sl(),
      readExpenses: sl(),
      deleteExpense: sl(),
      parseChatExpense: sl(),
    ),
  );

  sl.registerFactory(() => SettingsCubit());
}
