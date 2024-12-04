import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/dialog/shift_title_dialog.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

// シフト編集
class ShiftEdit extends ConsumerWidget {
  int _selectValue = -1; // ラジオボタン選択値

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    // 更新監視用
    ref.watch(shiftCalendarProvider);
    List<ShiftTableModel> listItems = ShiftTableSql.getShiftTableAll();
    // ラジオボタン初期選択値
    _selectValue = -1;
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
                    listItems, index, context, ref, shiftCalendarController);
              },
              itemCount: listItems.length,
              onReorder: (int oldIndex, int newIndex) {
                // 入れ替え処理(old⇒newのindexに移動)
                if (oldIndex < newIndex) {
                  // 前方移動
                  newIndex -= 1;
                  for (int i = oldIndex; i < newIndex; i++) {
                    listItems[i + 1].orderNum = i;
                  }
                } else {
                  // 後方移動
                  for (int i = oldIndex; i > newIndex; i--) {
                    listItems[i - 1].orderNum = i;
                  }
                }
                // 直接指定した項目の移動
                listItems[oldIndex].orderNum = newIndex;
                // DB更新処理
                ShiftTableSql.update(tableList: listItems);
                // 画面更新処理
                shiftCalendarController.update();
              },
              proxyDecorator: (widget, _, __) {
                return Opacity(opacity: 0.5, child: widget);
              },
            )),
            const SizedBox(height: 70)
          ],
        ),
        // 追加ボタン
        floatingActionButton: SizedBox(
          width: 64.0,
          height: 64.0,
          child: FloatingActionButton(
            onPressed: () {
              // 4件以上は追加不可
              if (listItems.length >= 4) {
                // 新規作成の場合
                Fluttertoast.showToast(
                    msg: 'シフトは５件以上は登録できません。',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                return;
              }
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
        ));
  }

  // シフト一覧ヘッダー
  Widget _listDataHeader() {
    return Container(
        color: Colors.blue,
        child: const ListTile(
            title: Row(children: [
          Expanded(
              flex: 2,
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('表示',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(
              flex: 7,
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('シフト名',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)))),
        ])));
  }

  // シフトデータ
  Widget _listData(
      List<ShiftTableModel> itemList,
      int index,
      BuildContext context,
      WidgetRef ref,
      ShiftCalendarNotifier shiftCalendarController) {
    ShiftTableModel shiftData = itemList[index];
    return Card(
        key: Key(shiftData.id.toString()), // キー指定
        child: Dismissible(
            key: Key(shiftData.id.toString()),
            onDismissed: (DismissDirection direction) {
              // リスト削除処理
              ShiftTableSql.delete(id: shiftData.id);
              // 順番を更新
              List<ShiftTableModel> items = ShiftTableSql.getShiftTableAll();
              // 順番を更新
              for (int i = index; i < items.length; i++) {
                items[i].orderNum = i;
              }
              ShiftTableSql.updateList(list: items);
              // 画面を更新
              shiftCalendarController.update();
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
                    title: Text(
                      shiftData.shiftName,
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                    ), // ダイアログのタイトル
                    content: const Text('シフトを削除しますか？'), // ダイアログのメッセージ
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('削除'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('キャンセル'),
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
                  // シフト編集詳細へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShiftEditDetail(shiftData: shiftData)),
                  );
                },
                title: Row(children: [
                  // 表示チェックボックス
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
                          ShiftTableSql.update(tableList: [shiftData]);
                          // 画面更新処理
                          shiftCalendarController.update();
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
