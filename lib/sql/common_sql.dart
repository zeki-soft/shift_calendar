import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class CommonSql {
  static late Database db;

  // 初期化（テーブル生成）
  static create() {
    try {
      getApplicationDocumentsDirectory().then((directory) {
        db = sqlite3.open('${directory.path}/shift_calendar.sqlite3');
        // シフト表CREATE
        db.execute('''
    CREATE TABLE shift_table (
      id INTEGER NOT NULL PRIMARY KEY,
      shift_name TEXT NOT NULL,
      base_date TEXT NOT NULL,
      order_num INTEGER NOT NULL
    );
  ''');
        // シフトレコードCREATE
        db.execute('''
    CREATE TABLE shift_record (
      shift_table_id INTEGER NOT NULL PRIMARY KEY,
      order_num INTEGER NOT NULL PRIMARY KEY,
      start_time TEXT,
      end_time TEXT,
      comment TEXT
    );
  ''');
      });
    } catch (e) {
      // テーブル作成済みの場合
      print(e);
    }
  }

  // テーブル削除
  static drop() {
    var stmt = db.prepare('''
          DROP TABLE shift_table
        ''');
    stmt.execute();
    stmt = db.prepare('''
          DROP TABLE shift_record
        ''');
    stmt.dispose();
  }
}
