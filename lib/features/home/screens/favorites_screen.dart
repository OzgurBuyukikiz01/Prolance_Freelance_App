import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/job_card.dart';
import '../../jobs/screens/job_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final favorites = appState.favoriteJobs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: AppColors.background,
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorite jobs yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = favorites[index];
                return JobCard(
                  job: job,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                    );
                  },
                  onSaveToggle: (saved) => appState.toggleFavorite(job.id, saved),
                );
              },
            ),
    );
  }
}
