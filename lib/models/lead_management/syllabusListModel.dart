import 'dart:convert';

class SyllabusListModel {
  bool? status;
  String? message;
  List<SyllabusItem>? data;

  SyllabusListModel({this.status, this.message, this.data});

  factory SyllabusListModel.fromRawJson(String str) =>
      SyllabusListModel.fromJson(json.decode(str));

  factory SyllabusListModel.fromJson(Map<String, dynamic> json) => SyllabusListModel(
        status: json["status"] is bool ? json["status"] : true,
        message: json["message"]?.toString() ?? "",
        data: json["data"] != null
            ? List<SyllabusItem>.from(
                json["data"].map((x) => SyllabusItem.fromJson(x)))
            : [],
      );
}

class SyllabusItem {
  String id;
  String value;

  SyllabusItem({
    required this.id,
    required this.value,
  });

  factory SyllabusItem.fromJson(Map<String, dynamic> json) => SyllabusItem(
        id: json["id"]?.toString() ?? "",
        value: json["value"]?.toString() ?? json["name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "value": value,
      };
}
