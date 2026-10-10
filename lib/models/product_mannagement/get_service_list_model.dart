import 'dart:convert';

GetServiceListModel getServiceListModelFromJson(String str) =>
    GetServiceListModel.fromJson(json.decode(str));

String getServiceListModelToJson(GetServiceListModel data) =>
    json.encode(data.toJson());

class GetServiceListModel {
  final bool status;
  final String message;
  final List<ServiceListItem> data;
  final int totalCount;

  GetServiceListModel({
    required this.status,
    required this.message,
    required this.data,
    required this.totalCount,
  });

  factory GetServiceListModel.fromJson(Map<String, dynamic> json) {
    bool parsedStatus = false;
    if (json["status"] is bool) {
      parsedStatus = json["status"];
    } else if (json["status"] != null) {
      parsedStatus = json["status"].toString().toLowerCase() == "true" ||
          json["status"].toString() == "1" ||
          json["status"].toString().toLowerCase() == "success";
    }

    int parsedTotalCount = 0;
    if (json["total_count"] != null) {
      parsedTotalCount = int.tryParse(json["total_count"].toString()) ?? 0;
    }

    return GetServiceListModel(
      status: parsedStatus,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null && json["data"] is List
          ? List<ServiceListItem>.from(
              (json["data"] as List).map((x) => ServiceListItem.fromJson(x)))
          : [],
      totalCount: parsedTotalCount,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "total_count": totalCount,
      };
}

class ServiceListItem {
  final String id;
  final String companyId;
  final String productId;
  final String productName;
  final String productCode;
  final String serviceDate;
  final String servicePlace;
  final String servicePlaceContact;
  final String vendorUserId;
  final String vendorName;
  final String vendorMobile;
  final String returnDate;
  final String serviceType;
  final String issues;
  final String serviceAmount;
  final String paymentStatus;
  final String totalPaidAmount;
  final String paymentDetails;
  final String createdAt;
  final String servicePlaceId;

  ServiceListItem({
    required this.id,
    required this.companyId,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.serviceDate,
    required this.servicePlace,
    required this.servicePlaceContact,
    required this.vendorUserId,
    required this.vendorName,
    required this.vendorMobile,
    required this.returnDate,
    required this.serviceType,
    required this.issues,
    required this.serviceAmount,
    required this.paymentStatus,
    required this.totalPaidAmount,
    required this.paymentDetails,
    required this.createdAt,
    required this.servicePlaceId,
  });

  factory ServiceListItem.fromJson(Map<String, dynamic> json) =>
      ServiceListItem(
        id: json["id"]?.toString() ?? "",
        companyId: json["company_id"]?.toString() ?? "",
        productId: json["product_id"]?.toString() ?? "",
        productName: json["product_name"]?.toString() ?? "",
        productCode: json["product_code"]?.toString() ?? "",
        serviceDate: json["service_date"]?.toString() ?? "",
        servicePlace: json["service_place"]?.toString() ?? "",
        servicePlaceContact: json["service_place_contact"]?.toString() ?? "",
        vendorUserId: json["vendor_user_id"]?.toString() ?? "",
        vendorName: json["vendor_name"]?.toString() ?? "",
        vendorMobile: json["vendor_mobile"]?.toString() ?? "",
        returnDate: json["return_date"]?.toString() ?? "",
        serviceType: json["service_type"]?.toString() ?? "",
        issues: json["issues"]?.toString() ?? "",
        serviceAmount: json["service_amount"]?.toString() ?? "",
        paymentStatus: json["payment_status"]?.toString() ?? "",
        totalPaidAmount: json["total_paid_amount"]?.toString() ?? "",
        paymentDetails: json["payment_details"]?.toString() ?? "",
        createdAt: json["created_at"]?.toString() ?? "",
        servicePlaceId: json["service_place_id"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "product_id": productId,
        "product_name": productName,
        "product_code": productCode,
        "service_date": serviceDate,
        "service_place": servicePlace,
        "service_place_contact": servicePlaceContact,
        "vendor_user_id": vendorUserId,
        "vendor_name": vendorName,
        "vendor_mobile": vendorMobile,
        "return_date": returnDate,
        "service_type": serviceType,
        "issues": issues,
        "service_amount": serviceAmount,
        "payment_status": paymentStatus,
        "total_paid_amount": totalPaidAmount,
        "payment_details": paymentDetails,
        "created_at": createdAt,
        "service_place_id": servicePlaceId,
      };
}
