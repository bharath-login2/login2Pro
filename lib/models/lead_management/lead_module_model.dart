class LeadModuleModel {
  bool status;
  String message;
  List<LeadModule> data;

  LeadModuleModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadModuleModel.fromJson(Map<String, dynamic> json) {
    return LeadModuleModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => LeadModule.fromJson(e))
              .toList()
          : [],
    );
  }
}

class LeadModule {
  String id;
  String module;

  LeadModule({
    required this.id,
    required this.module,
  });

  factory LeadModule.fromJson(Map<String, dynamic> json) {
    return LeadModule(
      id: json['id']?.toString() ?? '',
      module: json['module'] ?? '',
    );
  }
}