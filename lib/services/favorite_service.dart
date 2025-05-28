import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _key = 'favorite_clothes';

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map(int.parse).toList();
  }

  static Future<void> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();
    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }
    await prefs.setStringList(_key, favs.map((e) => e.toString()).toList());
  }

  static Future<bool> isFavorite(int id) async {
    final favs = await getFavorites();
    return favs.contains(id);
  }
}
