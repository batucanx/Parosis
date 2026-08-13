import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:parosis_sulama/features/notifications/presentation/controllers/notification_preferences_controller.dart';
import 'package:parosis_sulama/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/screens/cards_modal.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/features/profile/presentation/screens/help_support_screen.dart';
import 'package:parosis_sulama/features/profile/presentation/screens/security_screen.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_booking_request.dart';
import 'package:parosis_sulama/features/well_bookings/presentation/controllers/well_bookings_controller.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/confirm_dialog.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/modal_header.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';
import 'package:parosis_sulama/widgets/slide_up_page_route.dart';

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

/// Bin ayraçlı tam sayı + "sa" — geçmiş sulamalardaki toplam [Duration]
/// üzerinden en yakın saate yuvarlanır.
String _formatHours(Duration total) {
  final hours = (total.inMinutes / 60).round();
  final digits = hours.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '$buffer sa';
}

class ProfileScreen extends StatelessWidget {
  final ProfileController profileController;
  final PaymentCardsController paymentCardsController;
  final IrrigationController irrigationController;
  final WellBookingsController wellBookingsController;
  final AuthController authController;
  final NotificationPreferencesController notificationPreferencesController;
  final VoidCallback onOpenAddressInfo;
  final VoidCallback onLogout;
  const ProfileScreen({
    super.key,
    required this.profileController,
    required this.paymentCardsController,
    required this.irrigationController,
    required this.wellBookingsController,
    required this.authController,
    required this.notificationPreferencesController,
    required this.onOpenAddressInfo,
    required this.onLogout,
  });

  void _openUserInfo(BuildContext context) {
    Navigator.of(context).push<void>(
      SlideUpPageRoute(
        builder: (_) => ProfileInfoScreen(profileController: profileController),
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

  void _openNotificationSettings(BuildContext context) {
    Navigator.of(context).push<void>(
      SlideUpPageRoute(
        builder: (_) => NotificationSettingsScreen(
          controller: notificationPreferencesController,
        ),
      ),
    );
  }

  void _openSecurity(BuildContext context) {
    Navigator.of(context).push<void>(
      SlideUpPageRoute(
        builder: (_) => SecurityScreen(controller: authController),
      ),
    );
  }

  void _openHelp(BuildContext context) {
    Navigator.of(context).push<void>(
      SlideUpPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.logout_rounded,
      title: 'Çıkış Yap',
      message: 'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
      confirmLabel: 'Çıkış Yap',
    );
    if (confirmed) onLogout();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      profileController,
      irrigationController,
      wellBookingsController,
    ]),
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

      final activeCount = irrigationController.active.length;
      final planCount = wellBookingsController.outgoing
          .where(
            (r) =>
                r.status == WellBookingStatus.pending ||
                r.status == WellBookingStatus.approved,
          )
          .length;
      final pastSessions = irrigationController.past;
      final completedWellsCount = pastSessions
          .map((session) => session.wellId)
          .toSet()
          .length;
      final totalDuration = pastSessions.fold<Duration>(
        Duration.zero,
        (sum, session) => sum + session.duration,
      );

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 104),
        children: [
          _ProfileHeaderCard(
            fullName: user.fullName,
            statusLabel: user.statusLabel,
            statusActive: user.hasCompleteAddress,
            email: user.email,
            phone: _formatPhone(user.phone),
            onTap: () => _openUserInfo(context),
          ),
          const SizedBox(height: 16),
          _StatsSummaryCard(
            items: [
              _StatItem(
                icon: AppIcons.droplet(size: 19, color: AppColors.brand600),
                value: '$activeCount',
                label: 'Aktif Sulamalarım',
              ),
              _StatItem(
                icon: AppIcons.calendarClock(
                  size: 19,
                  color: AppColors.sea600,
                ),
                value: '$planCount',
                label: 'Sulama Planım',
              ),
              _StatItem(
                icon: AppIcons.listChecks(size: 19, color: AppColors.sea600),
                value: '$completedWellsCount',
                label: 'Tamamlanan',
              ),
              _StatItem(
                icon: AppIcons.clock(size: 19, color: AppColors.brand600),
                value: _formatHours(totalDuration),
                label: 'Toplam Kullanım',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MenuCard(
            icon: AppIcons.user(size: 20, color: AppColors.brand700),
            iconBg: AppColors.brand100,
            title: 'Kullanıcı Bilgilerim',
            subtitle: 'Kişisel bilgilerinizi görüntüleyin ve düzenleyin',
            onTap: () => _openUserInfo(context),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: AppIcons.mapPin(size: 20, color: AppColors.brand700),
            iconBg: AppColors.brand100,
            title: 'Adres Bilgilerim',
            subtitle: 'Kayıtlı adreslerinizi yönetin',
            onTap: onOpenAddressInfo,
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: AppIcons.creditCard(size: 20, color: AppColors.brand700),
            iconBg: AppColors.brand100,
            title: 'Kayıtlı Kartlarım',
            subtitle: 'Kayıtlı ödeme yöntemlerinizi görüntüleyin',
            onTap: () => _openCards(context),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: AppIcons.bell(size: 20, color: AppColors.sea700),
            iconBg: AppColors.sea100,
            title: 'Bildirim Ayarları',
            subtitle: 'Bildirim tercihlerinizi yönetin',
            onTap: () => _openNotificationSettings(context),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: AppIcons.shield(size: 20, color: AppColors.sea700),
            iconBg: AppColors.sea100,
            title: 'Güvenlik',
            subtitle: 'Şifre değişikliği ve güvenlik ayarları',
            onTap: () => _openSecurity(context),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: AppIcons.helpCircle(size: 20, color: AppColors.sea700),
            iconBg: AppColors.sea100,
            title: 'Yardım & Destek',
            subtitle: 'Yardım merkezi ve iletişim',
            onTap: () => _openHelp(context),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: AppIcons.logout(size: 20, color: AppColors.red600),
            iconBg: AppColors.red50,
            title: 'Çıkış Yap',
            subtitle: 'Hesabınızdan güvenli çıkış yapın',
            onTap: () => _confirmLogout(context),
          ),
        ],
      );
    },
  );
}

class _ProfileHeaderCard extends StatefulWidget {
  final String fullName;
  final String statusLabel;
  final bool statusActive;
  final String email;
  final String phone;
  final VoidCallback onTap;
  const _ProfileHeaderCard({
    required this.fullName,
    required this.statusLabel,
    required this.statusActive,
    required this.email,
    required this.phone,
    required this.onTap,
  });

