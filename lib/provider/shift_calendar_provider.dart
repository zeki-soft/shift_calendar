import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:sqlite3/sqlite3.dart';

// シフトカレンダーを取得するProvider
final shiftCalendarProvider =
    StateNotifierProvider<ShiftCalendarNotifier, List<ShiftDataModel>>((ref) {
  return ShiftCalendarNotifier();
});

class ShiftCalendarNotifier extends StateNotifier<List<ShiftDataModel>> {
  ShiftCalendarNotifier() : super(_ShiftDataUtil().getShiftCalendar());

  void update() {
    state = _ShiftDataUtil().getShiftCalendar();
  }
}

class _ShiftDataUtil {
  // シフト表データ全件取得
  List<ShiftDataModel> getShiftCalendar() {
    final ResultSet resultSet = CommonSql.db.select('''
          SELECT 
            T1.id AS shift_table_id,
            T1.shift_name AS shift_name,
            T1.base_date AS base_date,
            T2.id AS record_id,
            T2.order_num AS record_order_num,
            T2.start_time AS start_time,
            T2.end_time AS end_time,
            T2.holiday_flag AS holiday_flag
          FROM shift_table T1 INNER JOIN shift_record T2 ON T1.id = T2.shift_table_id
          WHERE T1.show_flag = 1
          ORDER BY T1.order_num ASC, T2.order_num ASC;
        ''');
    List<ShiftDataModel> list = [];
    for (Row row in resultSet) {
      ShiftDataModel model = ShiftDataModel(
          shiftTableId: row["shift_table_id"],
          shiftName: row["shift_name"],
          baseDate: row["base_date"],
          recordId: row['record_id'],
          recordOrderNum: row['record_order_num'],
          startTime: row['start_time'],
          endTime: row['end_time'],
          holidayFlag: row['holiday_flag'] == 1);
      list.add(model);
    }
    return list;
  }
}
