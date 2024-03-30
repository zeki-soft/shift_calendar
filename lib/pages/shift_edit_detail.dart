import 'package:flutter/material.dart';
import 'package:shift_calendar/dialog/shift_title_dialog.dart';
import 'package:shift_calendar/dialog/time_edit_dialog.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';

// シフト編集詳細
class ShiftEditDetail extends StatefulWidget {
  ShiftTableModel shiftData;
  ShiftEditDetail({required this.shiftData});

  @override
  _ShiftEditDetailState createState() =>
      _ShiftEditDetailState(shiftData: shiftData);
}

class _ShiftEditDetailState extends State<ShiftEditDetail> {
  ShiftTableModel shiftData;
  _ShiftEditDetailState({required this.shiftData});
  List<ShiftRecordModel> listItems = [
    ShiftRecordModel(
        shiftTableId: 1,
        orderNum: 1,
        startTime: '10:00',
        endTime: '19:00',
        remarks: '備考１'),
    ShiftRecordModel(
        shiftTableId: 1,
        orderNum: 2,
        startTime: '10:30',
        endTime: '19:30',
        remarks: '備考２'),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 戻るボタン
        leading: IconButton(
          onPressed: () {
            // 画面を閉じる
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        // タイトルテキスト
        title: const Text('シフト名'),
        // 右側のアイコン一覧
        actions: <Widget>[
          // シフト名編集ボタン
          IconButton(
            onPressed: () {
              // シフト名、シフト基準日を編集するダイアログ表示
              showDialog<void>(
                  barrierColor: Colors.grey.withOpacity(0.8),
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return ShiftTitleDialog(
                        shiftData: shiftData, updateFlag: true);
                  });
            },
            icon: const Icon(Icons.edit),
          )
        ],
      ),
      body: Column(
        children: [
          // シフト詳細ヘッダー
          _listDataHeader(),
          // シフト詳細
          Expanded(
              child: ListView.separated(
            itemCount: listItems.length,
            itemBuilder: (BuildContext context, int index) {
              return _listData(listItems[index], index);
            },
            // 区切り
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          )),
        ],
      ),
    );
  }

  // シフト一覧ヘッダー
  Widget _listDataHeader() {
    return Container(
        color: Colors.grey[300],
        child: const ListTile(
            title: Row(children: [
          Expanded(
              flex: 1,
              child: Text('日付',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('開始\n時間',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('終了\n時間',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('備考',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('編集',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ])));
  }

  // シフトデータ
  Widget _listData(ShiftRecordModel item, int index) {
    return SizedBox(
        height: 50,
        child: Container(
            child: Dismissible(
                key: Key(index.toString()), // キー指定
                onDismissed: (DismissDirection direction) {
                  // リスト削除処理
                  // setState(() {
                  //   items.removeAt(index);
                  // });
                },
                background: Container(
                  color: Colors.cyan[300],
                ),
                child: ListTile(
                    title: Row(children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        shiftData.baseDate, // TODO 基準日から計算
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        item.startTime,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        item.endTime,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      flex: 2,
                      child: Text(
                        item.remarks,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          // シフト時間、備考を編集
                          showDialog<void>(
                              barrierColor: Colors.grey.withOpacity(0.8),
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                // 時間、備考編集ダイアログ表示
                                return TimeEditDialog(recordData: item);
                              });
                        },
                        icon: const Icon(Icons.edit),
                      )),
                ])))));
  }
}
