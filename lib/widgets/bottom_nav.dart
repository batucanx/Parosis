import 'package:flutter/material.dart';

import '../app/navigation/app_destination.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'glass.dart';

class _TabDef {
  final AppDestination destination;
  final String label;
  final Widget Function({double size, Color color}) icon;
  const _TabDef(this.destination, this.label, this.icon);
}

final _tabs = [
  _TabDef(
    AppDestination.home,
    'Ana Sayfa',
    ({size = 24.0, color = Colors.black}) =>
        AppIcons.home(size: size, color: color),
  ),
  _TabDef(
    AppDestination.balance,
    'Bakiyem',
    ({size = 24.0, color = Colors.black}) =>
        AppIcons.wallet(size: size, color: color),
  ),
  _TabDef(
    AppDestination.profile,
    'Profil',
    ({size = 24.0, color = Colors.black}) =>
        AppIcons.user(size: size, color: color),
  ),
];

class BottomNav extends StatelessWidget {
  final AppDestination activeDestination;
  final ValueChanged<AppDestination> onChange;
  const BottomNav({
    super.key,
    required this.activeDestination,
    required this.onChange,
  });

  int get _activeIndex {
    final index = _tabs.indexWhere((t) => t.destination == activeDestination);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return GlassNav(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / _tabs.length;
            return SizedBox(
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    left: tabWidth * _activeIndex,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.brand600,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF115A4B,
                              ).withValues(alpha: 0.85),
                              blurRadius: 16,
                              spreadRadius: -6,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final tab in _tabs)
                        Expanded(
                          child: _NavButton(
                            tab: tab,
                            selected: activeDestination == tab.destination,
                            onTap: () => onChange(tab.destination),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _TabDef tab;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutBack,
              child: tab.icon(
                size: 20,
                color: selected ? Colors.white : AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: figtree(
                size: 10.5,
                weight: selected ? W.bold : W.semibold,
                color: selected ? Colors.white : AppColors.inkSoft,
                tracking: Tracking.tight,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
