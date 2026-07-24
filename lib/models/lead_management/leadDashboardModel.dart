// To parse this JSON data, do
//
//     final leadDashboardModel = leadDashboardModelFromJson(jsonString);

import 'dart:convert';

LeadDashboardModel leadDashboardModelFromJson(String str) => LeadDashboardModel.fromJson(json.decode(str));

String leadDashboardModelToJson(LeadDashboardModel data) => json.encode(data.toJson());

class LeadDashboardModel {
    Data data;
    bool status;
    String message;

    LeadDashboardModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory LeadDashboardModel.fromJson(Map<String, dynamic> json) => LeadDashboardModel(
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
    int newLeads;
    int followupLeads;
    int closedLeads;
    int totalCalled;
    int missedLeads;
    int transferLeads;
    int revenue;
    int projectPlanning;
    int designing;
    int reDesigning;
    int designSubmit;
    int estimation;
    int proposalMade;
    int negotiation;
    int totalLeads;
    int todaysLost;
    LeadsCount currentLeadsCount;
    LeadsCount previousLeadsCount;
    int unreadNotification;

    Data({
        required this.newLeads,
        required this.followupLeads,
        required this.closedLeads,
        required this.totalCalled,
        required this.missedLeads,
        required this.transferLeads,
        required this.revenue,
        required this.projectPlanning,
        required this.designing,
        required this.reDesigning,
        required this.designSubmit,
        required this.estimation,
        required this.proposalMade,
        required this.negotiation,
        required this.totalLeads,
        required this.todaysLost,
        required this.currentLeadsCount,
        required this.previousLeadsCount,
        required this.unreadNotification,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        newLeads: json["newLeads"],
        followupLeads: json["followupLeads"],
        closedLeads: json["closedLeads"],
        totalCalled: json["totalCalled"],
        missedLeads: json["missedLeads"],
        transferLeads: json["transferLeads"],
        revenue: json["Revenue"] ?? 0,
        projectPlanning: json["projectPlanning"] ?? 0,
        designing: json["designing"] ?? 0,
        reDesigning: json["reDesigning"] ?? 0,
        designSubmit: json["designSubmit"] ?? 0,
        estimation: json["estimation"] ?? 0,
        proposalMade: json["proposalMade"] ?? 0,
        negotiation: json["negotiation"] ?? 0,
        totalLeads: json["totalLeads"] ?? 0,
        todaysLost: json["todaysLost"] ?? 0,
        currentLeadsCount: LeadsCount.fromJson(json["current_leads_count"]),
        previousLeadsCount: LeadsCount.fromJson(json["previous_leads_count"]),
        unreadNotification: json["unread_notification"],
    );

    Map<String, dynamic> toJson() => {
        "newLeads": newLeads,
        "followupLeads": followupLeads,
        "closedLeads": closedLeads,
        "totalCalled": totalCalled,
        "missedLeads": missedLeads,
        "transferLeads": transferLeads,
        "revenue": revenue,
        "projectPlanning": projectPlanning,
        "reDesigning": reDesigning,
        "designSubmit": designSubmit,
        "estimation": estimation,
        "proposalMade": proposalMade,
        "negotiation": negotiation,
        "totalLeads": totalLeads,
        "todaysLost": todaysLost,
        "current_leads_count": currentLeadsCount.toJson(),
        "previous_leads_count": previousLeadsCount.toJson(),
        "unread_notification": unreadNotification,
    };
}

class LeadsCount {
    String total;
    String month;
    String date;

    LeadsCount({
        required this.total,
        required this.month,
        required this.date,
    });

    factory LeadsCount.fromJson(Map<String, dynamic> json) => LeadsCount(
        total: json["total"],
        month: json["month"],
        date: json["date"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "month": month,
        "date": date,
    };
}
