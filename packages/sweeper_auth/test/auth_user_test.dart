import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';

void main() {
  test('AuthUser equality compares all fields', () {
    const a = AuthUser(
      id: '1',
      email: 'a@b.com',
      displayName: 'Alice',
      photoUrl: 'https://example.com/a.png',
    );
    const b = AuthUser(
      id: '1',
      email: 'a@b.com',
      displayName: 'Alice',
      photoUrl: 'https://example.com/a.png',
    );
    const c = AuthUser(id: '1', email: 'a@b.com', displayName: 'Bob');

    expect(a, b);
    expect(a, isNot(c));
  });
}
