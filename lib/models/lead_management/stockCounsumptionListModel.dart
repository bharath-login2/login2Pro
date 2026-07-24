class StockConsumptionListModel {
  final bool status;
  final String message;
  final List<ConsumptionData> data;

  StockConsumptionListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StockConsumptionListModel.fromJson(Map<String, dynamic> json) {
    return StockConsumptionListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((e) => ConsumptionData.fromJson(e)).toList()
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

class ConsumptionData {
  final String consumptionId;
  final String date;
  final String requisitionNo;
  final String locationName;
  final String remarks;
  final List<ConsumptionItem> items;

  ConsumptionData({
    required this.consumptionId,
    required this.date,
    required this.requisitionNo,
    required this.locationName,
    required this.remarks,
    required this.items,
  });

  factory ConsumptionData.fromJson(Map<String, dynamic> json) {
    return ConsumptionData(
      consumptionId: json['consumption_id']?.toString() ?? '',
      date: json['date'] ?? '',
      requisitionNo: json['requisition_no'] ?? '',
      locationName: json['location_name'] ?? '',
      remarks: json['remarks'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => ConsumptionItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "consumption_id": consumptionId,
      "date": date,
      "requisition_no": requisitionNo,
      "location_name": locationName,
      "remarks": remarks,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}
class ConsumptionItem {
  final String id;
  final String materialId;
  final String materialName;
  final String unit;
  final String unitName;
  final String quantity;
  final String unitPrice;
  final String totalAmount;

  ConsumptionItem({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.unit,
    required this.unitName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  factory ConsumptionItem.fromJson(Map<String, dynamic> json) {
    return ConsumptionItem(
      id: json['id']?.toString() ?? '',
      materialId: json['material_id']?.toString() ?? '',
      materialName: json['material_name'] ?? '',
      unit: json['unit']?.toString() ?? '',
      unitName: json['unit_name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "material_id": materialId,
      "material_name": materialName,
      "unit": unit,
      "unit_name": unitName,
      "quantity": quantity,
      "unit_price": unitPrice,
      "total_amount": totalAmount,
    };
  }
}