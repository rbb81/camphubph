import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _campsiteNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _termsTouched = false;
  bool _submitting = false;
  String? _formError;
  String? _submittedEmail;
  UserRole _role = UserRole.camper;

  @override
  void dispose() {
    _fullNameController.dispose();
    _campsiteNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _termsTouched = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !_acceptedTerms) return;

    setState(() {
      _submitting = true;
      _formError = null;
    });

    try {
      await AuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        role: _role,
        campsiteName: _role == UserRole.campOwner
            ? _campsiteNameController.text.trim()
            : null,
      );
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
                  'We sent a confirmation link to $_submittedEmail. Confirm '
                  'your address to finish creating your account.',
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
            'Create your account',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Start planning your next camping trip.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (_formError != null) ...[
            FormErrorBanner(_formError!),
            const SizedBox(height: 16),
          ],
          fieldLabel(context, 'I am a'),
          SegmentedButton<UserRole>(
            key: const Key('accountTypeField'),
            segments: const [
              ButtonSegment(
                value: UserRole.camper,
                label: Text('Camper'),
                icon: Icon(Icons.hiking),
              ),
              ButtonSegment(
                value: UserRole.campOwner,
                label: Text('Camp Owner'),
                icon: Icon(Icons.holiday_village),
              ),
            ],
            selected: {_role},
            onSelectionChanged: (selection) =>
                setState(() => _role = selection.first),
          ),
          if (_role == UserRole.campOwner) ...[
            const SizedBox(height: 16),
            fieldLabel(context, 'Campsite name'),
            TextFormField(
              key: const Key('campsiteNameField'),
              controller: _campsiteNameController,
              decoration: const InputDecoration(hintText: 'Daraitan Basecamp'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter your campsite name.'
                  : null,
            ),
          ],
          const SizedBox(height: 16),
          fieldLabel(context, _role == UserRole.campOwner ? 'Host name' : 'Full name'),
          TextFormField(
            key: const Key('fullNameField'),
            controller: _fullNameController,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(hintText: 'Jasmine Reyes'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? _role == UserRole.campOwner
                    ? 'Enter the host name.'
                    : 'Enter your full name.'
                : null,
          ),
          const SizedBox(height: 16),
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
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(hintText: 'At least 8 characters'),
            validator: (value) => (value == null || value.length < 8)
                ? 'Use at least 8 characters.'
                : null,
          ),
          const SizedBox(height: 16),
          fieldLabel(context, 'Confirm password'),
          TextFormField(
            key: const Key('confirmPasswordField'),
            controller: _confirmPasswordController,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(hintText: 'Re-enter your password'),
            validator: (value) => (value != _passwordController.text)
                ? "Passwords don't match."
                : null,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() {
              _acceptedTerms = !_acceptedTerms;
              _termsTouched = true;
            }),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  key: const Key('termsCheckbox'),
                  value: _acceptedTerms,
                  onChanged: (value) => setState(() {
                    _acceptedTerms = value ?? false;
                    _termsTouched = true;
                  }),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      'I agree to the terms of service and privacy policy.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_termsTouched && !_acceptedTerms)
            const Padding(
              padding: EdgeInsets.only(left: 44, top: 2),
              child: Text(
                'You need to accept the terms to continue.',
                style: TextStyle(color: AppColors.danger, fontSize: 12),
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
                  : const Text('Create account'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: Text(
                    'Log in',
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
