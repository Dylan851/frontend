import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_state.dart';
import 'api_service.dart';

class AuthSession {
  final String token;
  final String? playerName;
  final String? playerId;
  final String? email;
  final int? coins;
  final int? gems;
  final int? level;

  const AuthSession({
    required this.token,
    this.playerName,
    this.playerId,
    this.email,
    this.coins,
    this.gems,
    this.level,
  });

  AuthSession copyWith({
    String? token,
    String? playerName,
    String? playerId,
    String? email,
    int? coins,
    int? gems,
    int? level,
  }) {
    return AuthSession(
      token: token ?? this.token,
      playerName: playerName ?? this.playerName,
      playerId: playerId ?? this.playerId,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      level: level ?? this.level,
    );
  }
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _playerNameKey = 'auth_player_name';
  static const _playerIdKey = 'auth_player_id';
  static const _emailKey = 'auth_email';
  static const _coinsKey = 'auth_player_coins';
  static const _gemsKey = 'auth_player_gems';
  static const _levelKey = 'auth_player_level';
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static GoogleSignIn? _googleSignIn;
  static Future<void>? _prepareFuture;
  static Timer? _syncDebounce;
  static bool _syncInFlight = false;

  static String get googleWebClientId => _googleWebClientId.trim();

  static bool get isGoogleWebConfigured =>
      !kIsWeb || googleWebClientId.isNotEmpty;

  static GoogleSignIn get _googleClient {
    return _googleSignIn ??= GoogleSignIn(
      scopes: const ['email', 'profile', 'openid'],
      clientId:
          kIsWeb && googleWebClientId.isNotEmpty ? googleWebClientId : null,
    );
  }

  static Stream<GoogleSignInAccount?> get onGoogleUserChanged =>
      _googleClient.onCurrentUserChanged;

  static Future<void> prepareGoogleSignIn() {
    return _prepareFuture ??= _prepareGoogleSignInInternal();
  }

  static Future<void> _prepareGoogleSignInInternal() async {
    if (kIsWeb && !isGoogleWebConfigured) {
      throw Exception(
        'Google no está configurado correctamente. Falta GOOGLE_WEB_CLIENT_ID.',
      );
    }

    try {
      await _googleClient.signInSilently(suppressErrors: true);
    } catch (_) {
      // En web puede no existir sesión previa.
    }
  }

