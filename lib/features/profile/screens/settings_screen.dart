import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/theme_preference.dart';

import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = context.read<AppState>().languageCode;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AppState>().logout();
                if (!mounted) return;
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          app.t('Settings', 'Ayarlar'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingMd),

            // Account section
            _buildSectionHeader(context, app.t('Account', 'Hesap')),
            _buildSettingsCard(context,
              children: [
                _buildSettingsTile(
                  icon: Iconsax.user_edit,
                  title: app.t('Edit Profile', 'Profili Duzenle'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  icon: Iconsax.lock_1,
                  title: app.t('Change Password', 'Sifre Degistir'),
                  onTap: _openChangePassword,
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  icon: Iconsax.wallet_3,
                  title: app.t('Payment Methods', 'Odeme Yontemleri'),
                  onTap: _openPaymentMethod,
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  icon: Iconsax.verify,
                  title: app.t('Verification', 'Dogrulama'),
                  onTap: _openVerification,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Preferences section
            _buildSectionHeader(context, app.t('Preferences', 'Tercihler')),
            _buildSettingsCard(context,
              children: [
                _buildSettingsTile(
                  icon: Iconsax.global,
                  title: app.t('Language', 'Dil'),
                  trailing: Text(
                    _selectedLanguage == 'tr' ? 'Turkce' : 'English',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: _openLanguagePicker,
                ),
                _buildDivider(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMd,
                    vertical: AppConstants.paddingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 22,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              app.t('Appearance', 'Gorunum'),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemePreference>(
                        segments: [
                          ButtonSegment<ThemePreference>(
                            value: ThemePreference.light,
                            icon: const Icon(Icons.light_mode_outlined, size: 18),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(app.t('Light', 'Acik')),
                            ),
                          ),
                          ButtonSegment<ThemePreference>(
                            value: ThemePreference.dark,
                            icon: const Icon(Icons.dark_mode_outlined, size: 18),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(app.t('Dark', 'Karanlik')),
                            ),
                          ),
                          ButtonSegment<ThemePreference>(
                            value: ThemePreference.system,
                            icon:
                                const Icon(Icons.brightness_auto_outlined, size: 18),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(app.t('System', 'Sistem')),
                            ),
                          ),
                        ],
                        selected: <ThemePreference>{app.themePreference},
                        multiSelectionEnabled: false,
                        showSelectedIcon: false,
                        onSelectionChanged: (Set<ThemePreference> selected) {
                          if (selected.isEmpty) return;
                          context
                              .read<AppState>()
                              .setThemePreference(selected.first);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Support section
            _buildSectionHeader(context, app.t('Support', 'Destek')),
            _buildSettingsCard(context,
              children: [
                _buildSettingsTile(
                  icon: Iconsax.message_question,
                  title: app.t('Help Center', 'Yardim Merkezi'),
                  onTap: _openHelpCenter,
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  icon: Iconsax.warning_2,
                  title: app.t('Report a Problem', 'Problem Bildir'),
                  onTap: _openReportProblem,
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  icon: Iconsax.document_text,
                  title: app.t('Terms of Service', 'Kullanim Kosullari'),
                  onTap: () => _openLongTextPage(
                    title: 'Terms of Service',
                    text:
                        'This is a demo Terms of Service page. By continuing to use Prolance, you agree to use the platform responsibly, respect other users, and comply with applicable laws. The service is provided as-is for demonstration purposes.',
                  ),
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  icon: Iconsax.shield_tick,
                  title: app.t('Privacy Policy', 'Gizlilik Politikasi'),
                  onTap: () => _openLongTextPage(
                    title: 'Privacy Policy',
                    text:
                        'This is a demo Privacy Policy page. We may process profile and usage data to improve in-app experience. No real external processing occurs in this demo build.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Danger Zone section
            _buildSectionHeader(context, app.t('Danger Zone', 'Tehlikeli Alan')),
            _buildSettingsCard(context,
              children: [
                _buildSettingsTile(
                  icon: Iconsax.logout,
                  title: app.t('Logout', 'Cikis Yap'),
                  titleColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: _showLogoutDialog,
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  icon: Iconsax.trash,
                  title: app.t('Delete Account', 'Hesabi Sil'),
                  titleColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: _deleteAccount,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.paddingSm,
        bottom: AppConstants.paddingSm,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveTitleColor = titleColor ?? scheme.onSurface;
    final effectiveIconColor = iconColor ?? scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical: AppConstants.paddingMd,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: effectiveIconColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: effectiveTitleColor,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Iconsax.arrow_right_3,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 54),
      child: Divider(
        height: 1,
        thickness: 1,
        color: scheme.outlineVariant.withValues(alpha: 0.35),
      ),
    );
  }

  Future<void> _openLanguagePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(context, 'en'),
            ),
            ListTile(
              title: const Text('Turkce'),
              onTap: () => Navigator.pop(context, 'tr'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (selected != null) {
      setState(() => _selectedLanguage = selected);
      final appState = context.read<AppState>();
      await appState.setLanguage(selected);
    }
  }

  void _openChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ChangePasswordPage()),
    );
  }

  void _openPaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PaymentMethodPage()),
    );
  }

  void _openVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _VerificationPage()),
    );
  }

  void _openHelpCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _SimpleAssistantPage(),
      ),
    );
  }

  void _openReportProblem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ReportProblemPage()),
    );
  }

  void _openLongTextPage({required String title, required String text}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StaticTextPage(title: title, text: text),
      ),
    );
  }

  void _deleteAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin account cannot be deleted.')),
    );
  }
}

