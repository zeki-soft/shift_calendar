import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/provider/shift_record_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/utils/const.dart';

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
  TextEditingController _remarksController =
      TextEditingController(); // 備考コントローラー

  _TimeEditDialogState(
      {required this.shiftData,
      required this.recordData,
      required this.ref,
      required this.updateFlag});

  @override
  Widget build(BuildContext context) {
    String baseData = shiftData.baseDate;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
      title: Text(
        updateFlag ? '$baseData 追加' : '$baseData 編集',
        style: const TextStyle(color: Colors.black),
      ),
      content: Container(
          width: 300,
          height: 220,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // 開始時間
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(
                labelText: '開始時間',
                hintText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                // 編集完了後
                print("Current text: $text");
              },
            ),
            const SizedBox(height: 20),
            // 終了時間
            TextField(
              controller: _endTimeController,
              decoration: const InputDecoration(
                labelText: '終了時間',
                hintText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                // 編集完了後
                print("Current text: $text");
              },
            ),
            const SizedBox(height: 20),
            // 備考
            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: '備考',
                hintText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                // 編集完了後
              },
            ),
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
                      endTime: _endTimeController.text,
                      remarks: _remarksController.text);
                  ShiftRecordSql.upsert(recordList: [model]);
                  // シフト編集を更新
                  Const.editShiftTableId = shiftData.id;
                  ref.invalidate(shiftRecordProvider);
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
}
