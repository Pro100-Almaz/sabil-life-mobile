// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'Sabil Life';

  @override
  String get navHome => 'Басты бет';

  @override
  String get navMap => 'Карта';

  @override
  String get navFavorites => 'Таңдаулылар';

  @override
  String get navSettings => 'Баптаулар';

  @override
  String get searchHint => 'Мектептер, сабақтар іздеу…';

  @override
  String get nearYou => 'Жақын маңда';

  @override
  String get featured => 'Ұсынылған';

  @override
  String get popularInDoha => 'Дохада танымал';

  @override
  String get catAll => 'Барлығы';

  @override
  String get catSchools => 'Мектептер';

  @override
  String get catNurseries => 'Балабақшалар';

  @override
  String get catActivities => 'Сабақтар';

  @override
  String get catEntertainment => 'Ойын-сауық';

  @override
  String get catTutoring => 'Репетиторлар';

  @override
  String get catMasterclasses => 'Шеберлік сыныптары';

  @override
  String get catPartnerships => 'Серіктестер';

  @override
  String distanceAway(String km) {
    return '$km км қашықтықта';
  }

  @override
  String fromPrice(String price) {
    return '$price QAR-дан';
  }

  @override
  String get free => 'Тегін';

  @override
  String get filters => 'Сүзгілер';

  @override
  String get sort => 'Сұрыптау';

  @override
  String get maxDistance => 'Макс. қашықтық';

  @override
  String get priceRange => 'Баға аралығы';

  @override
  String get ageGroup => 'Жас';

  @override
  String get anyAge => 'Кез келген жас';

  @override
  String get apply => 'Қолдану';

  @override
  String get reset => 'Тазалау';

  @override
  String get sortDistance => 'Алдымен жақындары';

  @override
  String get sortRating => 'Жоғары рейтингті';

  @override
  String get sortPriceLow => 'Баға: өсу бойынша';

  @override
  String get save => 'Сақтау';

  @override
  String get saved => 'Сақталды';

  @override
  String get noFavorites => 'Әзірге ештеңе сақталмаған';

  @override
  String get noFavoritesHint => 'Сақтау үшін жүрекшені басыңыз';

  @override
  String get noResults => 'Нәтиже табылмады';

  @override
  String get noResultsHint => 'Сүзгілерді немесе іздеуді өзгертіп көріңіз';

  @override
  String get viewOnMap => 'Картадан көру';

  @override
  String reviews(int count) {
    return '$count пікір';
  }

  @override
  String get about => 'Біз туралы';

  @override
  String get aboutAppSubtitle => 'Доха бойынша отбасылық гид';

  @override
  String get details => 'Толығырақ';

  @override
  String get highlights => 'Ерекшеліктері';

  @override
  String get language => 'Тіл';

  @override
  String get selectLanguage => 'Тілді таңдаңыз';

  @override
  String resultsCount(int count) {
    return '$count нәтиже';
  }

  @override
  String get seeAll => 'Барлығы';

  @override
  String kmUnit(String km) {
    return '$km км';
  }

  @override
  String upToPrice(String price) {
    return '$price QAR дейін';
  }

  @override
  String monthsAgo(int count) {
    return '$count ай бұрын';
  }

  @override
  String get share => 'Бөлісу';

  @override
  String get linkCopied => 'Сілтеме көшірілді';

  @override
  String get version => 'Нұсқа';

  @override
  String get subjectMath => 'Математика';

  @override
  String get subjectArabic => 'Араб тілі';

  @override
  String get subjectEnglish => 'Ағылшын тілі';

  @override
  String get subjectScience => 'Жаратылыстану';

  @override
  String get subjectExamPrep => 'Емтиханға дайындық';

  @override
  String get formatOneOnOne => 'Жеке сабақ';

  @override
  String get formatSmallGroup => 'Шағын топ';

  @override
  String get formatOnline => 'Онлайн';

  @override
  String get formatAtCentre => 'Орталықта';

  @override
  String perHour(String price) {
    return '$price QAR/сағ';
  }

  @override
  String get trialLesson => 'Сынақ сабағы';

  @override
  String yearsExperience(int years) {
    return 'Тәжірибе: $years жыл';
  }

  @override
  String get languagesLabel => 'Тілдер';

  @override
  String get viewCentre => 'Орталықты ашу';

  @override
  String get ourTutors => 'Біздің репетиторлар';

  @override
  String get thisWeekend => 'Осы демалыста';

  @override
  String get nextWeek => 'Келесі аптада';

  @override
  String get later => 'Кейінірек';

  @override
  String seatsLeft(int count) {
    return '$count орын қалды';
  }

  @override
  String durationMinutes(int min) {
    return '$min мин';
  }

  @override
  String get withParent => 'Ата-анамен бірге';

  @override
  String get dropOff => 'Ата-анасыз';

  @override
  String seriesCount(int count) {
    return '$count сабақтан тұратын курс';
  }

  @override
  String get oneOffEvent => 'Бір реттік сабақ';

  @override
  String get pickDate => 'Күнді таңдаңыз';

  @override
  String perSession(String price) {
    return '$price QAR / сабақ';
  }
}
