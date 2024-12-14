import 'package:flutter/widgets.dart';

class Constant {
  static double deviceWidth = 0;
  static double deviceHeight = 0;
  static double aspectRatio = 0;

  // シフト一覧用変数
  static int appointmentDisplayCount = 4; // イベント表示数
  static double agendaItemHeight = 0; // イベントセルの高さ
  static double agendaViewHeight = 0; // イベントビューの高さ
  static double eventFontSize = 0; // イベントのフォントサイズ(シフト一覧)
  static int spaceCount = 0; // スペース数

  // シフト一覧用変数
  static double agendaItemHeightSingle = 0; // イベントセルの高さ
  static double agendaViewHeightSingle = 0; // イベントビューの高さ
  static double eventFontSizeSingle = 0; // イベントのフォントサイズ(シフト一覧)
  static int spaceCountSingle = 0; // スペース数
  static int appointmentDisplayCountSingle = 2; // イベント表示数

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
      // シングル向け
      eventFontSizeSingle = 16;
      agendaItemHeightSingle = 25;
      agendaViewHeightSingle = 150 - (150 / aspectRatio);
      spaceCountSingle = (10 / aspectRatio).toInt();
      appointmentDisplayCountSingle = 1;
    } else if (size.aspectRatio >= 0.602) {
      // 9:16(Nexus6)
      appointmentDisplayCount = 4;
      eventFontSize = 6.5;
      agendaItemHeight = 10;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
      // シングル向け
      eventFontSizeSingle = 24;
      agendaItemHeightSingle = 40;
      agendaViewHeightSingle = 150 - (150 / aspectRatio);
      spaceCountSingle = (10 / aspectRatio).toInt();
      appointmentDisplayCountSingle = 1;
    } else if (size.aspectRatio >= 0.515) {
      // 9:18.5(Pixel3XL)
      appointmentDisplayCount = 4;
      eventFontSize = 9;
      agendaItemHeight = 13;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
      // シングル向け
      eventFontSizeSingle = 18;
      agendaItemHeightSingle = 32;
      agendaViewHeightSingle = 150 - (150 / aspectRatio);
      spaceCountSingle = (10 / aspectRatio).toInt();
      appointmentDisplayCountSingle = 2;
    } else if (size.aspectRatio >= 0.501) {
      // 9:19(Pixel4XL)
      appointmentDisplayCount = 4;
      eventFontSize = 9;
      agendaItemHeight = 13;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
      // シングル向け
      eventFontSizeSingle = 18;
      agendaItemHeightSingle = 32;
      agendaViewHeightSingle = 150 - (150 / aspectRatio);
      spaceCountSingle = (10 / aspectRatio).toInt();
      appointmentDisplayCountSingle = 2;
    } else if (size.aspectRatio >= 0.489) {
      // 9:19.5(Pixel5)
      appointmentDisplayCount = 4;
      eventFontSize = 9;
      agendaItemHeight = 13;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
      // シングル向け
      eventFontSizeSingle = 18;
      agendaItemHeightSingle = 32;
      agendaViewHeightSingle = 150 - (150 / aspectRatio);
      spaceCountSingle = (10 / aspectRatio).toInt();
      appointmentDisplayCountSingle = 2;
    } else if (size.aspectRatio >= 0.474) {
      // 9:20(Pixel6a)
      appointmentDisplayCount = 4;
      eventFontSize = 10;
      agendaItemHeight = 14;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
      // シングル向け
      eventFontSizeSingle = 25;
      agendaItemHeightSingle = 32;
      agendaViewHeightSingle = 150 - (150 / aspectRatio);
      spaceCountSingle = (10 / aspectRatio).toInt();
      appointmentDisplayCountSingle = 2;
    } else {
      // 9:20より縦長（基本ない）
      appointmentDisplayCount = 4;
      eventFontSize = 10;
      agendaItemHeight = 14;
      agendaViewHeight = 150 - (150 / aspectRatio);
      spaceCount = (50 / aspectRatio).toInt();
      // シングル向け
      eventFontSizeSingle = 25;
      agendaItemHeightSingle = 32;
      agendaViewHeightSingle = 150 - (150 / aspectRatio);
      spaceCountSingle = (10 / aspectRatio).toInt();
      appointmentDisplayCountSingle = 2;
    }
  }
}
