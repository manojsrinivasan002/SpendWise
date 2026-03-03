import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';
import 'package:spend_wise/features/expense_tracking/domain/repo/expense_repo.dart';

class ExpenseRepoImp extends ExpenseRepo{
  @override
  Future<void> deleteExpense(String id) {
    // TODO: implement deleteExpense
    throw UnimplementedError();
  }

  @override
  Future<List<ExpenseEntity>> getExpenses() {
    // TODO: implement getExpenses
    throw UnimplementedError();
  }

  @override
  Future<void> saveExpense(ExpenseEntity expense) {
    // TODO: implement saveExpense
    throw UnimplementedError();
  }
  

}