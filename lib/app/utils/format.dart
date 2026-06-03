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

String formatLastSeen(dynamic timestamp) {
  if (timestamp == null) return "";

  final lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();

  final now = DateTime.now();

  final isToday =
      now.year == lastSeen.year &&
      now.month == lastSeen.month &&
      now.day == lastSeen.day;

  if (isToday) {
    return DateFormat("HH:mm").format(lastSeen);
  }

  return DateFormat("dd/MM/yyyy HH:mm").format(lastSeen);
}

String formatChatDate(dynamic timestamp) {
  if (timestamp == null) return "";

  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  return DateFormat("EEEE, dd MMMM yyyy").format(date);
}

String formatChatTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  return DateFormat("HH:mm").format(date);
}

///GAP MESSAGE
bool isSameMinuteGroup(int current, int next) {
  final diff = next - current;
  return diff <= 60; // 60 detik = 1 menit
}
