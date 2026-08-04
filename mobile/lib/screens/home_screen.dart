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
          tone: AppColors.mist600,
          icon: AppIcons.calendarClock(size: 24, color: Colors.white),
          title: 'Program Sulama',
          description: 'İleri tarihe sulama planla',
          onTap: () => widget.onNavigate('program'),
        ),
        const SizedBox(height: 10),
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
  Widget build(BuildContext context) => PressableScale(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: tone.withOpacity(.55),
            blurRadius: 28,
            spreadRadius: -14,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: figtree(
                    size: 15,
                    weight: W.extrabold,
                    color: Colors.white,
                    tracking: Tracking.tight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: figtree(
                    size: 12,
                    weight: W.medium,
                    color: Colors.white.withOpacity(.80),
                  ),
                ),
              ],
            ),
          ),
          AppIcons.chevronRight(size: 20, color: Colors.white.withOpacity(.7)),
        ],
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
  Widget build(BuildContext context) => PressableScale(
    scale: .98,
    onTap: onTap,
    child: selected
        ? Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.sea600,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sea600.withOpacity(.75),
                  blurRadius: 22,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (count != null)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: figtree(
                          size: 10,
                          weight: W.extrabold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (count != null) const SizedBox(width: 6),
                Text(
                  label,
                  style: figtree(
                    size: 13,
                    weight: W.bold,
                    color: Colors.white,
                    tracking: Tracking.tight,
                  ),
                ),
              ],
            ),
          )
        : GlassPanel(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  label,
                  style: figtree(
                    size: 13,
                    weight: W.bold,
                    color: AppColors.inkSoft,
                    tracking: Tracking.tight,
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
            color: AppColors.brand700.withOpacity(.80),
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
                  color: Colors.white.withOpacity(.20),
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
                    color: Colors.white.withOpacity(.75),
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
                      color: Colors.white.withOpacity(.5),
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
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Sulama çalışıyor',
                style: figtree(
                  size: 12,
                  weight: W.semibold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
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
            color: AppColors.sea100.withOpacity(.8),
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
