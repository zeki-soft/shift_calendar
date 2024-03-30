import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:sqlite3/sqlite3.dart';

// 譜面データを取得するProvider
final shiftDataProvider = FutureProvider<dynamic>((ref) {
  return _ShiftDataUtil().getShiftDataAll();
});

class _ShiftDataUtil {
  // シフト表データ全件取得
  List<ShiftDataModel> getShiftDataAll() {
    final ResultSet resultSet = CommonSql.db.select('''
          SELECT 
            T1.id AS id,
            T1.shift_name AS shift_name,
            T1.show_flag AS show_flag,
            T1.base_date AS base_date,
            T1.order_num AS table_order_num,
            T2.shift_table_id AS shift_table_id,
            T2.order_num AS record_order_num,
            T2.start_time AS start_time,
            T2.end_time AS end_time,
            T2.remarks AS remarks
          FROM shift_table T1 LEFT JOIN shift_record T2 ON T1.id = T2.shift_table_id
          ORDER BY T1.order_num ASC, T2.order_num ASC;
        ''');
    List<ShiftDataModel> list = [];
    for (Row row in resultSet) {
      ShiftDataModel model = ShiftDataModel(
          id: row["id"],
          shiftName: row["shift_name"],
          showFlag: row["show_flag"],
          baseDate: row["base_date"],
          tableOrderNum: row["table_order_num"],
          shiftTableId: row['shift_table_id'],
          recordOrderNum: row['order_num'],
          startTime: row['start_time'],
          endTime: row['end_time'],
          remarks: row['remarks']);
      list.add(model);
    }
    return list;
  }
}
