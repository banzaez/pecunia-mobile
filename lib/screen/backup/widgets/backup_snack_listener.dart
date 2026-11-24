import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pecunia/l10n/app_localizations.dart';
import 'package:pecunia/router/app_router.dart';
import 'package:pecunia/screen/backup/backup_controller.dart';

class BackupSnackListener extends ConsumerWidget {
  const BackupSnackListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    ref.listen<BackupState>(backupNotifierProvider, (prev, next) {
      final msg = next.snackType;
      if (msg == null || msg == prev?.snackType) return;

      final text = switch (msg) {
        BackupSnackType.saved => l10n.backupSavedSuccess,
        BackupSnackType.restored => l10n.backupRestoredSuccess,
        BackupSnackType.deleted => l10n.backupDeletedSuccess,
        BackupSnackType.formatError => l10n.backupErrorMsg,
        BackupSnackType.cancelled => l10n.backupCancelled,
        BackupSnackType.error => l10n.error,
      };

      if (msg == BackupSnackType.cancelled) {
        ref.read(backupNotifierProvider.notifier).clearSnack();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: next.isError ? Colors.red : Colors.green,
        ),
      );

      ref.read(backupNotifierProvider.notifier).clearSnack();

      if (msg == BackupSnackType.restored && context.mounted) {
        context.go(AppRoute.home.path);
      }
    });

    return child;
  }
}
