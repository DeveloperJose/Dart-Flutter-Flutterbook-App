import 'package:sqflite/sqflite.dart';

import 'groceries_model.dart';

/// The class in charge of all grocery database operations
class GroceriesDBWorker {
  /// The database in charge of managing grocery information
  static final GroceriesDBWorker db = GroceriesDBWorker._();

  /// The name used for this database
  static const String DB_NAME = 'groceries.db';

  /// The name used for the table of the database
  static const String TBL_NAME = 'groceries';

  /// The primary key of the database
  static const String KEY_ID = 'id';

  /// The key used to store a grocery item's name
  static const String KEY_ITEM_NAME = 'item_name';

  /// The key used to store ALL grocery store names (separated by commas)
  static const String KEY_STORE_NAMES = 'store_names';

  /// The key used to store ALL grocery store prices (separated by commas)
  static const String KEY_STORE_PRICES = 'store_prices';

  Database _db;

  GroceriesDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  /// Initializes the database
  Future<Database> _init() async {
    return await openDatabase(DB_NAME, version: 2, onOpen: (db) {}, onCreate: (Database db, int version) async {
      createTable(db);
    });
  }

  /// Creates the database table used to store the information
  Future<void> createTable(Database db) async {
    await db.execute("CREATE TABLE IF NOT EXISTS $TBL_NAME ("
        "$KEY_ID INTEGER PRIMARY KEY,"
        "$KEY_ITEM_NAME TEXT,"
        "$KEY_STORE_NAMES TEXT,"
        "$KEY_STORE_PRICES TEXT"
        ")");
  }

  /// Drops the previous version of the table and create a new one
  Future<void> upgradeTable() async {
    await _db.execute('DROP TABLE IF EXISTS $TBL_NAME');
    print('Dropped database table');
    await createTable(_db);
    print('Created new database table');
  }

  /// Inserts a grocery item into the table
  Future<int> create(Grocery grocery) async {
    Database db = await database;
    return await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_ITEM_NAME, $KEY_STORE_NAMES, $KEY_STORE_PRICES) "
        "VALUES (?, ?, ?)",
        [grocery.name, grocery.getStoreNames(), grocery.getPrices()]);
  }

  /// Deletes a grocery item from the table
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  /// Gets a grocery item from it's unique primary key ID
  Future<Grocery> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _groceryFromMap(values.first);
  }

  /// Gets all the stored grocery items in the database
  Future<List<Grocery>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _groceryFromMap(m)).toList() : [];
  }

  /// Updates the details of a grocery item already in the database
  Future<int> update(Grocery contact) async {
    Database db = await database;
    return await db.update(TBL_NAME, _groceryToMap(contact), where: "$KEY_ID = ?", whereArgs: [contact.id]);
  }

  /// Splits the strings storing the store details together into individual stores
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

  /// Loads grocery information from a database map
  Grocery _groceryFromMap(Map<String, dynamic> map) => Grocery()
    ..id = map[KEY_ID]
    ..name = map[KEY_ITEM_NAME]
    ..details = _detailsFromMap(map);

  /// Converts grocery information into a mappable format
  Map<String, dynamic> _groceryToMap(Grocery grocery) => Map<String, dynamic>()
    ..[KEY_ID] = grocery.id
    ..[KEY_ITEM_NAME] = grocery.name
    ..[KEY_STORE_NAMES] = grocery.getStoreNames()
    ..[KEY_STORE_PRICES] = grocery.getPrices();
}
