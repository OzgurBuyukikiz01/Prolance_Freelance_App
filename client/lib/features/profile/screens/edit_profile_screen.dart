import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_catalog_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/overlays/prolance_dialog.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _bioController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late   List<String> _skills;
  bool _locationsReady = false;
  List<String> _locationSuggestions = [];
  String? _avatarOverrideUrl;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _nameController = TextEditingController(text: user.name);
    _titleController = TextEditingController(text: user.title);
    _bioController = TextEditingController(text: user.bio);
    _hourlyRateController = TextEditingController(
      text: user.hourlyRate > 0
          ? (user.hourlyRate == user.hourlyRate.roundToDouble()
              ? user.hourlyRate.toStringAsFixed(0)
              : user.hourlyRate.toStringAsFixed(2))
          : '',
    );
    _locationController = TextEditingController(text: user.location);
    _websiteController = TextEditingController(text: user.website);
    _skills = List.from(user.skills);
    LocationCatalogService.instance.ensureLoaded().then((_) {
      if (mounted) setState(() => _locationsReady = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _addSkill() async {
    final appState = context.read<AppState>();
    final controller = TextEditingController();
    final added = await showProlanceFramedDialog<bool>(
      context: context,
      title: appState.t('Add skill', 'Beceri ekle'),
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: appState.t('Enter skill name', 'Beceri adı girin'),
          hintStyle: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
        ),
        style: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(context, true);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            appState.t('Cancel', 'İptal'),
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, true);
            }
          },
          child: Text(
            appState.t('Add', 'Ekle'),
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
    if (added == true && controller.text.trim().isNotEmpty) {
      setState(() => _skills.add(controller.text.trim()));
    }
    controller.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    if (!SupabaseConfig.isEnabled) {
      if (!mounted) return;
      final appState = context.read<AppState>();
      ProlanceMessenger.info(
        context,
        appState.t(
          'Avatar upload requires Supabase.',
          'Avatar yüklemesi için Supabase gerekir.',
        ),
      );
      return;
    }
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (img == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await img.readAsBytes();
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final path = '$uid/avatar.jpg';
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final url = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);
      final busted =
          '$url?v=${DateTime.now().millisecondsSinceEpoch}';
      if (!mounted) return;
      setState(() {
        _avatarOverrideUrl = busted;
        _uploadingAvatar = false;
      });
      final current = context.read<AppState>().currentUser;
      await context.read<AppState>().updateUser(
            current.copyWith(avatarUrl: busted),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ProlanceMessenger.error(
        context,
        context.read<AppState>().t('Could not upload avatar.', 'Avatar yüklenemedi.'),
      );
    }
  }

  Future<void> _saveProfile() async {
    final current = context.read<AppState>().currentUser;
    final hourly = double.tryParse(_hourlyRateController.text.trim()) ?? 0;
    final updated = current.copyWith(
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      bio: _bioController.text.trim(),
      hourlyRate: hourly,
      location: _locationController.text.trim(),
      website: _websiteController.text.trim(),
      skills: _skills,
      avatarUrl: _avatarOverrideUrl ?? current.avatarUrl,
    );
    if (!mounted) return;
    context.read<AppState>().updateUser(updated);
    // Persist to Supabase profiles table (fire-and-forget, non-blocking)
    AuthService.instance.upsertProfileFromUserModel(updated).catchError((_) {});
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingMd),

            // Profile photo section
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _avatarOverrideUrl ??
                          context.read<AppState>().currentUser.avatarUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.grey200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.grey300,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _uploadingAvatar
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(
                                Iconsax.camera,
                                color: AppColors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Form fields
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Iconsax.user,
            ),
            const SizedBox(height: AppConstants.paddingMd),

            CustomTextField(
              controller: _titleController,
              label: 'Title / Headline',
              hint: 'e.g. Senior Flutter Developer',
              prefixIcon: Iconsax.briefcase,
            ),
            const SizedBox(height: AppConstants.paddingMd),

            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell clients about yourself...',
              prefixIcon: Iconsax.document_text,
              maxLines: 4,
            ),
            const SizedBox(height: AppConstants.paddingMd),

            CustomTextField(
              controller: _hourlyRateController,
              label: 'Hourly Rate (\$)',
              hint: '75',
              prefixIcon: Iconsax.dollar_circle,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppConstants.paddingMd),

            CustomTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Search city or country',
              prefixIcon: Iconsax.location,
              onChanged: (value) {
                if (!_locationsReady) return;
                setState(() {
                  _locationSuggestions =
                      LocationCatalogService.instance.filter(value);
                });
              },
            ),
            if (_locationsReady && _locationSuggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _locationSuggestions.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.grey200),
                  itemBuilder: (context, i) {
                    final option = _locationSuggestions[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      onTap: () {
                        _locationController.text = option;
                        setState(() => _locationSuggestions = []);
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: AppConstants.paddingMd),

            CustomTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'yourwebsite.com',
              prefixIcon: Iconsax.global,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Skills section
            Text(
              'Skills',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._skills.map((skill) => Chip(
                      label: Text(
                        skill,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      deleteIcon: Icon(
                        Iconsax.close_circle,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onDeleted: () {
                        setState(() => _skills.remove(skill));
                      },
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                    )),
                GestureDetector(
                  onTap: _addSkill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.add,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Add skill',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXl),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: AppConstants.paddingXl),
          ],
        ),
      ),
    );
  }
}
