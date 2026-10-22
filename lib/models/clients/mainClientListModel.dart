// To parse this JSON data, do
//
//     final mainClientListModel = mainClientListModelFromJson(jsonString);

import 'dart:convert';

MainClientListModel mainClientListModelFromJson(String str) => MainClientListModel.fromJson(json.decode(str));

String mainClientListModelToJson(MainClientListModel data) => json.encode(data.toJson());

class MainClientListModel {
    bool status;
    String message;
    List<ClientLists> data;

    MainClientListModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory MainClientListModel.fromJson(Map<String, dynamic> json) => MainClientListModel(
        status: json["status"],
        message: json["message"],
        data: List<ClientLists>.from(json["data"].map((x) => ClientLists.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class ClientLists {
    String id;
    String clientName;
    String phoneNumber;
    String location;
    String pincode;
    String postOffice;
    String createdBy;
    String createdAt;
    String totalDue;
    String totalInvoiceCount;
    String? isNegative;

    ClientLists({
        required this.id,
        required this.clientName,
        required this.phoneNumber,
        required this.location,
        required this.pincode,
        required this.postOffice,
        required this.createdBy,
        required this.createdAt,
        required this.totalDue,
        required this.totalInvoiceCount,
        this.isNegative,
    });

    factory ClientLists.fromJson(Map<String, dynamic> json) => ClientLists(
        id: json["id"] ?? "",
        clientName: json["clientName"] ?? "",
        phoneNumber: json["phoneNumber"] ?? "",
        location: json["location"] ?? "",
        pincode: json["pincode"] ?? "",
        postOffice: json["post_office"] ?? "",
        createdBy: json["created_by"] ?? "",
        createdAt: json["created_at"] ?? "",
        totalDue: json["total_due"] ?? "",
        totalInvoiceCount: json["total_invoice_count"] ?? "",
        isNegative: json["is_negative"]?.toString() ?? "0",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "clientName": clientName,
        "phoneNumber": phoneNumber,
        "location": location,
        "pincode": pincode,
        "post_office": postOffice,
        "created_by": createdBy,
        "created_at": createdAt,
        "total_due": totalDue,
        "total_invoice_count": totalInvoiceCount,
        "is_negative": isNegative,
    };
}
