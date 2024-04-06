import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar/dialog/shift_title_dialog.dart';
import 'package:shift_calendar/dialog/time_edit_dialog.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/provider/shift_record_provider.dart';
import 'package:shift_calendar/provider/shift_table_provider.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';

// シフト編集詳細
class ShiftEditDetail extends ConsumerWidget {
  ShiftTableModel shiftData;
  bool newFlag = false;
  ShiftEditDetail({required this.shiftData, this.newFlag = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShiftTableNotifier shiftTableController =
        ref.read(shiftTableProvider.notifier);
    ShiftRecordNotifier shiftRecordController =
        ref.read(shiftRecordProvider.notifier);
    // シフトレコード全件取得(監視)
    List<ShiftRecordModel> listItems = ref.watch(shiftRecordProvider);
    if (newFlag) {
      // 新規作成の場合
      Fluttertoast.showToast(
          msg: 'サンプルのシフトデータを作成しました。',
          // toastLength: Toast.LENGTH_LONG,
          // gravity: ToastGravity.CENTER,
          // timeInSecForIosWeb: 3,
          // backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    return Scaffold(
      appBar: AppBar(
        // 戻るボタン(バックボタン?)
        leading: IconButton(
          onPressed: () {
            // 前画面を更新
            shiftTableController.update();
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
                    return _listData(listItems[index], index, context, ref,
                        shiftRecordController);
                  },
                  itemCount: listItems.length,
                  onReorder: (int oldIndex, int newIndex) {
                    // 入れ替え処理(固定処理) TODO 禁止
                    // if (oldIndex < newIndex) {
                    //   newIndex -= 1;
                    // }
                    // var item = items.removeAt(oldIndex);
                    // items.insert(newIndex, item);
                  },
                  proxyDecorator: (widget, _, __) {
                    return Opacity(opacity: 0.5, child: widget);
                  }))
        ],
      ),
      // 追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 新規作成データを生成
          ShiftRecordModel recordData = ShiftRecordModel(
              shiftTableId: shiftData.id,
              orderNum:
                  ShiftRecordSql.generateOrderNum(shiftTableId: shiftData.id),
              startTime: '',
              endTime: '');
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
                    updateFlag: true);
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
              flex: 1,
              child: Text('シフト基準日',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('開始時間',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('終了時間',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ])));
  }

  // シフトデータ
  Widget _listData(ShiftRecordModel item, int index, BuildContext context,
      WidgetRef ref, ShiftRecordNotifier shiftRecordController) {
    // シフト基準日を計算
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    DateTime date = dateFormat.parseStrict(shiftData.baseDate);
    String baseDate = dateFormat.format(date.add(Duration(days: index)));
    return Card(
        key: Key(item.orderNum.toString()), // キー指定
        child: Dismissible(
            key: Key(item.orderNum.toString()),
            onDismissed: (DismissDirection direction) {
              // リスト削除処理
              ShiftRecordSql.delete(
                  shiftTableId: item.shiftTableId, orderNum: item.orderNum);
              shiftRecordController.update(item.shiftTableId);
            },
            background: Container(
              color: Colors.grey[500],
            ),
            child: ListTile(
                onTap: () => {
                      // シフト時間、備考を編集
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
                                updateFlag: false);
                          })
                    },
                title: Row(children: [
                  Expanded(
                      // シフト基準日
                      flex: 1,
                      child: Text(
                        baseDate,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      // 開始時間
                      flex: 1,
                      child: Text(
                        item.startTime,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      // 終了時間
                      flex: 1,
                      child: Text(
                        item.endTime,
                        textAlign: TextAlign.center,
                      )),
                ]))));
  }
}
