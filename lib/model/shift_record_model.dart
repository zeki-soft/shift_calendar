import 'dart:convert';

class ShiftRecordModel {
  final int shiftTableId;
  final int orderNum;
  final String startTime;
  final String endTime;
  final String remarks;

  ShiftRecordModel({
    required this.shiftTableId,
    required this.orderNum,
    required this.startTime,
    required this.endTime,
    required this.remarks,
  });

  factory ShiftRecordModel.fromJson(Map<String, dynamic> json) =>
      ShiftRecordModel(
        shiftTableId: json["shiftTableId"],
        orderNum: json["orderNum"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        remarks: json["remarks"],
      );

  Map<String, dynamic> toJson() => {
        "shiftTableId": shiftTableId,
        "orderNum": orderNum,
        "startTime": startTime,
        "endTime": endTime,
        "remarks": remarks,
      };
}

ShiftRecordModel recordDataFromJson(String str) =>
    ShiftRecordModel.fromJson(json.decode(str));

String recordDataToJson(ShiftRecordModel user) => json.encode(user.toJson());
