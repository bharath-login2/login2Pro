import 'dart:convert';

class SchoolDistrictListModel {
  bool? status;
  String? message;
  List<SchoolDistrictItem>? data;

  SchoolDistrictListModel({this.status, this.message, this.data});

  factory SchoolDistrictListModel.fromRawJson(String str) =>
      SchoolDistrictListModel.fromJson(json.decode(str));

  factory SchoolDistrictListModel.fromJson(Map<String, dynamic> json) =>
      SchoolDistrictListModel(
        status: json["status"] is bool ? json["status"] : true,
        message: json["message"]?.toString() ?? "",
        data: json["data"] != null
            ? List<SchoolDistrictItem>.from(
                json["data"].map((x) => SchoolDistrictItem.fromJson(x)))
            : [],
      );
}

class SchoolDistrictItem {
  String districtId;
  String districtTitle;

  SchoolDistrictItem({
    required this.districtId,
    required this.districtTitle,
  });

  factory SchoolDistrictItem.fromJson(Map<String, dynamic> json) =>
      SchoolDistrictItem(
        districtId:
            json["district_id"]?.toString() ?? json["id"]?.toString() ?? "",
        districtTitle: json["district_name"]?.toString() ??
            json["district_title"]?.toString() ??
            json["name"]?.toString() ??
            json["title"]?.toString() ??
            "",
      );

  Map<String, dynamic> toJson() => {
        "district_id": districtId,
        "district_title": districtTitle,
      };
}
