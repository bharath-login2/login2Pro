class ServiceMandatoryFieldItem {
  final String id;
  final String fieldLabel;
  final String fieldKey;

  ServiceMandatoryFieldItem({
    required this.id,
    required this.fieldLabel,
    required this.fieldKey,
  });

  factory ServiceMandatoryFieldItem.fromJson(Map<String, dynamic> json) {
    return ServiceMandatoryFieldItem(
      id: (json['id'] ?? '').toString(),
      fieldLabel:
          (json['field_label'] ?? json['label'] ?? json['name'] ?? '').toString(),
      fieldKey: (json['field_key'] ?? json['key'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_label': fieldLabel,
      'field_key': fieldKey,
    };
  }
}

class ServiceMandatoryFieldsResponse {
  final bool status;
  final String message;
  final List<ServiceMandatoryFieldItem> data;

  ServiceMandatoryFieldsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ServiceMandatoryFieldsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<ServiceMandatoryFieldItem> list = [];
    if (rawData is List) {
      for (var item in rawData) {
        if (item is Map<String, dynamic>) {
          list.add(ServiceMandatoryFieldItem.fromJson(item));
        } else if (item is Map) {
          list.add(
              ServiceMandatoryFieldItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ServiceMandatoryFieldsResponse(
      status: json['status'] == true ||
          json['status'] == 'true' ||
          json['status'] == 1 ||
          json['status'] == 200,
      message: (json['message'] ?? '').toString(),
      data: list,
    );
  }
}

class MandatoryFieldSelectItem {
  final String id;
  final String field;

  MandatoryFieldSelectItem({
    required this.id,
    required this.field,
  });

  factory MandatoryFieldSelectItem.fromJson(Map<String, dynamic> json) {
    return MandatoryFieldSelectItem(
      id: (json['id'] ?? '').toString(),
      field: (json['field'] ??
              json['field_label'] ??
              json['label'] ??
              json['name'] ??
              '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field': field,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MandatoryFieldSelectItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => field;
}

class MandatoryFieldsSelectResponse {
  final bool status;
  final String message;
  final List<MandatoryFieldSelectItem> data;

  MandatoryFieldsSelectResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MandatoryFieldsSelectResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<MandatoryFieldSelectItem> list = [];
    if (rawData is List) {
      for (var item in rawData) {
        if (item is Map<String, dynamic>) {
          list.add(MandatoryFieldSelectItem.fromJson(item));
        } else if (item is Map) {
          list.add(MandatoryFieldSelectItem.fromJson(
              Map<String, dynamic>.from(item)));
        }
      }
    }
    return MandatoryFieldsSelectResponse(
      status: json['status'] == true ||
          json['status'] == 'true' ||
          json['status'] == 1 ||
          json['status'] == 200,
      message: (json['message'] ?? '').toString(),
      data: list,
    );
  }
}


