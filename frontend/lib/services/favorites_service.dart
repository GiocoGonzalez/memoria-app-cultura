import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favoritos';

  /// Devuelve el set de IDs favoritos (como Strings).
  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    return list.toSet();
  }

  /// Añade o quita del set.
  static Future<void> toggle(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = (prefs.getStringList(_key) ?? <String>[]).toSet();
    if (favs.contains(eventId)) favs.remove(eventId);
    else favs.add(eventId);
    await prefs.setStringList(_key, favs.toList());
  }

  /// Comprueba si un ID está en favoritos.
  static Future<bool> isFavorite(String eventId) async {
    final favs = await getFavorites();
    return favs.contains(eventId);
  }
}