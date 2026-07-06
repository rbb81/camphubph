import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _submitting = false;
  String? _formError;
  String? _submittedEmail;

  @override
  void dispose() {
    _emailController.dispose();
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
      await AuthService.instance.resetPassword(_emailController.text.trim());
      setState(() => _submittedEmail = _emailController.text.trim());
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
    return AuthScaffold(
      builder: (context) => _submittedEmail != null
          ? InfoPanel(
              title: 'Check your email',
              message:
                  'We sent a password reset link to $_submittedEmail. '
                  'Follow it to choose a new password.',
            )
          : _buildForm(context),
    );
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
            'Forgot password?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "We'll email you a link to reset it.",
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
                  : const Text('Send reset link'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: Text(
                'Back to log in',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.brandDark : AppColors.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
