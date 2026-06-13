// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sabil Life';

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navFavorites => 'Saved';

  @override
  String get navSettings => 'Settings';

  @override
  String get searchHint => 'Search schools, activities…';

  @override
  String get nearYou => 'Near you';

  @override
  String get featured => 'Featured';

  @override
  String get popularInDoha => 'Popular in Doha';

  @override
  String get catAll => 'All';

  @override
  String get catSchools => 'Schools';

  @override
  String get catNurseries => 'Nurseries';

  @override
  String get catActivities => 'Activities';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catTutoring => 'Tutoring';

  @override
  String get catMasterclasses => 'Masterclasses';

  @override
  String get catPartnerships => 'Partners';

  @override
  String distanceAway(String km) {
    return '$km km away';
  }

  @override
  String fromPrice(String price) {
    return 'from $price QAR';
  }

  @override
  String get free => 'Free';

  @override
  String get filters => 'Filters';

  @override
  String get sort => 'Sort';

  @override
  String get maxDistance => 'Max distance';

  @override
  String get priceRange => 'Price range';

  @override
  String get ageGroup => 'Age group';

  @override
  String get anyAge => 'Any age';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get sortDistance => 'Nearest first';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get noFavorites => 'Nothing saved yet';

  @override
  String get noFavoritesHint => 'Tap the heart on any listing to save it here';

  @override
  String get noResults => 'No results';

  @override
  String get noResultsHint => 'Try adjusting your filters or search';

  @override
  String get viewOnMap => 'View on map';

  @override
  String reviews(int count) {
    return '$count reviews';
  }

  @override
  String get about => 'About';

  @override
  String get aboutAppSubtitle => 'Family-life directory for Doha';

  @override
  String get details => 'Details';

  @override
  String get highlights => 'Highlights';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String resultsCount(int count) {
    return '$count results';
  }

  @override
  String get seeAll => 'See all';

  @override
  String kmUnit(String km) {
    return '$km km';
  }

  @override
  String upToPrice(String price) {
    return 'up to $price QAR';
  }

  @override
  String monthsAgo(int count) {
    return '$count months ago';
  }

  @override
  String get share => 'Share';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get version => 'Version';

  @override
  String get subjectMath => 'Math';

  @override
  String get subjectArabic => 'Arabic';

  @override
  String get subjectEnglish => 'English';

  @override
  String get subjectScience => 'Science';

  @override
  String get subjectExamPrep => 'Exam prep';

  @override
  String get formatOneOnOne => '1-on-1';

  @override
  String get formatSmallGroup => 'Small group';

  @override
  String get formatOnline => 'Online';

  @override
  String get formatAtCentre => 'At centre';

  @override
  String perHour(String price) {
    return '$price QAR/hr';
  }

  @override
  String get trialLesson => 'Trial lesson';

  @override
  String yearsExperience(int years) {
    return '$years yrs experience';
  }

  @override
  String get languagesLabel => 'Languages';

  @override
  String get viewCentre => 'View centre';

  @override
  String get ourTutors => 'Our tutors';

  @override
  String get thisWeekend => 'This weekend';

  @override
  String get nextWeek => 'Next week';

  @override
  String get later => 'Later';

  @override
  String seatsLeft(int count) {
    return '$count seats left';
  }

  @override
  String durationMinutes(int min) {
    return '$min min';
  }

  @override
  String get withParent => 'With parent';

  @override
  String get dropOff => 'Drop-off';

  @override
  String seriesCount(int count) {
    return '$count-session course';
  }

  @override
  String get oneOffEvent => 'One-off';

  @override
  String get pickDate => 'Pick a date';

  @override
  String perSession(String price) {
    return '$price QAR / session';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get createAccount => 'Create account';

  @override
  String get register => 'Register';

  @override
  String get login => 'Log in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get roleFamily => 'Family';

  @override
  String get roleProvider => 'Provider';

  @override
  String get roleTutor => 'Tutoring centre';

  @override
  String get roleMasterclass => 'Masterclass provider';

  @override
  String get noAccountPrompt => 'No account yet?';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get demoLoginHint =>
      'Try the demo accounts: family@demo · tutor@demo · mc@demo (password: demo1234)';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get authSheetTitle => 'Sign in to continue';

  @override
  String get authSheetHint =>
      'Sign in or create an account to send your request.';

  @override
  String get request => 'Request';

  @override
  String get requestSent => 'Request sent — the provider will be in touch.';

  @override
  String get inquiryComposerTitle => 'Send a request';

  @override
  String get inquiryComposerHint =>
      'Tell the provider a bit about your child and what you\'re looking for.';

  @override
  String get send => 'Send';

  @override
  String get myRequests => 'My requests';

  @override
  String get noRequestsYet => 'No requests yet';

  @override
  String get requestStatusPending => 'Pending';

  @override
  String get requestStatusAccepted => 'Accepted';

  @override
  String get requestStatusDeclined => 'Declined';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get myListings => 'Listings';

  @override
  String get inquiries => 'Inquiries';

  @override
  String get earnings => 'Earnings';

  @override
  String get providerSettings => 'Settings';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get underReviewBanner =>
      'Your account is under review — listings stay in draft until approved.';

  @override
  String get metricActiveListings => 'Active listings';

  @override
  String get metricNewInquiries => 'New inquiries';

  @override
  String get metricPendingCommission => 'Pending commission';

  @override
  String get newListing => 'New listing';

  @override
  String get editListing => 'Edit listing';

  @override
  String get submitForReview => 'Submit for review';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get draftCanOnlySubmitWhenVerified =>
      'Verify your account to submit listings for review.';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPending => 'Pending review';

  @override
  String get statusActive => 'Active';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldSubtitle => 'Subtitle';

  @override
  String get fieldNeighborhood => 'Neighborhood';

  @override
  String get fieldPrice => 'Price (QAR, from)';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldHighlights => 'Highlights';

  @override
  String get fieldImageUrl => 'Image URL';

  @override
  String get fieldAddImage => 'Add image';

  @override
  String get fieldAddHighlight => 'Add highlight';

  @override
  String get noListingsYet => 'You haven\'t created any listings yet';

  @override
  String get createFirstListing => 'Create your first listing';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get noInquiriesYet => 'No inquiries yet';

  @override
  String commissionApplies(int amount) {
    return 'A $amount QAR commission applies for this accepted student.';
  }

  @override
  String contactRevealed(String email) {
    return '$email — get in touch directly.';
  }

  @override
  String get acceptedStudents => 'Accepted students';

  @override
  String get pendingCommission => 'Pending';

  @override
  String get paidCommission => 'Paid';

  @override
  String get commissionListEmpty =>
      'Accepted student requests will appear here.';

  @override
  String get fillRequiredFields => 'Please fill in all required fields.';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get switchToFamily => 'Browse as family';
}
