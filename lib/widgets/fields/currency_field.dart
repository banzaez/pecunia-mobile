import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pecunia/models/currency.dart';
import 'package:pecunia/providers/settings_notifier.dart';
import 'package:pecunia/styles/app_border_style.dart';
import 'package:pecunia/styles/app_text_style.dart';
import 'package:pecunia/widgets/app_bottom_sheet.dart';
import 'package:pecunia/widgets/fields/currency_picker_sheet.dart';

class CurrencyField extends ConsumerWidget {
  const CurrencyField({
    super.key,
    required this.onChange,
    required this.currency,
    this.errorText,
  });

  final ValueChanged<Currency> onChange;
  final Currency? currency;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCode = ref.watch(
      settingsNotifierProvider.select((s) => s.currency?.code),
    );
    return GestureDetector(
      onTap: () => _showCurrencyPicker(context, favoriteCode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: AppBorderStyle.fieldBox(context),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    currency?.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(currency?.symbol ?? ""),
                const SizedBox(width: 8),
                Text(currency?.code ?? ""),
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                errorText!,
                style: AppTextStyle.text12w400(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showCurrencyPicker(
    BuildContext context,
    String? favoriteCode,
  ) async {
    final selected = await appBottomSheet<Currency>(
      context,
      CurrencyPickerSheet(
        selectedCode: currency?.code,
        favoriteCode: favoriteCode,
      ),
    );
    if (selected != null) {
      onChange(selected);
    }
  }
}
