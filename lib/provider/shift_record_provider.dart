import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';

// シフトレコードを取得するProvider
final shiftRecordProvider =
    StateNotifierProvider<ShiftRecordNotifier, List<ShiftRecordModel>>((ref) {
  return ShiftRecordNotifier();
});

class ShiftRecordNotifier extends StateNotifier<List<ShiftRecordModel>> {
  ShiftRecordNotifier() : super([]);

  void update(int shiftTableId) {
    state = ShiftRecordSql.getShiftRecordAll(shiftTableId: shiftTableId);
  }
}
