#!/usr/bin/env bash
set -euo pipefail

PUBSPEC_VERSION=$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' pubspec.yaml | head -n 1)
CONST_VERSION=$(sed -nE 's/.*appVersion[[:space:]]*=[[:space:]]*["'\'']([^"'\'']+)["'\''].*/\1/p' lib/util/app_constants.dart | head -n 1)

if [[ -z "$PUBSPEC_VERSION" || -z "$CONST_VERSION" ]]; then
  echo "Ошибка: не удалось прочитать версию из pubspec.yaml ('$PUBSPEC_VERSION') или lib/util/app_constants.dart ('$CONST_VERSION')." >&2
  exit 1
fi

if [[ "$PUBSPEC_VERSION" != "$CONST_VERSION" ]]; then
  echo "Ошибка: версии не совпадают! pubspec.yaml=$PUBSPEC_VERSION, AppConstants.appVersion=$CONST_VERSION" >&2
  exit 1
fi

echo "Версия проверена: $PUBSPEC_VERSION"
flutter build appbundle --release --obfuscate --split-debug-info=symbols/android
