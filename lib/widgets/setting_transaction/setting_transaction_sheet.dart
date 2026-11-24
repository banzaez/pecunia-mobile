import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/models/transaction.dart';
import 'package:pecunia/models/transaction_type.dart';
import 'package:pecunia/providers/transaction_notifier.dart';
import 'package:pecunia/providers/wallet_notifier.dart';
import 'package:pecunia/styles/app_border_style.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/styles/app_text_style.dart';
import 'package:pecunia/util/app_spaces.dart';
import 'package:pecunia/util/ext_datetime.dart';
import 'package:pecunia/util/sheet_save.dart';
import 'package:pecunia/widgets/app_bottom_sheet.dart';
import 'package:pecunia/widgets/fields/app_switch.dart';
import 'package:pecunia/widgets/fields/base_field.dart';
import 'package:pecunia/widgets/fields/number_field.dart';
import 'package:pecunia/widgets/fields/pick_date/pick_date.dart';
import 'package:pecunia/widgets/setting_transaction/category_chip_picker.dart';
import 'package:pecunia/widgets/setting_transaction/setting_transaction_controller.dart';

class SettingTransactionSheet extends ConsumerStatefulWidget {
  const SettingTransactionSheet({
    super.key,
    required this.type,
    this.transaction,
  });

  final TransactionType type;
  final Transaction? transaction;

  @override
  ConsumerState<SettingTransactionSheet> createState() =>
      _SettingTransactionSheetState();
}

class _SettingTransactionSheetState
    extends ConsumerState<SettingTransactionSheet> {
  late SettingTransactionController _ctrl;
  final FocusNode _descriptionFocus = FocusNode();
  bool _showCustomDate = false;

  @override
  void initState() {
    super.initState();
    _ctrl = SettingTransactionController(
      type: widget.type,
      transaction: widget.transaction,
    );
    _showCustomDate =
        widget.transaction != null &&
        !_ctrl.datetime.isToday &&
        !_ctrl.datetime.isYesterday;
  }

  @override
  void dispose() {
    _descriptionFocus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = _ctrl.transaction.id != 0;
    final title = isEditing ? l10n.settingTranTitle : l10n.settingTranTitleNew;

    final targetWalletId = isEditing
        ? _ctrl.transaction.walletId
        : ref.watch(transactionNotifierProvider.select((s) => s.walletId));
    final wallets = ref.watch(walletNotifierProvider.select((s) => s.wallets));
    final activeWallet =
        wallets.where((w) => w.id == targetWalletId).firstOrNull;
    final currencySymbol = activeWallet?.currency?.symbol;

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, _) => BottomSheetScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (activeWallet != null && activeWallet.name.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                activeWallet.name,
                style: AppTextStyle.text12w400(
                  color: AppColors.neutralSecondary(context),
                ),
              ),
            ],
            AppSpaces.v16,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  AppSwitch(
                    onChange: (value) => _ctrl.type = value,
                    values: [
                      AppSwitchValue(
                        label: l10n.settingTranExpenses,
                        value: TransactionType.expense,
                        color: AppColors.expense,
                      ),
                      AppSwitchValue(
                        label: l10n.settingTranIncome,
                        value: TransactionType.income,
                        color: AppColors.income,
                      ),
                    ],
                    value: _ctrl.type,
                  ),
                  AppSpaces.v16,
                  NumberField(
                    autofocus: !isEditing,
                    controller: _ctrl.amount,
                    labelText: l10n.settingTranAmount,
                    suffixText: currencySymbol,
                    errorText: _ctrl.errorAmount,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  ),
                ],
              ),
            ),
            AppSpaces.v16,
            CategoryChipPicker(
              type: _ctrl.type,
              selectedCategory: _ctrl.category,
              selectedSubcategory: _ctrl.subcategory,
              onCategoryChanged: (value) => _ctrl.category = value,
              onSubcategoryChanged: (value) => _ctrl.subcategory = value,
              errorText: _ctrl.errorCategory,
            ),
            AppSpaces.v16,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: BaseField(
                focusNode: _descriptionFocus,
                controller: _ctrl.description,
                minLines: 1,
                maxLines: 3,
                labelText: l10n.settingTranDescription,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
              ),
            ),
            AppSpaces.v16,
            _QuickDateRow(
              datetime: _ctrl.datetime,
              isExpanded: _showCustomDate,
              onSelectToday: () {
                _ctrl.setDatePreservingTime(DateTime.now());
                setState(() => _showCustomDate = false);
              },
              onSelectYesterday: () {
                _ctrl.setDatePreservingTime(
                  DateTime.now().subtract(const Duration(days: 1)),
                );
                setState(() => _showCustomDate = false);
              },
              onToggleCustom: () {
                setState(() => _showCustomDate = !_showCustomDate);
              },
            ),
            if (_showCustomDate) ...[
              AppSpaces.v12,
              PickDate(
                onChanged: (value, type) {
                  if (value != null) _ctrl.setDatetime(value);
                },
                initDate: _ctrl.datetime,
              ),
            ],
            AppSpaces.v24,
            BottomSheetActionRow(
              action: ElevatedButton(
                onPressed: _save,
                child: Text(l10n.settingTranSave),
              ),
            ),
            AppSpaces.v16,
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final transaction = _ctrl.transaction;

    await saveSheetAndPop(
      context: context,
      validate: () =>
          _ctrl.isOk(l10n.tranItemErrorAmount, l10n.tranItemErrorCategory),
      applyChanges: _ctrl.updateValues,
      persist: () async {
        final notifier = ref.read(transactionNotifierProvider.notifier);
        if (transaction.id == 0) {
          await notifier.addSQL(transaction);
        } else {
          await notifier.updateSQL(transaction);
        }
      },
      hasError: () => ref.read(transactionNotifierProvider).error != null,
      popResult: true,
    );
  }
}

class _QuickDateRow extends StatelessWidget {
  const _QuickDateRow({
    required this.datetime,
    required this.isExpanded,
    required this.onSelectToday,
    required this.onSelectYesterday,
    required this.onToggleCustom,
  });

  final DateTime datetime;
  final bool isExpanded;
  final VoidCallback onSelectToday;
  final VoidCallback onSelectYesterday;
  final VoidCallback onToggleCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isToday = datetime.isToday;
    final isYesterday = datetime.isYesterday;
    final isCustomDate = !isToday && !isYesterday;

    final customLabel = isCustomDate
        ? '${datetime.formatDDMMYYYY} · ${datetime.formatHourMin}'
        : datetime.formatHourMin;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          _DatePresetChip(
            label: l10n.dateToday,
            isSelected: isToday && !isExpanded,
            onTap: onSelectToday,
          ),
          const SizedBox(width: 8),
          _DatePresetChip(
            label: l10n.dateYesterday,
            isSelected: isYesterday && !isExpanded,
            onTap: onSelectYesterday,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DatePresetChip(
              label: customLabel,
              icon: isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.calendar_today_rounded,
              isSelected: isExpanded || isCustomDate,
              onTap: onToggleCustom,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePresetChip extends StatelessWidget {
  const _DatePresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final foreground = isSelected
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.78);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderStyle.borderRadius,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppBorderStyle.fillColor(brightness),
            borderRadius: AppBorderStyle.borderRadius,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppBorderStyle.borderColor(brightness),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: foreground),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.text14w400(color: foreground).copyWith(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
