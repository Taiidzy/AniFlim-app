import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/widgets/bottom_nav_bar.dart';
import 'package:AniFlim/widgets/anime_card.dart';
import 'package:AniFlim/models/anime_model.dart';
import 'package:AniFlim/models/lists_model.dart';
import 'package:AniFlim/models/user_model.dart';
import 'package:AniFlim/utils/resolution.dart';
import 'package:AniFlim/api/user_api.dart';

class UserListsScreen extends StatefulWidget {
  final String token;

  const UserListsScreen({super.key, required this.token});

  @override
  _UserListsScreenState createState() => _UserListsScreenState();
}

class _UserListsScreenState extends State<UserListsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  User? userInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final info = await UserAPI.fetchUserData(
        token: widget.token,
        userProvider: Provider.of<UserProvider>(context, listen: false)
      );
      setState(() {
        userInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user info: $e');
    }
  }

  /// Построение списка карточек через GridView для переданного списка AnimeProgressItem.
  Widget _buildGridList(List<ListsModel> items, BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noItems,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Resolution.getGridCount(context),
        childAspectRatio: Resolution.getChildAspectRatio(context),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final ListsModel item = items[index];
        final String animeId = item.id;
        // Для каждого элемента получаем данные аниме через FutureBuilder
        return FutureBuilder<Anime>(
          future: UserAPI.fetchAnimeDetail(animeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки ($animeId)'));
            } else if (snapshot.hasData) {
              return AnimeCard(anime: snapshot.data!);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://pic.rutubelist.ru/video/2024-10-08/01/da/01daee6107408babfd3c400d734f36ec.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkTheme 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Container(
                          height: kToolbarHeight + 48,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                automaticallyImplyLeading: false,
                                title: Text(
                                  localizations.animelists,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkTheme ? Colors.white : Colors.black87,
                                  ),
                                ),
                                centerTitle: true,
                                actions: [
                                  IconButton(
                                    icon: HugeIcon(
                                      icon: HugeIcons.strokeRoundedSettings02,
                                      color: isDarkTheme ? Colors.white : Colors.black,
                                      size: 22.0,
                                    ),
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(context, '/settings'),
                                  ),
                                ],
                              ),
                              TabBar(
                                controller: _tabController,
                                indicatorColor: Colors.purple,
                                labelColor: isDarkTheme ? Colors.white : Colors.black87,
                                unselectedLabelColor: isDarkTheme ? Colors.white70 : Colors.black54,
                                indicatorSize: TabBarIndicatorSize.label,
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                                tabs: [
                                  Tab(text: localizations.watched),
                                  Tab(text: localizations.watching),
                                  Tab(text: localizations.planned),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildGridList(userInfo?.watched ?? [], context),
                              _buildGridList(userInfo?.watching ?? [], context),
                              _buildGridList(userInfo?.planned ?? [], context),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: kIsWeb ? null : ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkTheme 
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: isDarkTheme 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: const BottomNavBar(currentIndex: 2),
          ),
        ),
      ),
    );
  }
}
