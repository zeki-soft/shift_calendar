import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/enums/window_enums.dart';
import 'package:shift_calendar/model/json_file_model.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';
import 'package:shift_calendar/utils/key_manage.dart';
import 'package:shift_calendar/utils/string_util.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarTable extends ConsumerWidget {
  final calendarController = CalendarController();
  String shiftName = ''; // シフト名
  int isSelectedWeek = 4; // 表示週数
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    // シフト表全件取得(監視)
    List<ShiftDataModel> listItems = ref.watch(shiftCalendarProvider);
    shiftName = '';
    if (KeyManage.windowKeyValue == WindowEnums.single.value) {
      if (listItems.isNotEmpty) {
        shiftName = listItems[0].shiftName;
      }
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
          // シフト名
          child: Row(children: [
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            Expanded(
                flex: 5,
                child: Container(
                    alignment: Alignment.center,
                    child: Text(shiftName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                        )))),
            // 表示週変更プルダウン
            DropdownButton(
              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Text('1 week'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('2 weeks'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('3 weeks'),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text('4 weeks'),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text('5 weeks'),
                ),
                DropdownMenuItem(
                  value: 6,
                  child: Text('6 weeks'),
                ),
              ],
              value: isSelectedWeek,
              onChanged: (int? value) {
                // TODO
                print('TEST');
              },
            ),
            // 設定ボタン
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      iconSize: 35,
                      onPressed: () {
                        // 設定ボタン押下
                        showDialog(
                          context: context,
                          builder: (_) {
                            List<ShiftTableModel> listItems =
                                ShiftTableSql.getShiftTableAll();
                            return AlertDialog(
                              title: const Center(
                                  child: Text('表示シフトを選択',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25,
                                      ))),
                              content: Container(
                                width: double.maxFinite,
                                height: 300,
                                child: ListView(
                                  children: [
                                    ListTile(
                                      title: const Text('すべてのシフトを表示',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          )),
                                      onTap: () {
                                        // パラメータ保持
                                        String value = WindowEnums.all.value;
                                        KeyManage.windowKeyValue = value;
                                        KeyManage.prefs.setString(
                                            KeyManage.windowKey, value);
                                        // 画面更新処理
                                        shiftCalendarController.update();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    for (var shiftData in listItems) ...{
                                      ListTile(
                                        title: Text(shiftData.shiftName,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                            )),
                                        onTap: () {
                                          // パラメータ保持
                                          String value =
                                              WindowEnums.single.value;
                                          KeyManage.windowKeyValue = value;
                                          KeyManage.prefs.setString(
                                              KeyManage.windowKey, value);
                                          // 表示フラグOFF
                                          ShiftTableSql.offShowFlag();
                                          // 表示フラグ更新
                                          shiftData.showFlag = true;
                                          ShiftTableSql.update(
                                              tableList: [shiftData]);
                                          // 画面更新処理
                                          shiftCalendarController.update();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    }
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )))
          ])),
      Expanded(
          child: KeyManage.windowKeyValue == WindowEnums.single.value
              ? SfCalendar(
                  // シングル表示
                  view: CalendarView.month,
                  showNavigationArrow: true,
                  monthViewSettings: MonthViewSettings(
                      showTrailingAndLeadingDates: true, // 前月、次月表示
                      appointmentDisplayCount:
                          _getEventDisplayCount(listItems), // イベント表示数
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                      showAgenda: false, // イベント表示(無)
                      monthCellStyle: const MonthCellStyle(
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
                  dataSource: _getCalendarDataSourceSingle(listItems),
                )
              : SfCalendar(
                  // シフト全表示
                  appointmentBuilder: appointmentBuilder,
                  view: CalendarView.month,
                  showNavigationArrow: true,
                  monthViewSettings: MonthViewSettings(
                      numberOfWeeksInView: 3, // 表示週数 TODO
                      showTrailingAndLeadingDates: true, // 前月、次月表示
                      appointmentDisplayCount:
                          _getEventDisplayCount(listItems), // イベント表示数(シフト数)
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                      showAgenda: true, // イベント表示(有)
                      monthCellStyle: const MonthCellStyle(
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
                  dataSource: _getCalendarDataSourceAll(listItems),
                ))
    ])));
  }
}

// イベント表示数取得
int _getEventDisplayCount(List<ShiftDataModel> listItems) {
  int displayCount = 3; // 最低表示数
  if (KeyManage.windowKeyValue == WindowEnums.all.value) {
    var idSet = <int>{};
    for (var item in listItems) {
      idSet.add(item.shiftTableId);
    }
    if (idSet.length > 3) {
      displayCount = idSet.length;
    }
  }
  return displayCount;
}

// シングル表示設定
_AppointmentDataSource _getCalendarDataSourceSingle(
    List<ShiftDataModel> dataList) {
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
      // 終了時間(イベント順番を調整するため10秒加算)
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

// シフト全表示設定
_AppointmentDataSource _getCalendarDataSourceAll(
    List<ShiftDataModel> dataList) {
  List<Appointment> appointments = [];
  final dateFormatter = DateFormat('yyyy/MM/dd');
  // シフトIDを抽出
  var idSet = <int>{};
  for (var item in dataList) {
    idSet.add(item.shiftTableId);
  }
  // シフトID単位でデータ振り分け
  int identifier = 0; // 識別子カウンター
  for (var id in idSet) {
    identifier++;
    var list = dataList.where((data) => data.shiftTableId == id).toList();
    int roopNum = list.length; // 繰り返し回数
    for (ShiftDataModel data in list) {
      // シフト基準日(加算)
      DateTime baseDateAdd = dateFormatter
          .parseStrict(data.baseDate)
          .add(Duration(days: data.recordOrderNum));
      String baseDate = DateFormat('yyyy/MM/dd').format(baseDateAdd);
      // 識別番号を加算してソート
      DateTime baseDateCal = baseDateAdd.add(Duration(seconds: identifier));
      if (data.holidayFlag) {
        // 休日
        appointments.add(Appointment(
          startTime: baseDateCal,
          endTime: baseDateCal,
          subject: StringUtil.numToStr(identifier),
          color: Colors.red,
          notes:
              '${data.shiftName}||$baseDate ${data.startTime}||$baseDate ${data.endTime}',
          recurrenceRule: 'FREQ=DAILY;INTERVAL=$roopNum',
        ));
      } else {
        // 識別子を表示
        appointments.add(Appointment(
          startTime: baseDateCal,
          endTime: baseDateCal,
          subject: StringUtil.numToStr(identifier),
          color: Colors.blue,
          notes: '${data.shiftName}||${data.startTime}||${data.endTime}',
          recurrenceRule: 'FREQ=DAILY;INTERVAL=$roopNum',
        ));
      }
    }
  }

  // カスタマイズ
  return _AppointmentDataSource(appointments);
}

// イベントソース
class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

// イベント表示カスタマイズ
Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;
  List notes = appointment.notes!.split('||');
  String title = notes[0];
  String startTime = notes[1];
  String endTime = notes[2];
  return Column(
    children: [
      Container(
        width: calendarAppointmentDetails.bounds.width,
        height: calendarAppointmentDetails.bounds.height,
        color: appointment.color,
        child: Text(
          appointment.color == Colors.red
              ? '${appointment.subject}\n$title  休日'
              : '${appointment.subject}\n$title  $startTime - $endTime',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
    ],
  );
}
