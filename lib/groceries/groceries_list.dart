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

  Widget buildCard(GroceriesModel model, Grocery item) {
    item.details.sort((item1, item2) => (item1.price - item2.price).toInt());
    return Card(
        elevation: 8,
        child: Column(children: [
          CircleAvatar(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, child: Text(item.name.substring(0, 2).toUpperCase())),
          Text(item.name),
          Expanded(child: Scrollbar(child: buildListView(item)))
        ]));
  }

  ListView buildListView(Grocery item) {
    return ListView.builder(
        itemCount: item.details.length,
        itemBuilder: (BuildContext context, int index) {
          var itemDetail = item.details[index];
          var leadingWidget = Text((index + 1).toString(), style: TextStyle(fontSize: 30), textAlign: TextAlign.center);
          var trailingWidget = (index == 0) ? Icon(Icons.star) : Text('');
          return ListTile(leading: leadingWidget, title: Text(itemDetail.storeName), subtitle: Text('\$${itemDetail.price.toStringAsFixed(2)}'), trailing: trailingWidget);
        });
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
                  child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: model.entityList.length,
                  itemBuilder: (BuildContext context, int index) => buildCard(model, model.entityList[index]),
                )),
          RaisedButton(child: Text('Renew DB'), onPressed: () => GroceriesDBWorker.db.upgradeTable())
        ]),
      );
    });
  }
}
