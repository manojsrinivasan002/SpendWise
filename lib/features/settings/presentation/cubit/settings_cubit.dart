import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Box _settingsBox = Hive.box('settingsBox');
  SettingsCubit() : super(SettingsState(monthlyBudgetLimit: 30000.00, isDarkMode: false)) {
    _loadSettings();
  }

  void _loadSettings() {
    final budget = _settingsBox.get('monthlyBudgetLimit', defaultValue: 30000.00);
    final isDark = _settingsBox.get('isDarkMode', defaultValue: false);
    emit(SettingsState(monthlyBudgetLimit: budget, isDarkMode: isDark));
  }

  Future<void> updateBudget(double newBudget) async {
    await _settingsBox.put('monthlyBudgetLimit', newBudget);
    emit(state.copyWith(monthlyBudgetLimit: newBudget));
  }

  Future<void> toggleTheme(bool isDark) async {
    await _settingsBox.put('isDarkMode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }
}
