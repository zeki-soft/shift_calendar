import 'package:flutter/material.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';

// シフト編集
class ShiftEdit extends StatefulWidget {
  @override
  _ShiftEditState createState() => _ShiftEditState();
}

class _ShiftEditState extends State<ShiftEdit> {
  final List<Map<String, dynamic>> listItems = [
    {
      'text': 'Item 1',
      'color': Colors.red,
    },
    {
      'text': 'Item 2',
      'color': Colors.blue[300],
    },
    {
      'text': 'Item 3',
      'color': Colors.blue[100],
    },
    {
      'text': 'Item 4',
      'color': Colors.blue[100],
    },
    {
      'text': 'Item 5',
      'color': Colors.blue[100],
    },
    {
      'text': 'Item 6',
      'color': Colors.blue[100],
    },
    {
      'text': 'Item 7',
      'color': Colors.blue[100],
    },
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
              return _listData(listItems[index]);
            },
            // 区切り
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          )),
          // 区切り
          // const Divider(),
        ],
      ),
      // 追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // シフト編集詳細へ遷移
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShiftEditDetail()),
          );
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
  Widget _listData(items) {
    return SizedBox(
        height: 50,
        child: Container(
            child: ListTile(
                title: Row(children: [
          // 表示
          Expanded(
            flex: 1,
            child: Checkbox(
              activeColor: Colors.blue,
              value: true, // チェックフラグ
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
                "${items['text']}",
                textAlign: TextAlign.center,
              )),
          // 編集ボタン
          Expanded(
              flex: 2,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // ボタンが押された際の動作を記述する
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
        ]))));
  }
}
