import 'package:intl/intl.dart';

extension DoubleExtension on double {
  static final NumberFormat _roundedFormat = NumberFormat("#,##0", "en_US");
  static final NumberFormat _decimalFormat = NumberFormat("#,##0.00", "en_US");

  String get formatSum => formatSumCustom(roundUp: false);

  String formatSumCustom({bool roundUp = false}) =>
      (roundUp ? _roundedFormat : _decimalFormat)
          .format(this)
          .replaceAll(',', ' ');

  String get formatDouble => _decimalFormat.format(this).replaceAll(',', ' ');
}
