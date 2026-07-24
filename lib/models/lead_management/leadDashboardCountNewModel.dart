class DashboardLeadCounts {
  final Data data;
  final bool status;
  final String message;

  DashboardLeadCounts({
    required this.data,
    required this.status,
    required this.message,
  });

  factory DashboardLeadCounts.fromJson(Map<String, dynamic> json) {
    return DashboardLeadCounts(
      data: Data.fromJson(json['data']),
      status: json['status'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'status': status,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'DashboardLeadCounts(data: $data, status: $status, message: $message)';
  }
}

class Data {
  final Leads leads;

  Data({
    required this.leads,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      leads: Leads.fromJson(json['leads']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leads': leads.toJson(),
    };
  }

  @override
  String toString() {
    return 'Data(leads: $leads)';
  }
}

class Leads {
  final int newLeads;
  final int missedLeads;
  final int followupLeads;
  final int closedLeads;
  final int calledCount;
  final int transferLeads;
  final int revenue;
  final int projectPlanning;
  final int designing;

  Leads({
    required this.newLeads,
    required this.missedLeads,
    required this.followupLeads,
    required this.closedLeads,
    required this.calledCount,
    required this.transferLeads,
    required this.revenue,
    required this.projectPlanning,
    required this.designing,
  });

  factory Leads.fromJson(Map<String, dynamic> json) {
    return Leads(
      newLeads: json['newLeads'] ?? 0,
      missedLeads: json['missedLeads'] ?? 0,
      followupLeads: json['followupLeads'] ?? 0,
      closedLeads: json['closedLeads'] ?? 0,
      calledCount: json['calledCount'] ?? 0,
      transferLeads: json['transferLeads'] ?? 0,
      revenue: json['Revenue'] ?? 0,
      projectPlanning: json['projectPlanning'] ?? 0,
      designing: json['designing'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newLeads': newLeads,
      'missedLeads': missedLeads,
      'followupLeads': followupLeads,
      'closedLeads': closedLeads,
      'calledCount': calledCount,
      'transferLeads': transferLeads,
      'revenue': revenue,
      'projectPlanning': projectPlanning,
      'designing': designing,
    };
  }

  @override
  String toString() {
    return 'Leads(newLeads: $newLeads, missedLeads: $missedLeads, followupLeads: $followupLeads, closedLeads: $closedLeads, calledCount: $calledCount, transferLeads: $transferLeads, revenue: $revenue, projectPlanning: $projectPlanning, designing: $designing)';
  }
}