class _SimpleAssistantPage extends StatefulWidget {
  const _SimpleAssistantPage();

  @override
  State<_SimpleAssistantPage> createState() => _SimpleAssistantPageState();
}

class _SimpleAssistantPageState extends State<_SimpleAssistantPage> {
  final _controller = TextEditingController();
  final List<String> _messages = ['Hi! How can I help you today?'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          'Help Center Assistant',
          style: TextStyle(color: scheme.onSurface),
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final isAssistant = i.isEven;
                return Align(
                  alignment: isAssistant
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAssistant
                          ? scheme.surfaceContainerHighest
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _messages[i],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.35,
                        color: isAssistant
                            ? scheme.onSurface
                            : scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: scheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your question…',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final q = _controller.text.trim();
                      if (q.isEmpty) return;
                      setState(() {
                        _messages.add(q);
                        _messages.add(
                          'Thanks! We received your question and will guide you shortly.',
                        );
                      });
                      _controller.clear();
                    },
                    icon: Icon(Icons.send, color: scheme.primary),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ChangePasswordPage extends StatefulWidget {
  const _ChangePasswordPage();

  @override
  State<_ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<_ChangePasswordPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _current, decoration: const InputDecoration(labelText: 'Current Password')),
            TextField(controller: _next, decoration: const InputDecoration(labelText: 'New Password')),
            TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm Password')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_next.text.trim().length < 4 || _next.text != _confirm.text) return;
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await context.read<AppState>().changePassword(_next.text.trim());
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Password updated.')),
                );
                navigator.pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodPage extends StatelessWidget {
  const _PaymentMethodPage();

  @override
  Widget build(BuildContext context) {
    final holder = TextEditingController();
    final number = TextEditingController();
    final date = TextEditingController();
    final cvv = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: holder, decoration: const InputDecoration(labelText: 'Card Holder')),
            TextField(controller: number, decoration: const InputDecoration(labelText: 'Card Number')),
            TextField(controller: date, decoration: const InputDecoration(labelText: 'MM/YY')),
            TextField(controller: cvv, decoration: const InputDecoration(labelText: 'CVV')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo card saved successfully.')),
                );
              },
              child: const Text('Save Card'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationPage extends StatefulWidget {
  const _VerificationPage();

  @override
  State<_VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<_VerificationPage> {
  final tc = TextEditingController();
  final pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: tc,
              decoration: const InputDecoration(labelText: 'TC Kimlik No (11 hane)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pass,
              decoration: const InputDecoration(labelText: 'Passport No (6-9 alphanumeric)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final tcOk = RegExp(r'^\d{11}$').hasMatch(tc.text.trim());
                final passOk =
                    RegExp(r'^[A-Z0-9]{6,9}$', caseSensitive: false).hasMatch(pass.text.trim());
                if (!tcOk && !passOk) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter valid TC or passport format.')),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification submitted (demo).')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportProblemPage extends StatelessWidget {
  const _ReportProblemPage();

  @override
  Widget build(BuildContext context) {
    final c = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Problem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: c,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Describe the issue...'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ticket sent to support mail (demo).')),
                );
              },
              child: const Text('Send Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticTextPage extends StatelessWidget {
  const _StaticTextPage({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text('$text\n\n$text\n\n$text'),
      ),
    );
  }
}
