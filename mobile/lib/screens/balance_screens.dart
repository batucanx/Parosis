import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass.dart';
import '../widgets/page_heading.dart';
import '../widgets/pressable_scale.dart';
import 'statement_layout.dart';

class BalanceScreen extends StatefulWidget {
  final int balance;
  final int? lastTopUp;
  final VoidCallback onTopUp;
  const BalanceScreen({
    super.key,
    required this.balance,
    required this.lastTopUp,
    required this.onTopUp,
  });
  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  int? _year;
  int? _month;
  bool _noticeHidden = false;
  @override
  Widget build(BuildContext context) {
    final rows = statement
        .where(
          (row) =>
              (_year == null || row.year == _year) &&
              (_month == null || row.month == _month),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Bakiyem',
            style: figtree(
              size: 21,
              weight: W.extrabold,
              tracking: Tracking.tight,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (widget.lastTopUp != null && !_noticeHidden) ...[
          _TopUpNotice(
            amount: widget.lastTopUp!,
            onClose: () => setState(() => _noticeHidden = true),
          ),
          const SizedBox(height: 20),
        ],
        GlassPanel(
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: [
              Text(
                'Kullanılabilir Bakiye',
                style: figtree(
                  size: 15,
                  weight: W.bold,
                  color: AppColors.inkSoft,
                  tracking: Tracking.tight,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: formatTL(widget.balance),
                      style: figtree(
                        size: 42,
                        weight: W.extrabold,
                        color: AppColors.ink,
                        tracking: Tracking.tight,
                      ),
                    ),
                    TextSpan(
                      text: ' TL',
                      style: figtree(
                        size: 20,
                        weight: W.bold,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PressableScale(
          scale: .98,
          onTap: widget.onTopUp,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.brand600,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand700.withOpacity(.8),
                  blurRadius: 24,
                  spreadRadius: -12,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcons.plus(size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Bakiye Yükle',
                  style: figtree(
                    size: 15,
                    weight: W.extrabold,
                    color: Colors.white,
                    tracking: Tracking.tight,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Hesap Ekstresi',
                style: figtree(
                  size: 17,
                  weight: W.extrabold,
                  tracking: Tracking.tight,
                ),
              ),
            ),
            _Filter<int>(
              value: _year,
              label: _year?.toString() ?? 'Tüm Yıllar',
              items: const [2026],
              titleOf: (v) => '$v',
              onChanged: (value) => setState(() {
                _year = value;
                _month = null;
              }),
            ),
            const SizedBox(width: 6),
            _Filter<int>(
              value: _month,
              label: _month == null ? 'Tüm Aylar' : monthLabels[_month]!,
              items: monthLabels.keys.toList(),
              titleOf: (v) => monthLabels[v]!,
              onChanged: (value) => setState(() => _month = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Bu döneme ait işlem bulunamadı.',
              textAlign: TextAlign.center,
              style: figtree(
                size: 13,
                weight: W.semibold,
                color: AppColors.inkFaint,
              ),
            ),
          )
        else ...[
          const StatementLayoutHead(),
          const SizedBox(height: 10),
          for (final row in rows) ...[
            StatementLayoutCard(row: row),
            const SizedBox(height: 8),
          ],
        ],
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            'Tutarlar TL cinsindendir.',
            style: figtree(
              size: 12,
              weight: W.medium,
              color: AppColors.inkFaint,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopUpNotice extends StatelessWidget {
  final int amount;
  final VoidCallback onClose;
  const _TopUpNotice({required this.amount, required this.onClose});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.brand100.withOpacity(.85),
      border: Border.all(color: AppColors.brand200),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.brand600,
            shape: BoxShape.circle,
          ),
          child: Center(child: AppIcons.check(size: 20, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${formatTL(amount)} TL bakiyenize eklendi.',
            style: figtree(size: 14, weight: W.bold, color: AppColors.brand700),
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.brand200.withOpacity(.6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcons.x(size: 14, color: AppColors.brand700),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Filter<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<T> items;
  final String Function(T) titleOf;
  final ValueChanged<T?> onChanged;
  const _Filter({
    required this.value,
    required this.label,
    required this.items,
    required this.titleOf,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => PopupMenuButton<T?>(
    onSelected: onChanged,
    itemBuilder: (context) => [
      PopupMenuItem<T?>(
        value: null,
        child: Text(label.startsWith('Tüm') ? label : 'Tümü'),
      ),
      ...items.map((v) => PopupMenuItem<T?>(value: v, child: Text(titleOf(v)))),
    ],
    child: Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.mist100.withOpacity(.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: figtree(size: 12, weight: W.bold, color: AppColors.inkSoft),
          ),
          const SizedBox(width: 4),
          AppIcons.chevronDown(size: 12, color: AppColors.inkFaint),
        ],
      ),
    ),
  );
}

class _StatementHead extends StatelessWidget {
  const _StatementHead();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      _FixedText('TARİH', 54),
      Expanded(flex: 19, child: _SmallHead('AÇIKLAMA')),
      Expanded(child: _SmallHead('YÜKLEME', align: TextAlign.right)),
      Expanded(child: _SmallHead('HARCAMA', align: TextAlign.right)),
    ],
  );
}

class _FixedText extends StatelessWidget {
  final String text;
  final double width;
  const _FixedText(this.text, this.width);
  @override
  Widget build(BuildContext c) =>
      SizedBox(width: width, child: _SmallHead(text));
}

class _SmallHead extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _SmallHead(this.text, {this.align = TextAlign.left});
  @override
  Widget build(BuildContext c) => Text(
    text,
    textAlign: align,
    style: figtree(
      size: 9.5,
      weight: W.bold,
      color: AppColors.inkFaint,
      tracking: Tracking.widest,
    ),
  );
}

class _StatementCard extends StatelessWidget {
  final StatementRow row;
  const _StatementCard({required this.row});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF1F5F9)),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            row.tarih,
            style: figtree(
              size: 12,
              weight: W.semibold,
              color: AppColors.inkFaint,
            ),
          ),
        ),
        Expanded(
          flex: 19,
          child: Text(
            row.aciklama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtree(size: 13, weight: W.bold, tracking: Tracking.tight),
          ),
        ),
        Expanded(
          child: Text(
            row.yukleme == null ? '—' : '+${formatTL(row.yukleme!)}',
            textAlign: TextAlign.right,
            style: figtree(
              size: 12,
              weight: W.extrabold,
              color: AppColors.brand600,
              tracking: Tracking.tight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            row.harcama == null ? '—' : '−${formatTL(row.harcama!)}',
            textAlign: TextAlign.right,
            style: figtree(
              size: 12,
              weight: W.extrabold,
              color: AppColors.red500,
              tracking: Tracking.tight,
            ),
          ),
        ),
      ],
    ),
  );
}

class TopUpScreen extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<int> onConfirm;
  const TopUpScreen({super.key, required this.onBack, required this.onConfirm});
  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _controller = TextEditingController();
  int get _amount => int.tryParse(_controller.text) ?? 0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _amount > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
      children: [
        PageHeading(
          title: 'Bakiye Yükle',
          subtitle: 'Tutar seçin veya yazın',
          onBack: widget.onBack,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Hızlı Seçim',
            style: figtree(
              size: 14,
              weight: W.extrabold,
              tracking: Tracking.tight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final v in quickAmounts)
              SizedBox(
                width: (MediaQuery.sizeOf(context).width - 60) / 3,
                height: 48,
                child: _AmountButton(
                  amount: v,
                  selected: _amount == v,
                  onTap: () => setState(() => _controller.text = '$v'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Kendi Tutarınız',
            style: figtree(
              size: 14,
              weight: W.extrabold,
              tracking: Tracking.tight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassPanel(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: figtree(size: 16, weight: W.extrabold),
                    decoration: InputDecoration(
                      hintText: 'Tutar giriniz',
                      hintStyle: figtree(
                        size: 14,
                        weight: W.semibold,
                        color: AppColors.inkFaint,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Text(
                  'TL',
                  style: figtree(
                    size: 14,
                    weight: W.bold,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.amber50.withOpacity(.6),
            border: Border.all(color: AppColors.amber200.withOpacity(.7)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 17,
                color: AppColors.amber400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bakiye işlemlerini yukarıdan hızlı seçimden seçerek yapabilirsiniz. Test sürecinde olduğu için bakiyeniz direkt olarak yüklenir.',
                  style: figtree(
                    size: 12,
                    weight: W.semibold,
                    color: AppColors.amber800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PressableScale(
          scale: .98,
          onTap: valid ? () => widget.onConfirm(_amount) : null,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: valid
                  ? AppColors.nearBlack
                  : AppColors.mist200.withOpacity(.7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcons.plus(
                  size: 20,
                  color: valid ? Colors.white : AppColors.mist600,
                ),
                const SizedBox(width: 10),
                Text(
                  valid ? 'Yükle' : 'Tutar Seçin',
                  style: figtree(
                    size: 15,
                    weight: W.extrabold,
                    color: valid ? Colors.white : AppColors.mist600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountButton extends StatelessWidget {
  final int amount;
  final bool selected;
  final VoidCallback onTap;
  const _AmountButton({
    required this.amount,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext c) => PressableScale(
    scale: .97,
    onTap: onTap,
    child: selected
        ? Container(
            decoration: BoxDecoration(
              color: AppColors.brand600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$amount TL',
                style: figtree(
                  size: 14,
                  weight: W.extrabold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : GlassPanel(
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                '$amount TL',
                style: figtree(
                  size: 14,
                  weight: W.extrabold,
                  tracking: Tracking.tight,
                ),
              ),
            ),
          ),
  );
}
