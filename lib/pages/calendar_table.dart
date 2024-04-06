import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarTable extends ConsumerWidget {
  final calendarController = CalendarController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // シフト表全件取得(監視)
    List<ShiftDataModel> listItems = ref.watch(shiftCalendarProvider);
    // シフト名
    String shiftName = '';
    if (listItems.isNotEmpty) {
      shiftName = listItems[0].shiftName;
    }

    return Scaffold(
        body: Container(
      child: SfCalendar(
        view: CalendarView.month,
        showNavigationArrow: true,
        monthViewSettings: const MonthViewSettings(
            showTrailingAndLeadingDates: true, // 前月、次月表示
            appointmentDisplayCount: 3, // イベント表示数
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: false, // イベント表示
            monthCellStyle: MonthCellStyle(
                // セルのスタイル
                textStyle: TextStyle(
                    // 今月
                    fontStyle: FontStyle.normal,
                    fontSize: 15,
                    color: Colors.black),
                trailingDatesTextStyle: TextStyle(
                    // 前月
                    fontStyle: FontStyle.normal,
                    fontSize: 15,
                    color: Colors.grey),
                leadingDatesTextStyle: TextStyle(
                    // 次月
                    fontStyle: FontStyle.normal,
                    fontSize: 15,
                    color: Colors.grey))),
        headerDateFormat: 'yyyy年MM月 ${shiftName}',
        controller: calendarController,
        dataSource: _getCalendarDataSource(listItems),
      ),
    ));
  }
}

_AppointmentDataSource _getCalendarDataSource(List<ShiftDataModel> dataList) {
  List<Appointment> appointments = <Appointment>[];
  final dateFormatter = DateFormat("yyyy/MM/dd");
  int roopNum = dataList.length; // 繰り返し回数
  for (ShiftDataModel data in dataList) {
    // シフト基準日(加算)
    DateTime baseDate = dateFormatter
        .parseStrict(data.baseDate)
        .add(Duration(days: data.recordOrderNum));
    if (data.holidayFlag) {
      // 休日
      appointments.add(Appointment(
        startTime: baseDate,
        endTime: baseDate,
        subject: '休',
        color: Colors.red,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=$roopNum',
      ));
    } else {
      // 開始時間
      appointments.add(Appointment(
        startTime: baseDate,
        endTime: baseDate,
        subject: data.startTime,
        color: Colors.blue,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=$roopNum',
      ));
      // 終了時間
      appointments.add(Appointment(
        startTime: baseDate,
        endTime: baseDate,
        subject: data.endTime,
        color: Colors.blue,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=$roopNum',
      ));
    }
  }

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
