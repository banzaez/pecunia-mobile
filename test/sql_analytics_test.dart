import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pecunia/models/analytics_filter.dart';
import 'package:pecunia/models/finance_categories.dart';
import 'package:pecunia/models/transaction.dart';
import 'package:pecunia/models/wallet.dart';
import 'package:pecunia/data/sql/sql_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late SQLProvider sqlProvider;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pecunia_sql_analytics_test_');
    sqlProvider = SQLProvider(databasePath: '${tempDir.path}/pecunia.db');
    await sqlProvider.init();
  });

  tearDown(() async {
    await sqlProvider.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('analytics groups expenses by category for month filter', () async {
    final walletId = (await sqlProvider.wallets.selectAll()).first.id;
    final month = DateTime(2024, 6, 15);

    await sqlProvider.transactions.add(
      value: Transaction(
        walletId: walletId,
        amount: -50,
        category: FinanceCategories.foodAndDrinks,
        createdAt: month,
        description: 'lunch',
      ),
    );
    await sqlProvider.transactions.add(
      value: Transaction(
        walletId: walletId,
        amount: -30,
        category: FinanceCategories.transport,
        createdAt: month,
        description: 'bus',
      ),
    );
    await sqlProvider.transactions.add(
      value: Transaction(
        walletId: walletId,
        amount: 1000,
        category: FinanceCategories.salary,
        createdAt: month,
        description: 'salary',
      ),
    );

    final expenses = await sqlProvider.analytics.selectByWalletId(
      walletId: walletId,
      filter: AnalyticsFilter.expenses,
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 30),
      detail: false,
    );

    expect(expenses, hasLength(2));
    expect(expenses.every((e) => e.total < 0), isTrue);
  });

  test('transfer between two wallets writes to both wallet ids', () async {
    final defaultWallet = (await sqlProvider.wallets.selectAll()).first;

    final secondWallet = Wallet(
      name: 'EUR',
      currency: defaultWallet.currency,
      description: '',
      showBalance: true,
      isRoundUp: true,
    );
    await sqlProvider.wallets.add(value: secondWallet);

    final wallets = await sqlProvider.wallets.selectAll();
    final walletA = wallets.first.id;
    final walletB = wallets.last.id;

    await sqlProvider.transactions.addBatch(
      values: [
        Transaction(
          walletId: walletA,
          amount: -200,
          category: FinanceCategories.transfer,
          createdAt: DateTime(2024, 3, 1),
          description: 'out',
        ),
        Transaction(
          walletId: walletB,
          amount: 200,
          category: FinanceCategories.transfer,
          createdAt: DateTime(2024, 3, 1),
          description: 'in',
        ),
      ],
    );

    final listA = await sqlProvider.transactions.selectByWalletId(walletA);
    final listB = await sqlProvider.transactions.selectByWalletId(walletB);

    expect(listA.single.amount, -200);
    expect(listB.single.amount, 200);
  });
}
