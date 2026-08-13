import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';
import 'package:parosis_sulama/widgets/screen_in.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.onBack});

  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ScreenIn(
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          SingleChildScrollView(
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
          if (onBack != null)
            Positioned(top: 4, left: 4, child: _AuthBackButton(onTap: onBack!)),
        ],
      ),
    ),
  );
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Geri',
    child: Tooltip(
      message: 'Geri',
      child: PressableScale(
        scale: 0.9,
        onTap: onTap,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Center(
            child: AppIcons.arrowLeft(size: 24, color: AppColors.brand700),
          ),
        ),
      ),
    ),
  );
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) => Container(
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
