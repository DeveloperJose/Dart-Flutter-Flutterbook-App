import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'contacts_dbworker.dart';
import 'contacts_entry.dart';
import 'contacts_list.dart';
import 'contacts_model.dart' show ContactsModel, contactsModel;

class Contacts extends StatelessWidget {
  Contacts() {
    contactsModel.loadData(ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(builder: (BuildContext context, Widget child, ContactsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[ContactsList(), ContactsEntry()],
          );
        }));
  }
}
