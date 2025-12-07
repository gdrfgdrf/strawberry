
class Failure {
  final dynamic error;
  final StackTrace stackTrace;

  const Failure(this.error, this.stackTrace);

  static Failure current(dynamic error) {
    return Failure(error, StackTrace.current);
  }
}
