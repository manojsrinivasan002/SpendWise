class CacheException implements Exception {
  final String message;
  CacheException({this.message = "A local storage error occured."});
}
