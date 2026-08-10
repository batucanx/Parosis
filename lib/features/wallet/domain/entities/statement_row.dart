/// A single account-movement line. Exactly one of [topUpAmount] /
/// [spendAmount] is set — the amount is in whole TL.
class StatementRow {
  final String id;
  final DateTime occurredAt;
  final String description;
  final int? topUpAmount;
  final int? spendAmount;

  const StatementRow({
    required this.id,
    required this.occurredAt,
    required this.description,
    this.topUpAmount,
    this.spendAmount,
  });
}
