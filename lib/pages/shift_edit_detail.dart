import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/dialog/shift_title_dialog.dart';
import 'package:shift_calendar/dialog/time_edit_dialog.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';

// シフト編集詳細
class ShiftEditDetail extends ConsumerWidget {
  ShiftTableModel shiftData;
  ShiftEditDetail({required this.shiftData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShiftCalendarNotifier shiftCalendarController =
        ref.read(shiftCalendarProvider.notifier);
    // 更新監視用
    ref.watch(shiftCalendarProvider);
    List<ShiftRecordModel> listItems =
        ShiftRecordSql.getShiftRecordAll(shiftTableId: shiftData.id);

    return Scaffold(
      appBar: AppBar(
        // 戻るボタン(バックボタン?)
        leading: IconButton(
          onPressed: () {
            // 前画面を更新
            shiftCalendarController.update();
            // 画面を閉じる
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        // シフト名(タイトル)
        title: Text(shiftData.shiftName),
        // 右側のアイコン一覧
        actions: <Widget>[
          // シフト名編集ボタン
          IconButton(
            onPressed: () async {
              // シフト名、シフト基準日を編集するダイアログ表示
              final result = await showDialog<bool>(
                  barrierColor: Colors.grey.withOpacity(0.8),
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => PopScope(
                      canPop: false,
                      child: ShiftTitleDialog(
                          shiftData: shiftData, ref: ref, updateFlag: true)));
              if (result != null && result) {
                // ダイアログを閉じた際の処理
                print('');
              }
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
              // 入れ替え可能リスト
              child: ReorderableListView.builder(
                  itemBuilder: (context, index) {
                    return _listData(shiftData, listItems, index, context, ref,
                        shiftCalendarController);
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
                    ShiftRecordSql.update(recordList: listItems);
                    // 画面更新処理
                    shiftCalendarController.update();
                  },
                  proxyDecorator: (widget, _, __) {
                    return Opacity(opacity: 0.5, child: widget);
                  })),
          const SizedBox(height: 50)
        ],
      ),
      // 追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 新規作成データを生成
          ShiftRecordModel recordData = ShiftRecordModel(
              id: ShiftRecordSql.generateId(),
              shiftTableId: shiftData.id,
              orderNum:
                  ShiftRecordSql.generateOrderNum(shiftTableId: shiftData.id),
              startTime: '',
              endTime: '',
              holidayFlag: false);
          // シフトレコード(新規作成)のダイアログ表示
          showDialog<void>(
              barrierColor: Colors.grey.withOpacity(0.8),
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return TimeEditDialog(
                    shiftData: shiftData,
                    recordData: recordData,
                    ref: ref,
                    updateFlag: false);
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
              child: Text('シフト基準日',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('開始時間',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('終了時間',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('休日',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ])));
  }

  // シフトデータ
  Widget _listData(
      ShiftTableModel shiftData,
      List<ShiftRecordModel> itemList,
      int index,
      BuildContext context,
      WidgetRef ref,
      ShiftCalendarNotifier shiftCalendarController) {
    // シフト基準日を計算
    ShiftRecordModel item = itemList[index];
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    DateTime date = dateFormat.parseStrict(shiftData.baseDate);
    String baseDate =
        dateFormat.format(date.add(Duration(days: item.orderNum)));
    return Card(
        key: Key(item.id.toString()), // キー指定
        child: Dismissible(
            key: Key(item.id.toString()),
            onDismissed: (DismissDirection direction) {
              // リスト削除処理
              ShiftRecordSql.delete(id: item.id);
              // 順番を更新
              List<ShiftRecordModel> items = ShiftRecordSql.getShiftRecordAll(
                  shiftTableId: item.shiftTableId);
              for (int i = index; i < items.length; i++) {
                items[i].orderNum = i;
              }
              ShiftRecordSql.update(recordList: items);
              // 画面を更新
              shiftCalendarController.update();
              // メッセージ
              Fluttertoast.showToast(
                  msg: 'シフトを削除しました。',
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
                    title: Text('シフト基準日: $baseDate',
                        style: const TextStyle(
                            color: Colors.black, fontSize: 20)), // ダイアログのタイトル
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
                onTap: () => {
                      // 休日でない場合のみ
                      if (!item.holidayFlag)
                        {
                          // シフト時間を編集
                          showDialog<void>(
                              barrierColor: Colors.grey.withOpacity(0.8),
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                // 編集ダイアログ表示
                                return TimeEditDialog(
                                    shiftData: shiftData,
                                    recordData: item,
                                    ref: ref,
                                    updateFlag: true);
                              })
                        }
                    },
                title: Row(children: [
                  Expanded(
                      // シフト基準日
                      flex: 2,
                      child: Text(
                        baseDate,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      // 開始時間
                      flex: 2,
                      child: Text(
                        item.holidayFlag ? '' : item.startTime,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      // 終了時間
                      flex: 2,
                      child: Text(
                        item.holidayFlag ? '' : item.endTime,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                    // 休日
                    flex: 1,
                    child: Checkbox(
                        activeColor: Colors.blue,
                        value: item.holidayFlag,
                        onChanged: (flag) {
                          // DB更新処理
                          item.holidayFlag = flag!;
                          ShiftRecordSql.update(recordList: [item]);
                          // 前画面を更新
                          shiftCalendarController.update();
                        }),
                  ),
                ]))));
  }
}
