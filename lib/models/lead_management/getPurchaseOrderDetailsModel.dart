class GetPurchaseOrderDetailsModel {
  bool? status;
  String? message;
  PurchaseOrderData? data;

  GetPurchaseOrderDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  GetPurchaseOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PurchaseOrderData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PurchaseOrderData {
  OrderDetails? orderDetails;
  List<Item>? items;

  PurchaseOrderData({
    this.orderDetails,
    this.items,
  });

  PurchaseOrderData.fromJson(Map<String, dynamic> json) {
    orderDetails = json['order_details'] != null
        ? OrderDetails.fromJson(json['order_details'])
        : null;
    if (json['items'] != null) {
      items = <Item>[];
      json['items'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (orderDetails != null) {
      data['order_details'] = orderDetails!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderDetails {
  String? purchaseOrderId;
  String? orderId;
  String? requestId;
  String? supplierId;
  String? supplierName;
  String? referenceNo;
  String? billingAddress;
  String? shippingAddress;
  String? deliveryDate;
  String? remarks;
  String? supplierBalance;
  String? orderDate;
  String? totalAmount;
  String? advanceAmount;
  String? createdBy;
  String? paymentMethod;
  String? refNo;
  String? address;

  OrderDetails({
    this.purchaseOrderId,
    this.orderId,
    this.requestId,
    this.supplierId,
    this.supplierName,
    this.referenceNo,
    this.billingAddress,
    this.shippingAddress,
    this.deliveryDate,
    this.remarks,
    this.supplierBalance,
    this.orderDate,
    this.totalAmount,
    this.advanceAmount,
    this.createdBy,
    this.paymentMethod,
    this.refNo,
    this.address,
  });

  OrderDetails.fromJson(Map<String, dynamic> json) {
    purchaseOrderId = json['purchase_order_id'];
    orderId = json['order_id'];
    requestId = json['request_id'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    referenceNo = json['refference_no'];
    billingAddress = json['billing_address'];
    shippingAddress = json['shipping_address'];
    deliveryDate = json['delivery_date'];
    remarks = json['remarks'];
    supplierBalance = json['supplier_balance'];
    orderDate = json['order_date'];
    totalAmount = json['total_amount'];
    advanceAmount = json['advance_amount'];
    createdBy = json['created_by'];
    paymentMethod = json['payment_method'];
    refNo = json['ref_no'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['purchase_order_id'] = purchaseOrderId;
    data['order_id'] = orderId;
    data['request_id'] = requestId;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['refference_no'] = referenceNo;
    data['billing_address'] = billingAddress;
    data['shipping_address'] = shippingAddress;
    data['delivery_date'] = deliveryDate;
    data['remarks'] = remarks;
    data['supplier_balance'] = supplierBalance;
    data['order_date'] = orderDate;
    data['total_amount'] = totalAmount;
    data['advance_amount'] = advanceAmount;
    data['created_by'] = createdBy;
    data['payment_method'] = paymentMethod;
    data['ref_no'] = refNo;
    data['address'] = address;
    return data;
  }
}

class Item {
  String? itemId;
  String? materialId;
  String? materialName;
  String? productCode;
  String? unitId;
  String? unitName;
  String? quantity;
  String? unitPrice;
  String? totalAmount;

  Item({
    this.itemId,
    this.materialId,
    this.materialName,
    this.productCode,
    this.unitId,
    this.unitName,
    this.quantity,
    this.unitPrice,
    this.totalAmount,
  });

  Item.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    materialId = json['material_id'];
    materialName = json['material_name'];
    productCode = json['product_code'];
    unitId = json['unit_id'];
    unitName = json['unit_name'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    totalAmount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['item_id'] = itemId;
    data['material_id'] = materialId;
    data['material_name'] = materialName;
    data['product_code'] = productCode;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['quantity'] = quantity;
    data['unit_price'] = unitPrice;
    data['total_amount'] = totalAmount;
    return data;
  }
}