class SettingsState {
  final double monthlyBudgetLimit;
  final bool isDarkMode;

  SettingsState({required this.monthlyBudgetLimit, required this.isDarkMode});

  SettingsState copyWith({double? monthlyBudgetLimit, bool? isDarkMode}) {
    return SettingsState(
      monthlyBudgetLimit: monthlyBudgetLimit ?? this.monthlyBudgetLimit,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
