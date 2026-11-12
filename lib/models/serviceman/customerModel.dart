import 'dart:convert';

class CustomerModelService {
    String status;
    List<CustomerDetails> data;

    CustomerModelService({
        required this.status,
        required this.data,
    });

    factory CustomerModelService.fromRawJson(String str) => CustomerModelService.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustomerModelService.fromJson(Map<String, dynamic> json) => CustomerModelService(
        status: json["status"]?.toString() ?? "",
        data: json["data"] != null && json["data"] is List
            ? List<CustomerDetails>.from(
                json["data"].map((x) => CustomerDetails.fromJson(x)))
            : [],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class CustomerDetails {
    String id;
    String name;
    String contactNo;
    String address;
    String emailId;
    String branchId;
    String branchName;

    CustomerDetails({
        required this.id,
        required this.name,
        required this.contactNo,
        required this.address,
        required this.emailId,
        this.branchId = "",
        this.branchName = "",
    });

    factory CustomerDetails.fromRawJson(String str) => CustomerDetails.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustomerDetails.fromJson(Map<String, dynamic> json) => CustomerDetails(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        contactNo: json["contact_no"]?.toString() ?? "",
        address: json["address"]?.toString() ?? "",
        emailId: json["email_id"]?.toString() ?? "",
        branchId: (json["branch_id"] ?? json["branchId"] ?? "").toString(),
        branchName: (json["branch_name"] ?? json["branchName"] ?? "").toString(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "contact_no": contactNo,
        "address": address,
        "email_id": emailId,
        "branch_id": branchId,
        "branch_name": branchName,
    };
}
