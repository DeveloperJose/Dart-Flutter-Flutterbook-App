import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/image_mixin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:spinner_input/spinner_input.dart';

import 'groceries_dbworker.dart';
import 'groceries_model.dart';

/// The class in charge of creating and editing grocery information
class GroceriesEntry extends StatelessWidget with ImageMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<GroceriesModel>(
        model: groceriesModel,
        child: ScopedModelDescendant<GroceriesModel>(builder: (BuildContext context, Widget child, GroceriesModel model) {
          File avatarFile = imageTempFile();
          // Copy the previously filled in information when editing
          if (model.entityBeingEdited != null) {
            model.details = model.entityBeingEdited.details;

            // Load the previously selected image if it exists
            if (!avatarFile.existsSync()) avatarFile = File(imageFilenameFromString(model.entityBeingEdited.name));
          }

          // Force users to select at least one store
          if (model.details.isEmpty) model.details.add(ItemDetail());

          return Scaffold(
              bottomNavigationBar: _buildBottomNavigationBar(context, model),
              body: Form(
                  key: _formKey,
                  child: Column(children: [
                    _buildItemNameEditor(model),
                    _buildImageEditor(context, avatarFile),
                    _buildStoreList(model),
                    _buildAddStoreButton(model),
                  ])));
        }));
  }

  /// Builds the widget in charge of storing and validating the item name
  Widget _buildItemNameEditor(GroceriesModel model) => ListTile(
      leading: Icon(Icons.text_fields),
      title: TextFormField(
          controller: _buildItemNameController(model),
          decoration: InputDecoration(hintText: 'Item Name'),
          validator: (newItemName) {
            if (newItemName.isEmpty) return 'Please type an item name';
            return null;
          }));

  /// Builds the widget in charge of showing the grocery image and editing it
  Widget _buildImageEditor(BuildContext context, File avatarFile) => ListTile(
      title: avatarFile.existsSync()
          ? Image.memory(Uint8List.fromList(avatarFile.readAsBytesSync()), alignment: Alignment.center, height: 100, width: 100, fit: BoxFit.contain)
          : Text("Grocery image not chosen yet", textAlign: TextAlign.right),
      trailing: IconButton(icon: Icon(Icons.photo_library), color: Colors.blue, onPressed: () => _selectImage(context)));

  /// Builds the button to add another store and price to the item
  Widget _buildAddStoreButton(GroceriesModel model) =>
      RaisedButton(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add), Text('Add Another Store and Price')]), onPressed: () => model.addDetail(ItemDetail()));

  /// Builds the list of cards containing the stores and prices
  Widget _buildStoreList(GroceriesModel model) => Expanded(child: Scrollbar(child: ListView.builder(itemCount: model.details.length, itemBuilder: (c, idx) => _buildStoreEditCard(model, idx))));

  /// Builds an individual store card which shows the information that can be inputted per store
  Widget _buildStoreEditCard(GroceriesModel model, int index) => Card(
      elevation: 8,
      color: Colors.blue[200],
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: .2,
        secondaryActions: [IconSlideAction(caption: "Delete", color: Colors.red, icon: Icons.delete, onTap: () => model.removeDetail(index))],
        child: Column(children: [
          _buildStoreNameEditor(model, index),
          _buildStorePriceEditor(model, index),
        ]),
      ));

  /// Builds the form field that edits the name of one store
  ListTile _buildStoreNameEditor(GroceriesModel model, int index) => ListTile(
      leading: Icon(Icons.store),
      title: TextFormField(
          controller: _buildStoreNameController(model, index),
          decoration: InputDecoration(hintText: 'Store Name'),
          validator: (newStoreName) {
            if (newStoreName.isEmpty) return 'Please type a store name';
            return null;
          }));

  /// Builds the form field that edits the price of one store
  ListTile _buildStorePriceEditor(GroceriesModel model, int index) => ListTile(
        leading: Icon(Icons.attach_money),
        title: SpinnerInput(
          minValue: 0.01,
          maxValue: double.maxFinite,
          fractionDigits: 2,
          step: 1,
          plusButton: SpinnerButtonStyle(elevation: 0, color: Colors.blue, borderRadius: BorderRadius.circular(0)),
          minusButton: SpinnerButtonStyle(elevation: 0, color: Colors.red, borderRadius: BorderRadius.circular(0)),
          middleNumberWidth: 125,
          middleNumberStyle: TextStyle(fontSize: 21),
          middleNumberBackground: Colors.yellowAccent.withOpacity(0.5),
          spinnerValue: model?.details[index]?.price ?? 0,
          onChange: (newValue) {
            model.details[index].price = newValue;
            model.triggerRebuild();
          },
        ),
//      title: TextFormField(
//        controller: _buildStorePriceController(model, index),
//        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
//        decoration: InputDecoration(hintText: 'Price'),
//        validator: (newPrice) {
//          if (newPrice.isEmpty) return 'Please select a price';
//          double num = double.tryParse(newPrice);
//          if (num == null || num <= 0) return 'Please select a valid price';
//          return null;
//        },
      );

  /// Builds the controller in charge of updating the item name editing field
  TextEditingController _buildItemNameController(GroceriesModel model) {
    if (model.entityBeingEdited == null) return null;
    var controller = TextEditingController(text: model.entityBeingEdited.name);
    controller.addListener(() => model.entityBeingEdited.name = controller.text);
    return controller;
  }

  /// Builds the controller in charge of updating the store name editing field
  TextEditingController _buildStoreNameController(GroceriesModel model, int index) {
    var itemDetail = model.details[index];
    var controller = TextEditingController(text: itemDetail.storeName);
    controller.addListener(() => itemDetail.storeName = controller.text);
    return controller;
  }

  /// Builds the controller in charge of updating the store price editing field
  TextEditingController _buildStorePriceController(GroceriesModel model, int index) {
    var itemDetail = model.details[index];
    var price = itemDetail.price == null ? "" : itemDetail.price.toString();
    var controller = TextEditingController(text: price);
    controller.addListener(() => itemDetail.price = double.tryParse(controller.text));
    return controller;
  }

  /// Builds the widget at the bottom used for navigation
  Padding _buildBottomNavigationBar(BuildContext context, GroceriesModel model) =>
      Padding(padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), child: Row(children: [_buildCancelButton(context, model), Spacer(), _buildSaveButton(context, model)]));

  /// Builds the save button and performs the saving as well, checking the form for validation and updating the database
  FlatButton _buildSaveButton(BuildContext context, GroceriesModel model) => FlatButton(
        child: Text('Save'),
        onPressed: () async {
          // Check if the form is valid
          if (!_formKey.currentState.validate()) return;

          // Save to entity being edited
          groceriesModel.entityBeingEdited.details = groceriesModel.details;
          print('Being edited: ${groceriesModel.entityBeingEdited}');
          print('Model: ${groceriesModel.toString()}');

          // Database updating
          if (model.entityBeingEdited.id == null) {
            await GroceriesDBWorker.db.create(groceriesModel.entityBeingEdited);
          } else {
            await GroceriesDBWorker.db.update(groceriesModel.entityBeingEdited);
          }
          File avatarFile = imageTempFile();
          if (avatarFile.existsSync()) {
            File f = avatarFile.renameSync(imageFilenameFromString(groceriesModel.entityBeingEdited.name));
            model.triggerRebuild();
          }
          groceriesModel.loadData(GroceriesDBWorker.db);

          // Clear and go back to list
          model.details = [];
          model.setStackIndex(0);
          Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, duration: Duration(seconds: 2), content: Text('Grocery item saved!')));
        },
      );

  /// Builds the cancel button and clears the model for the next iteration
  FlatButton _buildCancelButton(BuildContext context, GroceriesModel model) => FlatButton(
        child: Text('Cancel'),
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          model.details = [];
          model.setStackIndex(0);
        },
      );

  /// Allows you to select if you want to take a picture with your camera or get it from your gallery
  Future _selectImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                GestureDetector(
                    child: ListTile(leading: Icon(Icons.camera_alt), title: Text("Take a picture", style: TextStyle(fontSize: 20))),
                    onTap: () async {
                      var cameraImage = await ImagePicker.pickImage(source: ImageSource.camera);
                      if (cameraImage != null) {
                        cameraImage.copySync(imageTempFilename());
                        groceriesModel.triggerRebuild();
                      }
                      Navigator.of(dialogContext).pop();
                    }),
                Divider(),
                GestureDetector(
                    child: ListTile(leading: Icon(Icons.photo), title: Text("Select from your gallery", style: TextStyle(fontSize: 20))),
                    onTap: () async {
                      var galleryImage = await ImagePicker.pickImage(source: ImageSource.gallery);
                      if (galleryImage != null) {
                        galleryImage.copySync(imageTempFilename());
                        imageCache.clear();
                        groceriesModel.triggerRebuild();
                      }
                      Navigator.of(dialogContext).pop();
                    }),
              ]),
            ),
          );
        });
  }
}
