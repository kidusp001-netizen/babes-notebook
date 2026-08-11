import 'package:flutter/material.dart';

import '../config/theme.dart';

/// App image assets.
class AppAssets {
  static const queenAvatar = 'assets/images/queen_avatar.png';
}

/// Profile avatar with a rose-gold ring — used across the app.
class QueenAvatar extends StatelessWidget {
  const QueenAvatar({
    super.key,
    this.size = 52,
    this.showCrown = true,
    this.showRing = true,
  });

  final double size;
  final bool showCrown;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final imageSize = showRing ? size - 6 : size;
    final crownSize = size * 0.28;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: showRing
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.roseGold,
                        AppTheme.primary,
                        AppTheme.primaryDark,
                      ],
                    ),
                    boxShadow: AppTheme.primaryShadow,
                  )
                : null,
            padding: showRing ? const EdgeInsets.all(3) : EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  AppAssets.queenAvatar,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (showCrown)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: crownSize,
                height: crownSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.roseGold, Color(0xFFD4A574)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.roseGold.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: crownSize * 0.55,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// App logo mark for splash, auth, and branding.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QueenAvatar(size: size, showCrown: true),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryLight,
                AppTheme.primaryLight.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            '♡ for my queen',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
          ),
        ),
      ],
    );
  }
}
