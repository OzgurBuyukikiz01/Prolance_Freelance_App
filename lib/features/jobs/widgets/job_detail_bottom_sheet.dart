import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/job_model.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/state/jobs_provider.dart';
import '../../messages/screens/chat_screen.dart';

/// Rich bottom-sheet modal with 3 tabs: Özet / İşveren / Teklif
void showJobDetailBottomSheet(BuildContext context, JobModel job) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => JobDetailBottomSheet(job: job),
  );
}

class JobDetailBottomSheet extends StatelessWidget {
  const JobDetailBottomSheet({super.key, required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // Handle + header
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: job.clientAvatar,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                color: scheme.surfaceContainerHighest,
                                child: Icon(Iconsax.user,
                                    color: scheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick action row
                    _QuickActionsRow(job: job),
                    const SizedBox(height: 8),
                    // Tab bar
                    TabBar(
                      labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: scheme.onSurfaceVariant,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Özet'),
                        Tab(text: 'İşveren'),
                        Tab(text: 'Teklif'),
                      ],
                    ),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    _SummaryTab(job: job, scrollController: scrollController),
                    _ClientTab(job: job),
                    _ProposalTab(job: job),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.job});
  final JobModel job;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(
            icon: Iconsax.share,
            label: 'Paylaş',
            onTap: () => Share.share(
              '${job.title}\n${job.category}\n— Prolance',
              subject: job.title,
            ),
          ),
          _QuickAction(
            icon: Iconsax.heart,
            label: 'Kaydet',
            onTap: () {
              context.read<JobsProvider>().toggleFavorite(job.id, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İlan kaydedildi')),
              );
            },
          ),
          _QuickAction(
            icon: Iconsax.message_2,
            label: 'Mesaj',
            onTap: () {
              final repo = context.read<MessageRepository>();
              final convId = repo.ensureConversationForJob(
                jobId: job.id,
                employerName: job.clientName,
                employerAvatar: job.clientAvatar,
              );
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ChatScreen(
                    conversationId: convId,
                    userName: job.clientName,
                    userAvatar: job.clientAvatar,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Summary
// ---------------------------------------------------------------------------
class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.job, required this.scrollController});
  final JobModel job;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Budget badge
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Iconsax.dollar_circle,
              label: job.budgetType == 'hourly'
                  ? '\$${job.budgetMin.toInt()}–\$${job.budgetMax.toInt()}/hr'
                  : '\$${job.budgetMin.toInt()}–\$${job.budgetMax.toInt()}',
            ),
            _InfoChip(icon: Iconsax.clock, label: job.duration),
            _InfoChip(icon: Iconsax.crown, label: job.experienceLevel),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Açıklama',
          style: AppTextStyles.heading6
              .copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          job.description,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: scheme.onSurface,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        if (job.skills.isNotEmpty) ...[
          Text(
            'Gerekli Beceriler',
            style: AppTextStyles.heading6
                .copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.skills
                .map(
                  (s) => Chip(
                    label: Text(
                      s,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Client
// ---------------------------------------------------------------------------
class _ClientTab extends StatelessWidget {
  const _ClientTab({required this.job});
  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: job.clientAvatar,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      color: scheme.surfaceContainerHighest,
                      child: const Icon(Iconsax.user, size: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.clientName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingBarIndicator(
                        rating: 4.5,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        itemSize: 16,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Doğrulanmış İşveren',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Message button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final repo = context.read<MessageRepository>();
                final convId = repo.ensureConversationForJob(
                  jobId: job.id,
                  employerName: job.clientName,
                  employerAvatar: job.clientAvatar,
                );
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ChatScreen(
                      conversationId: convId,
                      userName: job.clientName,
                      userAvatar: job.clientAvatar,
                    ),
                  ),
                );
              },
              icon: const Icon(Iconsax.message_2),
              label: const Text('Mesaj Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
// Tab 3: Proposal
// ---------------------------------------------------------------------------
class _ProposalTab extends StatefulWidget {
  const _ProposalTab({required this.job});
  final JobModel job;

  @override
  State<_ProposalTab> createState() => _ProposalTabState();
}

class _ProposalTabState extends State<_ProposalTab> {
  final _coverController = TextEditingController();
  final _priceController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _coverController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_coverController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_submitted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.tick_circle,
                color: AppColors.success, size: 56),
            const SizedBox(height: 16),
            Text(
              'Teklifiniz Gönderildi!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İşveren en kısa sürede size dönecektir.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teklifiniz',
            style: AppTextStyles.heading6
                .copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 16),
          // Cover letter
          TextField(
            controller: _coverController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText:
                  'Kendinizi ve bu iş için neden uygun olduğunuzu anlatın...',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: scheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: scheme.outlineVariant),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.poppins(
                fontSize: 14, color: scheme.onSurface),
          ),
          const SizedBox(height: 16),
          // Price
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Teklif Fiyatı (USD)',
              prefixIcon: const Icon(Iconsax.dollar_circle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            style: GoogleFonts.poppins(
                fontSize: 14, color: scheme.onSurface),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Iconsax.send_2),
              label: const Text('Teklif Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
// Helpers
// ---------------------------------------------------------------------------
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
