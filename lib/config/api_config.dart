/// API Configuration for WildQuest Game
///
/// This file contains the configuration for connecting to the backend API.
/// You can change the baseUrl here based on your environment.

class ApiConfig {
  // API Base URL - Change this based on your environment
  // For development: http://localhost:8000
  // For production: Update with your production URL
  static const String baseUrl = 'http://localhost:8000';

  // API Endpoints
  static const String healthCheck = '/health';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';

  // Player endpoints
  static const String playersEndpoint = '/players';
  static String playerEndpoint(String playerId) => '/players/$playerId';

  // Animal endpoints
  static const String animalsEndpoint = '/animals';
  static String animalEndpoint(int animalId) => '/animals/$animalId';
  static String captureAnimalEndpoint(int animalId) => '/animals/$animalId/capture';

  // Map endpoints
  static const String mapsEndpoint = '/maps';
  static String mapEndpoint(int mapId) => '/maps/$mapId';
  static String mapNpcsEndpoint(int mapId) => '/maps/$mapId/npcs';
  static String mapEnemiesEndpoint(int mapId) => '/maps/$mapId/enemies';

  // Shop endpoints
  static const String shopItemsEndpoint = '/shop/items';
  static const String shopPurchaseEndpoint = '/shop/purchase';

  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration responseTimeout = Duration(seconds: 15);

  /// Get the full URL for an endpoint
  static String getFullUrl(String endpoint) => baseUrl + endpoint;

  /// Check if API is available
  static bool get isLocalhost => baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');
}
