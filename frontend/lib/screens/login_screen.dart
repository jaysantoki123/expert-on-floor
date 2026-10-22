import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/social_button.dart';
import '../widgets/role_selector.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../screens/learner/learner_dashboard_screen.dart';
import 'expert/expert_dashboard_screen.dart';
import '../models/user_role.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String _role = 'Learner';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _snack('Please fill in all fields', error: true);
      return;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _snack('Please enter a valid email address', error: true);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, password);

    if (success) {
      _snack('Welcome back! 👋');
      if (mounted) {
        if (_role == 'Expert') {
          authProvider.switchRolePreview(UserRole.expert);
        } else {
          authProvider.switchRolePreview(UserRole.learner);
        }
        final isExpert = _role == 'Expert' || authProvider.isExpert;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => isExpert ? const ExpertDashboardScreen() : const LearnerDashboardScreen(),
          ),
          (route) => false,
        );
      }
    } else {
      _snack(authProvider.error ?? 'Login failed', error: true);
    }
  }

  void _quickPreview() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.switchRolePreview(
      _role == 'Expert' ? UserRole.expert : UserRole.learner,
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => _role == 'Expert'
            ? const ExpertDashboardScreen()
            : const LearnerDashboardScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _googleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.googleLogin();

    if (success) {
      _snack('Google Login Successful! 🚀');
      if (mounted) {
        final isExpert = authProvider.isExpert;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => isExpert ? const ExpertDashboardScreen() : const LearnerDashboardScreen(),
          ),
          (route) => false,
        );
      }
    } else if (authProvider.error != null) {
      _snack(authProvider.error!, error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Logo ──
              const _AppLogo(),
              const SizedBox(height: 40),

              // ── Heading ──
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to continue your learning journey',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // ── Email ──
              AppTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailCtrl,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // ── Password ──
              AppTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passCtrl,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 10),

              // ── Forgot Password ──
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ── Role Selector ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _FieldLabel('Login as'),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_role == 'Expert') {
                          _emailCtrl.text = 'learner_1780147696277@test.com';
                          _passCtrl.text = 'password123';
                        } else {
                          _emailCtrl.text = 'learner_1780147982813@test.com';
                          _passCtrl.text = 'password123';
                        }
                      });
                      _snack('Filled $_role demo credentials! 🚀');
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primary),
                    label: Text(
                      'Auto-fill $_role',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RoleSelector(
                selected: _role,
                onChanged: (r) {
                  setState(() {
                    _role = r;
                  });
                },
              ),
              const SizedBox(height: 12),
              // Direct Preview Bypass
              InkWell(
                onTap: _quickPreview,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                  decoration: BoxDecoration(
                    color: _role == 'Expert' ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _role == 'Expert' ? const Color(0xFF93C5FD) : const Color(0xFFA7F3D0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 16,
                        color: _role == 'Expert' ? const Color(0xFF1D4ED8) : const Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Direct Preview as $_role (Skip Login)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _role == 'Expert' ? const Color(0xFF1D4ED8) : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Login Button ──
              AppButton(label: 'Login', loading: isLoading, onPressed: _login),
              const SizedBox(height: 28),

              // ── Divider ──
              const _OrDivider(),
              const SizedBox(height: 22),

              // ── Google ──
              SocialButton(
                label: 'Continue with Google',
                onTap: isLoading ? null : () => _googleLogin(),
              ),
              const SizedBox(height: 32),

              // ── Sign Up ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'ExpertMentor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.line, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.line, thickness: 1)),
      ],
    );
  }
}
