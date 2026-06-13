// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Sabil Life';

  @override
  String get navHome => 'Главная';

  @override
  String get navMap => 'Карта';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navSettings => 'Настройки';

  @override
  String get searchHint => 'Поиск школ, занятий…';

  @override
  String get nearYou => 'Рядом с вами';

  @override
  String get featured => 'Рекомендуемые';

  @override
  String get popularInDoha => 'Популярное в Дохе';

  @override
  String get catAll => 'Все';

  @override
  String get catSchools => 'Школы';

  @override
  String get catNurseries => 'Детские сады';

  @override
  String get catActivities => 'Занятия';

  @override
  String get catEntertainment => 'Развлечения';

  @override
  String get catTutoring => 'Репетиторы';

  @override
  String get catMasterclasses => 'Мастер-классы';

  @override
  String get catPartnerships => 'Партнёры';

  @override
  String distanceAway(String km) {
    return '$km км от вас';
  }

  @override
  String fromPrice(String price) {
    return 'от $price QAR';
  }

  @override
  String get free => 'Бесплатно';

  @override
  String get filters => 'Фильтры';

  @override
  String get sort => 'Сортировка';

  @override
  String get maxDistance => 'Макс. расстояние';

  @override
  String get priceRange => 'Диапазон цен';

  @override
  String get ageGroup => 'Возраст';

  @override
  String get anyAge => 'Любой возраст';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get sortDistance => 'Сначала ближайшие';

  @override
  String get sortRating => 'С высоким рейтингом';

  @override
  String get sortPriceLow => 'Цена: по возрастанию';

  @override
  String get save => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get noFavorites => 'Пока ничего не сохранено';

  @override
  String get noFavoritesHint => 'Нажмите на сердечко, чтобы сохранить сюда';

  @override
  String get noResults => 'Ничего не найдено';

  @override
  String get noResultsHint => 'Попробуйте изменить фильтры или запрос';

  @override
  String get viewOnMap => 'Показать на карте';

  @override
  String reviews(int count) {
    return '$count отзывов';
  }

  @override
  String get about => 'О нас';

  @override
  String get aboutAppSubtitle => 'Семейный гид по Дохе';

  @override
  String get details => 'Подробности';

  @override
  String get highlights => 'Особенности';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String resultsCount(int count) {
    return '$count результатов';
  }

  @override
  String get seeAll => 'Все';

  @override
  String kmUnit(String km) {
    return '$km км';
  }

  @override
  String upToPrice(String price) {
    return 'до $price QAR';
  }

  @override
  String monthsAgo(int count) {
    return '$count мес. назад';
  }

  @override
  String get share => 'Поделиться';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get version => 'Версия';

  @override
  String get subjectMath => 'Математика';

  @override
  String get subjectArabic => 'Арабский язык';

  @override
  String get subjectEnglish => 'Английский язык';

  @override
  String get subjectScience => 'Естественные науки';

  @override
  String get subjectExamPrep => 'Подготовка к экзаменам';

  @override
  String get formatOneOnOne => 'Один на один';

  @override
  String get formatSmallGroup => 'Мини-группа';

  @override
  String get formatOnline => 'Онлайн';

  @override
  String get formatAtCentre => 'В центре';

  @override
  String perHour(String price) {
    return '$price QAR/час';
  }

  @override
  String get trialLesson => 'Пробное занятие';

  @override
  String yearsExperience(int years) {
    return 'Опыт: $years лет';
  }

  @override
  String get languagesLabel => 'Языки';

  @override
  String get viewCentre => 'Открыть центр';

  @override
  String get ourTutors => 'Наши репетиторы';

  @override
  String get thisWeekend => 'В эти выходные';

  @override
  String get nextWeek => 'На следующей неделе';

  @override
  String get later => 'Позже';

  @override
  String seatsLeft(int count) {
    return 'Осталось мест: $count';
  }

  @override
  String durationMinutes(int min) {
    return '$min мин';
  }

  @override
  String get withParent => 'С родителем';

  @override
  String get dropOff => 'Без родителей';

  @override
  String seriesCount(int count) {
    return 'Курс из $count занятий';
  }

  @override
  String get oneOffEvent => 'Разовое занятие';

  @override
  String get pickDate => 'Выберите дату';

  @override
  String perSession(String price) {
    return '$price QAR / занятие';
  }
}
