import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/main_nav_controller.dart';
import '../../../core/state/jobs_provider.dart';
import '../../../core/widgets/job_card.dart';
import '../../../core/widgets/prolance_empty_state.dart';
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.watch<JobsProvider>();
    final favorites = jobsProvider.favoriteJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? ProlanceEmptyState.favorites(
              onBrowse: () {
                context.read<MainNavController>().selectTab(1);
                context.go('/home');
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = favorites[index];
                return JobCard(
                  job: job,
                  onTap: () => context.push('/jobs/${job.id}'),
                  onSaveToggle: (saved) => jobsProvider.toggleFavorite(job.id, saved),
                );
              },
            ),
    );
  }
}
