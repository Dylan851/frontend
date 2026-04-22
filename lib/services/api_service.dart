import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Uri _uri(String endpoint) => Uri.parse('${ApiConfig.baseUrl}$endpoint');

  static Map<String, String> _headers({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http
          .get(_uri(ApiConfig.healthCheck), headers: _headers())
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.loginEndpoint),
            headers: _headers(),
            body: jsonEncode({'identifier': identifier, 'password': password}),
          )
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.registerEndpoint),
            headers: _headers(),
            body: jsonEncode({
              'email': email,
              'password': password,
              'username': username,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPlayerProfile({String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.playerProfileEndpoint), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updatePlayerLocation(
    double coordLat,
    double coordLng, {
    String? token,
  }) async {
    try {
      final response = await http
          .put(
            _uri(ApiConfig.playerLocationEndpoint),
            headers: _headers(token: token),
            body: jsonEncode({'coord_lat': coordLat, 'coord_lng': coordLng}),
          )
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPlayerInventory({String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.playerInventoryEndpoint), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getNearbyAnimals({String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.nearbyAnimalsEndpoint), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> captureAnimal(int animalId, {String? token}) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.captureAnimalEndpoint),
            headers: _headers(token: token),
            body: jsonEncode({'animal_id': animalId}),
          )
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMaps({String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.mapsEndpoint), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUnlockedMaps({String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.unlockedMapsEndpoint), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> unlockMap(int mapId, {String? token}) async {
    try {
      final response = await http
          .post(
            _uri('${ApiConfig.unlockMapEndpoint}?map_id=$mapId'),
            headers: _headers(token: token),
          )
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMapNpcs(int mapId, {String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.mapNpcsEndpoint(mapId)), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMapEnemies(int mapId, {String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.mapEnemiesEndpoint(mapId)), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> defeatEnemy(int enemyId, {String? token}) async {
    try {
      final response = await http
          .post(_uri(ApiConfig.enemyDefeatEndpoint(enemyId)), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getShopItems({String? token}) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.shopItemsEndpoint), headers: _headers(token: token))
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> purchaseItem(int itemId, {String? token}) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.shopPurchaseEndpoint),
            headers: _headers(token: token),
            body: jsonEncode({'item_id': itemId}),
          )
          .timeout(ApiConfig.connectionTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
