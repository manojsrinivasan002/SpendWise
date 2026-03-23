import 'package:hive/hive.dart';
import 'package:spend_wise/core/error/exceptions.dart';
import 'package:spend_wise/features/expense_tracking/data/models/expense_model.dart';

abstract class ExpenseLocalDatasource {
  Future<void> cacheExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getCachedExpenses();
  Future<void> deleteCachedExpense(String id);
}

class ExpenseLocalDatasourceImp extends ExpenseLocalDatasource {
  final Box<ExpenseModel> box;

  ExpenseLocalDatasourceImp(this.box);

  @override
  Future<void> cacheExpense(ExpenseModel expense) async {
    try {
      await box.put(expense.id, expense);
    } catch (e) {
      throw CacheException(message: 'Failed to save expense to device');
    }
  }

  @override
  Future<void> deleteCachedExpense(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete expense from device');
    }
  }

  @override
  Future<List<ExpenseModel>> getCachedExpenses() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: "Failed to load expenses");
    }
  }
}
