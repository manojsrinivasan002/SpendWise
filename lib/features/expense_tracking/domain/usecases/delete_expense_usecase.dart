import 'package:dartz/dartz.dart';
import 'package:spend_wise/core/error/failure.dart';
import 'package:spend_wise/features/expense_tracking/domain/repo/expense_repo.dart';

class DeleteExpenseUseCase {
  final ExpenseRepo repo;

  DeleteExpenseUseCase(this.repo);

  Future<Either<Failure, void>> call(String id) async {
    return await repo.deleteExpense(id);
  }
}
