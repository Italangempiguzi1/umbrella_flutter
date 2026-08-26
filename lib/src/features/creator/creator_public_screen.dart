import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class CreatorPublicScreen extends ConsumerWidget {
  const CreatorPublicScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Channel')),
      body: FutureBuilder<CreatorProfile>(
        future: ref.read(creatorRepositoryProvider).publicProfile(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || snapshot.data == null) return EmptyState(title: 'Creator not found', message: snapshot.error?.toString() ?? 'This creator profile is not available.', icon: Icons.person_off_rounded);
          final creator = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: creator.coverImageUrl.isEmpty ? AppTheme.heroGradient : null,
                  image: creator.coverImageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(creator.coverImageUrl), fit: BoxFit.cover) : null,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -38),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.surfaceAlt,
                      backgroundImage: creator.profileImageUrl.isNotEmpty ? NetworkImage(creator.profileImageUrl) : null,
                      child: creator.profileImageUrl.isEmpty ? Text(creator.displayName.isEmpty ? 'C' : creator.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)) : null,
                    ),
                    const SizedBox(height: 10),
                    Text(creator.displayName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('${compactNumber(creator.totalFollowers)} followers • ${creator.verificationStatus}', style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Follow Creator',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: () async {
                        try {
                          final result = await ref.read(engagementRepositoryProvider).toggleFollow(creator.id);
                          if (context.mounted) showSnack(context, result['following'] == true ? 'Following creator' : 'Unfollowed creator');
                        } catch (error) {
                          if (context.mounted) showSnack(context, error.toString());
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(creator.bio.isEmpty ? 'No bio provided.' : creator.bio, textAlign: TextAlign.center, style: const TextStyle(height: 1.5, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
