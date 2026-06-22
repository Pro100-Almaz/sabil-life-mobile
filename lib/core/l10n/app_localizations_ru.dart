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

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get register => 'Регистрация';

  @override
  String get login => 'Вход';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get fullName => 'Полное имя';

  @override
  String get roleFamily => 'Семья';

  @override
  String get roleProvider => 'Поставщик услуг';

  @override
  String get roleTutor => 'Центр репетиторства';

  @override
  String get roleMasterclass => 'Организатор мастер-классов';

  @override
  String get noAccountPrompt => 'Ещё нет аккаунта?';

  @override
  String get haveAccountPrompt => 'Уже есть аккаунт?';

  @override
  String get demoLoginHint =>
      'Демо-аккаунты: family@demo · tutor@demo · mc@demo (пароль: demo1234)';

  @override
  String signedInAs(String name) {
    return 'Вы вошли как $name';
  }

  @override
  String get authSheetTitle => 'Войдите, чтобы продолжить';

  @override
  String get authSheetHint =>
      'Войдите или создайте аккаунт, чтобы отправить запрос.';

  @override
  String get request => 'Отправить запрос';

  @override
  String get requestSent =>
      'Запрос отправлен — поставщик скоро свяжется с вами.';

  @override
  String get inquiryComposerTitle => 'Отправить запрос';

  @override
  String get inquiryComposerHint =>
      'Расскажите немного о ребёнке и о том, что вам нужно.';

  @override
  String get send => 'Отправить';

  @override
  String get myRequests => 'Мои запросы';

  @override
  String get noRequestsYet => 'Запросов пока нет';

  @override
  String get requestStatusPending => 'В ожидании';

  @override
  String get requestStatusAccepted => 'Принят';

  @override
  String get requestStatusDeclined => 'Отклонён';

  @override
  String get dashboard => 'Главная';

  @override
  String get myListings => 'Объявления';

  @override
  String get inquiries => 'Запросы';

  @override
  String get earnings => 'Доходы';

  @override
  String get providerSettings => 'Настройки';

  @override
  String welcomeBack(String name) {
    return 'С возвращением, $name';
  }

  @override
  String get underReviewBanner =>
      'Ваш аккаунт на проверке — объявления остаются в черновиках до одобрения.';

  @override
  String get metricActiveListings => 'Активные объявления';

  @override
  String get metricNewInquiries => 'Новые запросы';

  @override
  String get metricPendingCommission => 'Комиссия к оплате';

  @override
  String get newListing => 'Новое объявление';

  @override
  String get editListing => 'Редактировать';

  @override
  String get submitForReview => 'Отправить на проверку';

  @override
  String get saveDraft => 'Сохранить черновик';

  @override
  String get draftCanOnlySubmitWhenVerified =>
      'Подтвердите аккаунт, чтобы отправлять объявления на проверку.';

  @override
  String get statusDraft => 'Черновик';

  @override
  String get statusPending => 'На проверке';

  @override
  String get statusActive => 'Активно';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get fieldTitle => 'Название';

  @override
  String get fieldSubtitle => 'Подзаголовок';

  @override
  String get fieldNeighborhood => 'Район';

  @override
  String get fieldPrice => 'Цена (QAR, от)';

  @override
  String get fieldDescription => 'Описание';

  @override
  String get fieldHighlights => 'Особенности';

  @override
  String get fieldImageUrl => 'Ссылка на изображение';

  @override
  String get fieldAddImage => 'Добавить изображение';

  @override
  String get fieldAddHighlight => 'Добавить особенность';

  @override
  String get noListingsYet => 'У вас пока нет объявлений';

  @override
  String get createFirstListing => 'Создать первое объявление';

  @override
  String get accept => 'Принять';

  @override
  String get decline => 'Отклонить';

  @override
  String get noInquiriesYet => 'Пока нет запросов';

  @override
  String commissionApplies(int amount) {
    return 'За принятого ученика взимается комиссия $amount QAR.';
  }

  @override
  String contactRevealed(String email) {
    return '$email — свяжитесь напрямую.';
  }

  @override
  String get acceptedStudents => 'Принятые ученики';

  @override
  String get pendingCommission => 'К оплате';

  @override
  String get paidCommission => 'Оплачено';

  @override
  String get commissionListEmpty =>
      'Принятые запросы будут отображаться здесь.';

  @override
  String get fillRequiredFields =>
      'Пожалуйста, заполните все обязательные поля.';

  @override
  String minutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String hoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String daysAgo(int count) {
    return '$count дн назад';
  }

  @override
  String get switchToFamily => 'Перейти в семейный режим';

  @override
  String get switchToProvider => 'Вернуться в кабинет провайдера';

  @override
  String get switchToTutor => 'Перейти в кабинет репетитора';

  @override
  String get switchToMasterclass => 'Перейти в кабинет мастер-классов';

  @override
  String get genericLoadError => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get retry => 'Повторить';

  @override
  String get loading => 'Загрузка…';

  @override
  String get listingNoLongerAvailable => 'Это объявление больше недоступно';

  @override
  String get providerUnverifiedBanner =>
      'Ваш аккаунт ожидает верификации. Объявления останутся в статусе ЧЕРНОВИК до одобрения администратором.';

  @override
  String get providerEarningsBillingPending =>
      'Биллинг ещё не активен. Данные о комиссиях и выплатах появятся здесь после запуска биллинга.';

  @override
  String get providerProfileSaved => 'Профиль сохранён';

  @override
  String get providerMarkContacted => 'Отметить как связался';

  @override
  String get providerComplete => 'Завершить';

  @override
  String get providerContactNotRevealed =>
      'Контактные данные открываются после принятия';

  @override
  String get providerContactRevealed => 'Контакт открыт';

  @override
  String get providerSubscribers => 'Подписчики';

  @override
  String get providerNoSubscribers => 'Подписчиков пока нет';

  @override
  String get listingSubmittedForReview => 'Объявление отправлено на проверку';

  @override
  String get statusContacted => 'Связались';

  @override
  String get statusCompleted => 'Завершено';

  @override
  String get filterAll => 'Все';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get bio => 'О себе (необязательно)';

  @override
  String get subjects => 'Предметы';

  @override
  String get hourlyRate => 'Цена за час (QAR)';

  @override
  String get availability => 'Доступность';

  @override
  String get profileFormats => 'Форматы обучения';

  @override
  String get profileAgeGroups => 'Возрастные группы';

  @override
  String get profileLanguages => 'Языки';

  @override
  String get profileYearsExperience => 'Стаж (лет)';

  @override
  String get profileCredentials => 'Квалификация (необязательно)';

  @override
  String get profileAvatar => 'Фото профиля (необязательно)';

  @override
  String get profileTrialAvailable => 'Предлагать пробное занятие';

  @override
  String get profileSubmittedForReview => 'Профиль отправлен на проверку';

  @override
  String get suggestService => 'Предложить услугу';

  @override
  String get suggestServiceHint => 'Чего не хватает в Дохе? Расскажите нам.';

  @override
  String get suggestionCategory => 'Категория (необязательно)';

  @override
  String get suggestionCategoryAny => 'Любая';

  @override
  String get suggestionNeighborhood => 'Район (необязательно)';

  @override
  String get suggestionMessage => 'Ваше предложение';

  @override
  String get suggestionMessageHint => 'Опишите, что вы хотели бы найти рядом…';

  @override
  String get suggestionSubmit => 'Отправить';

  @override
  String get suggestionSubmitted => 'Спасибо! Ваше предложение отправлено.';

  @override
  String get mySuggestions => 'Мои предложения';

  @override
  String get suggestionStatusNew => 'Отправлено';

  @override
  String get suggestionStatusReviewed => 'На рассмотрении';

  @override
  String get suggestionStatusActedOn => 'Принято к действию';

  @override
  String get suggestionStatusDismissed => 'Отклонено';

  @override
  String get rateLimited => 'Слишком много запросов. Попробуйте позже.';

  @override
  String get other => 'Другое';

  @override
  String get addCustomSubject => 'Добавить свой предмет';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get photoFromGallery => 'Выбрать из галереи';

  @override
  String get photoFromCamera => 'Сделать фото';
}
