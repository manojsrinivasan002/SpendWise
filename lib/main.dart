import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:spend_wise/core/themes/app_theme.dart';
import 'package:spend_wise/features/expense_tracking/data/models/expense_model.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_cubit.dart';
import 'package:spend_wise/features/expense_tracking/presentation/pages/expense_page.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_state.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. setup hive
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  // await Hive.deleteBoxFromDisk('expensesBox');
  // 2. Initialize Dependency Injection
  await di.initDI();

  // 3. Run the App
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<ExpenseCubit>()),
        BlocProvider(create: (context) => di.sl<SettingsCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightMode,
          darkTheme: AppTheme.darkMode,
          home: const ExpensePage(),
        );
      },
    );
  }
}
