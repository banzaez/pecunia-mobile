import 'package:pecunia/models/currency.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pecunia/models/wallet.dart';

/// Чистый ChangeNotifier — заменяет GetxController для SettingWallet формы.
class SettingWalletController extends ChangeNotifier {
  SettingWalletController({
    required Wallet? wallet,
    Currency? defaultCurrency,
  }) {
    this.wallet = wallet ?? Wallet.empty();
    _init(defaultCurrency);
  }

  late Wallet wallet;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  Currency? _currency;
  Currency? get currency => _currency;
  set currency(Currency? value) {
    _currency = value;
    notifyListeners();
  }

  bool _showBalance = true;
  bool get showBalance => _showBalance;
  set showBalance(bool value) {
    _showBalance = value;
    notifyListeners();
  }

  bool _isRoundUp = true;
  bool get isRoundUp => _isRoundUp;
  set isRoundUp(bool value) {
    _isRoundUp = value;
    notifyListeners();
  }

  String? errorName;
  String? errorCurrency;

  // ----------INIT------------------------------------------------------------------------------

  void _init(Currency? defaultCurrency) {
    nameController.text = wallet.name;
    descriptionController.text = wallet.description;
    _currency = wallet.id == 0 ? defaultCurrency : wallet.currency;
    _showBalance = wallet.showBalance;
    _isRoundUp = wallet.isRoundUp;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ----------VALUES----------------------------------------------------------------------------

  void updateValues() {
    wallet.name = nameController.text.trim();
    wallet.description = descriptionController.text.trim();
    wallet.currency = _currency;
    wallet.showBalance = _showBalance;
    wallet.isRoundUp = _isRoundUp;
  }

  bool isOk(String nameError, String currencyError) {
    errorName = nameController.text.trim().isEmpty ? nameError : null;
    errorCurrency = _currency == null ? currencyError : null;
    notifyListeners();
    return errorName == null && errorCurrency == null;
  }
}
