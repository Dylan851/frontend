/// API Configuration for WildQuest Game
///
/// This file contains the configuration for connecting to the backend API.
/// You can change the baseUrl here based on your environment.

class ApiConfig {
  // Set with --dart-define=API_BASE_URL=https://your-backend.onrender.com
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static String get baseUrl => _rawBaseUrl.endsWith('/')
      ? _rawBaseUrl.substring(0, _rawBaseUrl.length - 1)
      : _rawBaseUrl;

  // API Endpoints
  static const String healthCheck = '/health';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  // Player endpoints
  static const String playerProfileEndpoint = '/player/profile';
  static const String playerLocationEndpoint = '/player/location';
  static const String playerInventoryEndpoint = '/player/inventory';

  // Animal endpoints
  static const String animalsEndpoint = '/animals';
  static const String nearbyAnimalsEndpoint = '/animals/nearby';
  static const String captureAnimalEndpoint = '/animals/capture';

  // Map endpoints
  static const String mapsEndpoint = '/maps';
  static const String unlockedMapsEndpoint = '/maps/unlocked';
  static const String unlockMapEndpoint = '/maps/unlock';
  static String mapNpcsEndpoint(int mapId) => '/npc/map/$mapId';
  static String mapEnemiesEndpoint(int mapId) => '/enemies/map/$mapId';
  static String enemyDefeatEndpoint(int enemyId) => '/enemies/$enemyId/defeat';

  // Shop endpoints
  static const String shopItemsEndpoint = '/shop';
  static const String shopPurchaseEndpoint = '/shop/buy';

  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration responseTimeout = Duration(seconds: 15);

  /// Get the full URL for an endpoint
  static String getFullUrl(String endpoint) => baseUrl + endpoint;

  /// Check if API is available
  static bool get isLocalhost => baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');
}
