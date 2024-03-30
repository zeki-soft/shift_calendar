import 'package:flutter/material.dart';

// シフト編集詳細
class ShiftEditDetail extends StatefulWidget {
  @override
  _ShiftEditDetailState createState() => _ShiftEditDetailState();
}

class _ShiftEditDetailState extends State<ShiftEditDetail> {
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
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
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
              return _listData(listItems[index]);
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
              flex: 2,
              child: Text('日付',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('開始時間',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('終了時間',
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
  Widget _listData(items) {
    return SizedBox(
        height: 50,
        child: Container(
            child: ListTile(
                title: Row(children: [
          Expanded(
              flex: 2,
              child: Text(
                '2024/04/10',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '03:00',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '10:00',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit),
              )),
        ]))));
  }
}
