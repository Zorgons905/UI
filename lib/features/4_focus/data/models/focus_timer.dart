class FocusTimer {
  final int? id;
  final String name;
  final int focusTime;
  final int breakTime;
  final int section;
  final String createdAt;

  FocusTimer({
    this.id,
    required this.name,
    required this.focusTime,
    required this.breakTime,
    required this.section,
    required this.createdAt,
  });

  factory FocusTimer.fromMap(Map<String, dynamic> map) {
    return FocusTimer(
      id: map['id'],
      name: map['name'],
      focusTime: map['focus_time'],
      breakTime: map['break_time'],
      section: map['section'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'focus_time': focusTime,
      'break_time': breakTime,
      'section': section,
      'created_at': createdAt,
    };
  }

  String get formattedFocusTimeValue {
    if (focusTime >= 60) {
      final int hours = focusTime ~/ 60;
      final int minutes = focusTime % 60;
      if (minutes == 0) {
        return '$hours h';
      }
      return '$hours h $minutes min';
    }
    return '$focusTime min';
  }

  String get formattedBreakTimeValue {
    return '$breakTime min';
  }

  String get formattedSectionTimeValue {
    return '$section intervals';
  }
}
