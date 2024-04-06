import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:sqlite3/sqlite3.dart';

class ShiftRecordSql extends CommonSql {
  // 順番号生成(初期値:0)
  static int generateOrderNum({required int shiftTableId}) {
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT IFNULL(MAX(order_num), 0) AS order_num FROM shift_record WHERE shift_table_id = ?
        ''', [shiftTableId]);
    int orderNum = 0;
    if (resultSet.isNotEmpty) {
      Row row = resultSet.first;
      orderNum = row['order_num'] + 1;
    }
    return orderNum;
  }

  // 新規作成(更新)
  static void insert({required List<ShiftRecordModel> recordList}) {
    try {
      final stmt = CommonSql.db.prepare('''
          INSERT INTO shift_record (shift_table_id, order_num, start_time, end_time)
          VALUES (?, ?, ?, ?)
          ON CONFLICT (shift_table_id, order_num) 
          DO UPDATE SET start_time = shift_record.start_time, end_time = shift_record.end_time
        ''');
      recordList.forEach((data) {
        stmt.execute([
          data.shiftTableId,
          data.orderNum,
          data.startTime,
          data.endTime,
        ]);
      });
      stmt.dispose();
    } catch (e) {
      print(e);
    }
  }

  // 更新
  static void update({required List<ShiftRecordModel> recordList}) {
    final stmt = CommonSql.db.prepare('''
          UPDATE shift_record SET 
          order_num = ?, start_time = ?, end_time = ?
          WHERE shift_table_id = ?
        ''');
    recordList.forEach((data) {
      stmt.execute([
        data.orderNum,
        data.startTime,
        data.endTime,
        data.shiftTableId,
      ]);
    });
    stmt.dispose();
  }

  // 削除
  static void delete({required int shiftTableId, int? orderNum}) {
    String sql = orderNum == null
        ? 'DELETE FROM shift_record WHERE shift_table_id = ?'
        : 'DELETE FROM shift_record WHERE shift_table_id = ? AND order_num = ?';
    final stmt = CommonSql.db.prepare(sql);
    stmt.execute(orderNum == null ? [shiftTableId] : [shiftTableId, orderNum]);
    stmt.dispose();
  }

  // 1件取得
  static ShiftRecordModel? getShiftRecord(
      {required int shiftTableId, required int orderNum}) {
    ShiftRecordModel? model;
    try {
      final ResultSet resultSet = CommonSql.db.select('''
        SELECT shift_table_id, order_num, start_time, end_time
        FROM shift_record WHERE shift_table_id = ? AND order_num = ?
        ''', [shiftTableId, orderNum]);
      if (resultSet.isNotEmpty) {
        Row row = resultSet.first;
        model = ShiftRecordModel(
            shiftTableId: row['shift_table_id'],
            orderNum: row['order_num'],
            startTime: row['start_time'],
            endTime: row['end_time']);
      }
    } catch (e) {
      print(e);
    }
    return model;
  }

  // 全件取得
  static List<ShiftRecordModel> getShiftRecordAll({required int shiftTableId}) {
    try {
      final ResultSet resultSet = CommonSql.db.select('''
        SELECT shift_table_id, order_num, start_time, end_time
        FROM shift_record WHERE shift_table_id = ?;
        ''', [shiftTableId]);
      List<ShiftRecordModel> list = [];
      for (Row row in resultSet) {
        ShiftRecordModel model = ShiftRecordModel(
            shiftTableId: row['shift_table_id'],
            orderNum: row['order_num'],
            startTime: row['start_time'],
            endTime: row['end_time']);
        list.add(model);
      }
      return list;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
