import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/mock_data.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'pressable_scale.dart';

/// Üst çubuk: ana ekranlarda hamburger, alt ekranlarda geri; ortada logo,
/// sağda bakiye.
class AppHeader extends StatelessWidget {
  final int balance;
  final VoidCallback onBalanceTap;
  final VoidCallback onMenuTap;
  final VoidCallback onBackTap;
  final bool showBackButton;

  const AppHeader({
    super.key,
    required this.balance,
    required this.onBalanceTap,
    required this.onMenuTap,
    required this.onBackTap,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  label: showBackButton ? 'Geri' : 'Hızlı erişim menüsünü aç',
                  child: Tooltip(
                    message: showBackButton ? 'Geri' : 'Hızlı erişim',
                    child: PressableScale(
                      scale: 0.9,
                      onTap: showBackButton ? onBackTap : onMenuTap,
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                ),
                            child: showBackButton
                                ? KeyedSubtree(
                                    key: const ValueKey('back'),
                                    child: AppIcons.arrowLeft(
                                      size: 24,
                                      color: AppColors.brand700,
                                    ),
                                  )
                                : KeyedSubtree(
                                    key: const ValueKey('menu'),
                                    child: AppIcons.menu(
                                      size: 24,
                                      color: AppColors.brand700,
                                      strokeWidth: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                PressableScale(
                  scale: 0.95,
                  onTap: onBalanceTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcons.wallet(size: 18, color: AppColors.brand600),
                      const SizedBox(width: 6),
                      Text(
                        '${formatTL(balance)} ₺',
                        style: figtree(
                          size: 14,
                          weight: W.extrabold,
                          color: AppColors.ink,
                          tracking: Tracking.tight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            IgnorePointer(
              child: SvgPicture.asset('assets/icons/logo.svg', height: 34),
            ),
          ],
        ),
      ),
    );
  }
}

const _menuItems = [
  (
    icon: 'droplets',
    label: 'Kuyu Taleplerim',
    desc: 'Açık ve bekleyen talepleriniz',
    color: AppColors.brand700,
    bg: AppColors.brand100,
  ),
  (
    icon: 'listChecks',
    label: 'Talepler',
    desc: 'Tüm sulama talepleri',
    color: AppColors.sea700,
    bg: AppColors.sea100,
  ),
  (
    icon: 'history',
    label: 'Geçmiş Sulamalar',
    desc: 'Tamamlanan sulama kayıtları',
    color: AppColors.mist600,
    bg: AppColors.mist100,
  ),
];

Widget _menuIcon(String key, {required double size, required Color color}) {
  switch (key) {
    case 'droplets':
      return AppIcons.droplets(size: size, color: color);
    case 'listChecks':
      return AppIcons.listChecks(size: size, color: color);
    default:
      return AppIcons.history(size: size, color: color);
  }
}

/// Tam ekran hızlı erişim menüsü — AppRoot'un kök Stack'inde overlay olarak render edilir.
class AppDrawerOverlay extends StatelessWidget {
  final VoidCallback onClose;
  const AppDrawerOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sheetBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/logo.svg', height: 44),
                const Spacer(),
                PressableScale(
                  onTap: onClose,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcons.x(size: 18, color: AppColors.inkSoft),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (var i = 0; i < _menuItems.length; i++)
                  _MenuRow(
                    item: _menuItems[i],
                    isLast: i == _menuItems.length - 1,
                    onTap: onClose,
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            width: double.infinity,
            child: Text(
              'Sulama Yönetim Sistemi v1.0',
              textAlign: TextAlign.center,
              style: figtree(
                size: 11.5,
                weight: W.medium,
                color: AppColors.inkFaint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final ({String icon, String label, String desc, Color color, Color bg}) item;
  final bool isLast;
  final VoidCallback onTap;
  const _MenuRow({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.07),
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: item.bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _menuIcon(item.icon, size: 20, color: item.color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: figtree(
                      size: 15,
                      weight: W.bold,
                      color: AppColors.ink,
                      tracking: Tracking.tight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.desc,
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
}
