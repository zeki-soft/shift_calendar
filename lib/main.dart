import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shift_calendar/pages/calendar_table.dart';

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
  // サイドバー選択
  var _selectMenu = '';

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'カレンダー'),
    Tab(text: 'シフト管理'),
    Tab(text: '設定'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  } else {
                    return Center(
                      child: Text(
                        'This is the $label tab',
                        style: const TextStyle(fontSize: 36),
                      ),
                    );
                  }
                }).toList(),
                // サイドメニュー
                // drawer: ConstrainedBox(
                //     constraints: BoxConstraints(maxWidth: 250.0),
                //     child: Drawer(
                //       child: ListView(
                //         children: <Widget>[
                //           const SizedBox(
                //               height: 65,
                //               child: DrawerHeader(
                //                 child: Text(
                //                   '設定',
                //                   style: TextStyle(
                //                     fontSize: 20,
                //                     color: Colors.white,
                //                   ),
                //                 ),
                //                 decoration: BoxDecoration(
                //                   color: Colors.blue,
                //                 ),
                //               )),
                //           ListTile(
                //             title: const Text('追加', style: TextStyle(fontSize: 20)),
                //             onTap: () {
                //               setState(() => _selectMenu = 'AAAA Angeles, CA');
                //               Navigator.pop(context);
                //             },
                //           ),
                //           ListTile(
                //             title: const Text('Honolulu', style: TextStyle(fontSize: 20)),
                //             onTap: () {
                //               setState(() => _selectMenu = 'Honolulu, HI');
                //               Navigator.pop(context);
                //             },
                //           ),
                //           ListTile(
                //             title: const Text('Dallas', style: TextStyle(fontSize: 20)),
                //             onTap: () {
                //               setState(() => _selectMenu = 'Dallas, TX');
                //               Navigator.pop(context);
                //             },
                //           ),
                //           ListTile(
                //             title: const Text('Seattle', style: TextStyle(fontSize: 20)),
                //             onTap: () {
                //               setState(() => _selectMenu = 'Seattle, WA');
                //               Navigator.pop(context);
                //             },
                //           ),
                //           ListTile(
                //             title: const Text('Tokyo', style: TextStyle(fontSize: 20)),
                //             onTap: () {
                //               setState(() => _selectMenu = 'Tokyo, Japan');
                //               Navigator.pop(context);
                //             },
                //           ),
                //         ],
                //       ),
                //     )),
                // カレンダー表示
                // body: Center(child: TableEventsCalendar()),
              ),
            )));
  }
}
