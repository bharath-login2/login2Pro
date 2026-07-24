class ProjectListCustModel {
  final bool status;
  final String message;
  final ProjectListData data;

  ProjectListCustModel({required this.status, required this.message, required this.data});

  factory ProjectListCustModel.fromJson(Map<String, dynamic> json) {
    return ProjectListCustModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ProjectListData.fromJson(json['data'] ?? {}),
    );
  }
}

class ProjectListData {
  final List<ProjectExp> list;
  final ProjectPermissions permissions;

  ProjectListData({required this.list, required this.permissions});

  factory ProjectListData.fromJson(Map<String, dynamic> json) {
    return ProjectListData(
      list: (json['list'] as List?)?.map((e) => ProjectExp.fromJson(e)).toList() ?? [],
      permissions: ProjectPermissions.fromJson(json['permissions'] ?? {}),
    );
  }
}

class ProjectPermissions {
  final bool addProject;
  final bool addWorkModule;
  final bool editModule;
  final bool deleteModule;
  final bool deleteProject;
  final bool exportProjectDetailView;
  final bool editProject;
  final bool viewAllProject;
  final bool viewAllAccessibleHandledProject;

  ProjectPermissions({
    required this.addProject,
    required this.addWorkModule,
    required this.editModule,
    required this.deleteModule,
    required this.deleteProject,
    required this.exportProjectDetailView,
    required this.editProject,
    required this.viewAllProject,
    required this.viewAllAccessibleHandledProject,
  });

  factory ProjectPermissions.fromJson(Map<String, dynamic> json) {
    return ProjectPermissions(
      addProject: json['add_project'] == "true",
      addWorkModule: json['add_work_module'] == "true",
      editModule: json['edit_module'] == "true",
      deleteModule: json['delete_module'] == "true",
      deleteProject: json['delete_project'] == "true",
      exportProjectDetailView: json['export_project_detail_view'] == "true",
      editProject: json['edit_project'] == "true",
      viewAllProject: json['view_all_project'] == "true",
      viewAllAccessibleHandledProject: json['view_all_accessible_handled_project'] == "true",
    );
  }
}

class ProjectExp {
  final String id;
  final String projectName;
  final String customerId;
  final String customerName;
  final String? fromDate;
  final String? toDate;
  final String? saveToLocation;

  ProjectExp({
    required this.id,
    required this.projectName,
    required this.customerId,
    required this.customerName,
    this.fromDate,
    this.toDate,
    this.saveToLocation,
  });

  factory ProjectExp.fromJson(Map<String, dynamic> json) {
    return ProjectExp(
      id: json['id']?.toString() ?? '',
      projectName: json['project_name'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      fromDate: json['from_date'],
      toDate: json['to_date'],
      saveToLocation: json['save_to_location'],
    );
  }
}
