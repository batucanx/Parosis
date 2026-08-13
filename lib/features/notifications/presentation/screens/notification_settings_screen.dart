import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/notifications/domain/entities/notification_preferences.dart';
import 'package:parosis_sulama/features/notifications/presentation/controllers/notification_preferences_controller.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/modal_header.dart';

class NotificationSettingsScreen extends StatelessWidget {
  final NotificationPreferencesController controller;
  const NotificationSettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: Column(
        children: [
          const ModalHeader(title: 'Bildirim Ayarları'),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final prefs = controller.preferences;
                if (prefs == null) {
                  return Center(
                    child: Text(
                      'Yükleniyor…',
                      style: figtree(
                        size: 13,
                        weight: W.semibold,
                        color: AppColors.inkFaint,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    _ToggleRow(
                      icon: AppIcons.droplet(size: 20, color: AppColors.brand700),
                      iconBg: AppColors.brand100,
                      title: 'Sulama Bildirimleri',
                      subtitle: 'Sulama başladığında ve bittiğinde haber ver',
                      value: prefs.irrigationAlerts,
                      onChanged: (v) =>
                          controller.update(prefs.copyWith(irrigationAlerts: v)),
                    ),
                    const SizedBox(height: 10),
                    _ToggleRow(
                      icon: AppIcons.wallet(size: 20, color: AppColors.brand700),
                      iconBg: AppColors.brand100,
                      title: 'Bakiye Bildirimleri',
                      subtitle: 'Bakiye yüklemeleri ve düşük bakiye uyarıları',
                      value: prefs.balanceAlerts,
                      onChanged: (v) =>
                          controller.update(prefs.copyWith(balanceAlerts: v)),
                    ),
                    const SizedBox(height: 10),
                    _ToggleRow(
                      icon: AppIcons.listChecks(size: 20, color: AppColors.sea700),
                      iconBg: AppColors.sea100,
                      title: 'Talep ve Onaylar',
                      subtitle: 'Kuyu ve randevu taleplerinizdeki gelişmeler',
                      value: prefs.requestAlerts,
                      onChanged: (v) =>
                          controller.update(prefs.copyWith(requestAlerts: v)),
                    ),
                    const SizedBox(height: 10),
                    _ToggleRow(
                      icon: AppIcons.bell(size: 20, color: AppColors.sea700),
                      iconBg: AppColors.sea100,
                      title: 'Kampanya ve Duyurular',
                      subtitle: 'Genel duyurular ve kampanya bildirimleri',
                      value: prefs.announcements,
                      onChanged: (v) =>
                          controller.update(prefs.copyWith(announcements: v)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final Widget icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(18),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    elevated: false,
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: icon),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: figtree(size: 14, weight: W.bold)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: figtree(
                  size: 11.5,
                  weight: W.medium,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.brand600,
        ),
      ],
    ),
  );
}
