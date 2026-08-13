import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_schedule_entry.dart';
import 'package:parosis_sulama/features/well_bookings/presentation/controllers/well_bookings_controller.dart';
import 'package:parosis_sulama/features/wells/domain/entities/well.dart';
import 'package:parosis_sulama/features/wells/presentation/controllers/wells_controller.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/confirm_dialog.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/marquee_text.dart';
import 'package:parosis_sulama/widgets/page_heading.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

String _twoDigits(int n) => n.toString().padLeft(2, '0');
String _formatDate(DateTime dt) =>
    '${_twoDigits(dt.day)}.${_twoDigits(dt.month)}.${dt.year}';
String _formatTime(DateTime dt) =>
    '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';

String _componentLabel(WellComponentType type) => switch (type) {
  WellComponentType.pump => 'Pompa',
  WellComponentType.thermal => 'Termik',
  WellComponentType.power => 'Enerji',
  WellComponentType.communication => 'Haberleşme',
};

String _formatElapsed(Duration d) {
  final h = _twoDigits(d.inHours);
  final m = _twoDigits(d.inMinutes % 60);
  final s = _twoDigits(d.inSeconds % 60);
  return '$h:$m:$s';
}

const _busyNamePool = [
  'Ali Yurtseven',
  'Mehmet Polat',
  'Fatma Yılmaz',
  'Hasan Demir',
  'Ayşe Kara',
];

/// Anlık Sulama'da, donanımı tamamen sağlıklı bir kuyunun "Meşgul" (başka
/// biri kullanıyor) durumunu deterministik olarak simüle eder — gerçek
/// çoklu kullanıcı/kuyu sahipliği verisi olmadığı için (bkz. memory
/// `project_well_ownership_deferred`) `well_bookings`/`irrigation` geçmişi
/// ile aynı desende sahte ama sabit veri. `since`, ilk çağrıldığı anda
/// dondurulup önbelleğe alınır ki geçen süre canlı sayaç gibi ilerlesin,
/// her build'de "şimdi"ye göre kaymasın.
final Map<String, DateTime> _busySinceCache = {};

({String personName, DateTime since})? _syntheticBusyInfo(Well well) {
  final hasIssue = well.components.any(
    (c) => c.status == WellComponentStatus.offline,
  );
  if (hasIssue) return null;

  final rng = Random(well.id.hashCode ^ 0x6d6573);
  if (rng.nextDouble() >= 0.5) return null;

  final since = _busySinceCache.putIfAbsent(well.id, () {
    final hoursAgo = 1 + rng.nextInt(72);
    final minutesAgo = rng.nextInt(60);
    final secondsAgo = rng.nextInt(60);
    return DateTime.now().subtract(
      Duration(hours: hoursAgo, minutes: minutesAgo, seconds: secondsAgo),
    );
  });
  final personName =
      _busyNamePool[well.id.hashCode.abs() % _busyNamePool.length];
  return (personName: personName, since: since);
}

enum _InstantStatus { ready, started, stopping, busy, problem }

class ProgramScreen extends StatelessWidget {
  final WellsController wellsController;
  final ValueChanged<Well> onWellEdit;
  const ProgramScreen({
    super.key,
    required this.wellsController,
    required this.onWellEdit,
  });
  @override
  Widget build(BuildContext context) => _WellPage(
    title: 'Program Sulama',
    subtitle: 'Sulama planlamak için kuyu seçin',
    wellsController: wellsController,
    onWellEdit: onWellEdit,
  );
}

class InstantScreen extends StatelessWidget {
  final WellsController wellsController;
  final IrrigationController irrigationController;
  final ProfileController profileController;
  final VoidCallback onNavigateHome;

  final VoidCallback onAddressRequired;
  const InstantScreen({
    super.key,
    required this.wellsController,
    required this.irrigationController,
    required this.profileController,
    required this.onNavigateHome,
    required this.onAddressRequired,
  });
  @override
  Widget build(BuildContext context) => _WellPage(
    title: 'Anlık Sulama',
    subtitle: 'Hemen başlatmak için kuyu seçin',
    wellsController: wellsController,
    irrigationController: irrigationController,
    profileController: profileController,
    onNavigateHome: onNavigateHome,
    onAddressRequired: onAddressRequired,
  );
}

class _WellPage extends StatelessWidget {
  final String title, subtitle;
  final WellsController wellsController;

