import 'package:flutter_test/flutter_test.dart';
import 'package:pecunia/models/finance_categories.dart';
import 'package:pecunia/models/transaction.dart';
import 'package:pecunia/models/transaction_type.dart';
import 'package:pecunia/widgets/setting_transaction/setting_transaction_controller.dart';

void main() {
  group('SettingTransactionController', () {
    test('rejects zero or empty amount and missing category', () {
      final ctrl = SettingTransactionController(type: TransactionType.expense);

      expect(ctrl.isOk('amount err', 'category err'), isFalse);
      expect(ctrl.errorAmount, 'amount err');
      expect(ctrl.errorCategory, 'category err');

      ctrl.amount.text = '0';
      expect(ctrl.isOk('amount err', 'category err'), isFalse);
      expect(ctrl.errorAmount, 'amount err');

      ctrl.dispose();
    });

    test('clears errors automatically when valid amount and category are set', () {
      final ctrl = SettingTransactionController(type: TransactionType.expense);

      expect(ctrl.isOk('amount err', 'category err'), isFalse);
      expect(ctrl.errorAmount, isNotNull);
      expect(ctrl.errorCategory, isNotNull);

      ctrl.amount.text = '125.50';
      expect(ctrl.errorAmount, isNull);

      ctrl.category = FinanceCategories.foodAndDrinks;
      expect(ctrl.errorCategory, isNull);

      expect(ctrl.isOk('amount err', 'category err'), isTrue);
      ctrl.dispose();
    });

    test('switching type resets category, subcategory, and category error', () {
      final ctrl = SettingTransactionController(type: TransactionType.expense);
      ctrl.category = FinanceCategories.foodAndDrinks;
      ctrl.subcategory = FinanceCategories.foodAndDrinks.subcategories.first;

      ctrl.type = TransactionType.income;
      expect(ctrl.category, isNull);
      expect(ctrl.subcategory, isNull);
      expect(ctrl.errorCategory, isNull);

      ctrl.dispose();
    });

    test('setDatePreservingTime changes day while keeping hour and minute', () {
      final initial = Transaction(
        walletId: 1,
        amount: -50,
        createdAt: DateTime(2026, 11, 24, 14, 35),
        description: '',
      );
      final ctrl = SettingTransactionController(
        type: TransactionType.expense,
        transaction: initial,
      );

      ctrl.setDatePreservingTime(DateTime(2026, 11, 23, 8, 0));
      expect(ctrl.datetime.year, 2026);
      expect(ctrl.datetime.month, 11);
      expect(ctrl.datetime.day, 23);
      expect(ctrl.datetime.hour, 14);
      expect(ctrl.datetime.minute, 35);

      ctrl.dispose();
    });
  });
}
