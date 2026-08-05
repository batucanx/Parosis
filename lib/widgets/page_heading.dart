import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Alt sayfa başlığı. Geri navigasyonu ortak AppHeader tarafından yönetilir.
class PageHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: figtree(
              size: 21,
              weight: W.extrabold,
              color: AppColors.ink,
              tracking: Tracking.tight,
              height: 1.15,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: figtree(
                size: 13,
                weight: W.medium,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
