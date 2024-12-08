import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/constant/constant.dart';
import 'package:shift_calendar/enums/window_enums.dart';
import 'package:shift_calendar/model/json_file_model.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';
import 'package:shift_calendar/utils/key_manage.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarTable extends ConsumerWidget {
  final calendarController = CalendarController();
  String shiftName = ''; // シフト名
  int isSelectedShift = -1; // シフト選択
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Constant.initialize(context);
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    // シフト表全件取得(監視)
    List<ShiftDataModel> dataItems = ref.watch(shiftCalendarProvider);
    List<ShiftTableModel> tableItems = ShiftTableSql.getShiftTableAll();
    shiftName = 'シフト一覧';
    if (KeyManage.windowValue == WindowEnums.single.value) {
      if (dataItems.isNotEmpty) {
        shiftName = dataItems[0].shiftName;
      }
      // プルダウン初期選択値
      var select = tableItems.where((element) => element.showFlag);
      if (select.isEmpty) {
        try {
          isSelectedShift = select.first.id;
        } catch (e) {
          // シフト削除で見つからない場合
          isSelectedShift = -1;
        }
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
          child: SizedBox(
              height: 30,
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
                              fontSize: 15,
                            )))),
                // 設定ボタン
                Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.topCenter,
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          iconSize: 20,
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
                                          title: const Text('シフト一覧',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                              )),
                                          onTap: () {
                                            // パラメータ保持
                                            String value =
                                                WindowEnums.all.value;
                                            KeyManage.windowValue = value;
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
                                              KeyManage.windowValue = value;
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
              ]))),
      Expanded(
          child: KeyManage.windowValue == WindowEnums.single.value
              ? SfCalendar(
                  // シングル表示
                  todayHighlightColor: Colors.orange, // 今日の日付色
                  initialDisplayDate: DateTime.now(),
                  initialSelectedDate: DateTime.now(),
                  view: CalendarView.month,
                  showNavigationArrow: true,
                  monthViewSettings: const MonthViewSettings(
                      numberOfWeeksInView: 6, // 表示週数(6未満だと月を跨ぐ)
                      showTrailingAndLeadingDates: false, // 前月、次月表示
                      appointmentDisplayCount: 3, // イベント表示数
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                      showAgenda: false, // イベント表示(無)
                      monthCellStyle: MonthCellStyle(
                          // セルのスタイル
                          textStyle: TextStyle(
                              // 今月
                              fontStyle: FontStyle.normal,
                              fontSize: 15,
                              color: Colors.black))),
                  headerDateFormat: 'yyyy年MM月',
                  controller: calendarController,
                  dataSource: _getCalendarDataSourceSingle(dataItems),
                )
              : SfCalendar(
                  // シフト全表示
                  todayHighlightColor: Colors.orange, // 今日の日付色
                  initialDisplayDate: DateTime.now(),
                  initialSelectedDate: DateTime.now(),
                  appointmentBuilder: appointmentBuilder, // イベント表示設定
                  view: CalendarView.month,
                  showNavigationArrow: true,
                  monthViewSettings: MonthViewSettings(
                      numberOfWeeksInView: 6, // 表示週数(6未満だと月を跨ぐ)
                      showTrailingAndLeadingDates: false, // 前月、次月表示
                      appointmentDisplayCount: 4, // イベント表示数(シフト数)
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                      showAgenda: true, // イベント表示(有)
                      agendaItemHeight: Constant.agendaItemHeight, // イベントセルの高さ
                      agendaViewHeight: Constant.agendaViewHeight, // イベントビューの高さ
                      monthCellStyle: const MonthCellStyle(
                          // セルのスタイル
                          textStyle: TextStyle(
                              // 今月
                              fontStyle: FontStyle.normal,
                              fontSize: 15,
                              color: Colors.black))),
                  headerDateFormat: 'yyyy年MM月',
                  controller: calendarController,
                  dataSource: _getCalendarDataSourceAll(dataItems),
                ))
    ])));
  }
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
          subject: data.identifier,
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
          subject: data.identifier,
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

// イベント表示カスタマイズ（シフト一覧）
Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;
  String title = '', startTime = '', endTime = '';
  if (appointment.notes! != '') {
    List notes = appointment.notes!.split('||');
    title = notes[0];
    startTime = notes[1];
    endTime = notes[2];
    // シフト名の文字数を揃える
    while (title.length <= 8) {
      title += '　';
    }
  }

  // 縦横比に応じて半角空白を挿入
  String space = '';
  for (int i = 0; i < Constant.spaceCount; i++) {
    space += ' ';
  }

  return FittedBox(
      fit: BoxFit.fill,
      child: Column(
        children: [
          Container(
            width: calendarAppointmentDetails.bounds.width,
            height: calendarAppointmentDetails.bounds.height,
            color: appointment.color,
            child: Text(
              appointment.color == Colors.red
                  ? '${appointment.subject}$space$title　　　　休  日'
                  : '${appointment.subject}$space$title　$startTime - $endTime',
              textAlign: TextAlign
                  .center, // 表示される範囲で中央寄せ、両端をトリムする。高さを文字と合わせないと改行表示される。
              style: TextStyle(
                  fontSize: Constant.eventFontSize, color: Colors.white),
            ),
          )
        ],
      ));
}
