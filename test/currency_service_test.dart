import 'package:flutter_test/flutter_test.dart';
import 'package:pecunia/models/currency.dart';

void main() {
  const service = CurrencyService();

  test('getAll returns unique ISO currency codes', () {
    final all = service.getAll();
    final codes = all.map((c) => c.code).toSet();

    expect(all.length, greaterThan(130));
    expect(codes.length, all.length);
  });

  test('findByCode is case-insensitive and handles unknown codes', () {
    expect(service.findByCode('usd')?.code, 'USD');
    expect(service.findByCode('eur')?.symbol, '€');
    expect(service.findByCode('crc')?.code, 'CRC');
    expect(service.findByCode(''), isNull);
    expect(service.findByCode(null), isNull);
    expect(service.findByCode('UNKNOWN'), isNull);
  });
}
