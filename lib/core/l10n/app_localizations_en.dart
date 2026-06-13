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
}
