import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/models/finance_categories.dart';
import 'package:pecunia/models/transaction.dart';
import 'package:pecunia/providers/transaction_notifier.dart';
import 'package:pecunia/providers/wallet_notifier.dart';
import 'package:pecunia/styles/app_border_style.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/styles/app_text_style.dart';
import 'package:pecunia/util/app_spaces.dart';
import 'package:pecunia/util/ext_double.dart';
import 'package:pecunia/util/sheet_save.dart';
import 'package:pecunia/widgets/app_bottom_sheet.dart';
import 'package:pecunia/widgets/fields/number_field.dart';
import 'package:pecunia/widgets/fields/wallet_field.dart';
import 'package:pecunia/widgets/text_error.dart';
import 'package:pecunia/widgets/transfer/transfer_controller.dart';

class TransferSheet extends ConsumerStatefulWidget {
  const TransferSheet({super.key});

  @override
  ConsumerState<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<TransferSheet> {
  late TransferController _ctrl;

  @override
  void initState() {
    super.initState();
    final activeWalletId = ref.read(transactionNotifierProvider).walletId;
    final wallets = ref.read(walletNotifierProvider).wallets;
    final initialFrom = wallets
        .where((w) => w.id == activeWalletId)
        .firstOrNull;
    final initialTo = wallets.length == 2
        ? wallets.where((w) => w.id != activeWalletId).firstOrNull
        : null;

    _ctrl = TransferController(
      initialFrom: initialFrom,
      initialTo: initialTo,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, _) {
        final walletError = _ctrl.hasWalletError
            ? l10n.transferErrorWallet
            : null;
        final singleCurrencySymbol =
            _ctrl.to?.currency?.symbol ?? _ctrl.from?.currency?.symbol;

        return BottomSheetScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.transferTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              AppSpaces.v16,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.from,
                      style: AppTextStyle.text12w400(
                        color: AppColors.neutralSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    WalletField(
                      onChanged: (value) => _ctrl.from = value,
                      initValue: _ctrl.from,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: IconButton(
                          onPressed: _ctrl.swapWallets,
                          icon: const Icon(Icons.swap_vert_rounded),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    Text(
                      l10n.to,
                      style: AppTextStyle.text12w400(
                        color: AppColors.neutralSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    WalletField(
                      onChanged: (value) => _ctrl.to = value,
                      initValue: _ctrl.to,
                    ),
                    if (walletError != null) ...[
                      const SizedBox(height: 6),
                      TextError(text: walletError),
                    ],
                    AppSpaces.v16,
                    if (_ctrl.differentCurrencies) ...[
                      Row(
                        children: [
                          Expanded(
                            child: NumberField(
                              autofocus: true,
                              controller: _ctrl.amount,
                              labelText:
                                  _ctrl.from?.currency?.code ??
                                  l10n.transferAmount,
                              suffixText: _ctrl.from?.currency?.symbol,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          AppSpaces.h12,
                          _exchangeRate(context, l10n),
                        ],
                      ),
                      AppSpaces.v16,
                    ],
                    NumberField(
                      autofocus: !_ctrl.differentCurrencies,
                      controller: _ctrl.total,
                      labelText: _ctrl.differentCurrencies
                          ? (_ctrl.to?.currency?.code ?? l10n.transferTotal)
                          : l10n.transferAmount,
                      suffixText: _ctrl.differentCurrencies
                          ? _ctrl.to?.currency?.symbol
                          : singleCurrencySymbol,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (_ctrl.enableDone) _onDone(context, l10n);
                      },
                    ),
                  ],
                ),
              ),
              AppSpaces.v24,
              BottomSheetActionRow(
                action: ElevatedButton(
                  onPressed: _ctrl.enableDone
                      ? () => _onDone(context, l10n)
                      : null,
                  child: Text(l10n.transferDone),
                ),
              ),
              AppSpaces.v16,
            ],
          ),
        );
      },
    );
  }

  Widget _exchangeRate(BuildContext context, AppLocalizations l10n) => Expanded(
    child: Row(
      children: [
        GestureDetector(
          onTap: _ctrl.toggleDivisionSign,
          child: Container(
            decoration: AppBorderStyle.fieldBox(
              context,
            ).copyWith(color: AppColors.backgroundContent(context)),
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                _ctrl.divisionSign ? "/" : "*",
                style: AppTextStyle.text18w400(),
              ),
            ),
          ),
        ),
        AppSpaces.h8,
        Flexible(
          child: NumberField(
            controller: _ctrl.exchangeRate,
            decimal: 5,
            enabled: _ctrl.differentCurrencies,
            labelText: l10n.transferExchangeRate,
          ),
        ),
      ],
    ),
  );

  Future<void> _onDone(BuildContext context, AppLocalizations l10n) async {
    if (!_ctrl.isOk()) return;

    final from = _ctrl.from;
    final to = _ctrl.to;
    if (from == null || to == null) return;

    final description = l10n.transferDescription(
      from.name,
      to.name,
      _ctrl.exchangeRate.number.toDouble().formatDouble,
    );

    final fromTransaction = Transaction.empty();
    fromTransaction.walletId = from.id;
    fromTransaction.category = FinanceCategories.transfer;
    fromTransaction.description = description;
    fromTransaction.amount = -_ctrl.amount.number.toDouble();

    final toTransaction = Transaction.empty();
    toTransaction.walletId = to.id;
    toTransaction.category = FinanceCategories.transfer;
    toTransaction.description = description;
    toTransaction.amount = _ctrl.total.number.toDouble();

    await saveSheetAndPop(
      context: context,
      validate: () => true,
      applyChanges: () {},
      persist: () => ref
          .read(transactionNotifierProvider.notifier)
          .addTransferSQL(fromTransaction, toTransaction),
      hasError: () => ref.read(transactionNotifierProvider).error != null,
      popResult: true,
    );
  }
}
