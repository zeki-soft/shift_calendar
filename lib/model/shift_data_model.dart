import 'dart:convert';

class ShiftDataModel {
  int shiftTableId;
  String shiftName;
  String baseDate;
  int recordId;
  int recordOrderNum;
  String startTime;
  String endTime;
  bool holidayFlag;

  ShiftDataModel({
    required this.shiftTableId,
    required this.shiftName,
    required this.baseDate,
    required this.recordId,
    required this.recordOrderNum,
    required this.startTime,
    required this.endTime,
    required this.holidayFlag,
  });

  factory ShiftDataModel.fromJson(Map<String, dynamic> json) => ShiftDataModel(
        shiftTableId: json["shiftTableId"],
        shiftName: json["shiftName"],
        baseDate: json["baseDate"],
        recordId: json["recordId"],
        recordOrderNum: json["recordOrderNum"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        holidayFlag: json["holidayFlag"],
      );

  Map<String, dynamic> toJson() => {
        "shiftTableId": shiftTableId,
        "shiftName": shiftName,
        "baseDate": baseDate,
        "recordId": recordId,
        "recordOrderNum": recordOrderNum,
        "startTime": startTime,
        "endTime": endTime,
        "holidayFlag": holidayFlag,
      };
}

ShiftDataModel modelFromJson(String str) =>
    ShiftDataModel.fromJson(json.decode(str));

String modelToJson(ShiftDataModel user) => json.encode(user.toJson());
