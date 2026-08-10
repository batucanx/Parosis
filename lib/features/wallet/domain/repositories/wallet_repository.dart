import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wallet/domain/entities/statement_row.dart';

abstract interface class WalletRepository {
  Future<Result<int>> getBalance();
  Future<Result<List<StatementRow>>> getStatement();

  /// Credits [amount] TL to the balance and returns the resulting balance.
  Future<Result<int>> topUp(int amount);
}
