import 'package:intl/intl.dart';

class Formatters {
  static String currency(double value) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String monthYear(String monthRef) {
    // Transforma "01/2025" em "Janeiro 2025"
    try {
      final parts = monthRef.split('/');
      final date = DateTime(int.parse(parts[1]), int.parse(parts[0]));
      return DateFormat('MMMM yyyy', 'pt_BR').format(date).toUpperCase();
    } catch (e) {
      return monthRef;
    }
  }
}