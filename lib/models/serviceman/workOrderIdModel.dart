import 'dart:convert';

WorkOrderDetailsModel workOrderDetailsModelFromJson(String str) =>
    WorkOrderDetailsModel.fromJson(json.decode(str));

class WorkOrderDetailsModel {
  bool status;
  WorkOrderData data;
  String message;
  Map<String, dynamic>? rawJson;
  dynamic productImages;
  dynamic warrantyImages;

  WorkOrderDetailsModel({
    required this.status,
    required this.data,
    required this.message,
    this.rawJson,
    this.productImages,
    this.warrantyImages,
  });

  factory WorkOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rawData = <String, dynamic>{};
    final dynamic dataField = json["data"];
    if (dataField is Map) {
      rawData = Map<String, dynamic>.from(dataField);
    } else if (dataField is List &&
        dataField.isNotEmpty &&
        dataField.first is Map) {
      rawData = Map<String, dynamic>.from(dataField.first as Map);
    }

    final prodImgs = json["product_images"] ??
        json["product_image"] ??
        rawData["product_images"] ??
        rawData["product_image"];

    final warrImgs = json["warranty_images"] ??
        json["warranty_image"] ??
        rawData["warranty_images"] ??
        rawData["warranty_image"];

    final dynamic rawStatus = json["status"];
    final bool parsedStatus = rawStatus == true ||
        rawStatus == 1 ||
        rawStatus?.toString().trim().toLowerCase() == 'true' ||
        rawStatus?.toString().trim() == '1' ||
        rawStatus?.toString().trim().toLowerCase() == 'success';

    return WorkOrderDetailsModel(
      status: parsedStatus,
      data: WorkOrderData.fromJson(rawData),
      message: (json["message"] ?? '').toString(),
      rawJson: json,
      productImages: prodImgs,
      warrantyImages: warrImgs,
    );
  }
}

class WorkOrderData {
  String workOrderID;
  String workOrderId;
  String assignedServiceMan;
  String customerName;
  String customerType;
  String receivedTru;
  String workCategory;
  String serialNo;
  String brand;
  String workType;
  String pipelineName;
  String problemReportedByCustomer;
  String mobileNumber;
  String emailId;
  String address;
  String location;
  String jobType;
  String issueDescription;
  String preferredDateTime;
  String estimatedDatetime;
  String priority;
  String dealerName;
  String userPassword;
  String remarks;
  String accessories;
  String status;
  String createdBy;
  String companyId;
  String createdAt;
  String startedAt;
  String stoppedAt;
  String startedBy;
  String stoppedBy;
  String createdByName;
  String assignedStaffName;
  List<dynamic> addProducts;
  String customerNameActual;
  ProductDetails productDetails;
  String serviceOption;
  String serviceCharge;
  String serviceType;
  String branchId;
  int hasInvoice;
  dynamic productImages;
  dynamic warrantyImages;
  Map<String, dynamic>? rawJson;

  WorkOrderData({
    required this.workOrderID,
    required this.workOrderId,
    required this.assignedServiceMan,
    required this.customerName,
    required this.customerType,
    required this.receivedTru,
    required this.workCategory,
    required this.serialNo,
    required this.brand,
    required this.workType,
    required this.pipelineName,
    required this.problemReportedByCustomer,
    required this.mobileNumber,
    required this.emailId,
    required this.address,
    required this.location,
    required this.jobType,
    required this.issueDescription,
    required this.preferredDateTime,
    required this.estimatedDatetime,
    required this.priority,
    required this.dealerName,
    required this.userPassword,
    required this.remarks,
    required this.accessories,
    required this.status,
    required this.createdBy,
    required this.companyId,
    required this.createdAt,
    required this.startedAt,
    required this.stoppedAt,
    required this.startedBy,
    required this.stoppedBy,
    required this.createdByName,
    required this.assignedStaffName,
    required this.addProducts,
    required this.customerNameActual,
    required this.productDetails,
    this.serviceOption = '',
    this.serviceCharge = '',
    this.serviceType = '',
    this.branchId = '',
    this.hasInvoice = 0,
    this.productImages,
    this.warrantyImages,
    this.rawJson,
  });

