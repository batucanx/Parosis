import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'pressable_scale.dart';

/// Geri alınamaz/hassas eylemlerden önce (talep iptali, sulama durdurma,
/// çıkış yapma vb.) kullanıcıya "emin misiniz?" diye soran, tüm uygulamada
/// aynı görünüme sahip onay diyaloğu. `showDialog<bool>` ile açılır — true
/// dönerse eylem onaylanmış demektir.
class ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  const ConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Vazgeç',
  });

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.red50,
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, color: AppColors.red600, size: 26)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: figtree(size: 16, weight: W.extrabold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: figtree(
              size: 13,
              weight: W.medium,
              color: AppColors.inkSoft,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  scale: .97,
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.surfaceBorder),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        cancelLabel,
                        style: figtree(
                          size: 13.5,
                          weight: W.bold,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PressableScale(
                  scale: .97,
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.red600,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        confirmLabel,
                        style: figtree(
                          size: 13.5,
                          weight: W.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// [ConfirmDialog]'u açıp kullanıcının onayını bekler; onaylarsa true döner.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Vazgeç',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDialog(
      icon: icon,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
  return confirmed == true;
}
