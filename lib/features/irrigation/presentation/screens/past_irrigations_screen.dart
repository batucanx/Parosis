import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/irrigation/domain/entities/past_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:parosis_sulama/features/wells/domain/entities/well.dart';
import 'package:parosis_sulama/features/wells/presentation/controllers/wells_controller.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/marquee_text.dart';
import 'package:parosis_sulama/widgets/page_heading.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

String _twoDigits(int n) => n.toString().padLeft(2, '0');
String _formatDayMonth(DateTime dt) => '${_twoDigits(dt.day)}.${_twoDigits(dt.month)}';

const _weekdayLabels = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];
String _weekdayLabel(DateTime dt) => _weekdayLabels[dt.weekday - 1];

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h == 0) return '$m dk';
  if (m == 0) return '$h sa';
  return '$h sa $m dk';
}

/// Bir kuyunun bir günündeki tüm oturumlarının gruplanmış hâli — "Günlük
/// Toplam Kullanım" grafiği ve "Detayı göster" listesi bu birimi kullanır.
class _DayGroup {
  final DateTime date;
  final List<PastIrrigation> sessions;
  const _DayGroup({required this.date, required this.sessions});

  Duration get totalDuration =>
      sessions.fold(Duration.zero, (sum, s) => sum + s.duration);

  Map<String, Duration> get byPerson {
    final map = <String, Duration>{};
    for (final s in sessions) {
      map[s.personName] = (map[s.personName] ?? Duration.zero) + s.duration;
    }
    return map;
  }
}

List<_DayGroup> _groupByDay(List<PastIrrigation> sessions) {
  final map = <DateTime, List<PastIrrigation>>{};
  for (final s in sessions) {
    final day = DateTime(
      s.occurredAt.year,
      s.occurredAt.month,
      s.occurredAt.day,
    );
    (map[day] ??= []).add(s);
  }
  final days = map.entries
      .map((e) => _DayGroup(date: e.key, sessions: e.value))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return days;
}

class _CenteredNotice extends StatelessWidget {
  final String text;
  const _CenteredNotice({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Center(
      child: Text(
        text,
        style: figtree(size: 13, weight: W.semibold, color: AppColors.inkFaint),
      ),
    ),
  );
}

/// Hamburger menüden açılan "Geçmiş Sulamalar" akışının ilk adımı — kuyu
/// seçilince [onSelectWell] ile detay ekranına geçilir.
class PastIrrigationsScreen extends StatefulWidget {
  final WellsController wellsController;
  final IrrigationController irrigationController;
  final ValueChanged<Well> onSelectWell;
  const PastIrrigationsScreen({
    super.key,
    required this.wellsController,
    required this.irrigationController,
    required this.onSelectWell,
  });

