import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wallet/domain/entities/statement_row.dart';

abstract interface class WalletRepository {
  Future<Result<int>> getBalance();
  Future<Result<List<StatementRow>>> getStatement();

  Future<Result<int>> topUp(int amount);
}
