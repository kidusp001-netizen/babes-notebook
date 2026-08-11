import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/preview_config.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'queen_avatar.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, Queen!';
    if (hour < 17) return 'Good Afternoon, Queen!';
    return 'Good Evening, Queen!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(displayNameProvider);

    return Row(
      children: [
        const QueenAvatar(size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        if (PreviewConfig.enabled)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Preview',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primary,
                    fontSize: 12,
                  ),
            ),
          )
        else
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
      ],
    );
  }
}