  /// Kuyu adına dokununca düzenleme/randevu ekranına gitme davranışı —
  /// sadece Program Sulama'da var. Anlık Sulama'da kullanıcı kuyulara
  /// müdahale edemesin diye null bırakılıyor (bkz. [InstantScreen]).
  final ValueChanged<Well>? onWellEdit;
  final IrrigationController? irrigationController;
  final ProfileController? profileController;
  final VoidCallback? onNavigateHome;
  final VoidCallback? onAddressRequired;
  const _WellPage({
    required this.title,
    required this.subtitle,
    required this.wellsController,
    this.onWellEdit,
    this.irrigationController,
    this.profileController,
    this.onNavigateHome,
    this.onAddressRequired,
  });

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: wellsController,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 104),
      children: [
        PageHeading(title: title, subtitle: subtitle),
        const SizedBox(height: 20),
        if (wellsController.isLoading)
          const _CenteredNotice(text: 'Kuyular yükleniyor…')
        else
          WellList(
            wells: wellsController.wells,
            onWellEdit: onWellEdit,
            irrigationController: irrigationController,
            profileController: profileController,
            onNavigateHome: onNavigateHome,
            onAddressRequired: onAddressRequired,
          ),
      ],
    ),
  );
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

class WellList extends StatefulWidget {
  final List<Well> wells;
  final ValueChanged<Well>? onWellEdit;
  final IrrigationController? irrigationController;
  final ProfileController? profileController;
  final VoidCallback? onNavigateHome;
  final VoidCallback? onAddressRequired;
  const WellList({
    super.key,
    required this.wells,
    this.onWellEdit,
    this.irrigationController,
    this.profileController,
    this.onNavigateHome,
    this.onAddressRequired,
  });
  @override
  State<WellList> createState() => _WellListState();
}

class _WellListState extends State<WellList> {
  String query = '';
  Timer? _busyTicker;

