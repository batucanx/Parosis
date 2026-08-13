import 'package:flutter/material.dart';

import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool enabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return PressableScale(
      disabled: !active,
      onTap: active ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.nearBlack
              : AppColors.mist200.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 18,
                    spreadRadius: -8,
                    offset: const Offset(0, 9),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: figtree(
                          size: 15,
                          weight: W.extrabold,
                          color: active ? Colors.white : AppColors.mist600,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class AuthTonalButton extends StatelessWidget {
  const AuthTonalButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: 0.98,
    onTap: onTap,
    child: Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand700, width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: figtree(
            size: 14.5,
            weight: W.extrabold,
            color: AppColors.brand700,
          ),
        ),
      ),
    ),
  );
}

class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: 0.98,
    onTap: onTap,
    child: Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4285F4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            spreadRadius: -6,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Text(
            label,
            style: figtree(size: 14, weight: W.bold, color: AppColors.ink),
          ),
        ],
      ),
    ),
  );
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: AppColors.surfaceBorder, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'veya',
          style: figtree(
            size: 12,
            weight: W.semibold,
            color: AppColors.inkFaint,
          ),
        ),
      ),
      Expanded(child: Divider(color: AppColors.surfaceBorder, thickness: 1)),
    ],
  );
}
