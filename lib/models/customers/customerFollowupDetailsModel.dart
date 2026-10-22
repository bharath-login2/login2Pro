class CustomerFollowupDetailsModel {
  final bool status;
  final String message;
  final CustomerFollowupData? data;

  CustomerFollowupDetailsModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CustomerFollowupDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerFollowupDetailsModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? CustomerFollowupData.fromJson(
              Map<String, dynamic>.from(json['data']))
          : null,
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

class CustomerFollowupData {
  final String callMasterId;
  final CustomerCallData? callData;
  final List<CustomerFollowupItem> followup;

  CustomerFollowupData({
    required this.callMasterId,
    this.callData,
    required this.followup,
  });

  factory CustomerFollowupData.fromJson(Map<String, dynamic> json) {
    return CustomerFollowupData(
      callMasterId: json['call_master_id']?.toString() ?? '',
      callData: json['callData'] != null && json['callData'] is Map<String, dynamic>
          ? CustomerCallData.fromJson(
              Map<String, dynamic>.from(json['callData']))
          : null,
      followup: json['followup'] != null && json['followup'] is List
          ? (json['followup'] as List)
              .map((e) => CustomerFollowupItem.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'call_master_id': callMasterId,
      'callData': callData?.toJson(),
      'followup': followup.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerCallData {
  final String callMasterId;
  final String leadCategoryId;
  final String leadSubCategoryId;
  final String clientName;
  final String address;
  final String cost;
  final String assignedUserId;
  final String callResultId;
  final String calledDate;
  final String createdDate;
  final String createdStaff;
  final String nextFollowupDate;
  final String remarks;
  final String leadMethod;
  final String leadCategory;
  final String leadSubCategory;
  final String callResult;
  final String staffName;
  final String priorityId;
  final String priority;
  final String countryCode;
  final String contactNumber1;
  final String branchId;
  final String leadSourceId;
  final String leadSource;
  final String stateName;
  final String districtName;
  final String productsLead;
  final String emailLead;
  final String whatsappNumberLead;
  final String whatsappCountryCode;
  final String products;
  final List<CallHandledUser> callHandledUsers;

  CustomerCallData({
    required this.callMasterId,
    required this.leadCategoryId,
    required this.leadSubCategoryId,
    required this.clientName,
    required this.address,
    required this.cost,
    required this.assignedUserId,
    required this.callResultId,
    required this.calledDate,
    required this.createdDate,
    required this.createdStaff,
    required this.nextFollowupDate,
    required this.remarks,
    required this.leadMethod,
    required this.leadCategory,
    required this.leadSubCategory,
    required this.callResult,
    required this.staffName,
    required this.priorityId,
    required this.priority,
    required this.countryCode,
    required this.contactNumber1,
    required this.branchId,
    required this.leadSourceId,
    required this.leadSource,
    required this.stateName,
    required this.districtName,
    required this.productsLead,
    required this.emailLead,
    required this.whatsappNumberLead,
    required this.whatsappCountryCode,
    required this.products,
    required this.callHandledUsers,
  });

  factory CustomerCallData.fromJson(Map<String, dynamic> json) {
    return CustomerCallData(
      callMasterId: json['call_master_id']?.toString() ?? '',
      leadCategoryId: json['lead_category_id']?.toString() ?? '',
      leadSubCategoryId: json['lead_sub_category_id']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      cost: json['cost']?.toString() ?? '',
      assignedUserId: json['assigned_user_id']?.toString() ?? '',
      callResultId: json['call_result_id']?.toString() ?? '',
      calledDate: json['called_date']?.toString() ?? '',
      createdDate: json['created_date']?.toString() ?? '',
      createdStaff: json['created_staff']?.toString() ?? '',
      nextFollowupDate: json['next_followup_date']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      leadMethod: json['lead_method']?.toString() ?? '',
      leadCategory: json['lead_category']?.toString() ?? '',
      leadSubCategory: json['lead_sub_category']?.toString() ?? '',
      callResult: json['call_result']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      priorityId: json['priority_id']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      contactNumber1: json['contact_number1']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      leadSourceId: json['lead_source_id']?.toString() ?? '',
      leadSource: json['lead_source']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
      productsLead: json['products_lead']?.toString() ?? '',
      emailLead: json['email_lead']?.toString() ?? '',
      whatsappNumberLead: json['whatsapp_number_lead']?.toString() ?? '',
      whatsappCountryCode: json['whatsapp_country_code']?.toString() ?? '',
      products: json['products']?.toString() ?? '',
      callHandledUsers: json['call_handled_users'] != null &&
              json['call_handled_users'] is List
          ? (json['call_handled_users'] as List)
              .map((e) =>
                  CallHandledUser.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'call_master_id': callMasterId,
      'lead_category_id': leadCategoryId,
      'lead_sub_category_id': leadSubCategoryId,
      'client_name': clientName,
      'address': address,
      'cost': cost,
      'assigned_user_id': assignedUserId,
      'call_result_id': callResultId,
      'called_date': calledDate,
      'created_date': createdDate,
      'created_staff': createdStaff,
      'next_followup_date': nextFollowupDate,
      'remarks': remarks,
      'lead_method': leadMethod,
      'lead_category': leadCategory,
      'lead_sub_category': leadSubCategory,
      'call_result': callResult,
      'staff_name': staffName,
      'priority_id': priorityId,
      'priority': priority,
      'country_code': countryCode,
      'contact_number1': contactNumber1,
      'branch_id': branchId,
      'lead_source_id': leadSourceId,
      'lead_source': leadSource,
      'state_name': stateName,
      'district_name': districtName,
      'products_lead': productsLead,
      'email_lead': emailLead,
      'whatsapp_number_lead': whatsappNumberLead,
      'whatsapp_country_code': whatsappCountryCode,
      'products': products,
      'call_handled_users': callHandledUsers.map((e) => e.toJson()).toList(),
    };
  }
}

class CallHandledUser {
  final String userId;
  final String staffName;
  final String proPicThumb;
  final String phoneNo;
  final String email;
  final String callCount;

  CallHandledUser({
    required this.userId,
    required this.staffName,
    required this.proPicThumb,
    required this.phoneNo,
    required this.email,
    required this.callCount,
  });

  factory CallHandledUser.fromJson(Map<String, dynamic> json) {
    return CallHandledUser(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      proPicThumb: json['pro_pic_thumb']?.toString() ?? '',
      phoneNo: json['phone_no']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      callCount: json['call_count']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'pro_pic_thumb': proPicThumb,
      'phone_no': phoneNo,
      'email': email,
      'call_count': callCount,
    };
  }
}

class CustomerFollowupItem {
  final String id;
  final String callDetailsId;
  final String customerId;
  final String callMasterId;
  final String callResultId;
  final String callResponseId;
  final String callStatusId;
  final String reasonId;
  final String? calledDate;
  final String? scheduledDate;
  final String? calledDateFormatted;
  final String? date;
  final String? followupDate;
  final String? followupDateFormatted;
  final String? remarks;
  final String? callHandledBy;
  final String? companyId;
  final String? branchId;
  final String? createdBy;
  final String? createdAt;
  final String? callResult;
  final String? callResponse;
  final String? callStatus;
  final String? reason;
  final String? staffName;
  final String? proPicThumb;
  final bool? isEditDelete;

  CustomerFollowupItem({
    required this.id,
    required this.callDetailsId,
    required this.customerId,
    required this.callMasterId,
    required this.callResultId,
    required this.callResponseId,
    required this.callStatusId,
    required this.reasonId,
    this.calledDate,
    this.scheduledDate,
    this.calledDateFormatted,
    this.date,
    this.followupDate,
    this.followupDateFormatted,
    this.remarks,
    this.callHandledBy,
    this.companyId,
    this.branchId,
    this.createdBy,
    this.createdAt,
    this.callResult,
    this.callResponse,
    this.callStatus,
    this.reason,
    this.staffName,
    this.proPicThumb,
    this.isEditDelete,
  });

  factory CustomerFollowupItem.fromJson(Map<String, dynamic> json) {
    return CustomerFollowupItem(
      id: json['id']?.toString() ?? '',
      callDetailsId: json['call_details_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      callMasterId: json['call_master_id']?.toString() ?? '',
      callResultId: json['call_result_id']?.toString() ?? '',
      callResponseId: json['call_response_id']?.toString() ?? '',
      callStatusId: json['call_status_id']?.toString() ?? '',
      reasonId: json['reason_id']?.toString() ?? '',
      calledDate: json['called_date']?.toString(),
      scheduledDate: json['scheduled_date']?.toString(),
      calledDateFormatted: json['called_date_formatted']?.toString(),
      date: json['date']?.toString(),
      followupDate: json['followup_date']?.toString(),
      followupDateFormatted: json['followup_date_formatted']?.toString(),
      remarks: json['remarks']?.toString(),
      callHandledBy: json['call_handled_by']?.toString(),
      companyId: json['company_id']?.toString(),
      branchId: json['branch_id']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      callResult: json['call_result']?.toString(),
      callResponse: json['call_response']?.toString(),
      callStatus: json['call_status']?.toString(),
      reason: json['reason']?.toString(),
      staffName: json['staff_name']?.toString(),
      proPicThumb: json['pro_pic_thumb']?.toString(),
      isEditDelete: json['is_edit_delete'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_details_id': callDetailsId,
      'customer_id': customerId,
      'call_master_id': callMasterId,
      'call_result_id': callResultId,
      'call_response_id': callResponseId,
      'call_status_id': callStatusId,
      'reason_id': reasonId,
      'called_date': calledDate,
      'scheduled_date': scheduledDate,
      'called_date_formatted': calledDateFormatted,
      'date': date,
      'followup_date': followupDate,
      'followup_date_formatted': followupDateFormatted,
      'remarks': remarks,
      'call_handled_by': callHandledBy,
      'company_id': companyId,
      'branch_id': branchId,
      'created_by': createdBy,
      'created_at': createdAt,
      'call_result': callResult,
      'call_response': callResponse,
      'call_status': callStatus,
      'reason': reason,
      'staff_name': staffName,
      'pro_pic_thumb': proPicThumb,
      'is_edit_delete': isEditDelete,
    };
  }
}