  static Future<AuthSession?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;
    return AuthSession(
      token: token,
      playerName: prefs.getString(_playerNameKey),
      playerId: prefs.getString(_playerIdKey),
      email: prefs.getString(_emailKey),
      coins: prefs.getInt(_coinsKey),
      gems: prefs.getInt(_gemsKey),
      level: prefs.getInt(_levelKey),
    );
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_playerNameKey);
    await prefs.remove(_playerIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_coinsKey);
    await prefs.remove(_gemsKey);
    await prefs.remove(_levelKey);
    if (!kIsWeb) {
      try {
        await _googleClient.signOut();
      } catch (_) {
        // no-op
      }
    }
  }

  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.login(email, password);
    return _parseAndStoreSession(response, emailHint: email);
  }

  static Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.register(email, password, username);
    return _parseAndStoreSession(response, emailHint: email);
  }

  static Future<AuthSession> loginWithGoogle() async {
    if (kIsWeb) {
      throw Exception('En Web usa el botón oficial de Google para continuar.');
    }

    final account = await _googleClient.signIn();
    if (account == null) {
      throw Exception('Inicio con Google cancelado.');
    }
    return loginWithGoogleAccount(account);
  }

  static Future<AuthSession> loginWithGoogleAccount(
    GoogleSignInAccount account,
  ) async {
    if (kIsWeb && !isGoogleWebConfigured) {
      throw Exception(
        'Google no está configurado correctamente. Revisa GOOGLE_WEB_CLIENT_ID.',
      );
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google no devolvió id_token. Verifica OAuth Web y origen autorizado http://localhost:8080.',
      );
    }

    final response = await ApiService.loginWithGoogle(idToken);
    return _parseAndStoreSession(response, emailHint: account.email);
  }

  static void applySessionToGameState(AuthSession session) {
    final gs = GameState();
    final parsedName = _normalizedName(
      preferredName: session.playerName,
      emailHint: session.email,
    );
    if (parsedName != null && parsedName.isNotEmpty) {
      gs.playerName = parsedName;
    }
    if (session.coins != null) gs.coins = session.coins!;
    if (session.gems != null) gs.gems = session.gems!;
    if (session.level != null) gs.level = session.level!;
    gs.autosave();
  }

  static Future<AuthSession> refreshSessionFromServer(
      AuthSession session) async {
    final response =
        await ApiService.getCurrentPlayerProfile(token: session.token);
    if (response['success'] != true) {
      return session;
    }

    final player = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final refreshed = _sessionFromPlayerData(
      token: session.token,
      emailHint: session.email,
      player: player,
    );
    await _saveSession(refreshed);
    applySessionToGameState(refreshed);
    return refreshed;
  }

  static Future<void> syncGameStateToBackend(GameState state) async {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), () async {
      if (_syncInFlight || !state.cloudSave) return;
      _syncInFlight = true;
      try {
        final session = await restoreSession();
        if (session == null || session.token.isEmpty) return;

        final response = await ApiService.updateCurrentPlayerProfile(
          token: session.token,
          nickname:
              state.playerName.trim().isEmpty ? null : state.playerName.trim(),
          coins: state.coins,
          gems: state.gems,
        );

        if (response['success'] == true) {
          final player =
              (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
          final updated = _sessionFromPlayerData(
            token: session.token,
            emailHint: session.email,
            player: player,
          );
          await _saveSession(updated);
        }
      } catch (_) {
        // No interrumpir juego por fallos de red.
      } finally {
        _syncInFlight = false;
      }
    });
  }

  static Future<AuthSession> _parseAndStoreSession(
    Map<String, dynamic> response, {
    required String emailHint,
  }) async {
    final ok = response['success'] == true;
    if (!ok) {
      throw Exception(_extractError(response));
    }

    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final token = (data['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('No se recibió token de sesión.');
    }

    final player = (data['player'] as Map?)?.cast<String, dynamic>() ?? {};
    final session = _sessionFromPlayerData(
      token: token,
      emailHint: emailHint,
      player: player,
    );
    await _saveSession(session);
    return session;
  }

  static AuthSession _sessionFromPlayerData({
    required String token,
    required String? emailHint,
    required Map<String, dynamic> player,
  }) {
    final rawName =
        (player['nickname'] ?? player['name'] ?? '').toString().trim();
    final finalName = _normalizedName(
      preferredName: rawName,
      emailHint: emailHint,
    );
    final playerId = (player['id'] ?? '').toString().trim();

    return AuthSession(
      token: token,
      playerName: finalName,
      playerId: playerId.isEmpty ? null : playerId,
      email: emailHint,
      coins: _asInt(player['coins']),
      gems: _asInt(player['gems']),
      level: _asInt(player['level']),
    );
  }

  static String? _normalizedName({
    required String? preferredName,
    required String? emailHint,
  }) {
    final candidate = (preferredName ?? '').trim();
    if (candidate.isNotEmpty) return candidate;
    final email = (emailHint ?? '').trim();
    if (email.contains('@')) {
      return email.split('@').first.trim();
    }
    return email.isEmpty ? null : email;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static Future<void> _saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    if (session.playerName != null) {
      await prefs.setString(_playerNameKey, session.playerName!);
    }
    if (session.playerId != null) {
      await prefs.setString(_playerIdKey, session.playerId!);
    }
    if (session.email != null) {
      await prefs.setString(_emailKey, session.email!);
    }
    if (session.coins != null) {
      await prefs.setInt(_coinsKey, session.coins!);
    }
    if (session.gems != null) {
      await prefs.setInt(_gemsKey, session.gems!);
    }
    if (session.level != null) {
      await prefs.setInt(_levelKey, session.level!);
    }
  }

  static String _extractError(Map<String, dynamic> response) {
    final raw = [
      response['detail'],
      response['error'],
      response['message'],
    ].whereType<String>().join(' | ');
    final text = raw.toLowerCase();

    if (text.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (text.contains('failed to fetch') ||
        text.contains('xmlhttprequest error') ||
        text.contains('socketexception') ||
        text.contains('connection refused')) {
      return 'No se pudo conectar con el servidor.';
    }
    if (text.contains('people api') ||
        text.contains('service_disabled') ||
        text.contains('google oauth is not configured')) {
      return 'Google no está configurado correctamente.';
    }
    if (text.contains('invalid google token') ||
        text.contains('token missing email') ||
        text.contains('issuer') ||
        text.contains('google') ||
        text.contains('id_token')) {
      return 'No se pudo iniciar sesión con Google.';
    }
    if (raw.contains('{') || raw.length > 220) {
      return 'No se pudo completar la autenticación. Inténtalo de nuevo.';
    }
    if (raw.isNotEmpty) return raw;
    return 'No se pudo completar la autenticación.';
  }
}
