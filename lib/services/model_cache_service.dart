// lib/services/model_cache_service.dart
//
// Pre-carga modelos GLB del bundle de assets a un fichero local
// emitiendo progreso real (0.0 → 1.0). Permite al visor 3D mostrar
// una barra de progreso fiable y reutilizar el modelo en cargas
// posteriores (cache).

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ModelCacheService {
  ModelCacheService._();

  static final Map<String, String> _diskCache = {};

  /// Pre-carga `assetPath` (p.ej. 'assets/models/fox.glb') a un fichero local
  /// emitiendo progreso por `onProgress` (entre 0.0 y 1.0).
  /// Devuelve la ruta absoluta del fichero local listo para `flutter_3d_controller`.
  ///
  /// En web no se puede escribir a disco — devuelve el `assetPath` original
  /// y simula el progreso para no bloquear la UI.
  static Future<String> prefetch(
    String assetPath, {
    void Function(double progress)? onProgress,
  }) async {
    if (kIsWeb) {
      // No file system: simulamos un progreso suave para que la UI fluya.
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 60));
        onProgress?.call(i / 10);
      }
      return assetPath;
    }

    final cached = _diskCache[assetPath];
    if (cached != null && await File(cached).exists()) {
      onProgress?.call(1.0);
      return cached;
    }

    onProgress?.call(0.02);

    // 1) Cargamos los bytes desde el bundle (Flutter no expone progreso real
    //    sobre rootBundle.load, así que lo emulamos en pasos cortos antes y
    //    durante la escritura por chunks al disco — eso sí da progreso real).
    final ByteData data = await rootBundle.load(assetPath);
    onProgress?.call(0.30);

    final bytes = data.buffer.asUint8List();
    final tmpDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final outFile = File('${tmpDir.path}/$fileName');
    final sink = outFile.openWrite();

    const chunkSize = 256 * 1024; // 256 KB
    final total = bytes.length;
    int written = 0;

    while (written < total) {
      final end = (written + chunkSize).clamp(0, total);
      sink.add(bytes.sublist(written, end));
      written = end;
      // Mapeamos al rango 0.30 → 0.98 para dejar el último 2 % al loader.
      final p = 0.30 + (written / total) * 0.68;
      onProgress?.call(p);
      // Cedemos el frame para que la UI repinte la barra suavemente.
      await Future.delayed(Duration.zero);
    }

    await sink.flush();
    await sink.close();
    onProgress?.call(1.0);

    final path = outFile.path;
    _diskCache[assetPath] = path;
    return path;
  }

  /// Pre-calienta varios modelos en segundo plano (sin esperar a que terminen).
  /// Útil al entrar en pantallas donde es probable abrir el visor 3D después.
  static void warmUp(Iterable<String> assetPaths) {
    for (final p in assetPaths) {
      // Fire-and-forget; ignoramos errores.
      // ignore: discarded_futures
      prefetch(p).catchError((_) => p);
    }
  }
}
