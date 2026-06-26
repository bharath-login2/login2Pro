class LeadWorkDetailsModel {
  bool status;
  String message;
  List<WorkData> data;

  LeadWorkDetailsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadWorkDetailsModel.fromJson(
      Map<String, dynamic> json) {
    return LeadWorkDetailsModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => WorkData.fromJson(e))
          .toList(),
    );
  }
}
class WorkData {
  String workId;
  String status;
  Progress progress;
  List<WorkTask> tasks;
  List<WorkReport> workReport;

  WorkData({
    required this.workId,
    required this.status,
    required this.progress,
    required this.tasks,
    required this.workReport,
  });

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      workId: json['work_id']?.toString() ?? '',
      status: json['status'] ?? '',
      progress: Progress.fromJson(json['progress'] ?? {}),
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => WorkTask.fromJson(e))
          .toList(),
      workReport: (json['work_report'] as List? ?? [])
          .map((e) => WorkReport.fromJson(e))
          .toList(),
    );
  }
}
class Progress {
  int percentage;
  String text;
  String className;

  Progress({
    required this.percentage,
    required this.text,
    required this.className,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      percentage: json['percentage'] ?? 0,
      text: json['text'] ?? '',
      className: json['class'] ?? '',
    );
  }
}
class WorkTask {
  String taskName;
  String staffName;
  List<WorkDocument> documents;

  WorkTask({
    required this.taskName,
    required this.staffName,
    required this.documents,
  });

  factory WorkTask.fromJson(Map<String, dynamic> json) {
    return WorkTask(
      taskName: json['task_name'] ?? '',
      staffName: json['staff_name'] ?? '',
      documents: (json['documents'] as List? ?? [])
          .map((e) => WorkDocument.fromJson(e))
          .toList(),
    );
  }
}
class WorkReport {
  String completedDate;
  String timeTaken;
  List<WorkDocument> documents;

  WorkReport({
    required this.completedDate,
    required this.timeTaken,
    required this.documents,
  });

  factory WorkReport.fromJson(Map<String, dynamic> json) {
    return WorkReport(
      completedDate: json['completed_date'] ?? '',
      timeTaken: json['time_taken'] ?? '',
      documents: (json['documents'] as List? ?? [])
          .map((e) => WorkDocument.fromJson(e))
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