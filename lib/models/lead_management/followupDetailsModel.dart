class FollowupDetailsModel {
  bool? status;
  String? message;
  Data? data;

  FollowupDetailsModel({this.status, this.message, this.data});

  FollowupDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? callDetailsId;
  String? callMasterId;
  String? cost;
  String? leadCategoryId;
  String? leadCategory;
  String? leadSubCategoryId;
  String? leadSubCategory;
  String? calledDate;
  String? callResultId;
  String? callResult;
  String? callResponseId;
  String? callResponse;
  String? followupDate;
  String? expectedClosingDate;
  String? remarks;
  String? reason;
  String? reasonId;
  List<AdditionalField>? additionalFields;

  Data(
      {this.callDetailsId,
      this.callMasterId,
      this.cost,
      this.leadCategoryId,
      this.leadCategory,
      this.leadSubCategoryId,
      this.leadSubCategory,
      this.calledDate,
      this.callResultId,
      this.callResult,
      this.callResponseId,
      this.callResponse,
      this.followupDate,
      this.expectedClosingDate,
      this.remarks,
      this.reason,
      this.reasonId,
      this.additionalFields});

  Data.fromJson(Map<String, dynamic> json) {
    callDetailsId = json['call_details_id']??"";
    callMasterId = json['call_master_id']??"";
    cost = json['cost']??"";
    leadCategoryId = json['lead_category_id']??"";
    leadCategory = json['lead_category']??"";
    leadSubCategoryId = json['lead_sub_category_id'];
    leadSubCategory = json['lead_sub_category'];
    calledDate = json['called_date'];
    callResultId = json['call_result_id'];
    callResult = json['call_result'];
    callResponseId = json['call_response_id'];
    callResponse = json['call_response'];
    followupDate = json['followup_date'];
    expectedClosingDate = json['expected_closing_date'];
    remarks = json['remarks'];
    reason = json['reason'];
    reasonId = json['reason_id'];
    if (json['additional_fields'] != null) {
      additionalFields = <AdditionalField>[];
      json['additional_fields'].forEach((v) {
        additionalFields!.add(AdditionalField.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_details_id'] = callDetailsId;
    data['call_master_id'] = callMasterId;
    data['cost'] = cost;
    data['lead_category_id'] = leadCategoryId;
    data['lead_category'] = leadCategory;
    data['lead_sub_category_id'] = leadSubCategoryId;
    data['lead_sub_category'] = leadSubCategory;
    data['called_date'] = calledDate;
    data['call_result_id'] = callResultId;
    data['call_result'] = callResult;
    data['call_response_id'] = callResponseId;
    data['call_response'] = callResponse;
    data['followup_date'] = followupDate;
    data['expected_closing_date'] = expectedClosingDate;
    data['remarks'] = remarks;
    data['reason'] = reason;
    data['reason_id'] = reasonId;
    if (additionalFields != null) {
      data['additional_fields'] =
          additionalFields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AdditionalField {
  String? id;
  String? name;
  String? value;

  AdditionalField({this.id, this.name, this.value});

  AdditionalField.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}
