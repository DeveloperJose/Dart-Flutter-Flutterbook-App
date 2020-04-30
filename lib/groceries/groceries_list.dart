import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'groceries_dbworker.dart';
import 'groceries_model.dart';

class GroceriesList extends StatelessWidget {
  FloatingActionButton buildFloatingActionButton(GroceriesModel model) {
    return FloatingActionButton(
        child: Icon(Icons.add_shopping_cart, color: Colors.white),
        onPressed: () {
          model.entityBeingEdited = Grocery();
          model.setStackIndex(1);
        });
  }

  Widget buildItem(Grocery item) {
    return Card(
      child: Text(item.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GroceriesModel>(builder: (BuildContext context, Widget child, GroceriesModel model) {
      return Scaffold(
        floatingActionButton: buildFloatingActionButton(model),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          model.entityList.length == 0
              ? Center(child: Text('No groceries added yet!', style: TextStyle(fontSize: 24), textAlign: TextAlign.center))
              : Expanded(
                  child: ListView.builder(
                  itemCount: model.entityList.length,
                  itemBuilder: (BuildContext context, int index) => buildItem(model.entityList[index]),
                )),
          // Debugging database button
          RaisedButton(child: Text('Renew DB'), onPressed: () => GroceriesDBWorker.db.upgradeTable())
        ]),
      );
    });
  }
}