  @override
  State<PastIrrigationsScreen> createState() => _PastIrrigationsScreenState();
}

class _PastIrrigationsScreenState extends State<PastIrrigationsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      widget.wellsController,
      widget.irrigationController,
    ]),
    builder: (context, _) {
      final wells = widget.wellsController.wells;
      final q = _query.trim().toLowerCase();
      final results = q.isEmpty
          ? wells
          : wells
                .where(
                  (w) => '${w.name} ${w.province} ${w.district}'
                      .toLowerCase()
                      .contains(q),
                )
                .toList();

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
        children: [
          PageHeading(
            title: 'Geçmiş Sulamalar',
            subtitle: 'Bir kuyu seç, o kuyunun tüm geçmiş sulamalarını gör.',
          ),
          const SizedBox(height: 20),
          GlassPanel(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            elevated: false,
            child: SizedBox(
              height: 46,
              child: Row(
                children: [
                  AppIcons.search(size: 18, color: AppColors.inkFaint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: figtree(size: 14, weight: W.semibold),
                      decoration: InputDecoration(
                        hintText: 'Kuyu Ara',
                        hintStyle: figtree(
                          size: 14,
                          weight: W.medium,
                          color: AppColors.inkFaint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (widget.wellsController.isLoading)
            const _CenteredNotice(text: 'Kuyular yükleniyor…')
          else if (results.isEmpty)
            GlassPanel(
              borderRadius: BorderRadius.circular(21),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  Text(
                    wells.isEmpty ? 'Henüz kuyunuz yok' : 'Kuyu bulunamadı',
                    style: figtree(size: 14, weight: W.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wells.isEmpty
                        ? 'Kuyu talebiniz onaylandığında burada görünecek.'
                        : 'Farklı bir isim veya ilçe deneyin.',
                    textAlign: TextAlign.center,
                    style: figtree(
                      size: 12.5,
                      weight: W.medium,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final well in results) ...[
              _HistoryWellCard(well: well, onTap: () => widget.onSelectWell(well)),
              const SizedBox(height: 12),
            ],
        ],
      );
    },
  );
}

class _HistoryWellCard extends StatelessWidget {
  final Well well;
  final VoidCallback onTap;
  const _HistoryWellCard({required this.well, required this.onTap});

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: .98,
    onTap: onTap,
    child: GlassPanel(
      borderRadius: BorderRadius.circular(19),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.mist100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AppIcons.droplet(size: 18, color: AppColors.mist600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarqueeText(
                  key: ValueKey('history-well-${well.id}'),
                  text: well.name,
                  style: figtree(
                    size: 15,
                    weight: W.extrabold,
                    tracking: Tracking.tight,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    AppIcons.mapPin(size: 11, color: AppColors.inkSoft),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${well.province} / ${well.district}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: figtree(
                          size: 11.5,
                          weight: W.semibold,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppIcons.chevronRight(size: 16, color: AppColors.inkFaint),
        ],
      ),
    ),
  );
}

/// Seçilen kuyunun tüm geçmiş sulama dökümü — GÜN/TOPLAM KULLANIM özeti,
/// günlük kullanım grafiği ve açılır/kapanır kişi bazlı detay listesi.
/// Geri navigasyonu ortak AppHeader yönettiği için ayrı bir "kuyu değiştir"
/// butonu yok.
class PastIrrigationDetailScreen extends StatefulWidget {
  final WellsController wellsController;
  final IrrigationController irrigationController;
  final String? wellId;
  const PastIrrigationDetailScreen({
    super.key,
    required this.wellsController,
    required this.irrigationController,
    required this.wellId,
  });

  @override
  State<PastIrrigationDetailScreen> createState() =>
      _PastIrrigationDetailScreenState();
}

class _PastIrrigationDetailScreenState
    extends State<PastIrrigationDetailScreen> {
  bool _detailExpanded = false;
  DateTime? _highlightedDay;

  Well? get _well {
    final id = widget.wellId;
    return id == null ? null : widget.wellsController.byId(id);
  }

  void _onBarTap(DateTime day) {
    setState(() {
      _detailExpanded = true;
      _highlightedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final well = _well;
    if (well == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
        children: [
          const PageHeading(
            title: 'Geçmiş Sulamalar',
            subtitle: 'Kuyu bulunamadı.',
          ),
        ],
      );
    }

    return ListenableBuilder(
      listenable: widget.irrigationController,
      builder: (context, _) {
        final sessions =
            widget.irrigationController.past
                .where((p) => p.wellId == well.id)
                .toList()
              ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

        final days = _groupByDay(sessions);
        final totalDuration = sessions.fold<Duration>(
          Duration.zero,
          (sum, s) => sum + s.duration,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
          children: [
            PageHeading(
              title: well.name,
              subtitle: '${well.province} / ${well.district}',
            ),
            const SizedBox(height: 20),
            if (widget.irrigationController.isLoading)
              const _CenteredNotice(text: 'Geçmiş sulamalar yükleniyor…')
            else if (sessions.isEmpty)
              GlassPanel(
                borderRadius: BorderRadius.circular(21),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Center(
                  child: Text(
                    'Bu kuyu için geçmiş sulama kaydı yok.',
                    style: figtree(
                      size: 13,
                      weight: W.semibold,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(child: _StatTile(label: 'GÜN', value: '${days.length}')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: 'TOPLAM KULLANIM',
                      value: _formatDuration(totalDuration),
                      valueColor: AppColors.brand600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DailyUsageChart(
                days: days,
                selectedDay: _highlightedDay,
                onBarTap: _onBarTap,
              ),
              const SizedBox(height: 14),
              _DetailToggle(
                expanded: _detailExpanded,
                onTap: () => setState(() => _detailExpanded = !_detailExpanded),
              ),
              if (_detailExpanded) ...[
                const SizedBox(height: 12),
                for (final day in days.reversed) ...[
                  _DayDetailCard(
                    key: ValueKey(day.date),
                    day: day,
                    highlighted:
                        _highlightedDay != null &&
                        _isSameDay(day.date, _highlightedDay!),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(18),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    elevated: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: figtree(
            size: 10.5,
            weight: W.extrabold,
            color: AppColors.inkFaint,
            tracking: Tracking.wide,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: figtree(size: 20, weight: W.extrabold, color: valueColor ?? AppColors.ink),
        ),
      ],
    ),
  );
}

class _DailyUsageChart extends StatelessWidget {
  final List<_DayGroup> days;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onBarTap;
  const _DailyUsageChart({
    required this.days,
    required this.selectedDay,
    required this.onBarTap,
  });

  static const _chartHeight = 140.0;
  static const _axisSteps = [1, 2, 3, 6, 12, 18, 24, 36, 48, 72, 96, 120, 168, 240];

  double _niceAxisMax(double maxHours) {
    if (maxHours <= 0) return 1;
    for (final step in _axisSteps) {
      if (maxHours <= step) return step.toDouble();
    }
    return (maxHours / 24).ceil() * 24.0;
  }

  @override
  Widget build(BuildContext context) {
    final maxHours = days.fold<double>(0, (max, d) {
      final hours = d.totalDuration.inMinutes / 60.0;
      return hours > max ? hours : max;
    });
    final axisMax = _niceAxisMax(maxHours);
    final axisLabelStyle = figtree(
      size: 9.5,
      weight: W.semibold,
      color: AppColors.inkFaint,
    );

    final selectedGroup = selectedDay == null
        ? null
        : days.where((d) => _isSameDay(d.date, selectedDay!)).firstOrNull;

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Günlük Toplam Kullanım',
                  style: figtree(size: 13.5, weight: W.extrabold),
                ),
              ),
              Flexible(
                flex: 2,
                child: Text(
                  selectedGroup == null
                      ? 'bir güne dokun'
                      : '${_formatDayMonth(selectedGroup.date)} '
                            '${_weekdayLabel(selectedGroup.date)} · '
                            '${_formatDuration(selectedGroup.totalDuration)}',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: figtree(
                    size: 10.5,
                    weight: selectedGroup == null ? W.medium : W.bold,
                    color: selectedGroup == null
                        ? AppColors.inkFaint
                        : AppColors.brand700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: _chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 34,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${axisMax.toInt()} sa', style: axisLabelStyle),
                      Text('${(axisMax / 2).toInt()} sa', style: axisLabelStyle),
                      Text('0', style: axisLabelStyle),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final day in days)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _DayBar(
                              heightFactor:
                                  (day.totalDuration.inMinutes / 60.0) /
                                  axisMax,
                              selected: _isSameDay(
                                day.date,
                                selectedDay ?? DateTime(1970),
                              ),
                              onTap: () => onBarTap(day.date),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 42),
              Expanded(
                child: Row(
                  children: [
                    for (final day in days)
                      Expanded(
                        child: Text(
                          _formatDayMonth(day.date),
                          textAlign: TextAlign.center,
                          style: figtree(
                            size: 9.5,
                            weight: _isSameDay(day.date, selectedDay ?? DateTime(1970))
                                ? W.extrabold
                                : W.semibold,
                            color: _isSameDay(day.date, selectedDay ?? DateTime(1970))
                                ? AppColors.brand700
                                : AppColors.inkFaint,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final double heightFactor;
  final bool selected;
  final VoidCallback onTap;
  const _DayBar({
    required this.heightFactor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: .92,
    onTap: onTap,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: heightFactor.clamp(0.02, 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand700 : AppColors.brand300,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
      ),
    ),
  );
}

class _DetailToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _DetailToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: .98,
    onTap: onTap,
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.inkSoft,
          ),
          const SizedBox(width: 6),
          Text(
            expanded ? 'Detayı gizle' : 'Detayı göster',
            style: figtree(size: 13, weight: W.bold, color: AppColors.inkSoft),
          ),
        ],
      ),
    ),
  );
}

class _DayDetailCard extends StatelessWidget {
  final _DayGroup day;
  final bool highlighted;
  const _DayDetailCard({super.key, required this.day, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final byPerson = day.byPerson;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.brand400 : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: GlassPanel(
        borderRadius: BorderRadius.circular(16),
        elevated: false,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 46,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weekdayLabel(day.date),
                    style: figtree(
                      size: 10,
                      weight: W.extrabold,
                      color: AppColors.inkFaint,
                      tracking: Tracking.wide,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDayMonth(day.date),
                    style: figtree(size: 13, weight: W.extrabold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final entry in byPerson.entries)
                        _PersonBadge(name: entry.key, duration: entry.value),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${day.sessions.length} oturum',
                    style: figtree(
                      size: 11,
                      weight: W.medium,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TOPLAM',
                  style: figtree(
                    size: 9.5,
                    weight: W.extrabold,
                    color: AppColors.inkFaint,
                    tracking: Tracking.wide,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDuration(day.totalDuration),
                  style: figtree(
                    size: 13.5,
                    weight: W.extrabold,
                    color: AppColors.brand600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonBadge extends StatelessWidget {
  final String name;
  final Duration duration;
  const _PersonBadge({required this.name, required this.duration});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.slate100,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '${name.toUpperCase()}: ${_formatDuration(duration)}',
      style: figtree(size: 10.5, weight: W.bold, color: AppColors.inkSoft),
    ),
  );
}
