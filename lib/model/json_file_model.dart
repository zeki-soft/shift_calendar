import 'package:shift_calendar/model/shift_record_model.dart';
import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class JsonFIleModel {
  List<ShiftTableModel> tableList;
  List<ShiftRecordModel> recordList;

  JsonFIleModel({required this.tableList, required this.recordList});

  static JsonFIleModel fromJson(Map<String, dynamic> json) {
    List<ShiftTableModel> tableList = [];
    List<ShiftRecordModel> recordList = [];
    json['tableList'].forEach((element) {
      tableList.add(ShiftTableModel.fromJson(element));
    });
    json['recordList'].forEach((element) {
      recordList.add(ShiftRecordModel.fromJson(element));
    });
    return JsonFIleModel(tableList: tableList, recordList: recordList);
  }

  Map<String, dynamic> toJson() => {
        'tableList': tableList,
        'recordList': recordList,
      };
}
