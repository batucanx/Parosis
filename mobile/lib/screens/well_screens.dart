import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass.dart';
import '../widgets/page_heading.dart';
import '../widgets/pressable_scale.dart';

class ProgramScreen extends StatelessWidget {
  final VoidCallback onBack;
  final ValueChanged<Well> onWellEdit;
  const ProgramScreen({
    super.key,
    required this.onBack,
    required this.onWellEdit,
  });
  @override
  Widget build(BuildContext context) => _WellPage(
    title: 'Program Sulama',
    subtitle: 'Sulama planlamak için kuyu seçin',
    onBack: onBack,
    onWellEdit: onWellEdit,
  );
}

class InstantScreen extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<Well> onWellEdit;
  final ValueChanged<String> onNavigate;
  const InstantScreen({
    super.key,
    required this.onBack,
    required this.onWellEdit,
    required this.onNavigate,
  });
  @override
  State<InstantScreen> createState() => _InstantScreenState();
}

class _InstantScreenState extends State<InstantScreen> {
  String? startedId;
  @override
  Widget build(BuildContext c) => _WellPage(
    title: 'Anlık Sulama',
    subtitle: 'Hemen başlatmak için kuyu seçin',
    onBack: widget.onBack,
    onWellEdit: widget.onWellEdit,
    startedId: startedId,
    onStart: (w) => setState(() => startedId = w.id),
    onNavigate: widget.onNavigate,
  );
}

class _WellPage extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onBack;
  final ValueChanged<Well> onWellEdit;
  final String? startedId;
  final ValueChanged<Well>? onStart;
  final ValueChanged<String>? onNavigate;
  const _WellPage({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onWellEdit,
    this.startedId,
    this.onStart,
    this.onNavigate,
  });
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
    children: [
      PageHeading(title: title, subtitle: subtitle, onBack: onBack),
      const SizedBox(height: 20),
      WellList(
        onWellEdit: onWellEdit,
        startedId: startedId,
        onStart: onStart,
        onNavigate: onNavigate,
      ),
    ],
  );
}

class WellList extends StatefulWidget {
  final ValueChanged<Well> onWellEdit;
  final String? startedId;
  final ValueChanged<Well>? onStart;
  final ValueChanged<String>? onNavigate;
  const WellList({
    super.key,
    required this.onWellEdit,
    this.startedId,
    this.onStart,
    this.onNavigate,
  });
  @override
  State<WellList> createState() => _WellListState();
}

class _WellListState extends State<WellList> {
  String query = '';
  @override
  Widget build(BuildContext c) {
    final q = query.trim().toLowerCase();
    final result = q.isEmpty
        ? wells
        : wells
              .where(
                (w) => '${w.ad} ${w.il} ${w.ilce}'.toLowerCase().contains(q),
              )
              .toList();
    return Column(
      children: [
        GlassPanel(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  'Kuyu bulunamadı',
                  style: figtree(size: 14, weight: W.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Farklı bir isim veya ilçe deneyin.',
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
              isInstant: widget.onStart != null,
              started: widget.startedId == well.id,
              onEdit: () => widget.onWellEdit(well),
              onStart: widget.onStart == null
                  ? null
                  : () {
                      if (widget.startedId == well.id) {
                        widget.onNavigate?.call('home');
                      } else {
                        widget.onStart!(well);
                      }
                    },
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _WellCard extends StatelessWidget {
  final Well well;
  final bool isInstant, started;
  final VoidCallback onEdit;
  final VoidCallback? onStart;
  const _WellCard({
    required this.well,
    required this.isInstant,
    required this.started,
    required this.onEdit,
    this.onStart,
  });
  @override
  Widget build(BuildContext c) => GlassPanel(
    borderRadius: BorderRadius.circular(19),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brand100.withOpacity(.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppIcons.droplet(size: 18, color: AppColors.brand700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onEdit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        well.ad,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                              '${well.il} / ${well.ilce}',
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
              ),
              if (isInstant) ...[
                const SizedBox(width: 8),
                _StartButton(started: started, onTap: onStart!),
              ] else
                AppIcons.chevronRight(size: 16, color: AppColors.inkFaint),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final badge in well.badges)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _WellBadge(badge: badge),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _StartButton extends StatelessWidget {
  final bool started;
  final VoidCallback onTap;
  const _StartButton({required this.started, required this.onTap});
  @override
  Widget build(BuildContext c) => PressableScale(
    scale: .96,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: started ? AppColors.sea600 : AppColors.brand600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (started)
            const Icon(Icons.visibility_outlined, color: Colors.white, size: 13)
          else
            AppIcons.play(size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            started ? 'Takip Et' : 'Başlat',
            style: figtree(size: 12, weight: W.bold, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _WellBadge extends StatelessWidget {
  final WellBadge badge;
  const _WellBadge({required this.badge});
  @override
  Widget build(BuildContext c) {
    final ok = badge.tone == 'green';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ok
            ? AppColors.brand100.withOpacity(.9)
            : AppColors.red100.withOpacity(.9),
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

class WellEditScreen extends StatelessWidget {
  final Well? well;
  final VoidCallback onBack;
  const WellEditScreen({super.key, required this.well, required this.onBack});
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
    children: [
      PageHeading(
        title: well?.ad ?? 'Kuyu Düzenle',
        subtitle: 'Kuyu bilgilerini güncelleyin',
        onBack: onBack,
      ),
      const SizedBox(height: 20),
      GlassPanel(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        child: Column(
          children: [
            Icon(Icons.edit_outlined, size: 40, color: AppColors.inkFaint),
            const SizedBox(height: 12),
            Text('Düzenleme Ekranı', style: figtree(size: 15, weight: W.bold)),
            const SizedBox(height: 4),
            Text(
              'Bu bölüm yakında aktif olacak.',
              textAlign: TextAlign.center,
              style: figtree(
                size: 13,
                weight: W.medium,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
