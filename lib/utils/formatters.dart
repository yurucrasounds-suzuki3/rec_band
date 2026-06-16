import 'package:intl/intl.dart';

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'たった今';
  }

  return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
}
