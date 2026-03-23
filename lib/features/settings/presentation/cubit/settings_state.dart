import 'package:flutter/material.dart';

class SettingsState {
  final double monthlyBudgetLimit;
  final String currencySymbol;
  final ThemeMode themeMode;

  SettingsState({
    required this.monthlyBudgetLimit,
    required this.currencySymbol,
    required this.themeMode,
  });

  SettingsState copyWith({
    double? monthlyBudgetLimit,
    String? currencySymbol,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      monthlyBudgetLimit: monthlyBudgetLimit ?? this.monthlyBudgetLimit,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
