class MaterialListModel {
  final bool? status;
  final List<MaterialData>? data;
  final String? message;

  MaterialListModel({this.status, this.data, this.message});

  factory MaterialListModel.fromJson(Map<String, dynamic> json) {
    return MaterialListModel(
      status: json['status'],
      data: json['data'] != null
          ? List<MaterialData>.from(
              json['data'].map((x) => MaterialData.fromJson(x)),
            )
          : [],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data?.map((x) => x.toJson()).toList(),
    'message': message,
  };
}

class MaterialData {
  final String? materialId;
  final String? materialName;
  final String? productType;
   final String? taxPercentage;
    final String? discountPercentage;
  final String? unitName;
  final String? unitPrice;
   final String? lastPurchasePrice;
  final String? currentStock;
final String? gstPercentage;
final String? purchasePrice;
final String? description;

  MaterialData({
    this.materialId,
    this.materialName,
    this.productType,
    this.taxPercentage,
    this.discountPercentage,
    this.unitName,
    this.unitPrice,
    this.lastPurchasePrice,
    this.currentStock,
        this.gstPercentage,
        this.purchasePrice,
        this.description,
  });

  factory MaterialData.fromJson(Map<String, dynamic> json) {
    return MaterialData(
      materialId: json['material_id'] ?? "",
      materialName: json['material_name'] ?? "",
      productType: json['product_type'] ?? "",
      taxPercentage: json['tax_percentage'] ?? "",
      discountPercentage: json['discount_percentage'] ?? "",
      unitName: json['unit_name'] ?? "",
      unitPrice: json['unit_price'] ?? "",
      lastPurchasePrice: json['last_purchase_amount'] ?? "",
      currentStock: json['current_stock'] ?? "",
      gstPercentage: json['gst_percentage'] ?? "",
      purchasePrice: json['purchase_price'] ?? "",
      description: json['description'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'material_id': materialId,
    'material_name': materialName,
    'product_type': productType,
    'tax_percentage': taxPercentage,
    'discount_percentage': discountPercentage,
    'unit_name': unitName,
    'unit_price': unitPrice,
    'last_purchase_amount': lastPurchasePrice,
    'current_stock': currentStock,
    'gst_percentage': gstPercentage,
    'purchase_price': purchasePrice,
    'description': description,
  };
}
