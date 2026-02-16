import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  Future<Database> get database async {
    throw UnimplementedError(
      "SQLite is disabled. Please use ApiClient for backend communication.",
    );
  }
}
