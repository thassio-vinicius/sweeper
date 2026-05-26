import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_game/core/clock.dart';

void main() {
  test('SystemClock.now returns current time', () {
    final before = DateTime.now();
    final clock = SystemClock();
    final after = DateTime.now();

    expect(clock.now().isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
    expect(clock.now().isBefore(after.add(const Duration(seconds: 1))), isTrue);
  });

  test('SystemClock.periodic emits incrementing ticks', () async {
    final clock = SystemClock();
    final ticks = await clock
        .periodic(const Duration(milliseconds: 10))
        .take(3)
        .toList();

    expect(ticks, [0, 1, 2]);
  });
}
