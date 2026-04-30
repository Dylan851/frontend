// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'data/game_state.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Cargar progreso persistido antes de arrancar la UI.
  await GameState().load();
  GameState.autosaveSyncHook = AuthService.syncGameStateToBackend;
  runApp(const AnimalGoApp());
}

class AnimalGoApp extends StatelessWidget {
  const AnimalGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimalGO!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRouter.loading,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
