import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

// シフト表を取得するProvider
final shiftTableProvider = FutureProvider<List<ShiftTableModel>>((ref) {
  return ShiftTableSql.getShiftTableAll();
});
