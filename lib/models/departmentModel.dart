import 'dart:convert';

class DepartmentModel {
  bool status;
  String message;
  List<DepartmentData> data;

  DepartmentModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DepartmentModel.fromRawJson(String str) =>
      DepartmentModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<DepartmentData>.from(
                json["data"].map((x) => DepartmentData.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DepartmentData {
  String id;
  String departmentName;

  DepartmentData({
    required this.id,
    required this.departmentName,
  });

  factory DepartmentData.fromRawJson(String str) =>
      DepartmentData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DepartmentData.fromJson(Map<String, dynamic> json) => DepartmentData(
        id: json["id"]?.toString() ?? "",
        departmentName: json["department_name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "department_name": departmentName,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DepartmentStaffModel {
  bool status;
  String message;
  List<DepartmentStaffData> data;

  DepartmentStaffModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DepartmentStaffModel.fromRawJson(String str) =>
      DepartmentStaffModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DepartmentStaffModel.fromJson(Map<String, dynamic> json) =>
      DepartmentStaffModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<DepartmentStaffData>.from(
                json["data"].map((x) => DepartmentStaffData.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DepartmentStaffData {
  String userId;
  String staffName;

  DepartmentStaffData({
    required this.userId,
    required this.staffName,
  });

  factory DepartmentStaffData.fromRawJson(String str) =>
      DepartmentStaffData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DepartmentStaffData.fromJson(Map<String, dynamic> json) =>
      DepartmentStaffData(
        userId: json["user_id"]?.toString() ?? "",
        staffName: json["staff_name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentStaffData &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
