import 'dart:convert';

class ShiftRecordModel {
  int shiftTableId;
  int orderNum;
  String startTime;
  String endTime;

  ShiftRecordModel({
    required this.shiftTableId,
    required this.orderNum,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftRecordModel.fromJson(Map<String, dynamic> json) =>
      ShiftRecordModel(
        shiftTableId: json["shiftTableId"],
        orderNum: json["orderNum"],
        startTime: json["startTime"],
        endTime: json["endTime"],
      );

  Map<String, dynamic> toJson() => {
        "shiftTableId": shiftTableId,
        "orderNum": orderNum,
        "startTime": startTime,
        "endTime": endTime,
      };
}

ShiftRecordModel recordDataFromJson(String str) =>
    ShiftRecordModel.fromJson(json.decode(str));

String recordDataToJson(ShiftRecordModel user) => json.encode(user.toJson());