  @override
  void initState() {
    super.initState();
    // Anlık Sulama'daki "Meşgul" kartlarının süre sayacı canlı aksın diye —
    // sadece bu ekranda (irrigationController varken) çalışır.
    if (widget.irrigationController != null) {
      _busyTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _busyTicker?.cancel();
    super.dispose();
  }

  Future<void> _handleStart(Well well) async {
    final irrigationController = widget.irrigationController;
    if (irrigationController == null) return;
    if (irrigationController.isActiveForWell(well.id)) {
      widget.onNavigateHome?.call();
      return;
    }

    final hasAddress =
        widget.profileController?.user?.hasCompleteAddress ?? false;
    if (!hasAddress) {
      final goToAddress = await showConfirmDialog(
        context,
        icon: Icons.location_on_outlined,
        title: 'Adres Bilgileri Gerekli',
        message:
            'Kuyuları başlatabilmek için adres bilgilerinizi doldurmanız '
            'gerekmektedir.',
        confirmLabel: 'Adres Bilgilerim',
        cancelLabel: 'İptal',
      );
      if (goToAddress) widget.onAddressRequired?.call();
      return;
    }

    irrigationController.start(well.id);
  }

  @override
  Widget build(BuildContext c) {
    final irrigationController = widget.irrigationController;
    if (irrigationController == null) return _buildList();
    // Sulama başlatıldığında/durdurulduğunda `_WellCard`'ın `started`
    // bayrağı hemen güncellensin diye liste, dinlenen controller'ın
    // builder'ı İÇİNDE yeniden kuruluyor; dışarıda önbelleklenmiş bir
    // widget ağacı, notifyListeners() sonrası "Takip Et"e dönmüyordu.
    return ListenableBuilder(
      listenable: irrigationController,
      builder: (context, _) => _buildList(),
    );
  }

  Widget _buildList() {
    final q = query.trim().toLowerCase();
    final result = q.isEmpty
        ? widget.wells
        : widget.wells
              .where(
                (w) => '${w.name} ${w.ownerName} ${w.province} ${w.district}'
                    .toLowerCase()
                    .contains(q),
              )
              .toList();

    return Column(
      children: [
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
                    onChanged: (v) => setState(() => query = v),
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
        if (result.isEmpty)
          GlassPanel(
            borderRadius: BorderRadius.circular(21),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
                Text(
                  widget.wells.isEmpty
                      ? 'Henüz kuyunuz yok'
                      : 'Kuyu bulunamadı',
                  style: figtree(size: 14, weight: W.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.wells.isEmpty
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
          for (final well in result) ...[
            _WellCard(
              well: well,
              isInstant: widget.irrigationController != null,
              started:
                  widget.irrigationController?.isActiveForWell(well.id) ??
                  false,
              stopping:
                  widget.irrigationController?.isStopping(well.id) ?? false,
              onEdit: widget.onWellEdit == null
                  ? null
                  : () => widget.onWellEdit!(well),
              onStart: widget.irrigationController == null
                  ? null
                  : () => _handleStart(well),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _WellCard extends StatelessWidget {
  final Well well;
  final bool isInstant, started, stopping;

  /// Anlık Sulama'da null — kullanıcı orada kuyulara müdahale edemez
  /// (bkz. [InstantScreen]), kuyu adı dokunmaya tepki vermez.
  final VoidCallback? onEdit;
  final VoidCallback? onStart;
  const _WellCard({
    required this.well,
    required this.isInstant,
    required this.started,
    required this.stopping,
    this.onEdit,
    this.onStart,
  });

  _InstantStatus get _status {
    if (!isInstant) return _InstantStatus.ready;
    if (stopping) return _InstantStatus.stopping;
    if (started) return _InstantStatus.started;
    final hasIssue = well.components.any(
      (c) => c.status == WellComponentStatus.offline,
    );
    if (hasIssue) return _InstantStatus.problem;
    if (_syntheticBusyInfo(well) != null) return _InstantStatus.busy;
    return _InstantStatus.ready;
  }

  @override
  Widget build(BuildContext c) {
    final status = _status;
    final busyInfo = status == _InstantStatus.busy
        ? _syntheticBusyInfo(well)
        : null;

    final card = GlassPanel(
      borderRadius: BorderRadius.circular(19),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isInstant) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: stopping
                          ? AppColors.mist100
                          : AppColors.brand100.withValues(alpha: .8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: AppIcons.droplet(
                        size: 18,
                        color: stopping
                            ? AppColors.mist600
                            : AppColors.brand700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: InkWell(
                    onTap: onEdit,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarqueeText(
                          key: ValueKey('well-name-${well.id}'),
                          text: well.name,
                          style: figtree(
                            size: 15,
                            weight: W.extrabold,
                            tracking: Tracking.tight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          well.ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: figtree(
                            size: 12,
                            weight: W.bold,
                            color: AppColors.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            AppIcons.mapPin(
                              size: 11,
                              color: AppColors.inkFaint,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${well.province} / ${well.district}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: figtree(
                                  size: 11.5,
                                  weight: W.semibold,
                                  color: AppColors.inkFaint,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (busyInfo != null)
                          _BusyStatusLine(
                            personName: busyInfo.personName,
                            since: busyInfo.since,
                          ),
                      ],
                    ),
                  ),
                ),
                if (isInstant) ...[
                  const SizedBox(width: 8),
                  _StartButton(status: status, onTap: onStart!),
                ] else
                  AppIcons.chevronRight(size: 16, color: AppColors.inkFaint),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final component in well.components)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: _WellComponentBadge(component: component),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (status == _InstantStatus.started) {
      return _ActiveWellFrame(child: card);
    }

    if (status != _InstantStatus.busy) return card;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.amber400, width: 2),
      ),
      child: card,
    );
  }
}

class _ActiveWellFrame extends StatefulWidget {
  final Widget child;
  const _ActiveWellFrame({required this.child});

  @override
  State<_ActiveWellFrame> createState() => _ActiveWellFrameState();
}

class _ActiveWellFrameState extends State<_ActiveWellFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21.5),
          border: Border.all(color: AppColors.brand500, width: 2.5),
        ),
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _RotatingFramePainter(progress: _controller.value),
        child: child,
      ),
      child: Padding(padding: const EdgeInsets.all(2.5), child: widget.child),
    );
  }
}

class _RotatingFramePainter extends CustomPainter {
  final double progress;
  const _RotatingFramePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const strokeWidth = 2.5;
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(21.5),
    ).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          AppColors.brand300.withValues(alpha: 0.3),
          AppColors.brand300.withValues(alpha: 0.3),
          AppColors.brand400,
          AppColors.brand600,
          AppColors.brand400,
          AppColors.brand300.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 0.6, 0.71, 0.8, 0.89, 1.0],
        transform: GradientRotation(2 * pi * progress),
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _RotatingFramePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _BusyStatusLine extends StatelessWidget {
  final String personName;
  final DateTime since;
  const _BusyStatusLine({required this.personName, required this.since});

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(since);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.amber400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: personName,
                    style: figtree(
                      size: 11,
                      weight: W.extrabold,
                      color: AppColors.amber800,
                    ),
                  ),
                  TextSpan(
                    text: ' kullanıyor · ${_formatElapsed(elapsed)} süredir',
                    style: figtree(
                      size: 11,
                      weight: W.semibold,
                      color: AppColors.amber800,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final _InstantStatus status;
  final VoidCallback onTap;
  const _StartButton({required this.status, required this.onTap});

  @override
  Widget build(BuildContext c) => switch (status) {
    _InstantStatus.stopping => const _PassiveChip(
      background: AppColors.mist500,
      textColor: Colors.white,
      label: 'Kapatılıyor',
      spinner: true,
    ),
    _InstantStatus.busy => const _PassiveChip(
      background: AppColors.slate200,
      textColor: AppColors.inkSoft,
      label: 'Meşgul',
    ),
    _InstantStatus.problem => const _PassiveChip(
      background: AppColors.red50,
      textColor: AppColors.red600,
      label: 'Sorun',
      icon: Icons.error_outline_rounded,
    ),
    _InstantStatus.started => PressableScale(
      scale: .96,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.sea600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.sea600.withValues(alpha: 0.28),
              blurRadius: 16,
              spreadRadius: -7,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility_outlined,
              color: Colors.white,
              size: 13,
            ),
            const SizedBox(width: 6),
            Text(
              'Takip Et',
              style: figtree(size: 12, weight: W.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
    _InstantStatus.ready => PressableScale(
      scale: .96,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.brand600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand700.withValues(alpha: 0.28),
              blurRadius: 16,
              spreadRadius: -7,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcons.play(size: 13, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'Başlat',
              style: figtree(size: 12, weight: W.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  };
}

class _PassiveChip extends StatelessWidget {
  final Color background, textColor;
  final String label;
  final bool spinner;
  final IconData? icon;
  const _PassiveChip({
    required this.background,
    required this.textColor,
    required this.label,
    this.spinner = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (spinner)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: textColor,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 13, color: textColor),
        if (spinner || icon != null) const SizedBox(width: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: figtree(size: 12, weight: W.bold, color: textColor),
        ),
      ],
    ),
  );
}

class _WellComponentBadge extends StatefulWidget {
  final WellComponent component;
  const _WellComponentBadge({required this.component});

  @override
  State<_WellComponentBadge> createState() => _WellComponentBadgeState();
}

class _WellComponentBadgeState extends State<_WellComponentBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  bool get _isOffline => widget.component.status != WellComponentStatus.online;

  @override
  void initState() {
    super.initState();
    if (_isOffline) _startPulse();
  }

  void _startPulse() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _WellComponentBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOffline && _pulseController == null) {
      _startPulse();
    } else if (!_isOffline && _pulseController != null) {
      _pulseController!.dispose();
      _pulseController = null;
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _componentLabel(widget.component.type);
    if (!_isOffline) {
      return _ComponentBadgeChrome(
        label: label,
        background: AppColors.brand100.withValues(alpha: .9),
        border: AppColors.brand200,
        dot: AppColors.brand500,
        text: AppColors.brand700,
      );
    }

    final controller = _pulseController;
    if (controller == null || MediaQuery.disableAnimationsOf(context)) {
      return _ComponentBadgeChrome(
        label: label,
        background: AppColors.red100.withValues(alpha: .9),
        border: AppColors.red200,
        dot: AppColors.red500,
        text: AppColors.red600,
      );
    }

    // Devre dışı bileşenlerde kullanıcının dikkatini çekmesi için hafif,
    // yavaş (~2sn'de bir) bir renk nabzı — metin okunaklılığını korumak
    // için sadece arkaplan/nokta rengi değişiyor, yazı sabit kalıyor.
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.value);
        return _ComponentBadgeChrome(
          label: label,
          background: Color.lerp(
            AppColors.red100.withValues(alpha: .9),
            AppColors.red200.withValues(alpha: .9),
            t,
          )!,
          border: AppColors.red200,
          dot: Color.lerp(AppColors.red500, AppColors.red600, t)!,
          text: AppColors.red600,
        );
      },
    );
  }
}

class _ComponentBadgeChrome extends StatelessWidget {
  final String label;
  final Color background, border, dot, text;
  const _ComponentBadgeChrome({
    required this.label,
    required this.background,
    required this.border,
    required this.dot,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: figtree(
            size: 10,
            weight: W.bold,
            color: text,
            tracking: Tracking.tight,
          ),
        ),
      ],
    ),
  );
}

