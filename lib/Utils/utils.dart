import 'dart:ui';

class Utils {
  static String? calculateRemainingMinutes(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
// 解析年、月、日、小时和分钟
    int year = int.parse(dateString.substring(0, 4));
    int month = int.parse(dateString.substring(4, 6));
    int day = int.parse(dateString.substring(6, 8));
    int hour = int.parse(dateString.substring(9, 11));
    int minute = int.parse(dateString.substring(12, 14));

    // 创建DateTime对象
    DateTime dateTime = DateTime(year, month, day, hour, minute);
    DateTime now = DateTime.now();

    Duration difference = dateTime.difference(now);
    if (difference.isNegative) {
      return "0 minutes,";
    }
    if (difference.inMinutes.toString() == "1") {
      return "${difference.inMinutes.toString()} minute";
    }
    return "${difference.inMinutes.toString()} minutes";
  }

  static Color? hexToColor(String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    code = code.replaceAll("#", "");
    return Color(int.parse(code, radix: 16) + 0xFF000000);
  }
}
