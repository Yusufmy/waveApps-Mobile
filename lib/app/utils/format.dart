import 'package:intl/intl.dart';

String formatHour(String? date) {
  if (date == null || date.trim().isEmpty) {
    return "";
  }

  try {
    final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date).toLocal();

    return DateFormat('HH:mm').format(dateTime);
  } catch (e) {
    print("FORMAT ERROR: $e");
    return "";
  }
}
