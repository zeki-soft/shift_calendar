import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shift_calendar/pages/calendar_table.dart';
import 'package:shift_calendar/pages/shift_edit.dart';
import 'package:shift_calendar/pages/shift_file.dart';
import 'package:shift_calendar/sql/common_sql.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 縦向き固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  initializeDateFormatting('ja').then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'シフト表'),
    Tab(text: '編集'),
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
    CommonSql.create(); // DB初期化
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
                    if (label == 'シフト表') {
                      return CalendarTable();
                    } else if (label == '編集') {
                      return ShiftEdit();
                    } else {
                      return ShiftFile();
                    }
                  }).toList(),
                ))));
  }
}
