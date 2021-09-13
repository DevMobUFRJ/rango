
## testando o app

O arquivo de teste fica em /test/widget_test.dart
Nesse arquivo tem um único teste que é responsável por: Logar, confirmar uma reserva, adicionar uma nova quentinha e fechar a loja.

Para testar local:
 * Coloque o email e senha no arquivo widget_test.dart nas linhas 11 e 12
 * execute o comando:
  ``` flutter drive --flavor ${flavor} --driver=test/test_driver/driver.dart --target=test/widget_test.dart --dart-define=MAPS_KEY=${MAPS_KEY} --dart-define=MESSAGING_KEY=${MESSAGING_KEY}
 alterando ${flavor}, ${MAPS_KEY} e ${MESSAGING_KEY} ```
 Executado corretamente, esse comando irá efetuar o teste no celular que estiver conectado na máquina.

Para testar no TestLab do Firebase:
 * Coloque o email e senha no arquivo widget_test.dart nas linhas 11 e 12
 * Substitua as keys nos próprios arquivos:
    * android/app/build.gradle, altere de dartEnvironmentVariables.MAPS_KEY para a própria key
    * de MESSAGING_KEY para a própria key nos arquivos ChatScreen.dart, OrderContainer.dart
 * execute o comando: ```pushd android
flutter build apk --flavor ${flavor}
./gradlew app:assembleAndroidTest 
./gradlew app:assembleDebug -Ptarget=test/widget_test.dart 
popd ```
alterando ${flavor}
Executado corretamente, esse comando irá criar alguns apks.
1. ``` rango/build/app/outputs/apk/${flavor}/debug ```
2. ``` rango/build/app/outputs/apk/androidTest/${flavor}/debug ```

 * Acesse o Firebase > Test Lab > Executar um teste > Instrumentação > APK do app > selecione o 1
 APK de teste > selecione o 2.
 Selecione um dispositivo e prossiga.
Obs: para esse teste, o login deve ser válido, a loja deve estar aberta, e deve existir um pedido para esse vendedor.