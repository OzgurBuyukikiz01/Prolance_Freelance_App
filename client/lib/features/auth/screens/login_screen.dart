import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgAnim.dispose();
    super.dispose();
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    final ok = await context.read<AppState>().loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!ok) {
      ProlanceMessenger.error(
        context,
        context.read<AppState>().t(
          'Could not start Google sign-in.',
          'Google ile giriş başlatılamadı.',
        ),
      );
    }
  }

  Future<void> _onAppleSignIn() async {
    setState(() => _isLoading = true);
    final ok = await context.read<AppState>().loginWithApple();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!ok) {
      ProlanceMessenger.error(
        context,
        context.read<AppState>().t(
          'Could not start Apple sign-in.',
          'Apple ile giriş başlatılamadı.',
        ),
      );
    }
  }

  Future<void> _onSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    final ok = await context.read<AppState>().login(
      username: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      context.go('/home');
    } else {
      ProlanceMessenger.error(
        context,
        context.read<AppState>().t(
          'Incorrect email or password.',
          'E-posta veya şifre hatalı.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final supportsAppleOAuth = AuthService.instance.supportsAppleOAuth;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient gradient bg
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _bgAnim.value * 0.5, -1.0),
                  end: Alignment(1.0 - _bgAnim.value * 0.5, 1.0),
                  colors: isDark
                      ? const [
                          Color(0xFF1A1625),
                          Color(0xFF0F0E1A),
                          Color(0xFF1A1625),
                        ]
                      : const [
                          Color(0xFFF0EEFF),
                          Color(0xFFF8F7FF),
                          Color(0xFFEEF6FF),
                        ],
                ),
              ),
            ),
          ),

          // Top decorative orb
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    // Logo + greeting
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'P',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .scale(
                              begin: const Offset(0.5, 0.5),
                              duration: 500.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(),

                        const SizedBox(height: 28),

                        Text(
                              'Welcome\nback 👋',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 500.ms)
                            .slideX(begin: -0.1, end: 0),

                        const SizedBox(height: 10),

                        Text(
                          'Sign in to your Prolance account',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: scheme.onSurfaceVariant,
                          ),
                        ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Email
                    _AnimatedField(
                      controller: _emailController,
                      hint: 'Your email address',
                      icon: Iconsax.sms,
                      keyboardType: TextInputType.emailAddress,
                      delay: 200,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Email is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Password
                    _AnimatedField(
                      controller: _passwordController,
                      hint: 'Your password',
                      icon: Iconsax.lock_1,
                      obscure: _obscurePassword,
                      delay: 280,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : null,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                        ),
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Sign in button
                    _GradientButton(
                      label: 'Sign in',
                      isLoading: _isLoading,
                      onTap: _onSignIn,
                      delay: 400,
                    ),

                    const SizedBox(height: 28),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'or',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                      ],
                    ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                    const SizedBox(height: 20),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onTap: _isLoading ? () {} : _onGoogleSignIn,
                          ),
                        ),
                        if (supportsAppleOAuth) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.apple,
                              label: 'Apple',
                              onTap: _isLoading ? () {} : _onAppleSignIn,
                            ),
                          ),
                        ],
                      ],
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                    const SizedBox(height: 36),

                    // Sign up
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Don't have an account?  ",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared components
// ---------------------------------------------------------------------------

class _AnimatedField extends StatefulWidget {
  const _AnimatedField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.delay,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
    required this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int delay;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?) validator;

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: _focused ? AppColors.primary : scheme.outlineVariant,
              width: _focused ? 2 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscure,
            validator: widget.validator,
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _focused ? AppColors.primary : scheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: widget.onToggleObscure != null
                  ? IconButton(
                      icon: Icon(
                        widget.obscure ? Iconsax.eye_slash : Iconsax.eye,
                        color: scheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: widget.onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: GoogleFonts.poppins(fontSize: 11),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: widget.delay),
          duration: 400.ms,
        )
        .slideY(begin: 0.2, end: 0);
  }
}

// ---------------------------------------------------------------------------
class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    required this.delay,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  final int delay;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressAnim;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _pressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) {
            setState(() => _pressing = true);
            _pressAnim.forward();
          },
          onTapUp: (_) {
            setState(() => _pressing = false);
            _pressAnim.reverse();
            widget.onTap();
          },
          onTapCancel: () {
            setState(() => _pressing = false);
            _pressAnim.reverse();
          },
          child: AnimatedScale(
            scale: _pressing ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: _pressing ? 0.2 : 0.4,
                    ),
                    blurRadius: _pressing ? 6 : 16,
                    offset: Offset(0, _pressing ? 2 : 8),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.label,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: widget.delay),
          duration: 500.ms,
        )
        .slideY(begin: 0.2, end: 0);
  }
}

// ---------------------------------------------------------------------------
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: scheme.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
