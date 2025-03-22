import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'AniFlim',
      'settings': 'Settings',
      'darkTheme': 'Dark Theme',
      'language': 'Language',
      'detail': 'Detail',
      'watch': 'Watch',
      'animelists': 'Anime Lists',
      'watched': 'Watched',
      'watching': 'Watching',
      'home': 'Home',
      'profile': 'Profile',
      'myprofile': 'My Profile',
      'lists': 'My Lists',
      'episode': 'Episode',
      'changepassword': 'Change Password',
      'changeavatar': 'Change Avatar',
      'logout': 'Logout',
      'registration': 'Registration',
      'login': 'Login',
      'enl': 'Please enter your login',
      'email': 'Email',
      'ene': 'Please enter your email',
      'password': 'Password',
      'enp': 'Please enter your password',
      'register': 'Register',
      'style': 'Style',
      'logIn': 'Log In',
      'skip': 'Skip',
      'outin': 'Out in',
      'description': 'Description',
      'status': 'Status',
      'genres': 'Genres',
      'studio': 'Studio',
      'addtolist': 'Add To List',
      'removefromlist': 'Remove From List',
      'continueWatch': 'Continue',
      'no': 'No',
      'continueWatching': 'Do you want to continue watching anime?',
      'ecp': 'Sorry, this feature has not been implemented yet, to change your password, log in to your personal account on the site. "https://aniflim.space/profile"',
      'autocontinue': 'Auto-switching an episode',
      'last': 'Last',
      'lf': 'Login Failed',
      'iup': 'Invalid username or password.',
      'rf': 'Registration Failed',
      'iupe': 'Invalid username or password or email.',
      'lastanime': 'Last anime',
      'aua': 'An update is available',
      'nv': 'A new version of the app is available. Do you want to upgrade?',
      'yes': 'Yes',
      'all_watching': 'All watching',
      'all_watched': 'All watched',
      'codecSettings': 'Use the HEVC codec',
      'enableHEVC': 'This codec allows you to reduce the consumption of traffic and space on the device when watching and downloading anime',
      'hevcNotSupported': 'Your device does not support the HEVC codec',
      'voiceover': 'Voiceover',
      'downloadedanime': 'Downloaded anime',
      'downloadinganime': 'Downloading Anime...',
      'downloading': 'Downloading',
      'canceldownload': 'Cancel the download',
      'unarchive': 'Unarchive',
      'notification': 'Notifications',
      'globalSettings': 'Globals settings',
      'playerSettings': 'Player settings',
      'marathonMode': 'Marathon mode',
      'autoSkipOpening': 'Auto skip opening',
      'searchEpisode': 'Search episode',
      'enterEpisodeNumber': 'Enter episode number',
      'ageRaiting': 'Age raiting',
      'quality': 'Quality',
      'schedule': 'Schedule',
    },
    'ru': {
      'title': 'AniFlim',
      'settings': 'Настройки',
      'darkTheme': 'Темная тема',
      'language': 'Язык',
      'detail': 'Подробно',
      'watch': 'Смотреть',
      'animelists': 'Аниме списки',
      'watched': 'Смотрю',
      'watching': 'Просмотренно',
      'home': 'Главная',
      'profile': 'Профиль',
      'myprofile': 'Мой Профиль',
      'lists': 'Мои списки',
      'episode': 'Эпизод',
      'changepassword': 'Изменить Пароль',
      'changeavatar': 'Изменить Аватар',
      'logout': 'Выйти',
      'registration': 'Регистрация',
      'login': 'Логин',
      'enl': 'Пожалуйста, введите свой логин',
      'email': 'Почта',
      'ene': 'Пожалуйста, введите свою почту',
      'password': 'Пароль',
      'enp': 'Пожалуйста, введите свой пароль',
      'register': 'Зарегестрироваться',
      'style': 'Тема',
      'logIn': 'Войти',
      'skip': 'Пропустить',
      'outin': 'Вышел в',
      'description': 'Описание',
      'status': 'Статус',
      'genres': 'Жанры',
      'studio': 'Студия',
      'addtolist': 'Добавить в список',
      'removefromlist': 'Удалить из списка',
      'continueWatch': 'Продолжить',
      'no': 'Нет',
      'continueWatching': 'Хотите продолжить просмотр аниме?',
      'ecp': 'Извините, данная функция ещё не реализована, для смены пароля зайдите в личный кабинет на сайте. "https://aniflim.space/profile"',
      'autocontinue': 'Авто переключение эпизода',
      'last': 'Последние',
      'lf': 'Ошибка входа',
      'iup': 'Неверное имя пользователя или пароль.',
      'rf': 'Ошибка регистрации',
      'iupe': 'Неверное имя пользователя, пароль или адрес электронной почты.',
      'lastanime': 'Последние аниме',
      'aua': 'Доступно обновление',
      'nv': 'Новая версия приложения доступна. Хотите обновить?',
      'yes': 'Да',
      'all_watching': 'Всего просмотрено',
      'all_watched': 'Всего смотрю',
      'codecSettings': 'Использовать кодек HEVC',
      'enableHEVC': 'Данный кодек позволяет снизить потребление трафика и места на устройстве при просмотре и загрузке аниме',
      'hevcNotSupported': 'Ваше устройство не поддерживает кодек HEVC',
      'voiceover': 'Озвучка',
      'downloadedanime': 'Скачанные аниме',
      'downloadinganime': 'Загрузка аниме...',
      'downloading': 'Скачивание',
      'canceldownload': 'Отменить загрузку',
      'unarchive': 'Разархивирование',
      'notification': 'Уведомления',
      'globalSettings': 'Глобальные настройки',
      'playerSettings': 'Настройки плеера',
      'marathonMode': 'Режим марафона',
      'autoSkipOpening': 'Авто пропуск опенинга',
      'searchEpisode': 'Поиск эпизода',
      'enterEpisodeNumber': 'Введите номер эпизода',
      'ageRaiting': 'Возрастной рейтинг',
      'quality': 'Качество',
      'schedule': 'Расписание',
    },
  };

  String get title {
    return _localizedValues[locale.languageCode]!['title']!;
  }

  String get settings {
    return _localizedValues[locale.languageCode]!['settings']!;
  }

  String get darkTheme {
    return _localizedValues[locale.languageCode]!['darkTheme']!;
  }

  String get language {
    return _localizedValues[locale.languageCode]!['language']!;
  }

  String get detail {
    return _localizedValues[locale.languageCode]!['detail']!;
  }

  String get watch {
    return _localizedValues[locale.languageCode]!['watch']!;
  }

  String get animelists {
    return _localizedValues[locale.languageCode]!['animelists']!;
  }

  String get watched {
    return _localizedValues[locale.languageCode]!['watched']!;
  }

  String get watching {
    return _localizedValues[locale.languageCode]!['watching']!;
  }

  String get home {
    return _localizedValues[locale.languageCode]!['home']!;
  }

  String get profile {
    return _localizedValues[locale.languageCode]!['profile']!;
  }

  String get myprofile {
    return _localizedValues[locale.languageCode]!['myprofile']!;
  }

  String get lists {
    return _localizedValues[locale.languageCode]!['lists']!;
  }

  String get episode {
    return _localizedValues[locale.languageCode]!['episode']!;
  }

  String get changepassword {
    return _localizedValues[locale.languageCode]!['changepassword']!;
  }

  String get changeavatar {
    return _localizedValues[locale.languageCode]!['changeavatar']!;
  }

  String get logout {
    return _localizedValues[locale.languageCode]!['logout']!;
  }

  String get registration {
    return _localizedValues[locale.languageCode]!['registration']!;
  }

  String get login {
    return _localizedValues[locale.languageCode]!['login']!;
  }

  String get enl {
    return _localizedValues[locale.languageCode]!['enl']!;
  }

  String get email {
    return _localizedValues[locale.languageCode]!['email']!;
  }

  String get ene {
    return _localizedValues[locale.languageCode]!['ene']!;
  }

  String get password {
    return _localizedValues[locale.languageCode]!['password']!;
  }

  String get enp {
    return _localizedValues[locale.languageCode]!['enp']!;
  }

  String get register {
    return _localizedValues[locale.languageCode]!['register']!;
  }

  String get style {
    return _localizedValues[locale.languageCode]!['style']!;
  }

  String get logIn {
    return _localizedValues[locale.languageCode]!['logIn']!;
  }

  String get skip {
    return _localizedValues[locale.languageCode]!['skip']!;
  }

  String get outin {
    return _localizedValues[locale.languageCode]!['outin']!;
  }

  String get description {
    return _localizedValues[locale.languageCode]!['description']!;
  }

  String get status {
    return _localizedValues[locale.languageCode]!['status']!;
  }

  String get genres {
    return _localizedValues[locale.languageCode]!['genres']!;
  }

  String get studio {
    return _localizedValues[locale.languageCode]!['studio']!;
  }

  String get addtolist {
    return _localizedValues[locale.languageCode]!['addtolist']!;
  }

  String get removefromlist {
    return _localizedValues[locale.languageCode]!['removefromlist']!;
  }

  String get continueWatch {
    return _localizedValues[locale.languageCode]!['continueWatch']!;
  }

  String get no {
    return _localizedValues[locale.languageCode]!['no']!;
  }

  String get continueWatching {
    return _localizedValues[locale.languageCode]!['continueWatching']!;
  }

  String get ecp {
    return _localizedValues[locale.languageCode]!['ecp']!;
  }

  String get autocontinue {
    return _localizedValues[locale.languageCode]!['autocontinue']!;
  }

  String get last {
    return _localizedValues[locale.languageCode]!['last']!;
  }

  String get lf {
    return _localizedValues[locale.languageCode]!['lf']!;
  }

  String get iup {
    return _localizedValues[locale.languageCode]!['iup']!;
  }

  String get rf {
    return _localizedValues[locale.languageCode]!['rf']!;
  }

  String get iupe {
    return _localizedValues[locale.languageCode]!['iupe']!;
  }

  String get lastanime {
    return _localizedValues[locale.languageCode]!['lastanime']!;
  }

  String get aua {
    return _localizedValues[locale.languageCode]!['aua']!;
  }

  String get nv {
    return _localizedValues[locale.languageCode]!['nv']!;
  }

  String get yes {
    return _localizedValues[locale.languageCode]!['yes']!;
  }

  String get all_watching {
    return _localizedValues[locale.languageCode]!['all_watching']!;
  }

  String get all_watched {
    return _localizedValues[locale.languageCode]!['all_watched']!;
  }

  String get codecSettings {
    return _localizedValues[locale.languageCode]!['codecSettings']!;
  }

  String get enableHEVC {
    return _localizedValues[locale.languageCode]!['enableHEVC']!;
  }

  String get hevcNotSupported {
    return _localizedValues[locale.languageCode]!['hevcNotSupported']!;
  }

  String get voiceover {
    return _localizedValues[locale.languageCode]!['voiceover']!;
  }

  String get downloadedanime {
    return _localizedValues[locale.languageCode]!['downloadedanime']!;
  }

  String get downloadinganime {
    return _localizedValues[locale.languageCode]!['downloadinganime']!;
  }

  String get downloading {
    return _localizedValues[locale.languageCode]!['downloading']!;
  }

  String get canceldownload {
    return _localizedValues[locale.languageCode]!['canceldownload']!;
  }

  String get unarchive {
    return _localizedValues[locale.languageCode]!['unarchive']!;
  }

  String get notification {
    return _localizedValues[locale.languageCode]!['notification']!;
  }

  String get globalSettings {
    return _localizedValues[locale.languageCode]!['globalSettings']!;
  }

  String get playerSettings {
    return _localizedValues[locale.languageCode]!['playerSettings']!;
  }

  String get marathonMode {
    return _localizedValues[locale.languageCode]!['marathonMode']!;
  }

  String get autoSkipOpening {
    return _localizedValues[locale.languageCode]!['autoSkipOpening']!;
  }

  String get searchEpisode {
    return _localizedValues[locale.languageCode]!['searchEpisode']!;
  }

  String get enterEpisodeNumber {
    return _localizedValues[locale.languageCode]!['enterEpisodeNumber']!;
  }

  String get ageRaiting {
    return _localizedValues[locale.languageCode]!['ageRaiting']!;
  }

  String get quality {
    return _localizedValues[locale.languageCode]!['quality']!;
  }

  String get schedule {
    return _localizedValues[locale.languageCode]!['schedule']!;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
