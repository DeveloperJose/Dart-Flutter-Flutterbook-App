import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'groceries_dbworker.dart';
import 'groceries_model.dart';

class GroceriesEntry extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<GroceriesModel>(
        model: groceriesModel,
        child: ScopedModelDescendant<GroceriesModel>(builder: (BuildContext context, Widget child, GroceriesModel model) {
          return Scaffold(
              bottomNavigationBar: buildBottomNavigationBar(context, model),
              body: Form(
                  key: _formKey,
                  child: Column(children: [
                    buildItemNameListTile(model),
                    buildImageListTile(),
                    buildAddPriceButton(model),
                    buildPriceList(model),
                  ])));
        }));
  }

  ListTile buildItemNameListTile(GroceriesModel model) => ListTile(
      leading: Icon(Icons.text_fields),
      title: TextFormField(
        controller: buildItemNameController(model),
        decoration: InputDecoration(hintText: 'Item Name'),
        validator: (newItemName) {
          if (newItemName.isEmpty) return 'Please type an item name';
          return null;
        },
      ));

  ListTile buildImageListTile() => ListTile(leading: Icon(Icons.photo), title: Text('Grocery image not set...'), trailing: IconButton(icon: Icon(Icons.edit)));

  RaisedButton buildAddPriceButton(GroceriesModel model) =>
      RaisedButton(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add), Text('Add Price')]), onPressed: () => model.addDetail(ItemDetail()));

  Expanded buildPriceList(GroceriesModel model) =>
      Expanded(child: Scrollbar(child: ListView.builder(itemCount: model.details.length, itemBuilder: (BuildContext context, int index) => buildPriceCard(model, index))));

  Card buildPriceCard(GroceriesModel model, int index) => Card(
      elevation: 8,
      color: Colors.blue[200],
      child: Column(children: [
        ListTile(
            leading: Icon(Icons.store),
            title: TextFormField(
                controller: buildStoreNameController(model, index),
                decoration: InputDecoration(hintText: 'Store Name'),
                validator: (newStoreName) {
                  if (newStoreName.isEmpty) return 'Please type a store name';
                  return null;
                })),
        ListTile(
            leading: Icon(Icons.attach_money),
            title: TextFormField(
              controller: buildStorePriceController(model, index),
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              decoration: InputDecoration(hintText: 'Price'),
              validator: (newPrice) {
                if (newPrice.isEmpty) return 'Please select a price';
                double num = double.tryParse(newPrice);
                if (num == null || num <= 0) return 'Please select a valid price';
                return null;
              },
            )),
      ]));

  TextEditingController buildItemNameController(GroceriesModel model) {
    if (model.entityBeingEdited == null) return null;
    var controller = TextEditingController(text: model.entityBeingEdited.name);
    controller.addListener(() => model.entityBeingEdited.name = controller.text);
    return controller;
  }

  TextEditingController buildStoreNameController(GroceriesModel model, int index) {
    var itemDetail = model.details[index];
    var controller = TextEditingController(text: itemDetail.storeName);
    controller.addListener(() => itemDetail.storeName = controller.text);
    return controller;
  }

  TextEditingController buildStorePriceController(GroceriesModel model, int index) {
    var itemDetail = model.details[index];
    var controller = TextEditingController(text: itemDetail.price ?? "");
    controller.addListener(() => itemDetail.price = double.tryParse(controller.text));
    return controller;
  }

  Padding buildBottomNavigationBar(BuildContext context, GroceriesModel model) =>
      Padding(padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), child: Row(children: [buildCancelButton(context, model), Spacer(), buildSaveButton(context, model)]));

  FlatButton buildSaveButton(BuildContext context, GroceriesModel model) => FlatButton(
        child: Text('Save'),
        onPressed: () async {
          // Check if the form is valid
          if (!_formKey.currentState.validate()) return;

          // Save to entity being edited
          groceriesModel.entityBeingEdited.details = groceriesModel.details;
          print('Being edited: ${groceriesModel.entityBeingEdited}');
          print('Model: ${groceriesModel.toString()}');

          // Database updating
          int id = 0;
          if (model.entityBeingEdited.id == null) {
            id = await GroceriesDBWorker.db.create(groceriesModel.entityBeingEdited);
          } else {
            id = await GroceriesDBWorker.db.update(groceriesModel.entityBeingEdited);
          }
          groceriesModel.loadData(GroceriesDBWorker.db);
          // Clear and go back to list
          model.clear();
          model.setStackIndex(0);
          Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, duration: Duration(seconds: 2), content: Text('Grocery item saved!')));
        },
      );

  FlatButton buildCancelButton(BuildContext context, GroceriesModel model) => FlatButton(
        child: Text('Cancel'),
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          model.clear();
          model.setStackIndex(0);
        },
      );
}
