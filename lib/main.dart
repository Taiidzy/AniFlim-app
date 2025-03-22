import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'models/anime_model.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/anime_online_screen.dart';
import 'screens/development_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/user_lists.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/development': (context) => const UnderDevelopmentPage(),
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
      case '/settings':
        return MaterialPageRoute(builder: (context) => const SettingsScreen());
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
    final token = Provider.of<UserProvider>(context, listen: false).currentToken;
    if (token != null) {
      return MaterialPageRoute(
        builder: (context) => ProfileScreen(
          token: token,
          onLogout: () async {
            userProvider.setToken(null);
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
    final token = Provider.of<UserProvider>(context).currentToken;
    if (token != null) {
      return MaterialPageRoute(
        builder: (context) => UserLists(username: token),
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
