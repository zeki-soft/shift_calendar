import 'package:shift_calendar/model/shift_table_model.dart';
import 'package:shift_calendar/sql/common_sql.dart';
import 'package:sqlite3/sqlite3.dart';

class ShiftTableSql extends CommonSql {
  // ID生成
  static int generateId() {
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT IFNULL(MAX(id), 0) AS id FROM shift_table
        ''');
    int id = 0;
    if (resultSet.isNotEmpty) {
      Row row = resultSet.first;
      id = row['id'] + 1;
    }
    return id;
  }

  // 順番生成
  static int generateOrderNum() {
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT IFNULL(MAX(order_num), 0) AS order_num FROM shift_table
        ''');
    int orderNum = 0;
    if (resultSet.isNotEmpty) {
      Row row = resultSet.first;
      orderNum = row['order_num'] + 1;
    }
    return orderNum;
  }

  // 新規作成(追加)
  static void insert({required ShiftTableModel model}) {
    try {
      final stmt = CommonSql.db.prepare('''
          INSERT INTO shift_table (id, shift_name, show_flag, base_date, order_num) VALUES (?, ?, ?, ?, ?)
          ON CONFLICT (id) 
          DO UPDATE SET shift_name = shift_table.shift_name, show_flag = shift_table.show_flag, base_date = shift_table.base_date, order_num = shift_table.order_num;
        ''');
      stmt.execute([
        model.id,
        model.shiftName,
        model.showFlag,
        model.baseDate,
        model.orderNum,
      ]);
      stmt.dispose();
    } catch (e) {
      print(e);
    }
  }

  // 更新
  static void update({required ShiftTableModel model}) {
    final stmt = CommonSql.db.prepare('''
          UPDATE shift_table SET 
          shift_name = ?, show_flag = ?, base_date = ?, order_num = ?
          WHERE id = ?
        ''');
    stmt.execute([
      model.shiftName,
      model.showFlag,
      model.baseDate,
      model.orderNum,
      model.id,
    ]);
    stmt.dispose();
  }

  // 削除
  static void delete({required int id}) {
    final stmt = CommonSql.db.prepare('''
          DELETE FROM shift_table WHERE id = ?
        ''');
    stmt.execute([id]);
    stmt.dispose();
  }

  // 1件取得
  static ShiftTableModel? getShiftTable({required int id}) {
    final ResultSet resultSet = CommonSql.db.select('''
        SELECT id, shift_name, show_flag, base_date, order_num FROM shift_table WHERE id = ?
        ''', [id]);

    ShiftTableModel? model;
    if (resultSet.isNotEmpty) {
      Row row = resultSet.first;
      model = ShiftTableModel(
          id: row['id'],
          shiftName: row['shift_name'],
          showFlag: row['show_flag'],
          baseDate: row['base_date'],
          orderNum: row['order_num']);
    }
    return model;
  }

  // 全件取得
  static List<ShiftTableModel> getShiftTableAll() {
    try {
      final ResultSet resultSet = CommonSql.db.select('''
        SELECT id, shift_name, show_flag, base_date, order_num FROM shift_table
        ''');
      List<ShiftTableModel> list = [];
      for (Row row in resultSet) {
        ShiftTableModel model = ShiftTableModel(
            id: row['id'],
            shiftName: row['shift_name'],
            showFlag: row['show_flag'] == 1,
            baseDate: row['base_date'],
            orderNum: row['order_num']);
        list.add(model);
      }
      return list;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
