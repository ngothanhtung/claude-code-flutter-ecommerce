import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_screen.dart';
import '../data/auth_repository.dart';
import 'auth_providers.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  static const routeName = '/register';
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
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
          .register(name.text, email.text, password.text);
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
    prefix: 'register',
    title: 'Create your account',
    subtitle: 'A minute now, easier everyday shopping later.',
    formKey: formKey,
    primaryLabel: 'Register',
    secondaryLabel: 'Back to login',
    busy: busy,
    onPrimary: submit,
    onGoogle: signInWithGoogle,
    onSecondary: () => Navigator.pop(context),
    children: [
      AuthField(
        fieldKey: 'name-field',
        label: 'Full name',
        icon: Icons.person_outline,
        controller: name,
        validator: (value) =>
            (value?.trim().length ?? 0) < 2 ? 'Enter a valid full name' : null,
      ),
      const SizedBox(height: 14),
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
