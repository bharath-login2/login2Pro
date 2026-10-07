import 'dart:convert';
import 'dart:developer';

class WorkModelPage {
  final bool? status;
  final String? message;
  final WorkData? data;

  WorkModelPage({this.status, this.message, this.data});

  factory WorkModelPage.fromJson(Map<String, dynamic> json) {
    return WorkModelPage(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? WorkData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "message": message, "data": data?.toJson()};
  }
}

class WorkData {
  final List<WorkOrder>? lists;
  final String? receiptSum;

  WorkData({this.lists, this.receiptSum});

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      lists: (json['lists'] as List<dynamic>?)
          ?.map((e) => WorkOrder.fromJson(e))
          .toList(),
      receiptSum: json['receipt_sum'] ?? "0",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lists": lists?.map((e) => e.toJson()).toList(),
      "receipt_sum": receiptSum,
    };
  }
}

class WorkOrder {
  final String? workOrderID;
  final String? workOrderId;
  final String? customerName;
  final String? custId;
  final String? customerType;
  final String? receivedTru;
  final String? workCategory;
  final String? serialNo;
  final String? brand;
  final String? workType;
  final String? problemReportedByCustomer;
  final String? mobileNumber;
  final String? emailId;
  final String? address;
  final String? location;
  final String? jobType;
  final String? issueDescription;
  final String? preferredDateTime;
  final String? estimatedDatetime;
  final String? priority;
  final String? dealerName;
  final String? userPassword;
  final String? remarks;
  final String? accessories;
  final String? status;
  final String? createdAt;
  final String? createdBy;
  final String? assignedServiceMan;
  final String? assignedStaffIds;
  final List<History>? history;
  final List<AddProduct>? addProducts; // ✅ New field added

  WorkOrder({
    this.workOrderID,
    this.workOrderId,
    this.customerName,
    this.custId,
    this.customerType,
    this.receivedTru,
    this.workCategory,
    this.serialNo,
    this.brand,
    this.workType,
    this.problemReportedByCustomer,
    this.mobileNumber,
    this.emailId,
    this.address,
    this.location,
    this.jobType,
    this.issueDescription,
    this.preferredDateTime,
    this.estimatedDatetime,
    this.priority,
    this.dealerName,
    this.userPassword,
    this.remarks,
    this.accessories,
    this.status,
    this.createdAt,
    this.createdBy,
    this.assignedServiceMan,
    this.assignedStaffIds,
    this.history,
    this.addProducts, // ✅ added here
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      workOrderID: json['WorkOrderID'] ?? "",
      workOrderId: json['work_order_id'] ?? "",
      customerName: json['customer_name'] ?? "",
      custId: json['cust_id'] ?? "",
      customerType: json['customer_type'] ?? "", 
      receivedTru: json['received_tru'] ?? "",
      workCategory: json['work_category'] ?? "",
      serialNo: json['serial_no'] ?? "",
      brand: json['brand'] ?? "",
      workType: json['work_type'] ?? "",
      problemReportedByCustomer: json['problem_reported_by_customer'] ?? "",
      mobileNumber: json['MobileNumber'] ?? "",
      emailId: json['EmailID'] ?? "",
      address: json['Address'] ?? "",
      location: json['Location'] ?? "",
      jobType: json['job_type'] ?? "",
      issueDescription: json['IssueDescription'] ?? "",
      preferredDateTime: json['PreferredDateTime'] ?? "",
      estimatedDatetime: json['Estimated_datetime'] ?? "",
      priority: json['Priority'] ?? "",
      dealerName: json['dealer_name'] ?? "",
      userPassword: json['user_password'] ?? "",
      remarks: json['remarks'] ?? "",
      accessories: json['accessories'] ?? "",
      status: json['Status'] ?? "",
      createdAt: json['CreatedAt'] ?? "",
      createdBy: json['CreatedBy'] ?? "",
      assignedServiceMan: json['assigned_service_man'] ?? "",
      assignedStaffIds: json['assigned_staff_ids'] ?? "",
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => History.fromJson(e))
          .toList(),
      addProducts:
          (json['add_products'] as List<dynamic>?) // ✅ parse add_products
              ?.map((e) => AddProduct.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "WorkOrderID": workOrderID,
      "work_order_id": workOrderId,
      "customer_name": customerName,
      "cust_id": custId,
      "customer_type": customerType,
      "received_tru": receivedTru,
      "work_category": workCategory,
      "serial_no": serialNo,
      "brand": brand,
      "work_type": workType,
      "problem_reported_by_customer": problemReportedByCustomer,
      "MobileNumber": mobileNumber,
      "EmailID": emailId,
      "Address": address,
      "Location": location,
      "job_type": jobType,
      "IssueDescription": issueDescription,
      "PreferredDateTime": preferredDateTime,
      "Estimated_datetime": estimatedDatetime,
      "Priority": priority,
      "dealer_name": dealerName,
      "user_password": userPassword,
      "remarks": remarks,
      "accessories": accessories,
      "Status": status,
      "CreatedAt": createdAt,
      "CreatedBy": createdBy,
      "assigned_service_man": assignedServiceMan,
      "assigned_staff_ids": assignedStaffIds,
      "history": history?.map((e) => e.toJson()).toList(),
      "add_products": addProducts
          ?.map((e) => e.toJson())
          .toList(), // ✅ added here
    };
  }

