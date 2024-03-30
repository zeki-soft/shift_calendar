import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:sqlite3/sqlite3.dart';

class ShiftRecordSql extends CommonSql {
  // 新規作成(更新)
  static void upsert({required ShiftRecordModel model}) {
    final stmt = CommonSql.db.prepare('''
          INSERT INTO shift_record (shift_table_id, order_num, start_time, end_time, remarks)
          VALUES (?, ?, ?, ?, ?)
          ON CONFLICT (shift_table_id, order_num) 
          DO UPDATE SET start_time = ?, end_time = ?, remarks = ?;
        ''');
    stmt.execute([
      model.shiftTableId,
      model.orderNum,
      model.startTime,
      model.endTime,
      model.remarks,
      model.startTime, // キー重複時
      model.endTime, // キー重複時
      model.remarks // キー重複時
    ]);
    stmt.dispose();
  }

  // 更新
  // static void update({required ShiftRecordModel model}) {
  //   final stmt = CommonSql.db.prepare('''
  //         UPDATE shift_record
  //         SET order_num = ?, start_time = ?, end_time = ?, remarks = ?
  //         WHERE shift_table_id = ?
  //       ''');
  //   stmt.execute([
  //     model.orderNum,
  //     model.startTime,
  //     model.endTime,
  //     model.remarks,
  //     model.shiftTableId
  //   ]);
  //   stmt.dispose();
  // }

  // 削除
  static void delete({required int shiftTableId}) {
    final stmt = CommonSql.db.prepare('''
          DELETE FROM shift_record WHERE shift_table_id = ?
        ''');
    stmt.execute([shiftTableId]);
    stmt.dispose();
  }

  // 1件取得
  static ShiftRecordModel? getShiftRecord(
      {required int shiftTableId, required int orderNum}) {
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT shift_table_id, order_num, start_time, end_time, remarks
        FROM shift_record WHERE shift_table_id = ? AND order_num = ?
        ''', [shiftTableId, orderNum]);

    ShiftRecordModel? model;
    if (resultSet.isNotEmpty) {
      Row row = resultSet.first;
      model = ShiftRecordModel(
          shiftTableId: row['shift_table_id'],
          orderNum: row['order_num'],
          startTime: row['start_time'],
          endTime: row['end_time'],
          remarks: row['remarks']);
    }
    return model;
  }

  // 全件取得
  static List<ShiftRecordModel> getShiftRecordAll({required int shiftTableId}) {
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT shift_table_id, order_num, start_time, end_time, remarks
        FROM shift_record
        ''', [shiftTableId]);
    List<ShiftRecordModel> list = [];
    for (Row row in resultSet) {
      ShiftRecordModel model = ShiftRecordModel(
          shiftTableId: row['shift_table_id'],
          orderNum: row['order_num'],
          startTime: row['start_time'],
          endTime: row['end_time'],
          remarks: row['remarks']);
      list.add(model);
    }
    return list;
  }
}
