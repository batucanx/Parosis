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

/// Yüzen alt navigasyon — ikon üstte, yazı altta, seçili sekme yeşil pill.
class BottomNav extends StatelessWidget {
  final AppDestination activeDestination;
  final ValueChanged<AppDestination> onChange;
  const BottomNav({
    super.key,
    required this.activeDestination,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return GlassNav(
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand600 : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF115A4B).withValues(alpha: 0.85),
                    blurRadius: 16,
                    spreadRadius: -6,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tab.icon(
              size: 20,
              color: selected ? Colors.white : AppColors.inkSoft,
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: figtree(
                size: 10.5,
                weight: selected ? W.bold : W.semibold,
                color: selected ? Colors.white : AppColors.inkSoft,
                tracking: Tracking.tight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
