import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../widgets/queen_avatar.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const AppLogoMark(size: 88),
              const SizedBox(height: 20),
              Text(
                'Almost ready',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Connect Supabase to finish setup. See README.md for steps.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
