import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/well_requests/domain/entities/well_request.dart';
import 'package:parosis_sulama/features/well_requests/presentation/controllers/well_requests_controller.dart';
import 'package:parosis_sulama/features/well_requests/presentation/screens/well_request_form_screen.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';
import 'package:parosis_sulama/widgets/slide_up_page_route.dart';

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String _formatDateTime(DateTime dt) =>
    '${_twoDigits(dt.day)}.${_twoDigits(dt.month)}.${dt.year} '
    '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';

String _statusLabel(WellRequestStatus status) => switch (status) {
  WellRequestStatus.pending => 'Onay Bekliyor',
  WellRequestStatus.approved => 'Onaylandı',
  WellRequestStatus.rejected => 'Reddedildi',
};

Color _statusColor(WellRequestStatus status) => switch (status) {
  WellRequestStatus.pending => AppColors.amber800,
  WellRequestStatus.approved => AppColors.brand700,
  WellRequestStatus.rejected => AppColors.red600,
};

Color _statusBg(WellRequestStatus status) => switch (status) {
  WellRequestStatus.pending => AppColors.amber50,
  WellRequestStatus.approved => AppColors.brand100,
  WellRequestStatus.rejected => AppColors.red50,
};

class WellRequestsTab extends StatelessWidget {
  final WellRequestsController controller;
  const WellRequestsTab({super.key, required this.controller});

  Future<void> _openNew(BuildContext context) async {
    await Navigator.of(context).push<WellRequest>(
      SlideUpPageRoute(
        builder: (_) => WellRequestFormScreen(controller: controller),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, WellRequest request) async {
    await Navigator.of(context).push<WellRequest>(
      SlideUpPageRoute(
        builder: (_) =>
            WellRequestFormScreen(controller: controller, existing: request),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WellRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Talebi silmek istiyor musunuz?',
          style: figtree(size: 18, weight: W.extrabold),
        ),
        content: Text(
          '"${request.name}" talebi kaldırılacak. Bu işlem geri alınamaz.',
          style: figtree(size: 14, weight: W.medium, color: AppColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Vazgeç',
              style: figtree(
                size: 14,
                weight: W.bold,
                color: AppColors.inkSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Sil',
              style: figtree(
                size: 14,
                weight: W.extrabold,
                color: AppColors.red600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteRequest(request.id);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: 'Yeni kuyu talebi oluştur',
            child: PressableScale(
              onTap: () => _openNew(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand700,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand800.withValues(alpha: 0.28),
                      blurRadius: 16,
                      spreadRadius: -8,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yeni Kuyu Talebi',
                            style: figtree(
                              size: 14.5,
                              weight: W.extrabold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kuyu bilgilerini gir, onaya gönder',
                            style: figtree(
                              size: 11.5,
                              weight: W.medium,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (controller.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Talepler yükleniyor…',
                  style: figtree(
                    size: 13,
                    weight: W.semibold,
                    color: AppColors.inkFaint,
                  ),
                ),
              ),
            )
          else if (controller.requests.isEmpty)
            _EmptyRequestsState()
          else
            for (final request in controller.requests) ...[
              _WellRequestCard(
                request: request,
                onEdit: () => _openEdit(context, request),
                onDelete: () => _confirmDelete(context, request),
              ),
              const SizedBox(height: 12),
            ],
        ],
      );
    },
  );
}

class _EmptyRequestsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.brand100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: AppIcons.droplets(size: 24, color: AppColors.brand700),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Henüz kuyu talebiniz yok',
          style: figtree(size: 14.5, weight: W.extrabold),
        ),
        const SizedBox(height: 4),
        Text(
          'Yeni bir kuyu kaydettirmek için yukarıdan başlayın.',
          textAlign: TextAlign.center,
          style: figtree(
            size: 12.5,
            weight: W.medium,
            color: AppColors.inkSoft,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _WellRequestCard extends StatelessWidget {
  final WellRequest request;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _WellRequestCard({
    required this.request,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final canEdit = request.status == WellRequestStatus.pending;
    return GlassPanel(
      borderRadius: BorderRadius.circular(19),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brand100.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppIcons.droplet(size: 18, color: AppColors.brand700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtree(size: 14.5, weight: W.extrabold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      request.locationLabel,
                      style: figtree(
                        size: 11.5,
                        weight: W.semibold,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(request.createdAt),
                      style: figtree(
                        size: 10.5,
                        weight: W.medium,
                        color: AppColors.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusBg(request.status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(request.status),
                  style: figtree(
                    size: 10.5,
                    weight: W.extrabold,
                    color: _statusColor(request.status),
                  ),
                ),
              ),
            ],
          ),
          if (canEdit) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                    scale: 0.98,
                    onTap: onEdit,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.mist600,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          'Düzenle',
                          style: figtree(
                            size: 13,
                            weight: W.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  button: true,
                  label: '${request.name} talebini sil',
                  child: PressableScale(
                    scale: 0.9,
                    onTap: onDelete,
                    child: Container(
                      height: 42,
                      width: 52,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          'Sil',
                          style: figtree(
                            size: 13,
                            weight: W.bold,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
