import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/model/json_file_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/provider/shift_table_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

class ShiftFile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    ShiftTableNotifier shiftTableController =
        ref.read(shiftTableProvider.notifier);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ファイル入力',
                    style: TextStyle(
                      fontSize: 16,
                    )),
                Text(
                  'ファイル出力',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ファイル入力
                FloatingActionButton(
                  onPressed: () => inputFileAction(
                      context, shiftCalendarController, shiftTableController),
                  tooltip: 'ファイル入力',
                  child: const Icon(Icons.file_open),
                ),
                // ファイル出力
                FloatingActionButton(
                  onPressed: outputFileAction,
                  tooltip: 'ファイル出力',
                  child: const Icon(Icons.file_download),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ファイル入力
  Future inputFileAction(
      BuildContext context,
      ShiftCalendarNotifier shiftCalendarController,
      ShiftTableNotifier shiftTableController) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'ファイル入力',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          content: const Text(
              'シフト表を更新するファイルを選択してください。\n※現在のシフト表は上書きされるため、事前にファイル出力しておくことを推奨します。'),
          actions: [
            TextButton(
              child: const Text('続ける',
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onPressed: () async {
                // ファイル選択
                FilePickerResult? filePickerResult =
                    await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (filePickerResult != null) {
                  try {
                    // ファイル読み込み
                    File file = File(filePickerResult.files.single.path!);
                    String json = await file.readAsString();
                    // Json形式で読み込み
                    var map = jsonDecode(json);
                    JsonFIleModel jsonModel = JsonFIleModel.fromJson(map);
                    // テーブル削除
                    ShiftTableSql.truncate();
                    ShiftRecordSql.truncate();
                    // インポート
                    ShiftTableSql.insert(tableList: jsonModel.tableList);
                    ShiftRecordSql.insert(recordList: jsonModel.recordList);
                    // 画面更新
                    shiftCalendarController.update();
                    shiftTableController.update();
                    // メッセージ表示
                    Fluttertoast.showToast(
                        msg: 'シフト表をインポートしました。',
                        toastLength: Toast.LENGTH_LONG,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } catch (e) {
                    print(e);
                    // エラーメッセージ表示
                    Fluttertoast.showToast(
                        msg: 'インポートに失敗しました。\nファイルが正しいか確認してください。',
                        toastLength: Toast.LENGTH_LONG,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('キャンセル',
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // ファイル出力
  Future outputFileAction() async {
    // 現在日時
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyyMMddhhmmss');
    String date = outputFormat.format(now);

    // 出力ファイル生成
    JsonFIleModel file = JsonFIleModel(
        tableList: ShiftTableSql.getShiftTableAll(),
        recordList: ShiftRecordSql.getShiftRecordAll());
    String json = jsonEncode(file.toJson());

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: '現在のシフト表をファイル出力します:',
      fileName: '交代制シフト表_$date.json',
      bytes: utf8.encode(json), // 出力内容(UTF-8)
    );

    if (outputFile == null) {
      // ファイル出力キャンセル
    } else {
      // ファイル出力した場合
      Fluttertoast.showToast(
          msg: 'ファイル出力しました。',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
