class LeadWorkDetailsModel {
  final bool status;
  final String message;
  final List<WorkData> data;

  LeadWorkDetailsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadWorkDetailsModel.fromJson(Map<String, dynamic> json) {
    return LeadWorkDetailsModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((e) => WorkData.fromJson(e))
          .toList(),
    );
  }
}
class WorkData {
  final String workId;
  final String status;
  final Progress progress;
  final List<WorkTask> tasks;

  WorkData({
    required this.workId,
    required this.status,
    required this.progress,
    required this.tasks,
  });

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      workId: json["work_id"]?.toString() ?? "",
      status: json["status"] ?? "",
      progress: Progress.fromJson(json["progress"] ?? {}),
      tasks: (json["tasks"] as List? ?? [])
          .map((e) => WorkTask.fromJson(e))
          .toList(),
    );
  }
}
class Progress {
  final int percentage;
  final String text;

  Progress({
    required this.percentage,
    required this.text,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      percentage: json['percentage'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}
class WorkTask {
  String taskName;
  String? staffName;
  List<WorkDocument> documents;
  List<WorkLog> workLog;

  WorkTask({
    required this.taskName,
    this.staffName,
    required this.documents,
    required this.workLog,
  });

  factory WorkTask.fromJson(Map<String, dynamic> json) {
    return WorkTask(
      taskName: json['task_name'] ?? '',
      staffName: json['staff_name'],
      documents: (json['documents'] as List? ?? [])
          .map((e) => WorkDocument.fromJson(e))
          .toList(),
      workLog: (json['work_log'] as List? ?? [])
          .map((e) => WorkLog.fromJson(e))
          .toList(),
    );
  }
}
class WorkDocument {
  String fileId;
  String fileUrl;
  String documentName;

  WorkDocument({
    required this.fileId,
    required this.fileUrl,
    required this.documentName,
  });

  factory WorkDocument.fromJson(Map<String, dynamic> json) {
    return WorkDocument(
      fileId: json['file_id'] ?? '',
      fileUrl: json['file_url'] ?? '',
      documentName: json['document_name'] ?? '',
    );
  }
}
class LogDocument {
  String logFileId;
  String logFileUrl;

  LogDocument({
    required this.logFileId,
    required this.logFileUrl,
  });

  factory LogDocument.fromJson(Map<String, dynamic> json) {
    return LogDocument(
      logFileId: json['log_file_id'] ?? '',
      logFileUrl: json['log_file_url'] ?? '',
    );
  }
}
class WorkLog {
  String createdAt;
  String startTime;
  String endTime;
  String timeTaken;
  String remarks;
  List<LogDocument> logDocuments;

  WorkLog({
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.timeTaken,
    required this.remarks,
    required this.logDocuments,
  });

  factory WorkLog.fromJson(Map<String, dynamic> json) {
    return WorkLog(
      createdAt: json['created_at'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      timeTaken: json['time_taken'] ?? '',
      remarks: json['remarks'] ?? '',
      logDocuments: json['log_documents'] == null
          ? []
          : List<LogDocument>.from(
              json['log_documents']
                  .map((x) => LogDocument.fromJson(x)),
            ),
    );
  }
}