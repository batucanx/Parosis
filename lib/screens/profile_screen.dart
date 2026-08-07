import 'package:flutter/material.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass.dart';
import '../widgets/overlay_sheet.dart';

enum ProfileInfoSection { user, contact }

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenCards;
  final ValueChanged<ProfileInfoSection> onOpenSheet;
  const ProfileScreen({
    super.key,
    required this.onOpenCards,
    required this.onOpenSheet,
  });
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 104),
    children: [
      Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.brand400, AppColors.brand600],
              ),
            ),
            child: Center(
              child: Text(
                'BC',
                style: figtree(
                  size: 16,
                  weight: W.extrabold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batuhan Canaracı',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: figtree(size: 17, weight: W.extrabold),
                ),
                const SizedBox(height: 3),
                Text(
                  'SLM-48210 · Aktif Üye',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: figtree(
                    size: 12.5,
                    weight: W.semibold,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      GlassPanel(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _row(
              icon: AppIcons.user(size: 20, color: AppColors.brand700),
              label: 'Kullanıcı Bilgileri',
              subtitle: 'Ad, e-posta, ID',
              onTap: () => onOpenSheet(ProfileInfoSection.user),
            ),
            _row(
              icon: AppIcons.phone(size: 20, color: AppColors.brand700),
              label: 'İletişim Bilgileri',
              subtitle: 'Telefon, e-posta',
              onTap: () => onOpenSheet(ProfileInfoSection.contact),
            ),
            _row(
              icon: AppIcons.creditCard(size: 20, color: AppColors.brand700),
              label: 'Kayıtlı Kartlar',
              subtitle: 'Ödeme yöntemleriniz',
              onTap: onOpenCards,
              last: true,
            ),
          ],
        ),
      ),
    ],
  );
  Widget _row({
    required Widget icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool last = false,
  }) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: figtree(size: 14.5, weight: W.bold)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: figtree(
                    size: 12,
                    weight: W.medium,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          AppIcons.chevronRight(size: 16, color: AppColors.inkFaint),
        ],
      ),
    ),
  );
}

class ProfileInfoSheet extends StatelessWidget {
  final ProfileInfoSection section;
  final VoidCallback onClose;
  const ProfileInfoSheet({
    super.key,
    required this.section,
    required this.onClose,
  });
  @override
  Widget build(BuildContext context) {
    final (title, rows) = switch (section) {
      ProfileInfoSection.user => (
        'Kullanıcı Bilgileri',
        const [
          'Ad Soyad|Batuhan Canaracı',
          'E-posta|batuhancanaraci85@gmail.com',
          'Kullanıcı ID|SLM-48210',
        ],
      ),
      ProfileInfoSection.contact => (
        'İletişim Bilgileri',
        const ['Telefon|0532 118 04 76', 'E-posta|batuhancanaraci85@gmail.com'],
      ),
    };
    return OverlaySheet(
      title: title,
      onClose: onClose,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [for (final row in rows) _infoRow(row)],
      ),
    );
  }

  Widget _infoRow(String data) {
    final parts = data.split('|');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parts[0],
            style: figtree(
              size: 11.5,
              weight: W.semibold,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 3),
          Text(parts[1], style: figtree(size: 14, weight: W.bold)),
        ],
      ),
    );
  }
}
