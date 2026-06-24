import '../models/tutor.dart';

String _avatar(String id) => 'https://i.pravatar.cc/300?u=$id';

/// Individual tutors, each affiliated with one of the tutoring-centre
/// listings in mock_listings.dart.
final List<Tutor> mockTutors = [
  Tutor(
    id: 'tutor-lina',
    name: 'Lina Haddad',
    avatarUrl: _avatar('tutor-lina'),
    affiliationListingId: 'tutor-mathcraft',
    subjects: ['MATH', 'EXAM_PREP'],
    formats: [
      TutorFormat.oneOnOne,
      TutorFormat.smallGroup,
      TutorFormat.atCentre,
    ],
    ageGroups: ['6-11', '12-15'],
    pricePerHourQar: 180,
    rating: 4.9,
    reviewCount: 64,
    yearsExperience: 8,
    credentials: 'MSc Mathematics, Texas A&M Qatar',
    languages: ['EN', 'AR'],
    trialAvailable: true,
    bio:
        'Lina specialises in building number confidence in primary and middle '
        'schoolers. Her sessions mix visual methods with exam-style practice, '
        'and she sends parents a short progress note after every lesson.',
  ),
  Tutor(
    id: 'tutor-omar',
    name: 'Omar Said',
    avatarUrl: _avatar('tutor-omar'),
    affiliationListingId: 'tutor-mathcraft',
    subjects: ['MATH', 'SCIENCE'],
    formats: [TutorFormat.oneOnOne, TutorFormat.online],
    ageGroups: ['12-15', '16+'],
    pricePerHourQar: 160,
    rating: 4.7,
    reviewCount: 41,
    yearsExperience: 5,
    credentials: 'BSc Physics, Qatar University',
    languages: ['EN', 'AR'],
    trialAvailable: false,
    bio:
        'Omar tutors physics and advanced maths for IGCSE and IB students. '
        'He focuses on past-paper technique and runs convenient evening '
        'sessions online.',
  ),
  Tutor(
    id: 'tutor-mariam',
    name: 'Mariam Al-Naimi',
    avatarUrl: _avatar('tutor-mariam'),
    affiliationListingId: 'tutor-mathcraft',
    subjects: ['SCIENCE'],
    formats: [TutorFormat.smallGroup, TutorFormat.atCentre, TutorFormat.online],
    ageGroups: ['6-11', '12-15'],
    pricePerHourQar: 170,
    rating: 4.8,
    reviewCount: 38,
    yearsExperience: 6,
    credentials: 'BSc Biology, Carnegie Mellon Qatar',
    languages: ['EN', 'AR'],
    trialAvailable: true,
    bio:
        'Mariam makes science hands-on with small home-safe experiments and '
        'clear visual summaries. Popular with families preparing for school '
        'entrance assessments.',
  ),
  Tutor(
    id: 'tutor-aisha',
    name: 'Aisha Rahman',
    avatarUrl: _avatar('tutor-aisha'),
    affiliationListingId: 'tutor-arabicroots',
    subjects: ['ARABIC'],
    formats: [
      TutorFormat.oneOnOne,
      TutorFormat.smallGroup,
      TutorFormat.atCentre,
    ],
    ageGroups: ['3-5', '6-11'],
    pricePerHourQar: 150,
    rating: 4.9,
    reviewCount: 57,
    yearsExperience: 10,
    credentials: 'Certified Arabic-as-foreign-language instructor',
    languages: ['EN', 'AR'],
    trialAvailable: true,
    bio:
        'Aisha teaches Arabic to non-native young learners through stories, '
        'songs and games. Many of her students arrive with zero Arabic and '
        'leave reading confidently.',
  ),
  Tutor(
    id: 'tutor-yusuf',
    name: 'Yusuf Karim',
    avatarUrl: _avatar('tutor-yusuf'),
    affiliationListingId: 'tutor-arabicroots',
    subjects: ['ARABIC'],
    formats: [TutorFormat.oneOnOne, TutorFormat.online],
    ageGroups: ['6-11', '12-15'],
    pricePerHourQar: 140,
    rating: 4.6,
    reviewCount: 29,
    yearsExperience: 4,
    credentials: 'BA Arabic Literature, Qatar University',
    languages: ['EN', 'AR'],
    trialAvailable: true,
    bio:
        'Yusuf supports school Arabic curricula and conversation practice. '
        'Flexible online slots make him a favourite for busy after-school '
        'schedules.',
  ),
  Tutor(
    id: 'tutor-elena',
    name: 'Elena Petrova',
    avatarUrl: _avatar('tutor-elena'),
    affiliationListingId: 'tutor-summit',
    subjects: ['ENGLISH', 'EXAM_PREP'],
    formats: [TutorFormat.oneOnOne, TutorFormat.atCentre, TutorFormat.online],
    ageGroups: ['12-15', '16+'],
    pricePerHourQar: 200,
    rating: 4.8,
    reviewCount: 52,
    yearsExperience: 12,
    credentials: 'CELTA; former IELTS examiner',
    languages: ['EN', 'RU'],
    trialAvailable: false,
    bio:
        'Elena prepares teens for IELTS, IGCSE English and university '
        'applications. Russian-speaking families value her bilingual '
        'feedback to parents.',
  ),
  Tutor(
    id: 'tutor-david',
    name: 'David Chen',
    avatarUrl: _avatar('tutor-david'),
    affiliationListingId: 'tutor-summit',
    subjects: ['MATH', 'EXAM_PREP'],
    formats: [TutorFormat.smallGroup, TutorFormat.atCentre],
    ageGroups: ['16+'],
    pricePerHourQar: 250,
    rating: 4.9,
    reviewCount: 47,
    yearsExperience: 9,
    credentials: 'SAT specialist; 99th-percentile scorer',
    languages: ['EN'],
    trialAvailable: false,
    bio:
        'David runs intensive SAT maths batches with weekly timed mocks. '
        'His small groups are capped at six and fill up at the start of '
        'every season.',
  ),
];

Tutor? tutorById(String id) {
  for (final tutor in mockTutors) {
    if (tutor.id == id) return tutor;
  }
  return null;
}

List<Tutor> tutorsForListing(String listingId) =>
    mockTutors.where((t) => t.affiliationListingId == listingId).toList();
