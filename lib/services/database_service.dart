import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sales_order.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'sales_orders';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'erp_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer TEXT NOT NULL,
            amount REAL NOT NULL,
            status TEXT NOT NULL,
            date TEXT NOT NULL,
            product TEXT,
            quantity INTEGER,
            rate REAL
          )
        ''');
      },
    );
  }

  Future<int> insertSalesOrder(SalesOrder order) async {
    final db = await database;
    return await db.insert(tableName, order.toJson());
  }

  Future<List<SalesOrder>> getSalesOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return SalesOrder.fromJson(maps[i]);
    });
  }

  Future<int> updateSalesOrder(SalesOrder order) async {
    final db = await database;
    return await db.update(
      tableName,
      order.toJson(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteSalesOrder(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
