import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Read-only profile for another user (opened from chat, links, etc.).
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>?> _load() async {
    if (!SupabaseConfig.isEnabled) return null;
    try {
      final c = Supabase.instance.client;
      final row = await c
          .from('profiles')
          .select(
            'full_name, avatar_url, title, bio, hourly_rate, website, skills, location, role',
          )
          .eq('id', widget.userId)
          .maybeSingle();
      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final row = snap.data;
          if (row == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  SupabaseConfig.isEnabled
                      ? 'Profile not found or unavailable.'
                      : 'Sign in with Supabase to view member profiles.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: scheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }
          final name = '${row['full_name'] ?? 'Member'}'.trim();
          final avatar = '${row['avatar_url'] ?? ''}';
          final title = '${row['title'] ?? ''}'.trim();
          final bio = '${row['bio'] ?? ''}'.trim();
          final rate = (row['hourly_rate'] as num?)?.toDouble() ?? 0.0;
          final site = '${row['website'] ?? ''}'.trim();
          final location = '${row['location'] ?? 'Remote'}'.trim();
          final role = '${row['role'] ?? ''}';
          final skillsRaw = row['skills'];
          final skills = skillsRaw is List
              ? skillsRaw.map((e) => '$e').where((s) => s.isNotEmpty).toList()
              : <String>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipOval(
                    child: avatar.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatar,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 96,
                              height: 96,
                              color: scheme.surfaceContainerHighest,
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 96,
                              height: 96,
                              color: scheme.surfaceContainerHighest,
                              child: Icon(Iconsax.user,
                                  size: 40, color: scheme.onSurfaceVariant),
                            ),
                          )
                        : Container(
                            width: 96,
                            height: 96,
                            color: AppColors.primary.withValues(alpha: 0.12),
                            child: Icon(Iconsax.user,
                                size: 40, color: AppColors.primary),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                if (title.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '$role · $location',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (rate > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '\$${rate.toStringAsFixed(0)}/hr',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (site.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    site,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Skills',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills
                        .map(
                          (s) => Chip(
                            label: Text(
                              s,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
