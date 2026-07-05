import '../models/commission.dart';
import '../models/inquiry.dart';
import 'mock_users.dart';

DateTime _ago({int days = 0, int hours = 0}) =>
    DateTime.now().subtract(Duration(days: days, hours: hours));

/// Seed inquiries so the provider screens have something to act on the
/// moment a demo provider logs in. Mutated by [MockInquiryRepository] /
/// [MockProviderRepository] as inquiries are created or transitioned.
final List<Inquiry> seedInquiries = [
  Inquiry(
    id: 'inq-seed-1',
    familyId: kDemoFamilyId,
    familyName: 'Reem Khan',
    familyEmail: 'reem.khan@example.com',
    message:
        'Looking for weekly SAT maths sessions for my Year 11 daughter. '
        'Evenings work best.',
    status: InquiryStatus.new_,
    createdAt: _ago(hours: 3),
  ),
  Inquiry(
    id: 'inq-seed-2',
    familyId: kDemoFamilyId,
    familyName: 'Daniyar O.',
    familyEmail: 'daniyar.o@example.com',
    message: 'Hi! My 7-year-old is new to Arabic — would love to try a trial.',
    status: InquiryStatus.accepted,
    createdAt: _ago(days: 2),
  ),
  Inquiry(
    id: 'inq-seed-3',
    familyId: kDemoFamilyId,
    familyName: 'Sofia M.',
    familyEmail: 'sofia.m@example.com',
    message:
        "We'd like to attend the weekend painting class as a family of three. "
        'Is that possible?',
    status: InquiryStatus.new_,
    createdAt: _ago(hours: 18),
  ),
];

/// Seed commissions matching the already-accepted inquiry above so the
/// Earnings tab isn't empty on first open.
final List<Commission> seedCommissions = [
  Commission(
    id: 'cms-seed-1',
    inquiryId: 'inq-seed-2',
    providerId: kDemoTutorId,
    amountQar: kInquiryCommissionQar,
    status: CommissionStatus.paid,
    createdAt: _ago(days: 2),
  ),
];
