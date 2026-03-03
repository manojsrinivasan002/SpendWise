import 'package:hive/hive.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';
part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends ExpenseEntity {
  @HiveField(0)
  @override
  final String id;
  @HiveField(1)
  @override
  final String title;
  @HiveField(2)
  @override
  final double amount;
  @HiveField(3)
  @override
  final DateTime date;
  @HiveField(4)
  @override
  final ExpenseCategory expenseCategory;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.expenseCategory,
  }) : super(id: id, title: title, amount: amount, date: date, expenseCategory: expenseCategory);

  // Need to convert pure domain data into hive data (when saving)

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      expenseCategory: entity.expenseCategory,
    );
  }

  // Need to convert pure hive data into domain data (when reading)

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      title: title,
      amount: amount,
      date: date,
      expenseCategory: expenseCategory,
    );
  }
}
