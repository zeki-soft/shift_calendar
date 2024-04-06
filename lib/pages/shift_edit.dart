import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/dialog/shift_title_dialog.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/pages/shift_edit_detail.dart';
import 'package:shift_calendar/provider/shift_record_provider.dart';
import 'package:shift_calendar/provider/shift_table_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

// シフト編集
class ShiftEdit extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // シフト表全件取得(監視)
    List<ShiftTableModel> listItems = ref.watch(shiftTableProvider);
    ShiftRecordNotifier shiftRecordController =
        ref.read(shiftRecordProvider.notifier);
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
                  listItems[index], context, ref, shiftRecordController);
            },
            itemCount: listItems.length,
            onReorder: (int oldIndex, int newIndex) {
              // 入れ替え処理(固定処理)
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              var item = listItems.removeAt(oldIndex);
              listItems.insert(newIndex, item);
              // TODO DB更新?
              // ShiftTableSql.upsert(id: shiftData.id);
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
  Widget _listData(ShiftTableModel shiftData, BuildContext context,
      WidgetRef ref, ShiftRecordNotifier shiftRecordController) {
    return Card(
        key: Key(shiftData.id.toString()), // キーで紐づけ
        child: Dismissible(
            key: Key(shiftData.id.toString()),
            onDismissed: (DismissDirection direction) {
              // リスト削除処理
              ShiftTableSql.delete(id: shiftData.id);
              ShiftRecordSql.delete(shiftTableId: shiftData.id);
              shiftRecordController.update(shiftData.id);
            },
            background: Container(
              color: Colors.grey[500],
            ),
            child: ListTile(
                onTap: () {
                  // シフト編集を更新
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
                      flex: 7,
                      child: Text(
                        shiftData.shiftName,
                        textAlign: TextAlign.center,
                      )),
                ]))));
  }
}