  @override
  State<_ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<_ProfileHeaderCard>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _pulseController;
  bool? _animating;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shouldAnimate = !MediaQuery.disableAnimationsOf(context);
    if (_animating == shouldAnimate) return;
    _animating = shouldAnimate;
    if (shouldAnimate) {
      _glowController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: .99,
    onTap: widget.onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.neutral600, AppColors.nearBlack],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .30),
            blurRadius: 28,
            spreadRadius: -12,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_glowController.value);
                return Positioned(
                  right: -34 + 10 * t,
                  top: -34 - 8 * t,
                  child: Transform.scale(
                    scale: .88 + .24 * t,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.brand400.withValues(alpha: .28 + .14 * t),
                            AppColors.brand400.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.brand400, AppColors.brand600],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .18),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _initials(widget.fullName),
                            style: figtree(
                              size: 16,
                              weight: W.extrabold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: figtree(
                                size: 17,
                                weight: W.extrabold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _StatusDot(
                                  active: widget.statusActive,
                                  pulse: _pulseController,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  widget.statusLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: figtree(
                                    size: 12.5,
                                    weight: W.semibold,
                                    color: Colors.white.withValues(alpha: .72),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .14),
                          ),
                        ),
                        child: Center(
                          child: AppIcons.chevronRight(
                            size: 15,
                            color: Colors.white.withValues(alpha: .85),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ContactLine(
                    icon: AppIcons.mail(
                      size: 14,
                      color: Colors.white.withValues(alpha: .5),
                    ),
                    text: widget.email,
                  ),
                  const SizedBox(height: 8),
                  _ContactLine(
                    icon: AppIcons.phone(
                      size: 14,
                      color: Colors.white.withValues(alpha: .5),
                    ),
                    text: widget.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// "Aktif Üye" durumunda yumuşak bir canlı-durum darbesiyle (pulse) nabız
/// gibi atar; pasif üyelikte sabit kalır, animasyon boşuna çalışmaz.
class _StatusDot extends StatelessWidget {
  final bool active;
  final Animation<double> pulse;
  const _StatusDot({required this.active, required this.pulse});

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .32),
          shape: BoxShape.circle,
        ),
      );
    }
    return SizedBox(
      width: 16,
      height: 16,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final t = pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t) * .5,
                child: Transform.scale(
                  scale: .6 + t * 1.8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.brand300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.brand300,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  final Widget icon;
  final String text;
  const _ContactLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      icon,
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: figtree(
            size: 12.5,
            weight: W.semibold,
            color: Colors.white.withValues(alpha: .72),
          ),
        ),
      ),
    ],
  );
}

class _StatItem {
  final Widget icon;
  final String value;
  final String label;
  const _StatItem({required this.icon, required this.value, required this.label});
}

/// Dört özeti tek kartta, aralarında ince dikey çizgilerle ayırarak
/// yan yana sığdırır (bkz. referans görsel) — ayrı kartlar yerine tek
/// satırlık bir özet şeridi.
class _StatsSummaryCard extends StatelessWidget {
  final List<_StatItem> items;
  const _StatsSummaryCard({required this.items});

  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(20),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
    elevated: false,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 40,
              color: AppColors.surfaceBorder,
            ),
          Expanded(child: _StatColumn(item: items[i])),
        ],
      ],
    ),
  );
}

class _StatColumn extends StatelessWidget {
  final _StatItem item;
  const _StatColumn({required this.item});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      item.icon,
      const SizedBox(height: 8),
      Text(
        item.value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: figtree(size: 17, weight: W.extrabold, tracking: Tracking.tight),
      ),
      const SizedBox(height: 3),
      Text(
        item.label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: figtree(size: 9.5, weight: W.semibold, color: AppColors.inkFaint),
      ),
    ],
  );
}

class _MenuCard extends StatelessWidget {
  final Widget icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: .98,
    onTap: onTap,
    child: GlassPanel(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      elevated: false,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: figtree(size: 14.5, weight: W.bold)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          AppIcons.chevronRight(size: 16, color: AppColors.inkFaint),
        ],
      ),
    ),
  );
}

class ProfileInfoScreen extends StatelessWidget {
  final ProfileController profileController;
  const ProfileInfoScreen({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: profileController,
    builder: (context, _) {
      final user = profileController.user;
      final rows = user == null
          ? const <(String, String)>[]
          : [
              ('Ad Soyad', user.fullName),
              ('E-posta', user.email),
              ('Telefon', _formatPhone(user.phone)),
            ];

      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Column(
            children: [
              const ModalHeader(title: 'Kullanıcı Bilgileri'),
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
