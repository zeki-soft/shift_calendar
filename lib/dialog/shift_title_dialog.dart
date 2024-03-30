import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';

// シフト必須項目編集ダイアログ
class ShiftTitleDialog extends StatefulWidget {
  ShiftTableModel shiftData;
  bool updateFlag;
  ShiftTitleDialog({required this.shiftData, required this.updateFlag});

  @override
  _ShiftTitleDialogState createState() =>
      _ShiftTitleDialogState(shiftData: shiftData, updateFlag: updateFlag);
}

class _ShiftTitleDialogState extends State<ShiftTitleDialog> {
  ShiftTableModel shiftData;
  bool updateFlag; // 更新フラグ
  TextEditingController _shiftNameController =
      TextEditingController(); // シフト名コントローラー
  TextEditingController _dateController =
      TextEditingController(); // シフト基準日コントローラー

  _ShiftTitleDialogState({required this.shiftData, required this.updateFlag});

  @override
  Widget build(BuildContext context) {
    String title;
    if (updateFlag) {
      title = 'シフト表 編集';
    } else {
      title = 'シフト表 新規作成';
    }
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0), // マージン
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      content: Container(
          width: 300,
          height: 220,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // シフト名
            TextField(
              controller: _shiftNameController,
              decoration: const InputDecoration(
                labelText: 'シフト名(必須)',
                hintText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                // 編集完了後
                print("Current text: $text");
              },
            ),
            const SizedBox(height: 20),
            // シフト基準日
            CalenderTextField(_dateController),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // 決定ボタン
              TextButton(
                onPressed: () {
                  // DB登録処理

                  // シフト編集詳細へ遷移 TODO
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShiftEditDetail(shiftData: shiftData)),
                  );
                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
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

  TextField CalenderTextField(TextEditingController _date) {
    return TextField(
      controller: _date,
      textInputAction: TextInputAction.next,
      enabled: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'シフト基準日(必須)',
        hintText: 'yyyy/MM/dd',
        // inputの端にカレンダーアイコンをつける
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            // textFieldがの値からデフォルトの日付を取得する
            DateTime initDate = DateTime.now();
            try {
              initDate = DateFormat('yyyy/MM/dd').parse(_date.text);
            } catch (_) {}
            // DatePickerを表示する
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initDate,
              firstDate: DateTime(2016),
              lastDate: DateTime.now().add(
                Duration(days: 360),
              ),
            );
            // DatePickerで取得した日付を文字列に変換
            String? formatedDate;
            try {
              formatedDate = DateFormat('yyyy/MM/dd').format(picked!);
            } catch (_) {}
            if (formatedDate != null) {
              _date.text = formatedDate;
            }
          },
        ),
      ),
    );
  }
}
