import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Box _settingsBox = Hive.box('settingsBox');
  SettingsCubit()
    : super(
        SettingsState(
          monthlyBudgetLimit: 30000.00,
          currencySymbol: '₹',
          themeMode: ThemeMode.system,
        ),
      ) {
    _loadSettings();
  }

  void _loadSettings() {
    final savedBudget = _settingsBox.get('monthlyBudget', defaultValue: 30000.00);
    final savedCurrency = _settingsBox.get('currencySymbol', defaultValue: '₹');
    final themeString = _settingsBox.get('themeMode', defaultValue: 'system');
    final savedTheme = ThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => ThemeMode.system,
    );
    emit(
      SettingsState(
        monthlyBudgetLimit: savedBudget,
        currencySymbol: savedCurrency,
        themeMode: savedTheme,
      ),
    );
  }

  void updateBudgetLimit(double newLimit) {
    _settingsBox.put('monthlyBudget', newLimit);
    emit(state.copyWith(monthlyBudgetLimit: newLimit));
  }

  void updateCurrencySymbol(String newSymbol) {
    _settingsBox.put('currencySymbol', newSymbol);
  }

  void updateTheme(String newTheme) {
    _settingsBox.put('themeMode', newTheme);
  }
}
