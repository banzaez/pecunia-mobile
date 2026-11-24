import 'package:material_ui/material_ui.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/models/currency.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/styles/app_text_style.dart';
import 'package:pecunia/util/app_spaces.dart';
import 'package:pecunia/widgets/empty_state_view.dart';

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    super.key,
    required this.selectedCode,
    required this.favoriteCode,
  });

  final String? selectedCode;
  final String? favoriteCode;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late final List<Currency> _allCurrencies;
  late final ValueNotifier<List<Currency>> _filteredNotifier;

  @override
  void initState() {
    super.initState();
    _allCurrencies = _buildOrderedList();
    _filteredNotifier = ValueNotifier<List<Currency>>(_allCurrencies);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _filteredNotifier.dispose();
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
    if (query.isEmpty) {
      _filteredNotifier.value = _allCurrencies;
      return;
    }

    _filteredNotifier.value = _allCurrencies
        .where(
          (c) =>
              c.code.toLowerCase().contains(query) ||
              c.name.toLowerCase().contains(query) ||
              c.symbol.toLowerCase().contains(query),
        )
        .toList();
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
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (_, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            color: isDark ? Colors.white54 : Colors.black54,
                            onPressed: _searchController.clear,
                          ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          AppSpaces.v8,
          Expanded(
            child: ValueListenableBuilder<List<Currency>>(
              valueListenable: _filteredNotifier,
              builder: (_, filtered, _) {
                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: l10n.emptySearchTitle,
                    subtitle: l10n.emptySearchDesc,
                    accentColor: Colors.grey,
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  itemBuilder: (_, index) {
                    final item = filtered[index];
                    final isSelected = item.code == widget.selectedCode;
                    final isFavorite = item.code == widget.favoriteCode;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
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
                                    Row(
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
                                        if (isFavorite) ...[
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: AppColors.accentIndigo,
                                          ),
                                        ],
                                      ],
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
