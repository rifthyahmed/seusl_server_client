import 'dart:async';

import 'package:api_con/conf.dart';
import 'package:api_con/page/dialogs.dart';

import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';

class SQLDemo extends StatefulWidget {
  SQLDemo({Key key}) : super(key: key);

  @override
  _SQLDemoState createState() => _SQLDemoState();
}

class _SQLDemoState extends State<SQLDemo> {
  List<Map<String, dynamic>> products = [];
  StreamSubscription _changefeed;

  SqlSelectBloc bloc;

  @override
  void initState() {
    this.bloc = SqlSelectBloc(
        database: db, table: "product", orderBy: 'name ASC', reactive: true);
    // listen for changes in the database
    _changefeed = db.changefeed.listen((change) {
      print("CHANGE IN THE DATABASE:");
      print("Change type: ${change.type}");
      print("Number of items impacted: ${change.value}");
      print("Query: ${change.query}");
      if (change.type == DatabaseChange.insert) {}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            children: [
              FlatButton(
                  onPressed: () => insertItemDialog(context),
                  color: Colors.teal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_view),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("Insert Data"),
                      )
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: StreamBuilder<List<DbRow>>(
                    stream: bloc.rows,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<DbRow>> snapshot) {
                      if (snapshot.hasData) {
                        // the select query has not found anything
                        if (snapshot.data.isEmpty) {
                          return const Center(
                            child: Text(
                                "No data. Use the + button to insert an item"),
                          );
                        }
                        // the select query has results
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final row = snapshot.data[index];
                              final name = row.record<String>("name");
                              final id = row.record<int>("id");
                              return ListTile(
                                title: GestureDetector(
                                  child: Text(name),
                                  onTap: () => null,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.grey,
                                  onPressed: () =>
                                      deleteItemDialog(context, name, id),
                                ),
                              );
                            });
                      } else {
                        // the select query is still running
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _changefeed.cancel();
    super.dispose();
  }
}
