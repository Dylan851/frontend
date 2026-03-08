// lib/router/app_router.dart
import 'package:flutter/material.dart';
import '../screens/loading_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/game_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/minigame_screen.dart';
import '../data/animal_data.dart';

abstract class AppRouter {
  static const String loading    = '/';
  static const String mainMenu   = '/menu';
  static const String game       = '/game';
  static const String collection = '/collection';
  static const String minigame   = '/minigame';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loading:
        return _fade(const LoadingScreen());
      case mainMenu:
        return _fade(const MainMenuScreen());
      case game:
        return _fade(const GameScreen());
      case collection:
        return _fade(const CollectionScreen());
      case minigame:
        final animal = settings.arguments as AnimalData;
        return _slide(MinigameScreen(animal: animal));
      default:
        return _fade(const LoadingScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      );

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      );
}
