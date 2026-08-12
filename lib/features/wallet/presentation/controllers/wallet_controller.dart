import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wallet/domain/entities/statement_row.dart';
import 'package:parosis_sulama/features/wallet/domain/repositories/wallet_repository.dart';

final class WalletController extends ChangeNotifier {
  WalletController({required WalletRepository repository})
    : _repository = repository {
    _load();
  }

  final WalletRepository _repository;

  int _balance = 0;
  List<StatementRow> _statement = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  Object? _error;

  int get balance => _balance;
  List<StatementRow> get statement => _statement;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  Object? get error => _error;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.getBalance()) {
      case Ok<int>(:final value):
        _balance = value;
      case Error<int>(:final error):
        _error = error;
    }

    switch (await _repository.getStatement()) {
      case Ok<List<StatementRow>>(:final value):
        _statement = value;
      case Error<List<StatementRow>>(:final error):
        _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  /// Returns whether the top-up succeeded.
  Future<bool> topUp(int amount) async {
    if (_isSubmitting || amount <= 0) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.topUp(amount)) {
      case Ok<int>(:final value):
        _balance = value;
        success = true;
        // Repository yeni satırı zaten kalıcı olarak ekledi — ekranın
        // hemen göstermesi için ekstreyi de yeniden çekiyoruz, yoksa bu
        // controller bir sonraki refresh()'e kadar eski listede kalırdı.
        switch (await _repository.getStatement()) {
          case Ok<List<StatementRow>>(value: final statement):
            _statement = statement;
          case Error<List<StatementRow>>():
          // Bakiye güncellendi; ekstre bir sonraki refresh()'te düzelir.
        }
      case Error<int>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }
}
