import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shift_calendar/pages/calendar_table.dart';
import 'package:shift_calendar/pages/shift_edit.dart';
import 'package:shift_calendar/pages/shift_file.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 縦向き固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(ProviderScope(child: MyApp()));
  // initializeDateFormatting('ja')
  //     .then((_) => runApp(ProviderScope(child: MyApp())));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'カレンダー'),
    Tab(text: 'シフト編集'),
    Tab(text: 'ファイル'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // タブ生成
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (BuildContext context, AsyncSnapshot<Directory> snapshot) {
          if (snapshot.hasData) {
            // DB初期化
            CommonSql.init(snapshot.data!);
            return MaterialApp(
              home: DefaultTabController(
                  length: 3,
                  child: Scaffold(
                      // ヘッダー
                      appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(50.0),
                          child: AppBar(
                            bottom: TabBar(
                              controller: _tabController,
                              tabs: myTabs,
                            ),
                          )),
                      body: TabBarView(
                        controller: _tabController,
                        children: myTabs.map((Tab tab) {
                          // タブ選択
                          final String label = tab.text!;
                          if (label == 'カレンダー') {
                            return CalendarTable();
                          } else if (label == 'シフト編集') {
                            return ShiftEdit();
                          } else {
                            return ShiftFile();
                          }
                        }).toList(),
                      ))),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale("ja"),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
