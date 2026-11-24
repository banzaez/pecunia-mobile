import 'package:material_ui/material_ui.dart';
import 'package:pecunia/models/wallet.dart';
import 'package:pecunia/widgets/fields/number_field.dart';

/// Чистый ChangeNotifier — заменяет GetxController для Transfer формы.
class TransferController extends ChangeNotifier {
  final NumberEditingController amount = NumberEditingController();
  final NumberEditingController exchangeRate = NumberEditingController();
  final NumberEditingController total = NumberEditingController();

  bool differentCurrencies = false;
  bool enableDone = false;
  bool divisionSign = false;
  bool hasWalletError = false;
  bool _isUpdating = false;

  Wallet? _from;
  Wallet? get from => _from;
  set from(Wallet? wallet) {
    _from = wallet;
    changeWallet();
  }

  Wallet? _to;
  Wallet? get to => _to;
  set to(Wallet? wallet) {
    _to = wallet;
    changeWallet();
  }

  TransferController({Wallet? initialFrom, Wallet? initialTo}) {
    _from = initialFrom;
    _to = initialTo;
    amount.addListener(_onAmountChanged);
    exchangeRate.addListener(_onAmountChanged);
    total.addListener(_onTotalChanged);
    if (_from != null || _to != null) {
      changeWallet();
    }
  }

  @override
  void dispose() {
    amount.removeListener(_onAmountChanged);
    exchangeRate.removeListener(_onAmountChanged);
    total.removeListener(_onTotalChanged);
    amount.dispose();
    exchangeRate.dispose();
    total.dispose();
    super.dispose();
  }

  // ----------CHANGES---------------------------------------------------------------------------

  void swapWallets() {
    final prevFrom = _from;
    _from = _to;
    _to = prevFrom;
    changeWallet();
  }

  void toggleDivisionSign() {
    divisionSign = !divisionSign;
    changeAmount();
  }

  void changeWallet() {
    _isUpdating = true;
    try {
      exchangeRate.number = 1;
      differentCurrencies =
          _from != null &&
          _to != null &&
          _from?.currency?.code != _to?.currency?.code;
      hasWalletError = _from != null && _to != null && _from?.id == _to?.id;

      if (differentCurrencies) {
        if (amount.number <= 0 && total.number > 0) {
          amount.number = total.number;
        }
        _recalculateTotalFromAmount();
      } else {
        amount.number = total.number;
      }

      checkEnableDone();
    } finally {
      _isUpdating = false;
    }
    notifyListeners();
  }

  void _onAmountChanged() {
    if (_isUpdating) return;
    changeAmount();
  }

  void _recalculateTotalFromAmount() {
    final rate = exchangeRate.number;
    final raw = divisionSign
        ? (rate == 0 ? 0.0 : amount.number / rate)
        : amount.number * rate;
    total.number = double.tryParse(raw.toStringAsFixed(2)) ?? 0;
  }

  void changeAmount() {
    if (!differentCurrencies) return;

    _isUpdating = true;
    try {
      _recalculateTotalFromAmount();
      checkEnableDone();
    } finally {
      _isUpdating = false;
    }
    notifyListeners();
  }

  void _onTotalChanged() {
    if (_isUpdating) return;
    changeTotal();
  }

  void changeTotal() {
    _isUpdating = true;
    try {
      if (!differentCurrencies) {
        amount.number = total.number;
      }
      checkEnableDone();
    } finally {
      _isUpdating = false;
    }
    notifyListeners();
  }

  void checkEnableDone() {
    enableDone = isOk();
  }

  // ----------IS OK-----------------------------------------------------------------------------

  bool isOk() {
    if (_from == null || _to == null) return false;
    if (hasWalletError) return false;
    if (amount.number <= 0) return false;
    if (differentCurrencies && exchangeRate.number <= 0) return false;
    if (total.number <= 0) return false;
    return true;
  }
}
