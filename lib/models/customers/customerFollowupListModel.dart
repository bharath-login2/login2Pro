import 'dart:convert';

CustomerFollowupListModel customerFollowupListModelFromJson(String str) =>
    CustomerFollowupListModel.fromJson(json.decode(str));

String customerFollowupListModelToJson(CustomerFollowupListModel data) =>
    json.encode(data.toJson());

class CustomerFollowupListModel {
  final bool status;
  final String message;
  final List<CustomerFollowupListItem> data;

  CustomerFollowupListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerFollowupListModel.fromJson(Map<String, dynamic> json) {
    dynamic listData = json['data'];
    if (listData is String) {
      try {
        listData = jsonDecode(listData);
      } catch (_) {}
    }

    final items = <CustomerFollowupListItem>[];
    if (listData is List) {
      for (var element in listData) {
        if (element != null && element is Map<String, dynamic>) {
          items.add(CustomerFollowupListItem.fromJson(element));
        } else if (element != null && element is Map) {
          items.add(CustomerFollowupListItem.fromJson(
              Map<String, dynamic>.from(element)));
        }
      }
    }

    return CustomerFollowupListModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      data: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.map((x) => x.toJson()).toList(),
      };
}

class CustomerFollowupListItem {
  final String id;
  final String customerId;
  final String callMasterId;
  final String callResultId;
  final String callResponseId;
  final String callStatusId;
  final String reasonId;
  final String? scheduledDate;
  final String? calledDate;
  final String? followupDate;
  final String? transferredDate;
  final String remarks;
  final String callHandledBy;
  final String companyId;
  final String branchId;
  final String createdBy;
  final String createdAt;
  final String isDeleted;
  final String leadId;
  final String name;
  final String emailId;
  final String countryCode;
  final String contactNo;
  final String whatsappCountryCode;
  final String whatsappNumber;
  final String address;
  final String address2;
  final String address3;
  final String postOffice;
  final String pincode;
  final String gstNum;
  final String state;
  final String? district;
  final String taxType;
  final String? nationality;
  final String? stateId;
  final String? districtId;
  final String? customerType;
  final String isNegative;
  final String? negativeMarkedAt;
  final String priority;
  final String? negativeMarkedBy;
  final String? negativeReason;

  CustomerFollowupListItem({
    required this.id,
    required this.customerId,
    required this.callMasterId,
    required this.callResultId,
    required this.callResponseId,
    required this.callStatusId,
    required this.reasonId,
    this.scheduledDate,
    this.calledDate,
    this.followupDate,
    this.transferredDate,
    required this.remarks,
    required this.callHandledBy,
    required this.companyId,
    required this.branchId,
    required this.createdBy,
    required this.createdAt,
    required this.isDeleted,
    required this.leadId,
    required this.name,
    required this.emailId,
    required this.countryCode,
    required this.contactNo,
    required this.whatsappCountryCode,
    required this.whatsappNumber,
    required this.address,
    required this.address2,
    required this.address3,
    required this.postOffice,
    required this.pincode,
    required this.gstNum,
    required this.state,
    this.district,
    required this.taxType,
    this.nationality,
    this.stateId,
    this.districtId,
    this.customerType,
    required this.isNegative,
    this.negativeMarkedAt,
    required this.priority,
    this.negativeMarkedBy,
    this.negativeReason,
  });

