import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/models/wallet.dart';
import 'package:pecunia/providers/wallet_notifier.dart';
import 'package:pecunia/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:pecunia/styles/app_colors.dart';
import 'package:pecunia/styles/app_text_style.dart';

class WalletItem extends ConsumerWidget {
  const WalletItem({super.key, required this.wallet, required this.isEditing});

  final Wallet wallet;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Colors.white10
        : Colors.black.withValues(alpha: 0.04);
    final avatarBgColor = isDark
        ? Colors.white10
        : Colors.black.withValues(alpha: 0.08);
    final avatarTextColor = AppColors.neutralSecondary(context);

    return Card(
      color: cardColor,
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarBgColor,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                wallet.currency?.code ?? "",
                maxLines: 1,
                style: AppTextStyle.text14w600(color: avatarTextColor),
              ),
            ),
          ),
        ),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "${l10n.walletItemName}: ",
                style: AppTextStyle.text12w400(),
              ),
              TextSpan(text: wallet.name),
            ],
          ),
        ),
        subtitle: wallet.description.isNotEmpty
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${l10n.walletItemDescription}: ",
                      style: AppTextStyle.text12w400(),
                    ),
                    TextSpan(text: wallet.description),
                  ],
                ),
              )
            : null,
        trailing: isEditing
            ? IconButton(
                onPressed: () => _onDelete(context, ref),
                icon: const Icon(Icons.close, color: AppColors.edit),
              )
            : null,
      ),
    );
  }

  // --------------------------------------------------------------------------------------------

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirmDismiss(context);
    if (confirmed != true) return;
    await ref.read(walletNotifierProvider.notifier).deleteSQL(wallet.id);
  }

  Future<bool?> _confirmDismiss(BuildContext context) =>
      showConfirmDeleteDialog(context);
}