  /// Helper to get the latest non-empty pipeline progress from history
  List<PipelineProgress>? get effectivePipelineProgress {
    if (history != null && history!.isNotEmpty) {
      for (int i = history!.length - 1; i >= 0; i--) {
        final p = history![i].pipelineProgress;
        if (p != null && p.isNotEmpty) {
          return p;
        }
      }
    }
    return null;
  }
}

class AddProduct {
  final String? id;
  final String? workOrderId;
  final String? productId;
  final String? productName;
  final String? quantity;
  final String? consumedQty;
  final String? rate;
  final String? unitPrice;
  final String? amount;
  final String? currentStock;

  AddProduct({
    this.id,
    this.workOrderId,
    this.productId,
    this.productName,
    this.quantity,
    this.consumedQty,
    this.rate,
    this.unitPrice,
    this.amount,
    this.currentStock,
  });

  factory AddProduct.fromJson(Map<String, dynamic> json) {
    final qty = (json['consumed_qty'] != null && json['consumed_qty'].toString().isNotEmpty)
        ? json['consumed_qty'].toString()
        : (json['quantity']?.toString() ?? "");
    final price = (json['unit_price'] != null && json['unit_price'].toString().isNotEmpty)
        ? json['unit_price'].toString()
        : (json['rate']?.toString() ?? "");

    return AddProduct(
      id: json['id']?.toString() ?? "",
      workOrderId: json['work_order_id']?.toString() ?? "",
      productId: json['material_id']?.toString() ?? json['product_id']?.toString() ?? "",
      productName: json['product_name']?.toString() ?? "",
      quantity: qty,
      consumedQty: json['consumed_qty']?.toString() ?? qty,
      rate: price,
      unitPrice: price,
      amount: json['amount']?.toString() ?? "",
      currentStock: json['current_stock']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "work_order_id": workOrderId,
      "material_id": productId,
      "product_name": productName,
      "quantity": quantity,
      "consumed_qty": consumedQty,
      "rate": rate,
      "unit_price": unitPrice,
      "amount": amount,
      "current_stock": currentStock,
    };
  }
}

class History {
  final String? histID;
  final String? actionType;
  final String? actionTime;
  final String? valWorkOrderID;
  final String? valWorkOrderId;
  final String? valAssignedServiceMan;
  final String? valCustomerName;
  final String? valCustomerType;
  final String? valReceivedTru;
  final String? valWorkCategory;
  final String? valSerialNo;
  final String? valBrand;
  final String? valWorkType;
  final String? valProblemReportedByCustomer;
  final String? valMobileNumber;
  final String? valEmailID;
  final String? valAddress;
  final String? valLocation;
  final String? valJobType;
  final String? valIssueDescription;
  final String? valPreferredDateTime;
  final String? valEstimatedDatetime;
  final String? valPriority;
  final String? valDealerName;
  final String? valUserPassword;
  final String? valRemarks;
  final String? valAccessories;
  final String? valStatus;
  final String? valCreatedBy;
  final String? valCreatedAt;
  final List<PipelineProgress>? pipelineProgress;

  History({
    this.histID,
    this.actionType,
    this.actionTime,
    this.valWorkOrderID,
    this.valWorkOrderId,
    this.valAssignedServiceMan,
    this.valCustomerName,
    this.valCustomerType,
    this.valReceivedTru,
    this.valWorkCategory,
    this.valSerialNo,
    this.valBrand,
    this.valWorkType,
    this.valProblemReportedByCustomer,
    this.valMobileNumber,
    this.valEmailID,
    this.valAddress,
    this.valLocation,
    this.valJobType,
    this.valIssueDescription,
    this.valPreferredDateTime,
    this.valEstimatedDatetime,
    this.valPriority,
    this.valDealerName,
    this.valUserPassword,
    this.valRemarks,
    this.valAccessories,
    this.valStatus,
    this.valCreatedBy,
    this.valCreatedAt,
    this.pipelineProgress,
  });

