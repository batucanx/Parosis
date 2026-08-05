import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// index.css `sheetUp`/`slideUp` — navbar alanından yukarı kayarak gelen
/// tam ekran bottom sheet. ProfileInfoSheet ve CardsModal bunu paylaşır.
class OverlaySheet extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;

  const OverlaySheet({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (context, value, sheet) => Transform.translate(
                offset: Offset(0, value * MediaQuery.sizeOf(context).height),
                child: sheet,
              ),
              child: Container(
                height: MediaQuery.sizeOf(context).height - 54,
                decoration: const BoxDecoration(
                  color: AppColors.sheetBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(29)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: figtree(size: 17, weight: W.extrabold),
                            ),
                          ),
                          IconButton(
                            onPressed: onClose,
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
