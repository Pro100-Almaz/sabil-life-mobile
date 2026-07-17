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
  String get searchTutorsHint => 'Search tutors, subjects…';

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
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortExperience => 'Most experienced';

  @override
  String get priceMin => 'Min price (QAR)';

  @override
  String get priceMax => 'Max price (QAR)';

  @override
  String get filterTrialOnly => 'Offers a trial lesson';

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
  String get qualifications => 'Qualifications';

  @override
  String get centre => 'Centre';

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
  String get fieldRequired => 'Required';

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

  @override
  String get switchToProvider => 'Back to provider dashboard';

  @override
  String get switchToTutor => 'Switch to Tutor dashboard';

  @override
  String get switchToMasterclass => 'Switch to Masterclass dashboard';

  @override
  String get genericLoadError => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get listingNoLongerAvailable => 'This listing is no longer available';

  @override
  String get providerUnverifiedBanner =>
      'Your account is awaiting verification. Listings will stay in DRAFT until an admin approves your account.';

  @override
  String get providerEarningsBillingPending =>
      'Billing is not yet active. Commission statements and payouts will appear here once billing ships.';

  @override
  String get providerProfileSaved => 'Profile saved';

  @override
  String get providerMarkContacted => 'Mark contacted';

  @override
  String get providerComplete => 'Complete';

  @override
  String get providerContactNotRevealed =>
      'Contact details unlocked after acceptance';

  @override
  String get providerContactRevealed => 'Contact revealed';

  @override
  String get providerSubscribers => 'Subscribers';

  @override
  String get providerNoSubscribers => 'No subscribers yet';

  @override
  String get listingSubmittedForReview => 'Listing submitted for review';

  @override
  String get statusContacted => 'Contacted';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get filterAll => 'All';

  @override
  String get displayName => 'Display name';

  @override
  String get bio => 'Bio (optional)';

  @override
  String get subjects => 'Subjects';

  @override
  String get hourlyRate => 'Price per hour (QAR)';

  @override
  String get cityLabel => 'City';

  @override
  String get citySearchHint => 'Start typing a city…';

  @override
  String get cityNoResults => 'No cities found';

  @override
  String get availability => 'Availability';

  @override
  String get profileFormats => 'Teaching formats';

  @override
  String get profileAgeGroups => 'Age groups';

  @override
  String get profileLanguages => 'Languages';

  @override
  String get profileYearsExperience => 'Years of experience';

  @override
  String get profileCredentials => 'Credentials (optional)';

  @override
  String get profileAvatar => 'Profile photo (optional)';

  @override
  String get profileTrialAvailable => 'Offer trial lesson';

  @override
  String get profileSubmittedForReview => 'Profile submitted for review';

  @override
  String get suggestService => 'Suggest a service';

  @override
  String get suggestServiceHint =>
      'Missing something in Doha? Let us know what you\'d love to see.';

  @override
  String get suggestionCategory => 'Category (optional)';

  @override
  String get suggestionCategoryAny => 'Any';

  @override
  String get suggestionNeighborhood => 'Neighborhood (optional)';

  @override
  String get suggestionMessage => 'Your suggestion';

  @override
  String get suggestionMessageHint =>
      'Describe what you\'d love to find near you…';

  @override
  String get suggestionSubmit => 'Submit';

  @override
  String get suggestionSubmitted =>
      'Thanks! Your suggestion has been submitted.';

  @override
  String get mySuggestions => 'My suggestions';

  @override
  String get suggestionStatusNew => 'Submitted';

  @override
  String get suggestionStatusReviewed => 'Under review';

  @override
  String get suggestionStatusActedOn => 'Acted on';

  @override
  String get suggestionStatusDismissed => 'Dismissed';

  @override
  String get rateLimited => 'Rate limited. Please try again shortly.';

  @override
  String get other => 'Other';

  @override
  String get addCustomSubject => 'Add custom subject';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photoFromGallery => 'Choose from gallery';

  @override
  String get photoFromCamera => 'Take a photo';

  @override
  String get writeReview => 'Write a review';

  @override
  String get rateThisTutor => 'Rate this tutor';

  @override
  String get editReview => 'Edit review';

  @override
  String get deleteReview => 'Delete review';

  @override
  String get deleteReviewConfirm =>
      'Are you sure you want to delete this review?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get reviewSubmitted => 'Review submitted';

  @override
  String get reviewUpdated => 'Review updated';

  @override
  String get reviewDeleted => 'Review deleted';

  @override
  String get shareExperience => 'Share your experience…';

  @override
  String get submitting => 'Submitting…';

  @override
  String get submit => 'Submit';

  @override
  String get updating => 'Updating…';

  @override
  String get update => 'Update';

  @override
  String get tutorAccountUnderReview =>
      'Your tutor account is being reviewed. We\'ll notify you once it\'s approved.';

  @override
  String get fillTutorProfile =>
      'Fill in your tutor profile to get started as a tutor.';

  @override
  String get goBack => 'Go back';

  @override
  String get requestMasterclassProvider =>
      'Request to become a masterclass provider';

  @override
  String get masterclassRequestSent =>
      'Your request has been submitted. We\'ll review it shortly.';

  @override
  String get masterclassAccountUnderReview =>
      'Your masterclass provider request is being reviewed.';

  @override
  String get becomeTutor => 'Become a tutor';

  @override
  String get becomeMasterclassProvider => 'Become a masterclass provider';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get verificationRejected => 'Your application wasn\'t approved';

  @override
  String get verificationRejectedReason => 'Reason';

  @override
  String get requestAgain => 'Request again';

  @override
  String get editAndResubmit => 'Edit & resubmit';

  @override
  String get resubmitTutorProfile =>
      'Update your profile and resubmit it for review.';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get cancelRequestTitle => 'Cancel request?';

  @override
  String get cancelRequestMessage =>
      'This withdraws your verification request. You can submit a new one later.';

  @override
  String get cancelRequestConfirm => 'Yes, cancel';

  @override
  String get keepRequest => 'Keep request';

  @override
  String get requestCancelled => 'Your request has been cancelled.';

  @override
  String get myRequestsTabListings => 'Enrollments';

  @override
  String get myRequestsTabTutors => 'Tutors';

  @override
  String get enroll => 'Enroll';

  @override
  String get enrolled => 'Enrolled';

  @override
  String get enrollmentSubmitted =>
      'You\'re enrolled — the provider will be in touch.';

  @override
  String get enrollmentCancelled => 'Your enrollment has been cancelled.';

  @override
  String get cancelEnrollment => 'Cancel enrollment';

  @override
  String get keepEnrollment => 'Keep enrollment';

  @override
  String get noEnrollmentsYet => 'No enrollments yet';

  @override
  String get cancelListingEnrollmentTitle => 'Cancel enrollment?';

  @override
  String get cancelListingEnrollmentMessage =>
      'This withdraws your enrollment for this listing. You can enroll again later.';

  @override
  String get clients => 'Clients';

  @override
  String get viewClients => 'View clients';

  @override
  String get noClientsYet => 'No clients yet';

  @override
  String get clientStatusUpdated => 'Status updated.';

  @override
  String get acceptEnrollmentTitle => 'Accept enrollment';

  @override
  String get rejectEnrollmentTitle => 'Reject enrollment';

  @override
  String get commentOptionalHint => 'Add a note for the family (optional).';

  @override
  String get commentRequiredHint =>
      'Let the family know why — a note is required to reject.';

  @override
  String get commentHint => 'Write a note…';

  @override
  String get inquire => 'Inquire';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get cancelInquiry => 'Cancel inquiry';

  @override
  String get cancelInquiryTitle => 'Cancel inquiry?';

  @override
  String get cancelInquiryMessage =>
      'This withdraws your inquiry to this tutor. You can send a new one later.';

  @override
  String get keepInquiry => 'Keep inquiry';

  @override
  String get inquiryCancelled => 'Your inquiry has been cancelled.';

  @override
  String get directions => 'Directions';

  @override
  String get directionError => 'Couldn\'t open a map app';
}
