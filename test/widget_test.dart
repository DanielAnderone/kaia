import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaia_app/main.dart';

void main() {
  testWidgets('Login screen renders correctly with button and fields', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Verifica se a tela carrega
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    // Botão LOGIN existe
    final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
    expect(loginButton, findsOneWidget);

    // Verifica cores aproximadas: botão cinza claro
    final ElevatedButton buttonWidget = tester.widget<ElevatedButton>(loginButton);
    final ButtonStyle style = buttonWidget.style!;
    final Color? bg = style.backgroundColor?.resolve({});
    expect(bg, const Color(0xFFD9D9D9)); // botão cinza claro

    // Textos adicionais
    expect(find.text('Forgot your password ?'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
  });
}
