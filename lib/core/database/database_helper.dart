import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/menu/domain/product_entity.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('resto_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    if (oldVersion < 2) {
      // 1. Add Stock to Products
      // SQLite doesn't support adding default value easily in one go with NOT NULL without default, 
      // but we can add nullable then update or just default 0.
      await db.execute('ALTER TABLE products ADD COLUMN stock INTEGER DEFAULT 100');

      // 2. Create Users Table
      await db.execute('''
        CREATE TABLE users (
          id $idType,
          name $textType,
          email $textType,
          password $textType,
          role $textType
        )
      ''');

      // 3. Create Tables (Restaurant Tables)
      await db.execute('''
        CREATE TABLE restaurant_tables (
          id $idType,
          number $textType,
          capacity $intType,
          status $textType,
          x $doubleType,
          y $doubleType
        )
      ''');

      // 4. Create Settings Table
      await db.execute('''
        CREATE TABLE settings (
          key $idType,
          value $textType
        )
      ''');

      await _seedUsers(db);
      await _seedRestaurantTables(db);
      await _seedSettings(db);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Products Table (v2 Schema directly)
    await db.execute('''
      CREATE TABLE products ( 
        id $idType, 
        name $textType,
        description $textType,
        price $doubleType,
        imageUrl $textType,
        category $textType,
        calories $intType,
        stock INTEGER DEFAULT 100
      )
    ''');

    // Orders Table
    await db.execute('''
      CREATE TABLE orders (
        id $idType,
        userId $textType,
        userName $textType,
        totalPrice $doubleType,
        status $textType,
        timestamp $intType
      )
    ''');

    // Order Items Table (Linked to Orders)
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId $textType,
        productId $textType,
        productName $textType,
        productPrice $doubleType,
        quantity $intType,
        note $textNullable,
        modifiers $textNullable,
        FOREIGN KEY (orderId) REFERENCES orders (id)
      )
    ''');

    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType,
        password $textType,
        role $textType
      )
    ''');

    // Restaurant Tables
    await db.execute('''
      CREATE TABLE restaurant_tables (
        id $idType,
        number $textType,
        capacity $intType,
        status $textType,
        x $doubleType,
        y $doubleType
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        key $idType,
        value $textType
      )
    ''');
    
    // Seed Table with Initial Data
    await _seedProducts(db);
    await _seedUsers(db);
    await _seedRestaurantTables(db);
    await _seedSettings(db);
  }

  Future<void> _seedUsers(Database db) async {
    final users = [
      {'id': 'u1', 'name': 'Admin Super', 'email': 'admin@resto.com', 'password': 'admin123', 'role': 'admin'},
      {'id': 'u2', 'name': 'Kasir Utama', 'email': 'cashier@resto.com', 'password': 'cashier123', 'role': 'cashier'},
      {'id': 'u3', 'name': 'Chef Juna', 'email': 'kitchen@resto.com', 'password': 'kitchen123', 'role': 'kitchen'},
      {'id': 'u4', 'name': 'Pelanggan Demo', 'email': 'user@gmail.com', 'password': 'user123', 'role': 'customer'},
    ];

    for (var u in users) {
      await db.insert('users', u, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedRestaurantTables(Database db) async {
    final tables = [
      {'id': 't1', 'number': 'T01', 'capacity': 4, 'status': 'available', 'x': 0.0, 'y': 0.0},
      {'id': 't2', 'number': 'T02', 'capacity': 2, 'status': 'occupied', 'x': 1.0, 'y': 0.0},
      {'id': 't3', 'number': 'T03', 'capacity': 6, 'status': 'reserved', 'x': 0.0, 'y': 1.0},
      {'id': 't4', 'number': 'T04', 'capacity': 4, 'status': 'available', 'x': 1.0, 'y': 1.0},
    ];

    for (var t in tables) {
      await db.insert('restaurant_tables', t, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedSettings(Database db) async {
    await db.insert('settings', {'key': 'tax_rate', 'value': '0.11'}); // 11% PPN
    await db.insert('settings', {'key': 'service_charge', 'value': '0.05'}); // 5% Service
    await db.insert('settings', {'key': 'resto_name', 'value': 'Resto Nusantara'});
  }

  Future<void> _seedProducts(Database db) async {
    final products = [
      Product(id: '1', name: 'Nasi Goreng Spesial', description: 'Nasi goreng dengan telur, ayam, dan udang.', price: 25000, imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19', category: 'makanan', calories: 450),
      Product(id: '2', name: 'Ayam Bakar Madu', description: 'Ayam bakar dengan olesan madu spesial.', price: 30000, imageUrl: 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b', category: 'makanan', calories: 380),
      Product(id: '3', name: 'Es Teh Manis', description: 'Teh manis segar dengan es batu.', price: 5000, imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc', category: 'minuman', calories: 120),
      Product(id: '4', name: 'Kopi Susu Gula Aren', description: 'Kopi susu kekinian dengan gula aren asli.', price: 18000, imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772', category: 'minuman', calories: 220),
      Product(id: '5', name: 'Sate Ayam Madura', description: 'Sate ayam dengan bumbu kacang khas Madura.', price: 22000, imageUrl: 'https://images.unsplash.com/photo-1594957640209-1cdb717b12e3', category: 'makanan', calories: 500),
      Product(id: '6', name: 'Jus Alpukat', description: 'Jus alpukat kental dengan susu coklat.', price: 15000, imageUrl: 'https://images.unsplash.com/photo-1601039641847-7857b994d704', category: 'minuman', calories: 300),
      Product(id: '7', name: 'Burger', description: 'Burger daging sapi dengan keju dan sayuran.', price: 35000, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd', category: 'makanan', calories: 600),
      Product(id: '8', name: 'Mie Goreng Jawa', description: 'Mie goreng dengan bumbu rempah jawa.', price: 20000, imageUrl: 'https://images.unsplash.com/photo-1612927601601-6608466f1202', category: 'makanan', calories: 480),
    ];

    for (var p in products) {
      await db.insert('products', p.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
