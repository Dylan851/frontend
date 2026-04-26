// lib/router/app_router.dart
import 'package:flutter/material.dart';
import '../screens/loading_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/game_screen.dart';
import '../screens/map_loading_screen.dart';
import '../screens/character_select_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/minigame_screen.dart';
import '../screens/map_select_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/missions_screen.dart';
import '../data/animal_data.dart';

abstract class AppRouter {
  static const String loading         = '/';
  static const String mainMenu        = '/menu';
  static const String characterSelect = '/character-select';
  static const String game            = '/game';
  static const String gameDirect      = '/game-direct';
  static const String collection      = '/collection';
  static const String minigame        = '/minigame';
  static const String mapSelect       = '/map-select';
  static const String shop            = '/shop';
  static const String inventory       = '/inventory';
  static const String profile         = '/profile';
  static const String settings        = '/settings';
  static const String missions        = '/missions';

  static Route<dynamic> generateRoute(RouteSettings s) {
    switch (s.name) {
      case loading:         return _fade(const LoadingScreen());
      case mainMenu:        return _fade(const MainMenuScreen());
      case characterSelect: return _slide(const CharacterSelectScreen());
      case game:            return _fade(const MapLoadingScreen());
      case gameDirect:      return _fade(const GameScreen());
      case collection: return _fade(const CollectionScreen());
      case mapSelect:  return _slide(const MapSelectScreen());
      case shop:       return _slide(const ShopScreen());
      case inventory:  return _slide(const InventoryScreen());
      case profile:    return _slide(const ProfileScreen());
      case settings:   return _slide(const SettingsScreen());
      case missions:   return _slide(const MissionsScreen());
      case minigame:
        final animal = s.arguments as AnimalData;
        return _slide(MinigameScreen(animal: animal));
      default:         return _fade(const LoadingScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 380),
  );
}
