import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'widgets/auth_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  String? _error;
  StreamSubscription<sb.AuthState>? _authSub;
  bool _completingOAuth = false;

  @override
  void initState() {
    super.initState();
    unawaited(_tryCompleteGoogleOAuth());
    // Escucha el callback de Supabase (deep link wildquest://login-callback/).
    // Sin esto, tras el OAuth la sesión llega a Supabase pero la pantalla
    // se queda quieta y el usuario no entra en la app.
    try {
      _authSub = sb.Supabase.instance.client.auth.onAuthStateChange.listen((evt) {
        final session = evt.session;
        if (session == null || session.accessToken.isEmpty) return;
        if (_completingOAuth) return;
        unawaited(_tryCompleteGoogleOAuth());
      });
    } catch (_) {
      // Supabase no inicializado: ignoramos.
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    await _runAuthAction(() async {
      final session = await AuthService.loginWithPasswordFlow(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      await _completeSession(session);
    });
  }

  Future<void> _submitGoogle() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    await _runAuthAction(AuthService.startGoogleOAuth);
  }

  Future<void> _recoverPassword() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    final email = await _askRecoveryEmail();
    if (email == null || email.isEmpty) return;
    await _runAuthAction(() async {
      final message = await AuthService.requestPasswordRecovery(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Future<void> _tryCompleteGoogleOAuth() async {
    if (_completingOAuth) return;
    _completingOAuth = true;
    try {
      final session = await AuthService.completeGoogleOAuthIfPossible();
      if (session == null) return;
      await _completeSession(session);
    } catch (e) {
      // Mostramos el error real al usuario para no quedarnos en limbo.
      if (mounted) {
        setState(() =>
            _error = e.toString().replaceFirst('Exception: ', '').trim());
      }
    } finally {
      _completingOAuth = false;
    }
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _completeSession(AuthSession session) async {
    AuthService.applySessionToGameState(session);
    await AuthService.refreshSessionFromServer(session);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.mainMenu,
      (route) => false,
    );
  }

  Future<String?> _askRecoveryEmail() async {
    final controller = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              validator: (value) {
                final email = AuthService.normalizeEmail(value ?? '');
                if (email.isEmpty) return 'El correo es obligatorio.';
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                if (!ok) return 'Introduce un correo válido.';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(
                  AuthService.normalizeEmail(controller.text),
                );
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final s = (size.shortestSide / (isLandscape ? 700 : 600)).clamp(0.62, 1.05);
    return AuthScaffold(
      child: AuthPanel(
        title: 'ANIMAL GO',
        subtitle: '',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Iniciar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 22 * s,
                ),
              ),
              SizedBox(height: 10 * s),
              AuthTextField(
                label: 'Correo electrónico',
                hint: 'tucorreo@ejemplo.com',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = AuthService.normalizeEmail(v ?? '');
                  if (value.isEmpty) return 'El correo es obligatorio.';
                  final ok =
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                  if (!ok) return 'Introduce un correo válido.';
                  return null;
                },
              ),
              SizedBox(height: 8 * s),
              AuthTextField(
                label: 'Contraseña',
                hint: '************',
                icon: Icons.lock_outline,
                controller: _passwordCtrl,
                obscureText: _obscure,
                onToggleVisibility: () => setState(() => _obscure = !_obscure),
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'La contraseña es obligatoria.';
                  return null;
                },
              ),
              if (_error != null) ...[
                SizedBox(height: 6 * s),
                Text(
                  _error!,
                  style: TextStyle(
                    color: const Color(0xFFFFB4A9),
                    fontWeight: FontWeight.w700,
                    fontSize: 12 * s,
                  ),
                ),
              ],
              SizedBox(height: 10 * s),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTone.leafGreen,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(48 * s),
                  textStyle: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w800),
                ),
                child: _loading
                    ? SizedBox(
                        width: 18 * s,
                        height: 18 * s,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entrar'),
              ),
              SizedBox(height: 10 * s),
              OutlinedButton.icon(
                onPressed: _loading ? null : _submitGoogle,
                icon: Text('G',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * s)),
                label: Text('Continuar con Google',
                    style: TextStyle(fontSize: 16 * s)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(54 * s),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: GameTone.goldTrim),
                ),
              ),
              SizedBox(height: 4 * s),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                children: [
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pushNamed(context, AppRouter.register),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Crear cuenta', style: TextStyle(fontSize: 15 * s)),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _recoverPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('¿Olvidaste tu contraseña?',
                        style: TextStyle(fontSize: 15 * s)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
