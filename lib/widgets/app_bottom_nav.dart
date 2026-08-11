import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentPath});

  /// Total vertical space taken by the floating nav bar.
  static double bottomClearance(BuildContext context) {
    return 72 + 24 + MediaQuery.of(context).padding.bottom;
  }

  final String currentPath;

  int get _currentIndex {
    if (currentPath.startsWith('/calendar')) return 1;
    if (currentPath.startsWith('/entries')) return 2;
    if (currentPath.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/calendar');
      case 2:
        context.go('/entries');
      case 3:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.navDark,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              selected: _currentIndex == 0,
              onTap: () => _onTap(context, 0),
            ),
            _NavItem(
              icon: Icons.calendar_month_rounded,
              selected: _currentIndex == 1,
              onTap: () => _onTap(context, 1),
            ),
            _NavItem(
              icon: Icons.menu_book_rounded,
              selected: _currentIndex == 2,
              onTap: () => _onTap(context, 2),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              selected: _currentIndex == 3,
              onTap: () => _onTap(context, 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.45),
          size: 24,
        ),
      ),
    );
  }
}
