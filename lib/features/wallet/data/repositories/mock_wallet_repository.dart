import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wallet/domain/entities/statement_row.dart';
import 'package:parosis_sulama/features/wallet/domain/repositories/wallet_repository.dart';

/// `payment_cards`/`well_bookings` ile aynı desende kullanıcıya özel: her
/// gerçek kullanıcı **0 TL bakiye ve boş hesap ekstresiyle** başlar; sadece
/// sabit demo hesap (`SLM-10001`) örnek geçmişle gelir. Gerçek bir top-up,
/// cihazda kalıcı olarak saklanır ve hesap ekstresinde hemen görünür.
final class MockWalletRepository implements WalletRepository {
  MockWalletRepository({required String? Function() currentUserId})
    : _currentUserId = currentUserId;

  final String? Function() _currentUserId;

  static const _demoUserId = 'SLM-10001';
  static const _balanceKeyPrefix = 'wallet_balance_v1_';
  static const _statementKeyPrefix = 'wallet_statement_v1_';

  int? _balance;
  List<StatementRow>? _statement;
  String? _cacheUserId;

  int _seedBalance() => 450;

  List<StatementRow> _seedStatement() => [
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

  Map<String, dynamic> _toJson(StatementRow r) => {
    'id': r.id,
    'occurredAt': r.occurredAt.toIso8601String(),
    'description': r.description,
    'topUpAmount': r.topUpAmount,
    'spendAmount': r.spendAmount,
  };

  StatementRow _fromJson(Map<String, dynamic> json) => StatementRow(
    id: json['id'] as String,
    occurredAt: DateTime.parse(json['occurredAt'] as String),
    description: json['description'] as String,
    topUpAmount: json['topUpAmount'] as int?,
    spendAmount: json['spendAmount'] as int?,
  );

  Future<void> _ensureLoaded() async {
    final userId = _currentUserId();
    if (_cacheUserId == userId && _balance != null) return;
    _cacheUserId = userId;

    if (userId == null) {
      _balance = 0;
      _statement = const [];
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final balanceKey = '$_balanceKeyPrefix$userId';
    final statementKey = '$_statementKeyPrefix$userId';
    final rawBalance = prefs.getInt(balanceKey);

    if (rawBalance == null) {
      // İlk açılış: sadece demo hesap örnek geçmişle başlar.
      _balance = userId == _demoUserId ? _seedBalance() : 0;
      _statement = userId == _demoUserId ? _seedStatement() : const [];
      if (userId == _demoUserId) await _persist();
    } else {
      final rawStatement = prefs.getString(statementKey);
      _balance = rawBalance;
      _statement = rawStatement == null
          ? const []
          : (jsonDecode(rawStatement) as List)
                .map((e) => _fromJson(e as Map<String, dynamic>))
                .toList();
    }
  }

  Future<void> _persist() async {
    final userId = _currentUserId();
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_balanceKeyPrefix$userId', _balance!);
    await prefs.setString(
      '$_statementKeyPrefix$userId',
      jsonEncode(_statement!.map(_toJson).toList()),
    );
  }

  @override
  Future<Result<int>> getBalance() async {
    await _ensureLoaded();
    return Result.ok(_balance!);
  }

  @override
  Future<Result<List<StatementRow>>> getStatement() async {
    await _ensureLoaded();
    return Result.ok(List.unmodifiable(_statement!));
  }

  @override
  Future<Result<int>> topUp(int amount) async {
    await _ensureLoaded();
    _balance = _balance! + amount;
    _statement = [
      StatementRow(
        id: 'wtx-${DateTime.now().microsecondsSinceEpoch}',
        occurredAt: DateTime.now(),
        description: 'Bakiye yükleme',
        topUpAmount: amount,
      ),
      ..._statement!,
    ];
    await _persist();
    return Result.ok(_balance!);
  }
}
