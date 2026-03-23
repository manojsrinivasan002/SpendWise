import 'package:spend_wise/core/error/failure.dart';

class ErrorMapper {
  static String mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case CacheFailure:
        return failure.message;
      case InputFailure:
        return failure.message;
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
