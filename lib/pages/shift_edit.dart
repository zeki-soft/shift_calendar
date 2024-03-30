import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/dialog/shift_title_dialog.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

// シフト編集
class ShiftEdit extends StatefulWidget {
  @override
  _ShiftEditState createState() => _ShiftEditState();
}

class _ShiftEditState extends State<ShiftEdit> {
  final List<ShiftTableModel> listItems = [
    ShiftTableModel(
        id: 1,
        shiftName: 'シフト１',
        showFlag: true,
        baseDate: '2024/10/01',
        orderNum: 1),
    ShiftTableModel(
        id: 2,
        shiftName: 'シフト２',
        showFlag: false,
        baseDate: '2024/12/19',
        orderNum: 2)
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
      body: Column(
        children: [
          // シフト一覧ヘッダー
          _listDataHeader(),
          // シフト一覧
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
      // 追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 新規作成データを生成
          ShiftTableModel shiftData = ShiftTableModel(
              id: ShiftTableSql.generateId(), // 新規ID取得
              shiftName: '新規シフト',
              showFlag: true,
              baseDate: DateFormat('yyyy/MM/dd').format(DateTime.now()),
              orderNum: ShiftTableSql.generateOrderNum());
          // シフト編集詳細へ遷移(新規作成)のダイアログ表示
          showDialog<void>(
              barrierColor: Colors.grey.withOpacity(0.8),
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return ShiftTitleDialog(
                    shiftData: shiftData, updateFlag: false);
              });
        },
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.add),
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
              child: Text('表示',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 6,
              child: Text('シフト名',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('編集',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('削除',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ])));
  }

  // シフトデータ
  Widget _listData(ShiftTableModel shiftData, int index) {
    return SizedBox(
        height: 50,
        child: Container(
            child: Dismissible(
                key: Key(index.toString()),
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
                  // 表示
                  Expanded(
                    flex: 1,
                    child: Checkbox(
                      activeColor: Colors.blue,
                      value: shiftData.showFlag, // チェックフラグ
                      onChanged: (flag) {
                        // ボタンが押された際の動作を記述する
                        if (flag!) {
                          print(flag);
                        }
                      },
                    ),
                  ),
                  // シフト名
                  Expanded(
                      flex: 6,
                      child: Text(
                        shiftData.shiftName,
                        textAlign: TextAlign.center,
                      )),
                  // 編集ボタン
                  Expanded(
                      flex: 2,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // シフト編集詳細へ遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShiftEditDetail(shiftData: shiftData)),
                          );
                        },
                      )),
                  // 削除ボタン
                  Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // ボタンが押された際の動作を記述する
                        },
                      )),
                ])))));
  }
}
