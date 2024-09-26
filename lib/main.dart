import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'models/anime_model.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/anime_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/last_anime_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/user_lists.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Создаём инстанс UserProvider и загружаем данные пользователя
  final userProvider = UserProvider();
  await userProvider.loadUserFromPreferences();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userProvider),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'AniFlim',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
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
        '/': (context) => HomeScreen(),  // Изменённый HomeScreen
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    switch (settings.name) {
      case '/animeDetail':
        return _buildAnimeDetailRoute(settings);
      case '/profile':
        return _buildProfileRoute(context);
      case '/lists':
        return _buildUserListsRoute(context);
      case '/last':
        return _buildLastRoute(context);
      case '/settings':
        return MaterialPageRoute(builder: (context) => SettingsScreen());
      default:
        return null;
    }
  }

  MaterialPageRoute _buildAnimeDetailRoute(RouteSettings settings) {
    final anime = settings.arguments as Anime;
    return MaterialPageRoute(
      builder: (context) => AnimeDetailScreen(anime: anime),
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

  MaterialPageRoute _buildLastRoute(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      return MaterialPageRoute(builder: (context) => LastAnime());
    } else {
      return MaterialPageRoute(
        builder: (context) => LoginScreen(onLoginSuccess: () {
          Navigator.pushReplacementNamed(context, '/');
        }),
      );
    }
  }
}
