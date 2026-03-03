import 'package:dartz/dartz.dart';
import 'package:spend_wise/core/error/failure.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';

abstract class ExpenseRepo {
  // save new expense to db
  Future<Either<Failure, void>> saveExpense(ExpenseEntity expense);

  // read expenses from db
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses();

  // delete expense from db
  Future<Either<Failure, void>> deleteExpense(String id);
}
