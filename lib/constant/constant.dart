import 'package:flutter/widgets.dart';

class Constant {
  static double deviceWidth = 0;
  static double deviceHeight = 0;
  static double aspectRatio = 0;

  // シフト一覧用変数
  static int appointmentDisplayCount = 4; // イベント表示数
  static double agendaItemHeight = 0; // イベントセルの高さ
  static double agendaViewHeight = 0; // イベントビューの高さ
  static double eventFontSize = 0; // イベントのフォントサイズ
  static int spaceCount = 0; // スペース数

  static initialize(BuildContext context) {
    // 画面サイズ取得
    final Size size = MediaQuery.of(context).size;
    deviceWidth = size.width;
    deviceHeight = size.height;
    aspectRatio = deviceHeight / deviceWidth;

    print(
        '画面サイズ:${deviceWidth.toStringAsFixed(0)}-${deviceHeight.toStringAsFixed(0)}[${aspectRatio.toStringAsFixed(2)}]');
    // シフト一覧のイベント表示数
    if (size.aspectRatio >= 0.648) {
      // 3:5(Nexus4)
      appointmentDisplayCount = 4;
      eventFontSize = 3.5;
      agendaItemHeight = 7;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (70 / aspectRatio).toInt();
    } else if (size.aspectRatio >= 0.602) {
      // 9:16(Nexus6)
      appointmentDisplayCount = 4;
      eventFontSize = 6.5;
      agendaItemHeight = 10;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
    } else if (size.aspectRatio >= 0.515) {
      // 9:18.5(Pixel3XL)
      appointmentDisplayCount = 4;
      eventFontSize = 9;
      agendaItemHeight = 13;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
    } else if (size.aspectRatio >= 0.501) {
      // 9:19(Pixel4XL)
      appointmentDisplayCount = 4;
      eventFontSize = 9;
      agendaItemHeight = 13;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
    } else if (size.aspectRatio >= 0.489) {
      // 9:19.5(Pixel5)
      appointmentDisplayCount = 4;
      eventFontSize = 9;
      agendaItemHeight = 13;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
    } else if (size.aspectRatio >= 0.474) {
      // 9:20(Pixel6a)
      appointmentDisplayCount = 4;
      eventFontSize = 10;
      agendaItemHeight = 14;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
    } else {
      // 9:20より縦長（基本ない）
      appointmentDisplayCount = 4;
      eventFontSize = 10;
      agendaItemHeight = 14;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
    }
  }
}
