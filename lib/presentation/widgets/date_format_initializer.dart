// lib/core/utils/date_format_initializer.dart
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initializeDateFormattingBR() async {
  await initializeDateFormatting('pt_BR', null);
}