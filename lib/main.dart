import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:spend_wise/core/themes/app_theme.dart';
import 'package:spend_wise/features/expense_tracking/data/models/expense_model.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_cubit.dart';
import 'package:spend_wise/features/expense_tracking/presentation/pages/expense_page.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:spend_wise/features/settings/presentation/pages/settings_page.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. setup hive
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());

  // 2. Initialize Dependency Injection
  await di.initDI();

  // 3. Run the App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<ExpenseCubit>()),
          BlocProvider(create: (context) => di.sl<SettingsCubit>()),
        ],
        child: const ExpensePage(),
      ),
      // darkTheme: AppTheme.darkMode,
      theme: AppTheme.lightMode,
      themeMode: ThemeMode.system,
    );
  }
}
