import 'dart:convert';

class ShiftTableModel {
  final int id;
  final String shiftName;
  final bool showFlag;
  final String baseDate;
  final int orderNum;

  ShiftTableModel({
    required this.id,
    required this.shiftName,
    required this.showFlag,
    required this.baseDate,
    required this.orderNum,
  });

  factory ShiftTableModel.fromJson(Map<String, dynamic> json) =>
      ShiftTableModel(
        id: json["id"],
        shiftName: json["shiftName"],
        showFlag: json["showFlag"],
        baseDate: json["baseDate"],
        orderNum: json["orderNum"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shiftName": shiftName,
        "showFlag": showFlag,
        "baseDate": baseDate,
        "orderNum": orderNum,
      };
}

ShiftTableModel modelFromJson(String str) =>
    ShiftTableModel.fromJson(json.decode(str));

String modelToJson(ShiftTableModel user) => json.encode(user.toJson());
