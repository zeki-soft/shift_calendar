import 'dart:convert';

class ShiftRecordModel {
  int id;
  int shiftTableId;
  int orderNum;
  String startTime;
  String endTime;
  bool holidayFlag;

  ShiftRecordModel({
    required this.id,
    required this.shiftTableId,
    required this.orderNum,
    required this.startTime,
    required this.endTime,
    required this.holidayFlag,
  });

  factory ShiftRecordModel.fromJson(Map<String, dynamic> json) =>
      ShiftRecordModel(
        id: json["id"],
        shiftTableId: json["shiftTableId"],
        orderNum: json["orderNum"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        holidayFlag: json["holidayFlag"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shiftTableId": shiftTableId,
        "orderNum": orderNum,
        "startTime": startTime,
        "endTime": endTime,
        "holidayFlag": holidayFlag,
      };
}

ShiftRecordModel recordDataFromJson(String str) =>
    ShiftRecordModel.fromJson(json.decode(str));

String recordDataToJson(ShiftRecordModel user) => json.encode(user.toJson());
