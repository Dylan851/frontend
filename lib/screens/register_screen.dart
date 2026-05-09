import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'widgets/auth_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  StreamSubscription<sb.AuthState>? _authSub;
  bool _completingOAuth = false;

  @override
  void initState() {
    super.initState();
    unawaited(_tryCompleteGoogleOAuth());
    try {
      _authSub = sb.Supabase.instance.client.auth.onAuthStateChange.listen((evt) {
        final session = evt.session;
        if (session == null || session.accessToken.isEmpty) return;
        if (_completingOAuth) return;
        unawaited(_tryCompleteGoogleOAuth());
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    await _runAuthAction(() async {
      final session = await AuthService.registerWithPasswordFlow(
        username: _nameCtrl.text.trim(),
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

  Future<void> _tryCompleteGoogleOAuth() async {
    if (_completingOAuth) return;
    _completingOAuth = true;
    try {
      final session = await AuthService.completeGoogleOAuthIfPossible();
      if (session == null) return;
      await _completeSession(session);
    } catch (e) {
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
                'Crear cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 22 * s,
                ),
              ),
              SizedBox(height: 8 * s),
              AuthTextField(
                label: 'Nombre de usuario',
                hint: 'Tu nombre',
                icon: Icons.person_outline,
                controller: _nameCtrl,
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'El nombre es obligatorio.';
                  return null;
                },
              ),
              SizedBox(height: 6 * s),
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
              SizedBox(height: 6 * s),
              AuthTextField(
                label: 'Contraseña',
                hint: '************',
                icon: Icons.lock_outline,
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                onToggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'La contraseña es obligatoria.';
                  return null;
                },
              ),
              SizedBox(height: 6 * s),
              AuthTextField(
                label: 'Confirmar contraseña',
                hint: '************',
                icon: Icons.lock_outline,
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                onToggleVisibility: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Confirma tu contraseña.';
                  if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden.';
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
              SizedBox(height: 8 * s),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTone.leafGreen,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(40 * s),
                  textStyle: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w800),
                ),
                child: _loading
                    ? SizedBox(
                        width: 18 * s,
                        height: 18 * s,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear cuenta'),
              ),
              SizedBox(height: 6 * s),
              OutlinedButton.icon(
                onPressed: _loading ? null : _submitGoogle,
                icon: Text('G',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13 * s)),
                label: Text('Registrarse con Google',
                    style: TextStyle(fontSize: 13 * s)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(38 * s),
                  foregroundColor: GameTone.textCream,
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
                        : () => Navigator.pushReplacementNamed(
                              context,
                              AppRouter.login,
                            ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(fontSize: 12 * s)),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Términos y privacidad pendientes.')),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Términos y privacidad',
                        style: TextStyle(fontSize: 12 * s)),
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
