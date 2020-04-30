import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'groceries_entry.dart';
import 'groceries_list.dart';
import 'groceries_model.dart' show GroceriesModel, groceriesModel;

class Groceries extends StatelessWidget {
  Groceries() {
//    groceries_model.loadData(GroceriesDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<GroceriesModel>(
        model: groceriesModel,
        child: ScopedModelDescendant<GroceriesModel>(builder: (BuildContext context, Widget child, GroceriesModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[GroceriesList(), GroceriesEntry()],
          );
        }));
  }
}