import 'dart:convert';

class StreamListModel {
  bool? status;
  String? message;
  List<StreamItem>? data;

  StreamListModel({this.status, this.message, this.data});

  factory StreamListModel.fromRawJson(String str) =>
      StreamListModel.fromJson(json.decode(str));

  factory StreamListModel.fromJson(Map<String, dynamic> json) => StreamListModel(
        status: json["status"] is bool ? json["status"] : true,
        message: json["message"]?.toString() ?? "",
        data: json["data"] != null
            ? List<StreamItem>.from(
                json["data"].map((x) => StreamItem.fromJson(x)))
            : [],
      );
}

class StreamItem {
  String streamName;

  StreamItem({
    required this.streamName,
  });

  factory StreamItem.fromJson(Map<String, dynamic> json) => StreamItem(
        streamName:
            json["stream_name"]?.toString() ?? json["name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "stream_name": streamName,
      };
}
