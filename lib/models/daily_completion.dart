class DailyCompletion {
  final String id;
  final String userId;
  final String taskId;
  final DateTime completionDate;
  final DateTime completedAt;

  DailyCompletion({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.completionDate,
    required this.completedAt,
  });

  factory DailyCompletion.fromJson(Map<String, dynamic> json) {
    return DailyCompletion(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskId: json['task_id'] as String,
      completionDate: DateTime.parse(json['completion_date'] as String),
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'completion_date': _formatDateOnly(completionDate),
      'completed_at': completedAt.toIso8601String(),
    };
  }

  // Helper method to format date as YYYY-MM-DD for database storage
  String _formatDateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DailyCompletion copyWith({
    String? id,
    String? userId,
    String? taskId,
    DateTime? completionDate,
    DateTime? completedAt,
  }) {
    return DailyCompletion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      completionDate: completionDate ?? this.completionDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'DailyCompletion(id: $id, userId: $userId, taskId: $taskId, completionDate: $completionDate, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyCompletion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
