abstract class Clock {
  DateTime now();

  Stream<int> periodic(Duration interval);
}

class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now();

  @override
  Stream<int> periodic(Duration interval) =>
      Stream.periodic(interval, (tick) => tick);
}

class FakeClock implements Clock {
  FakeClock([DateTime? initial]) : _now = initial ?? DateTime(2024, 1, 1);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  @override
  Stream<int> periodic(Duration interval) =>
      Stream.periodic(interval, (tick) => tick);
}
