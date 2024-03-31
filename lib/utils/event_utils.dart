import 'dart:collection';

import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:table_calendar/table_calendar.dart';

/// カレンダーイベントクラス
class EventUtils {
  final String title;

  const EventUtils(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<EventUtils>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

/// イベント一覧（カレンダー下部に表示） リスト追加
final _kEventSource = Map.fromIterable(List.generate(40, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => EventUtils('イベントTEST $item -> ${index + 1}')))
  ..addAll({
    // 今日のイベント
    // kToday: [
    //   EventUtils('今日イベント 1'),
    //   EventUtils('Today\'s Event 2'),
    // ],
    // kToday2: [
    //   EventUtils('明日のイベント'),
    // ]
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

// 今日の日付
final kToday = DateTime.now();
// 表示可能な最初の日付
final kFirstDay = DateTime(kToday.year - 3, kToday.month, kToday.day);
// 表示可能な最後の日付
final kLastDay = DateTime(kToday.year + 3, kToday.month, kToday.day);

// カレンダーイベント設定 TODO
void setCalendarEvent(List<ShiftDataModel> modelList) {
  Map<DateTime, List<EventUtils>> eventMap = {};
  var kToday2 = kToday.add(Duration(days: 2));
  eventMap[kToday2] = [
    EventUtils('明日のイベント'),
  ];

  _kEventSource.clear();
  _kEventSource.addAll(eventMap);
}
