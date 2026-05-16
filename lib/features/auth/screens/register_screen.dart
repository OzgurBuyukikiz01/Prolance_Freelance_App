import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';

enum UserRole { freelancer, client }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  UserRole _selectedRole = UserRole.freelancer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the Terms & Conditions'),
          ),
        );
        return;
      }
      await context.read<AppState>().registerUser(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            isFreelancer: _selectedRole == UserRole.freelancer,
          );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _presentTermsAcceptance() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          clipBehavior: Clip.antiAlias,
          backgroundColor: scheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Terms of Service',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.close, color: scheme.onSurfaceVariant),
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                Expanded(
                  child: _TermsScrollAcceptPanel(
                    onAccept: () => Navigator.of(dialogContext).pop(true),
                    onDecline: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _agreedToTerms = accepted == true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Header
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join thousands of freelancers',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Full Name
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 500),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: Icon(
                        Iconsax.user,
                        color: scheme.onSurfaceVariant,
                        size: 22,
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                            color: scheme.outlineVariant, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Email
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 500),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(
                        Iconsax.sms,
                        color: scheme.onSurfaceVariant,
                        size: 22,
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                            color: scheme.outlineVariant, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Password
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 500),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(
                        Iconsax.lock_1,
                        color: scheme.onSurfaceVariant,
                        size: 22,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                          color: scheme.onSurfaceVariant,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                            color: scheme.outlineVariant, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  duration: const Duration(milliseconds: 500),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: Icon(
                        Iconsax.lock_1,
                        color: scheme.onSurfaceVariant,
                        size: 22,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                          color: scheme.onSurfaceVariant,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword);
                        },
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                            color: scheme.outlineVariant, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Role selection
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          title: "I'm a Freelancer",
                          icon: Iconsax.user,
                          isSelected: _selectedRole == UserRole.freelancer,
                          onTap: () {
                            setState(() => _selectedRole = UserRole.freelancer);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _RoleCard(
                          title: "I'm a Client",
                          icon: Iconsax.briefcase,
                          isSelected: _selectedRole == UserRole.client,
                          onTap: () {
                            setState(() => _selectedRole = UserRole.client);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Terms checkbox
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) async {
                            if (value == true) {
                              await _presentTermsAcceptance();
                            } else {
                              setState(() => _agreedToTerms = false);
                            }
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusXs),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Text(
                                'I agree to the ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: scheme.onSurface,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () async {
                                  await _presentTermsAcceptance();
                                },
                                child: Text(
                                  'Terms of Service',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Create Account button
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 500),
                  child: SizedBox(
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _onCreateAccount,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                          child: Center(
                            child: Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign in link
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsScrollAcceptPanel extends StatefulWidget {
  const _TermsScrollAcceptPanel({
    required this.onAccept,
    required this.onDecline,
  });

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<_TermsScrollAcceptPanel> createState() =>
      _TermsScrollAcceptPanelState();
}

class _TermsScrollAcceptPanelState extends State<_TermsScrollAcceptPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolledToBottom = false;

  static final String _garbageBody = List.filled(
    28,
    'Prolance demo Terms. By using this platform you agree to placeholder obligations '
        'including accurate listings, respectful messaging, and compliance with applicable law. '
        'Fees, escrow, dispute resolution, and account termination are described here with filler '
        'text so the scroll region is realistically long. Lorem ipsum dolor sit amet.',
  ).join('\n\n');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncShortContent());
  }

  void _syncShortContent() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 12 && !_scrolledToBottom) {
      setState(() => _scrolledToBottom = true);
    }
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 32) {
      if (!_scrolledToBottom) setState(() => _scrolledToBottom = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Text(
                _garbageBody,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.55,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _scrolledToBottom
                    ? 'You can accept below.'
                    : 'Scroll to the bottom to enable Accept.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          _scrolledToBottom ? widget.onAccept : null,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : scheme.surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
