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
String _formatDayMonth(DateTime dt) =>
    '${_twoDigits(dt.day)}.${_twoDigits(dt.month)}';
String _formatTime(DateTime dt) =>
    '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';

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

class _DayGroup {
  final DateTime date;
  final List<PastIrrigation> sessions;
  const _DayGroup({required this.date, required this.sessions});

  Duration get totalDuration =>
      sessions.fold(Duration.zero, (sum, s) => sum + s.duration);

  Map<String, List<PastIrrigation>> get sessionsByPerson {
    final map = <String, List<PastIrrigation>>{};
    for (final s in sessions) {
      (map[s.personName] ??= []).add(s);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
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
  final days =
      map.entries.map((e) => _DayGroup(date: e.key, sessions: e.value)).toList()
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
              _HistoryWellCard(
                well: well,
                onTap: () => widget.onSelectWell(well),
              ),
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

  Future<void> _pickDate(List<_DayGroup> days) async {
    if (days.isEmpty) return;
    final firstDate = days.first.date;
    final lastDate = days.last.date;
    final initialDate =
        _highlightedDay != null &&
            !_highlightedDay!.isBefore(firstDate) &&
            !_highlightedDay!.isAfter(lastDate)
        ? _highlightedDay!
        : lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null || !mounted) return;

    final match = days.where((d) => _isSameDay(d.date, picked)).firstOrNull;
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_formatDayMonth(picked)} tarihinde sulama kaydı yok.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _detailExpanded = true;
      _highlightedDay = match.date;
    });
    await _showDayDetailSheet(context, match);
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
                  Expanded(
                    child: _StatTile(label: 'GÜN', value: '${days.length}'),
                  ),
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
              _FilterActionsRow(
                expanded: _detailExpanded,
                onDateTap: () => _pickDate(days),
                onToggleTap: () =>
                    setState(() => _detailExpanded = !_detailExpanded),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                ),
                child: _detailExpanded
                    ? Column(
                        key: const ValueKey('day-detail-list'),
                        children: [
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
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('day-detail-list-empty'),
                      ),
              ),
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
          style: figtree(
            size: 20,
            weight: W.extrabold,
            color: valueColor ?? AppColors.ink,
          ),
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
  static const _axisSteps = [
    1,
    2,
    3,
    6,
    12,
    18,
    24,
    36,
    48,
    72,
    96,
    120,
    168,
    240,
  ];

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
                      Text(
                        '${(axisMax / 2).toInt()} sa',
                        style: axisLabelStyle,
                      ),
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
                            weight:
                                _isSameDay(
                                  day.date,
                                  selectedDay ?? DateTime(1970),
                                )
                                ? W.extrabold
                                : W.semibold,
                            color:
                                _isSameDay(
                                  day.date,
                                  selectedDay ?? DateTime(1970),
                                )
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

class _FilterActionsRow extends StatelessWidget {
  final bool expanded;
  final VoidCallback onDateTap;
  final VoidCallback onToggleTap;
  const _FilterActionsRow({
    required this.expanded,
    required this.onDateTap,
    required this.onToggleTap,
  });

  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeOutCubic;
  static const _toggleWidth = 158.0;
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 46,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final toggleWidth = _toggleWidth.clamp(0.0, totalWidth);
        final reserved = (toggleWidth + _gap).clamp(0.0, totalWidth);
        return Stack(
          children: [
            AnimatedPositioned(
              duration: _duration,
              curve: _curve,
              top: 0,
              bottom: 0,
              left: 0,
              right: expanded ? reserved : totalWidth,
              child: ClipRect(
                child: AnimatedOpacity(
                  duration: _duration,
                  curve: _curve,
                  opacity: expanded ? 1 : 0,
                  child: _DateFilterButton(onTap: onDateTap),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: _duration,
              curve: _curve,
              top: 0,
              bottom: 0,
              left: expanded ? totalWidth - toggleWidth : 0,
              right: 0,
              child: _DetailToggle(expanded: expanded, onTap: onToggleTap),
            ),
          ],
        );
      },
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

class _DateFilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DateFilterButton({required this.onTap});

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
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: AppColors.inkSoft,
            ),
            const SizedBox(width: 8),
            Text(
              'Tarih Filtrele',
              style: figtree(
                size: 13,
                weight: W.bold,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showDayDetailSheet(BuildContext context, _DayGroup day) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _DayDetailSheet(day: day),
  );
}

class _DayDetailCard extends StatelessWidget {
  final _DayGroup day;
  final bool highlighted;
  const _DayDetailCard({
    super.key,
    required this.day,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.brand400 : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: PressableScale(
        scale: .98,
        onTap: () => _showDayDetailSheet(context, day),
        child: GlassPanel(
          borderRadius: BorderRadius.circular(16),
          elevated: false,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
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
              const Spacer(),
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
              const SizedBox(width: 10),
              AppIcons.chevronRight(size: 14, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final _DayGroup day;
  const _DayDetailSheet({required this.day});

  @override
  Widget build(BuildContext context) {
    final byPerson = day.sessionsByPerson;
    final people = byPerson.keys.toList()
      ..sort((a, b) {
        Duration totalOf(String name) =>
            byPerson[name]!.fold(Duration.zero, (sum, s) => sum + s.duration);
        return totalOf(b).compareTo(totalOf(a));
      });

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weekdayLabel(day.date)} ${_formatDayMonth(day.date)}',
                          style: figtree(size: 16, weight: W.extrabold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.sessions.length} oturum',
                          style: figtree(
                            size: 12,
                            weight: W.medium,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          size: 15,
                          weight: W.extrabold,
                          color: AppColors.brand600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  for (final person in people) ...[
                    _PersonSessionGroup(
                      name: person,
                      sessions: byPerson[person]!,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonSessionGroup extends StatelessWidget {
  final String name;
  final List<PastIrrigation> sessions;
  const _PersonSessionGroup({required this.name, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final total = sessions.fold(Duration.zero, (sum, s) => sum + s.duration);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: figtree(
                    size: 12.5,
                    weight: W.extrabold,
                    tracking: Tracking.tight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(total),
                style: figtree(
                  size: 12.5,
                  weight: W.extrabold,
                  color: AppColors.brand600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final session in sessions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: AppColors.inkFaint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(session.occurredAt),
                    style: figtree(
                      size: 12,
                      weight: W.semibold,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDuration(session.duration),
                    style: figtree(size: 12, weight: W.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
