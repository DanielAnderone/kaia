import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaia_app/main.dart';

void main() {
  testWidgets('Login screen renders correctly with button and fields', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Elementos base
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.text('Forgot your password ?'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);

    // Botão LOGIN e cor verde
    final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
    expect(loginButton, findsOneWidget);
    final ElevatedButton btn = tester.widget(loginButton);
    final ButtonStyle style = btn.style!;
    final Color? bg = style.backgroundColor?.resolve({});
    expect(bg, const Color(0xFF22C55E)); // verde correto
  });
}
