class BtcTickerDto {
  const BtcTickerDto({required this.price});

  final double price;

  factory BtcTickerDto.fromJson(Map<String, dynamic> json) {
    // Combined stream: {"stream":"btcusdt@ticker","data":{..."c":"..."}}
    // Direct / SUBSCRIBE stream: {"e":"24hrTicker",..."c":"..."}
    final data = json['data'];
    final Map<String, dynamic> payload = switch (data) {
      final Map<String, dynamic> map => map,
      _ => json,
    };

    final priceStr =
        payload['c'] as String? ?? payload['p'] as String? ?? '0';
    return BtcTickerDto(price: double.tryParse(priceStr) ?? 0);
  }
}
