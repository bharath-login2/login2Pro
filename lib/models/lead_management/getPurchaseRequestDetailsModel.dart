class GetPurchaseRequestDetailsResponse {
  bool status;
  String message;
  List<PurchaseRequestDetail> data;

  GetPurchaseRequestDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetPurchaseRequestDetailsResponse.fromJson(Map<String, dynamic> json) {
    return GetPurchaseRequestDetailsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<PurchaseRequestDetail>.from(
              json['data'].map((item) => PurchaseRequestDetail.fromJson(item)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseRequestDetail {
  String pmrId;
  String requestId;
  String requestedBy;
  String requestDate;
  String approvedBy;
  String requestStatus;
  String orderStatus;
  String materialId;
  String materialName;
  String unitId;
  String unitName;
  String quantity;
  String unitPrice;
  String totalAmount;
  String description;
  String remarks;
String purchaseRequestId;
String alreadyOrderedQty;
String remainingQty;
String amount;
String taxPercent;
String taxAmount;
  PurchaseRequestDetail({
    required this.pmrId,
    required this.requestId,
    required this.requestedBy,
    required this.requestDate,
    required this.approvedBy,
    required this.requestStatus,
    required this.orderStatus,
    required this.materialId,
    required this.materialName,
    required this.unitId,
    required this.unitName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.description,
    required this.remarks,
    required this.purchaseRequestId,
required this.alreadyOrderedQty,
required this.remainingQty,
required this.amount,
required this.taxPercent,
required this.taxAmount,
  });

  factory PurchaseRequestDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestDetail(
      pmrId: json['pmr_id']?.toString() ?? '',
      requestId: json['request_id'] ?? '',
      requestedBy: json['requested_by'] ?? '',
      requestDate: json['request_date'] ?? '',
      approvedBy: json['approved_by'] ?? '',
      requestStatus: json['request_status'] ?? '',
      orderStatus: json['order_status'] ?? '',
      materialId: json['material_id']?.toString() ?? '',
      materialName: json['material_name'] ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      unitName: json['unit_name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
      description: json['description'] ?? '',
      remarks: json['remarks'] ?? '',
      purchaseRequestId:
    json['purchase_request_id']?.toString() ?? '',

alreadyOrderedQty:
    json['already_ordered_qty']?.toString() ?? '',

remainingQty:
    json['remaining_qty']?.toString() ?? '',

amount:
    json['amount']?.toString() ?? '',

taxPercent:
    json['tax_percent']?.toString() ?? '',

taxAmount:
    json['tax_amount']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pmr_id': pmrId,
      'request_id': requestId,
      'requested_by': requestedBy,
      'request_date': requestDate,
      'approved_by': approvedBy,
      'request_status': requestStatus,
      'order_status': orderStatus,
      'material_id': materialId,
      'material_name': materialName,
      'unit_id': unitId,
      'unit_name': unitName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'description': description,
      'remarks': remarks,
    };
  }

}