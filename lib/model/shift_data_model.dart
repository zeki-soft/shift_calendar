import 'dart:convert';

class ShiftDataModel {
  int id;
  String shiftName;
  bool showFlag;
  String baseDate;
  int tableOrderNum;
  int shiftTableId;
  int recordOrderNum;
  String startTime;
  String endTime;
  String remarks;

  ShiftDataModel({
    required this.id,
    required this.shiftName,
    required this.showFlag,
    required this.baseDate,
    required this.tableOrderNum,
    required this.shiftTableId,
    required this.recordOrderNum,
    required this.startTime,
    required this.endTime,
    required this.remarks,
  });

  factory ShiftDataModel.fromJson(Map<String, dynamic> json) => ShiftDataModel(
        id: json["id"],
        shiftName: json["shiftName"],
        showFlag: json["showFlag"],
        baseDate: json["baseDate"],
        tableOrderNum: json["tableOrderNum"],
        shiftTableId: json["shiftTableId"],
        recordOrderNum: json["recordOrderNum"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        remarks: json["remarks"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shiftName": shiftName,
        "showFlag": showFlag,
        "baseDate": baseDate,
        "tableOrderNum": tableOrderNum,
        "shiftTableId": shiftTableId,
        "recordOrderNum": recordOrderNum,
        "startTime": startTime,
        "endTime": endTime,
        "remarks": remarks,
      };
}

ShiftDataModel modelFromJson(String str) =>
    ShiftDataModel.fromJson(json.decode(str));

String modelToJson(ShiftDataModel user) => json.encode(user.toJson());
