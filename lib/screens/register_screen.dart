import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'widgets/auth_ui.dart';
import 'widgets/google_sign_in_web_button.dart';

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
  bool _handlingGoogleAccount = false;
  String? _error;
  StreamSubscription<GoogleSignInAccount?>? _googleSub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _googleSub =
          AuthService.onGoogleUserChanged.listen(_onGoogleAccountChanged);
      AuthService.prepareGoogleSignIn().catchError((Object e) {
        if (!mounted) return;
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      });
    }
  }

  @override
  void dispose() {
    _googleSub?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final session = await AuthService.register(
        username: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      AuthService.applySessionToGameState(session);
      await AuthService.refreshSessionFromServer(session);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.mainMenu,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final session = await AuthService.loginWithGoogle();
      AuthService.applySessionToGameState(session);
      await AuthService.refreshSessionFromServer(session);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.mainMenu,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onGoogleAccountChanged(GoogleSignInAccount? account) async {
    if (!kIsWeb || account == null || _handlingGoogleAccount || !mounted) {
      return;
    }

    _handlingGoogleAccount = true;
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final session = await AuthService.loginWithGoogleAccount(account);
      AuthService.applySessionToGameState(session);
      await AuthService.refreshSessionFromServer(session);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.mainMenu,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _handlingGoogleAccount = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthPanel(
        title: 'ANIMAL GO',
        subtitle: 'Descubre el mundo animal',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                ),
              ),
              const Text(
                'Únete para comenzar tu aventura',
                textAlign: TextAlign.center,
                style: TextStyle(color: GameTone.textGold, fontSize: 14),
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Nombre de usuario',
                hint: 'Tu nombre',
                icon: Icons.person_outline,
                controller: _nameCtrl,
                validator: (v) {
                  if ((v ?? '').trim().isEmpty)
                    return 'El nombre es obligatorio.';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              AuthTextField(
                label: 'Correo electrónico',
                hint: 'tucorreo@ejemplo.com',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'El correo es obligatorio.';
                  final ok =
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                  if (!ok) return 'Introduce un correo válido.';
                  return null;
                },
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
                  if (v != _passwordCtrl.text)
                    return 'Las contraseñas no coinciden.';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFFFB4A9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTone.leafGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear cuenta'),
              ),
              const SizedBox(height: 8),
              if (kIsWeb)
                SizedBox(
                  height: 48,
                  child: IgnorePointer(
                    ignoring: _loading,
                    child: buildGoogleWebSignInButton(),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _loading ? null : _submitGoogle,
                  icon: const Text('G',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  label: const Text('Registrarse con Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: GameTone.textCream,
                    side: const BorderSide(color: GameTone.goldTrim),
                  ),
                ),
              const SizedBox(height: 4),
              const Text(
                'Inicia sesión con tu cuenta de Google',
                textAlign: TextAlign.center,
                style: TextStyle(color: GameTone.textGold, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Términos y privacidad pendientes.')),
                      );
                    },
                    child: const Text('Términos y privacidad'),
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
