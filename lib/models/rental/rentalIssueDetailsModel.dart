class RentalIssueDetailsResponse {
  final bool status;
  final String message;
  final RentalIssueData data;

  RentalIssueDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentalIssueDetailsResponse.fromJson(Map<String, dynamic> json) {
    return RentalIssueDetailsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: RentalIssueData.fromJson(json['data'] ?? {}),
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

class RentalIssueData {
  final RentIssue rentIssue;
  final List<RentItem> rentItems;

  RentalIssueData({
    required this.rentIssue,
    required this.rentItems,
  });

  factory RentalIssueData.fromJson(Map<String, dynamic> json) {
    return RentalIssueData(
      rentIssue: RentIssue.fromJson(json['rent_issue'] ?? {}),
      rentItems: (json['rent_items'] as List? ?? [])
          .map((item) => RentItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rent_issue': rentIssue.toJson(),
      'rent_items': rentItems.map((item) => item.toJson()).toList(),
    };
  }
}

class RentIssue {
  final String id;
  final String companyId;
  final String customerId;
  final String locationId;
  final String collectedRent;
  final String address;
  final String fromDate;
  final String toDate;
  final String totalDays;
  final String rentNo;
  final String invoiceNo;
  final String invoiceDate;
  final String advanceAmount;
  final String amountPaid;
  final String subTotal;
  final String gstTotal;
  final String discount;
  final String otherExpenses;
  final String grandTotal;
  final String createdBy;
  final String createdAt;
  final String updatedBy;
  final String updatedAt;
  final String deletedBy;
  final String deletedAt;
  final String isDeleted;
  final String customerName;
  final String locationName;
  final String collectedStaffName;

  RentIssue({
    required this.id,
    required this.companyId,
    required this.customerId,
    required this.locationId,
    required this.collectedRent,
    required this.address,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.rentNo,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.advanceAmount,
    required this.amountPaid,
    required this.subTotal,
    required this.gstTotal,
    required this.discount,
    required this.otherExpenses,
    required this.grandTotal,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.deletedBy,
    required this.deletedAt,
    required this.isDeleted,
    required this.customerName,
    required this.locationName,
    required this.collectedStaffName,
  });

  factory RentIssue.fromJson(Map<String, dynamic> json) {
    return RentIssue(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      collectedRent: json['collected_Rent']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      totalDays: json['total_days']?.toString() ?? '',
      rentNo: json['rent_no']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      advanceAmount: json['advance_amount']?.toString() ?? '0.00',
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      subTotal: json['sub_total']?.toString() ?? '0.00',
      gstTotal: json['gst_total']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      otherExpenses: json['other_expenses']?.toString() ?? '0.00',
      grandTotal: json['grand_total']?.toString() ?? '0.00',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? 'N',
      customerName: json['customer_name']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      collectedStaffName: json['collected_staff_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'customer_id': customerId,
      'location_id': locationId,
      'collected_Rent': collectedRent,
      'address': address,
      'from_date': fromDate,
      'to_date': toDate,
      'total_days': totalDays,
      'rent_no': rentNo,
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
      'advance_amount': advanceAmount,
      'amount_paid': amountPaid,
      'sub_total': subTotal,
      'gst_total': gstTotal,
      'discount': discount,
      'other_expenses': otherExpenses,
      'grand_total': grandTotal,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'deleted_by': deletedBy,
      'deleted_at': deletedAt,
      'is_deleted': isDeleted,
      'customer_name': customerName,
      'location_name': locationName,
      'collected_staff_name': collectedStaffName,
    };
  }
}

class RentItem {
  final String id;
  final String rentId;
  final String productId;
  final String productName;
  final String qty;
  final String unitPrice;
  final String days;
  final String ratePerDay;
  final String gross;
  final String gstPercent;
  final String gstAmount;
  final String total;
  final String createdAt;
  final String companyId;
  final String locationId;
  final String deletedAt;
  final String deletedBy;
  final String isDeleted;

  RentItem({
    required this.id,
    required this.rentId,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.days,
    required this.ratePerDay,
    required this.gross,
    required this.gstPercent,
    required this.gstAmount,
    required this.total,
    required this.createdAt,
    required this.companyId,
    required this.locationId,
    required this.deletedAt,
    required this.deletedBy,
    required this.isDeleted,
  });

  factory RentItem.fromJson(Map<String, dynamic> json) {
    return RentItem(
      id: json['id']?.toString() ?? '',
      rentId: json['rent_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '0',
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      days: json['days']?.toString() ?? '0',
      ratePerDay: json['rate_per_day']?.toString() ?? '0.00',
      gross: json['gross']?.toString() ?? '0.00',
      gstPercent: json['gst_percent']?.toString() ?? '0',
      gstAmount: json['gst_amount']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
      createdAt: json['created_at']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? 'N',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rent_id': rentId,
      'product_id': productId,
      'product_name': productName,
      'qty': qty,
      'unit_price': unitPrice,
      'days': days,
      'rate_per_day': ratePerDay,
      'gross': gross,
      'gst_percent': gstPercent,
      'gst_amount': gstAmount,
      'total': total,
      'created_at': createdAt,
      'company_id': companyId,
      'location_id': locationId,
      'deleted_at': deletedAt,
      'deleted_by': deletedBy,
      'is_deleted': isDeleted,
    };
  }
}
