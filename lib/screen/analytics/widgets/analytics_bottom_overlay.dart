import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/models/analytics_filter.dart';
import 'package:pecunia/screen/analytics/analytics_controller.dart';
import 'package:pecunia/screen/analytics/analytics_bottom_layout.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/util/app_spaces.dart';
import 'package:pecunia/widgets/fields/app_switch.dart';
import 'package:pecunia/widgets/fields/pick_date/pick_date.dart';

class AnalyticsBottomOverlay extends ConsumerWidget {
  const AnalyticsBottomOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(analyticsNotifierProvider.select((s) => s.filter));
    final date = ref.watch(analyticsNotifierProvider.select((s) => s.date));
    final period = ref.watch(analyticsNotifierProvider.select((s) => s.period));
    final valuesYear = ref.watch(
      analyticsNotifierProvider.select((s) => s.valuesYear),
    );
    final valuesMonth = ref.watch(
      analyticsNotifierProvider.select((s) => s.valuesMonth),
    );
    final valuesDay = ref.watch(
      analyticsNotifierProvider.select((s) => s.valuesDay),
    );
    final baseColor = AppColors.overlayBase(context);
    final panelColor = AppColors.panel(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [baseColor.withValues(alpha: 0.0), panelColor],
            ),
          ),
          child: const SizedBox(height: 24, width: double.infinity),
        ),
        ColoredBox(
          color: panelColor,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              AnalyticsBottomLayout.panelPadding +
                  AnalyticsBottomLayout.bottomInset(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSwitch(
                  onChange: (value) => ref
                      .read(analyticsNotifierProvider.notifier)
                      .setFilter(value),
                  values: List.generate(
                    AnalyticsFilter.values.length,
                    (i) => AppSwitchValue(
                      label: AnalyticsFilter.values[i].label(l10n),
                      value: AnalyticsFilter.values[i],
                      color: i == 0
                          ? Colors.green
                          : i == 1
                          ? Colors.red
                          : null,
                    ),
                  ),
                  value: filter,
                ),
                AppSpaces.v16,
                PickDate(
                  onChanged: (value, type) {
                    if (value == null) return;
                    ref
                        .read(analyticsNotifierProvider.notifier)
                        .setDate(value, type);
                  },
                  initDate: date,
                  enableTime: false,
                  isYearSelected: period == DateType.year,
                  isMonthSelected: period == DateType.month,
                  isDaySelected: period == DateType.day,
                  valuesYear: valuesYear,
                  valuesMonth: valuesMonth,
                  valuesDay: valuesDay,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
