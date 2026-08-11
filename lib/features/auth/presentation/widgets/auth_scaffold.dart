import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/screen_in.dart';

/// Login, kayıt ve şifremi-unuttum ekranlarının ortak iskeleti: marka
/// başlığı + beyaz kart + telif hakkı satırı. İçerik klavye açıldığında
/// kaydırılabilir kalır, boş alanda dikey ortalanır.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ScreenIn(
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _AuthBrandHeader(),
              const SizedBox(height: 26),
              GlassPanel(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: child,
              ),
              const SizedBox(height: 18),
              const _AuthFooter(),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand700.withValues(alpha: 0.26),
              blurRadius: 22,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SvgPicture.asset(
            'assets/icons/parosis_mark.svg',
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        'Parosis',
        style: figtree(
          size: 30,
          weight: W.extrabold,
          color: AppColors.brand700,
          tracking: Tracking.tight,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Divider(color: AppColors.surfaceBorder, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'UZAKTAN KONTROL SİSTEMLERİ',
              style: figtree(
                size: 10.5,
                weight: W.bold,
                color: AppColors.inkFaint,
                tracking: Tracking.widest,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: AppColors.surfaceBorder, thickness: 1),
          ),
        ],
      ),
    ],
  );
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter();

  @override
  Widget build(BuildContext context) => Text(
    '© ${DateTime.now().year} Parosis Uzaktan Kontrol Sistemleri. '
    'Tüm hakları saklıdır. — Created by Corwus',
    textAlign: TextAlign.center,
    style: figtree(size: 10.5, weight: W.medium, color: AppColors.inkFaint),
  );
}
