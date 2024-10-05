import 'package:AniFlim/api/firebase_api.dart';
import 'package:AniFlim/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'l10n/app_localizations.dart';
import 'models/anime_model.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/anime_online_screen.dart';
import 'screens/home_screen.dart';
import 'screens/downloaded_anime_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/user_lists.dart';
import 'screens/notification_screen.dart';
import 'utils/permisions.dart';
import 'utils/notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Запрос разрешений
  await Permision.requestNotificationPermission();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseApi.initNotifications();

  // Инициализация уведомлений
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Создаём инстанс UserProvider и загружаем данные пользователя
  final userProvider = UserProvider();
  await userProvider.loadUserFromPreferences();

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // Используем обработчик для реакции на нажатие уведомления
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        _handleNotificationTap(notificationResponse.payload!);
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userProvider),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Notifications.showNotification(message.data['type'], message.data['text']);
  print("Handling a background message: ${message.data}");
}

void _handleNotificationTap(String payload) {
  // Проверяем, что это уведомление от нового аниме
  if (payload.startsWith('anime_')) {
    // Получаем animeId, удалив префикс "anime_"
    String animeId = payload.replaceFirst('anime_', '');

    // Навигация на экран с деталями аниме
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => AnimeOnlineScreen(animeId: animeId),
      ),
    );
  } else {
    // Обработка других типов уведомлений
    print('Другое уведомление: $payload');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey, // Устанавливаем ключ навигатора
      title: 'AniFlim',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: [Locale('en'), Locale('ru')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(onLoginSuccess: () {
          Navigator.pushReplacementNamed(context, '/');
        }),
        '/register': (context) => RegisterScreen(onRegisterSuccess: () {
          Navigator.pushReplacementNamed(context, '/login');
        }),
      },
      onGenerateRoute: (settings) {
        return _generateRoute(context, settings);
      },
    );
  }

  Route? _generateRoute(BuildContext context, RouteSettings settings) {
    switch (settings.name) {
      case '/animeDetail':
        return _buildAnimeDetailRoute(settings);
      case '/profile':
        return _buildProfileRoute(context);
      case '/lists':
        return _buildUserListsRoute(context);
      case '/downloadedanime':
        return MaterialPageRoute(builder: (context) => const DownloadedAnimeScreen());
      case '/settings':
        return MaterialPageRoute(builder: (context) => const SettingsScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (context) => NotificationsScreen());
      default:
        return null;
    }
  }

  MaterialPageRoute _buildAnimeDetailRoute(RouteSettings settings) {
    final anime = settings.arguments as Anime;
    return MaterialPageRoute(
      builder: (context) => AnimeOnlineScreen(animeId: anime.id),
    );
  }

  MaterialPageRoute _buildProfileRoute(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      return MaterialPageRoute(
        builder: (context) => ProfileScreen(
          user: user,
          onLogout: () async {
            userProvider.setUser(null);
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => LoginScreen(onLoginSuccess: () {
          Navigator.pushReplacementNamed(context, '/');
        }),
      );
    }
  }

  MaterialPageRoute _buildUserListsRoute(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      return MaterialPageRoute(
        builder: (context) => UserLists(username: user.username),
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => LoginScreen(onLoginSuccess: () {
          Navigator.pushReplacementNamed(context, '/');
        }),
      );
    }
  }
}
