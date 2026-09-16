import 'dart:convert';

WorkOrderDetailsModel workOrderDetailsModelFromJson(String str) =>
    WorkOrderDetailsModel.fromJson(json.decode(str));

class WorkOrderDetailsModel {
  bool status;
  WorkOrderData data;
  String message;

  WorkOrderDetailsModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory WorkOrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      WorkOrderDetailsModel(
        status: json["status"],
        data: WorkOrderData.fromJson(json["data"]),
        message: json["message"],
      );
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
  });

  factory WorkOrderData.fromJson(Map<String, dynamic> json) => WorkOrderData(
        workOrderID: json["WorkOrderID"] ?? '',
        workOrderId: json["work_order_id"] ?? '',
        assignedServiceMan: json["assigned_service_man"] ?? '',
        customerName: json["customer_name"] ?? '',
        customerType: json["customer_type"] ?? '',
        receivedTru: json["received_tru"] ?? '',
        workCategory: json["work_category"] ?? '',
        serialNo: json["serial_no"] ?? '',
        brand: json["brand"] ?? '',
        workType: json["work_type"] ?? '',
        pipelineName: json["pipeline_name"] ?? '',
        problemReportedByCustomer: json["problem_reported_by_customer"] ?? '',
        mobileNumber: json["MobileNumber"] ?? '',
        emailId: json["EmailID"] ?? '',
        address: json["Address"] ?? '',
        location: json["Location"] ?? '',
        jobType: json["job_type"] ?? '',
        issueDescription: json["IssueDescription"] ?? '',
        preferredDateTime: json["PreferredDateTime"] ?? '',
        estimatedDatetime: json["Estimated_datetime"] ?? '',
        priority: json["Priority"] ?? '',
        dealerName: json["dealer_name"] ?? '',
        userPassword: json["user_password"] ?? '',
        remarks: json["remarks"] ?? '',
        accessories: json["accessories"] ?? '',
        status: json["Status"] ?? '',
        createdBy: json["CreatedBy"] ?? '',
        companyId: json["company_id"] ?? '',
        createdAt: json["CreatedAt"] ?? '',
        startedAt: json["StartedAt"] ?? '',
        stoppedAt: json["StoppedAt"] ?? '',
        startedBy: json["StartedBy"] ?? '',
        stoppedBy: json["StoppedBy"] ?? '',
        createdByName: json["created_by_name"] ?? '',
        assignedStaffName: json["assigned_staff_name"] ?? '',
        addProducts: json["add_products"] != null
            ? List<dynamic>.from(json["add_products"].map((x) => x))
            : [],
        customerNameActual: json["customer_name_actual"] ?? '',
        productDetails: json["product_details"] != null
            ? ProductDetails.fromJson(json["product_details"])
            : ProductDetails(id: '', productName: '', productType: '', pipeline: []),
        serviceOption: json["service_option"]?.toString() ??
            json["editservice_option"]?.toString() ??
            '',
        serviceCharge: json["service_charge"]?.toString() ??
            json["editservice_charge"]?.toString() ??
            '',
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
        id: json["id"],
        productName: json["product_name"],
        productType: json["product_type"],
        pipeline: List<String>.from(json["pipeline"].map((x) => x)),
      );
}
