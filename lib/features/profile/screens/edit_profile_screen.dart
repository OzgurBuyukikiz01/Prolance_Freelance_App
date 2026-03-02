import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/widgets/custom_text_field.dart';

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
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    final user = UserModel.dummy();
    _nameController = TextEditingController(text: user.name);
    _titleController = TextEditingController(text: user.title);
    _bioController = TextEditingController(text: user.bio);
    _hourlyRateController = TextEditingController(text: '75');
    _locationController = TextEditingController(text: user.location);
    _websiteController = TextEditingController(text: 'sarahchen.dev');
    _skills = List.from(user.skills);
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

  void _addSkill() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(
            'Add Skill',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter skill name',
              hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                setState(() => _skills.add(value.trim()));
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() => _skills.add(controller.text.trim()));
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Add',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveProfile() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
                      imageUrl: UserModel.dummy().avatarUrl,
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
                      onTap: () {
                        // TODO: Implement image picker
                      },
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
                        child: const Icon(
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
              hint: 'City, Country',
              prefixIcon: Iconsax.location,
            ),
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
                color: AppColors.textPrimary,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Iconsax.close_circle,
                        size: 18,
                        color: AppColors.textSecondary,
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
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.add,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Add skill',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
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
