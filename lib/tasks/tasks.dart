import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'tasks_dbworker.dart';
import 'tasks_entry.dart';
import 'tasks_list.dart';
import 'tasks_model.dart' show TasksModel, tasksModel;

class Tasks extends StatelessWidget {
  Tasks() {
    tasksModel.loadData(TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(builder: (BuildContext context, Widget child, TasksModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[TasksList(), TasksEntry()],
          );
        }));
  }
}
