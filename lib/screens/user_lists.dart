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



class UserLists extends StatefulWidget {
  final String token;
  const UserLists({Key? key, required this.token}) : super(key: key);

  @override
  _UserListsState createState() => _UserListsState();
}

class _UserListsState extends State<UserLists>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Получаем данные пользователя (поля planned, watching, watched имеют тип List<AnimeProgressItem>)
      User user = await UserAPI.fetchUserData(token: widget.token, userProvider: Provider.of<UserProvider>(context, listen: false));
      setState(() {
        userInfo = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Обработка ошибки загрузки данных
      print('Error loading user data: $e');
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          localizations.animelists,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedSettings02),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          tabs: [
            Tab(text: localizations.watched),
            Tab(text: localizations.watching),
            Tab(text: localizations.planned),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Приводим тип к List<AnimeProgressItem> если необходимо
                _buildGridList(userInfo?.watched ?? [], context),
                _buildGridList(userInfo?.watching ?? [], context),
                _buildGridList(userInfo?.planned ?? [], context),
              ],
            ),
      bottomNavigationBar: kIsWeb ? null : const BottomNavBar(currentIndex: 2),
    );
  }
}