/// Program Sulama'dan bir kuyuya dokunulunca açılan randevu/sıra alma
/// ekranı: Başlangıç seçimi, günün doluluk şeridi ve "Sıra Al" akışı.
/// Anlık Sulama'da kullanıcı kuyulara müdahale edemediği için ([InstantScreen]
/// kuyu adına dokunmayı devre dışı bırakır) buraya sadece Program
/// Sulama'dan gelinir.
class WellEditScreen extends StatefulWidget {
  final WellsController wellsController;
  final WellBookingsController wellBookingsController;
  final String? wellId;

  /// "Sıra Al" başarıyla gönderildikten sonra çağrılır — kullanıcıyı bu
  /// ekrandan Program Sulama listesine geri döndürmek için.
  final VoidCallback? onSubmitted;
  const WellEditScreen({
    super.key,
    required this.wellsController,
    required this.wellBookingsController,
    required this.wellId,
    this.onSubmitted,
  });

  @override
  State<WellEditScreen> createState() => _WellEditScreenState();
}

class _WellEditScreenState extends State<WellEditScreen> {
  static const _minDurationHours = 1;

  late DateTime _start;

  int? _durationHours;
  List<WellScheduleEntry> _daySchedule = const [];
  List<WellScheduleEntry> _todaySchedule = const [];
  bool _loadingSchedule = true;

