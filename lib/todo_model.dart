
//import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 1)
class TodoModel{
  @HiveField(0)
  late final String title;

  @HiveField(1)
  late final String detail;

  @HiveField(2)
  late final bool isCompleted;

  TodoModel({required this.title,required this.detail,required this.isCompleted});

}