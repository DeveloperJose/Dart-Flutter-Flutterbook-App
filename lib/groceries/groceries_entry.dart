import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'groceries_model.dart';

class GroceriesEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<GroceriesModel>(
        model: groceriesModel,
        child: ScopedModelDescendant<GroceriesModel>(builder: (BuildContext context, Widget child, GroceriesModel model) {
          return Scaffold(
              bottomNavigationBar: buildBottomNavigationBar(context, model),
              body: Column(children: [
                ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('Grocery image not set...'),
                    trailing: IconButton(icon: Icon(Icons.edit))),
                RaisedButton(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add), Text('Add Price')]),
                    onPressed: () => model.addDetail(ItemDetail())),
                Expanded(
                    child: Scrollbar(child: ListView.builder(
                        itemCount: model.details.length,
                        itemBuilder: (BuildContext context, int index) {
                          print('Building... index=${index}');
                          print('model ${model.details.length}');

                          return Card(elevation: 8, color: Colors.blue[200], child: Column(children: [
                            ListTile(leading: Icon(Icons.store), title: TextFormField(decoration: InputDecoration(hintText: 'Store Name'))),
                            ListTile(leading: Icon(Icons.attach_money), title: TextFormField(decoration: InputDecoration(hintText: 'Price'))),
                          ]));
                        }))),
              ]));
        }));
  }

  Padding buildBottomNavigationBar(BuildContext context, GroceriesModel model) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(children: [buildCancelButton(context, model), Spacer(), buildSaveButton()]));
  }

  FlatButton buildSaveButton() {
    return FlatButton(
      child: Text('Save'),
      onPressed: () {},
    );
  }

  FlatButton buildCancelButton(BuildContext context, GroceriesModel model) {
    return FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        model.clear();
        model.setStackIndex(0);
      },
    );
  }
}
