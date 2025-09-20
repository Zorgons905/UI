import '../../../config/db_provider.dart';
import '../data/models/task_group.dart';

class TaskGroupHelper {
  static const String _tableName = 'task_group';

  static Future<int> insertTaskGroup(TaskGroup taskGroup) async {
    final db = await DBProvider.database;
    return await db.insert(_tableName, taskGroup.toMap());
  }

  static Future<List<TaskGroup>> getTaskGroups({String? orderBy}) async {
    final db = await DBProvider.database;
    final maps = await db.query(_tableName, orderBy: orderBy);

    return List.generate(maps.length, (i) => TaskGroup.fromMap(maps[i]));
  }

  static Future<TaskGroup?> getTaskGroupById(int? id) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return TaskGroup.fromMap(maps.first);
    } else {
      return null;
    }
  }

  static Future<int> updateTaskGroup(TaskGroup taskGroup) async {
    final db = await DBProvider.database;
    return await db.update(
      _tableName,
      taskGroup.toMap(),
      where: 'id = ?',
      whereArgs: [taskGroup.id],
    );
  }

  static Future<int> deleteTaskGroup(int? id) async {
    final db = await DBProvider.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
