import 'dart:convert';

class ClassListModel {
  bool? status;
  String? message;
  List<ClassItem>? data;

  ClassListModel({this.status, this.message, this.data});

  factory ClassListModel.fromRawJson(String str) =>
      ClassListModel.fromJson(json.decode(str));

  factory ClassListModel.fromJson(Map<String, dynamic> json) => ClassListModel(
        status: json["status"] is bool ? json["status"] : true,
        message: json["message"]?.toString() ?? "",
        data: json["data"] != null
            ? List<ClassItem>.from(
                json["data"].map((x) => ClassItem.fromJson(x)))
            : [],
      );
}

class ClassItem {
  String classId;
  String className;

  ClassItem({
    required this.classId,
    required this.className,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) => ClassItem(
        classId: json["class_id"]?.toString() ?? json["id"]?.toString() ?? "",
        className:
            json["class_name"]?.toString() ?? json["name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
      };
}
