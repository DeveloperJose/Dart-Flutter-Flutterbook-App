// Author: Jose G. Perez
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'groceries_dbworker.dart';
import 'groceries_entry.dart';
import 'groceries_list.dart';
import 'groceries_model.dart' show GroceriesModel, groceriesModel;

/// The class that provides the grocery views for the main program
class Groceries extends StatelessWidget {
  Groceries() {
    groceriesModel.loadData(GroceriesDBWorker.db);
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
