abstract class Failure {
  final String message;
  const Failure(this.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class InputFailure extends Failure {
  const InputFailure(super.message);
}
