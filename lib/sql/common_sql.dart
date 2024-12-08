import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

class CommonSql {
  static late Database db;

  // 初期化（テーブル生成）
  static void init(Directory directory) {
    if (Platform.isWindows) {
      db = sqlite3.open('C:/Users/hatoi/Downloads/shift_calendar.sqlite3');
    } else {
      db = sqlite3.open('${directory.path}/shift_calendar.sqlite3');
    }
    // テーブル削除
    // CommonSql.drop();

    // シフト表CREATE
    db.execute('''
          CREATE TABLE IF NOT EXISTS shift_table (
            id INTEGER NOT NULL,
            shift_name TEXT,
            show_flag BOOLEAN,
            base_date TEXT,
            order_num INTEGER,
            PRIMARY KEY (id)
          );
        ''');
    // シフトレコードCREATE
    db.execute('''
          CREATE TABLE IF NOT EXISTS shift_record (
            id INTEGER NOT NULL,
            shift_table_id INTEGER NOT NULL,
            order_num INTEGER NOT NULL,
            identifier TEXT NOT NULL,
            start_time TEXT,
            end_time TEXT,
            holiday_flag BOOLEAN,
            PRIMARY KEY (id)
          );
        ''');
  }

  // テーブル削除
  static drop() {
    try {
      db.execute('DROP TABLE shift_table;');
      db.execute('DROP TABLE shift_record;');
    } catch (e) {
      print(e);
    }
  }

  // テーブル存在チェック
  static bool existTable() {
    final ResultSet resultSet =
        CommonSql.db.select('SELECT COUNT(*) FROM shift_table');
    var count = resultSet.first[0];
    if (count == 0) {
      // レコードなし(初期化)
      return false;
    } else {
      // レコードあり
      return true;
    }
  }
}
