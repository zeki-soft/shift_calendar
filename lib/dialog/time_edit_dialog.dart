import 'package:flutter/material.dart';
import 'package:shift_calendar/model/shift_record_model.dart';

// シフト時間、備考編集ダイアログ TODO
class TimeEditDialog extends StatefulWidget {
  ShiftRecordModel recordData;
  TimeEditDialog({required this.recordData});

  @override
  _TimeEditDialogState createState() =>
      _TimeEditDialogState(recordData: recordData);
}

class _TimeEditDialogState extends State<TimeEditDialog> {
  ShiftRecordModel recordData;
  TextEditingController _startTimeController =
      TextEditingController(); // 開始時間コントローラー
  TextEditingController _endTimeController =
      TextEditingController(); // 終了時間コントローラー
  TextEditingController _remarksController =
      TextEditingController(); // 備考コントローラー

  _TimeEditDialogState({required this.recordData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0), // マージン
      backgroundColor: Colors.white,
      title: const Text(
        'シフト時間 編集',
        style: TextStyle(color: Colors.black),
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
                onPressed: () {},
                child: const Text("決定",
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
