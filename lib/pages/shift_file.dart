import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftFile extends StatefulWidget {
  @override
  _ShiftFileState createState() => _ShiftFileState();
}

class _ShiftFileState extends State<ShiftFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ファイル入力
                FloatingActionButton(
                  onPressed: inputFileAction,
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
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ファイル入力'),
                Text('ファイル出力'),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ファイル入力
  Future inputFileAction() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ファイル入力'),
          content: const Text(
              'シフト表を更新するファイルを選択してください。\n※現在のシフト表は上書きされるため、事前にファイル出力しておくことを推奨します。'),
          actions: [
            TextButton(
              child: const Text('続ける'),
              onPressed: () {
                // ファイル選択
                final pickedFile = FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                pickedFile.then((value) => null);
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
    );
  }

  // ファイル出力
  Future outputFileAction() async {
    // 現在日時
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyyMMddhhmmss');
    String date = outputFormat.format(now);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: '現在のシフト表をファイル出力します:',
      fileName: 'シフト表_$date.json',
    );

    if (outputFile == null) {
      // User canceled the picker
    }
  }
}
