import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todolist/todo_model.dart';

const todoBoxName = 'todo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // const MyHomePage({Key? key, required this.title}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum todofilter { ALL, COMPLETED, INCOMPLETED }

class _MyHomePageState extends State<MyHomePage> {
  late Box<TodoModel> todoBox;
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  todofilter filter = todofilter.ALL;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<TodoModel>(todoBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('To Do List'), actions: [
          PopupMenuButton<String>(onSelected: (value) {
            if (value.compareTo("All") == 0) {
              setState(() {
                filter = todofilter.ALL;
              });
            } else if (value.compareTo("Completed") == 0) {
              setState(() {
                filter = todofilter.COMPLETED;
              });
            } else {
              setState(() {
                filter = todofilter.INCOMPLETED;
              });
            }
          }, itemBuilder: (BuildContext context) {
            return ['All', 'Completed', 'Incompleted']
                .map((e) => PopupMenuItem(value: e, child: Text(e)))
                .toList();
          })
        ]),
        body: Dialog(
          child: ListView(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ValueListenableBuilder(
                  valueListenable: todoBox.listenable(),
                  builder: (context, Box<TodoModel> todos, child) {
                    late List<int> keys;

                    if (filter == todofilter.ALL) {
                      keys = todoBox.keys.cast<int>().toList();
                    } else if (filter == todofilter.COMPLETED) {
                      keys = todoBox.keys
                          .cast<int>()
                          .where((key) => todos.get(key)!.isCompleted)
                          .toList();
                    } else {
                      keys = todoBox.keys
                          .cast<int>()
                          .where((key) => !todos.get(key)!.isCompleted)
                          .toList();
                    }

                    return ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, index) {
                        final key = keys[index];
                        final todovalue = todos.get(key);
                        return ListTile(
                          title: Text(todovalue!.title),
                          subtitle: Text(todovalue.detail),
                          leading: Text((index + 1).toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    editwindow(todos, key);
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    todoBox.delete(key);
                                  },
                                  icon: Icon(Icons.delete)),
                              Icon(
                                Icons.check,
                                color: todovalue.isCompleted
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        todovalue.isCompleted
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  final mtodo = TodoModel(
                                                      title: todovalue.title,
                                                      detail: todovalue.detail,
                                                      isCompleted: false);
                                                  todoBox.put(key, mtodo);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                    'Mark as Incompleted'))
                                            : ElevatedButton(
                                                onPressed: () {
                                                  final mtodo = TodoModel(
                                                      title: todovalue.title,
                                                      detail: todovalue.detail,
                                                      isCompleted: true);
                                                  todoBox.put(key, mtodo);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                    'Mark as Completed'))
                                      ],
                                    ),
                                  );
                                });
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          thickness: 5,
                        );
                      },
                      itemCount: keys.length,
                      shrinkWrap: true,
                    );
                  }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(hintText: 'Title'),
                        ),
                        TextField(
                          decoration:
                              const InputDecoration(hintText: 'Details'),
                          controller: detailController,
                        ),
                        TextButton(
                          onPressed: () {
                            final title = titleController.text;
                            final detail = detailController.text;
                            final todo = TodoModel(
                                title: title,
                                detail: detail,
                                isCompleted: false);
                            todoBox.add(todo);
                            Navigator.of(context).pop();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  );
                });
          },
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  editwindow(Box<TodoModel> todos, int key) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: todos.get(key)!.title),
                ),
                TextField(
                  decoration: InputDecoration(hintText: todos.get(key)!.detail),
                  controller: detailController,
                ),
                TextButton(
                  onPressed: () {
                    final title = titleController.text;
                    final detail = detailController.text;
                    final todoedited = TodoModel(
                        title: title, detail: detail, isCompleted: false);
                    todoBox.put(key, todoedited);
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        });
  }
}
