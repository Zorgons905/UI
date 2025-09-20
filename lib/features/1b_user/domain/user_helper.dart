// import 'package:dokie/config/db_provider.dart';
// import 'package:dokie/features/1b_user/data/models/user.dart';

// class UserHelper {
//   static const String _tableName = 'user_preference';

//   static const String username = 'username';
//   static const String language = 'language';
//   static const String colorTheme = 'color_theme';

//   User _fromMapToTask(Map<String, Object?> e) =>
//       User(username: username, language: language, colorTheme: colorTheme);

  // Future<int> add(
  //   String taskName,
  //   String? taskDesc,
  //   String? taskAttachment,
  //   String date,
  //   String time,
  //   int? progress,
  //   int? taskGroupId,
  // ) async {
  //   final db = await DBProvider.database;
  //   return await db.insert(_tableName, {
  //     _taskName: taskName,
  //     _taskDesc: taskDesc,
  //     _taskAttachment: taskAttachment,
  //     _taskDate: date,
  //     _taskTime: time,
  //     _taskProgress: progress ?? 0,
  //     _taskGroupId: taskGroupId,
  //   });
  // }

  // // Get All Task
  // Future<List<Task>> getTask() async {
  //   final db = await DBProvider.database;
  //   final data = await db.query(_tableName);
  //   List<Task> tasks = data.map(_fromMapToTask).toList();
  //   return tasks;
  // }

  // // Get Task By Group
  // Future<List<Task>> getTasksByGroup(int? groupId) async {
  //   final db = await DBProvider.database;
  //   final data = await db.query(
  //     _tableName,
  //     where: '$_taskGroupId = ?',
  //     whereArgs: [groupId],
  //   );
  //   List<Task> tasks = data.map(_fromMapToTask).toList();
  //   return tasks;
  // }

  // Future<int> updateTask(
  //   int? id,
  //   String taskName,
  //   String? taskDesc,
  //   String? taskAttachment,
  //   String date,
  //   String time,
  //   int progress,
  // ) async {
  //   final db = await DBProvider.database;
  //   return await db.update(
  //     _tableName,
  //     {
  //       _taskName: taskName,
  //       _taskDesc: taskDesc,
  //       _taskAttachment: taskAttachment,
  //       _taskDate: date,
  //       _taskTime: time,
  //       _taskProgress: progress,
  //     },
  //     where: '$_taskId = ?',
  //     whereArgs: [id],
  //   );
  // }``

  // Future<int> deleteTask(int? id) async {
  //   final db = await DBProvider.database;
  //   return await db.delete(_tableName, where: '$_taskId = ?', whereArgs: [id]);
  // }
// }
