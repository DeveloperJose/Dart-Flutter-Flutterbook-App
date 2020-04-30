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

  String getStoreNames() => details.map((detail) => detail.storeName).join(',');

  String getPrices() => details.map((detail) => detail.price).join(', ');

  String toString() => "{ id=$id, name=$name, details=${details.join(',')} }";

  ItemDetail getBestDeal() => details.reduce((prev, next) => prev.price < next.price ? prev : next);

  List<ItemDetail> getRestWithoutBest() {
    ItemDetail bestDeal = getBestDeal();
    return details.where((elem) => elem.price != bestDeal.price).toList();
  }
}

class GroceriesModel extends BaseModel<Grocery> {
  List<ItemDetail> details = [];
  bool isExpanded = false;

  void addDetail(ItemDetail detail) {
    details.add(detail);
    notifyListeners();
  }

  void setExpanded(bool val){
    isExpanded = val;
    notifyListeners();
  }

  String toString() => "{ details=${details.join(',')} }";
}
