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
