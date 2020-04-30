import 'package:flutterbook/base_model.dart';

GroceriesModel groceriesModel = GroceriesModel();

class ItemDetail {
  String storeName;
  double currentPrice;

  ItemDetail({this.storeName = 'Example Store', this.currentPrice = 0.00});

  @override
  String toString() => '[storeName=$storeName, currentPrice=$currentPrice]';
}

class Grocery {
  int id;
  List<ItemDetail> details = [];

  String toString() => "{ id=$id, details=${details.join(',')} }";
}

class GroceriesModel extends BaseModel<Grocery> {
  List<ItemDetail> details = [];

  void addDetail(ItemDetail detail) {
    details.add(detail);
    notifyListeners();
  }

  void clear(){
    details.clear();
  }
}
