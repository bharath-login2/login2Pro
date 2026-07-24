class StockRequestEditDetails {
  final bool status;
  final String message;
  final StockRequestData? data;

  StockRequestEditDetails({
    required this.status,
    required this.message,
    this.data,
  });

  factory StockRequestEditDetails.fromJson(Map<String, dynamic> json) {
    return StockRequestEditDetails(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? StockRequestData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class StockRequestData {
  final String id;
  final String requestId;
  final String locationId;
  final String locationName;
  final String requiredDate;
  final String requestedDate;
  final String requestedBy;
  final String createdAt;
  final String priority;
  final String remarks;
  final String status;

  final List<StockRequestItem> items;

  StockRequestData({
    required this.id,
    required this.requestId,
    required this.locationId,
    required this.locationName,
    required this.requiredDate,
    required this.requestedDate,
    required this.requestedBy,
    required this.createdAt,
    required this.priority,
    required this.remarks,
    required this.status,
    required this.items,
  });

  factory StockRequestData.fromJson(
      Map<String, dynamic> json) {
    return StockRequestData(
      id: json['id']?.toString() ?? '',
      requestId: json['request_id'] ?? '',
      locationId:
          json['location_id']?.toString() ?? '',
      locationName: json['location_name'] ?? '',
      requiredDate: json['required_date'] ?? '',
      requestedDate: json['requested_date'] ?? '',
      requestedBy: json['requested_by'] ?? '',
      createdAt: json['created_at'] ?? '',
      priority: json['priority'] ?? 'Normal',
      remarks: json['remarks'] ?? '',
      status: json['status'] ?? 'Pending',

      items: (json['items'] as List?)
              ?.map(
                (e) => StockRequestItem.fromJson(e),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'location_id': locationId,
      'location_name': locationName,
      'required_date': requiredDate,
      'requested_by': requestedBy,
      'created_at': createdAt,
      'priority': priority,
      'status': status,
      'items': items
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
class StockRequestItem {
  final String detailId;
  final String productId;
  final String productName;
  final String quantity;
  final String remarks;
  final String purchasePrice;
  final String unitId;

  StockRequestItem({
    required this.detailId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.remarks,
    required this.purchasePrice,
    required this.unitId,
  });

  factory StockRequestItem.fromJson(
      Map<String, dynamic> json) {
    return StockRequestItem(
      detailId: json['detail_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      remarks: json['remarks'] ?? '',
      purchasePrice:
          json['purchase_price']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail_id': detailId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'remarks': remarks,
      'purchase_price': purchasePrice,
      'unit_id': unitId,
    };
  }
}