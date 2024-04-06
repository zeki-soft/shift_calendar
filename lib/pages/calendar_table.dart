import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarTable extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // シフト表全件取得(監視)
    List<ShiftDataModel> listItems = ref.watch(shiftCalendarProvider);
    return Container(
      child: SfCalendar(
          view: CalendarView.schedule,
          headerDateFormat: 'yyyy年MM月',
          dataSource: MeetingDataSource(_getDataSource(listItems)),
          scheduleViewSettings: const ScheduleViewSettings(
              // 月ヘッダー
              monthHeaderSettings: MonthHeaderSettings(
                  monthFormat: 'yyyy年MM月',
                  height: 100,
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.blue,
                  monthTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400)),
              // 週ヘッダー（無し）
              weekHeaderSettings: WeekHeaderSettings(
                  height: 0,
                  weekTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w100,
                      fontSize: 0)),
              // 日ヘッダー
              dayHeaderSettings: DayHeaderSettings(
                  dayFormat: 'EEE',
                  width: 60,
                  // 曜日フォーマット
                  dayTextStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  // 日フォーマット
                  dateTextStyle:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w400)))),
    );
  }
}

// カレンダー表示データ編集
List<Meeting> _getDataSource(List<ShiftDataModel> dataList) {
  final List<Meeting> meetings = <Meeting>[];
  final _dateFormatter = DateFormat("yyyy/MM/dd");

  for (ShiftDataModel data in dataList) {
    // 時刻取得
    var start = data.startTime.split(':');
    var end = data.endTime.split(':');
    int startH = int.parse(start[0]);
    int startM = int.parse(start[1]);
    int endH = int.parse(end[0]);
    int endM = int.parse(end[1]);

    // シフト基準日(加算)
    DateTime baseDate = _dateFormatter
        .parseStrict(data.baseDate)
        .add(Duration(days: data.recordOrderNum));

    // for (int i = 0; i < 30; i++) {
    DateTime startTime = DateTime(
        baseDate.year, baseDate.month, baseDate.day, startH, startM, 0);
    DateTime endTime =
        DateTime(baseDate.year, baseDate.month, baseDate.day, endH, endM, 0);
    meetings
        .add(Meeting(data.shiftName, startTime, endTime, Colors.blue, false));
    // }
  }

  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
