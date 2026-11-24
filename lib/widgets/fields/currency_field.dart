import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/models/currency.dart';
import 'package:pecunia/providers/settings_notifier.dart';
import 'package:pecunia/styles/app_border_style.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/styles/app_text_style.dart';
import 'package:pecunia/util/app_spaces.dart';
import 'package:pecunia/widgets/app_bottom_sheet.dart';
import 'package:pecunia/widgets/empty_state_view.dart';

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
      _CurrencyPickerSheet(
        selectedCode: currency?.code,
        favoriteCode: favoriteCode,
      ),
    );
    if (selected != null) {
      onChange(selected);
    }
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.selectedCode,
    required this.favoriteCode,
  });

  final String? selectedCode;
  final String? favoriteCode;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late final List<Currency> _allCurrencies;
  late List<Currency> _filtered;

  @override
  void initState() {
    super.initState();
    _allCurrencies = _buildOrderedList();
    _filtered = _allCurrencies;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  List<Currency> _buildOrderedList() {
    final all = const CurrencyService().getAll();
    final favCode = widget.favoriteCode;
    if (favCode == null || favCode.isEmpty) return all;

    final favorite = <Currency>[];
    final rest = <Currency>[];
    for (final c in all) {
      if (c.code == favCode) {
        favorite.add(c);
      } else {
        rest.add(c);
      }
    }
    return [...favorite, ...rest];
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _allCurrencies;
      } else {
        _filtered = _allCurrencies
            .where(
              (c) =>
                  c.code.toLowerCase().contains(query) ||
                  c.name.toLowerCase().contains(query) ||
                  c.symbol.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight * 0.65,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyle.text14w600(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchPlaceholder,
                  hintStyle: AppTextStyle.text14w400(
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          color: isDark ? Colors.white54 : Colors.black54,
                          onPressed: _searchController.clear,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          AppSpaces.v8,
          Expanded(
            child: _filtered.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: l10n.emptySearchTitle,
                    subtitle: l10n.emptySearchDesc,
                    accentColor: Colors.grey,
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 0.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    itemBuilder: (_, index) {
                      final item = _filtered[index];
                      final isSelected = item.code == widget.selectedCode;

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.of(context).pop(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Text(
                                item.flag,
                                style: const TextStyle(fontSize: 22),
                              ),
                              AppSpaces.h12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.code,
                                      style: AppTextStyle.text14w600(
                                        color: isSelected
                                            ? AppColors.accentIndigo
                                            : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.text12w400(
                                        color: AppColors.neutralSecondary(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpaces.h12,
                              Text(
                                item.symbol,
                                style: AppTextStyle.text16w600(
                                  color: isSelected
                                      ? AppColors.accentIndigo
                                      : AppColors.neutralSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
