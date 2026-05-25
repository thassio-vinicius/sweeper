import 'package:sweeper/features/game/domain/entities/game_entities.dart';

abstract class BtcPriceRepository {
  Stream<BtcPrice> watchPrice();

  Future<void> connect();

  Future<void> disconnect();
}
