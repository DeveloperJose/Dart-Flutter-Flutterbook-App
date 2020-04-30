import 'package:flutterbook/base_model.dart';

GroceriesModel groceriesModel = GroceriesModel();

class ItemDetail {
  String storeName;
  double price;

  ItemDetail({this.storeName, this.price});

  @override
  String toString() => '[storeName=$storeName, currentPrice=$price]';
}

class Grocery {
  int id;

  String name;
  List<ItemDetail> details = [];

  void sortDetailsByPrice() => details.sort((item1, item2) => (item1.price - item2.price).toInt());

  String getStoreNames() => details.map((detail) => detail.storeName).join(',');

  String getPrices() => details.map((detail) => detail.price).join(', ');

  String toString() => "{ id=$id, name=$name, details=${details.join(',')} }";
}

class GroceriesModel extends BaseModel<Grocery> {
  List<ItemDetail> details = [];

  void addDetail(ItemDetail detail) {
    details.add(detail);
    notifyListeners();
  }

  void triggerRebuild() {
    notifyListeners();
  }

  String toString() => "{ details=${details.join(',')} }";
}
