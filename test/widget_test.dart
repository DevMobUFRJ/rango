import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:rango/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final email = "xxx@yy.com";
  final senha = "000";
  testWidgets('Login, reservar, adicionar novo prato e fechar loja',
      (WidgetTester tester) async {
    //usando o firebase
    await Firebase.initializeApp();

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    //preenchendo dados do login
    await tester.tap(find.byKey(Key('login')));
    await tester.pumpAndSettle();
    final elementEmail = find.byKey(Key('email'));
    await tester.tap(elementEmail);
    await tester.enterText(elementEmail, email);
    final elementSenha = find.byKey(Key('password'));
    await tester.tap(elementSenha);
    await tester.enterText(elementSenha, senha);
    await tester.pump(const Duration(milliseconds: 1000));

    //Botao de Logar
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    //confirmar reserva
    final checkboxFinder = find.byType(Checkbox).first;
    await tester.tap(checkboxFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    //acessa a tab de quentinhas
    final tab = find.byIcon(Icons.local_dining);
    await tester.tap(tab);
    await tester.pump(const Duration(milliseconds: 2000));

    //clica no botao Adicionar
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    //preenche os dados
    final nomePrato = find.byKey(Key('nomeprato'));
    await tester.tap(nomePrato);
    await tester.enterText(nomePrato, 'nome de prato novinho');

    final descricao = find.byKey(Key('descricao'));
    await tester.tap(descricao);
    await tester.enterText(descricao, 'descrição nova');

    final preco = find.byKey(Key('preco'));
    await tester.tap(preco);
    await tester.enterText(preco, '10');

    final quantidade = find.byKey(Key('quantidade'));
    await tester.tap(quantidade);
    await tester.enterText(quantidade, '10');
    await tester.pump(const Duration(milliseconds: 2000));

    //adicionar
    await tester.tap(find.byType(ElevatedButton).first);

    await tester.pump(const Duration(milliseconds: 2000));

    //acessa o perfil
    final profile = find.byIcon(Icons.person);
    await tester.tap(profile);
    await tester.pump(const Duration(milliseconds: 2000));

    //fechando a loja
    final fechaabre = find.byKey(Key('fechaabre'));
    await tester.tap(fechaabre);
    await tester.pump(const Duration(milliseconds: 2000));
    final txtFecha = find.text("Fechar");
    await tester.tap(txtFecha);
    await tester.pump(const Duration(milliseconds: 2000));
  });
}
