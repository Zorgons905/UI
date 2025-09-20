import '../data/models/task.dart';
import '../../../config/db_provider.dart';

class TaskHelper {
  static const String _tableName = 'task';

  // Insert task using Task object
  static Future<int> insertTask(Task task) async {
    final db = await DBProvider.database;
    return await db.insert(_tableName, task.toMap());
  }

  // Get all tasks with optional ordering
  static Future<List<Task>> getTasks({String? orderBy}) async {
    final db = await DBProvider.database;
    final maps = await db.query(_tableName, orderBy: orderBy);

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get task by ID
  static Future<Task?> getTaskById(int? id) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Get tasks by group ID
  static Future<List<Task>> getTasksByGroup(
    int? groupId, {
    String? orderBy,
  }) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where: 'task_group_id = ?',
      whereArgs: [groupId],
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Update task using Task object
  // Note: Triggers will automatically update task_group counts and notifications
  static Future<int> updateTask(Task task) async {
    final db = await DBProvider.database;
    return await db.update(
      _tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Update task progress only
  // Note: Progress update triggers will handle task_group counts and notifications
  static Future<int> updateTaskProgress(int? id, int progress) async {
    final db = await DBProvider.database;
    return await db.update(
      _tableName,
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete task
  // Note: CASCADE delete will remove related notifications automatically
  static Future<int> deleteTask(int? id) async {
    final db = await DBProvider.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Get tasks by progress status
  static Future<List<Task>> getTasksByProgress(
    int progress, {
    String? orderBy,
  }) async {
    final db = await DBProvider.database;
    String whereClause;

    if (progress == 0) {
      whereClause = 'progress = 0';
    } else if (progress == 100) {
      whereClause = 'progress = 100';
    } else {
      whereClause = 'progress > 0 AND progress < 100';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by date range
  static Future<List<Task>> getTasksByDateRange(
    String startDate,
    String endDate, {
    String? orderBy,
  }) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get overdue tasks (past due date and not completed)
  static Future<List<Task>> getOverdueTasks({String? orderBy}) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where:
          'datetime(date || " " || time) < datetime("now", "+7 hours") AND progress < 100',
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get today's tasks
  static Future<List<Task>> getTodayTasks({String? orderBy}) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where: 'date = date("now", "+7 hours")',
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get upcoming tasks (next 7 days)
  static Future<List<Task>> getUpcomingTasks({
    int days = 7,
    String? orderBy,
  }) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where:
          'date BETWEEN date("now", "+7 hours") AND date("now", "+7 hours", "+$days days")',
      orderBy: orderBy ?? 'date ASC, time ASC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Search tasks by name or description
  static Future<List<Task>> searchTasks(String query, {String? orderBy}) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR desc LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
}
