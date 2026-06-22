import '../models/tutor.dart';

class TutorException implements Exception {
  const TutorException(this.message);
  final String message;

  @override
  String toString() => 'TutorException: $message';
}

abstract class TutorRepository {
  Future<List<Tutor>> tutors();
  Future<List<String>> subjects();
}