  Well? get _well {
    final id = widget.wellId;
    return id == null ? null : widget.wellsController.byId(id);
  }

  @override
  void initState() {
    super.initState();
    _start = _roundUpToNext5(DateTime.now());
    _loadSchedules();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _roundUpToNext5(DateTime dt) {
    final remainder = dt.minute % 5;
    final add = remainder == 0 ? 0 : 5 - remainder;
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute + add);
  }

  Future<void> _loadSchedules() async {
    final well = _well;
    if (well == null) return;
    setState(() => _loadingSchedule = true);

    final today = DateTime.now();
    final sameDay = _isSameDay(_start, today);
    final selected = await widget.wellBookingsController.loadDaySchedule(
      wellId: well.id,
      date: _start,
    );
    final todaySchedule = sameDay
        ? selected
        : await widget.wellBookingsController.loadDaySchedule(
            wellId: well.id,
            date: today,
          );

    if (!mounted) return;
    setState(() {
      _daySchedule = selected;
      _todaySchedule = todaySchedule;
      _loadingSchedule = false;
    });
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _start = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _start.hour,
        _start.minute,
      );
    });
    _loadSchedules();
  }

  Future<void> _pickStartTime() async {
    final picked = await _showHourPicker(
      context,
      title: 'Sulama Başlatma Saatini Seçin',
      initialHour: _start.hour,
      itemCount: 24,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _start = DateTime(_start.year, _start.month, _start.day, picked);
    });
    _loadSchedules();
  }

  Future<void> _pickDuration() async {
    final picked = await _showHourPicker(
      context,
      title: 'Kaç Saat Sulama Yapılacak',
      initialHour: _durationHours ?? 0,
      itemCount: 100,
      unitSuffix: 'saat',
    );
    if (picked == null || !mounted) return;
    setState(() => _durationHours = picked);
  }

  DateTime get _end => _start.add(Duration(hours: _durationHours ?? 0));
  bool get _hasValidRange =>
      _durationHours != null && _durationHours! >= _minDurationHours;

  bool _rangesOverlap(
    DateTime aStart,
    DateTime? aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    final effectiveAEnd = aEnd ?? DateTime(9999);
    return aStart.isBefore(bEnd) && bStart.isBefore(effectiveAEnd);
  }

  WellScheduleEntry? get _conflict {
    for (final entry in _daySchedule) {
      if (entry.kind == WellScheduleEntryKind.mine) continue;
      if (_rangesOverlap(entry.start, entry.end, _start, _end)) return entry;
    }
    return null;
  }

  Future<void> _submit() async {
    final well = _well;
    if (well == null || !_hasValidRange || _conflict != null) return;
    final success = await widget.wellBookingsController.requestSlot(
      wellId: well.id,
      wellName: well.name,
      start: _start,
      end: _end,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Randevu talebiniz gönderildi.')),
      );
      widget.onSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final well = _well;
    if (well == null) {
      return const _WellNotFoundNotice();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
      children: [
        PageHeading(
          title: well.name,
          subtitle: '${well.province} / ${well.district}',
        ),
        const SizedBox(height: 20),
        _OccupancyPanel(
          day: _start,
          entries: _daySchedule,
          selectedStart: _start,
          selectedEnd: _end,
          isLoading: _loadingSchedule,
          conflict: _conflict,
        ),
        const SizedBox(height: 14),
        _BookingRangePanel(
          start: _start,
          end: _end,
          hasValidRange: _hasValidRange,
          durationHours: _durationHours,
          onPickStartDate: _pickStartDate,
          onPickStartTime: _pickStartTime,
          onPickDuration: _pickDuration,
        ),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: widget.wellBookingsController,
          builder: (context, _) => _SubmitPanel(
            durationHours: _durationHours,
            minDurationHours: _minDurationHours,
            hasValidRange: _hasValidRange,
            hasConflict: _conflict != null,
            submitting: widget.wellBookingsController.isSubmitting,
            onSubmit: _submit,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bu günün randevuları',
          style: figtree(size: 15, weight: W.extrabold),
        ),
        const SizedBox(height: 12),
        if (_loadingSchedule)
          const _CenteredNotice(text: 'Randevular yükleniyor…')
        else
          _TodayAppointmentsList(entries: _todaySchedule),
      ],
    );
  }
}

