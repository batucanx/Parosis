import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Referanstaki dört net kolonu, küçük ekranlarda da hizalı tutar.
class StatementLayoutHead extends StatelessWidget {
  const StatementLayoutHead();
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
  const StatementLayoutCard({required this.row});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.96),
      border: Border.all(color: const Color(0xFFE8F0EF)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF083E38).withOpacity(.09),
          blurRadius: 10,
          spreadRadius: -6,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        SizedBox(
          width: 70,
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
          child: Text(
            row.aciklama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtree(size: 13, weight: W.bold, tracking: Tracking.tight),
          ),
        ),
        SizedBox(
          width: 62,
          child: Text(
            row.yukleme == null ? '—' : '+${formatTL(row.yukleme!)}',
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
            row.harcama == null ? '—' : '-${formatTL(row.harcama!)}',
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
