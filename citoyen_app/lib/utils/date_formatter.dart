import 'package:intl/intl.dart';

class DateFormatter {
  /// Formate une date en chaîne de caractères "JJ/MM/AAAA".
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formate une date en chaîne de caractères "AAAA-MM-JJ".
  /// Utile pour l'envoi de dates à une API ou pour les champs de saisie de date.
  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formate une date et heure en chaîne de caractères "JJ/MM/AAAA HH:mm".
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formate une date et heure en chaîne de caractères complète "JJ MMMM AAAA à HH:mm".
  static String formatFullDateTime(DateTime date) {
    return DateFormat('dd MMMM yyyy à HH:mm', 'fr').format(date); // 'fr' pour les noms de mois en français
  }
}