class _WellNotFoundNotice extends StatelessWidget {
  const _WellNotFoundNotice();

  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
    children: [
      const PageHeading(
        title: 'Kuyu Düzenle',
        subtitle: 'Kuyu bilgilerini güncelleyin',
      ),
      const SizedBox(height: 20),
      GlassPanel(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: AppColors.inkFaint),
            const SizedBox(height: 12),
            Text('Kuyu bulunamadı', style: figtree(size: 15, weight: W.bold)),
          ],
        ),
      ),
    ],
  );
}

class _BookingRangePanel extends StatelessWidget {
  final DateTime start, end;
  final bool hasValidRange;
  final int? durationHours;
  final VoidCallback onPickStartDate, onPickStartTime, onPickDuration;
  const _BookingRangePanel({
    required this.start,
    required this.end,
    required this.hasValidRange,
    required this.durationHours,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickDuration,
  });

  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(22),
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateTimeColumn(
          dotColor: AppColors.brand500,
          date: start,
          onPickDate: onPickStartDate,
          onPickTime: onPickStartTime,
        ),
        const SizedBox(height: 14),
        _DurationField(hours: durationHours, onTap: onPickDuration),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
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
          child: hasValidRange
              ? Padding(
                  key: const ValueKey('end-row'),
                  padding: const EdgeInsets.only(top: 12),
                  child: _ComputedEndRow(end: end),
                )
              : const SizedBox.shrink(key: ValueKey('end-row-empty')),
        ),
      ],
    ),
  );
}

class _DotLabel extends StatelessWidget {
  final Color dotColor;
  final String text;
  const _DotLabel({required this.dotColor, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        text,
        style: figtree(
          size: 10.5,
          weight: W.extrabold,
          color: AppColors.inkSoft,
          tracking: Tracking.wide,
        ),
      ),
    ],
  );
}

class _DurationField extends StatelessWidget {
  final int? hours;
  final VoidCallback onTap;
  const _DurationField({required this.hours, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _DotLabel(
        dotColor: AppColors.brand500,
        text: 'KAÇ SAAT SULAMA YAPILACAK',
      ),
      const SizedBox(height: 8),
      _PickerBox(
        text: hours == null ? 'Süre seçin' : '$hours saat',
        icon: Icons.timer_outlined,
        onTap: onTap,
      ),
    ],
  );
}

class _ComputedEndRow extends StatelessWidget {
  final DateTime end;
  const _ComputedEndRow({required this.end});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.brand50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.brand200.withValues(alpha: .6)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.event_available_outlined,
          size: 16,
          color: AppColors.brand700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Bitiş: ${_formatDate(end)} ${_formatTime(end)}',
            style: figtree(
              size: 12.5,
              weight: W.bold,
              color: AppColors.brand700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DateTimeColumn extends StatelessWidget {
  final Color dotColor;
  final DateTime date;
  final VoidCallback onPickDate, onPickTime;
  const _DateTimeColumn({
    required this.dotColor,
    required this.date,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _DotLabel(dotColor: dotColor, text: 'SULAMA BAŞLATMA TARİHİNİ SEÇİN'),
      const SizedBox(height: 8),
      _PickerBox(
        text: _formatDate(date),
        icon: Icons.calendar_today_outlined,
        onTap: onPickDate,
      ),
      const SizedBox(height: 14),
      _DotLabel(dotColor: dotColor, text: 'SULAMA BAŞLATMA SAATİNİ SEÇİN'),
      const SizedBox(height: 8),
      _PickerBox(
        text: _formatTime(date),
        icon: Icons.access_time_rounded,
        onTap: onPickTime,
      ),
    ],
  );
}

class _PickerBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerBox({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: .97,
    onTap: onTap,
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: figtree(size: 13.5, weight: W.bold),
            ),
          ),
          Icon(icon, size: 16, color: AppColors.inkFaint),
        ],
      ),
    ),
  );
}

