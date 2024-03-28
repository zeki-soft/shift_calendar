import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

/// カレンダーイベントクラス
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

/// イベント一覧（カレンダー下部に表示） リスト追加
final _kEventSource = Map.fromIterable(List.generate(40, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('イベント $item -> ${index + 1}')))
  ..addAll({
    // 今日のイベント
    // kToday: [
    //   Event('今日の\'s イベント 1'),
    //   Event('Today\'s Event 2'),
    // ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
// List<DateTime> daysInRange(DateTime first, DateTime last) {
//   final dayCount = last.difference(first).inDays + 1;
//   return List.generate(
//     dayCount,
//     (index) => DateTime.utc(first.year, first.month, first.day + index),
//   );
// }

// 今日の日付
final kToday = DateTime.now();
// 表示可能な最初の日付
final kFirstDay = DateTime(kToday.year - 3, kToday.month, kToday.day);
// 表示可能な最後の日付
final kLastDay = DateTime(kToday.year + 3, kToday.month, kToday.day);
