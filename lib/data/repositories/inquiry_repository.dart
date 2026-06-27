import '../mock/mock_inquiries.dart';
import '../mock/mock_tutors.dart';
import '../mock/mock_users.dart';
import '../models/inquiry.dart';

abstract class InquiryRepository {
  /// Inquiries the signed-in family user has sent.
  /// [familyId] is accepted for interface compat but ignored by the HTTP impl
  /// (backend reads family from the token).
  Future<List<Inquiry>> myInquiries(String familyId);

  /// Create a new inquiry from the signed-in family to a tutor. Only
  /// [tutorId] + [message] go on the wire; family identity comes from the token.
  Future<Inquiry> create({required String tutorId, required String message});

  /// Cancel one of the family's own inquiries (→ CANCELLED). Returns the
  /// updated inquiry.
  Future<Inquiry> cancel(String inquiryId);
}

class MockInquiryRepository implements InquiryRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<List<Inquiry>> myInquiries(String familyId) async {
    await Future<void>.delayed(_latency);
    return seedInquiries.where((i) => i.familyId == familyId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Inquiry> create({
    required String tutorId,
    required String message,
  }) async {
    await Future<void>.delayed(_latency);
    final matches = mockTutors.where((t) => t.id == tutorId);
    if (matches.isEmpty) {
      throw StateError('Unknown tutor: $tutorId');
    }
    final tutor = matches.first;
    final inquiry = Inquiry(
      id: 'inq-${DateTime.now().millisecondsSinceEpoch}',
      tutorId: tutor.id,
      tutor: InquiryTutor(
        id: tutor.id,
        fullName: tutor.name,
        subjects: tutor.subjects,
        isVerified: true,
      ),
      familyId: kDemoFamilyId,
      message: message.trim(),
      status: InquiryStatus.new_,
      createdAt: DateTime.now(),
    );
    seedInquiries.add(inquiry);
    return inquiry;
  }

  @override
  Future<Inquiry> cancel(String inquiryId) async {
    await Future<void>.delayed(_latency);
    final index = seedInquiries.indexWhere((i) => i.id == inquiryId);
    if (index < 0) {
      throw StateError('Unknown inquiry: $inquiryId');
    }
    final current = seedInquiries[index];
    if (!current.status.isCancellable) {
      throw StateError('This inquiry can no longer be cancelled.');
    }
    final updated = current.copyWith(status: InquiryStatus.cancelled);
    seedInquiries[index] = updated;
    return updated;
  }
}
