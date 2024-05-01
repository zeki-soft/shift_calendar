import 'package:intl/intl.dart';

class StringUtil {
  static String numToStr(int num) {
    switch (num) {
      case 1:
        return '①';
      case 2:
        return '②';
      case 3:
        return '③';
      case 4:
        return '④';
      case 5:
        return '⑤';
      case 6:
        return '⑥';
      case 7:
        return '⑦';
      case 8:
        return '⑧';
      case 9:
        return '⑨';
      case 10:
        return '⑩';
      case 11:
        return '⑪';
      case 12:
        return '⑫';
      case 13:
        return '⑬';
      case 14:
        return '⑭';
      case 15:
        return '⑮';
      case 16:
        return '⑯';
      case 17:
        return '⑰';
      case 18:
        return '⑱';
      case 19:
        return '⑲';
      case 20:
        return '⑳';
      default:
        return num.toString();
    }
  }

  static final dateFormatter = DateFormat('yyyy/MM/dd');
  static final dateTimeFormatter = DateFormat("y/M/d HH:mm");
  static DateTime strToDatetime(String date, String time) {
    DateTime result;
    // String→DateTime変換
    try {
      result = dateTimeFormatter.parseStrict('$date $time');
    } catch (e) {
      // 変換に失敗した場合の処理
      result = dateFormatter.parseStrict(date);
    }
    return result;
  }
}
