import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  static const String healthEndpoint = '/health';
  static const String authEndpoint = '/auth';
  static const String playerEndpoint = '/players';
  static const String playerProfileEndpoint = '/player/profile';
  static const String animalsEndpoint = '/animals';
  static const String mapsEndpoint = '/maps';
  static const String shopEndpoint = '/shop';

  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$healthEndpoint'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'error': 'Health check failed'};
    } catch (_) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.'
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$authEndpoint/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'identifier': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      return _decodeResponse(response);
    } catch (_) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.'
      };
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
            Uri.parse('$baseUrl$authEndpoint/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'username': username,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return _decodeResponse(response);
    } catch (_) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.'
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$authEndpoint/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(const Duration(seconds: 15));
      return _decodeResponse(response);
    } catch (_) {
      return {
        'success': false,
        'error': 'No se pudo iniciar sesión con Google.'
      };
    }
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'error': 'Respuesta vacía del servidor',
      };
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': decoded,
      };
    } catch (_) {
      return {
        'success': false,
        'error': 'Respuesta inválida del servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> getPlayerData(String playerId,
      {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$baseUrl$playerEndpoint/$playerId'), headers: headers)
          .timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCurrentPlayerProfile({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$playerProfileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      return _decodeResponse(response);
    } catch (_) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.'
      };
    }
  }

  static Future<Map<String, dynamic>> updateCurrentPlayerProfile({
    required String token,
    String? nickname,
    int? coins,
    int? gems,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nickname != null) body['nickname'] = nickname;
      if (coins != null) body['coins'] = coins;
      if (gems != null) body['gems'] = gems;
      final response = await http
          .put(
            Uri.parse('$baseUrl$playerProfileEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return _decodeResponse(response);
    } catch (_) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.'
      };
    }
  }

  static Future<Map<String, dynamic>> updatePlayerData(
    String playerId,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .put(
            Uri.parse('$baseUrl$playerEndpoint/$playerId'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAnimals({String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$baseUrl$animalsEndpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAnimal(int animalId,
      {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$baseUrl$animalsEndpoint/$animalId'),
              headers: headers)
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> captureAnimal(
    String playerId,
    int animalId, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .post(
            Uri.parse('$baseUrl$animalsEndpoint/$animalId/capture'),
            headers: headers,
            body: jsonEncode({'player_id': playerId}),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMaps({String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$baseUrl$mapsEndpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMapData(int mapId,
      {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$baseUrl$mapsEndpoint/$mapId'), headers: headers)
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getShopItems({String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(Uri.parse('$baseUrl$shopEndpoint/items'), headers: headers)
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> purchaseItem(
    String playerId,
    int itemId, {
    String? token,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http
          .post(
            Uri.parse('$baseUrl$shopEndpoint/purchase'),
            headers: headers,
            body: jsonEncode({'player_id': playerId, 'item_id': itemId}),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