  factory CustomerFollowupListItem.fromJson(Map<String, dynamic> json) {
    String parseStr(dynamic val, {String fallback = ''}) {
      if (val == null) return fallback;
      return val.toString().trim();
    }

    String? parseNullableStr(dynamic val) {
      if (val == null) return null;
      final s = val.toString().trim();
      return (s.isEmpty || s.toLowerCase() == 'null') ? null : s;
    }

    return CustomerFollowupListItem(
      id: parseStr(json['id']),
      customerId:
          parseStr(json['customer_id'] ?? json['cust_id'] ?? json['id']),
      callMasterId: parseStr(json['call_master_id']),
      callResultId: parseStr(json['call_result_id']),
      callResponseId: parseStr(json['call_response_id']),
      callStatusId: parseStr(json['call_status_id']),
      reasonId: parseStr(json['reason_id']),
      scheduledDate: parseNullableStr(json['scheduled_date']),
      calledDate: parseNullableStr(json['called_date']),
      followupDate: parseNullableStr(json['followup_date']),
      transferredDate: parseNullableStr(json['transferred_date']),
      remarks: parseStr(json['remarks']),
      callHandledBy: parseStr(json['call_handled_by']),
      companyId: parseStr(json['company_id']),
      branchId: parseStr(json['branch_id']),
      createdBy: parseStr(json['created_by']),
      createdAt: parseStr(json['created_at']),
      isDeleted: parseStr(json['is_deleted'], fallback: 'N'),
      leadId: parseStr(json['lead_id']),
      name: parseStr(json['name'], fallback: 'Unknown Customer'),
      emailId: parseStr(json['email_id'] ?? json['email']),
      countryCode: parseStr(json['country_code'], fallback: '91'),
      contactNo:
          parseStr(json['contact_no'] ?? json['mobile'] ?? json['phone']),
      whatsappCountryCode: parseStr(json['whatsapp_country_code']),
      whatsappNumber: parseStr(json['whatsapp_number']),
      address: parseStr(json['address']),
      address2: parseStr(json['address2']),
      address3: parseStr(json['address3']),
      postOffice: parseStr(json['post_office']),
      pincode: parseStr(json['pincode']),
      gstNum: parseStr(json['gst_num']),
      state: parseStr(json['state']),
      district: parseNullableStr(json['district']),
      taxType: parseStr(json['tax_type']),
      nationality: parseNullableStr(json['nationality']),
      stateId: parseNullableStr(json['state_id']),
      districtId: parseNullableStr(json['district_id']),
      customerType: parseNullableStr(json['customer_type']),
      isNegative: parseStr(json['is_negative'], fallback: '0'),
      negativeMarkedAt: parseNullableStr(json['negative_marked_at']),
      priority: parseStr(json['priority'], fallback: '1'),
      negativeMarkedBy: parseNullableStr(json['negative_marked_by']),
      negativeReason: parseNullableStr(json['negative_reason']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'call_master_id': callMasterId,
        'call_result_id': callResultId,
        'call_response_id': callResponseId,
        'call_status_id': callStatusId,
        'reason_id': reasonId,
        'scheduled_date': scheduledDate,
        'called_date': calledDate,
        'followup_date': followupDate,
        'transferred_date': transferredDate,
        'remarks': remarks,
        'call_handled_by': callHandledBy,
        'company_id': companyId,
        'branch_id': branchId,
        'created_by': createdBy,
        'created_at': createdAt,
        'is_deleted': isDeleted,
        'lead_id': leadId,
        'name': name,
        'email_id': emailId,
        'country_code': countryCode,
        'contact_no': contactNo,
        'whatsapp_country_code': whatsappCountryCode,
        'whatsapp_number': whatsappNumber,
        'address': address,
        'address2': address2,
        'address3': address3,
        'post_office': postOffice,
        'pincode': pincode,
        'gst_num': gstNum,
        'state': state,
        'district': district,
        'tax_type': taxType,
        'nationality': nationality,
        'state_id': stateId,
        'district_id': districtId,
        'customer_type': customerType,
        'is_negative': isNegative,
        'negative_marked_at': negativeMarkedAt,
        'priority': priority,
        'negative_marked_by': negativeMarkedBy,
        'negative_reason': negativeReason,
      };

  String get fullAddress {
    final parts = [address, address2, address3, postOffice, district, pincode]
        .where((s) => s != null && s.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get phoneWithCountryCode {
    if (contactNo.isEmpty) return '';
    if (contactNo.startsWith(countryCode) || contactNo.startsWith('+')) {
      return contactNo;
    }
    return '+$countryCode$contactNo';
  }

  String get whatsappWithCountryCode {
    if (whatsappNumber.isNotEmpty) {
      final code =
          whatsappCountryCode.isNotEmpty ? whatsappCountryCode : countryCode;
      if (whatsappNumber.startsWith(code) || whatsappNumber.startsWith('+')) {
        return whatsappNumber;
      }
      return '+$code$whatsappNumber';
    }
    return phoneWithCountryCode;
  }

  String? relevantDate(String filterCategory) {
    final categoryLower = filterCategory.toLowerCase();
    if (categoryLower.contains('called')) {
      return calledDate ?? scheduledDate;
    } else if (categoryLower.contains('transferred')) {
      return transferredDate ?? scheduledDate;
    } else if (categoryLower.contains('missed')) {
      return scheduledDate ?? followupDate;
    } else {
      // Follow-up
      return scheduledDate ?? followupDate;
    }
  }
}
