import 'package:flutter/material.dart';

import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

/// Modal olarak (bkz. `SlideUpPageRoute`) açılan alt ekranların ortak
/// başlık çubuğu: geri butonu + başlık, `AppHeader`'dan bağımsız.
class ModalHeader extends StatelessWidget {
  final String title;
  const ModalHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
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
                  child: AppIcons.arrowLeft(size: 25, color: AppColors.ink),
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
  );
}