  static List<PipelineProgress>? parsePipelineProgress(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed == "null") return null;
      try {
        final decoded = jsonDecode(trimmed);
        return parsePipelineProgress(decoded);
      } catch (e) {
        log("Error decoding pipeline progress JSON string: $e");
        return null;
      }
    }
    if (raw is List) {
      return raw
          .map((e) {
            if (e is Map<String, dynamic>) {
              return PipelineProgress.fromJson(e);
            } else if (e is Map) {
              return PipelineProgress.fromJson(Map<String, dynamic>.from(e));
            } else if (e is String && e.isNotEmpty) {
              return PipelineProgress(name: e, status: 0);
            }
            return null;
          })
          .whereType<PipelineProgress>()
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      return [PipelineProgress.fromJson(raw)];
    }
    return null;
  }

  factory History.fromJson(Map<String, dynamic> json) {
    final rawPipeline = json['pipeline_progress'] ??
        json['val_pipeline_progress'] ??
        json['pipelineProgress'] ??
        json['milestone'] ??
        json['val_milestone'] ??
        json['stoppipeline_name'] ??
        json['val_stoppipeline_name'];

    return History(
      histID: json['HistID'] ?? "",
      actionType: json['ActionType'] ?? "",
      actionTime: json['ActionTime'] ?? "",
      valWorkOrderID: json['val_WorkOrderID'] ?? "",
      valWorkOrderId: json['val_work_order_id'] ?? "",
      valAssignedServiceMan: json['val_assigned_service_man'] ?? "",
      valCustomerName: json['val_customer_name'] ?? "",
      valCustomerType: json['val_customer_type'] ?? "",
      valReceivedTru: json['val_received_tru'] ?? "",
      valWorkCategory: json['val_work_category'] ?? "",
      valSerialNo: json['val_serial_no'] ?? "",
      valBrand: json['val_brand'] ?? "",
      valWorkType: json['val_work_type'] ?? "",
      valProblemReportedByCustomer:
          json['val_problem_reported_by_customer'] ?? "",
      valMobileNumber: json['val_MobileNumber'] ?? "",
      valEmailID: json['val_EmailID'] ?? "",
      valAddress: json['val_Address'] ?? "",
      valLocation: json['val_Location'] ?? "",
      valJobType: json['val_job_type'] ?? "",
      valIssueDescription: json['val_IssueDescription'] ?? "",
      valPreferredDateTime: json['val_PreferredDateTime'] ?? "",
      valEstimatedDatetime: json['val_Estimated_datetime'] ?? "",
      valPriority: json['val_Priority'] ?? "",
      valDealerName: json['val_dealer_name'] ?? "",
      valUserPassword: json['val_user_password'] ?? "",
      valRemarks: json['val_remarks'] ?? "",
      valAccessories: json['val_accessories'] ?? "",
      valStatus: json['val_Status'] ?? "",
      valCreatedBy: json['val_CreatedBy'] ?? "",
      valCreatedAt: json['val_CreatedAt'] ?? "",
      pipelineProgress: parsePipelineProgress(rawPipeline),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "HistID": histID,
      "ActionType": actionType,
      "ActionTime": actionTime,
      "val_WorkOrderID": valWorkOrderID,
      "val_work_order_id": valWorkOrderId,
      "val_assigned_service_man": valAssignedServiceMan,
      "val_customer_name": valCustomerName,
      "val_customer_type": valCustomerType,
      "val_received_tru": valReceivedTru,
      "val_work_category": valWorkCategory,
      "val_serial_no": valSerialNo,
      "val_brand": valBrand,
      "val_work_type": valWorkType,
      "val_problem_reported_by_customer": valProblemReportedByCustomer,
      "val_MobileNumber": valMobileNumber,
      "val_EmailID": valEmailID,
      "val_Address": valAddress,
      "val_Location": valLocation,
      "val_job_type": valJobType,
      "val_IssueDescription": valIssueDescription,
      "val_PreferredDateTime": valPreferredDateTime,
      "val_Estimated_datetime": valEstimatedDatetime,
      "val_Priority": valPriority,
      "val_dealer_name": valDealerName,
      "val_user_password": valUserPassword,
      "val_remarks": valRemarks,
      "val_accessories": valAccessories,
      "val_Status": valStatus,
      "val_CreatedBy": valCreatedBy,
      "val_CreatedAt": valCreatedAt,
      "pipeline_progress": pipelineProgress?.map((e) => e.toJson()).toList(),
    };
  }
}

class PipelineProgress {
  final String? name;
  final int? status;

  PipelineProgress({this.name, this.status});

  factory PipelineProgress.fromJson(Map<String, dynamic> json) {
    return PipelineProgress(
      name: (json['name'] ?? json['pipeline_name'] ?? json['milestone_name'] ?? json['title'] ?? '').toString(),
      status: int.tryParse((json['status'] ?? json['val_status'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "status": status};
  }
}
