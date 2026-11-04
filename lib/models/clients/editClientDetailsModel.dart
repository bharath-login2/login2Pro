// To parse this JSON data, do
//
//     final editClientDetailsModel = editClientDetailsModelFromJson(jsonString);

import 'dart:convert';

EditClientDetailsModel editClientDetailsModelFromJson(String str) =>
    EditClientDetailsModel.fromJson(json.decode(str));

String editClientDetailsModelToJson(EditClientDetailsModel data) =>
    json.encode(data.toJson());

class EditClientDetailsModel {
  Data data;
  bool status;
  String message;

  EditClientDetailsModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory EditClientDetailsModel.fromJson(Map<String, dynamic> json) =>
      EditClientDetailsModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  String id;
  String name;
  String emailId;
  String countryCode;
  String contactNo;
  String address1;
  String address2;
  String address3;
  String stateId;
  String districtId;
  String taxType;
  String pincode;
  String gstNum;
  String remarks;
  String postOffice;
  String branchId;
  List<AdditionalField> additionalFields;
  List<IdProofDocument> idProofs;
  String? idProof;
  String? whatsappNumber;
  String? whatsappCountryCode;

  Data({
    required this.id,
    required this.name,
    required this.emailId,
    required this.countryCode,
    required this.contactNo,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.stateId,
    required this.districtId,
    required this.taxType,
    required this.pincode,
    required this.gstNum,
    required this.remarks,
    required this.postOffice,
    required this.branchId,
    required this.additionalFields,
    this.idProofs = const [],
    this.idProof,
    this.whatsappNumber,
    this.whatsappCountryCode,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        emailId: json["email_id"]?.toString() ?? "",
        countryCode: json["country_code"]?.toString() ?? "",
        contactNo: json["contact_no"]?.toString() ?? "",
        address1: json["address1"]?.toString() ?? "",
        address2: json["address2"]?.toString() ?? "",
        address3: json["address3"]?.toString() ?? "",
        stateId: json["stateId"]?.toString() ?? "",
        districtId: json["districtId"]?.toString() ?? "",
        taxType: json["taxType"]?.toString() ?? "",
        pincode: json["pincode"]?.toString() ?? "",
        gstNum: json["gst_num"]?.toString() ?? "",
        remarks: json["remarks"]?.toString() ?? "",
        postOffice: json["post_office"]?.toString() ?? "",
        branchId: json["branch_id"]?.toString() ?? "",
        additionalFields: json["additional_fields"] != null
            ? List<AdditionalField>.from(
                json["additional_fields"].map((x) => AdditionalField.fromJson(x)))
            : [],
        idProofs: json["id_proofs"] != null && json["id_proofs"] is List
            ? List<IdProofDocument>.from(
                json["id_proofs"].map((x) => IdProofDocument.fromJson(
                    x is Map<String, dynamic>
                        ? x
                        : Map<String, dynamic>.from(x))))
            : [],
        idProof: json["id_proof"]?.toString() ??
            json["idProof"]?.toString() ??
            json["id_proof_url"]?.toString() ??
            json["id_proof_file"]?.toString(),
        whatsappNumber: json["whatsapp_no"]?.toString() ??
            json["whatsapp_number"]?.toString() ??
            json["whatsappNumber"]?.toString(),
        whatsappCountryCode: json["whatsapp_country_code"]?.toString() ??
            json["whatsapp_countrycode"]?.toString() ??
            json["whatsappCountryCode"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email_id": emailId,
        "country_code": countryCode,
        "contact_no": contactNo,
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "stateId": stateId,
        "districtId": districtId,
        "taxType": taxType,
        "pincode": pincode,
        "gst_num": gstNum,
        "remarks": remarks,
        "post_office": postOffice,
        "branch_id": branchId,
        "additional_fields":
            List<dynamic>.from(additionalFields.map((x) => x.toJson())),
        "id_proofs": List<dynamic>.from(idProofs.map((x) => x.toJson())),
        "id_proof": idProof,
        "whatsapp_number": whatsappNumber,
        "whatsapp_country_code": whatsappCountryCode,
      };
}

class IdProofDocument {
  String documentId;
  String fileId;
  String fileName;
  String fileUrl;
  String previewUrl;

  IdProofDocument({
    required this.documentId,
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.previewUrl,
  });

  factory IdProofDocument.fromJson(Map<String, dynamic> json) => IdProofDocument(
        documentId: json["document_id"]?.toString() ?? "",
        fileId: json["file_id"]?.toString() ?? "",
        fileName: json["file_name"]?.toString() ?? "",
        fileUrl: json["file_url"]?.toString() ?? "",
        previewUrl: json["preview_url"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "document_id": documentId,
        "file_id": fileId,
        "file_name": fileName,
        "file_url": fileUrl,
        "preview_url": previewUrl,
      };
}

class AdditionalField {
  String fieldId;
  String fieldName;
  String fieldValue;

  AdditionalField({
    required this.fieldId,
    required this.fieldName,
    required this.fieldValue,
  });

  factory AdditionalField.fromJson(Map<String, dynamic> json) =>
      AdditionalField(
        fieldId: json["field_id"]?.toString() ?? "",
        fieldName: json["field_name"]?.toString() ?? "",
        fieldValue: json["field_value"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "field_id": fieldId,
        "field_name": fieldName,
        "field_value": fieldValue,
      };
}
