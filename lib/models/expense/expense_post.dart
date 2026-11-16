// To parse this JSON data, do
//
//     final expensePostModel = expensePostModelFromJson(jsonString);

import 'dart:convert';

CommonResponse expensePostModelFromJson(String str) => CommonResponse.fromJson(json.decode(str));

String expensePostModelToJson(CommonResponse data) => json.encode(data.toJson());

class CommonResponse {
    bool status;
    String message;
    dynamic data; 

    CommonResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory CommonResponse.fromJson(Map<String, dynamic> json) {
      final rawStatus = json["status"];
      final bool parsedStatus = rawStatus == true ||
          rawStatus == 'true' ||
          rawStatus == 1 ||
          rawStatus == '1' ||
          rawStatus?.toString().toLowerCase() == 'success';
      return CommonResponse(
        status: parsedStatus,
        message: (json["message"] ?? "").toString(),
        data: json["data"],
      );
    }

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
    };
}
