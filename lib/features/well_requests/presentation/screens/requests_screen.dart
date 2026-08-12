import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/well_bookings/presentation/controllers/well_bookings_controller.dart';
import 'package:parosis_sulama/features/well_bookings/presentation/screens/well_bookings_tab.dart';
import 'package:parosis_sulama/features/well_requests/presentation/controllers/well_requests_controller.dart';
import 'package:parosis_sulama/features/well_requests/presentation/screens/well_requests_tab.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/page_heading.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

/// Hamburger menüdeki eski "Kuyu Taleplerim" ve "Talepler" girişlerinin
/// birleştiği ekran: kuyu kayıt talepleri ve randevu talepleri aynı yerde,
/// sekmelerle ayrılmış.
class RequestsScreen extends StatefulWidget {
  final WellRequestsController wellRequestsController;
  final WellBookingsController wellBookingsController;
  const RequestsScreen({
    super.key,
    required this.wellRequestsController,
    required this.wellBookingsController,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

enum _RequestsTab { wells, bookings }

class _RequestsScreenState extends State<RequestsScreen> {
  _RequestsTab _tab = _RequestsTab.wells;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
    children: [
      const PageHeading(
        title: 'Taleplerim',
        subtitle: 'Kuyu kayıt ve randevu taleplerinizi yönetin',
      ),
      const SizedBox(height: 18),
      _TabBar(
        value: _tab,
        onChanged: (tab) => setState(() => _tab = tab),
      ),
      const SizedBox(height: 18),
      switch (_tab) {
        _RequestsTab.wells =>
          WellRequestsTab(controller: widget.wellRequestsController),
        _RequestsTab.bookings =>
          WellBookingsTab(controller: widget.wellBookingsController),
      },
    ],
  );
}

class _TabBar extends StatelessWidget {
  final _RequestsTab value;
  final ValueChanged<_RequestsTab> onChanged;
  const _TabBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.surfaceBorder),
    ),
    child: Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Kuyu Talepleri',
            selected: value == _RequestsTab.wells,
            onTap: () => onChanged(_RequestsTab.wells),
          ),
        ),
        Expanded(
          child: _TabButton(
            label: 'Randevu Talepleri',
            selected: value == _RequestsTab.bookings,
            onTap: () => onChanged(_RequestsTab.bookings),
          ),
        ),
      ],
    ),
  );
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: 0.97,
    onTap: onTap,
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: figtree(
            size: 12.5,
            weight: W.extrabold,
            color: selected ? AppColors.ink : AppColors.inkSoft,
          ),
        ),
      ),
    ),
  );
}
