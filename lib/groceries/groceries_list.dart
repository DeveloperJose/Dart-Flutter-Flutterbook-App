import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/image_mixin.dart';
import 'package:scoped_model/scoped_model.dart';

import 'groceries_dbworker.dart';
import 'groceries_model.dart';

/// The class in charge of managing the list of groceries
class GroceriesList extends StatelessWidget with ImageMixin {
  /// Builds the FAB used to add more groceries
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

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GroceriesModel>(builder: (BuildContext context, Widget child, GroceriesModel model) {
      return Scaffold(
        floatingActionButton: buildFloatingActionButton(model),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          model.entityList.length == 0 ? Center(child: Text('No groceries added yet!', style: TextStyle(fontSize: 24), textAlign: TextAlign.center)) : _buildList(model),
          RaisedButton(child: Text('Clear All Items'), onPressed: () => GroceriesDBWorker.db.upgradeTable())
        ]),
      );
    });
  }

  /// Builds the grid listing the groceries
  Widget _buildList(GroceriesModel model) {
    return Expanded(
        child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: model.entityList.length,
      itemBuilder: (BuildContext context, int index) => _buildSlideable(context, model, model.entityList[index]),
    ));
  }

  /// Builds the slideable widget used to be able to delete the item, wraps the card
  Widget _buildSlideable(BuildContext context, GroceriesModel model, Grocery item) => Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: .2,
        child: _buildCard(model, item),
        secondaryActions: [IconSlideAction(caption: "Delete", color: Colors.red, icon: Icons.delete, onTap: () => _deleteGrocery(context, item))],
      );

  /// Builds an individual item's card
  Widget _buildCard(GroceriesModel model, Grocery item) {
    // Sort so we can show prices in order
    item.sortDetailsByPrice();
    // Attempt to load the grocery image
    File imageFile = File(imageFilenameFromString(item.name));
    bool imageFileExists = imageFile.existsSync();
    return GestureDetector(
      onTap: () => _editGrocery(model, item),
      child: Card(
        elevation: 8,
        child: Container(
          decoration: imageFileExists ? _buildImageContainer(imageFile) : null,
          child: Column(children: [
            Text(item.name, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.indigo)),
            Expanded(child: Scrollbar(child: _buildItemDetails(item))),
          ]),
        ),
      ),
    );
  }

  /// Builds the container used for the image, sets the opacity of the image to 20% as well
  BoxDecoration _buildImageContainer(File imageFile) =>
      BoxDecoration(image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.fitWidth, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop)));

  /// Builds the item details presented in the card for each grocery
  ListView _buildItemDetails(Grocery item) {
    return ListView.builder(
        itemCount: item.details.length,
        itemBuilder: (BuildContext context, int index) {
          var itemDetail = item.details[index];
          var leadingWidget = Text((index + 1).toString(), style: TextStyle(fontSize: 30), textAlign: TextAlign.center);
          var trailingWidget = (index == 0) ? Icon(Icons.star) : Text('');
          return ListTile(leading: leadingWidget, title: Text(itemDetail.storeName), subtitle: Text('\$${itemDetail.price.toStringAsFixed(2)}'), trailing: trailingWidget);
        });
  }

  /// Fetches previously filled in information and allows for grocery info editing
  void _editGrocery(GroceriesModel model, Grocery grocery) async {
    File tempFile = imageTempFile();
    if (tempFile.existsSync()) tempFile.deleteSync();

    model.entityBeingEdited = await GroceriesDBWorker.db.get(grocery.id);
    groceriesModel.setStackIndex(1);
  }

  /// Deletes a grocery from the list
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
