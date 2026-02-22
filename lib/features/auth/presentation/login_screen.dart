import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome Back',
      subtitle: 'Log in to your ChessMate account',
      child: _LoginForm(),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create Account',
      subtitle: 'Join millions of chess players',
      child: _RegisterForm(),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Reset Password',
      subtitle: 'We\'ll send a reset link to your email',
      child: _ForgotForm(),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppDimens.paddingXl),

              // Logo
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: const Center(
                    child: Text(
                      '♔',
                      style: TextStyle(fontSize: 36, color: AppColors.gold),
                    ),
                  ),
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: AppDimens.paddingXl),

              ShaderMask(
                shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(color: Colors.white),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppDimens.paddingSm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppDimens.paddingXl),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _EmailField(),
        const SizedBox(height: AppDimens.paddingMd),
        const _PasswordField(label: 'Password'),
        const SizedBox(height: AppDimens.paddingSm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/auth/forgot-password'),
            child: const Text(
              AppStrings.forgotPassword,
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingMd),
        ChessGradientButton(label: 'LOG IN', onTap: () => context.go('/lobby')),
        const SizedBox(height: AppDimens.paddingLg),
        const GoldDivider(),
        const SizedBox(height: AppDimens.paddingLg),
        _GoogleButton(),
        const SizedBox(height: AppDimens.paddingXl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            GestureDetector(
              onTap: () => context.pushReplacement('/auth/register'),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TextField(label: 'Username', icon: Icons.person_rounded),
        const SizedBox(height: AppDimens.paddingMd),
        const _EmailField(),
        const SizedBox(height: AppDimens.paddingMd),
        const _PasswordField(label: 'Password'),
        const SizedBox(height: AppDimens.paddingMd),
        const _PasswordField(label: 'Confirm Password'),
        const SizedBox(height: AppDimens.paddingLg),
        ChessGradientButton(
          label: 'CREATE ACCOUNT',
          onTap: () => context.go('/lobby'),
        ),
        const SizedBox(height: AppDimens.paddingLg),
        const GoldDivider(),
        const SizedBox(height: AppDimens.paddingLg),
        _GoogleButton(),
        const SizedBox(height: AppDimens.paddingXl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            GestureDetector(
              onTap: () => context.pushReplacement('/auth/login'),
              child: const Text(
                'Log In',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ForgotForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _EmailField(),
        const SizedBox(height: AppDimens.paddingLg),
        ChessGradientButton(
          label: 'SEND RESET LINK',
          icon: Icons.email_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reset link sent to your email!')),
            );
            context.pop();
          },
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();
  @override
  Widget build(BuildContext context) {
    return const _TextField(
      label: 'Email',
      icon: Icons.email_rounded,
      keyboardType: TextInputType.emailAddress,
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String label;
  const _PasswordField({required this.label});
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textMuted),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _TextField({
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'G',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
