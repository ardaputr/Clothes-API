import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clothing.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';
import 'create_edit_page.dart';
import 'login_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Clothing>> _clothesFuture;
  List<int> _favoriteIds = [];
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadClothes();
    _loadFavorites();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('session_user');
    setState(() {
      _username = username;
    });
  }

  void _loadClothes() {
    _clothesFuture = ApiService.fetchAllClothes();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoriteService.getFavorites();
    setState(() {
      _favoriteIds = favs;
    });
  }

  Future<void> _toggleFavorite(int id) async {
    await FavoriteService.toggleFavorite(id);
    await _loadFavorites();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadClothes();
    });
    await _loadFavorites();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pakaian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_username != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hi, $_username',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Clothing>>(
              future: _clothesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Data kosong'));
                }

                final clothes = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: clothes.length,
                    itemBuilder: (context, index) {
                      final item = clothes[index];
                      final isFav = _favoriteIds.contains(item.id);

                      return GestureDetector(
                        onTap: () async {
                          final needRefresh = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(id: item.id!),
                            ),
                          );
                          if (needRefresh == true) {
                            _refresh();
                          }
                        },
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Icon(
                                          Icons.checkroom,
                                          size: 64,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isFav
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                          onPressed: () {
                                            _toggleFavorite(item.id!);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Category: ${item.category}'),
                                Text('Price: Rp ${item.price}'),
                                Text('Rating: ${item.rating}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateEditPage()),
          );
          if (added == true) {
            _refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
