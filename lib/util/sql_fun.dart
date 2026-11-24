import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';
import 'package:pecunia/models/finance_categories.dart';
import 'package:pecunia/models/finance_category.dart';

final CurrencyService _currencyService = CurrencyService();
final DateFormat _sqlDateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");

DateTime toDateTime(String value) => DateTime.parse(
      value.endsWith('Z') ? value.substring(0, value.length - 1) : value,
    );

String fromDateTime(DateTime value) => _sqlDateFormat.format(value);

int? fromCategory(FinanceCategory? category) => category?.id;

FinanceCategory? toCategory(int? value) =>
    value == null ? null : FinanceCategories.getCategoryById(value);

Currency? toCurrency(String value) => _currencyService.findByCode(value);

String fromCurrency(Currency? currency) => currency?.code ?? "";
