import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecunia/data/sql/sql_provider.dart';
import 'package:pecunia/providers/sql_provider_ref.dart';
import 'package:pecunia/providers/transaction_notifier.dart';
import 'package:pecunia/providers/wallet_notifier.dart';
import 'package:pecunia/util/ext_datetime.dart';
import 'package:pecunia/util/sqlite_file.dart';

enum BackupSnackType {
  saved,
  restored,
  deleted,
  formatError,
  cancelled,
  error,
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class BackupState {
  final String filename;
  final int sizeKb;
  final bool isLoading;
  final BackupSnackType? snackType;
  final bool isError;

  const BackupState({
    this.filename = '',
    this.sizeKb = 0,
    this.isLoading = false,
    this.snackType,
    this.isError = false,
  });

  BackupState copyWith({
    String? filename,
    int? sizeKb,
    bool? isLoading,
    BackupSnackType? snackType,
    bool? isError,
    bool clearSnack = false,
  }) => BackupState(
    filename: filename ?? this.filename,
    sizeKb: sizeKb ?? this.sizeKb,
    isLoading: isLoading ?? this.isLoading,
    snackType: clearSnack ? null : (snackType ?? this.snackType),
    isError: isError ?? this.isError,
  );
}

// ---------------------------------------------------------------------------
// BackupNotifier
// ---------------------------------------------------------------------------

class BackupNotifier extends Notifier<BackupState> {
  @override
  BackupState build() {
    final sqlProvider = ref.read(sqlProviderProvider);
    Future.microtask(() async {
      try {
        final file = File(sqlProvider.databasePath);
        final sizeKb = await file.exists() ? (await file.length()) ~/ 1024 : 0;
        state = state.copyWith(filename: sqlProvider.filename, sizeKb: sizeKb);
      } catch (_) {}
    });
    return const BackupState();
  }

  Future<void> _refreshSize() async {
    try {
      final file = File(ref.read(sqlProviderProvider).databasePath);
      final sizeKb = await file.exists() ? (await file.length()) ~/ 1024 : 0;
      state = state.copyWith(sizeKb: sizeKb);
    } catch (_) {}
  }

  Future<void> _refreshAll() async {
    await ref.read(walletNotifierProvider.notifier).refreshWallets();
    await ref.read(transactionNotifierProvider.notifier).refreshAll();
  }

  // -----------BACKUP---------------------------------------------------------------------------

  Future<void> archiving() async {
    state = state.copyWith(isLoading: true, clearSnack: true);
    File? backupFile;
    try {
      final sqlProvider = ref.read(sqlProviderProvider);
      final backupPath = await sqlProvider.createBackupSnapshot();
      backupFile = File(backupPath);

      final savedPath = await FilePicker.saveFile(
        fileName: "pecunia_backup_${DateTime.now().toFormat("yyyyMMdd")}.db",
        bytes: await backupFile.readAsBytes(),
      );

      if (savedPath == null) {
        state = state.copyWith(
          isLoading: false,
          snackType: BackupSnackType.cancelled,
          isError: false,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        snackType: BackupSnackType.saved,
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        snackType: BackupSnackType.error,
        isError: true,
      );
    } finally {
      if (backupFile != null && await backupFile.parent.exists()) {
        await backupFile.parent.delete(recursive: true);
      }
    }
  }

  Future<void> _deleteWalSidecars(String dbPath) async {
    for (final suffix in const ['-wal', '-shm']) {
      final sidecar = File('$dbPath$suffix');
      if (await sidecar.exists()) {
        await sidecar.delete();
      }
    }
  }

  Future<bool> recovery() async {
    final result = await FilePicker.pickFiles();
    if (result.isEmpty) return false;

    final path = result.single.path;
    if (path == null) {
      state = state.copyWith(
        snackType: BackupSnackType.formatError,
        isError: true,
      );
      return false;
    }
    final backupFile = File(path);

    if (!await isSqliteFile(backupFile) ||
        !await SQLProvider.validateBackupDatabase(path)) {
      state = state.copyWith(
        snackType: BackupSnackType.formatError,
        isError: true,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearSnack: true);
    try {
      final sqlProvider = ref.read(sqlProviderProvider);
      await sqlProvider.close();
      await _deleteWalSidecars(sqlProvider.databasePath);
      await backupFile.copy(sqlProvider.databasePath);
      await sqlProvider.init();
      await _refreshAll();
      await _refreshSize();
      state = state.copyWith(
        isLoading: false,
        snackType: BackupSnackType.restored,
        isError: false,
      );
      return true;
    } catch (e) {
      final sqlProvider = ref.read(sqlProviderProvider);
      await sqlProvider.init();
      state = state.copyWith(
        isLoading: false,
        snackType: BackupSnackType.error,
        isError: true,
      );
      return false;
    }
  }

  void clearSnack() => state = state.copyWith(clearSnack: true);

  void showMessage(BackupSnackType type, {bool isError = false}) {
    state = state.copyWith(snackType: type, isError: isError);
  }
}

final backupNotifierProvider = NotifierProvider<BackupNotifier, BackupState>(
  BackupNotifier.new,
);
