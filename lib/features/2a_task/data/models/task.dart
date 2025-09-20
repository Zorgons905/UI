class Task {
  final int? id;
  final String taskName;
  final String? taskDesc;
  final String? taskAttachment;
  final String date;
  final String time;
  final int progress;
  final int taskGroupId;

  Task({
    this.id,
    required this.taskName,
    this.taskDesc,
    this.taskAttachment,
    required this.date,
    required this.time,
    required this.taskGroupId,
    this.progress = 0,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      taskName: map['task_name'],
      taskDesc: map['task_desc'],
      taskAttachment: map['task_attachment'],
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      progress: map['progress'] ?? 0,
      taskGroupId: map['task_group_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_name': taskName,
      'task_desc': taskDesc,
      'task_attachment': taskAttachment,
      'date': date,
      'time': time,
      'progress': progress,
      'task_group_id': taskGroupId,
    };
  }
}
