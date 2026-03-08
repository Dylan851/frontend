// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const WildQuestApp());
}

class WildQuestApp extends StatelessWidget {
  const WildQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRouter.loading,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
