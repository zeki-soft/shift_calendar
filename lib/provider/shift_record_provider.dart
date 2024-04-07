import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/sql/shift_record_sql.dart';

// シフトレコードを取得するProvider
// final shiftRecordProvider =
//     StateNotifierProvider<ShiftRecordNotifier, int>((ref) {
//   return ShiftRecordNotifier();
// });

// class ShiftRecordNotifier extends StateNotifier<int> {
//   ShiftRecordNotifier() : super(0);

//   void update(int shiftTableId) {
//     state = 3;
//   }
// }
