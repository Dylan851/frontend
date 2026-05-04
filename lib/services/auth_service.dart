import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}

class AuthMethods {
  final bool exists;
  final bool hasPassword;
  final bool hasGoogle;

  const AuthMethods({
    required this.exists,
    required this.hasPassword,
    required this.hasGoogle,
  });
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _playerNameKey = 'auth_player_name';
  static const _playerIdKey = 'auth_player_id';
  static const _emailKey = 'auth_email';
  static const _coinsKey = 'auth_player_coins';
  static const _gemsKey = 'auth_player_gems';
  static const _levelKey = 'auth_player_level';
  static Timer? _syncDebounce;
  static bool _syncInFlight = false;
  static const String googleOnlyMessage =
      'Esta cuenta inicia sesión con Google. Usa el botón de Google para acceder.';
  static const String genericRecoveryMessage =
      'Si existe una cuenta con este correo, recibirás instrucciones para restablecer tu contraseña.';

  static SupabaseClient? get _supabaseOrNull {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get _isSupabaseConfigured => _supabaseOrNull != null;

  static String get oauthRedirectUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
        return 'http://localhost:8080';
      }
      return 'https://frontend-4iam.onrender.com';
    }
    return 'wildquest://login-callback/';
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
    if (_isSupabaseConfigured) {
      try {
        await _supabaseOrNull!.auth.signOut();
      } catch (_) {
        // no-op
      }
    }
  }

  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final response = await ApiService.login(normalizedEmail, password);
    return _parseAndStoreSession(response, emailHint: normalizedEmail);
  }

  static Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final response = await ApiService.register(normalizedEmail, password, username);
    return _parseAndStoreSession(response, emailHint: normalizedEmail);
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static Future<AuthMethods> checkAuthMethods(String email) async {
    final normalizedEmail = normalizeEmail(email);
    final response = await ApiService.checkAuthMethods(normalizedEmail);
    if (response['success'] != true) {
      throw Exception(_extractError(response));
    }
    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return AuthMethods(
      exists: data['exists'] == true,
      hasPassword: data['has_password'] == true,
      hasGoogle: data['has_google'] == true,
    );
  }

  static Future<AuthSession> loginWithPasswordFlow({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final methods = await checkAuthMethods(normalizedEmail);
    if (methods.exists && !methods.hasPassword && methods.hasGoogle) {
      throw Exception(googleOnlyMessage);
    }
    return login(email: normalizedEmail, password: password);
  }

  static Future<AuthSession> registerWithPasswordFlow({
    required String username,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final methods = await checkAuthMethods(normalizedEmail);
    if (methods.exists) {
      if (methods.hasGoogle && !methods.hasPassword) {
        throw Exception(
          'Este correo ya existe con Google. Inicia con Google para continuar o añadir contraseña.',
        );
      }
      throw Exception('Este correo ya está registrado. Inicia sesión.');
    }
    return register(username: username, email: normalizedEmail, password: password);
  }

  static Future<String> requestPasswordRecovery(String email) async {
    final normalizedEmail = normalizeEmail(email);
    final response = await ApiService.recoverPassword(normalizedEmail);
    if (response['success'] != true) {
      throw Exception(_extractError(response));
    }
    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final message = (data['message'] ?? response['message'] ?? '').toString().trim();
    if (message.isNotEmpty) return message;
    return genericRecoveryMessage;
  }

  static Future<void> startGoogleOAuth() async {
    if (!_isSupabaseConfigured) {
      throw Exception('Supabase no está configurado en la app.');
    }

    final ok = await _supabaseOrNull!.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: oauthRedirectUrl,
    );
    if (!ok) {
      throw Exception('No se pudo iniciar Google OAuth en Supabase.');
    }
  }

  static Future<AuthSession?> completeGoogleOAuthIfPossible() async {
    if (!_isSupabaseConfigured) return null;
    final supabaseSession = _supabaseOrNull!.auth.currentSession;
    final accessToken = supabaseSession?.accessToken;
    if (accessToken == null || accessToken.isEmpty) return null;

    final response = await ApiService.loginWithSupabase(accessToken);
    final emailHint = supabaseSession?.user.email ?? '';
    return _parseAndStoreSession(response, emailHint: emailHint);
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

  static Future<AuthSession> refreshSessionFromServer(AuthSession session) async {
    final response = await ApiService.getCurrentPlayerProfile(token: session.token);
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
          nickname: state.playerName.trim().isEmpty ? null : state.playerName.trim(),
        );

        if (response['success'] == true) {
          final player = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
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
    final rawName = (player['nickname'] ?? player['name'] ?? '').toString().trim();
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

    if (text.contains('correo o contrasena incorrectos') ||
        text.contains('correo o contraseña incorrectos') ||
        text.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (text.contains('inicia sesion con google') ||
        text.contains('inicia sesión con google')) {
      return googleOnlyMessage;
    }
    if (text.contains('ya existe con google')) {
      return 'Este correo ya existe con Google. Inicia con Google para continuar o añadir contraseña.';
    }
    if (text.contains('ya esta registrado') || text.contains('ya está registrado')) {
      return 'Este correo ya está registrado. Inicia sesión.';
    }
    if (text.contains('failed to fetch') ||
        text.contains('xmlhttprequest error') ||
        text.contains('socketexception') ||
        text.contains('connection refused')) {
      return 'No se pudo conectar con el servidor.';
    }
    if (text.contains('supabase') || text.contains('oauth') || text.contains('google')) {
      return 'No se pudo iniciar sesión con Google.';
    }
    if (raw.contains('{') || raw.length > 220) {
      return 'No se pudo completar la autenticación. Inténtalo de nuevo.';
    }
    if (raw.isNotEmpty) return raw;
    return 'No se pudo completar la autenticación.';
  }
}
