import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() {
      _submitting = true;
      _formError = null;
    });

    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } on AuthException catch (e) {
      setState(() => _formError = e.message);
    } catch (_) {
      setState(
        () => _formError = 'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(builder: (context) => _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Log in',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick up where you left off.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (_formError != null) ...[
            FormErrorBanner(_formError!),
            const SizedBox(height: 16),
          ],
          fieldLabel(context, 'Email'),
          TextFormField(
            key: const Key('emailField'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(hintText: 'name@example.com'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email address.';
              }
              final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
              if (!emailPattern.hasMatch(value.trim())) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          fieldLabel(context, 'Password'),
          TextFormField(
            key: const Key('passwordField'),
            controller: _passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(hintText: 'Your password'),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Enter your password.'
                : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () =>
                  Navigator.of(context).pushNamed('/forgot-password'),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.brandDark : AppColors.brand,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Log in'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                InkWell(
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed('/register'),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.brandDark : AppColors.brand,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
