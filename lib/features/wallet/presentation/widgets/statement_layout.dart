import 'package:flutter/material.dart';

import 'package:parosis_sulama/core/formatting/currency_formatter.dart';
import 'package:parosis_sulama/core/formatting/turkish_date_formatter.dart';
import 'package:parosis_sulama/features/wallet/domain/entities/statement_row.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';

/// Referanstaki dört net kolonu, küçük ekranlarda da hizalı tutar.
class StatementLayoutHead extends StatelessWidget {
  const StatementLayoutHead({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        SizedBox(width: 70, child: _StatementLabel('TARİH')),
        Expanded(child: _StatementLabel('AÇIKLAMA')),
        SizedBox(
          width: 62,
          child: _StatementLabel('YÜKLEME', align: TextAlign.right),
        ),
        SizedBox(
          width: 58,
          child: _StatementLabel('HARCAMA', align: TextAlign.right),
        ),
      ],
    ),
  );
}

class _StatementLabel extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _StatementLabel(this.text, {this.align = TextAlign.left});
  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    textAlign: align,
    style: figtree(
      size: 9.5,
      weight: W.bold,
      color: AppColors.inkFaint,
      tracking: Tracking.widest,
    ),
  );
}

class StatementLayoutCard extends StatelessWidget {
  final StatementRow row;
  const StatementLayoutCard({super.key, required this.row});
  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: BorderRadius.circular(18),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            formatTurkishShortDate(row.occurredAt),
            style: figtree(
              size: 12,
              weight: W.semibold,
              color: AppColors.inkFaint,
            ),
          ),
        ),
        Expanded(
          child: Text(
            row.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtree(size: 13, weight: W.bold, tracking: Tracking.tight),
          ),
        ),
        SizedBox(
          width: 62,
          child: Text(
            row.topUpAmount == null ? '—' : '+${formatTL(row.topUpAmount!)}',
            textAlign: TextAlign.right,
            style: figtree(
              size: 12,
              weight: W.extrabold,
              color: AppColors.brand600,
            ),
          ),
        ),
        SizedBox(
          width: 58,
          child: Text(
            row.spendAmount == null ? '—' : '-${formatTL(row.spendAmount!)}',
            textAlign: TextAlign.right,
            style: figtree(
              size: 12,
              weight: W.extrabold,
              color: AppColors.red500,
            ),
          ),
        ),
      ],
    ),
  );
}
