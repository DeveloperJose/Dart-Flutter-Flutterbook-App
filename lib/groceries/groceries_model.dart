import 'package:flutterbook/base_model.dart';

GroceriesModel groceriesModel = GroceriesModel();

/// Represents a grocery that can be bought at any market
class Grocery {
  /// The primary ID given by the database identifying this item
  int id;

  /// The name of this grocery item
  String name;

  /// The information about this item per store
  List<ItemDetail> details = [];

  /// Sorts the item details by price in descending order
  void sortDetailsByPrice() => details.sort((item1, item2) => (item1.price - item2.price).toInt());

  /// Combines all the store names into one for database storage
  String getStoreNames() => details.map((detail) => detail.storeName).join('|');

  /// Combines all the store prices into one for database storage
  String getPrices() => details.map((detail) => detail.price).join('|');

  /// String representation of a grocery, mostly used for debugging
  String toString() => "{ id=$id, name=$name, details=${details.join(',')} }";
}

/// Represents the information a specific store has for an item
class ItemDetail {
  /// The name of the store for the item
  String storeName;

  /// The price of the item at the store
  double price;

  ItemDetail({this.storeName, this.price});

  /// String representation of item details, mostly used for debugging
  String toString() => '[storeName=$storeName, currentPrice=$price]';
}

/// The scoped model used for state management of groceries
class GroceriesModel extends BaseModel<Grocery> {
  /// The dynamically updated list of store details as they are being edited by the user
  List<ItemDetail> details = [];

  /// Adds a store detail and updates the view to reflect that
  void addDetail(ItemDetail detail) {
    details.add(detail);
    notifyListeners();
  }

  void removeDetail(int index) {
    details.removeAt(index);
    notifyListeners();
  }

  /// Tells the model to send updates and notify all listeners to rebuild their views
  void triggerRebuild() {
    notifyListeners();
  }

  /// String representation of the grocery scoped model, mostly used for debugging
  String toString() => "{ details=${details.join(',')} }";
}
