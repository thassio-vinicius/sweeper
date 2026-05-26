import 'package:equatable/equatable.dart';

class BtcPrice extends Equatable {
  const BtcPrice({required this.priceUsd, required this.receivedAt});

  final double priceUsd;
  final DateTime receivedAt;

  /// Whole-dollar value shown in the UI (matches [formatBtcPrice] rounding).
  static int wholeDollars(double priceUsd) => priceUsd.round();

  int get wholeDollarPrice => wholeDollars(priceUsd);

  int get integerPrice => wholeDollarPrice;

  bool get isDivisibleByFive => wholeDollarPrice % 5 == 0;

  /// Whether [currentWhole] just landed on a whole dollar ending in 0 or 5.
  static int? landedOnDivisibleWhole(int? previousWhole, int currentWhole) {
    if (previousWhole == null || previousWhole == currentWhole) return null;
    if (currentWhole % 5 != 0) return null;
    return currentWhole;
  }

  @override
  List<Object?> get props => [priceUsd, receivedAt];
}
