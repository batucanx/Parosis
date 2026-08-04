import 'package:flutter/material.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'glass.dart';
import 'pressable_scale.dart';

/// Alt sayfalarda büyük "Geri" hedefi + sayfa başlığı.
class PageHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const PageHeading({super.key, required this.title, this.subtitle, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PressableScale(
            scale: 0.95,
            onTap: onBack,
            child: GlassSoft(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 56,
                width: 56,
                child: Center(child: AppIcons.arrowLeft(size: 28, color: AppColors.ink)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: figtree(size: 21, weight: W.extrabold, color: AppColors.ink, tracking: Tracking.tight, height: 1.15),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: figtree(size: 13, weight: W.medium, color: AppColors.inkSoft),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
