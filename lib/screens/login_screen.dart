import 'dart:async';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    unawaited(_tryCompleteGoogleOAuth());
  }

  @override
  void dispose() {
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
    try {
      final session = await AuthService.completeGoogleOAuthIfPossible();
      if (session == null) return;
      await _completeSession(session);
    } catch (_) {
      // no-op
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
    return AuthScaffold(
      child: AuthPanel(
        title: 'ANIMAL GO',
        subtitle: '',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Iniciar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GameTone.textCream,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 10),
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
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loading ? null : _submitGoogle,
                icon: const Text('G',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                label: const Text('Continuar con Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: GameTone.textCream,
                  side: const BorderSide(color: GameTone.goldTrim),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: [
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pushNamed(context, AppRouter.register),
                    child: const Text('Crear cuenta'),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _recoverPassword,
                    child: const Text('¿Olvidaste tu contraseña?'),
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
