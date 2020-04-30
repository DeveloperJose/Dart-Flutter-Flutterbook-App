import 'package:sqflite/sqflite.dart';

import 'groceries_model.dart';

class GroceriesDBWorker {
  static final GroceriesDBWorker db = GroceriesDBWorker._();

  static const String DB_NAME = 'groceries.db';
  static const String TBL_NAME = 'groceries';
  static const String KEY_ID = 'id';
  static const String KEY_ITEM_NAME = 'item_name';
  static const String KEY_STORE_NAMES = 'store_names';
  static const String KEY_STORE_PRICES = 'store_prices';

  Database _db;

  GroceriesDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(DB_NAME, version: 2, onOpen: (db) {}, onCreate: (Database db, int version) async {
      createTable(db);
    });
  }

  Future<void> createTable(Database db) async {
    await db.execute("CREATE TABLE IF NOT EXISTS $TBL_NAME ("
        "$KEY_ID INTEGER PRIMARY KEY,"
        "$KEY_ITEM_NAME TEXT,"
        "$KEY_STORE_NAMES TEXT,"
        "$KEY_STORE_PRICES TEXT"
        ")");
  }

  Future<void> upgradeTable() async {
    await _db.execute('DROP TABLE IF EXISTS $TBL_NAME');
    print('Dropped database table');
    await createTable(_db);
    print('Created new database table');
  }

  Future<int> create(Grocery grocery) async {
    Database db = await database;
    return await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_ITEM_NAME, $KEY_STORE_NAMES, $KEY_STORE_PRICES) "
        "VALUES (?, ?, ?)",
        [grocery.name, grocery.getStoreNames(), grocery.getPrices()]);
  }

  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  Future<Grocery> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _groceryFromMap(values.first);
  }

  Future<List<Grocery>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _groceryFromMap(m)).toList() : [];
  }

  Future<int> update(Grocery contact) async {
    Database db = await database;
    return await db.update(TBL_NAME, _groceryToMap(contact), where: "$KEY_ID = ?", whereArgs: [contact.id]);
  }

  List<ItemDetail> _detailsFromMap(Map<String, dynamic> map) {
    // Attempt to load the details
    String storeNames = map[KEY_STORE_NAMES];
    String storePrices = map[KEY_STORE_PRICES];

    if (storeNames.isEmpty || storePrices.isEmpty) return [];

    List<String> nameSplit = storeNames.split(',');
    List<String> priceSplit = storePrices.split(',');

    List<ItemDetail> itemDetails = [];
    for (int i = 0; i < nameSplit.length; i++) {
      String name = nameSplit[i];
      double num = double.tryParse(priceSplit[i]);
      itemDetails.add(ItemDetail(storeName: name ?? 'Invalid DB Entry', price: num ?? -1));
    }
    return itemDetails;
  }

  Grocery _groceryFromMap(Map<String, dynamic> map) => Grocery()
    ..id = map[KEY_ID]
    ..name = map[KEY_ITEM_NAME]
    ..details = _detailsFromMap(map);

  Map<String, dynamic> _groceryToMap(Grocery grocery) => Map<String, dynamic>()
    ..[KEY_ID] = grocery.id
    ..[KEY_ITEM_NAME] = grocery.name
    ..[KEY_STORE_NAMES] = grocery.getStoreNames()
    ..[KEY_STORE_PRICES] = grocery.getPrices();
}