class _OccupancyPanel extends StatelessWidget {
  final DateTime day;
  final List<WellScheduleEntry> entries;
  final DateTime selectedStart, selectedEnd;
  final bool isLoading;
  final WellScheduleEntry? conflict;
  const _OccupancyPanel({
    required this.day,
    required this.entries,
    required this.selectedStart,
    required this.selectedEnd,
    required this.isLoading,
    required this.conflict,
  });

  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(20),
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Günün doluluğu',
                style: figtree(size: 13.5, weight: W.extrabold),
              ),
            ),
            Text(
              '00:00 – 24:00',
              style: figtree(
                size: 11,
                weight: W.semibold,
                color: AppColors.inkFaint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _DayOccupancyTimeline(
            day: day,
            entries: isLoading ? const [] : entries,
            selectedStart: selectedStart,
            selectedEnd: selectedEnd,
          ),
        ),
        const SizedBox(height: 12),
        const _TimelineLegend(),
        if (conflict != null) ...[
          const SizedBox(height: 10),
          Text(
            'Bu saat aralığı dolu: ${conflict!.personName}.',
            style: figtree(
              size: 11.5,
              weight: W.semibold,
              color: AppColors.red600,
            ),
          ),
        ],
      ],
    ),
  );
}

class _DayOccupancyTimeline extends StatelessWidget {
  final DateTime day;
  final List<WellScheduleEntry> entries;
  final DateTime selectedStart, selectedEnd;
  const _DayOccupancyTimeline({
    required this.day,
    required this.entries,
    required this.selectedStart,
    required this.selectedEnd,
  });

  static const _dayMinutes = 24 * 60;

  Color _colorFor(WellScheduleEntryKind kind) => switch (kind) {
    WellScheduleEntryKind.mine => AppColors.brand500,
    WellScheduleEntryKind.occupied => AppColors.mist500,
    WellScheduleEntryKind.pendingApproval => AppColors.amber400,
  };

