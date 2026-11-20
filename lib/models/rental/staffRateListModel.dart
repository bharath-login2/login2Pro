class StaffRateListResponse {
  final bool status;
  final String message;
  final List<StaffRate> data;

  StaffRateListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StaffRateListResponse.fromJson(Map<String, dynamic> json) {
    return StaffRateListResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => StaffRate.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class StaffRate {
  final String id;
  final String name;
  final String hourlyRate;
  final String dailyRate;

  StaffRate({
    required this.id,
    required this.name,
    required this.hourlyRate,
    required this.dailyRate,
  });

  factory StaffRate.fromJson(Map<String, dynamic> json) {
    return StaffRate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      hourlyRate: json['hourly_rate']?.toString() ?? '0.00',
      dailyRate: json['daily_rate']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hourly_rate': hourlyRate,
      'daily_rate': dailyRate,
    };
  }
}