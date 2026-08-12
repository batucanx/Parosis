import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/well_bookings/domain/entities/well_booking_request.dart';
import 'package:parosis_sulama/features/well_bookings/presentation/controllers/well_bookings_controller.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/confirm_dialog.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

String _twoDigits(int n) => n.toString().padLeft(2, '0');
String _formatDate(DateTime dt) =>
    '${_twoDigits(dt.day)}.${_twoDigits(dt.month)}.${dt.year}';
String _formatTime(DateTime dt) => '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';

String _statusLabel(WellBookingStatus status) => switch (status) {
  WellBookingStatus.pending => 'Onay Bekliyor',
  WellBookingStatus.approved => 'Onaylandı',
  WellBookingStatus.rejected => 'Reddedildi',
  WellBookingStatus.cancelled => 'İptal',
};

Color _statusColor(WellBookingStatus status) => switch (status) {
  WellBookingStatus.pending => AppColors.amber800,
  WellBookingStatus.approved => AppColors.brand700,
  WellBookingStatus.rejected => AppColors.red600,
  WellBookingStatus.cancelled => AppColors.inkSoft,
};

Color _statusBg(WellBookingStatus status) => switch (status) {
  WellBookingStatus.pending => AppColors.amber50,
  WellBookingStatus.approved => AppColors.brand100,
  WellBookingStatus.rejected => AppColors.red50,
  WellBookingStatus.cancelled => AppColors.slate100,
};

/// "Talepler" ekranının "Randevu Talepleri" sekmesi — bana gelen (onayım
/// gereken) ve benim gönderdiğim randevu taleplerinin durum filtreli listesi.
class WellBookingsTab extends StatefulWidget {
  final WellBookingsController controller;
  const WellBookingsTab({super.key, required this.controller});

  @override
  State<WellBookingsTab> createState() => _WellBookingsTabState();
}

class _WellBookingsTabState extends State<WellBookingsTab> {
  WellBookingStatus? _filter;

  List<WellBookingRequest> _applyFilter(List<WellBookingRequest> items) {
    final filter = _filter;
    if (filter == null) return items;
    return items.where((r) => r.status == filter).toList();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      if (widget.controller.isLoading) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'Randevu talepleri yükleniyor…',
              style: figtree(
                size: 13,
                weight: W.semibold,
                color: AppColors.inkFaint,
              ),
            ),
          ),
        );
      }

      final incoming = _applyFilter(widget.controller.incoming);
      final outgoing = _applyFilter(widget.controller.outgoing);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusFilterRow(
            value: _filter,
            onChanged: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 16),
          _SectionLabel('Kuyularıma Gelen Talepler (${incoming.length})'),
          const SizedBox(height: 10),
          if (incoming.isEmpty)
            const _EmptyNotice(text: 'Henüz talep yok.')
          else
            for (final r in incoming) ...[
              _BookingCard(request: r, controller: widget.controller),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 18),
          _SectionLabel('Taleplerim (${outgoing.length})'),
          const SizedBox(height: 10),
          if (outgoing.isEmpty)
            const _EmptyNotice(text: 'Henüz talep göndermediniz.')
          else
            for (final r in outgoing) ...[
              _BookingCard(request: r, controller: widget.controller),
              const SizedBox(height: 10),
            ],
        ],
      );
    },
  );
}

class _StatusFilterRow extends StatelessWidget {
  final WellBookingStatus? value;
  final ValueChanged<WellBookingStatus?> onChanged;
  const _StatusFilterRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <(String, WellBookingStatus?)>[
      ('Tümü', null),
      ('Onay Bekliyor', WellBookingStatus.pending),
      ('Onaylandı', WellBookingStatus.approved),
      ('Reddedildi', WellBookingStatus.rejected),
      ('İptal', WellBookingStatus.cancelled),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (label, status) in options) ...[
            _FilterChip(
              label: label,
              selected: value == status,
              onTap: () => onChanged(status),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: 0.96,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.nearBlack : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: selected ? null : Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        label,
        style: figtree(
          size: 12.5,
          weight: W.bold,
          color: selected ? Colors.white : AppColors.inkSoft,
        ),
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: figtree(size: 13.5, weight: W.extrabold, color: AppColors.ink),
  );
}

class _EmptyNotice extends StatelessWidget {
  final String text;
  const _EmptyNotice({required this.text});
  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(16),
    elevated: false,
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Center(
      child: Text(
        text,
        style: figtree(size: 12.5, weight: W.medium, color: AppColors.inkFaint),
      ),
    ),
  );
}

class _BookingCard extends StatelessWidget {
  final WellBookingRequest request;
  final WellBookingsController controller;
  const _BookingCard({required this.request, required this.controller});

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.event_busy_rounded,
      title: 'Talebi İptal Et',
      message:
          '${request.wellName} için gönderdiğiniz randevu talebini iptal '
          'etmek istediğinizden emin misiniz?',
      confirmLabel: 'Evet, İptal Et',
    );
    if (confirmed) controller.cancel(request.id);
  }

  bool get _sameDay =>
      request.start.year == request.end.year &&
      request.start.month == request.end.month &&
      request.start.day == request.end.day;

  String get _timeRangeLabel => _sameDay
      ? '${_formatDate(request.start)} · ${_formatTime(request.start)} - ${_formatTime(request.end)}'
      : '${_formatDate(request.start)} ${_formatTime(request.start)} → '
            '${_formatDate(request.end)} ${_formatTime(request.end)}';

  @override
  Widget build(BuildContext context) {
    final isIncoming = request.direction == WellBookingDirection.incoming;
    final canAct = request.status == WellBookingStatus.pending;

    return GlassPanel(
      borderRadius: BorderRadius.circular(17),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.sea100.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Icon(
                    isIncoming
                        ? Icons.call_received_rounded
                        : Icons.call_made_rounded,
                    size: 16,
                    color: AppColors.sea700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.wellName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtree(size: 13.5, weight: W.extrabold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeRangeLabel,
                      style: figtree(
                        size: 11,
                        weight: W.semibold,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIncoming
                          ? 'Talep eden: ${request.counterpartName}'
                          : 'Kuyu sahibi: ${request.counterpartName}',
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(request.status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(request.status),
                  style: figtree(
                    size: 10,
                    weight: W.extrabold,
                    color: _statusColor(request.status),
                  ),
                ),
              ),
            ],
          ),
          if (canAct) ...[
            const SizedBox(height: 10),
            if (isIncoming)
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Reddet',
                      onTap: () =>
                          controller.respond(id: request.id, approve: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Onayla',
                      isPrimary: true,
                      onTap: () =>
                          controller.respond(id: request.id, approve: true),
                    ),
                  ),
                ],
              )
            else
              _ActionButton(
                label: 'Talebi İptal Et',
                onTap: () => _confirmCancel(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: 0.97,
    onTap: onTap,
    child: Container(
      height: 38,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.brand700 : AppColors.slate100,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          label,
          style: figtree(
            size: 12,
            weight: W.bold,
            color: isPrimary ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    ),
  );
}
