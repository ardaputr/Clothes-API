import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<int> _favoriteIds = [];
  List<Clothing> _favoriteClothes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favIds = await FavoriteService.getFavorites();
      final allClothes = await ApiService.fetchAllClothes();

      final favClothes =
          allClothes.where((c) => favIds.contains(c.id)).toList();

      setState(() {
        _favoriteIds = favIds;
        _favoriteClothes = favClothes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Pakaian')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : _favoriteClothes.isEmpty
              ? const Center(child: Text('Belum ada favorit'))
              : RefreshIndicator(
                onRefresh: _refresh,
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _favoriteClothes.length,
                  itemBuilder: (context, index) {
                    final item = _favoriteClothes[index];
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
                                child: Center(
                                  child: Icon(
                                    Icons.checkroom,
                                    size: 64,
                                    color: Colors.blueAccent,
                                  ),
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
              ),
    );
  }
}
