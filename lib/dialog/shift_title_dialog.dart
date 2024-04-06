import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';
import 'package:shift_calendar/provider/shift_record_provider.dart';
import 'package:shift_calendar/provider/shift_table_provider.dart';
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
  bool _isOkEnabled = false; // 決定ボタン活性フラグ

  TextEditingController _shiftNameController =
      TextEditingController(); // シフト名コントローラー
  TextEditingController _dateController =
      TextEditingController(); // シフト基準日コントローラー

  _ShiftTitleDialogState(
      {required this.shiftData, required this.ref, required this.updateFlag});

  void checkOKFlag() async {
    setState(() {
      if (_shiftNameController.text != '' && _dateController.text != '') {
        // 必須項目が入力済みの場合は決定ボタンを活性化
        _isOkEnabled = true;
      } else {
        _isOkEnabled = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _shiftNameController.text = shiftData.shiftName;
    _dateController.text = shiftData.baseDate;
    checkOKFlag();
  }

  @override
  Widget build(BuildContext context) {
    ShiftTableNotifier shiftTableController =
        ref.read(shiftTableProvider.notifier);
    ShiftRecordNotifier shiftRecordController =
        ref.read(shiftRecordProvider.notifier);
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0), // マージン
      backgroundColor: Colors.white,
      title: Text(
        updateFlag ? 'シフト表 編集' : 'シフト表 新規作成',
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
                checkOKFlag();
              },
            ),
            const SizedBox(height: 20),
            // シフト基準日
            CalenderTextField(_dateController),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // 決定ボタン
              TextButton(
                onPressed: !_isOkEnabled
                    ? null
                    : () {
                        // シフト表DB登録
                        shiftData.shiftName = _shiftNameController.text;
                        shiftData.baseDate = _dateController.text;
                        if (updateFlag) {
                          // 更新
                          ShiftTableSql.update(model: shiftData);
                        } else {
                          // 新規追加
                          ShiftTableSql.insert(model: shiftData);
                          // シフトレコードサンプル登録
                          List<ShiftRecordModel> recordList = [
                            ShiftRecordModel(
                              shiftTableId: shiftData.id,
                              orderNum: 0,
                              startTime: '09:00',
                              endTime: '18:00',
                            ),
                            ShiftRecordModel(
                              shiftTableId: shiftData.id,
                              orderNum: 1,
                              startTime: '10:00',
                              endTime: '19:00',
                            ),
                            ShiftRecordModel(
                              shiftTableId: shiftData.id,
                              orderNum: 2,
                              startTime: '11:00',
                              endTime: '20:00',
                            ),
                          ];
                          ShiftRecordSql.insert(recordList: recordList);
                        }
                        // シフト編集を更新
                        shiftTableController.update();
                        shiftRecordController.update(shiftData.id);
                        // ダイアログを閉じる
                        Navigator.pop(context);
                        if (!updateFlag) {
                          // シフト編集詳細へ遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShiftEditDetail(
                                    shiftData: shiftData, newFlag: true)),
                          );
                        }
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

  // 日付入力テキストフィールド
  TextField CalenderTextField(TextEditingController _date) {
    return TextField(
      controller: _date,
      textInputAction: TextInputAction.next,
      enabled: true,
      keyboardType: TextInputType.number,
      onChanged: (text) {
        checkOKFlag();
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
              initialDate: initDate,
              firstDate: DateTime(2010),
              lastDate: DateTime.now().add(
                const Duration(days: 360),
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
