class ReturnDetailsRentalModel {
  final bool status;
  final String message;
  final ReturnDetailsData data;

  ReturnDetailsRentalModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReturnDetailsRentalModel.fromJson(Map<String, dynamic> json) {
    return ReturnDetailsRentalModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ReturnDetailsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ReturnDetailsData {
  final String rentIssueId;
  final String invoiceId;
  final String customerPhone;
  final String invoiceNo;
  final String rentNo;
  final String fromDate;
  final String toDate;
  final String issuedDate;
  final String collectedRent;
  final String locationName;
  final String locationId;
  final double advanceAmount;
  final double previousAmountPaid;
  final double previousGrandTotal;
  final double previousBalance;
  final double otherExpenses;
  final double loadingCharges;
  final double transportationCharges;
  final List<ReturnItem> items;
  final List<AddonProductReturnItem> addonProducts;

  ReturnDetailsData({
    required this.rentIssueId,
    required this.invoiceId,
    required this.customerPhone,
    required this.invoiceNo,
    required this.rentNo,
    required this.fromDate,
    required this.toDate,
    required this.issuedDate,
    required this.collectedRent,
    required this.locationName,
    required this.locationId,
    required this.advanceAmount,
    required this.previousAmountPaid,
    required this.previousGrandTotal,
    required this.previousBalance,
    required this.otherExpenses,
    required this.loadingCharges,
    required this.transportationCharges,
    required this.items,
    required this.addonProducts,
  });

  factory ReturnDetailsData.fromJson(Map<String, dynamic> json) {
    return ReturnDetailsData(
      rentIssueId: json['rent_issue_id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      rentNo: json['rent_no']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      issuedDate: json['issued_date']?.toString() ?? '',
      collectedRent: json['collected_rent']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      advanceAmount: (json['advance_amount'] as num?)?.toDouble() ??
          double.tryParse(json['advance_amount']?.toString() ?? '') ?? 0.0,
      previousAmountPaid:
          (json['previous_amount_paid'] as num?)?.toDouble() ??
              double.tryParse(json['previous_amount_paid']?.toString() ?? '') ?? 0.0,
      previousGrandTotal:
          (json['previous_grand_total'] as num?)?.toDouble() ??
              double.tryParse(json['previous_grand_total']?.toString() ?? '') ?? 0.0,
      previousBalance: (json['previous_balance'] as num?)?.toDouble() ??
          double.tryParse(json['previous_balance']?.toString() ?? '') ?? 0.0,
      otherExpenses: (json['other_expenses'] as num?)?.toDouble() ??
          double.tryParse(json['other_expenses']?.toString() ?? '') ?? 0.0,
      loadingCharges: (json['loading_charges'] as num?)?.toDouble() ??
          double.tryParse(json['loading_charges']?.toString() ?? '') ?? 0.0,
      transportationCharges: (json['transportation_charges'] as num?)?.toDouble() ??
          double.tryParse(json['transportation_charges']?.toString() ?? '') ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ReturnItem.fromJson(item))
              .toList() ??
          [],
      addonProducts: (json['addon_products'] as List<dynamic>?)
              ?.map((item) => AddonProductReturnItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rent_issue_id': rentIssueId,
      'invoice_id': invoiceId,
      'customer_phone': customerPhone,
      'invoice_no': invoiceNo,
      'rent_no': rentNo,
      'from_date': fromDate,
      'to_date': toDate,
      'issued_date': issuedDate,
      'collected_rent': collectedRent,
      'location_name': locationName,
      'location_id': locationId,
      'advance_amount': advanceAmount,
      'previous_amount_paid': previousAmountPaid,
      'previous_grand_total': previousGrandTotal,
      'previous_balance': previousBalance,
      'other_expenses': otherExpenses,
      'loading_charges': loadingCharges,
      'transportation_charges': transportationCharges,
      'items': items.map((item) => item.toJson()).toList(),
      'addon_products': addonProducts.map((item) => item.toJson()).toList(),
    };
  }
}

class ReturnItem {
  final String id;
  final String productId;
  final String productName;
  final int qty;
  final String unitPrice;
  final int returnedQty;
  final int qtyRemaining;

  ReturnItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.returnedQty,
    required this.qtyRemaining,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? int.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      unitPrice: json['rent_price']?.toString() ?? '',
      returnedQty: (json['returned_qty'] as num?)?.toInt() ?? int.tryParse(json['returned_qty']?.toString() ?? '0') ?? 0,
      qtyRemaining: (json['qty_remaining'] as num?)?.toInt() ?? int.tryParse(json['qty_remaining']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'qty': qty,
      'rent_price': unitPrice,
      'returned_qty': returnedQty,
      'qty_remaining': qtyRemaining,
    };
  }
}

class AddonProductReturnItem {
  final String id;
  final String companyId;
  final String rentId;
  final String productId;
  final double qty;
  final String createdAt;
  final String createdBy;
  final String productName;
  final int alreadyReturned;

  AddonProductReturnItem({
    required this.id,
    required this.companyId,
    required this.rentId,
    required this.productId,
    required this.qty,
    required this.createdAt,
    required this.createdBy,
    required this.productName,
    this.alreadyReturned = 0,
  });

  factory AddonProductReturnItem.fromJson(Map<String, dynamic> json) {
    return AddonProductReturnItem(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      rentId: json['rent_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? json['item_id']?.toString() ?? '',
      qty: double.tryParse(json['qty']?.toString() ?? json['quantity']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? json['name']?.toString() ?? '',
      alreadyReturned: int.tryParse(json['already_returned']?.toString() ?? json['returned_qty']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'rent_id': rentId,
      'product_id': productId,
      'qty': qty,
      'created_at': createdAt,
      'created_by': createdBy,
      'product_name': productName,
      'already_returned': alreadyReturned,
    };
  }
}
