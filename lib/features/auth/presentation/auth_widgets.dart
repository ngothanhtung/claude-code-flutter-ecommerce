import 'package:flutter/material.dart';

typedef FieldValidator = String? Function(String? value);

class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.prefix,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    required this.formKey,
    this.onGoogle,
    this.busy = false,
  });
  final String prefix;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback onSecondary;
  final GlobalKey<FormState> formKey;
  final VoidCallback? onGoogle;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.local_mall_rounded,
                        color: colors.onPrimary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'EVERYDAY STORE',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 22),
                            ...children,
                            const SizedBox(height: 18),
                            FilledButton.tonal(
                              key: ValueKey('$prefix-primary-button'),
                              onPressed: busy ? null : onPrimary,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                              ),
                              child: busy
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(primaryLabel),
                            ),
                            if (onGoogle != null) ...[
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: busy ? null : onGoogle,
                                child: const Text('Continue with provider'),
                              ),
                            ],
                            const SizedBox(height: 7),
                            TextButton(
                              key: ValueKey('$prefix-secondary-button'),
                              onPressed: busy ? null : onSecondary,
                              child: Text(secondaryLabel),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.icon,
    required this.controller,
    this.validator,
    this.obscure = false,
    this.keyboardType,
  });
  final String fieldKey;
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FieldValidator? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => TextFormField(
    key: ValueKey(fieldKey),
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    obscureText: obscure,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );
}

String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Email is required';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  final text = value ?? '';
  if (text.isEmpty) return 'Password is required';
  if (text.length < 8) return 'Use at least 8 characters';
  return null;
}
