import 'dart:convert';

class SchoolListModel {
  bool? status;
  String? message;
  List<SchoolItem>? data;

  SchoolListModel({this.status, this.message, this.data});

  factory SchoolListModel.fromRawJson(String str) =>
      SchoolListModel.fromJson(json.decode(str));

  factory SchoolListModel.fromJson(Map<String, dynamic> json) =>
      SchoolListModel(
        status: json["status"] is bool ? json["status"] : true,
        message: json["message"]?.toString() ?? "",
        data: json["data"] != null
            ? List<SchoolItem>.from(
                json["data"].map((x) => SchoolItem.fromJson(x)))
            : [],
      );
}

class SchoolItem {
  String id;
  String schoolName;
  String schoolCode;
  String districtId;

  SchoolItem({
    required this.id,
    required this.schoolName,
    required this.schoolCode,
    required this.districtId,
  });

  factory SchoolItem.fromJson(Map<String, dynamic> json) => SchoolItem(
        id: json["id"]?.toString() ?? "",
        schoolName:
            json["school_name"]?.toString() ?? json["name"]?.toString() ?? "",
        schoolCode: json["school_code"]?.toString() ?? "",
        districtId: json["district_id"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "school_name": schoolName,
        "school_code": schoolCode,
        "district_id": districtId,
      };
}
