import 'package:flutter/material.dart';

import 'package:parosis_sulama/core/formatting/currency_formatter.dart';
import 'package:parosis_sulama/core/formatting/turkish_date_formatter.dart';
import 'package:parosis_sulama/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:parosis_sulama/features/wallet/presentation/widgets/statement_layout.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/page_heading.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

const quickTopUpAmounts = <int>[50, 100, 150, 200, 300, 500];

class BalanceScreen extends StatefulWidget {
  final WalletController walletController;
  final int? lastTopUp;
  final VoidCallback onTopUp;
  const BalanceScreen({
    super.key,
    required this.walletController,
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.walletController,
    builder: (context, _) {
      final statement = widget.walletController.statement;
      final years = {for (final row in statement) row.occurredAt.year}.toList()
        ..sort((a, b) => b.compareTo(a));
      final rows = statement
          .where(
            (row) =>
                (_year == null || row.occurredAt.year == _year) &&
                (_month == null || row.occurredAt.month == _month),
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
                        text: formatTL(widget.walletController.balance),
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
                    color: AppColors.brand700.withValues(alpha: .8),
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
                items: years,
                titleOf: (v) => '$v',
                onChanged: (value) => setState(() {
                  _year = value;
                  _month = null;
                }),
              ),
              const SizedBox(width: 6),
              _Filter<int>(
                value: _month,
                label: _month == null
                    ? 'Tüm Aylar'
                    : turkishMonthNames[_month! - 1],
                items: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                titleOf: (v) => turkishMonthNames[v - 1],
                onChanged: (value) => setState(() => _month = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.walletController.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Hesap hareketleri yükleniyor…',
                textAlign: TextAlign.center,
                style: figtree(
                  size: 13,
                  weight: W.semibold,
                  color: AppColors.inkFaint,
                ),
              ),
            )
          else if (rows.isEmpty)
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
    },
  );
}

class _TopUpNotice extends StatelessWidget {
  final int amount;
  final VoidCallback onClose;
  const _TopUpNotice({required this.amount, required this.onClose});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.brand100.withValues(alpha: .85),
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
              color: AppColors.brand200.withValues(alpha: .6),
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
  static final Object _allSentinel = Object();

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
  Widget build(BuildContext context) => PopupMenuButton<Object>(
    onSelected: (selected) =>
        onChanged(selected == _allSentinel ? null : selected as T),
    itemBuilder: (context) => [
      PopupMenuItem<Object>(
        value: _allSentinel,
        child: Text(label.startsWith('Tüm') ? label : 'Tümü'),
      ),
      ...items.map(
        (v) =>
            PopupMenuItem<Object>(value: v as Object, child: Text(titleOf(v))),
      ),
    ],
    child: Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.mist100.withValues(alpha: .5),
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

class TopUpScreen extends StatefulWidget {
  final Future<bool> Function(int amount) onConfirm;
  const TopUpScreen({super.key, required this.onConfirm});
  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  int get _amount => int.tryParse(_controller.text) ?? 0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final success = await widget.onConfirm(_amount);
    if (!mounted) return;
    if (!success) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final valid = _amount > 0 && !_submitting;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
      children: [
        PageHeading(title: 'Bakiye Yükle', subtitle: 'Tutar seçin veya yazın'),
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
            for (final v in quickTopUpAmounts)
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
          elevated: false,
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
            color: AppColors.amber50.withValues(alpha: .6),
            border: Border.all(color: AppColors.amber200.withValues(alpha: .7)),
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
          onTap: valid ? _confirm : null,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: valid
                  ? AppColors.nearBlack
                  : AppColors.mist200.withValues(alpha: .7),
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
                  _submitting ? 'Yükleniyor…' : 'Yükle',
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
            elevated: false,
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
