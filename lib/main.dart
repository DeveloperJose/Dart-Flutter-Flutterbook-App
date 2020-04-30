import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'appointments/appointments.dart';
import 'contacts/avatar.dart';
import 'contacts/contacts.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';
import 'groceries/groceries.dart';

void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    Avatar.docsDir = await getApplicationDocumentsDirectory();
    runApp(FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'FlutterBook',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
            length: 5,
            child: Scaffold(
                appBar: AppBar(
                    title: Text('FlutterBook by Jose G. Perez'),
                    bottom: TabBar(tabs: [
                      Tab(icon: Icon(Icons.date_range), text: 'Appointments'),
                      Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
                      Tab(icon: Icon(Icons.note), text: 'Notes'),
                      Tab(icon: Icon(Icons.assignment_turned_in), text: 'Tasks'),
                      Tab(icon: Icon(Icons.local_grocery_store), text: 'Groceries'),
                    ])),
                body: TabBarView(children: [
                  Appointments(),
                  Contacts(),
                  Notes(),
                  Tasks(),
                  Groceries(),
                ]))));
  }
}

class Dummy extends StatelessWidget {
  final String _title;

  Dummy(this._title);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_title));
  }
}
