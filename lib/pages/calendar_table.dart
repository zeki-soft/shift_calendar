import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCalendar(
          view: CalendarView.schedule,
          headerDateFormat: 'yyyy年MM月',
          dataSource: MeetingDataSource(_getDataSource()),
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

List<Meeting> _getDataSource() {
  final List<Meeting> meetings = <Meeting>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));
  meetings
      .add(Meeting('シフトA', startTime, endTime, const Color(0xFF0F8644), false));

  for (int i = 0; i < 28; i++) {
    final DateTime today1 = DateTime(2024, 04, 01);
    final DateTime startTime1 =
        DateTime(today1.year, today1.month, today1.day + i, 9, 0, 0);
    final DateTime endTime1 = startTime1.add(const Duration(hours: 3));
    meetings.add(Meeting('シフトB', startTime1, endTime1, Colors.blue, false));
  }
  // final DateTime today2 = DateTime(2024, 01, 24);
  // final DateTime startTime2 =
  //     DateTime(today2.year, today2.month, today2.day, 9, 0, 0);
  // final DateTime endTime2 = startTime2.add(const Duration(hours: 3));
  // meetings.add(Meeting('シフトC', startTime2, endTime2, Colors.red, false));

  // final DateTime today3 = DateTime(2024, 01, 26);
  // final DateTime startTime3 =
  //     DateTime(today3.year, today3.month, today3.day, 9, 0, 0);
  // final DateTime endTime3 = startTime3.add(const Duration(hours: 3));
  // meetings.add(Meeting('シフトD', startTime3, endTime3, Colors.yellow, false));

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
