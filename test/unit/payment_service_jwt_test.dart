import 'package:flutter_test/flutter_test.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// JWT decode smoke (no live Supabase required).
void main() {
  test('jwt_decoder reads exp from sample JWT', () {
    const jwt =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
    final exp = JwtDecoder.getExpirationDate(jwt);
    expect(exp.isAfter(DateTime.now()), isTrue);
  });
}
