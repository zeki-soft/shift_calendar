import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/dialog/shift_title_dialog.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/provider/shift_record_provider.dart';
import 'package:shift_calendar/provider/shift_table_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

// シフト編集
class ShiftEdit extends ConsumerWidget {
  int _selectValue = 0; // ラジオボタン選択値

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // シフト表全件取得(監視)
    List<ShiftTableModel> listItems = ref.watch(shiftTableProvider);
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    ShiftTableNotifier shiftTableController =
        ref.read(shiftTableProvider.notifier);
    ShiftRecordNotifier shiftRecordController =
        ref.read(shiftRecordProvider.notifier);

    // ラジオボタン初期選択値
    _selectValue = 0;
    listItems.forEach((item) {
      if (item.showFlag) {
        _selectValue = item.orderNum;
        return;
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // シフト一覧ヘッダー
          _listDataHeader(),
          // シフト一覧
          Expanded(
              // 入れ替え可能リスト
              child: ReorderableListView.builder(
            itemBuilder: (context, index) {
              return _listData(
                  listItems,
                  index,
                  context,
                  ref,
                  shiftCalendarController,
                  shiftTableController,
                  shiftRecordController);
            },
            itemCount: listItems.length,
            onReorder: (int oldIndex, int newIndex) {
              // 入れ替え処理(old⇒newのindexに移動)
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              listItems[oldIndex].orderNum = newIndex;
              listItems[newIndex].orderNum = oldIndex;
              // DB更新処理
              ShiftTableSql.update(model: listItems[oldIndex]);
              ShiftTableSql.update(model: listItems[newIndex]);
              // 画面更新処理
              shiftCalendarController.update();
              shiftTableController.update();
            },
            proxyDecorator: (widget, _, __) {
              return Opacity(opacity: 0.5, child: widget);
            },
          )),
        ],
      ),
      // 追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 新規ID取得
          int id = ShiftTableSql.generateId();
          // 新規作成データを生成
          ShiftTableModel shiftData = ShiftTableModel(
              id: id, // 新規ID取得
              shiftName: '新規シフト',
              showFlag: id == 0, // 初回のみ対象
              baseDate: DateFormat('yyyy/MM/dd').format(DateTime.now()),
              orderNum: ShiftTableSql.generateOrderNum());
          // シフト編集詳細へ遷移(新規作成)のダイアログ表示
          showDialog<void>(
              barrierColor: Colors.grey.withOpacity(0.8),
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return ShiftTitleDialog(
                    shiftData: shiftData, ref: ref, updateFlag: false);
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
        color: Colors.blue,
        child: const ListTile(
            title: Row(children: [
          Expanded(
              flex: 2,
              child: Text('シフト表示',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 7,
              child: Text('シフト名',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ])));
  }

  // シフトデータ
  Widget _listData(
      List<ShiftTableModel> itemList,
      int index,
      BuildContext context,
      WidgetRef ref,
      ShiftCalendarNotifier shiftCalendarController,
      ShiftTableNotifier shiftTableController,
      ShiftRecordNotifier shiftRecordController) {
    ShiftTableModel shiftData = itemList[index];
    return Card(
        key: Key(shiftData.id.toString()), // キーで紐づけ
        child: Dismissible(
            key: Key(shiftData.id.toString()),
            onDismissed: (DismissDirection direction) {
              // リスト削除処理
              ShiftTableSql.delete(id: shiftData.id);
              // 順番を更新
              List<ShiftTableModel> items = ShiftTableSql.getShiftTableAll();
              // 順番を更新
              for (int i = 0; i < items.length; i++) {
                items[i].orderNum = i;
              }
              ShiftTableSql.updateList(list: items);
              // 画面を更新
              shiftCalendarController.update();
              shiftRecordController.update(shiftData.id);
              // メッセージ
              Fluttertoast.showToast(
                  msg: '【${shiftData.shiftName}】\nシフトを削除しました。',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            confirmDismiss: (direction) async {
              // アイテムを削除する前に確認ダイアログを表示する
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(shiftData.shiftName), // ダイアログのタイトル
                    content: const Text('シフトを削除しますか？'), // ダイアログのメッセージ
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('削除'),
                      ),
                    ],
                  );
                },
              );
            },
            background: Container(
              color: Colors.grey[500],
            ),
            child: ListTile(
                onTap: () {
                  // シフト編集を更新
                  shiftCalendarController.update();
                  shiftRecordController.update(shiftData.id);
                  // シフト編集詳細へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShiftEditDetail(shiftData: shiftData)),
                  );
                },
                title: Row(children: [
                  // シフト表示
                  Expanded(
                    flex: 2,
                    child: Radio(
                        value: shiftData.orderNum,
                        groupValue: _selectValue,
                        onChanged: (value) {
                          _selectValue = value!;
                          // 表示フラグOFF
                          ShiftTableSql.offShowFlag();
                          // 表示フラグ更新
                          shiftData.showFlag = true;
                          ShiftTableSql.update(model: shiftData);
                          // 画面更新処理
                          shiftCalendarController.update();
                          shiftTableController.update();
                        }),
                  ),
                  // シフト名
                  Expanded(
                      flex: 7,
                      child: Text(
                        shiftData.shiftName,
                        textAlign: TextAlign.center,
                      )),
                ]))));
  }
}
