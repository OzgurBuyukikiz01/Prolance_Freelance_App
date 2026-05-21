import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pdfx/pdfx.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/portfolio_item.dart';
import '../../../core/models/review_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/submitted_proposal_model.dart';
import '../../../core/repositories/proposal_repository.dart';
import '../../../core/repositories/review_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/utils/save_portfolio_download.dart';
import '../../../core/utils/external_url_launch.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/user_avatar.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

String _rateLabel(double rate) {
  if (rate == rate.roundToDouble()) return rate.toStringAsFixed(0);
  return rate.toStringAsFixed(2);
}

String _displayWebsite(String raw) {
  var t = raw.trim();
  if (t.startsWith('https://')) t = t.substring(8);
  if (t.startsWith('http://')) t = t.substring(7);
  return t;
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<PortfolioItem> _portfolioItems = [];

  Future<List<ReviewModel>>? _reviewsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AppState>().currentUser;
    _reviewsFuture ??= context.read<ReviewRepository>().loadReviewsForProfile(
      user.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final scheme = Theme.of(context).colorScheme;
    final activeJobs = context.watch<JobsProvider>().activeJobsForUser(
      user.id,
      fallbackUserName: user.name,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () => context.push('/edit-profile'),
          ),
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: _buildProfileHeader(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Stats row
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: _buildStatsRow(user),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 120),
              child: _buildWalletRow(
                context,
                user,
                scheme,
                pendingCents: context
                    .watch<ProposalRepository>()
                    .myProposals
                    .where(
                      (p) =>
                          p.lifecyclePhase == ProposalLifecycle.payoutPending,
                    )
                    .fold(0, (sum, p) => sum + (p.fundedAmountCents ?? 0)),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Profile completion
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 150),
              child: _buildProfileCompletion(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // About Me
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 200),
              child: _buildAboutMe(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Skills
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 250),
              child: _buildSkills(user),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 280),
              child: _buildActiveJobs(activeJobs),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Portfolio
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 300),
              child: _buildPortfolio(context),
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // Reviews
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 350),
              child: _buildReviews(),
            ),
            const SizedBox(height: AppConstants.paddingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          UserAvatar(imageUrl: user.avatarUrl, size: UserAvatarSize.xlarge),
          const SizedBox(height: AppConstants.paddingMd),
          Text(
            user.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.location,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  user.location,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (user.hourlyRate > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.dollar_circle, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '\$${_rateLabel(user.hourlyRate)}/hr',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
          if (user.website.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () =>
                  confirmAndLaunchExternalUrl(context, rawUrl: user.website),
              child: Text(
                _displayWebsite(user.website),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (user.rating > 0)
            RatingBarIndicator(
              rating: user.rating,
              itemBuilder: (context, index) =>
                  const Icon(Iconsax.star1, color: AppColors.warning),
              itemCount: 5,
              itemSize: 20,
              unratedColor: AppColors.grey300,
            )
          else
            Text(
              'No rating yet',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Iconsax.briefcase,
            value: '${user.completedJobs}',
            label: 'Jobs Done',
          ),
        ),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: StatCard(
            icon: Iconsax.dollar_circle,
            value: '\$${(user.totalEarnings / 1000).toStringAsFixed(1)}k',
            label: 'Earnings',
          ),
        ),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: StatCard(
            icon: Iconsax.star1,
            value: user.rating.toString(),
            label: 'Rating',
            iconColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletRow(
    BuildContext context,
    UserModel user,
    ColorScheme scheme, {
    int pendingCents = 0,
  }) {
    final demo = (user.demoBalanceCents / 100).toStringAsFixed(2);
    final avail = (user.earningsAvailableCents / 100).toStringAsFixed(2);
    final pending = (pendingCents / 100).toStringAsFixed(2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Demo wallet',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (SupabaseConfig.isEnabled)
                          TextButton.icon(
                            onPressed: () => context.push('/iyzico-topup'),
                            icon: Icon(
                              Iconsax.wallet_add,
                              size: 16,
                              color: scheme.primary,
                            ),
                            label: Text(
                              'Bakiye ekle',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$$demo',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Available (freelancer)',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$$avail',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pendingCents > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        'Pending (24h hold)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$$pending',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileCompletion(UserModel user) {
    final double completion = () {
      double v = 0.2;
      if (user.location != 'Not set') v += 0.2;
      if (user.skills.isNotEmpty) v += 0.25;
      if (user.bio.trim().isNotEmpty) v += 0.2;
      if (user.completedJobs > 0) v += 0.15;
      return v.clamp(0.15, 1.0);
    }();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Completion',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 40,
                lineWidth: 8,
                percent: completion,
                progressColor: AppColors.primary,
                backgroundColor: AppColors.grey200,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '${(completion * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete your profile to get more jobs',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Add portfolio items',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '• Verify your identity',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMe(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Text(
            user.bio,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills
                .map(
                  (skill) => SkillChip(
                    label: skill,
                    variant: SkillChipVariant.primary,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobs(List<dynamic> jobs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Jobs',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (jobs.isEmpty)
            Text(
              'No active jobs yet.',
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...jobs.take(5).map((job) {
              final statusLabel = switch (job.status) {
                'pending_review' => 'Pending review',
                'rejected' => 'Rejected',
                'open' => 'Published',
                'in_progress' => 'In progress',
                _ => job.status,
              };
              final subtitle =
                  job.status == 'rejected' &&
                      (job.rejectionReason?.isNotEmpty ?? false)
                  ? '${job.category} · $statusLabel: ${job.rejectionReason}'
                  : '${job.category} · $statusLabel';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(job.title),
                subtitle: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Edit job',
                  onPressed: () => context.push('/edit-job/${job.id}'),
                  icon: const Icon(Iconsax.edit_2, size: 18),
                ),
                onTap: () => context.push('/jobs/${job.id}'),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _pickPortfolioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      withData: true,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null) return;
    for (final file in result.files) {
      Uint8List? thumb;
      if ((file.extension ?? '').toLowerCase() == 'pdf' && file.bytes != null) {
        try {
          final doc = await PdfDocument.openData(file.bytes!);
          final page = await doc.getPage(1);
          final img = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.png,
          );
          thumb = img?.bytes;
          await page.close();
          await doc.close();
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _portfolioItems.add(PortfolioItem(file: file, thumbnailBytes: thumb));
      });
    }
  }

  Future<void> _downloadPortfolioFile(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) return;
    await savePortfolioDownload(
      name: file.name,
      bytes: bytes,
      extension: file.extension,
    );
  }

  void _showFullPreview(BuildContext context, PortfolioItem item) {
    showDialog(
      context: context,
      builder: (_) => _PortfolioPreviewDialog(item: item),
    );
  }

  Widget _buildPortfolio(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('MMM d, yyyy – HH:mm');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickPortfolioFiles,
            icon: const Icon(Iconsax.add),
            label: const Text('Add from device (jpg/png/pdf)'),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          if (_portfolioItems.isEmpty)
            Text(
              'No portfolio files yet.',
              style: GoogleFonts.poppins(color: scheme.onSurfaceVariant),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _portfolioItems.length,
              itemBuilder: (context, index) {
                final item = _portfolioItems[index];
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildPortfolioThumbnail(item),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Material(
                                color: scheme.surface.withValues(alpha: 0.85),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => _showFullPreview(context, item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Iconsax.maximize_3,
                                      size: 16,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.typeLabel} · ${item.sizeLabel}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              dateFmt.format(item.addedAt),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 28,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _downloadPortfolioFile(item.file),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        textStyle: GoogleFonts.poppins(
                                          fontSize: 10,
                                        ),
                                      ),
                                      child: const Text('Save'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => setState(
                                      () => _portfolioItems.removeAt(index),
                                    ),
                                    icon: Icon(
                                      Iconsax.trash,
                                      size: 16,
                                      color: scheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioThumbnail(PortfolioItem item) {
    if (item.isImage && item.file.bytes != null) {
      return Image.memory(item.file.bytes!, fit: BoxFit.cover);
    }
    if (item.isPdf && item.thumbnailBytes != null) {
      return Image.memory(item.thumbnailBytes!, fit: BoxFit.cover);
    }
    return Center(
      child: Icon(
        item.isPdf ? Icons.picture_as_pdf : Icons.image,
        size: 42,
        color: item.isPdf ? Colors.red : AppColors.primary,
      ),
    );
  }

  Widget _buildReviews() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          FutureBuilder<List<ReviewModel>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return Text(
                  'No reviews yet. Complete jobs to receive reviews.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                );
              }
              return Column(
                children: List.generate(reviews.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < reviews.length - 1
                          ? AppConstants.paddingMd
                          : 0,
                    ),
                    child: _buildReviewCard(reviews[index]),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: review.reviewerAvatar.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: review.reviewerAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.grey200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.grey300,
                          child: Icon(Icons.person, color: AppColors.grey600),
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: AppColors.primary.withValues(alpha: 0.15),
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName.isNotEmpty
                          ? review.reviewerName
                          : 'Anonymous',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: review.rating.toDouble(),
                      itemBuilder: (context, index) => const Icon(
                        Iconsax.star1,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      itemCount: 5,
                      itemSize: 14,
                      unratedColor: AppColors.grey300,
                    ),
                  ],
                ),
              ),
              Text(
                _timeAgo(review.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

class _PortfolioPreviewDialog extends StatefulWidget {
  const _PortfolioPreviewDialog({required this.item});
  final PortfolioItem item;

  @override
  State<_PortfolioPreviewDialog> createState() =>
      _PortfolioPreviewDialogState();
}

class _PortfolioPreviewDialogState extends State<_PortfolioPreviewDialog> {
  PdfDocument? _pdfDoc;
  int _pageCount = 0;
  int _currentPage = 1;
  PdfPageImage? _currentImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.item.isPdf && widget.item.file.bytes != null) {
      _loadPdf();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadPdf() async {
    try {
      _pdfDoc = await PdfDocument.openData(widget.item.file.bytes!);
      _pageCount = _pdfDoc!.pagesCount;
      await _renderPage(1);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _renderPage(int pageNum) async {
    if (_pdfDoc == null) return;
    final page = await _pdfDoc!.getPage(pageNum);
    final img = await page.render(
      width: page.width * 3,
      height: page.height * 3,
      format: PdfPageImageFormat.png,
    );
    await page.close();
    if (mounted) {
      setState(() {
        _currentPage = pageNum;
        _currentImage = img;
      });
    }
  }

  @override
  void dispose() {
    _pdfDoc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog.fullscreen(
      backgroundColor: scheme.surface,
      child: Column(
        children: [
          AppBar(
            title: Text(
              widget.item.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Iconsax.close_circle),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : widget.item.isImage && widget.item.file.bytes != null
                ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      widget.item.file.bytes!,
                      fit: BoxFit.contain,
                    ),
                  )
                : widget.item.isPdf && _currentImage?.bytes != null
                ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      _currentImage!.bytes,
                      fit: BoxFit.contain,
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.insert_drive_file,
                      size: 80,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
          ),
          if (widget.item.isPdf && _pageCount > 1)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1
                          ? () => _renderPage(_currentPage - 1)
                          : null,
                      icon: const Icon(Iconsax.arrow_left_2),
                    ),
                    Text(
                      'Page $_currentPage / $_pageCount',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: _currentPage < _pageCount
                          ? () => _renderPage(_currentPage + 1)
                          : null,
                      icon: const Icon(Iconsax.arrow_right_3),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
