import 'package:flutter/widgets.dart';

class Constant {
  static double deviceWidth = 0;
  static double deviceHeight = 0;
  static double aspectRatio = 0;

  static initialize(BuildContext context) {
    // 画面サイズ取得
    final Size size = MediaQuery.of(context).size;
    deviceWidth = size.height;
    deviceHeight = size.height;
    aspectRatio = deviceHeight / deviceWidth;
  }
}
