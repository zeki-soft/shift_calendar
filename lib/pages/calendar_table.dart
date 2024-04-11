import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/json_file_model.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarTable extends ConsumerWidget {
  final calendarController = CalendarController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    // シフト表全件取得(監視)
    List<ShiftDataModel> listItems = ref.watch(shiftCalendarProvider);
    // シフト名
    String shiftName = '';
    if (listItems.isNotEmpty) {
      shiftName = listItems[0].shiftName;
    }

    // データなしの場合
    if (!CommonSql.existTable()) {
      // 画面の描画が終わったタイミングで表示させる
      WidgetsBinding.instance.addPostFrameCallback((_) => showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                content: const Text('勤務表のデータがありません。\nサンプルデータを作成しますか？'),
                actions: [
                  TextButton(
                    child: const Text('作成'),
                    onPressed: () async {
                      // サンプルデータ読み込み
                      ByteData byteData =
                          await rootBundle.load('assets/file/交替勤務表.json');
                      Uint8List uint8list = byteData.buffer.asUint8List();
                      String json = utf8.decode(uint8list);
                      // Json形式で読み込み
                      var map = jsonDecode(json);
                      JsonFIleModel jsonModel = JsonFIleModel.fromJson(map);
                      // インポート
                      ShiftTableSql.insert(tableList: jsonModel.tableList);
                      ShiftRecordSql.insert(recordList: jsonModel.recordList);
                      // 画面更新
                      shiftCalendarController.update();
                      // ダイアログを閉じる
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('キャンセル'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            },
          ));
    }

    return Scaffold(
        body: Container(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Text(shiftName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              textAlign: TextAlign.center)),
      Expanded(
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
        headerDateFormat: 'yyyy年MM月',
        controller: calendarController,
        dataSource: _getCalendarDataSource(listItems),
      ))
    ])));
  }
}

_AppointmentDataSource _getCalendarDataSource(List<ShiftDataModel> dataList) {
  List<Appointment> appointments = [];
  final dateFormatter = DateFormat('yyyy/MM/dd');
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
      // 終了時間(イベント順番を調整するため5秒加算)
      DateTime endBaseDate = baseDate.add(const Duration(seconds: 10));
      appointments.add(Appointment(
        startTime: endBaseDate,
        endTime: endBaseDate,
        subject: data.endTime,
        color: Colors.blue,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=$roopNum',
      ));
    }
  }

  return _AppointmentDataSource(appointments);
}

// イベントソース
class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
