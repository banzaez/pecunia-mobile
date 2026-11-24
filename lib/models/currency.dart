class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  final String code;
  final String name;
  final String symbol;
  final String flag;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Currency($code)';
}

class CurrencyService {
  const CurrencyService();

  static const List<Currency> _currencies = [
    Currency(code: 'USD', name: 'United States Dollar', symbol: '\$', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧'),
    Currency(code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴', flag: '🇺🇦'),
    Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', flag: '🇷🇺'),
    Currency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', flag: '🇵🇱'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', flag: '🇨🇭'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: '\$', flag: '🇨🇦'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: '\$', flag: '🇦🇺'),
    Currency(code: 'BYN', name: 'Belarusian Ruble', symbol: 'Br', flag: '🇧🇾'),
    Currency(code: 'KZT', name: 'Kazakhstani Tenge', symbol: '₸', flag: '🇰🇿'),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flag: '🇹🇷'),
    Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', flag: '🇨🇿'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', flag: '🇸🇪'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', flag: '🇳🇴'),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', flag: '🇩🇰'),
    Currency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', flag: '🇭🇺'),
    Currency(code: 'RON', name: 'Romanian Leu', symbol: 'lei', flag: '🇷🇴'),
    Currency(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', flag: '🇧🇬'),
    Currency(code: 'RSD', name: 'Serbian Dinar', symbol: 'din', flag: '🇷🇸'),
    Currency(code: 'MDL', name: 'Moldovan Leu', symbol: 'L', flag: '🇲🇩'),
    Currency(code: 'GEL', name: 'Georgian Lari', symbol: '₾', flag: '🇬🇪'),
    Currency(code: 'AMD', name: 'Armenian Dram', symbol: '֏', flag: '🇦🇲'),
    Currency(code: 'AZN', name: 'Azerbaijani Manat', symbol: '₼', flag: '🇦🇿'),
    Currency(code: 'UZS', name: 'Uzbekistani Som', symbol: "so'm", flag: '🇺🇿'),
    Currency(code: 'KGS', name: 'Kyrgyzstani Som', symbol: 'с', flag: '🇰🇬'),
    Currency(code: 'TJS', name: 'Tajikistani Somoni', symbol: 'SM', flag: '🇹🇯'),
    Currency(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪', flag: '🇮🇱'),
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flag: '🇦🇪'),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flag: '🇸🇦'),
    Currency(code: 'QAR', name: 'Qatari Riyal', symbol: '﷼', flag: '🇶🇦'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', flag: '🇰🇷'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: '\$', flag: '🇸🇬'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: '\$', flag: '🇭🇰'),
    Currency(code: 'TWD', name: 'New Taiwan Dollar', symbol: 'NT\$', flag: '🇹🇼'),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭'),
    Currency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫', flag: '🇻🇳'),
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', flag: '🇮🇩'),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flag: '🇲🇾'),
    Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', flag: '🇵🇭'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: '\$', flag: '🇳🇿'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', flag: '🇧🇷'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$', flag: '🇲🇽'),
    Currency(code: 'ARS', name: 'Argentine Peso', symbol: '\$', flag: '🇦🇷'),
    Currency(code: 'CLP', name: 'Chilean Peso', symbol: '\$', flag: '🇨🇱'),
    Currency(code: 'COP', name: 'Colombian Peso', symbol: '\$', flag: '🇨🇴'),
    Currency(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', flag: '🇵🇪'),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', flag: '🇿🇦'),
    Currency(code: 'EGP', name: 'Egyptian Pound', symbol: '£', flag: '🇪🇬'),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', flag: '🇳🇬'),
    Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', flag: '🇰🇪'),
    Currency(code: 'MAD', name: 'Moroccan Dirham', symbol: 'DH', flag: '🇲🇦'),
    Currency(code: 'ISK', name: 'Icelandic Krona', symbol: 'kr', flag: '🇮🇸'),
    Currency(code: 'BAM', name: 'Bosnia-Herzegovina Mark', symbol: 'KM', flag: '🇧🇦'),
    Currency(code: 'MKD', name: 'Macedonian Denar', symbol: 'ден', flag: '🇲🇰'),
    Currency(code: 'ALL', name: 'Albanian Lek', symbol: 'L', flag: '🇦🇱'),
    Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: '₨', flag: '🇵🇰'),
    Currency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳', flag: '🇧🇩'),
    Currency(code: 'LKR', name: 'Sri Lankan Rupee', symbol: '₨', flag: '🇱🇰'),
    Currency(code: 'NPR', name: 'Nepalese Rupee', symbol: '₨', flag: '🇳🇵'),
  ];

  static final Map<String, Currency> _byCode = {
    for (final c in _currencies) c.code: c,
  };

  List<Currency> getAll() => _currencies;

  Currency? findByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return _byCode[code.toUpperCase()];
  }
}
