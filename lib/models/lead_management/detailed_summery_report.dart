class CallReportModel {
  final List<CallReportItem> data;
  final bool status;
  final String message;

  CallReportModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory CallReportModel.fromJson(Map<String, dynamic> json) {
    return CallReportModel(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => CallReportItem.fromJson(item))
              .toList()
          : [],
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class CallReportItem {
  final String staffName;
  final String userId;
  final String branchName;
  final int newLeads;
  final int followupLeads;
  final int rejectedLeads;
  final int closedLeads;
  final int activeLeads;
  final int callConnected;
  final int notConnected;
  final int totalCalled;

  CallReportItem({
    required this.staffName,
    required this.userId,
    required this.branchName,
    required this.newLeads,
    required this.followupLeads,
    required this.rejectedLeads,
    required this.closedLeads,
    required this.activeLeads,
    required this.callConnected,
    required this.notConnected,
    required this.totalCalled,
  });

  factory CallReportItem.fromJson(Map<String, dynamic> json) {
    // Dynamically calculate total called based on metrics
    int newL = json['newLeads'] ?? 0;
    int fUp = json['followupLeads'] ?? 0;
    int rej = json['rejectedLeads'] ?? 0;
    int closed = json['closedLeads'] ?? 0;
    int active = json['activeLeads'] ?? 0;

    return CallReportItem(
      staffName: json['staff_name'] ?? '',
      userId: json['user_id']?.toString() ?? '0',
      branchName: json['branch_name'] ?? '',
      newLeads: newL,
      followupLeads: fUp,
      rejectedLeads: rej,
      closedLeads: closed,
      activeLeads: active,
      callConnected: json['callConnected'] ?? 0,
      notConnected: json['notConnected'] ?? 0,
      totalCalled: newL +
          fUp +
          rej +
          closed +
          active, // automatic summation or override if provided
    );
  }
}
