import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../main_screen.dart';
import 'auth_providers.dart';
import 'auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => busy = true);
    try {
      await ref
          .read(currentUserProvider.notifier)
          .login(email.text, password.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainScreen.routeName,
        (_) => false,
      );
    } on AuthFailure catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => busy = true);
    try {
      await ref.read(currentUserProvider.notifier).loginWithGoogle();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainScreen.routeName,
        (_) => false,
      );
    } on AuthCancelledException {
      // Closing the account picker is not an error the user needs to dismiss.
    } on AuthFailure catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => AuthPage(
    prefix: 'login',
    title: 'Welcome back',
    subtitle: 'Sign in to continue where you left off.',
    formKey: formKey,
    primaryLabel: 'Login',
    secondaryLabel: 'Create account',
    busy: busy,
    onPrimary: submit,
    onGoogle: signInWithGoogle,
    onSecondary: () => Navigator.pushNamed(context, RegisterScreen.routeName),
    children: [
      AuthField(
        fieldKey: 'email-field',
        label: 'Email address',
        icon: Icons.alternate_email,
        controller: email,
        validator: validateEmail,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthField(
        fieldKey: 'password-field',
        label: 'Password',
        icon: Icons.lock_outline,
        controller: password,
        validator: validatePassword,
        obscure: true,
      ),
    ],
  );
}
