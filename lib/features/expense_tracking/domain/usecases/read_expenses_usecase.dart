import 'package:dartz/dartz.dart';
import 'package:spend_wise/core/error/failure.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';
import 'package:spend_wise/features/expense_tracking/domain/repo/expense_repo.dart';

class ReadExpensesUseCase {
  final ExpenseRepo repo;

  ReadExpensesUseCase(this.repo);

  Future<Either<Failure, List<ExpenseEntity>>> call() async {
    return await repo.getExpenses();
  }
}
