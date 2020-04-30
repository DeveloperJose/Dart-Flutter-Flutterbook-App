import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/avatar.dart';
import 'package:scoped_model/scoped_model.dart';

import 'groceries_dbworker.dart';
import 'groceries_model.dart';

class GroceriesList extends StatelessWidget with ImageMixin {
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

  FloatingActionButton buildFloatingActionButton(GroceriesModel model) {
    return FloatingActionButton(
        child: Icon(Icons.add_shopping_cart, color: Colors.white),
        onPressed: () async {
          File avatarFile = imageTempFile();
          if (avatarFile.existsSync()) {
            avatarFile.deleteSync();
          }
          model.entityBeingEdited = Grocery();
          model.setStackIndex(1);
        });
  }

  Widget buildSlidable(BuildContext context, GroceriesModel model, Grocery item) => Slidable(
        actionPane: SlidableDrawerActionPane(),
        child: buildCard(model, item),
        secondaryActions: [IconSlideAction(caption: "Delete", color: Colors.red, icon: Icons.delete, onTap: () => _deleteGrocery(context, item)), Divider()],
      );

  Widget buildCard(GroceriesModel model, Grocery item) {
    item.sortDetailsByPrice();
    File avatarFile = File(imageFilenameFromString(item.name));
    bool avatarFileExists = avatarFile.existsSync();
    return GestureDetector(
        onTap: () => _editGrocery(model, item),
        child: Card(
            elevation: 8,
            child: Column(children: [
              CircleAvatar(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  backgroundImage: avatarFileExists ? FileImage(avatarFile) : null,
                  child: avatarFileExists ? null : Text(item.name.substring(0, 2).toUpperCase())),
              Text(item.name),
              Expanded(child: Scrollbar(child: buildListView(item))),
            ])));
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

  void _editGrocery(GroceriesModel model, Grocery grocery) async {
    File tempFile = imageTempFile();
    if (tempFile.existsSync())
      tempFile.deleteSync();

    model.entityBeingEdited = await GroceriesDBWorker.db.get(grocery.id);
    groceriesModel.setStackIndex(1);
  }

  Future _deleteGrocery(BuildContext context, Grocery grocery) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(title: Text('Delete Grocery'), content: Text('Really delete ${grocery.name}?'), actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(alertContext).pop();
              },
            ),
            FlatButton(
              child: Text('Delete'),
              onPressed: () async {
                await GroceriesDBWorker.db.delete(grocery.id);
                Navigator.of(alertContext).pop();
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                  content: Text('Grocery item deleted'),
                ));
                groceriesModel.loadData(GroceriesDBWorker.db);
              },
            )
          ]);
        });
  }
}
