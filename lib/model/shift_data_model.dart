import 'dart:convert';

class ShiftDataModel {
  int id;
  String shiftName;
  String baseDate;
  int shiftTableId;
  int recordOrderNum;
  String startTime;
  String endTime;
  bool holidayFlag;

  ShiftDataModel({
    required this.id,
    required this.shiftName,
    required this.baseDate,
    required this.shiftTableId,
    required this.recordOrderNum,
    required this.startTime,
    required this.endTime,
    required this.holidayFlag,
  });

  factory ShiftDataModel.fromJson(Map<String, dynamic> json) => ShiftDataModel(
        id: json["id"],
        shiftName: json["shiftName"],
        baseDate: json["baseDate"],
        shiftTableId: json["shiftTableId"],
        recordOrderNum: json["recordOrderNum"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        holidayFlag: json["holidayFlag"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shiftName": shiftName,
        "baseDate": baseDate,
        "shiftTableId": shiftTableId,
        "recordOrderNum": recordOrderNum,
        "startTime": startTime,
        "endTime": endTime,
        "holidayFlag": holidayFlag,
      };
}

ShiftDataModel modelFromJson(String str) =>
    ShiftDataModel.fromJson(json.decode(str));

String modelToJson(ShiftDataModel user) => json.encode(user.toJson());
