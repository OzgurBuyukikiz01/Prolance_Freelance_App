import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class Counter {
  Future<int> read();
}

class MockCounter extends Mock implements Counter {}

void main() {
  test('mocktail stubs async methods', () async {
    final c = MockCounter();
    when(() => c.read()).thenAnswer((_) async => 42);
    expect(await c.read(), 42);
    verify(() => c.read()).called(1);
  });
}
