import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass.dart';
import '../widgets/pressable_scale.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _tab = 'active';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
      children: [
        _BigAction(
          tone: AppColors.neutral600,
          icon: AppIcons.calendarClock(size: 24, color: Colors.white),
          title: 'Program Sulama',
          description: 'İleri tarihe sulama planla',
          onTap: () => widget.onNavigate('program'),
        ),
        const SizedBox(height: 12),
        _BigAction(
          tone: AppColors.brand600,
          icon: AppIcons.droplet(size: 24, color: Colors.white),
          title: 'Anlık Sulama',
          description: 'Kuyuyu hemen çalıştır',
          onTap: () => widget.onNavigate('instant'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Segment(
                label: 'Aktif Sulamalar',
                selected: _tab == 'active',
                count: 1,
                onTap: () => setState(() => _tab = 'active'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Segment(
                label: 'Gelecek Sulamalar',
                selected: _tab == 'upcoming',
                onTap: () => setState(() => _tab = 'upcoming'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_tab == 'active')
          const _ActiveIrrigationCard()
        else ...[
          for (final item in upcomingIrrigations) ...[
            _UpcomingCard(item: item),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _BigAction extends StatelessWidget {
  final Color tone;
  final Widget icon;
  final String title, description;
  final VoidCallback onTap;
  const _BigAction({
    required this.tone,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    excludeSemantics: true,
    label: '$title. $description',
    child: PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: tone,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: .10),
            width: .8,
          ),
          boxShadow: [
            BoxShadow(
              color: tone.withValues(alpha: .32),
              blurRadius: 30,
              spreadRadius: -13,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .08),
                  width: .8,
                ),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: figtree(
                      size: 16,
                      weight: W.extrabold,
                      color: Colors.white,
                      tracking: Tracking.tight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: figtree(
                      size: 12,
                      weight: W.medium,
                      color: Colors.white.withValues(alpha: .80),
                    ),
                  ),
                ],
              ),
            ),
            AppIcons.chevronRight(
              size: 22,
              color: Colors.white.withValues(alpha: .72),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final int? count;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    excludeSemantics: true,
    label: label,
    value: count == null ? null : '$count sulama',
    child: PressableScale(
      scale: .98,
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: selected
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.sea600,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sea600.withValues(alpha: .42),
                        blurRadius: 16,
                        spreadRadius: -9,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (count != null)
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .24),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: figtree(
                                size: 9,
                                weight: W.extrabold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (count != null) const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: figtree(
                            size: 12,
                            weight: W.bold,
                            color: Colors.white,
                            tracking: Tracking.tight,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : GlassPanel(
                  borderRadius: BorderRadius.circular(14),
                  elevated: false,
                  child: Center(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: figtree(
                        size: 12,
                        weight: W.bold,
                        color: AppColors.inkSoft,
                        tracking: Tracking.tight,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    ),
  );
}

class _ActiveIrrigationCard extends StatelessWidget {
  const _ActiveIrrigationCard();
  @override
  Widget build(BuildContext context) {
    final well = wells.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brand600, AppColors.brand800],
        ),
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand700.withValues(alpha: .80),
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppIcons.droplet(size: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Anlık sulama',
                  style: figtree(
                    size: 11,
                    weight: W.semibold,
                    color: Colors.white.withValues(alpha: .75),
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SÜRE',
                    style: figtree(
                      size: 9,
                      weight: W.bold,
                      color: Colors.white.withValues(alpha: .5),
                      tracking: Tracking.widest,
                    ),
                  ),
                  Text(
                    '∞ Sınırsız',
                    style: figtree(
                      size: 13,
                      weight: W.extrabold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            well.ad,
            style: figtree(
              size: 20,
              weight: W.extrabold,
              color: Colors.white,
              tracking: Tracking.tight,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final badge in well.badges)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _Badge(badge: badge, bright: true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Sulama çalışıyor',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: figtree(
                          size: 12,
                          weight: W.semibold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Kullanım 02:34:11',
                style: figtree(
                  size: 11,
                  weight: W.semibold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pause_rounded,
                  color: AppColors.brand700,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  'Durdur',
                  style: figtree(
                    size: 13,
                    weight: W.bold,
                    color: AppColors.brand700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final WellBadge badge;
  final bool bright;
  const _Badge({required this.badge, this.bright = false});
  @override
  Widget build(BuildContext context) {
    final ok = badge.tone == 'green';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ok ? AppColors.brand200 : AppColors.red200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: ok ? AppColors.brand500 : AppColors.red500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            badge.label.toUpperCase(),
            style: figtree(
              size: 10.5,
              weight: W.bold,
              color: ok ? AppColors.brand700 : AppColors.red600,
              tracking: Tracking.tight,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final UpcomingIrrigation item;
  const _UpcomingCard({required this.item});
  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(19),
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.sea100.withValues(alpha: .8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: AppIcons.clock(size: 20, color: AppColors.sea700),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.kuyu,
                style: figtree(
                  size: 14,
                  weight: W.extrabold,
                  tracking: Tracking.tight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.tarih} · ${item.saat}',
                style: figtree(
                  size: 12,
                  weight: W.semibold,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.ilce,
                style: figtree(
                  size: 11,
                  weight: W.medium,
                  color: AppColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(item.sure, style: figtree(size: 13, weight: W.extrabold)),
            const SizedBox(height: 2),
            Text(
              'planlandı',
              style: figtree(
                size: 10.5,
                weight: W.semibold,
                color: AppColors.inkFaint,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
