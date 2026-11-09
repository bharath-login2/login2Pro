class RunningTasksResponse {
  final bool status;
  final String message;
  final List<RunningTask> data;

  RunningTasksResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RunningTasksResponse.fromJson(Map<String, dynamic> json) {
    return RunningTasksResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => RunningTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class RunningTask {
  final String id;
  final String taskId;
  final String projectId;
  final String projectName;
  final String title;
  final String taskName;
  final String? priority;
  final String? priorityName;
  final String status;
  final DateTime? dueDate;
  final DateTime? endTime;
  final String assignedTo;
  final String assignedToName;
  final String assignedFrom;
  final String assignedFromName;
  final DateTime? createdAt;
  final String? totalDuration;

  RunningTask({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.taskName,
    this.priority,
    this.priorityName,
    required this.status,
    this.dueDate,
    this.endTime,
    required this.assignedTo,
    required this.assignedToName,
    required this.assignedFrom,
    required this.assignedFromName,
    this.createdAt,
    this.totalDuration,
  });

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  factory RunningTask.fromJson(Map<String, dynamic> json) {
    return RunningTask(
      id: json['id']?.toString() ?? '',
      taskId: json['task_id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      projectName: (json['project_name'] ?? '').toString().trim(),
      title: json['title']?.toString() ?? '',
      taskName: json['task_name']?.toString() ?? '',
      priority: json['priority']?.toString(),
      priorityName: json['priority_name']?.toString(),
      status: json['status']?.toString() ?? '',
      dueDate: _parseDate(json['due_date']),
      endTime: _parseDate(json['end_time']),
      assignedTo: json['assigned_to']?.toString() ?? '',
      assignedToName: json['assigned_to_name']?.toString() ?? '',
      assignedFrom: json['assigned_from']?.toString() ?? '',
      assignedFromName: json['assigned_from_name']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      totalDuration: json['total_duration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId,
        'project_id': projectId,
        'project_name': projectName,
        'title': title,
        'task_name': taskName,
        'priority': priority,
        'priority_name': priorityName,
        'status': status,
        'due_date': dueDate?.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'assigned_to': assignedTo,
        'assigned_to_name': assignedToName,
        'assigned_from': assignedFrom,
        'assigned_from_name': assignedFromName,
        'created_at': createdAt?.toIso8601String(),
        'total_duration': totalDuration,
      };
}