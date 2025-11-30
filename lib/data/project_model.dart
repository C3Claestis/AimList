import 'package:hive/hive.dart';
import 'package:todolist_app/data/task_status.dart';


part 'project_model.g.dart';

@HiveType(typeId: 1)
class ProjectModel extends HiveObject {
  @HiveField(0)
  String taskGroup;

  @HiveField(1)
  String projectName;

  @HiveField(2)
  String description;

  @HiveField(3)
  String startTime;

  @HiveField(4)
  String endTime;

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  DateTime endDate;

  @HiveField(7)
  TaskStatus status;

  ProjectModel({
    required this.taskGroup,
    required this.projectName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.endDate,
    this.status = TaskStatus.todo, // default
  });
}
