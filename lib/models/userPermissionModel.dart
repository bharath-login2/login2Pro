class UserPermissionModel {
  Data? data;
  bool? status;
  String? message;

  UserPermissionModel({this.data, this.status, this.message});

  UserPermissionModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  String? ProjectDashboard;
  String? LeadDashboard;
  String? AccountsDashboard;
  String? MenuDashboard;
  String? RenewalDashboard;
  String? NewleadDashboard;
  String? QuotationDashboard;
  String? RoomDashboard;
  String? JobCard;
  String? adminCheck;
  String? createStaff;
  String? viewStaff;
  String? updateStaff;
  String? deleteStaff;
  String? viewStaffReport;
  String? createStaffDesignation;
  String? viewStaffDesignation;
  String? updateStaffDesignation;
  String? deleteStaffDesignation;
  String? updateStaffPassword;
  String? updateStaffPermission;
  String? createLead;
  String? viewLead;
  String? updateLead;
  String? deleteLead;
  String? createLeadCategory;
  String? viewLeadCategory;
  String? updateLeadCategory;
  String? deleteLeadCategory;
  String? viewLeadReport;
  String? viewWhatsappSettings;
  String? updateWhatsappSettings;
  String? createFacebookSettings;
  String? updateFacebookSettings;
  String? deleteFacebookSettings;
  String? createLeadImports;
  String? viewTargetReport;
  String? cloudCall;
  String? accessCallHistory;
  String? accessCallRecording;
  String? fileManager;
  String? phoneCallLog;
  String? createFile;
  String? openFile;
  String? renameFile;
  String? deleteFile;
  String? downloadFile;
  String? whatsappUnofficial;
  String? whatsappOfficial;
  String? whatsappMenu;
  String? transferLead;
  String? readRenewal;
  String? readAccount;
  bool? uploadCallLog;
  String? multipleUsers;
  String? multipleWorks;
  String? hasPhonecallAccess;
  String? addWorks;
  String? viewAllWorks;
  String? viewWorkReport;
  String? startAndStopWork;
  String? faceDetection;
  String? companyLocation;
  String? assignWork;
   String? editassignWork;
     String? deleteassignWork;
   String? markAttendance;
  String? addWorkModule;
  String? viewAttendanceSection;
  String? viewPendingWorks;
  String? updateDashboard;
  String? approvePayroll;
  String? proformaInvoiceMenu;
  String? gstInvoiceMenu;
  String? receiptMenu;
  String? pendingInvoiceMenu;
  String? addLeadSource;
  String? leadModule;
  String? accountsModule;
  String? renewalModule;
  String? workModule;
  String? quotationModule;
  String? roomModule;
  String? workWithoutLogin;
  String? addApproveLeave;
  String? rejectRequestLeave;
  String? editLeaveRequest;
  String? deleteLeaveRequest;
  String? voiceListerningPermission;
  String? voiceUploadPermission;
  String? createCustomerInvoice;
  String? createRenewal;
  String? createInstallment;
  String? customerAddPermission;
  String? customerAddInvoicePermission;
  String? viewLeadCategoryOnly;
  String? viewAllCategory;
  String? addAttendanceRemarks;
  Data({
    this.ProjectDashboard,
    this.LeadDashboard,
    this.AccountsDashboard,
    this.MenuDashboard,
    this.RenewalDashboard,
    this.NewleadDashboard,
    this.QuotationDashboard,
    this.RoomDashboard,
    this.JobCard,
    this.adminCheck,
    this.createStaff,
    this.viewStaff,
    this.updateStaff,
    this.deleteStaff,
    this.viewStaffReport,
    this.createStaffDesignation,
    this.viewStaffDesignation,
    this.updateStaffDesignation,
    this.deleteStaffDesignation,
    this.updateStaffPassword,
    this.updateStaffPermission,
    this.createLead,
    this.viewLead,
    this.updateLead,
    this.deleteLead,
    this.createLeadCategory,
    this.viewLeadCategory,
    this.updateLeadCategory,
    this.deleteLeadCategory,
    this.viewLeadReport,
    this.viewWhatsappSettings,
    this.updateWhatsappSettings,
    this.createFacebookSettings,
    this.updateFacebookSettings,
    this.deleteFacebookSettings,
    this.createLeadImports,
    this.viewTargetReport,
    this.cloudCall,
    this.accessCallHistory,
    this.accessCallRecording,
    this.fileManager,
    this.phoneCallLog,
    this.createFile,
    this.openFile,
    this.renameFile,
    this.deleteFile,
    this.downloadFile,
    this.whatsappUnofficial,
    this.whatsappOfficial,
    this.whatsappMenu,
    this.transferLead,
    this.readRenewal,
    this.readAccount,
    this.uploadCallLog,
    this.multipleUsers,
    this.multipleWorks,
    this.hasPhonecallAccess,
    this.addWorks,
    this.viewAllWorks,
    this.viewWorkReport,
    this.startAndStopWork,
    this.faceDetection,
    this.companyLocation,
    this.assignWork,
      this.editassignWork,
      this.deleteassignWork,
    this.markAttendance,
    this.addWorkModule,
    this.viewAttendanceSection,
    this.viewPendingWorks,
    this.updateDashboard,
    this.approvePayroll,
    this.proformaInvoiceMenu,
    this.gstInvoiceMenu,
    this.receiptMenu,
    this.pendingInvoiceMenu,
    this.addLeadSource,
    this.leadModule,
    this.accountsModule,
    this.renewalModule,
    this.workModule,
    this.quotationModule,
    this.roomModule,
    this.workWithoutLogin,
    this.addApproveLeave,
    this.rejectRequestLeave,
    this.editLeaveRequest,
    this.deleteLeaveRequest,
    this.voiceListerningPermission,
    this.voiceUploadPermission,
    this.createCustomerInvoice,
    this.createRenewal,
    this.createInstallment,
    this.customerAddPermission,
    this.customerAddInvoicePermission,
    this.viewLeadCategoryOnly,
    this.viewAllCategory,
    this.addAttendanceRemarks,
  });

  Data.fromJson(Map<String, dynamic> json) {
    ProjectDashboard = json['dashboard_project'];
    LeadDashboard = json['dashboard_lead'];
    AccountsDashboard = json['dashboard_accounts'];
    MenuDashboard = json['dashboard_menu'];
    RenewalDashboard = json['dashboard_renewal'];
    NewleadDashboard = json['dashboard_new_lead'];
    QuotationDashboard = json['dashboard_quotation'];
    RoomDashboard = json['dashboard_room_booking'];
    JobCard = json['dashboard_job_card'];
    adminCheck = json['admins_check'];
    createStaff = json['create_staff'];
    viewStaff = json['view_staff'];
    updateStaff = json['update_staff'];
    deleteStaff = json['delete_staff'];
    viewStaffReport = json['view_staff_report'];
    createStaffDesignation = json['create_staff_designation'];
    viewStaffDesignation = json['view_staff_designation'];
    updateStaffDesignation = json['update_staff_designation'];
    deleteStaffDesignation = json['delete_staff_designation'];
    updateStaffPassword = json['update_staff_password'];
    updateStaffPermission = json['update_staff_permission'];
    createLead = json['create_lead'];
    viewLead = json['view_lead'];
    updateLead = json['update_lead'];
    deleteLead = json['delete_lead'];
    createLeadCategory = json['create_lead_category'];
    viewLeadCategory = json['view_lead_category'];
    updateLeadCategory = json['update_lead_category'];
    deleteLeadCategory = json['delete_lead_category'];
    viewLeadReport = json['view_lead_report'];
    viewWhatsappSettings = json['view_whatsapp_settings'];
    updateWhatsappSettings = json['update_whatsapp_settings'];
    createFacebookSettings = json['create_facebook_settings'];
    updateFacebookSettings = json['update_facebook_settings'];
    deleteFacebookSettings = json['delete_facebook_settings'];
    createLeadImports = json['create_lead_imports'];
    viewTargetReport = json['view_target_report'];
    cloudCall = json['cloud_call'];
    accessCallHistory = json['access_call_history'];
    accessCallRecording = json['access_call_recording'];
    fileManager = json['file_manager'];
    phoneCallLog = json['phone_call_log'];
    createFile = json['create_file'];
    openFile = json['open_file'];
    renameFile = json['rename_file'];
    deleteFile = json['delete_file'];
    downloadFile = json['download_file'];
    whatsappUnofficial = json['whatsapp_unofficial'];
    whatsappOfficial = json['whatsapp_official'];
    whatsappMenu = json['whatsapp_menu'];
    transferLead = json['transfer_lead'];
    readRenewal = json['read_renewal'];
    readAccount = json['read_account'];
    uploadCallLog = json['upload_call_log'];
    multipleUsers = json['multiple_users'];
    multipleWorks = json['multiple_works'];
    hasPhonecallAccess = json['has_phone_call_access'];
    addWorks = json['add_work'];
    viewAllWorks = json['view_all_works'];
    viewWorkReport = json['View_Work_Report'];
    startAndStopWork = json['start_and_stop_work'];
    faceDetection = json['face_detection'];
    companyLocation = json['company_location'];
    assignWork = json['assign_work'];
      editassignWork = json['edit_assign_work'];
      deleteassignWork = json['delete_assign_work'];
    markAttendance = json['mark_attendance'];
    addWorkModule = json['add_work_module'];
    viewAttendanceSection = json['view_attendance'];
    viewPendingWorks = json['view_pending_works'];
    updateDashboard = json['update_dashboard'];
    approvePayroll = json['approve_payroll'];
    proformaInvoiceMenu = json['proforma_invoices_menu'];
    gstInvoiceMenu = json['gst_invoices_menu'];
    receiptMenu = json['receipts_menu'];
    pendingInvoiceMenu = json['pending_invoices_menu'];
    addLeadSource = json['add_lead_source'];
    leadModule = json['lead_management_module'];
    accountsModule = json['accounts_module'];
    renewalModule = json['renewal_management_module'];
    workModule = json['work_management_module'];
    quotationModule = json['quotations_module'];
    roomModule = json['room_management_module'];
    workWithoutLogin = json['work_without_login'];
    addApproveLeave = json['add_approve_leave'];
    rejectRequestLeave = json['reject_leave_request'];
    editLeaveRequest = json['edit_leave_request'];
    deleteLeaveRequest = json['delete_leave_request'];
    voiceListerningPermission = json['voiceListerningPermission'];
    voiceUploadPermission = json['voiceUploadPermission'];
    createCustomerInvoice = json['createCustomerInvoice'];
    createRenewal = json['createRenewal'];
    createInstallment = json['createInstallment'];
    customerAddPermission = json['customerAddPermission'];
    customerAddInvoicePermission = json['customerAddInvoicePermission'];
    viewLeadCategoryOnly = json['viewLeadCategoryOnly'];
    viewAllCategory = json['viewAllCategory'];
    addAttendanceRemarks = json['add_attendance_remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dashboard_project'] = ProjectDashboard;
    data['dashboard_lead'] = LeadDashboard;
    data['dashboard_accounts'] = AccountsDashboard;
    data['dashboard_menu'] = MenuDashboard;
    data['dashboard_renewal'] = RenewalDashboard;
    data['dashboard_new_lead'] = NewleadDashboard;
    data['dashboard_quotation'] = QuotationDashboard;
    data['dashboard_room_booking'] = RoomDashboard;
    data['dashboard_job_card'] = JobCard;
    data['admin_check'] = adminCheck;
    data['create_staff'] = createStaff;
    data['view_staff'] = viewStaff;
    data['update_staff'] = updateStaff;
    data['delete_staff'] = deleteStaff;
    data['view_staff_report'] = viewStaffReport;
    data['create_staff_designation'] = createStaffDesignation;
    data['view_staff_designation'] = viewStaffDesignation;
    data['update_staff_designation'] = updateStaffDesignation;
    data['delete_staff_designation'] = deleteStaffDesignation;
    data['update_staff_password'] = updateStaffPassword;
    data['update_staff_permission'] = updateStaffPermission;
    data['create_lead'] = createLead;
    data['view_lead'] = viewLead;
    data['update_lead'] = updateLead;
    data['delete_lead'] = deleteLead;
    data['create_lead_category'] = createLeadCategory;
    data['view_lead_category'] = viewLeadCategory;
    data['update_lead_category'] = updateLeadCategory;
    data['delete_lead_category'] = deleteLeadCategory;
    data['view_lead_report'] = viewLeadReport;
    data['view_whatsapp_settings'] = viewWhatsappSettings;
    data['update_whatsapp_settings'] = updateWhatsappSettings;
    data['create_facebook_settings'] = createFacebookSettings;
    data['update_facebook_settings'] = updateFacebookSettings;
    data['delete_facebook_settings'] = deleteFacebookSettings;
    data['create_lead_imports'] = createLeadImports;
    data['view_target_report'] = viewTargetReport;
    data['cloud_call'] = cloudCall;
    data['access_call_history'] = accessCallHistory;
    data['access_call_recording'] = accessCallRecording;
    data['file_manager'] = fileManager;
    data['phone_call_log'] = phoneCallLog;
    data['create_file'] = createFile;
    data['open_file'] = openFile;
    data['rename_file'] = renameFile;
    data['delete_file'] = deleteFile;
    data['download_file'] = downloadFile;
    data['multiple_users'] = multipleUsers;
    data['multiple_works'] = multipleWorks;
    data['whatsapp_unofficial'] = whatsappUnofficial;
    data['whatsapp_official'] = whatsappOfficial;
    data['whatsapp_menu'] = whatsappMenu;
    data['add_work'] = addWorks;
    data['view_all_works'] = viewAllWorks;
    data['View_Work_Report'] = viewWorkReport;
    data['start_and_stop_work'] = startAndStopWork;
    data['face_detection'] = faceDetection;
    data['company_location'] = companyLocation;
    data['assign_work'] = assignWork;
      data['edit_assign_work'] = editassignWork;
      data['delete_assign_work'] = deleteassignWork;
    data['mark_attendance'] = markAttendance;
    data['add_work_module'] = addWorkModule;
    data['view_attendance'] = viewAttendanceSection;
    data['view_pending_works'] = viewPendingWorks;
    data['update_dashboard'] = updateDashboard;
    data['approve_payroll'] = approvePayroll;
    data['proforma_invoices_menu'] = proformaInvoiceMenu;
    data['gst_invoices_menu'] = gstInvoiceMenu;
    data['receipts_menu'] = receiptMenu;
    data['pending_invoices_menu'] = pendingInvoiceMenu;
    data['add_lead_source'] = addLeadSource;
    data['lead_management_module'] = leadModule;
    data['accounts_module'] = accountsModule;
    data['renewal_management_module'] = renewalModule;
    data['work_management_module'] = workModule;
    data['quotations_module'] = quotationModule;
    data['room_management_module'] = roomModule;
    data['work_without_login'] = workWithoutLogin;
    data['add_approve_leave'] = addApproveLeave;
    data['reject_leave_request'] = rejectRequestLeave;
    data['edit_leave_request'] = editLeaveRequest;
    data['delete_leave_request'] = deleteLeaveRequest;
    data['voiceListerningPermission'] = voiceListerningPermission;
    data['voiceUploadPermission'] = voiceUploadPermission;
    data['createCustomerInvoice'] = createCustomerInvoice;
    data['createRenewal'] = createRenewal;
    data['createInstallment'] = createInstallment;
    data['customerAddPermission'] = customerAddPermission;
    data['customerAddInvoicePermission'] = customerAddInvoicePermission;
    data['viewLeadCategoryOnly'] = viewLeadCategoryOnly;
    data['viewAllCategory'] = viewAllCategory;
    data['add_attendance_remark'] = addAttendanceRemarks;
    return data;
  }
}
