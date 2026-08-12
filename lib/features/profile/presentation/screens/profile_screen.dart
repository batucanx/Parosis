import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/screens/cards_modal.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';
import 'package:parosis_sulama/widgets/slide_up_page_route.dart';

enum ProfileInfoSection { user, contact }

String _formatPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 11) return phone;
  return '${digits.substring(0, 4)} ${digits.substring(4, 7)} '
      '${digits.substring(7, 9)} ${digits.substring(9, 11)}';
}

String _initials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

class ProfileScreen extends StatelessWidget {
  final ProfileController profileController;
  final PaymentCardsController paymentCardsController;
  const ProfileScreen({
    super.key,
    required this.profileController,
    required this.paymentCardsController,
  });

  void _openInfo(BuildContext context, ProfileInfoSection section) {
    Navigator.of(context).push<void>(
      SlideUpPageRoute(
        builder: (_) => ProfileInfoScreen(
          profileController: profileController,
          section: section,
        ),
      ),
    );
  }

  void _openCards(BuildContext context) {
    Navigator.of(context).push<void>(
      SlideUpPageRoute(
        builder: (_) => CardsModal(controller: paymentCardsController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: profileController,
    builder: (context, _) {
      final user = profileController.user;
      if (user == null) {
        return Center(
          child: Text(
            'Profil yükleniyor…',
            style: figtree(
              size: 13,
              weight: W.semibold,
              color: AppColors.inkFaint,
            ),
          ),
        );
      }
      return ListView(
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
                    _initials(user.fullName),
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
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtree(size: 17, weight: W.extrabold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${user.id} · ${user.statusLabel}',
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
                  onTap: () => _openInfo(context, ProfileInfoSection.user),
                ),
                _row(
                  icon: AppIcons.phone(size: 20, color: AppColors.brand700),
                  label: 'İletişim Bilgileri',
                  subtitle: 'Telefon, e-posta',
                  onTap: () => _openInfo(context, ProfileInfoSection.contact),
                ),
                _row(
                  icon: AppIcons.creditCard(
                    size: 20,
                    color: AppColors.brand700,
                  ),
                  label: 'Kayıtlı Kartlar',
                  subtitle: 'Ödeme yöntemleriniz',
                  onTap: () => _openCards(context),
                  last: true,
                ),
              ],
            ),
          ),
        ],
      );
    },
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

/// Kullanıcı/İletişim bilgileri — "Yeni Kart Ekle" ekranıyla aynı düzende
/// (üstte geri oklu başlık çubuğu), navbar'dan yukarı kayarak açılan tam
/// ekran sayfa. iOS ve Android'de aynı geçiş için [SlideUpPageRoute] ile
/// açılır.
class ProfileInfoScreen extends StatelessWidget {
  final ProfileController profileController;
  final ProfileInfoSection section;
  const ProfileInfoScreen({
    super.key,
    required this.profileController,
    required this.section,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: profileController,
    builder: (context, _) {
      final user = profileController.user;
      final title = switch (section) {
        ProfileInfoSection.user => 'Kullanıcı Bilgileri',
        ProfileInfoSection.contact => 'İletişim Bilgileri',
      };
      final rows = user == null
          ? const <(String, String)>[]
          : switch (section) {
              ProfileInfoSection.user => [
                ('Ad Soyad', user.fullName),
                ('E-posta', user.email),
                ('Kullanıcı ID', user.id),
              ],
              ProfileInfoSection.contact => [
                ('Telefon', _formatPhone(user.phone)),
                ('E-posta', user.email),
              ],
            };

      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: '$title ekranını kapat',
                      child: Tooltip(
                        message: 'Geri',
                        child: PressableScale(
                          scale: 0.9,
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: Center(
                              child: AppIcons.arrowLeft(
                                size: 25,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: figtree(
                          size: 18,
                          weight: W.extrabold,
                          tracking: Tracking.tight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [for (final row in rows) _infoRow(row.$1, row.$2)],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _infoRow(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0x11000000))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: figtree(
            size: 11.5,
            weight: W.semibold,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 3),
        Text(value, style: figtree(size: 14, weight: W.bold)),
      ],
    ),
  );
}
