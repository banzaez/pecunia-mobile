import 'package:material_ui/material_ui.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/models/finance_categories.dart';
import 'package:pecunia/models/finance_category.dart';
import 'package:pecunia/models/transaction_type.dart';
import 'package:pecunia/styles/app_border_style.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/styles/app_text_style.dart';
import 'package:pecunia/util/category_icon_helper.dart';

/// Horizontal 1-tap chip selector for transaction categories and subcategories.
class CategoryChipPicker extends StatelessWidget {
  const CategoryChipPicker({
    super.key,
    required this.type,
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
    this.errorText,
  });

  final TransactionType type;
  final FinanceCategory? selectedCategory;
  final FinanceCategory? selectedSubcategory;
  final ValueChanged<FinanceCategory?> onCategoryChanged;
  final ValueChanged<FinanceCategory?> onSubcategoryChanged;
  final String? errorText;

  List<FinanceCategory> get _categories => type == TransactionType.income
      ? FinanceCategories.incomeCategories
      : FinanceCategories.expenseCategories;

  Color get _accentColor =>
      type == TransactionType.income ? AppColors.income : AppColors.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subcategories = selectedCategory?.subcategories ?? const [];
    final firstRow = <FinanceCategory>[];
    final secondRow = <FinanceCategory>[];
    for (var i = 0; i < _categories.length; i++) {
      if (i.isEven) {
        firstRow.add(_categories[i]);
      } else {
        secondRow.add(_categories[i]);
      }
    }

    Widget buildChip(FinanceCategory item) => _CategoryChip(
      label: item.localizedName(l10n),
      icon: CategoryIconHelper.getIcon(item.name),
      isSelected: selectedCategory == item,
      accentColor: _accentColor,
      hasError: errorText != null && selectedCategory == null,
      onTap: () => onCategoryChanged(item),
    );

    Widget buildRow(List<FinanceCategory> items) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          buildChip(items[i]),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRow(firstRow),
              if (secondRow.isNotEmpty) ...[
                const SizedBox(height: 8),
                buildRow(secondRow),
              ],
            ],
          ),
        ),
        if (subcategories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.06),
                borderRadius: AppBorderStyle.borderRadius,
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        size: 14,
                        color: AppColors.neutralSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.labelSubcategory,
                        style: AppTextStyle.text12w400(
                          color: AppColors.neutralSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sub in subcategories)
                        _CategoryChip(
                          label: sub.localizedName(l10n),
                          icon: CategoryIconHelper.getIcon(sub.name),
                          isSelected: selectedSubcategory == sub,
                          accentColor: _accentColor,
                          compact: true,
                          onTap: () => onSubcategoryChanged(
                            selectedSubcategory == sub ? null : sub,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 32, top: 6),
            child: Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
    this.hasError = false,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;
  final bool hasError;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final borderColor = hasError
        ? AppColors.error
        : isSelected
        ? accentColor
        : AppBorderStyle.borderColor(brightness);
    final backgroundColor = isSelected
        ? accentColor.withValues(alpha: 0.16)
        : AppBorderStyle.fillColor(brightness);
    final foregroundColor = isSelected
        ? accentColor
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderStyle.borderRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppBorderStyle.borderRadius,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 16 : 18, color: foregroundColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyle.text14w400(color: foregroundColor).copyWith(
                  fontSize: compact ? 13 : 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
