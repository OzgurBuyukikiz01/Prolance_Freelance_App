import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: Implement actual logout
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
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
            _buildSectionHeader('Account'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Iconsax.user_edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.lock_1,
                  title: 'Change Password',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.wallet_3,
                  title: 'Payment Methods',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.verify,
                  title: 'Verification',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Preferences section
            _buildSectionHeader('Preferences'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Iconsax.notification,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.global,
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.moon,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                    },
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Support section
            _buildSectionHeader('Support'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Iconsax.message_question,
                  title: 'Help Center',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.warning_2,
                  title: 'Report a Problem',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.document_text,
                  title: 'Terms of Service',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.shield_tick,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Danger Zone section
            _buildSectionHeader('Danger Zone'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Iconsax.logout,
                  title: 'Logout',
                  titleColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: _showLogoutDialog,
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Iconsax.trash,
                  title: 'Delete Account',
                  titleColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
    final effectiveTitleColor = titleColor ?? AppColors.textPrimary;
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;

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
                  color: AppColors.textSecondary,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 54),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.grey200,
      ),
    );
  }
}
