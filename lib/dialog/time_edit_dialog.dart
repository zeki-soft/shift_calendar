import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/provider/shift_record_provider.dart';
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

  _TimeEditDialogState(
      {required this.shiftData,
      required this.recordData,
      required this.ref,
      required this.updateFlag});

  @override
  void initState() {
    super.initState();
    _startTimeController.text = recordData.startTime;
    _endTimeController.text = recordData.endTime;
  }

  @override
  Widget build(BuildContext context) {
    ShiftRecordNotifier shiftRecordController =
        ref.read(shiftRecordProvider.notifier);
    // シフト基準日
    DateTime baseDate = DateFormat("yyyy/MM/dd")
        .parseStrict(shiftData.baseDate)
        .add(Duration(days: shiftData.orderNum));

    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
      title: Text(
        'シフト基準日: $baseDate',
        style: const TextStyle(color: Colors.black, fontSize: 20),
      ),
      content: Container(
          width: 320,
          height: 220,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // 開始時間入力
            TimeTextField(_startTimeController),
            const SizedBox(height: 20),
            // 終了時間入力
            TimeTextField(_endTimeController),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // 決定ボタン
              TextButton(
                onPressed: () {
                  // シフトレコードDB登録/更新
                  ShiftRecordModel model = ShiftRecordModel(
                      shiftTableId: recordData.shiftTableId,
                      orderNum: recordData.orderNum,
                      startTime: _startTimeController.text,
                      endTime: _endTimeController.text);
                  if (updateFlag) {
                    ShiftRecordSql.update(recordList: [model]);
                  } else {
                    ShiftRecordSql.insert(recordList: [model]);
                  }
                  // シフト編集を更新
                  shiftRecordController.update(shiftData.id);
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
  TextField TimeTextField(TextEditingController _time) {
    TimeOfDay selectedTime = TimeOfDay.now();
    return TextField(
      controller: _time,
      textInputAction: TextInputAction.next,
      enabled: true,
      keyboardType: TextInputType.number,
      onChanged: (text) {
        // checkOKFlag();
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: '開始時間',
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
              _time.text =
                  '${picked.hour.toString()}:${picked.minute.toString()}';
            }
          },
        ),
      ),
    );
  }
}