  static String _asString(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    if (val is List || val is Map) return jsonEncode(val);
    return val.toString();
  }

  factory WorkOrderData.fromJson(Map<String, dynamic> json) => WorkOrderData(
        workOrderID: _asString(json["WorkOrderID"]),
        workOrderId: _asString(json["work_order_id"]),
        assignedServiceMan: _asString(json["assigned_service_man"]),
        customerName: _asString(json["customer_name"]),
        customerType: _asString(json["customer_type"]),
        receivedTru: _asString(json["received_tru"]),
        workCategory: _asString(json["work_category"]),
        serialNo: _asString(json["serial_no"]),
        brand: _asString(json["brand"]),
        workType: _asString(json["work_type"]),
        pipelineName: _asString(json["pipeline_name"]),
        problemReportedByCustomer:
            _asString(json["problem_reported_by_customer"]),
        mobileNumber: _asString(json["MobileNumber"]),
        emailId: _asString(json["EmailID"]),
        address: _asString(json["Address"]),
        location: _asString(json["Location"]),
        jobType: _asString(json["job_type"]),
        issueDescription: _asString(json["IssueDescription"]),
        preferredDateTime: _asString(json["PreferredDateTime"]),
        estimatedDatetime: _asString(json["Estimated_datetime"]),
        priority: _asString(json["Priority"]),
        dealerName: _asString(json["dealer_name"]),
        userPassword: _asString(json["user_password"]),
        remarks: _asString(json["remarks"]),
        accessories: _asString(json["accessories"]),
        status: _asString(json["Status"]),
        createdBy: _asString(json["CreatedBy"]),
        companyId: _asString(json["company_id"]),
        createdAt: _asString(json["CreatedAt"]),
        startedAt: _asString(json["StartedAt"]),
        stoppedAt: _asString(json["StoppedAt"]),
        startedBy: _asString(json["StartedBy"]),
        stoppedBy: _asString(json["StoppedBy"]),
        createdByName: _asString(json["created_by_name"]),
        assignedStaffName: _asString(json["assigned_staff_name"]),
        addProducts: json["add_products"] is List
            ? List<dynamic>.from(json["add_products"])
            : [],
        customerNameActual: _asString(json["customer_name_actual"]),
        productDetails: json["product_details"] is Map
            ? ProductDetails.fromJson(
                Map<String, dynamic>.from(json["product_details"]))
            : ProductDetails(
                id: '', productName: '', productType: '', pipeline: []),
        serviceOption: json["service_option"]?.toString() ??
            json["editservice_option"]?.toString() ??
            '',
        serviceCharge: json["service_charge"]?.toString() ??
            json["editservice_charge"]?.toString() ??
            '',
        serviceType: json["service_type"]?.toString() ??
            json["editservice_type"]?.toString() ??
            '',
        branchId: (json["branch_id"] ?? json["branchId"] ?? '').toString(),
        hasInvoice: int.tryParse(
                (json["has_invoice"] ?? json["hasInvoice"] ?? '0')
                    .toString()) ??
            (json["has_invoice"] == true ? 1 : 0),
        productImages: json["product_images"] ??
            json["product_image"] ??
            json["productImages"] ??
            json["productImage"],
        warrantyImages: json["warranty_images"] ??
            json["warranty_image"] ??
            json["warrantyImages"] ??
            json["warrantyImage"],
        rawJson: json,
      );
}

class ProductDetails {
  String id;
  String productName;
  String productType;
  List<String> pipeline;

  ProductDetails({
    required this.id,
    required this.productName,
    required this.productType,
    required this.pipeline,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
        id: (json["id"] ?? '').toString(),
        productName: (json["product_name"] ?? '').toString(),
        productType: (json["product_type"] ?? '').toString(),
        pipeline: json["pipeline"] is List
            ? List<String>.from(
                (json["pipeline"] as List).map((x) => (x ?? '').toString()))
            : [],
      );
}
