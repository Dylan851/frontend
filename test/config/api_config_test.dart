// test/config/api_config_test.dart
//
// Tests para `ApiConfig` — punto único de configuración del backend.

import 'package:flutter_test/flutter_test.dart';
import 'package:animalgo_game/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('baseUrl no está vacío', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
    });

    test('endpoints fijos tienen el prefijo correcto', () {
      expect(ApiConfig.healthCheck, '/health');
      expect(ApiConfig.loginEndpoint, '/auth/login');
      expect(ApiConfig.registerEndpoint, '/auth/register');
      expect(ApiConfig.logoutEndpoint, '/auth/logout');
      expect(ApiConfig.playersEndpoint, '/players');
    });

    test('playerEndpoint compone correctamente la URL', () {
      expect(ApiConfig.playerEndpoint('abc-123'), '/players/abc-123');
    });

    test('animalEndpoint y captureAnimalEndpoint usan el id numérico', () {
      expect(ApiConfig.animalEndpoint(7), '/animals/7');
      expect(ApiConfig.captureAnimalEndpoint(7), '/animals/7/capture');
    });

    test('mapEndpoint y sub-endpoints', () {
      expect(ApiConfig.mapEndpoint(2), '/maps/2');
      expect(ApiConfig.mapNpcsEndpoint(2), '/maps/2/npcs');
      expect(ApiConfig.mapEnemiesEndpoint(2), '/maps/2/enemies');
    });

    test('getFullUrl concatena baseUrl + endpoint', () {
      expect(ApiConfig.getFullUrl('/health'),
          '${ApiConfig.baseUrl}/health');
    });

    test('isLocalhost detecta entornos de desarrollo', () {
      // Con la URL por defecto (localhost) o variantes 127.0.0.1.
      if (ApiConfig.baseUrl.contains('localhost') ||
          ApiConfig.baseUrl.contains('127.0.0.1')) {
        expect(ApiConfig.isLocalhost, isTrue);
      } else {
        expect(ApiConfig.isLocalhost, isFalse);
      }
    });

    test('los timeouts son positivos', () {
      expect(ApiConfig.connectionTimeout.inSeconds, greaterThan(0));
      expect(ApiConfig.responseTimeout.inSeconds, greaterThan(0));
    });
  });
}
