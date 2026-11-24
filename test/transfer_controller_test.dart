import 'package:flutter_test/flutter_test.dart';
import 'package:pecunia/models/currency.dart';
import 'package:pecunia/models/wallet.dart';
import 'package:pecunia/widgets/transfer/transfer_controller.dart';

Wallet _wallet(int id, String code) => Wallet(
  id: id,
  name: 'Wallet $id',
  currency: Currency(code: code, name: code, symbol: code, flag: ''),
  description: '',
  showBalance: true,
  isRoundUp: false,
);

void main() {
  group('TransferController', () {
    test('isOk requires both wallets, different IDs, and positive amount', () {
      final w1 = _wallet(1, 'USD');
      final w2 = _wallet(2, 'USD');
      final ctrl = TransferController(initialFrom: w1);

      ctrl.total.text = '100';
      expect(ctrl.isOk(), isFalse);

      ctrl.to = w1;
      expect(ctrl.hasWalletError, isTrue);
      expect(ctrl.isOk(), isFalse);

      ctrl.to = w2;
      expect(ctrl.hasWalletError, isFalse);
      expect(ctrl.amount.number, 100);
      expect(ctrl.isOk(), isTrue);

      ctrl.dispose();
    });

    test('calculates total with exchange rate and division toggle', () {
      final w1 = _wallet(1, 'EUR');
      final w2 = _wallet(2, 'USD');
      final ctrl = TransferController(initialFrom: w1, initialTo: w2);

      expect(ctrl.differentCurrencies, isTrue);

      ctrl.amount.text = '100';
      ctrl.exchangeRate.text = '1.1';
      expect(ctrl.total.number, 110);

      ctrl.toggleDivisionSign();
      expect(ctrl.divisionSign, isTrue);
      expect(ctrl.total.number, 90.91);

      ctrl.dispose();
    });

    test('swapWallets flips source and destination wallets', () {
      final w1 = _wallet(1, 'EUR');
      final w2 = _wallet(2, 'USD');
      final ctrl = TransferController(initialFrom: w1, initialTo: w2);

      ctrl.swapWallets();
      expect(ctrl.from?.id, 2);
      expect(ctrl.to?.id, 1);

      ctrl.dispose();
    });
  });
}
