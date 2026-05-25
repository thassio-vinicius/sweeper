import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:sweeper/features/game/data/dtos/btc_ticker_dto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BinanceWebSocketDataSource {
  BinanceWebSocketDataSource({
    this.url = 'wss://stream.binance.com:9443/ws',
  });

  final String url;

  WebSocketChannel? _channel;
  StreamController<BtcTickerDto>? _controller;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _reconnectTimer;
  bool _disposed = false;

  Stream<BtcTickerDto> get priceStream {
    _ensureController();
    return _controller!.stream;
  }

  void _ensureController() {
    _controller ??= StreamController<BtcTickerDto>.broadcast();
  }

  Future<void> connect() async {
    _disposed = false;
    _ensureController();
    await _openChannel();
  }

  Future<void> disconnect() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;
    await _controller?.close();
    _controller = null;
  }

  Future<void> _openChannel() async {
    if (_disposed) return;

    await _channelSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.sink.add(
        jsonEncode({
          'id': 1,
          'method': 'SUBSCRIBE',
          'params': ['btcusdt@ticker'],
        }),
      );

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _scheduleReconnect,
        cancelOnError: false,
      );
    } catch (e, st) {
      dev.log('Binance WS connect error', error: e, stackTrace: st);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;

      // Subscription acknowledgement: {"result":null,"id":1}
      if (json.containsKey('result') && !json.containsKey('data')) {
        return;
      }

      final dto = BtcTickerDto.fromJson(json);
      if (dto.price > 0) {
        _controller?.add(dto);
      }
    } catch (e, st) {
      dev.log('Binance WS parse error', error: e, stackTrace: st);
    }
  }

  void _onError(Object error) {
    dev.log('Binance WS error', error: error);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), _openChannel);
  }
}