  @override
  Widget build(BuildContext context) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    double offsetFraction(DateTime dt) {
      final clamped = dt.isBefore(dayStart)
          ? dayStart
          : (dt.isAfter(dayEnd) ? dayEnd : dt);
      return clamped.difference(dayStart).inMinutes / _dayMinutes;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 34,
          child: Stack(
            children: [
              Container(color: AppColors.slate100),
              for (final entry in entries)
                Positioned(
                  left: width * offsetFraction(entry.start),
                  width:
                      (width *
                              (offsetFraction(entry.end ?? dayEnd) -
                                  offsetFraction(entry.start)))
                          .clamp(2.0, width),
                  top: 0,
                  bottom: 0,
                  child: Container(color: _colorFor(entry.kind)),
                ),
              if (selectedEnd.isAfter(dayStart) &&
                  selectedStart.isBefore(dayEnd))
                Positioned(
                  left: width * offsetFraction(selectedStart),
                  width:
                      (width *
                              (offsetFraction(selectedEnd) -
                                  offsetFraction(selectedStart)))
                          .clamp(2.0, width),
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.red500, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineLegend extends StatelessWidget {
  const _TimelineLegend();
  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 14,
    runSpacing: 6,
    children: [
      _LegendDot(color: AppColors.brand500, label: 'seninki'),
      _LegendDot(color: AppColors.mist500, label: 'dolu'),
      _LegendDot(color: AppColors.amber400, label: 'onay bekliyor'),
    ],
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: figtree(size: 11, weight: W.semibold, color: AppColors.inkSoft),
      ),
    ],
  );
}

class _SubmitPanel extends StatelessWidget {
  final int? durationHours;
  final int minDurationHours;
  final bool hasValidRange, hasConflict, submitting;
  final VoidCallback onSubmit;
  const _SubmitPanel({
    required this.durationHours,
    required this.minDurationHours,
    required this.hasValidRange,
    required this.hasConflict,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final canSubmit = hasValidRange && !hasConflict && !submitting;
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Süre: ',
                  style: figtree(
                    size: 12.5,
                    weight: W.semibold,
                    color: AppColors.inkSoft,
                  ),
                ),
                TextSpan(
                  text: durationHours == null ? '—' : '$durationHours saat',
                  style: figtree(size: 12.5, weight: W.extrabold),
                ),
                TextSpan(
                  text: ' · en az $minDurationHours saat',
                  style: figtree(
                    size: 12,
                    weight: W.medium,
                    color: AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PressableScale(
            scale: .98,
            disabled: !canSubmit,
            onTap: onSubmit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: canSubmit
                    ? AppColors.nearBlack
                    : AppColors.mist200.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.watch_later_outlined,
                    size: 18,
                    color: canSubmit ? Colors.white : AppColors.mist600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    submitting ? 'Gönderiliyor…' : 'Sıra Al',
                    style: figtree(
                      size: 14.5,
                      weight: W.extrabold,
                      color: canSubmit ? Colors.white : AppColors.mist600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!hasValidRange) ...[
            const SizedBox(height: 8),
            Text(
              durationHours == null
                  ? 'Sulama süresini seçin.'
                  : 'Süre en az $minDurationHours saat olmalı.',
              style: figtree(
                size: 11.5,
                weight: W.semibold,
                color: AppColors.red600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayAppointmentsList extends StatelessWidget {
  final List<WellScheduleEntry> entries;
  const _TodayAppointmentsList({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return GlassPanel(
        borderRadius: BorderRadius.circular(16),
        elevated: false,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'Bugün için randevu yok.',
            style: figtree(
              size: 12.5,
              weight: W.medium,
              color: AppColors.inkFaint,
            ),
          ),
        ),
      );
    }

    final sorted = [...entries]..sort((a, b) => a.start.compareTo(b.start));
    return Column(
      children: [
        for (final entry in sorted) ...[
          _AppointmentCard(entry: entry),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final WellScheduleEntry entry;
  const _AppointmentCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final active = entry.isActiveAt(now);
    final pending = entry.kind == WellScheduleEntryKind.pendingApproval;
    final label = active ? 'aktif' : (pending ? 'onay bekliyor' : 'onaylandı');
    final color = active
        ? AppColors.brand600
        : (pending ? AppColors.amber800 : AppColors.inkSoft);
    final bg = active
        ? AppColors.brand100
        : (pending ? AppColors.amber50 : AppColors.slate100);
    final endLabel = entry.end == null ? '∞' : _formatTime(entry.end!);

    return GlassPanel(
      borderRadius: BorderRadius.circular(16),
      elevated: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_formatTime(entry.start)} - $endLabel',
              style: figtree(size: 13.5, weight: W.extrabold),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (active) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: figtree(size: 10, weight: W.extrabold, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            entry.personName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtree(
              size: 11,
              weight: W.bold,
              color: AppColors.inkFaint,
              tracking: Tracking.tight,
            ),
          ),
        ],
      ),
    );
  }
}

Future<int?> _showHourPicker(
  BuildContext context, {
  required String title,
  required int initialHour,
  required int itemCount,
  String? unitSuffix,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _HourPickerSheet(
      title: title,
      initialHour: initialHour,
      itemCount: itemCount,
      unitSuffix: unitSuffix,
    ),
  );
}

class _HourPickerSheet extends StatefulWidget {
  final String title;
  final int initialHour;
  final int itemCount;
  final String? unitSuffix;
  const _HourPickerSheet({
    required this.title,
    required this.initialHour,
    required this.itemCount,
    this.unitSuffix,
  });

  @override
  State<_HourPickerSheet> createState() => _HourPickerSheetState();
}

class _HourPickerSheetState extends State<_HourPickerSheet> {
  late int _hour = widget.initialHour.clamp(0, widget.itemCount - 1);

  late final FixedExtentScrollController _hourController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _hour);
  }

  @override
  void dispose() {
    _hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Text(widget.title, style: figtree(size: 15, weight: W.extrabold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 170,
              child: Row(
                children: [
                  Expanded(
                    child: _TimeWheel(
                      controller: _hourController,
                      itemCount: widget.itemCount,
                      labelOf: _twoDigits,
                      onChanged: (i) => setState(() => _hour = i),
                    ),
                  ),
                  if (widget.unitSuffix != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        widget.unitSuffix!,
                        style: figtree(
                          size: 13,
                          weight: W.bold,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PressableScale(
              scale: .98,
              onTap: () => Navigator.of(context).pop(_hour),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.nearBlack,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Tamam',
                    style: figtree(
                      size: 14.5,
                      weight: W.extrabold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) labelOf;
  final ValueChanged<int> onChanged;
  const _TimeWheel({
    required this.controller,
    required this.itemCount,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => CupertinoPicker(
    scrollController: controller,
    itemExtent: 40,
    diameterRatio: 1.4,
    onSelectedItemChanged: onChanged,
    selectionOverlay: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brand300, width: 1.4),
      ),
    ),
    children: [
      for (var i = 0; i < itemCount; i++)
        Center(
          child: Text(labelOf(i), style: figtree(size: 19, weight: W.bold)),
        ),
    ],
  );
}
