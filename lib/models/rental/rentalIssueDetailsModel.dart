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
  final List<AddonProduct> addonProducts;
  final AddressDetail? billingAddress;
  final AddressDetail? shippingAddress;

  RentalIssueData({
    required this.rentIssue,
    required this.rentItems,
    this.addonProducts = const [],
    this.billingAddress,
    this.shippingAddress,
  });

  factory RentalIssueData.fromJson(Map<String, dynamic> json) {
    return RentalIssueData(
      rentIssue: RentIssue.fromJson(json['rent_issue'] ?? {}),
      rentItems: (json['rent_items'] as List? ?? [])
          .map((item) => RentItem.fromJson(item))
          .toList(),
      addonProducts: (json['addon_products'] as List? ?? [])
          .map((item) => AddonProduct.fromJson(item))
          .toList(),
      billingAddress: json['billing_address'] != null &&
              json['billing_address'] is Map<String, dynamic>
          ? AddressDetail.fromJson(json['billing_address'])
          : null,
      shippingAddress: json['shipping_address'] != null &&
              json['shipping_address'] is Map<String, dynamic>
          ? AddressDetail.fromJson(json['shipping_address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rent_issue': rentIssue.toJson(),
      'rent_items': rentItems.map((item) => item.toJson()).toList(),
      'addon_products': addonProducts.map((item) => item.toJson()).toList(),
      'billing_address': billingAddress?.toJson(),
      'shipping_address': shippingAddress?.toJson(),
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
  final String loadingCharges;
  final String transportationCharges;
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
    required this.loadingCharges,
    required this.transportationCharges,
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
      loadingCharges: json['loading_charges']?.toString() ?? '0.00',
      transportationCharges: json['transportation_charges']?.toString() ?? '0.00',
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
      'loading_charges': loadingCharges,
      'transportation_charges': transportationCharges,
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

class AddonProduct {
  final String id;
  final String companyId;
  final String rentId;
  final String productId;
  final String qty;
  final String createdAt;
  final String createdBy;
  final String productName;

  AddonProduct({
    required this.id,
    required this.companyId,
    required this.rentId,
    required this.productId,
    required this.qty,
    required this.createdAt,
    required this.createdBy,
    required this.productName,
  });

  factory AddonProduct.fromJson(Map<String, dynamic> json) {
    return AddonProduct(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      rentId: json['rent_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '0',
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
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
    };
  }
}

class AddressDetail {
  final String id;
  final String category;
  final String masterId;
  final String clientId;
  final String name;
  final String contactNoCountryCode;
  final String contactNo;
  final String whatsappNoCountryCode;
  final String whatsappNumber;
  final String address;
  final String address1;
  final String address2;
  final String address3;
  final String pincode;
  final String postOffice;
  final String gstNum;
  final String companyId;

  AddressDetail({
    required this.id,
    required this.category,
    required this.masterId,
    required this.clientId,
    required this.name,
    required this.contactNoCountryCode,
    required this.contactNo,
    required this.whatsappNoCountryCode,
    required this.whatsappNumber,
    required this.address,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.pincode,
    required this.postOffice,
    required this.gstNum,
    required this.companyId,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      masterId: json['master_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactNoCountryCode: json['contact_no_country_code']?.toString() ?? '',
      contactNo: json['contact_no']?.toString() ?? '',
      whatsappNoCountryCode:
          json['whatsapp_no_country_code']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      address1: json['address1']?.toString() ?? '',
      address2: json['address2']?.toString() ?? '',
      address3: json['address3']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      postOffice: json['post_office']?.toString() ?? '',
      gstNum: json['gst_num']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'master_id': masterId,
      'client_id': clientId,
      'name': name,
      'contact_no_country_code': contactNoCountryCode,
      'contact_no': contactNo,
      'whatsapp_no_country_code': whatsappNoCountryCode,
      'whatsapp_number': whatsappNumber,
      'address': address,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'pincode': pincode,
      'post_office': postOffice,
      'gst_num': gstNum,
      'company_id': companyId,
    };
  }
}
