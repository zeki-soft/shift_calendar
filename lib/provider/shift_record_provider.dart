import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';
import 'package:shift_calendar/utils/const.dart';

// シフトレコードを取得するProvider
final shiftRecordProvider = FutureProvider<List<ShiftRecordModel>>((ref) {
  return ShiftRecordSql.getShiftRecordAll(shiftTableId: Const.editShiftTableId);
});
