import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

String formatCurrency(num value) => _currency.format(value);
