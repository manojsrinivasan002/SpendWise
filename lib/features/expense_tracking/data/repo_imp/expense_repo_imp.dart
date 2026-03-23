import 'package:dartz/dartz.dart';
import 'package:spend_wise/core/error/exceptions.dart';
import 'package:spend_wise/core/error/failure.dart';
import 'package:spend_wise/features/expense_tracking/data/datasouces/expense_local_datasource.dart';
import 'package:spend_wise/features/expense_tracking/data/models/expense_model.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';
import 'package:spend_wise/features/expense_tracking/domain/repo/expense_repo.dart';

class ExpenseRepoImp extends ExpenseRepo {
  final ExpenseLocalDatasource localDatasource;

  ExpenseRepoImp(this.localDatasource);
  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await localDatasource.deleteCachedExpense(id);
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses() async {
    try {
      final expenseModels = await localDatasource.getCachedExpenses();
      final entities = expenseModels.map((model) => model.toEntity()).toList();
      return right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveExpense(ExpenseEntity expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await localDatasource.cacheExpense(expenseModel);
      return right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
