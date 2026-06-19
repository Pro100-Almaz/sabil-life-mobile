import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sabil Life'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search schools, activities…'**
  String get searchHint;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get nearYou;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @popularInDoha.
  ///
  /// In en, this message translates to:
  /// **'Popular in Doha'**
  String get popularInDoha;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catSchools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get catSchools;

  /// No description provided for @catNurseries.
  ///
  /// In en, this message translates to:
  /// **'Nurseries'**
  String get catNurseries;

  /// No description provided for @catActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get catActivities;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catTutoring.
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get catTutoring;

  /// No description provided for @catMasterclasses.
  ///
  /// In en, this message translates to:
  /// **'Masterclasses'**
  String get catMasterclasses;

  /// No description provided for @catPartnerships.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get catPartnerships;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String distanceAway(String km);

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'from {price} QAR'**
  String fromPrice(String price);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @maxDistance.
  ///
  /// In en, this message translates to:
  /// **'Max distance'**
  String get maxDistance;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get ageGroup;

  /// No description provided for @anyAge.
  ///
  /// In en, this message translates to:
  /// **'Any age'**
  String get anyAge;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sortDistance.
  ///
  /// In en, this message translates to:
  /// **'Nearest first'**
  String get sortDistance;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortRating;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get noFavorites;

  /// No description provided for @noFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any listing to save it here'**
  String get noFavoritesHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search'**
  String get noResultsHint;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviews(int count);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Family-life directory for Doha'**
  String get aboutAppSubtitle;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String kmUnit(String km);

  /// No description provided for @upToPrice.
  ///
  /// In en, this message translates to:
  /// **'up to {price} QAR'**
  String upToPrice(String price);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(int count);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @subjectMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get subjectMath;

  /// No description provided for @subjectArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get subjectArabic;

  /// No description provided for @subjectEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get subjectEnglish;

  /// No description provided for @subjectScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get subjectScience;

  /// No description provided for @subjectExamPrep.
  ///
  /// In en, this message translates to:
  /// **'Exam prep'**
  String get subjectExamPrep;

  /// No description provided for @formatOneOnOne.
  ///
  /// In en, this message translates to:
  /// **'1-on-1'**
  String get formatOneOnOne;

  /// No description provided for @formatSmallGroup.
  ///
  /// In en, this message translates to:
  /// **'Small group'**
  String get formatSmallGroup;

  /// No description provided for @formatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get formatOnline;

  /// No description provided for @formatAtCentre.
  ///
  /// In en, this message translates to:
  /// **'At centre'**
  String get formatAtCentre;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'{price} QAR/hr'**
  String perHour(String price);

  /// No description provided for @trialLesson.
  ///
  /// In en, this message translates to:
  /// **'Trial lesson'**
  String get trialLesson;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs experience'**
  String yearsExperience(int years);

  /// No description provided for @languagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesLabel;

  /// No description provided for @viewCentre.
  ///
  /// In en, this message translates to:
  /// **'View centre'**
  String get viewCentre;

  /// No description provided for @ourTutors.
  ///
  /// In en, this message translates to:
  /// **'Our tutors'**
  String get ourTutors;

  /// No description provided for @thisWeekend.
  ///
  /// In en, this message translates to:
  /// **'This weekend'**
  String get thisWeekend;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @seatsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} seats left'**
  String seatsLeft(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String durationMinutes(int min);

  /// No description provided for @withParent.
  ///
  /// In en, this message translates to:
  /// **'With parent'**
  String get withParent;

  /// No description provided for @dropOff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get dropOff;

  /// No description provided for @seriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count}-session course'**
  String seriesCount(int count);

  /// No description provided for @oneOffEvent.
  ///
  /// In en, this message translates to:
  /// **'One-off'**
  String get oneOffEvent;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @perSession.
  ///
  /// In en, this message translates to:
  /// **'{price} QAR / session'**
  String perSession(String price);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @roleFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get roleFamily;

  /// No description provided for @roleProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get roleProvider;

  /// No description provided for @roleTutor.
  ///
  /// In en, this message translates to:
  /// **'Tutoring centre'**
  String get roleTutor;

  /// No description provided for @roleMasterclass.
  ///
  /// In en, this message translates to:
  /// **'Masterclass provider'**
  String get roleMasterclass;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get noAccountPrompt;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountPrompt;

  /// No description provided for @demoLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Try the demo accounts: family@demo · tutor@demo · mc@demo (password: demo1234)'**
  String get demoLoginHint;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String signedInAs(String name);

  /// No description provided for @authSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSheetTitle;

  /// No description provided for @authSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account to send your request.'**
  String get authSheetHint;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent — the provider will be in touch.'**
  String get requestSent;

  /// No description provided for @inquiryComposerTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a request'**
  String get inquiryComposerTitle;

  /// No description provided for @inquiryComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the provider a bit about your child and what you\'re looking for.'**
  String get inquiryComposerHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequests;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @requestStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestStatusPending;

  /// No description provided for @requestStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get requestStatusAccepted;

  /// No description provided for @requestStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get requestStatusDeclined;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get myListings;

  /// No description provided for @inquiries.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get inquiries;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @providerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get providerSettings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBack(String name);

  /// No description provided for @underReviewBanner.
  ///
  /// In en, this message translates to:
  /// **'Your account is under review — listings stay in draft until approved.'**
  String get underReviewBanner;

  /// No description provided for @metricActiveListings.
  ///
  /// In en, this message translates to:
  /// **'Active listings'**
  String get metricActiveListings;

  /// No description provided for @metricNewInquiries.
  ///
  /// In en, this message translates to:
  /// **'New inquiries'**
  String get metricNewInquiries;

  /// No description provided for @metricPendingCommission.
  ///
  /// In en, this message translates to:
  /// **'Pending commission'**
  String get metricPendingCommission;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New listing'**
  String get newListing;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListing;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitForReview;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @draftCanOnlySubmitWhenVerified.
  ///
  /// In en, this message translates to:
  /// **'Verify your account to submit listings for review.'**
  String get draftCanOnlySubmitWhenVerified;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get statusPending;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get fieldSubtitle;

  /// No description provided for @fieldNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get fieldNeighborhood;

  /// No description provided for @fieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (QAR, from)'**
  String get fieldPrice;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get fieldHighlights;

  /// No description provided for @fieldImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get fieldImageUrl;

  /// No description provided for @fieldAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get fieldAddImage;

  /// No description provided for @fieldAddHighlight.
  ///
  /// In en, this message translates to:
  /// **'Add highlight'**
  String get fieldAddHighlight;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any listings yet'**
  String get noListingsYet;

  /// No description provided for @createFirstListing.
  ///
  /// In en, this message translates to:
  /// **'Create your first listing'**
  String get createFirstListing;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @noInquiriesYet.
  ///
  /// In en, this message translates to:
  /// **'No inquiries yet'**
  String get noInquiriesYet;

  /// No description provided for @commissionApplies.
  ///
  /// In en, this message translates to:
  /// **'A {amount} QAR commission applies for this accepted student.'**
  String commissionApplies(int amount);

  /// No description provided for @contactRevealed.
  ///
  /// In en, this message translates to:
  /// **'{email} — get in touch directly.'**
  String contactRevealed(String email);

  /// No description provided for @acceptedStudents.
  ///
  /// In en, this message translates to:
  /// **'Accepted students'**
  String get acceptedStudents;

  /// No description provided for @pendingCommission.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingCommission;

  /// No description provided for @paidCommission.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidCommission;

  /// No description provided for @commissionListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Accepted student requests will appear here.'**
  String get commissionListEmpty;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get fillRequiredFields;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @switchToFamily.
  ///
  /// In en, this message translates to:
  /// **'Browse as family'**
  String get switchToFamily;

  /// No description provided for @switchToProvider.
  ///
  /// In en, this message translates to:
  /// **'Back to provider dashboard'**
  String get switchToProvider;

  /// No description provided for @genericLoadError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @listingNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This listing is no longer available'**
  String get listingNoLongerAvailable;

  /// No description provided for @providerUnverifiedBanner.
  ///
  /// In en, this message translates to:
  /// **'Your account is awaiting verification. Listings will stay in DRAFT until an admin approves your account.'**
  String get providerUnverifiedBanner;

  /// No description provided for @providerEarningsBillingPending.
  ///
  /// In en, this message translates to:
  /// **'Billing is not yet active. Commission statements and payouts will appear here once billing ships.'**
  String get providerEarningsBillingPending;

  /// No description provided for @providerProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get providerProfileSaved;

  /// No description provided for @providerMarkContacted.
  ///
  /// In en, this message translates to:
  /// **'Mark contacted'**
  String get providerMarkContacted;

  /// No description provided for @providerComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get providerComplete;

  /// No description provided for @providerContactNotRevealed.
  ///
  /// In en, this message translates to:
  /// **'Contact details unlocked after acceptance'**
  String get providerContactNotRevealed;

  /// No description provided for @providerContactRevealed.
  ///
  /// In en, this message translates to:
  /// **'Contact revealed'**
  String get providerContactRevealed;

  /// No description provided for @providerSubscribers.
  ///
  /// In en, this message translates to:
  /// **'Subscribers'**
  String get providerSubscribers;

  /// No description provided for @providerNoSubscribers.
  ///
  /// In en, this message translates to:
  /// **'No subscribers yet'**
  String get providerNoSubscribers;

  /// No description provided for @listingSubmittedForReview.
  ///
  /// In en, this message translates to:
  /// **'Listing submitted for review'**
  String get listingSubmittedForReview;

  /// No description provided for @statusContacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get statusContacted;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects (comma-separated)'**
  String get subjects;

  /// No description provided for @hourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate (QAR)'**
  String get hourlyRate;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @suggestService.
  ///
  /// In en, this message translates to:
  /// **'Suggest a service'**
  String get suggestService;

  /// No description provided for @suggestServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Missing something in Doha? Let us know what you\'d love to see.'**
  String get suggestServiceHint;

  /// No description provided for @suggestionCategory.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get suggestionCategory;

  /// No description provided for @suggestionCategoryAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get suggestionCategoryAny;

  /// No description provided for @suggestionNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood (optional)'**
  String get suggestionNeighborhood;

  /// No description provided for @suggestionMessage.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion'**
  String get suggestionMessage;

  /// No description provided for @suggestionMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you\'d love to find near you…'**
  String get suggestionMessageHint;

  /// No description provided for @suggestionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get suggestionSubmit;

  /// No description provided for @suggestionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your suggestion has been submitted.'**
  String get suggestionSubmitted;

  /// No description provided for @mySuggestions.
  ///
  /// In en, this message translates to:
  /// **'My suggestions'**
  String get mySuggestions;

  /// No description provided for @suggestionStatusNew.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get suggestionStatusNew;

  /// No description provided for @suggestionStatusReviewed.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get suggestionStatusReviewed;

  /// No description provided for @suggestionStatusActedOn.
  ///
  /// In en, this message translates to:
  /// **'Acted on'**
  String get suggestionStatusActedOn;

  /// No description provided for @suggestionStatusDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get suggestionStatusDismissed;

  /// No description provided for @rateLimited.
  ///
  /// In en, this message translates to:
  /// **'Rate limited. Please try again shortly.'**
  String get rateLimited;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
