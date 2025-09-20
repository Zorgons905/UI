import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static Database? _db;
  static const String _dbName = 'task_manager.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE task_group (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        created_at TEXT NOT NULL,
        not_started_count INTEGER DEFAULT 0,
        ongoing_count INTEGER DEFAULT 0,
        completed_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE task (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        desc TEXT,
        attachment TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        progress INTEGER,
        task_group_id INTEGER,
        FOREIGN KEY (task_group_id) REFERENCES task_group(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notification (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        notification_type TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        is_sent INTEGER DEFAULT 0,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preference (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        language TEXT NOT NULL,
        color_theme TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TRIGGER update_taskgroup_count_after_insert
      AFTER INSERT ON task
      BEGIN
        UPDATE task_group
        SET 
          not_started_count = not_started_count + CASE WHEN NEW.progress = 0 THEN 1 ELSE 0 END,
          ongoing_count = ongoing_count + CASE WHEN NEW.progress > 0 AND NEW.progress < 100 THEN 1 ELSE 0 END,
          completed_count = completed_count + CASE WHEN NEW.progress = 100 THEN 1 ELSE 0 END
        WHERE id = NEW.task_group_id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER update_taskgroup_count_after_update
      AFTER UPDATE OF progress ON task
      WHEN OLD.progress != NEW.progress
      BEGIN
        UPDATE task_group
        SET 
          not_started_count = not_started_count - CASE WHEN OLD.progress = 0 THEN 1 ELSE 0 END,
          ongoing_count = ongoing_count - CASE WHEN OLD.progress > 0 AND OLD.progress < 100 THEN 1 ELSE 0 END,
          completed_count = completed_count - CASE WHEN OLD.progress = 100 THEN 1 ELSE 0 END
        WHERE id = OLD.task_group_id;

        UPDATE task_group
        SET 
          not_started_count = not_started_count + CASE WHEN NEW.progress = 0 THEN 1 ELSE 0 END,
          ongoing_count = ongoing_count + CASE WHEN NEW.progress > 0 AND NEW.progress < 100 THEN 1 ELSE 0 END,
          completed_count = completed_count + CASE WHEN NEW.progress = 100 THEN 1 ELSE 0 END
        WHERE id = NEW.task_group_id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER update_taskgroup_count_after_delete
      AFTER DELETE ON task
      BEGIN
        UPDATE task_group
        SET 
          not_started_count = not_started_count - CASE WHEN OLD.progress = 0 THEN 1 ELSE 0 END,
          ongoing_count = ongoing_count - CASE WHEN OLD.progress > 0 AND OLD.progress < 100 THEN 1 ELSE 0 END,
          completed_count = completed_count - CASE WHEN OLD.progress = 100 THEN 1 ELSE 0 END
        WHERE id = OLD.task_group_id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER update_task_group_timestamp_after_task_update
      AFTER UPDATE ON task
      FOR EACH ROW
      BEGIN
          UPDATE task_group
        SET created_at = datetime('now', '+7 hours')
        WHERE id = NEW.task_group_id;
      END;
    ''');

    await db.execute('''
      CREATE TABLE focus_timer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        focus_time INTEGER NOT NULL,
        break_time INTEGER NOT NULL,
        section INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TRIGGER auto_schedule_notifications_after_task_insert
      AFTER INSERT ON task
      FOR EACH ROW
      WHEN NEW.progress < 100
      BEGIN
        -- Insert notifications for 3 days before
        INSERT INTO notification (task_id, notification_type, scheduled_time, title, body, created_at)
        SELECT NEW.id, '3_days', 
               datetime(NEW.date || ' ' || NEW.time, '-3 days'),
               'Task Reminder - 3 Days Left!',
               'Your task "' || NEW.name || '" is due in 3 days. Time to start preparing!',
               datetime('now', '+7 hours')
        WHERE datetime(NEW.date || ' ' || NEW.time, '-3 days') > datetime('now', '+7 hours');

        -- Insert notifications for 1 day before
        INSERT INTO notification (task_id, notification_type, scheduled_time, title, body, created_at)
        SELECT NEW.id, '1_day',
               datetime(NEW.date || ' ' || NEW.time, '-1 day'),
               'Task Reminder - 1 Day Left!',
               'Your task "' || NEW.name || '" is due tomorrow. Don''t forget to complete it!',
               datetime('now', '+7 hours')
        WHERE datetime(NEW.date || ' ' || NEW.time, '-1 day') > datetime('now', '+7 hours');

        -- Insert notifications for 6 hours before
        INSERT INTO notification (task_id, notification_type, scheduled_time, title, body, created_at)
        SELECT NEW.id, '6_hours',
               datetime(NEW.date || ' ' || NEW.time, '-6 hours'),
               'Task Reminder - 6 Hours Left!',
               'Your task "' || NEW.name || '" is due in 6 hours. Better get started!',
               datetime('now', '+7 hours')
        WHERE datetime(NEW.date || ' ' || NEW.time, '-6 hours') > datetime('now', '+7 hours');

        -- Insert notifications for 3 hours before
        INSERT INTO notification (task_id, notification_type, scheduled_time, title, body, created_at)
        SELECT NEW.id, '3_hours',
               datetime(NEW.date || ' ' || NEW.time, '-3 hours'),
               'Task Reminder - 3 Hours Left!',
               'Your task "' || NEW.name || '" is due in 3 hours. Time is running out!',
               datetime('now', '+7 hours')
        WHERE datetime(NEW.date || ' ' || NEW.time, '-3 hours') > datetime('now', '+7 hours');
      END;
    ''');

    // Trigger untuk cancel notifications saat task selesai
    await db.execute('''
      CREATE TRIGGER cancel_notifications_after_task_complete
      AFTER UPDATE OF progress ON task
      FOR EACH ROW
      WHEN NEW.progress = 100 AND OLD.progress < 100
      BEGIN
        DELETE FROM notification 
        WHERE task_id = NEW.id AND is_sent = 0;
      END;
    ''');
  }
}
