import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

// シフト必須項目編集ダイアログ
class ShiftTitleDialog extends StatefulWidget {
  ShiftTableModel shiftData;
  WidgetRef ref;
  bool updateFlag;
  ShiftTitleDialog(
      {required this.shiftData, required this.ref, required this.updateFlag});

  @override
  _ShiftTitleDialogState createState() => _ShiftTitleDialogState(
      shiftData: shiftData, ref: ref, updateFlag: updateFlag);
}

class _ShiftTitleDialogState extends State<ShiftTitleDialog> {
  ShiftTableModel shiftData;
  WidgetRef ref;
  final bool updateFlag; // 更新フラグ

  TextEditingController _shiftNameController =
      TextEditingController(); // シフト名コントローラー
  TextEditingController _dateController =
      TextEditingController(); // シフト基準日コントローラー

  _ShiftTitleDialogState(
      {required this.shiftData, required this.ref, required this.updateFlag});

  @override
  void initState() {
    super.initState();
    _shiftNameController.text = shiftData.shiftName;
    _dateController.text = shiftData.baseDate;
  }

  @override
  Widget build(BuildContext context) {
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0), // マージン
      backgroundColor: Colors.white,
      title: Text(
        updateFlag ? 'シフト表 編集' : 'シフト表 新規作成',
        style: const TextStyle(color: Colors.black, fontSize: 20),
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
                // checkOKFlag();
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
                  // 入力チェック
                  final regDate = RegExp(
                      r'^[0-9]{4}/(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])$');
                  bool checkFlag = _shiftNameController.text != '' &&
                      regDate.hasMatch(_dateController.text);
                  if (checkFlag) {
                    // シフト表DB登録
                    shiftData.shiftName = _shiftNameController.text;
                    shiftData.baseDate = _dateController.text;
                    if (updateFlag) {
                      // 更新
                      ShiftTableSql.update(tableList: [shiftData]);
                    } else {
                      // 新規追加
                      ShiftTableSql.insert(tableList: [shiftData]);
                      // ID生成
                      int id = ShiftRecordSql.generateId();
                      // シフトレコードサンプル登録
                      List<ShiftRecordModel> recordList = [
                        ShiftRecordModel(
                          id: id,
                          shiftTableId: shiftData.id,
                          orderNum: 0,
                          identifier: '①',
                          startTime: '09:00',
                          endTime: '18:00',
                          holidayFlag: false,
                        ),
                        ShiftRecordModel(
                          id: id + 1,
                          shiftTableId: shiftData.id,
                          orderNum: 1,
                          identifier: '②',
                          startTime: '12:00',
                          endTime: '21:00',
                          holidayFlag: false,
                        ),
                        ShiftRecordModel(
                          id: id + 2,
                          shiftTableId: shiftData.id,
                          orderNum: 2,
                          identifier: '③',
                          startTime: '15:00',
                          endTime: '00:00',
                          holidayFlag: false,
                        ),
                      ];
                      ShiftRecordSql.insert(recordList: recordList);
                    }
                    // シフト編集を更新
                    shiftCalendarController.update();
                    // ダイアログを閉じる
                    Navigator.pop(context);
                    if (!updateFlag) {
                      // 新規作成の場合
                      Fluttertoast.showToast(
                          msg: '【${shiftData.shiftName}】\nサンプルのシフト時間を作成しました。',
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      // シフト編集詳細へ遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ShiftEditDetail(shiftData: shiftData)),
                      );
                    }
                  } else {
                    // 入力チェックエラー
                    Fluttertoast.showToast(
                        msg: _shiftNameController.text == ''
                            ? 'シフト名を入力してください。'
                            : 'シフト基準日の形式が不正です。',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
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
  TextField CalenderTextField(TextEditingController _date) {
    return TextField(
      controller: _date,
      textInputAction: TextInputAction.next,
      enabled: true,
      keyboardType: TextInputType.number,
      onChanged: (text) {
        // checkOKFlag();
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'シフト基準日(必須)',
        hintText: 'yyyy/MM/dd',
        // inputの端にカレンダーアイコンをつける
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            // textFieldがの値からデフォルトの日付を取得する
            DateTime initDate = DateTime.now();
            try {
              initDate = DateFormat('yyyy/MM/dd').parse(_date.text);
            } catch (_) {}
            // DatePickerを表示する
            DateTime? picked = await showDatePicker(
              context: context,
              locale: const Locale("ja"),
              initialDate: initDate,
              firstDate: DateTime(2010),
              lastDate: DateTime.now().add(
                const Duration(days: 1000),
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
