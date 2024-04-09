import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';

// シフト時間、備考編集ダイアログ
class TimeEditDialog extends StatefulWidget {
  ShiftTableModel shiftData;
  ShiftRecordModel recordData;
  WidgetRef ref;
  bool updateFlag;
  TimeEditDialog(
      {required this.shiftData,
      required this.recordData,
      required this.ref,
      required this.updateFlag});

  @override
  _TimeEditDialogState createState() => _TimeEditDialogState(
      shiftData: shiftData,
      recordData: recordData,
      ref: ref,
      updateFlag: updateFlag);
}

class _TimeEditDialogState extends State<TimeEditDialog> {
  ShiftTableModel shiftData;
  ShiftRecordModel recordData;
  WidgetRef ref;
  bool updateFlag;
  TextEditingController _startTimeController =
      TextEditingController(); // 開始時間コントローラー
  TextEditingController _endTimeController =
      TextEditingController(); // 終了時間コントローラー
  bool _holidayFlag = false; // 休日チェック状態

  _TimeEditDialogState(
      {required this.shiftData,
      required this.recordData,
      required this.ref,
      required this.updateFlag});

  @override
  void initState() {
    super.initState();
    // 入力初期値
    _startTimeController.text = recordData.startTime;
    _endTimeController.text = recordData.endTime;
    _holidayFlag = recordData.holidayFlag;
  }

  @override
  Widget build(BuildContext context) {
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    // シフト基準日
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    DateTime baseDate = dateFormat
        .parseStrict(shiftData.baseDate)
        .add(Duration(days: recordData.orderNum));
    String baseDateStr = dateFormat.format(baseDate);

    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
      title: Text(
        'シフト基準日: $baseDateStr',
        style: const TextStyle(color: Colors.black, fontSize: 20),
      ),
      content: Container(
          width: 320,
          height: 280,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // 開始時間入力
            _TimeTextField(_startTimeController, _holidayFlag, '開始時間'),
            const SizedBox(height: 20),
            // 終了時間入力
            _TimeTextField(_endTimeController, _holidayFlag, '終了時間'),
            const SizedBox(height: 20),
            // 休日チェックボックス
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              const Text('休日',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
              Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                      activeColor: Colors.blue,
                      value: _holidayFlag,
                      onChanged: (flag) {
                        // 休日フラグを保持
                        setState(() {
                          // 画面再描画
                          _holidayFlag = flag!;
                        });
                      })),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // 決定ボタン
              TextButton(
                onPressed: () {
                  if (_holidayFlag) {
                    // 休日チェックONの場合
                    if (_startTimeController.text == '') {
                      _startTimeController.text == '09:00';
                    }
                    if (_endTimeController.text == '') {
                      _endTimeController.text == '18:00';
                    }
                  } else {
                    // 入力チェック
                    final regTime = RegExp(r'^([01][0-9]|2[0-4]):[0-5][0-9]$');
                    bool checkFlag =
                        regTime.hasMatch(_startTimeController.text) &&
                            regTime.hasMatch(_endTimeController.text);
                    if (!checkFlag) {
                      // 入力チェックエラー
                      Fluttertoast.showToast(
                          msg: '開始時間または終了時間の形式が不正です。',
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      // ダイアログ入力に戻る
                      return;
                    }
                  }
                  // シフトレコードDB登録/更新
                  ShiftRecordModel model = ShiftRecordModel(
                      id: recordData.id,
                      shiftTableId: recordData.shiftTableId,
                      orderNum: recordData.orderNum,
                      startTime: _startTimeController.text,
                      endTime: _endTimeController.text,
                      holidayFlag: _holidayFlag);
                  if (updateFlag) {
                    ShiftRecordSql.update(recordList: [model]);
                  } else {
                    ShiftRecordSql.insert(recordList: [model]);
                  }
                  // シフト編集を更新
                  shiftCalendarController.update();
                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: const Text('決定',
                    style: TextStyle(
                      fontSize: 16,
                    )),
              ),
              // キャンセルボタン
              TextButton(
                onPressed: () {
                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: const Text("キャンセル",
                    style: TextStyle(
                      fontSize: 16,
                    )),
              )
            ]),
          ])),
    );
  }

  // 日付入力テキストフィールド
  TextField _TimeTextField(
      TextEditingController _time, bool holidayFlag, String label) {
    TimeOfDay selectedTime = TimeOfDay.now();
    return TextField(
      controller: _time,
      textInputAction: TextInputAction.next,
      enabled: !holidayFlag, // 活性状態
      keyboardType: TextInputType.number,
      onChanged: (text) {
        // 日付フォーマットチェック
        final regTime = RegExp(r'^([01][0-9]|2[0-4]):[0-5][0-9]$');
        if (!regTime.hasMatch(text)) {
          // フォーマットが異なる場合は初期化
          _time.text = '';
        }
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: 'hh/mm',
        // inputの端に時計アイコンをつける
        suffixIcon: IconButton(
          icon: const Icon(Icons.timer),
          onPressed: () async {
            // TimePickerを表示する
            TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            // TimePickerで取得した時間を文字列に変換
            if (picked != null) {
              // ゼロ埋め編集
              _time.text =
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
            }
          },
        ),
      ),
    );
  }
}
