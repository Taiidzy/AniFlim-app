import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
      'totalTime': 'Total time',
      'planned': 'Planned',
      'episodes': 'Episodes',
      'pdm': "Passwords don't match",
      'rememberMe': 'Remember me',
      'seconds': 'Seconds',
      'second': 'Second',
      'secondss': 'Seconds',
      'minutes': 'Minutes',
      'minute': 'Minute',
      'minutess': 'Minutes',
      'hours': 'Hours',
      'hour': 'Hour',
      'hourss': 'Hours',
      'noItems': 'No items',
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
      'rf': 'Ошибка регистрации',
      'iup': 'Неверное имя пользователя или пароль.',
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
      'totalTime': 'Общее время',
      'planned': 'Запланировано',
      'episodes': 'Эпизоды',
      'pdm': 'Пароли не совпадают',
      'rememberMe': 'Запомнить меня',
      'seconds': 'Секунд',
      'second': 'Секунда',
      'secondss': 'Секунды',
      'minutes': 'Минут',
      'minute': 'Минута',
      'minutess': 'Минуты',
      'hours': 'Часов',
      'hour': 'Час',
      'hourss': 'Часа',
      'noItems': 'Нет элементов',
    },
  };

  String _t(String key) => _localizedValues[locale.languageCode]![key]!;

  String get title => _t('title');
  String get settings => _t('settings');
  String get darkTheme => _t('darkTheme');
  String get language => _t('language');
  String get detail => _t('detail');
  String get watch => _t('watch');
  String get animelists => _t('animelists');
  String get watched => _t('watched');
  String get watching => _t('watching');
  String get home => _t('home');
  String get profile => _t('profile');
  String get myprofile => _t('myprofile');
  String get lists => _t('lists');
  String get episode => _t('episode');
  String get changepassword => _t('changepassword');
  String get changeavatar => _t('changeavatar');
  String get logout => _t('logout');
  String get registration => _t('registration');
  String get login => _t('login');
  String get enl => _t('enl');
  String get email => _t('email');
  String get ene => _t('ene');
  String get password => _t('password');
  String get enp => _t('enp');
  String get register => _t('register');
  String get style => _t('style');
  String get logIn => _t('logIn');
  String get skip => _t('skip');
  String get outin => _t('outin');
  String get description => _t('description');
  String get status => _t('status');
  String get genres => _t('genres');
  String get studio => _t('studio');
  String get addtolist => _t('addtolist');
  String get removefromlist => _t('removefromlist');
  String get continueWatch => _t('continueWatch');
  String get no => _t('no');
  String get continueWatching => _t('continueWatching');
  String get ecp => _t('ecp');
  String get autocontinue => _t('autocontinue');
  String get last => _t('last');
  String get lf => _t('lf');
  String get rf => _t('rf');
  String get iup => _t('iup');
  String get lastanime => _t('lastanime');
  String get aua => _t('aua');
  String get nv => _t('nv');
  String get yes => _t('yes');
  String get all_watching => _t('all_watching');
  String get all_watched => _t('all_watched');
  String get codecSettings => _t('codecSettings');
  String get enableHEVC => _t('enableHEVC');
  String get hevcNotSupported => _t('hevcNotSupported');
  String get voiceover => _t('voiceover');
  String get downloadedanime => _t('downloadedanime');
  String get downloadinganime => _t('downloadinganime');
  String get downloading => _t('downloading');
  String get canceldownload => _t('canceldownload');
  String get unarchive => _t('unarchive');
  String get notification => _t('notification');
  String get globalSettings => _t('globalSettings');
  String get playerSettings => _t('playerSettings');
  String get marathonMode => _t('marathonMode');
  String get autoSkipOpening => _t('autoSkipOpening');
  String get searchEpisode => _t('searchEpisode');
  String get enterEpisodeNumber => _t('enterEpisodeNumber');
  String get ageRaiting => _t('ageRaiting');
  String get quality => _t('quality');
  String get schedule => _t('schedule');
  String get totalTime => _t('totalTime');
  String get planned => _t('planned');
  String get episodes => _t('episodes');
  String get pdm => _t('pdm');
  String get rememberMe => _t('rememberMe');
  String get seconds => _t('seconds');
  String get second => _t('second');
  String get secondss => _t('secondss');
  String get minutes => _t('minutes');
  String get minute => _t('minute');
  String get minutess => _t('minutess');
  String get hours => _t('hours');
  String get hour => _t('hour');
  String get hourss => _t('hourss');
  String get noItems => _t('noItems');

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
