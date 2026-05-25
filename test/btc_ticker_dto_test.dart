import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper/features/game/data/dtos/btc_ticker_dto.dart';

void main() {
  group('BtcTickerDto', () {
    test('parses subscribe stream flat ticker format', () {
      final dto = BtcTickerDto.fromJson({
        'e': '24hrTicker',
        'c': '77334.01000000',
      });
      expect(dto.price, closeTo(77334.01, 0.001));
    });

    test('parses combined stream wrapped format', () {
      final dto = BtcTickerDto.fromJson({
        'stream': 'btcusdt@ticker',
        'data': {'c': '67457.50'},
      });
      expect(dto.price, 67457.50);
    });

    test('ignores subscription ack payloads', () {
      final dto = BtcTickerDto.fromJson({'result': null, 'id': 1});
      expect(dto.price, 0);
    });
  });
}
