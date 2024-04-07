import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:sqlite3/sqlite3.dart';

class ShiftRecordSql extends CommonSql {
  // ID生成(初期値:0)
  static int generateId() {
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT IFNULL(MAX(id), 0) AS id FROM shift_record
        ''');
    int id = 0;
    if (resultSet.isNotEmpty) {
      Row row = resultSet.first;
      id = row['id'] + 1;
    }
    return id;
  }

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
          INSERT INTO shift_record (id, shift_table_id, order_num, start_time, end_time, holiday_flag)
          VALUES (?, ?, ?, ?, ?, ?)
          ON CONFLICT (id) 
          DO UPDATE SET shift_table_id = shift_record.shift_table_id, order_num = shift_record.order_num, 
            start_time = shift_record.start_time, end_time = shift_record.end_time, holiday_flag = shift_record.holiday_flag;
        ''');
      recordList.forEach((data) {
        stmt.execute([
          data.id,
          data.shiftTableId,
          data.orderNum,
          data.startTime,
          data.endTime,
          data.holidayFlag,
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
          UPDATE shift_record 
          SET shift_table_id = ?, order_num = ?, start_time = ?, end_time = ?, holiday_flag = ?
          WHERE id = ?;
        ''');
    recordList.forEach((data) {
      stmt.execute([
        data.shiftTableId,
        data.orderNum,
        data.startTime,
        data.endTime,
        data.holidayFlag,
        data.id,
      ]);
    });
    stmt.dispose();
  }

  // 削除
  static void delete({int? id, int? shiftTableId}) {
    // 削除処理
    String sql;
    List<Object?> whereList = [];
    if (id == null && shiftTableId == null) {
      sql = 'DELETE FROM shift_record';
    } else if (id != null) {
      sql = 'DELETE FROM shift_record WHERE id = ?';
      whereList.add(id);
    } else {
      sql = 'DELETE FROM shift_record WHERE shift_table_id = ?';
      whereList.add(shiftTableId);
    }
    var stmt = CommonSql.db.prepare(sql);
    stmt.execute(whereList);
    stmt.dispose();
  }

  // 1件取得
  static ShiftRecordModel? getShiftRecord({required int id}) {
    ShiftRecordModel? model;
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT id, shift_table_id, order_num, start_time, end_time, holiday_flag
        FROM shift_record 
        WHERE id = ?
        ORDER BY order_num ASC;
        ''', [id]);
    if (resultSet.isNotEmpty) {
      Row row = resultSet.first;
      model = ShiftRecordModel(
          id: row['id'],
          shiftTableId: row['shift_table_id'],
          orderNum: row['order_num'],
          startTime: row['start_time'],
          endTime: row['end_time'],
          holidayFlag: row['holiday_flag'] == 1);
    }
    return model;
  }

  // 全件取得
  static List<ShiftRecordModel> getShiftRecordAll({int? shiftTableId}) {
    ResultSet resultSet;
    if (shiftTableId != null) {
      resultSet = CommonSql.db.select('''
        SELECT id, shift_table_id, order_num, start_time, end_time, holiday_flag
        FROM shift_record 
        WHERE shift_table_id = ?
        ORDER BY order_num ASC;
        ''', [shiftTableId]);
    } else {
      resultSet = CommonSql.db.select('''
        SELECT id, shift_table_id, order_num, start_time, end_time, holiday_flag 
        FROM shift_record
        ORDER BY order_num ASC;
        ''');
    }
    List<ShiftRecordModel> list = [];
    for (Row row in resultSet) {
      ShiftRecordModel model = ShiftRecordModel(
          id: row['id'],
          shiftTableId: row['shift_table_id'],
          orderNum: row['order_num'],
          startTime: row['start_time'],
          endTime: row['end_time'],
          holidayFlag: row['holiday_flag'] == 1);
      list.add(model);
    }
    return list;
  }

  // テーブル削除
  static truncate() {
    var stmt = CommonSql.db.prepare('DELETE FROM shift_record');
    stmt.execute();
    stmt.dispose();
  }
}
