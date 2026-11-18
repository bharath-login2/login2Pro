class GetPurchaseOrderModel {
  bool? status;
  String? message;
  List<PurchaseOrderData>? data;

  GetPurchaseOrderModel({this.status, this.message, this.data});

  GetPurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PurchaseOrderData>[];
      json['data'].forEach((v) {
        data!.add(PurchaseOrderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseOrderData {
  String? poId;
  String? orderId;
  String? orderDate;
  String? supplierId;
  String? supplierName;
  String? estimatedAmt;
  String? advanceAmt;
  String? balanceAmt;
  String? billStatus;
  String? address;
  String? approvalStatus;
  List<POProduct>? products;

  PurchaseOrderData({
    this.poId,
    this.orderId,
    this.orderDate,
    this.supplierId,
    this.supplierName,
    this.estimatedAmt,
    this.advanceAmt,
    this.balanceAmt,
    this.billStatus,
    this.address,
    this.approvalStatus,
    this.products,
  });

  PurchaseOrderData.fromJson(Map<String, dynamic> json) {
    poId = json['po_id'];
    orderId = json['order_id'];
    orderDate = json['order_date'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    estimatedAmt = json['estimated_amt'];
    advanceAmt = json['advance_amt'];
    balanceAmt = json['balance_amt'];
    billStatus = json['bill_status'];
    approvalStatus = json['approval_status'];
    address = json['address'];
    if (json['products'] != null) {
      products = <POProduct>[];
      json['products'].forEach((v) {
        products!.add(POProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['po_id'] = poId;
    data['order_id'] = orderId;
    data['order_date'] = orderDate;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['estimated_amt'] = estimatedAmt;
    data['advance_amt'] = advanceAmt;
    data['balance_amt'] = balanceAmt;
    data['bill_status'] = billStatus;
    data['address'] = address;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class POProduct {
  String? itemId;
  String? materialId;
  String? productName;
  String? productCode;
  String? unitId;
  String? unitName;
  String? quantity;
  String? unitPrice;
  String? amount;

  POProduct({
    this.itemId,
    this.materialId,
    this.productName,
    this.productCode,
    this.unitId,
    this.unitName,
    this.quantity,
    this.unitPrice,
    this.amount,
  });

  POProduct.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    materialId = json['material_id'];
    productName = json['product_name'];
    productCode = json['product_code'];
    unitId = json['unit_id'];
    unitName = json['unit_name'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['material_id'] = materialId;
    data['product_name'] = productName;
    data['product_code'] = productCode;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['quantity'] = quantity;
    data['unit_price'] = unitPrice;
    data['amount'] = amount;
    return data;
  }
}