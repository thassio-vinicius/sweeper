import 'dart:async';

import 'package:sweeper_game/data/datasources/binance_ws.dart';
import 'package:sweeper_game/domain/entities/game_entities.dart';
import 'package:sweeper_game/domain/repositories/btc_price_repository.dart';

class BtcPriceRepositoryImpl implements BtcPriceRepository {
  BtcPriceRepositoryImpl(this._dataSource);

  final BinanceWebSocketDataSource _dataSource;

  @override
  Stream<BtcPrice> watchPrice() {
    return _dataSource.priceStream.map(
      (dto) => BtcPrice(priceUsd: dto.price, receivedAt: DateTime.now()),
    );
  }

  @override
  Future<void> connect() => _dataSource.connect();

  @override
  Future<void> disconnect() => _dataSource.disconnect();
}
