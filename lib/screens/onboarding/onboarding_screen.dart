import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/queen_avatar.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;
  late final AnimationController _pulse;

  static final _pages = [
    _SplashPage(
      gradient: const [Color(0xFFFFF0F5), Color(0xFFFFE4EC), Color(0xFFFFF5F7)],
      accentOrb: const Color(0xFFEC4899),
      builder: (context) => const _LoveSplashContent(),
    ),
    _SplashPage(
      gradient: const [Color(0xFFFFF5F7), Color(0xFFFCE7F3), Color(0xFFFDF2F8)],
      accentOrb: const Color(0xFFDB2777),
      builder: (context) => const _JournalSplashContent(),
    ),
    _SplashPage(
      gradient: const [Color(0xFFFDF2F8), Color(0xFFFBCFE8), Color(0xFFFFF5F7)],
      accentOrb: const Color(0xFFE8B4BC),
      builder: (context) => const _BeginSplashContent(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (mounted) context.go('/home');
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _SplashBackdrop(
                gradient: page.gradient,
                accentOrb: page.accentOrb,
                pulse: _pulse,
                child: page.builder(context),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    _PageDots(count: _pages.length, index: _page),
                    const Spacer(),
                    if (isLast) ...[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _StartButton(onTap: _finish),
                        ),
                      ),
                    ],
                    _ArrowButton(
                      isLast: isLast,
                      onTap: _next,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page data ───────────────────────────────────────────────────────────────

class _SplashPage {
  const _SplashPage({
    required this.gradient,
    required this.accentOrb,
    required this.builder,
  });

  final List<Color> gradient;
  final Color accentOrb;
  final Widget Function(BuildContext) builder;
}

// ─── Background ──────────────────────────────────────────────────────────────

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop({
    required this.gradient,
    required this.accentOrb,
    required this.pulse,
    required this.child,
  });

  final List<Color> gradient;
  final Color accentOrb;
  final Animation<double> pulse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final t = pulse.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60 + t * 20,
                right: -40,
                child: _GlowOrb(
                  size: 220,
                  color: accentOrb.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                bottom: 80 - t * 15,
                left: -70,
                child: _GlowOrb(
                  size: 180,
                  color: AppTheme.roseGold.withValues(alpha: 0.22),
                ),
              ),
              Positioned(
                top: 120,
                left: 30,
                child: _FloatingShape(
                  size: 14,
                  color: accentOrb.withValues(alpha: 0.35),
                  offset: t * 8,
                ),
              ),
              Positioned(
                top: 200,
                right: 40,
                child: _FloatingShape(
                  size: 10,
                  color: AppTheme.primaryDark.withValues(alpha: 0.25),
                  offset: -t * 6,
                ),
              ),
              SafeArea(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _FloatingShape extends StatelessWidget {
  const _FloatingShape({
    required this.size,
    required this.color,
    required this.offset,
  });

  final double size;
  final Color color;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

// ─── Page 1: Love ────────────────────────────────────────────────────────────

class _LoveSplashContent extends StatelessWidget {
  const _LoveSplashContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 100),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.15),
                      AppTheme.roseGold.withValues(alpha: 0.25),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: -0.06,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [AppTheme.roseGold, AppTheme.primary, AppTheme.primaryDark],
                    ),
                    boxShadow: AppTheme.primaryShadow,
                  ),
                  child: Container(
                    width: 148,
                    height: 188,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      AppAssets.queenAvatar,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Positioned(top: -12, right: 20, child: _MiniHeart(size: 22)),
              const Positioned(bottom: 16, left: 8, child: _MiniHeart(size: 16)),
              const Positioned(top: 40, left: -8, child: _SparkleIcon(size: 20)),
            ],
          ),
          const SizedBox(height: 36),
          _Headline(
            line1: 'I love you,',
            line2: 'my Babe',
            highlight: 'my Babe',
          ),
          const SizedBox(height: 16),
          Text(
            'This app was made just for you, Babe.\nEvery page, every detail — because you deserve the world.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'With all my love, Kidus ♡',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ─── Page 2: Journal ─────────────────────────────────────────────────────────

class _JournalSplashContent extends StatelessWidget {
  const _JournalSplashContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 100),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryLight.withValues(alpha: 0.6),
                        AppTheme.primaryLight.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -0.08,
                  child: _JournalCard(),
                ),
                const Positioned(top: 20, right: 30, child: _CategoryChip(label: 'Gratitude', icon: Icons.favorite_rounded)),
                const Positioned(top: 60, left: 20, child: _CategoryChip(label: 'Prayer', icon: Icons.church_rounded)),
                const Positioned(bottom: 30, right: 24, child: _CategoryChip(label: 'Reflection', icon: Icons.auto_stories_rounded)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _Headline(
            line1: 'Your daily',
            line2: 'letters to God',
            highlight: 'letters to God',
          ),
          const SizedBox(height: 16),
          Text(
            'Pour out your heart — gratitude, prayers,\nand reflections. One sacred page at a time.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.6,
                ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.15),
                  AppTheme.primaryLight,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                color: AppTheme.primary.withValues(alpha: 0.7),
                size: 28,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 8,
                      width: i == 3 ? 60.0 : double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.border.withValues(alpha: 0.8 - i * 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 14, color: AppTheme.primary.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        'Write today…',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 3: Begin ───────────────────────────────────────────────────────────

class _BeginSplashContent extends StatelessWidget {
  const _BeginSplashContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 100),
      child: Column(
        children: [
          const Spacer(flex: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      AppTheme.primaryLight.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _FeatureBubble(
                          icon: Icons.calendar_month_rounded,
                          label: 'Any day',
                          color: AppTheme.primary,
                        ),
                        _FeatureBubble(
                          icon: Icons.menu_book_rounded,
                          label: 'Scripture',
                          color: AppTheme.primaryDark,
                        ),
                        _FeatureBubble(
                          icon: Icons.cloud_off_rounded,
                          label: 'Offline',
                          color: AppTheme.roseGold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.primaryShadow,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 36),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          _Headline(
            line1: 'Your journal',
            line2: 'awaits you',
            highlight: 'awaits you',
          ),
          const SizedBox(height: 16),
          Text(
            'Everything is ready, my love.\nTap the arrow and start writing whenever your heart speaks.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.6,
                ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _FeatureBubble extends StatelessWidget {
  const _FeatureBubble({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _Headline extends StatelessWidget {
  const _Headline({
    required this.line1,
    required this.line2,
    required this.highlight,
  });

  final String line1;
  final String line2;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textDark,
              height: 1.15,
              fontSize: 30,
            ),
        children: [
          TextSpan(text: '$line1\n'),
          TextSpan(
            text: line2,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniHeart extends StatelessWidget {
  const _MiniHeart({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.favorite_rounded, size: size, color: AppTheme.primary.withValues(alpha: 0.7));
  }
}

class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome, size: size, color: AppTheme.roseGold);
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 6),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark])
                : null,
            color: active ? null : AppTheme.border,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.isLast, required this.onTap});

  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        width: isLast ? 60 : 56,
        height: isLast ? 60 : 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(isLast ? 20 : 18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
          color: Colors.white,
          size: isLast ? 28 : 26,
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Start writing ♡',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
