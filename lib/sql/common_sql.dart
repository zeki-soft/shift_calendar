import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class CommonSql {
  static late Database db;

  // 初期化（テーブル生成）
  static void create() {
    try {
      // DB準備
      getApplicationDocumentsDirectory().then((directory) {
        db = sqlite3.open('${directory.path}/shift_calendar.sqlite3');

        // テーブル削除
        // CommonSql.drop();

        // シフト表CREATE
        db.execute('''
          CREATE TABLE IF NOT EXISTS shift_table (
            id INTEGER NOT NULL PRIMARY KEY,
            shift_name TEXT NOT NULL,
            base_date TEXT NOT NULL,
            order_num INTEGER NOT NULL
          );
        ''');
        // シフトレコードCREATE
        db.execute('''
          CREATE TABLE IF NOT EXISTS shift_record (
            shift_table_id INTEGER NOT NULL,
            order_num INTEGER NOT NULL,
            start_time TEXT,
            end_time TEXT,
            comment TEXT,
            PRIMARY KEY (shift_table_id, order_num)
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
    db.execute('DROP TABLE shift_table;');
    db.execute('DROP TABLE shift_record;');
  }
}
