// dashboardLeadsCountsModel.dart

class DashboardLeadsCountsModel {
  bool? status;
  String? message;
  Data? data;

  DashboardLeadsCountsModel({
    this.status,
    this.message,
    this.data,
  });

  factory DashboardLeadsCountsModel.fromJson(Map<String, dynamic> json) {
    return DashboardLeadsCountsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
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
  Leads? leads;
  List<Target>? target;

  Data({
    this.leads,
    this.target,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      leads: json['leads'] != null ? Leads.fromJson(json['leads']) : null,
      target: json['target'] != null
          ? List<Target>.from(json['target'].map((x) => Target.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (leads != null) {
      data['leads'] = leads!.toJson();
    }
    if (target != null) {
      data['target'] = target!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}

class Leads {
  int? newLeads;
  int? newToday;
  int? newMissed;
  int? activeLeads;
  int? activeToday;
  int? activeMissed;
  int? closedLeads;
  int? rejectedLeads;
  int? todaysClosed;
  int? thisMonthClosed;
  int? todaysLost;
  int? thisMonthLost;
  int? revenue;
  int? projectPlanning;
  int? designing;
  int? reDesigning;
  int? designSubmit;
  int? estimation;
  int? proposalMade;
  int? negotiation;
  int? totalLeads;

  Leads({
    this.newLeads,
    this.newToday,
    this.newMissed,
    this.activeLeads,
    this.activeToday,
    this.activeMissed,
    this.closedLeads,
    this.rejectedLeads,
    this.todaysClosed,
    this.thisMonthClosed,
    this.todaysLost,
    this.thisMonthLost,
    this.revenue,
    this.projectPlanning,
    this.designing,
    this.reDesigning,
    this.designSubmit,
    this.estimation,
    this.proposalMade,
    this.negotiation,
    this.totalLeads,
  });

  factory Leads.fromJson(Map<String, dynamic> json) {
    return Leads(
      newLeads: json['newLeads'],
      newToday: json['newTodays'],
      newMissed: json['newMissed'],
      activeLeads: json['activeLeads'],
      activeToday: json['activeTodays'],
      activeMissed: json['activeMissed'],
      closedLeads: json['closedLeads'],
      rejectedLeads: json['rejectedLeads'],
      todaysClosed: json['todaysClosed'],
      thisMonthClosed: json['thisMonthClosed'],
      todaysLost: json['todaysRejectedLeads'],
      thisMonthLost: json['thisMonthRejectedLeads'],
      revenue: json['Revenue'],
      projectPlanning: json['projectPlanning'],
      designing: json['designing'],
      reDesigning: json['reDesigning'],
      designSubmit: json['designSubmit'],
      estimation: json['estimation'],
      proposalMade: json['proposalMade'],
      negotiation: json['negotiation'],
      totalLeads: json['totalLeads'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['newLeads'] = newLeads;
    data['newTodays'] = newToday;
    data['newMissed'] = newMissed;
    data['activeLeads'] = activeLeads;
    data['activeToday'] = activeToday;
    data['activeMissed'] = activeMissed;
    data['closedLeads'] = closedLeads;
    data['rejectedLeads'] = rejectedLeads;
    data['todaysClosed'] = todaysClosed;
    data['thisMonthClosed'] = thisMonthClosed;
    data['todaysRejectedLeads'] = todaysLost;
    data['thisMonthRejectedLeads'] = thisMonthLost;
    data['Revenue'] = revenue;
    data['projectPlanning'] = projectPlanning;
    data['designing'] = designing;
    data['reDesigning'] = reDesigning;
    data['designSubmit'] = designSubmit;
    data['estimation'] = estimation;
    data['proposalMade'] = proposalMade;
    data['negotiation'] = negotiation;
    data['totalLeads'] = totalLeads;
    return data;
  }
}

class Target {
  String? groupName;
  String? maxAmount;
  String? achieved;
  String? progressPercentage;

  Target({
    this.groupName,
    this.maxAmount,
    this.achieved,
    this.progressPercentage,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      groupName: json['group_name'],
      maxAmount: json['max_amount'],
      achieved: json['achieved'],
      progressPercentage: json['progress_percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_name'] = groupName;
    data['max_amount'] = maxAmount;
    data['achieved'] = achieved;
    data['progress_percentage'] = progressPercentage;
    return data;
  }
}
