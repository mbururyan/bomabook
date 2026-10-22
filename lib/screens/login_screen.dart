import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Owner/manager login, with the way in for farm staff below it.
///
/// UI only in this increment: neither button signs anyone in yet.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  // Says plainly that the feature isn't wired up, so nobody watching a demo
  // mistakes it for a broken login
  void _notYet(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what comes in the next step')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // Scrollable so the keyboard can't push the button off a small screen
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: ConstrainedBox(
              // Keeps the form a sensible width on the web dashboard and tablets
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Logo(),
                  const SizedBox(height: 16),
                  const _Wordmark(),
                  const SizedBox(height: 4),
                  const Text(
                    'Your farm, from anywhere',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _username,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _notYet('Logging in'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip:
                            _hidePassword ? 'Show password' : 'Hide password',
                        icon: Icon(_hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => _notYet('Logging in'),
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 24),
                  const _LabelledDivider(label: 'Farm staff'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _notYet('PIN login'),
                    icon: const Icon(Icons.dialpad),
                    label: const Text('Log in with PIN'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No sign-up here: the owner or manager adds staff and '
                    'sets their PIN.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x401F4A33), // brand green at 25%
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            'assets/brand/bomabook_icon_1024.png',
            width: 88,
            height: 88,
            // Decode at 3x display size, not 1024px, to save memory on cheap phones
            cacheWidth: 264,
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    // "Boma" heavy, "Book" regular: the same split as the logo lockup
    return const Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 28,
          color: AppColors.brand,
          letterSpacing: -0.3,
        ),
        children: [
          TextSpan(text: 'Boma', style: TextStyle(fontWeight: FontWeight.w800)),
          TextSpan(text: 'Book', style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _LabelledDivider extends StatelessWidget {
  const _LabelledDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}