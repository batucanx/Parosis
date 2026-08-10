import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wallet/domain/entities/statement_row.dart';
import 'package:parosis_sulama/features/wallet/domain/repositories/wallet_repository.dart';

final class MockWalletRepository implements WalletRepository {
  int _balance = 450;

  final List<StatementRow> _statement = [
    StatementRow(
      id: 'e1',
      occurredAt: DateTime(2026, 8, 2),
      description: 'Bakiye yükleme',
      topUpAmount: 150,
    ),
    StatementRow(
      id: 'e2',
      occurredAt: DateTime(2026, 8, 1),
      description: 'Sulama · Yayla',
      spendAmount: 85,
    ),
    StatementRow(
      id: 'e3',
      occurredAt: DateTime(2026, 7, 31),
      description: 'Sulama · Ova 2',
      spendAmount: 60,
    ),
    StatementRow(
      id: 'e4',
      occurredAt: DateTime(2026, 7, 29),
      description: 'Sulama · Ova 1',
      spendAmount: 120,
    ),
    StatementRow(
      id: 'e5',
      occurredAt: DateTime(2026, 7, 27),
      description: 'Bakiye yükleme',
      topUpAmount: 200,
    ),
    StatementRow(
      id: 'e6',
      occurredAt: DateTime(2026, 7, 24),
      description: 'Sulama · Ova 1',
      spendAmount: 65,
    ),
    StatementRow(
      id: 'e7',
      occurredAt: DateTime(2026, 6, 28),
      description: 'Bakiye yükleme',
      topUpAmount: 300,
    ),
    StatementRow(
      id: 'e8',
      occurredAt: DateTime(2026, 6, 20),
      description: 'Sulama · Yayla',
      spendAmount: 95,
    ),
    StatementRow(
      id: 'e9',
      occurredAt: DateTime(2026, 5, 15),
      description: 'Sulama · Ova 1',
      spendAmount: 70,
    ),
    StatementRow(
      id: 'e10',
      occurredAt: DateTime(2026, 5, 3),
      description: 'Bakiye yükleme',
      topUpAmount: 500,
    ),
    StatementRow(
      id: 'e11',
      occurredAt: DateTime(2026, 4, 22),
      description: 'Sulama · Menderes',
      spendAmount: 110,
    ),
    StatementRow(
      id: 'e12',
      occurredAt: DateTime(2026, 4, 8),
      description: 'Bakiye yükleme',
      topUpAmount: 250,
    ),
    StatementRow(
      id: 'e13',
      occurredAt: DateTime(2026, 3, 25),
      description: 'Sulama · Bağ',
      spendAmount: 45,
    ),
    StatementRow(
      id: 'e14',
      occurredAt: DateTime(2026, 3, 18),
      description: 'Sulama · Ova 2',
      spendAmount: 80,
    ),
    StatementRow(
      id: 'e15',
      occurredAt: DateTime(2026, 3, 10),
      description: 'Bakiye yükleme',
      topUpAmount: 400,
    ),
    StatementRow(
      id: 'e16',
      occurredAt: DateTime(2026, 3, 2),
      description: 'Sulama · Ova 1',
      spendAmount: 130,
    ),
    StatementRow(
      id: 'e17',
      occurredAt: DateTime(2026, 2, 14),
      description: 'Bakiye yükleme',
      topUpAmount: 200,
    ),
    StatementRow(
      id: 'e18',
      occurredAt: DateTime(2026, 1, 5),
      description: 'Sulama · Yayla',
      spendAmount: 55,
    ),
  ];

  int _nextStatementId = 19;

  @override
  Future<Result<int>> getBalance() async => Result.ok(_balance);

  @override
  Future<Result<List<StatementRow>>> getStatement() async =>
      Result.ok(List.unmodifiable(_statement));

  @override
  Future<Result<int>> topUp(int amount) async {
    _balance += amount;
    _statement.insert(
      0,
      StatementRow(
        id: 'e${_nextStatementId++}',
        occurredAt: DateTime.now(),
        description: 'Bakiye yükleme',
        topUpAmount: amount,
      ),
    );
    return Result.ok(_balance);
  }
}
