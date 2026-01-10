import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../domain/table_entity.dart';

final tableRepositoryProvider = Provider((ref) => TableRepository());

class TableRepository {
  Future<List<RestaurantTable>> getTables() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('restaurant_tables');
    return maps.map((json) => RestaurantTable.fromJson(json)).toList();
  }

  Future<void> updateTableStatus(String id, String status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'restaurant_tables',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
