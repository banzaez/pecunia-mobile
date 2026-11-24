import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecunia/screen/home/home_controller.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/styles/app_text_style.dart';
import 'package:pecunia/widgets/dialogs/dialog_choose_wallet.dart';

class CurrentWallet extends ConsumerWidget {
  const CurrentWallet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWallet = ref.watch(
      homeNotifierProvider.select((s) => s.currentWallet),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = currentWallet?.name ?? '—';
    final currency = currentWallet?.currency?.code ?? '';

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.07);
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final muted = AppColors.neutralSecondary(context);
    const accent = AppColors.accentIndigo;

    return DialogChooseWallet(
      onChanged: (value) {
        if (value != null) {
          ref.read(homeNotifierProvider.notifier).selectWallet(value);
        }
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 17,
                color: accent,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text14w600(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (currency.isNotEmpty)
                    Text(
                      currency,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text10w400(color: muted),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more_rounded, size: 18, color: muted),
          ],
        ),
      ),
    );
  }
}
