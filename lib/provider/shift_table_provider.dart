import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/sql/shift_table_sql.dart';

// シフト表を取得するProvider
final shiftTableProvider =
    StateNotifierProvider<ShiftTableNotifier, List<ShiftTableModel>>((ref) {
  return ShiftTableNotifier();
});

class ShiftTableNotifier extends StateNotifier<List<ShiftTableModel>> {
  ShiftTableNotifier() : super(ShiftTableSql.getShiftTableAll());

  void update() {
    state = ShiftTableSql.getShiftTableAll();
  }
}
