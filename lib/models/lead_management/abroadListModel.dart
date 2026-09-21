import 'dart:convert';

class AbroadListModel {
  bool? status;
  String? message;
  List<AbroadItem>? data;

  AbroadListModel({this.status, this.message, this.data});

  factory AbroadListModel.fromRawJson(String str) =>
      AbroadListModel.fromJson(json.decode(str));

  factory AbroadListModel.fromJson(Map<String, dynamic> json) =>
      AbroadListModel(
        status: json["status"] is bool ? json["status"] : true,
        message: json["message"]?.toString() ?? "",
        data: json["data"] != null
            ? List<AbroadItem>.from(
                json["data"].map((x) => AbroadItem.fromJson(x)))
            : [],
      );
}

class AbroadItem {
  String placeId;
  String placeName;

  AbroadItem({
    required this.placeId,
    required this.placeName,
  });

  factory AbroadItem.fromJson(Map<String, dynamic> json) => AbroadItem(
        placeId: json["place_id"]?.toString() ?? json["id"]?.toString() ?? "",
        placeName:
            json["place_name"]?.toString() ?? json["name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "place_name": placeName,
      };
}
