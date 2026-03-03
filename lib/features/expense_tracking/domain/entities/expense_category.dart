import 'package:hive/hive.dart';
part 'expense_category.g.dart';

@HiveType(typeId: 1)
enum ExpenseCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  shopping,
  @HiveField(3)
  bills,
  @HiveField(4)
  entertainment,
  @HiveField(5)
  health,
  @HiveField(6)
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔 Food';
      case ExpenseCategory.transport:
        return '🚗 Transport';
      case ExpenseCategory.shopping:
        return '🛍️ Shopping';
      case ExpenseCategory.bills:
        return '🏠 Bills';
      case ExpenseCategory.entertainment:
        return '🍿 Entertainment';
      case ExpenseCategory.health:
        return '🏥 Health';
      case ExpenseCategory.other:
        return '📦 Other';
    }
  }
}
