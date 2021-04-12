import 'package:intl/intl.dart';

String intToCurrency(int number) {
  final formatter = new NumberFormat("#,##0.00", "pt_BR");
  return "R\$ " + formatter.format(number / 100);
}