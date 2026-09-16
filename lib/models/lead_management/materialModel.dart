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
        this.purchasePrice
  });

  factory MaterialData.fromJson(Map<String, dynamic> json) {
    return MaterialData(
      materialId: (json['material_id'] ?? json['id'] ?? "").toString(),
      materialName: (json['material_name'] ?? json['product_name'] ?? json['name'] ?? "").toString(),
      productType: (json['product_type'] ?? "").toString(),
      taxPercentage: (json['tax_percentage'] ?? json['tax_percent'] ?? "").toString(),
      discountPercentage: (json['discount_percentage'] ?? json['discount_percent'] ?? "").toString(),
      unitName: (json['unit_name'] ?? json['unit'] ?? "-").toString(),
      unitPrice: (json['unit_price'] ?? json['price'] ?? json['rate'] ?? "0").toString(),
      lastPurchasePrice: (json['last_purchase_amount'] ?? "").toString(),
      currentStock: (json['current_stock'] ?? json['stock'] ?? "0").toString(),
      gstPercentage: (json['gst_percentage'] ?? "").toString(),
      purchasePrice: (json['purchase_price'] ?? "").toString(),
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
  };
}
