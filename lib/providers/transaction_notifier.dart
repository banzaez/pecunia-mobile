import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pecunia/models/analytics_total.dart';
import 'package:pecunia/models/transaction.dart';
import 'package:pecunia/providers/sql_provider_ref.dart';

part 'transaction_notifier.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class TransactionState {
  static const int pageSize = 50;

  final int walletId;
  final List<Transaction> transactions;
  final AnalyticsTotal analyticsTotal;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int revision;
  final String? error;

  const TransactionState({
    this.walletId = 0,
    this.transactions = const [],
    AnalyticsTotal? analyticsTotal,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.revision = 0,
    this.error,
  }) : analyticsTotal = analyticsTotal ?? const AnalyticsTotal(0, 0, 0);

  TransactionState copyWith({
    int? walletId,
    List<Transaction>? transactions,
    AnalyticsTotal? analyticsTotal,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? revision,
    String? error,
    bool clearError = false,
  }) =>
      TransactionState(
        walletId: walletId ?? this.walletId,
        transactions: transactions ?? this.transactions,
        analyticsTotal: analyticsTotal ?? this.analyticsTotal,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        revision: revision ?? this.revision,
        error: clearError ? null : (error ?? this.error),
      );
}

// ---------------------------------------------------------------------------
// TransactionNotifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true, name: 'transactionNotifierProvider')
class TransactionNotifier extends _$TransactionNotifier {
  bool _loadMoreInFlight = false;

  @override
  TransactionState build() => const TransactionState();

  // -----------WALLET-SELECTION-----------------------------------------------

  Future<void> changeWallet(int walletId) async {
    state = state.copyWith(walletId: walletId);
    await _syncCurrentWallet(showLoading: true, resetPagination: true);
  }

  // -----------SQL------------------------------------------------------------

  Future<void> refreshAll() async {
    await _syncCurrentWallet(showLoading: true, resetPagination: true);
  }

  /// Перезагружает загруженный диапазон списка и итоги без сброса пагинации
  /// при мутациях, затрагивающих текущий кошелёк.
  Future<void> _syncCurrentWallet({
    bool showLoading = false,
    bool resetPagination = false,
  }) async {
    if (state.walletId <= 0) return;

    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }

    try {
      final sql = ref.read(sqlProviderProvider).transactions;
      final walletId = state.walletId;
      final targetLimit = resetPagination
          ? TransactionState.pageSize
          : math.max(TransactionState.pageSize, state.transactions.length);

      final results = await Future.wait<Object>([
        sql.selectByWalletId(
          walletId,
          limit: targetLimit + 1,
          offset: 0,
        ),
        sql.selectTotalByWallet(walletId),
      ]);

      final fetched = results[0] as List<Transaction>;
      final hasMore = fetched.length > targetLimit;
      final list = hasMore ? fetched.sublist(0, targetLimit) : fetched;
      final analyticsTotal = results[1] as AnalyticsTotal;

      if (state.walletId != walletId) return;

      state = state.copyWith(
        isLoading: false,
        transactions: list,
        hasMore: hasMore,
        analyticsTotal: analyticsTotal,
        revision: state.revision + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool _affectsCurrentWallet(int walletId) => walletId == state.walletId;

  bool _transferAffectsCurrentWallet(Transaction from, Transaction to) =>
      _affectsCurrentWallet(from.walletId) || _affectsCurrentWallet(to.walletId);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading || _loadMoreInFlight) {
      return;
    }

    _loadMoreInFlight = true;
    final walletId = state.walletId;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final sql = ref.read(sqlProviderProvider).transactions;
      final offset = state.transactions.length;
      final fetched = await sql.selectByWalletId(
        walletId,
        limit: TransactionState.pageSize + 1,
        offset: offset,
      );
      if (state.walletId != walletId) return;
      final hasMore = fetched.length > TransactionState.pageSize;
      final pageItems = hasMore
          ? fetched.sublist(0, TransactionState.pageSize)
          : fetched;
      final merged = [...state.transactions, ...pageItems];
      state = state.copyWith(
        transactions: merged,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    } finally {
      _loadMoreInFlight = false;
    }
  }

  Future<void> addSQL(Transaction transaction) async {
    final showLoading = state.transactions.isEmpty;
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }
    try {
      if (transaction.walletId == 0) transaction.walletId = state.walletId;
      await ref.read(sqlProviderProvider).transactions.add(value: transaction);
      if (_affectsCurrentWallet(transaction.walletId)) {
        await _syncCurrentWallet();
      } else if (showLoading) {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateSQL(Transaction transaction) async {
    state = state.copyWith(clearError: true);
    try {
      if (transaction.walletId == 0) transaction.walletId = state.walletId;
      await ref.read(sqlProviderProvider).transactions.update(value: transaction);
      if (_affectsCurrentWallet(transaction.walletId) ||
          state.transactions.any((t) => t.id == transaction.id)) {
        await _syncCurrentWallet();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteSQL(int id) async {
    final affectsList = state.transactions.any((t) => t.id == id);
    if (affectsList) {
      state = state.copyWith(clearError: true);
    }
    try {
      await ref.read(sqlProviderProvider).transactions.delete(id: id);
      if (affectsList) {
        await _syncCurrentWallet();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addTransferSQL(Transaction from, Transaction to) async {
    state = state.copyWith(clearError: true);
    try {
      await ref
          .read(sqlProviderProvider)
          .transactions
          .addBatch(values: [from, to]);
      if (_transferAffectsCurrentWallet(from, to)) {
        await _syncCurrentWallet();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<List<Transaction>> selectByWalletIdAndCategoryAndByPeriod(
    int walletId,
    int categoryId,
    DateTime startDate,
    DateTime endDate,
  ) =>
      ref
          .read(sqlProviderProvider)
          .transactions
          .selectByWalletIdAndCategoryAndByPeriod(
            walletId,
            categoryId,
            startDate,
            endDate,
          );

  void clearError() => state = state.copyWith(clearError: true);
}
