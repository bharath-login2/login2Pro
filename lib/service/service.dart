import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/backgroundModel.dart';
import 'package:login2/models/clients/addInvoiceGstModel.dart';
import 'package:login2/models/clients/deleteMainClientModel.dart';
import 'package:login2/models/clients/editInvoiceDetailsModelGST.dart';
import 'package:login2/models/clients/editInvoiceDetailsModelTemp.dart';
import 'package:login2/models/clients/hideInvoiceModel.dart';
import 'package:login2/models/clients/invoiceAddCommonDetailsModelGST.dart';
import 'package:login2/models/clients/invoiceAddCommonDetailsModelTemp.dart';
import 'package:login2/models/clients/invoiceListModelGst.dart';
import 'package:login2/models/clients/invoiceListTempModel.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/clients/printInvoiceModel.dart';
import 'package:login2/models/clients/receiptDeleteModel.dart';
import 'package:login2/models/clients/receiptListAccountsModel.dart';
import 'package:login2/models/customers/customerDashboardModel.dart';
import 'package:login2/models/customers/customerHiddenPaymentReport.dart';
import 'package:login2/models/customers/customerLeadModel.dart';
import 'package:login2/models/customers/customerPaymentReportModel.dart';
import 'package:login2/models/customers/customerProjectModel.dart';
import 'package:login2/models/customers/customerQuotationModel.dart';
import 'package:login2/models/customers/customer_payment_response_model.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/expense/account_head_model.dart';
import 'package:login2/models/expense/bank_acc_list.dart';
import 'package:login2/models/expense/commonModel.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/exp_category_list.dart';
import 'package:login2/models/expense/exp_history.dart';
import 'package:login2/models/expense/exp_list.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/models/expense/getProjectListModel.dart';
import 'package:login2/models/expense/pending_expense.dart';
import 'package:login2/models/expense/profit_and_loss_model.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/expense/targetGroupModel.dart';
import 'package:login2/models/groupTargetModel.dart';
import 'package:login2/models/individualTargetModel.dart';
import 'package:login2/models/lead_management/AssignedWorkModel.dart';
import 'package:login2/models/lead_management/TransferWorkResponse.dart';
import 'package:login2/models/lead_management/WorkLoginAndOutModel.dart';
import 'package:login2/models/lead_management/activityModel.dart';
import 'package:login2/models/lead_management/addGoogleDriveResponseModel.dart';
import 'package:login2/models/lead_management/addMileStoneModel.dart';
import 'package:login2/models/lead_management/addModuleModel.dart';
import 'package:login2/models/lead_management/approvedListLeaveModel.dart';
import 'package:login2/models/lead_management/assignedWorkStatusModel.dart';
import 'package:login2/models/lead_management/attendanceAllmodel.dart';
import 'package:login2/models/lead_management/attendanceHistoryModel.dart';
import 'package:login2/models/lead_management/attendnceListModel.dart';
import 'package:login2/models/lead_management/calendarDataModel.dart';
import 'package:login2/models/lead_management/callDataModel.dart';
import 'package:login2/models/lead_management/callStatusReportModel.dart';
import 'package:login2/models/lead_management/callStatusReportOntapModel.dart';
import 'package:login2/models/lead_management/callStatusReportTableModel.dart';
import 'package:login2/models/lead_management/categoryReportModel.dart';
import 'package:login2/models/lead_management/categoryReportTableModel.dart';
import 'package:login2/models/lead_management/categoryWiseLeadBarModel.dart';
import 'package:login2/models/lead_management/cloudCallReportModel.dart';
import 'package:login2/models/lead_management/companyLocationModel.dart';
import 'package:login2/models/lead_management/contentIdModel.dart';
import 'package:login2/models/lead_management/createGoogleFoldersModel.dart';
import 'package:login2/models/lead_management/customerDetailsModel.dart';
import 'package:login2/models/lead_management/customerModel.dart';
import 'package:login2/models/lead_management/dailyAllCountModel.dart';
import 'package:login2/models/lead_management/damagedListApiModel.dart';
import 'package:login2/models/lead_management/dashboardLeadsCountsModel.dart';
import 'package:login2/models/lead_management/deletRentalReturnModel.dart';
import 'package:login2/models/lead_management/deleteGoogleDriveFileModel.dart';
import 'package:login2/models/lead_management/deleteModelOpenstock.dart';
import 'package:login2/models/lead_management/deletePurchaseOrderEditProductModel.dart';
import 'package:login2/models/lead_management/deletePurchaseRequestModel.dart';
import 'package:login2/models/lead_management/deleteQuotationModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/documentListModel.dart';
import 'package:login2/models/lead_management/expenseTypeModel.dart';
import 'package:login2/models/lead_management/expiredListModel.dart';
import 'package:login2/models/lead_management/fileManagerPermissionModel.dart';
import 'package:login2/models/lead_management/getActiveStatusModel.dart';
import 'package:login2/models/lead_management/getArchievedInvoiceModel.dart';
import 'package:login2/models/lead_management/getAttendanceReportModel.dart';
import 'package:login2/models/lead_management/getCheckStockMaterialsModel.dart';
import 'package:login2/models/lead_management/getCompanyInvoiceModel.dart';
import 'package:login2/models/lead_management/getLeadSourceModel.dart';
import 'package:login2/models/lead_management/getLeaveApprovalRejectTemplate.dart';
import 'package:login2/models/lead_management/getLeaveBalanceModel.dart';
import 'package:login2/models/lead_management/getMaterialForStockCunsuptionModel.dart';
import 'package:login2/models/lead_management/getOpeningModel.dart';
import 'package:login2/models/lead_management/getOpenstockForEditModel.dart';
import 'package:login2/models/lead_management/getPurchaseBillDetailsEditModel.dart';
import 'package:login2/models/lead_management/getPurchaseOrderDetailsModel.dart';
import 'package:login2/models/lead_management/getPurchaseRequestDetailsModel.dart';
import 'package:login2/models/lead_management/getPurchaseRequestListModel.dart';
import 'package:login2/models/lead_management/getPurchaseReturnAddListMode.dart';
import 'package:login2/models/lead_management/getPurchaseReturnModel.dart';
import 'package:login2/models/lead_management/getPurchseOrderModel.dart';
import 'package:login2/models/lead_management/getRecentExpenseModel.dart';
import 'package:login2/models/lead_management/getRentReturnModel.dart';
import 'package:login2/models/lead_management/getRentalViewModel.dart';
import 'package:login2/models/lead_management/getStaffDocumentListModel.dart';
import 'package:login2/models/lead_management/getStaffSalaryDetailsModel.dart';
import 'package:login2/models/lead_management/getStockRegisterListModel.dart';
import 'package:login2/models/lead_management/getStockRequestModel.dart';
import 'package:login2/models/lead_management/getSupplierDashboardModel.dart';
import 'package:login2/models/lead_management/getSupplierLedgerModel.dart';
import 'package:login2/models/lead_management/getSupplierListMode.dart';
import 'package:login2/models/lead_management/getTaskListModel.dart';
import 'package:login2/models/lead_management/get_chat_id.dart';
import 'package:login2/models/lead_management/invoiceListHistory.dart';
import 'package:login2/models/lead_management/leadCategoryReportOntapModel.dart';
import 'package:login2/models/lead_management/leadDashboardCountNewModel.dart';
import 'package:login2/models/lead_management/getOpeningModel.dart';
import 'package:login2/models/lead_management/leadExtraSettings.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart';
import 'package:login2/models/lead_management/leadProductsModel.dart';
import 'package:login2/models/lead_management/leadProgressBarStaffModel.dart';
import 'package:login2/models/lead_management/leadProgressBarStatusWise.dart';
import 'package:login2/models/lead_management/leadSourceReportOntapModel.dart';
import 'package:login2/models/lead_management/leadSourceTableModel.dart';
import 'package:login2/models/lead_management/lead_source_report_model.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/lead_management/moduleListModel.dart';
import 'package:login2/models/lead_management/newLeadDashboardModel.dart';
import 'package:login2/models/lead_management/pendingExpenseModel.dart';
import 'package:login2/models/lead_management/pendingListLeaveModel.dart';
import 'package:login2/models/lead_management/pendingListModel.dart';
import 'package:login2/models/lead_management/phoneCallReportModel.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/productDescriptionModel.dart';
import 'package:login2/models/lead_management/productHistoryRental.dart';
import 'package:login2/models/lead_management/productTypeModel.dart';
import 'package:login2/models/lead_management/profile_response_model.dart';
import 'package:login2/models/lead_management/projectDetailsModel.dart';
import 'package:login2/models/lead_management/projectPendingModel.dart';
import 'package:login2/models/lead_management/projectTraceModel.dart';
import 'package:login2/models/lead_management/purchaseBillModel.dart';
import 'package:login2/models/lead_management/qrCodeProductModel.dart';
import 'package:login2/models/lead_management/quotationDetailsModel.dart';
import 'package:login2/models/lead_management/quotationEditModel.dart';
import 'package:login2/models/lead_management/quotationListModel.dart';
import 'package:login2/models/lead_management/quotationRequestDetailsModel.dart';
import 'package:login2/models/lead_management/quotationRequestListModel.dart';
import 'package:login2/models/lead_management/quotationTemplateModel.dart';
import 'package:login2/models/lead_management/quotation_dashboard_model.dart';
import 'package:login2/models/lead_management/recentReceiptModel.dart';
import 'package:login2/models/lead_management/renameGdriveApiModel.dart';
import 'package:login2/models/lead_management/requestCreateResponseModel.dart';
import 'package:login2/models/lead_management/requestDetailsModel.dart';
import 'package:login2/models/lead_management/salaryDetailsModel.dart';
import 'package:login2/models/lead_management/salaryListModel.dart';
import 'package:login2/models/lead_management/showTransferHideorShowModel.dart';
import 'package:login2/models/lead_management/staffAccountDetailsModel.dart';
import 'package:login2/models/lead_management/staffCallSummaryModel.dart';
import 'package:login2/models/lead_management/staffDocumentUploadModel.dart';
import 'package:login2/models/lead_management/staffReportModel.dart';
import 'package:login2/models/lead_management/staffWisePendingModel.dart';
import 'package:login2/models/lead_management/staffWorkSummaryModel.dart';
import 'package:login2/models/lead_management/staff_dashboard_model.dart';
import 'package:login2/models/lead_management/staffwiseCompletedUpdatedModel.dart';
import 'package:login2/models/lead_management/staffwisePendingUpdatedModel.dart';
import 'package:login2/models/lead_management/staffwiseWorkDataCountModel.dart';
import 'package:login2/models/lead_management/stagewiseReportModel.dart';
import 'package:login2/models/lead_management/stagewiseReportOntap.dart';
import 'package:login2/models/lead_management/stagewiseTableModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/models/lead_management/stockCounsumptionListModel.dart';
import 'package:login2/models/lead_management/stockRequestEditDetails.dart';
import 'package:login2/models/lead_management/supplierDetailsModel.dart';
import 'package:login2/models/lead_management/tagListForFilterModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/models/lead_management/unhideInvoiceModel.dart';
import 'package:login2/models/lead_management/unitModel.dart';
import 'package:login2/models/lead_management/unverifiedTransactionModel.dart';
import 'package:login2/models/lead_management/updatePendingList.dart';
import 'package:login2/models/lead_management/uploadGoogleFilesModel.dart';
import 'package:login2/models/lead_management/uploadedQuotationModel.dart';
import 'package:login2/models/lead_management/viewPurcahseBillModel.dart';
import 'package:login2/models/lead_management/workCountModel.dart';
import 'package:login2/models/lead_management/workMessageModel.dart';
import 'package:login2/models/lead_management/workOrderIdModel.dart';
import 'package:login2/models/lead_management/lead_work_details_model.dart';
import 'package:login2/models/officialWhatsapp/campaigns_official_message_model.dart';
import 'package:login2/models/officialWhatsapp/campaign_sample_model.dart';
import 'package:login2/models/officialWhatsapp/message_view_status.dart';
import 'package:login2/models/officialWhatsapp/whatsapp_contact_list.dart';
import 'package:login2/models/product_mannagement/delete_category.dart';
import 'package:login2/models/product_mannagement/delete_product.dart';
import 'package:login2/models/product_mannagement/delete_subcategory.dart';
import 'package:login2/models/product_mannagement/post_category_model.dart';
import 'package:login2/models/product_mannagement/post_product.dart';
import 'package:login2/models/product_mannagement/post_subcategory.dart';
import 'package:login2/models/product_mannagement/product_categories.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:login2/models/product_mannagement/products_by_id_model.dart';
import 'package:login2/models/product_mannagement/sub_categories.dart';
import 'package:login2/models/product_mannagement/update_product.dart';
import 'package:login2/models/product_mannagement/update_subcategory.dart';
import 'package:login2/models/projectCountModel.dart';
import 'package:login2/models/renewal/add_customer_model.dart';
import 'package:login2/models/renewal/bulk_remind.dart';
import 'package:login2/models/renewal/delete_renewal.dart';
import 'package:login2/models/renewal/followup_dashboard_model.dart';
import 'package:login2/models/renewal/renewal_by_id_model.dart';
import 'package:login2/models/renewal/hidden_list.dart';
import 'package:login2/models/renewal/hide_model.dart';
import 'package:login2/models/renewal/payment_report.dart';
import 'package:login2/models/renewal/post_reminder.dart';
import 'package:login2/models/renewal/post_renewal.dart';
import 'package:login2/models/renewal/reminder_history_model.dart';
import 'package:login2/models/renewal/renewal_dashboard_model.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/models/renewal/renewal_followup_details.dart';
import 'package:login2/models/renewal/renewal_followup_list.dart';
import 'package:login2/models/renewal/renewal_list.dart';
import 'package:login2/models/renewal/rivert_client.dart';
import 'package:login2/models/rental/customerRentalProductModel.dart';
import 'package:login2/models/rental/generateInvoiceNumberRentalModel.dart';
import 'package:login2/models/rental/getRentalIssueDetailsModel.dart';
import 'package:login2/models/rental/paymentReportRentalModel.dart';
import 'package:login2/models/rental/rentIdByCustomerReturnModel.dart';
import 'package:login2/models/rental/rentReturnModel.dart';
import 'package:login2/models/rental/rentalCollectedByStaffList.dart';
import 'package:login2/models/rental/rentalCustomerLocations.dart';
import 'package:login2/models/rental/rentalDashbaordModel.dart';
import 'package:login2/models/rental/rentalIssueDetailsModel.dart';
import 'package:login2/models/rental/rentalIssueModel.dart';
import 'package:login2/models/rental/rentalLocationModel.dart';
import 'package:login2/models/rental/rentalReportHistoryModel.dart';
import 'package:login2/models/rental/rentalReturnNumberModel.dart';
import 'package:login2/models/rental/returnDetailsRentalModel.dart';
import 'package:login2/models/roomManagement/editListModel.dart';
import 'package:login2/models/roomManagement/fileUploadModel.dart';
import 'package:login2/models/roomManagement/roomDashboardModel.dart';
import 'package:login2/models/roomManagement/roomListModel.dart';
import 'package:login2/models/roomManagement/roomNumberListModel.dart';
import 'package:login2/models/roomManagement/roomProductsModel.dart';
import 'package:login2/models/roomManagement/roomTypesModel.dart';
import 'package:login2/models/search/search.dart';
import 'package:login2/models/serviceman/currentWorkStatusModel.dart';
import 'package:login2/models/serviceman/customerModel.dart';
import 'package:login2/models/serviceman/getRoleModel.dart';
import 'package:login2/models/serviceman/pushNotificationModel.dart';
import 'package:login2/models/serviceman/receivedThroughModel.dart';
import 'package:login2/models/serviceman/staffModel.dart';
import 'package:login2/models/serviceman/workCategoryGraphModel.dart';
import 'package:login2/models/serviceman/workCategoryModel.dart';
import 'package:login2/models/serviceman/workOrderIdModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'package:login2/models/staff_report/AttendanceStaffwiseModel.dart';
import 'package:login2/models/staff_report/staff_call_details_model.dart';
import 'package:login2/models/staff_report/staff_details_model.dart';
import 'package:login2/models/staff_report/targetReportModel.dart';
import 'package:login2/models/userManagement/companyTargetModel.dart';
import 'package:login2/models/userManagement/editUserBasicDetailsModel.dart';
import 'package:login2/models/renewal/renewal_template_model.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedGstInvoiceList.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedProformaInvoiceList.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedReceiptListModel.dart';
import 'package:login2/screens/accounts/renewal_mannagement/getDeletedInvoiceList.dart';
import 'package:login2/screens/accounts/renewal_mannagement/restoreInvoicesModel.dart';
import 'package:login2/screens/authentication/googleDriveAccountsModel.dart';
import 'package:login2/screens/authentication/googleDriveFilesModel.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/commonsettingsModel.dart';
import '../../models/contactGroup/addContactGroupModel.dart';
import '../../models/contactGroup/addContactNumberModel.dart';
import '../../models/contactGroup/contactFGroupModel.dart';
import '../../models/contactGroup/contactGroupDeatailsModel.dart';
import '../../models/contactGroup/deleteContactNumberModel.dart';
import '../../models/contactGroup/deleteContatGroupModel.dart';
import '../../models/contactGroup/editContactGroupModel.dart';
import '../../models/contactGroup/editContactNumberModel.dart';
import '../../models/contactGroup/groupInfoModel.dart';
import '../../models/contactGroup/sendMessageModel.dart';
import '../../models/dashboardModel.dart';
import '../../models/lead_management/addLeadCategoryModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/addLeadModel.dart';
import '../../models/lead_management/callHistoryModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/deleteLeadFollowupModel.dart';
import '../../models/lead_management/deleteLeadModel.dart';
import '../../models/lead_management/editDesignationDetailsModel.dart';
import '../../models/lead_management/editLeadCategoryModel.dart';
import '../../models/lead_management/editLeadFollowupModel.dart';
import '../../models/lead_management/editLeadModel.dart';
import '../../models/lead_management/followupDetailsModel.dart';
import '../../models/lead_management/leadCategoryDeleteModel.dart';
import '../../models/lead_management/leadDashboardModel.dart';
import '../models/clients/customer_log.dart';
import '../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/leadProgressbarModel.dart';
import '../../models/lead_management/leadTransferModel.dart';
import '../../models/lead_management/searchModel.dart';
import '../../models/lead_management/viewLeadCategoryModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../../models/loginCheckModel.dart';
import '../../models/loginModel.dart';
import '../../models/sendOtpModel.dart';
import '../../models/settings/addWhatsappSettingsModel.dart';
import '../../models/settings/addWhatsappSettingsOffModel.dart';
import '../../models/settings/whatsappSettings%20MOdel.dart';
import '../../models/updateModel.dart';
import '../../models/userChangePassword.dart';
import '../../models/userManagement/addUserCommonDataModel.dart';
import '../../models/userManagement/addUserImageModel.dart';
import '../../models/userManagement/addUserModel.dart';
import '../../models/userManagement/changePasswordModel.dart';
import '../../models/userManagement/deleteStaffModel.dart';
import '../../models/userManagement/designationListModel.dart';
import '../../models/userManagement/menuModel.dart';
import '../../models/userManagement/postEditSubmenuModel.dart';
import '../../models/userManagement/postSubmenuModel.dart';
import '../../models/userManagement/viewStaffModel.dart';
import 'package:dio/dio.dart';
import '../core/common.dart';
import '../core/config.dart';
import '../models/callLogUploadPermissionModel.dart';
import '../models/callLogs/callLogHistoryModel.dart';
import '../models/callLogs/callLogUploadModel.dart';
import '../models/callLogs/callLogUploadPermissionUpdateModel.dart';
import '../models/callLogs/deleteCallHistoryModel.dart';
import '../models/clients/addClientsModel.dart';
import '../models/clients/addInvoiceModel.dart';
import '../models/clients/branchListModel.dart';
import '../models/clients/customerListModel.dart';
import '../models/clients/deleteInvoiceModel.dart';
import '../models/clients/editClientDetailsModel.dart';
import '../models/clients/editClientsModel.dart';
import '../models/clients/editInvoiceDetailsModel.dart';
import '../models/clients/editInvoiceModel.dart';
import '../models/clients/editReceiptDetailsModel.dart';
import '../models/clients/editReceiptModel.dart';
import '../models/clients/getInvoiceSearchData.dart';
import '../models/clients/invoiceListModel.dart';
import '../models/clients/ivoiceAddCommonDetailsModel.dart';
import '../models/clients/leadConvertToClientModel.dart';
import '../models/clients/mainClientDetailsModel.dart';
import '../models/clients/mainClientListModel.dart';
import '../models/clients/pendingInvoiceListModel.dart';
import '../models/clients/postalCodeModel.dart';
import '../models/clients/receiptAddCommonDetailsModel.dart';
import '../models/clients/receiptAddModel.dart';
import '../models/clients/receiptByInvModel.dart';
import '../models/clients/receiptFileDeleteModel.dart';
import '../models/clients/receiptListModel.dart';
import '../models/clients/viewReceiptPdfModel.dart';
import '../models/complaints/add_item_model.dart';
import '../models/complaints/delete_model.dart';
import '../models/complaints/details_model.dart';
import '../models/complaints/get_model.dart';
import '../models/complaints/list_model.dart';
import '../models/complaints/post_model.dart';
import '../models/complaints/post_remark_model.dart';
import '../models/complaints/update_model.dart';
import '../models/fileManager/deleteFileModel.dart';
import '../models/fileManager/fileMagerMOdel.dart';
import '../models/fileManager/mainFileManagerPermissionModel.dart';
import '../models/fileManager/renameFileModel.dart';
import '../models/lead_management/BulkTransferLeadModel.dart';
import '../models/lead_management/TransferLeadModel.dart';
import '../models/lead_management/addBulkContactGroupModel.dart';
import '../models/lead_management/addLeadFollowupModel.dart';
import '../models/lead_management/addLeadSubCategoryModel.dart';
import '../models/lead_management/bulkDeleteLeadModel.dart';
import '../models/lead_management/callResultResonModel.dart';
import '../models/lead_management/checkLeadPhoneNumberModel.dart';
import '../models/lead_management/createFolderModel.dart';
import '../models/lead_management/deleteFolderAndFileModel.dart';
import '../models/lead_management/deleteLeadMileStoneModel.dart';
import '../models/lead_management/deleteLeadVoiceModel.dart';
import '../models/lead_management/delete_notification.dart';
import '../models/lead_management/editLeadSubCategoryModel.dart';
import '../models/lead_management/leadCategoryStaffWiseModel.dart';
import '../models/lead_management/leadDetailsModelAdd.dart' hide CallHistory;
import '../models/lead_management/leadMileStoneListModel.dart';
import '../models/lead_management/leadNotificationListModel.dart';
import '../models/lead_management/leadSubCategoryDeleteModel.dart';
import '../models/lead_management/leadSubTypeModel.dart';
import '../models/lead_management/listFolderName.dart';
import '../models/lead_management/projectList_model.dart';
import '../models/lead_management/readLeadNotificationModel.dart';
import '../models/lead_management/renameFolderModel.dart';
import '../models/lead_management/submitresponse_model.dart';
import '../models/lead_management/testListApiModel.dart';
import '../models/lead_management/timeDetailsModel.dart';
import '../models/lead_management/titleListModel.dart';
import '../models/lead_management/unsetReminderModel.dart';
import '../models/lead_management/updateReminderSetings.dart';
import '../models/lead_management/uploadAudioRecoed.dart';
import '../models/lead_management/viewLeadSubCategoryModel.dart';
import '../models/lead_management/workDetailsCompanyModel.dart';
import '../models/lead_management/workDetailsModel.dart';
import '../models/lead_management/workstatus_model.dart';
import '../models/officialWhatsapp/chat_list_model.dart';
import '../models/officialWhatsapp/addContactModel.dart';
import '../models/officialWhatsapp/campaignsListModel.dart';
import '../models/officialWhatsapp/mediaModel.dart';
import '../models/officialWhatsapp/official_message_model.dart';
import '../models/officialWhatsapp/officialWhatsappConfigureModel.dart';
import '../models/officialWhatsapp/sendMesaageModel.dart';
import '../models/officialWhatsapp/sendTemplateMesaageModel.dart';
import '../models/officialWhatsapp/template_content_model.dart';
import '../models/officialWhatsapp/templateModel.dart';
import '../models/removeUserModel.dart';
import '../models/resetPasswordModel.dart';
import '../models/serviceman/customerTypeModel.dart';
import '../models/serviceman/workModel.dart';
import '../models/settings/deleteFbLeadsModel.dart';
import '../models/settings/facebookSettingsModel.dart';
import '../models/settings/sendNotificationModel.dart';
import '../models/settings/updateFbLeadAssignStaff.dart';
import '../models/staff_report/staff_calls_model.dart';
import '../models/userManagement/deleteDesignationModel.dart';
import '../models/userManagement/postEditStaffPermissionModel.dart';
import '../models/userManagement/postEditStaffSubmenuModel.dart';
import '../models/userManagement/staffDetailsModel.dart';
import '../models/Product_mannagement/checkBarcodeDuplicateModel.dart';
import '../models/userPermissionModel.dart';
import '../models/verifyPhoneModel.dart';
import 'package:login2/models/lead_management/lead_module_model.dart';
class HttpService {
  static final Dio _dio = Dio();

  static Future configure(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}check_package_expired",
          // options: Options(receiveTimeout: const Duration(microseconds: 30)),
          queryParameters: params);
      if (kDebugMode) {}
      CommonConfigureModel model = CommonConfigureModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future backgroundData(body) async {
    try {
      var result = await _dio.get("${await Config.getUrl()}getClientName",
          queryParameters: body);
      if (kDebugMode) {}
      BackgroundModel model = BackgroundModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future forceUpdate() async {
    try {
      var result = await _dio.get(
        "https://account.login2.in/apiAuth.php",
        // options: Options(receiveTimeout: const Duration(seconds: 30)),
      );
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        UpdateModel model = UpdateModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future commonSettings() async {
    try {
      var result = await _dio.get(
        "${await Config.getUrl()}contact_us",
      );
      CommonSettingsModel model = CommonSettingsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future login(
    String username,
    String pass,
    String firebaseToken,
    String? faceData, {
    String? deviceName,
    String? platform,
    String? osVersion,
    String? mobileName,
  }) async {
    log("${await Config.getUrl()}login");
    var params = {
      "phoneNumber": username,
      "password": pass,
      "firebaseId": firebaseToken,
      "faceData": faceData ?? "",
      "mobile_series": mobileName ?? "",
      "platform": platform ?? "",
      "platform_version": osVersion ?? "",
      "mobile_name": deviceName ?? "",
    };
    log("Firebase Token: $firebaseToken");
    try {
      var result = await _dio.get("${await Config.getUrl()}login",
          queryParameters: params);
      if (result.statusCode == 200) {
        LoginModel model = LoginModel.fromJson(result.data);
        var token = result.data["data"]["token"];
        log("Login Token: $token");
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  // static Future loginCheck(token, firebaseToken) async {
  //    var params = {"token": token, "firebaseId": firebaseToken};
  //   try {
  //     var result = await _dio.get("${await Config.getUrl()}if_token_expired",
  //         queryParameters: params);
  //     LoginCheckModel model = LoginCheckModel.fromJson(result.data);
  //     return model;
  //   } catch (e) {
  //     log("error: $e");

  //   }
  // }

//   static Future loginCheck(token, firebaseToken) async {
//   var params = {"token": token, "firebaseId": firebaseToken};
//   try {
//     final baseUrl = await Config.getUrl();
//     final url = "${baseUrl}if_token_expired";

//     log("Final request URL: $url");
//     log("Query parameters: $params");

//     var result = await _dio.get(
//       url,
//       queryParameters: params,
//     );

//     LoginCheckModel model = LoginCheckModel.fromJson(result.data);
//     return model;
//   } catch (e) {
//     log("error: $e");
//   }
// }

  static Future<LoginCheckModel?> loginCheck(
      String? token, String firebaseToken) async {
    var params = {
      if (token != null && token.isNotEmpty) "token": token,
      "firebaseId": firebaseToken,
    };
    try {
      final baseUrl = await Config.getUrl();
      if (baseUrl.isEmpty) {
        log("❌ Base URL is empty. Check SharedPreferences or configuration.");
        return null;
      }
      log("🔗 Calling: ${baseUrl}if_token_expired");
      log("📦 Params: $params");
      var result =
          await _dio.get("${baseUrl}if_token_expired", queryParameters: params);

      if (result.data != null) {
        log("✅ API Response: ${result.data}");
        return LoginCheckModel.fromJson(result.data);
      } else {
        log("❌ No data received from API");
        return null;
      }
    } catch (e, stackTrace) {
      log("❌ Dio error: $e");
      log("🧵 Stack trace: $stackTrace");
      return null;
    }
  }

  static Future mobileDetails({
    String? deviceName,
    String? platform,
    String? osVersion,
    String? mobileName,
  }) async {
    var params = {
      "mobile_series": mobileName ?? "",
      "platform": platform ?? "",
      "platform_version": osVersion ?? "",
      "mobile_name": deviceName ?? "",
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}mobile_details",
          queryParameters: params);
      return result.data;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future sendOtp(phoneNumber, otp, String type) async {
    var params = {"phoneNumber": phoneNumber, "otp": otp, "type": type};
    try {
      var result = await _dio.get("${await Config.getUrl()}send_otp",
          queryParameters: params);
      SendOtpModel model = SendOtpModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadDashboard(
      token, fromDate, toDate, fromDate1, toDate1) async {
    log(token);
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_dashboard",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      LeadDashboardModel model = LeadDashboardModel.fromJson(result.data);
      print("Lead Dashboard Data: ${result.data}");
      return model;
    } catch (e) {
      log(e.toString());
    }
  }

  static Future leadDashboardNew(
    token,
    fromDate,
    toDate,
    fromDate1,
    toDate1,
    String leadType,
  ) async {
    log(token);
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
      "leadType": leadType,
    };
    try {
      var result = await _dio.get(
        "${await Config.getUrl()}lead_dashboard_new",
        options: Options(receiveTimeout: const Duration(seconds: 30)),
        queryParameters: params,
      );
      NewLeadDashboard model = NewLeadDashboard.fromJson(result.data);
      return model;
    } catch (e) {
      log(e.toString());
    }
  }

  static Future leadDashboard1(token, fromDate, toDate, fromDate1, toDate1,
      {List<String>? staffIds}) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
    };
    if (staffIds != null && staffIds.isNotEmpty) {
      if (staffIds.length == 1) {
        params["staffId"] = staffIds.first;
      } else {
        params["staffId"] = staffIds.join(',');
      }
    }
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}lead_category_staff_wise",
          queryParameters: params);
      LeadCategoryStaffWiseModel model =
          LeadCategoryStaffWiseModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadDashboardStaff(
      token, fromDate, toDate, fromDate1, toDate1, staffId) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
      "staffId": staffId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}staff_dashboard",
          queryParameters: params);
      StaffDashboardModel model = StaffDashboardModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadDashboard1Staff(
      token, fromDate, toDate, fromDate1, toDate1, staffId) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
      "staffId": staffId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}staff_lead_category_wise",
          queryParameters: params);
      LeadCategoryStaffWiseModel model =
          LeadCategoryStaffWiseModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future allViewLeads(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}view_total_lead_report",
          data: jsonEncode(body));
      ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future transferLeadReport(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}view_transfer_lead_history",
          data: jsonEncode(body));
      TransferLeadModel model = TransferLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeads(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}view_lead_report",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsforNew(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportStatusNew",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsforNewToday(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportStatusNewTodays",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsforNewMissed(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportStatusNewMissed",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsforActive(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportStatusFollowup",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsforActiveNew(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}getActiveLeads",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadReport(body) async {
    print(body);
    try {
      var result = await _dio.post("${await Config.getUrl()}leadReport",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadReportAll(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportByCreatedDate",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadReportCallStatus(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportCallStatus",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadReportActiveStatus(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportActiveStatus",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadReportLeadSource(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportLeadSource",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadReportLeadCategory(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}leadReportLeadCategory",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        print(result.data);
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsSts(token, fromdate, todate, type, id, status, sort,
      page, pageSize, isFirst, branchId,search) async {
    var params = {
      "token": token,
      "fromDate": fromdate,
      "toDate": todate,
      "type": type,
      "id": id,
      "status": status,
      "sort": sort,
      "page": page,
      "pageSize": pageSize,
      "isFirst": isFirst,
      "branchId": branchId,
      "search": search,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}view_category_staff_wise_lead_report",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadCommonData(token, {branchId}) async {
    var params = {"token": token, "branchId": branchId};
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}lead_management_master_data",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);

      if (result.statusCode == 200) {
        AddLeadCommonDataModel model =
            AddLeadCommonDataModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getState() async {
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}get_states",
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: {},
      );

      if (result.statusCode == 200) {
        StateModel model = StateModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getDistrict(stateId) async {
    try {
      var formData = FormData.fromMap({
        'state_id': stateId,
      });

      var result = await _dio.post(
        "${await Config.getUrl()}get_districts",
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (result.statusCode == 200) {
        DistrictModel model = DistrictModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadsNew(
      token,
      branchId,
      clientName,
      leadType,
      leadSubType,
      contactNo,
      staffId,
      cost,
      priorityId,
      address,
      pinCode,
      postOffice,
      remark,
      callResultId,
      callResponseId,
      nextFollowupDate,
      descriptions,
      code,
      checked,
      timeBefore,
      leadSource,
      {String? stateId,
      String? districtId,
      String? products,
      String? whatsappNumber,
      String? whatsappnumber_country_code,
      String? email}) async {
    var formData = FormData.fromMap({
      'token': token,
      'branchId': branchId,
      'next_followup_date': nextFollowupDate,
      'call_result_id': callResultId,
      'call_response_id': callResponseId,
      'lead_category_id': leadType,
      'lead_sub_category_id': leadSubType,
      'clientName': clientName,
      'contactNumber': contactNo,
      'whatsapp_number': whatsappNumber ?? '',
      'whatsapp_country_code': whatsappnumber_country_code ?? '',
      'email': email ?? '',
      'address': address,
      'pinCode': pinCode,
      "postOffice": postOffice,
      'cost': cost,
      'user_id': staffId,
      'remarks': remark,
      'priority': priorityId,
      'country_code': code,
      "additionalFields": jsonEncode(descriptions),
      "reminder": checked,
      "time_before": timeBefore,
      "lead_source_id": leadSource,
      'state_id': stateId ?? '',
      'district_id': districtId ?? '',
      'products': products ?? '',
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}add_leads_updated",
          data: formData);
      AddLeadModel model = AddLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeads(
      token,
      branchId,
      clientName,
      leadType,
      leadSubType,
      contactNo,
      staffId,
      cost,
      priorityId,
      address,
      pinCode,
      postOffice,
      remark,
      callResultId,
      callResponseId,
      nextFollowupDate,
      descriptions,
      code,
      checked,
      timeBefore,
      leadSource,
      {String? stateId,
      String? districtId,
      String? products,
      String? whatsappNumber,
      String? whatsappnumber_country_code,
      String? email}) async {
    var formData = FormData.fromMap({
      'token': token,
      'branchId': branchId,
      'next_followup_date': nextFollowupDate,
      'call_result_id': callResultId,
      'call_response_id': callResponseId,
      'lead_category_id': leadType,
      'lead_sub_category_id': leadSubType,
      'clientName': clientName,
      'contactNumber': contactNo,
      'whatsapp_number': whatsappNumber ?? '',
      'whatsapp_country_code': whatsappnumber_country_code ?? '',
      'email': email ?? '',
      'address': address,
      'pinCode': pinCode,
      "postOffice": postOffice,
      'cost': cost,
      'user_id': staffId,
      'remarks': remark,
      'priority': priorityId,
      'country_code': code,
      "additionalFields": jsonEncode(descriptions),
      "reminder": checked,
      "time_before": timeBefore,
      "lead_source_id": leadSource,
      'state_id': stateId ?? '',
      'district_id': districtId ?? '',
      'products': products ?? '',
    });

    try {
      var result =
          await _dio.post("${await Config.getUrl()}add_leads", data: formData);
      AddLeadModel model = AddLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsCategory(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_category",
          queryParameters: params);
      ViewLeadCategoryModel model = ViewLeadCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadCategory(token, categoryName) async {
    var params = {
      "token": token,
      "leadCategory": categoryName,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}add_lead_category",
          queryParameters: params);
      AddLeadCategoryModel model = AddLeadCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeadCategory(token, categoryName, categoryId) async {
    var params = {
      "token": token,
      "leadCategory": categoryName,
      'leadCategoryId': categoryId
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}edit_lead_category",
          queryParameters: params);
      EditLeadCategoryModel model = EditLeadCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadCategory(token, categoryId) async {
    var params = {
      "token": token,
      "leadCategoryId": categoryId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}delete_lead_category",
          queryParameters: params);
      LeadCategoryDeleteModel model =
          LeadCategoryDeleteModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsSubCategory(token, categoryId) async {
    var params = {"token": token, "leadCategoryId": categoryId};
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_sub_category",
          queryParameters: params);
      ViewLeadSubCategoryModel model =
          ViewLeadSubCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadSubCategory(token, categoryName, categoryId) async {
    var params = {
      "token": token,
      "leadSubCategory": categoryName,
      "leadCategoryId": categoryId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}add_lead_sub_category",
          queryParameters: params);
      AddLeadSubCategoryModel model =
          AddLeadSubCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeadSubCategory(
      token, subCategoryName, subCategoryId) async {
    var params = {
      "token": token,
      "leadSubCategory": subCategoryName,
      'leadSubCategoryId': subCategoryId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}edit_lead_sub_category",
          queryParameters: params);
      EditLeadSubCategoryModel model =
          EditLeadSubCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadSubCategory(token, subCategoryId) async {
    var params = {
      "token": token,
      "leadSubCategoryId": subCategoryId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}delete_lead_sub_category",
          queryParameters: params);
      LeadSubCategoryDeleteModel model =
          LeadSubCategoryDeleteModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadSubType(categoryId) async {
    var params = {
      "leadCategoryId": categoryId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}get_sub_categories",
          queryParameters: params);
      LeadSubTypeModel model = LeadSubTypeModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadDetails(token, callMasterId) async {
    var params = {
      "token": token,
      "call_master_id": callMasterId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_details",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);

      if (result.statusCode == 200) {
        LeadDeatailsModel model = LeadDeatailsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadsFollowup(
      token,
      callResultId,
      nextFollowupDate,
      cost,
      address,
      leadTypeId,
      leadSubType,
      remarks,
      callMasterId,
      calledDate,
      callHistoryId,
      priorityId,
      checked,
      timeBefore,
      callResponseId,
      reasonId,
      createSales,
      createType,
      checkIdVal,
      invoiceDate,
      productList,
      reminderTemplate,
      totalAmount,
      startDate,
      endDate,
      paymentStatus,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      paymentMethod,
      paidAmount,
      collectedStaff,
      isDiff,
      renProducts,
      targetGroup,
      {String? products,
      bool? createCustomer,
      String? whatsappLead,
      String? emailLead}) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResultId,
      "lead_category_id": leadTypeId,
      "lead_sub_category_id": leadSubType,
      "cost": cost,
      "remarks": remarks,
      "call_master_id": callMasterId,
      "called_date": calledDate,
      "cloud_call_id": callHistoryId,
      "address": address,
      "priority": priorityId,
      "reminder": checked,
      "time_before": timeBefore,
      "call_response_id": callResponseId,
      "reason_id": reasonId,
      "create_sales": createSales,
      "create_type": createType,
      "check_id_val": checkIdVal,
      "invoice_date": invoiceDate,
      "product_list": jsonEncode(productList),
      "reminder_template": reminderTemplate,
      "total_amount_paid": totalAmount,
      "start_date": startDate,
      "end_date": endDate,
      "payment_status": paymentStatus,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "payment_method": paymentMethod,
      "amount_paid_customer": paidAmount,
      "collected_staff": collectedStaff,
      "next_cost_diff": isDiff,
      "next_renewal_product": jsonEncode(renProducts),
      "target_group": jsonEncode(targetGroup),
      "products_lead": products ?? '', // Pass lead selected products
      "whatsapp_number_lead": whatsappLead ?? '',
      "email_lead": emailLead ?? '',
      if (createCustomer != null) "create_customer": createCustomer,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}add_lead_followup",
          data: formData);
      if (result.statusCode == 200) {
        AddLeadFollowupModel model = AddLeadFollowupModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadsFollowupUpdated(
      token,
      callResultId,
      nextFollowupDate,
      cost,
      address,
      leadTypeId,
      leadSubType,
      remarks,
      callMasterId,
      calledDate,
      callHistoryId,
      priorityId,
      checked,
      timeBefore,
      callResponseId,
      reasonId,
      createSales,
      createType,
      checkIdVal,
      invoiceDate,
      productList,
      reminderTemplate,
      totalAmount,
      startDate,
      endDate,
      paymentStatus,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      paymentMethod,
      paidAmount,
      collectedStaff,
      isDiff,
      renProducts,
      targetGroup,
      descriptions,
      {String? products,
      bool? createCustomer,
      String? whatsappLead,
      String? emailLead}) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResultId,
      "lead_category_id": leadTypeId,
      "lead_sub_category_id": leadSubType,
      "cost": cost,
      "remarks": remarks,
      "call_master_id": callMasterId,
      "called_date": calledDate,
      "cloud_call_id": callHistoryId,
      "address": address,
      "priority": priorityId,
      "reminder": checked,
      "time_before": timeBefore,
      "call_response_id": callResponseId,
      "reason_id": reasonId,
      "create_sales": createSales,
      "create_type": createType,
      "check_id_val": checkIdVal,
      "invoice_date": invoiceDate,
      "product_list": jsonEncode(productList),
      "reminder_template": reminderTemplate,
      "total_amount_paid": totalAmount,
      "start_date": startDate,
      "end_date": endDate,
      "payment_status": paymentStatus,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "payment_method": paymentMethod,
      "amount_paid_customer": paidAmount,
      "collected_staff": collectedStaff,
      "next_cost_diff": isDiff,
      "next_renewal_product": jsonEncode(renProducts),
      "target_group": jsonEncode(targetGroup),
      "additionalFields": jsonEncode(descriptions),
      "products_lead": products ?? '', // Pass lead selected products
      "whatsapp_number_lead": whatsappLead ?? '',
      "email_lead": emailLead ?? '',
      if (createCustomer != null) "create_customer": createCustomer,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}add_lead_followup_updated",
          data: formData);
      if (result.statusCode == 200) {
        AddLeadFollowupModel model = AddLeadFollowupModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postConfirmedFollowup(
      callMasterId,
      invoiceRemarks,
      renewalRemarks,
      createType,
      checkIdVal,
      invoiceDate,
      productList,
      reminderTemplate,
      totalAmount,
      startDate,
      endDate,
      paymentStatus,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      paymentMethod,
      paidAmount,
      collectedStaff,
      isDiff,
      renProducts,
      targetGroup,
      {String? callResultId,
      String? callResponseId,
      String? nextFollowupDate}) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "invoice_remarks": invoiceRemarks,
      "renewal_remarks": renewalRemarks,
      "call_master_id": callMasterId,
      "create_type": createType,
      "check_id_val": checkIdVal,
      "invoice_date": invoiceDate,
      "product_list": jsonEncode(productList),
      "reminder_template": reminderTemplate,
      "total_amount_paid": totalAmount,
      "start_date": startDate,
      "end_date": endDate,
      "payment_status": paymentStatus,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "payment_method": paymentMethod,
      "amount_paid_customer": paidAmount,
      "collected_staff": collectedStaff,
      "next_cost_diff": isDiff,
      "next_renewal_product": jsonEncode(renProducts),
      "target_group": jsonEncode(targetGroup),
      "next_followup_date": nextFollowupDate ?? '',
      "call_result_id": callResultId ?? '',
      "call_response_id": callResponseId ?? '',
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postConfirmedFollowup",
          data: formData);
      if (result.statusCode == 200) {
        AddLeadFollowupModel model = AddLeadFollowupModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeadsFollowup(
      token,
      callFollowupId,
      callResultId,
      nextFollowupDate,
      cost,
      leadTypeId,
      leadSubTypeId,
      remarks,
      calledDate,
      callMasterId,
      callResponseId,
      reasonId,
      {String? whatsappLead,
      String? emailLead,
      String? products}) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResultId,
      "lead_category_id": leadTypeId,
      "lead_sub_category_id": leadSubTypeId,
      "cost": cost,
      "remarks": remarks,
      "call_details_id": callFollowupId,
      "called_date": calledDate,
      'call_master_id': callMasterId,
      'call_response_id': callResponseId,
      'reason_id': reasonId,
      "whatsapp_number_lead": whatsappLead ?? '',
      "email_lead": emailLead ?? '',
      "products_lead": products ?? '',
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}edit_lead_followup",
          data: formData);
      EditLeadFollowupModel model = EditLeadFollowupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeadsFollowupUpdated(
      token,
      callFollowupId,
      callResultId,
      nextFollowupDate,
      cost,
      leadTypeId,
      leadSubTypeId,
      remarks,
      calledDate,
      callMasterId,
      callResponseId,
      reasonId,
      bool checked,
      String? timeBefore,
      descriptions,
      {String? whatsappLead,
      String? emailLead,
      String? products}) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResultId,
      "lead_category_id": leadTypeId,
      "lead_sub_category_id": leadSubTypeId,
      "cost": cost,
      "remarks": remarks,
      "call_details_id": callFollowupId,
      "called_date": calledDate,
      'call_master_id': callMasterId,
      'call_response_id': callResponseId,
      'reason_id': reasonId,
      "is_reminder": checked ? "1" : "0",
      "reminder_time": timeBefore ?? "",
      "whatsapp_number_lead": whatsappLead ?? '',
      "email_lead": emailLead ?? '',
      "products_lead": products ?? '',
      "additionalFields": jsonEncode(descriptions),
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}edit_lead_followup_updated",
          data: formData);
      EditLeadFollowupModel model = EditLeadFollowupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadFollowup(token, followupId, callMasterId) async {
    var formData = FormData.fromMap({
      "token": token,
      'call_master_id': callMasterId,
      "call_details_id": followupId,
    });

    try {
      var result = await _dio
          .post("${await Config.getUrl()}delete_lead_followup", data: formData);
      DeleteLeadFollowModel model = DeleteLeadFollowModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeads(
      token,
      callMasterId,
      branchId,
      clientName,
      leadType,
      leadSubTypeId,
      contactNo,
      staffId,
      cost,
      priorityId,
      address,
      pinCode,
      postOffice,
      remark,
      callResultId,
      callResponseId,
      nextFollowupDate,
      reminder,
      timeBefore,
      descriptions,
      code,
      leadSource,
      {String? stateId,
      String? districtId,
      String? products,
      String? whatsappNumber,
      String? whatsappnumber_country_code,
      String? email}) async {
    var formData = FormData.fromMap({
      'token': token,
      'branchId': branchId,
      'next_followup_date': nextFollowupDate,
      'call_result_id': callResultId,
      'call_response_id': callResponseId,
      'reminder': reminder,
      'time_before': timeBefore,
      'lead_category_id': leadType,
      'lead_sub_category_id': leadSubTypeId,
      'clientName': clientName,
      'contactNumber': contactNo,
      'whatsapp_number': whatsappNumber ?? '',
      'whatsapp_country_code': whatsappnumber_country_code ?? '',
      'email': email ?? '',
      'address': address,
      'pinCode': pinCode,
      "postOffice": postOffice,
      'cost': cost,
      'user_id': staffId,
      'remarks': remark,
      'priority': priorityId,
      'call_master_id': callMasterId,
      'country_code': code,
      "additionalFields": jsonEncode(descriptions),
      "lead_source_id": leadSource,
      'state_id': stateId ?? '',
      'district_id': districtId ?? '',
      'products': products ?? '',
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}edit_lead_updated",
          data: formData);

      EditLeadModel model = EditLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadTransfer(
      token, callMasterId, staff, remark, transferFresh) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
      "staff_id": staff,
      "remarks": remark,
      "transfer_fresh": transferFresh
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}transfer_leads",
          data: formData);
      LeadTransferModel model = LeadTransferModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future followupDetails(token, callDetailsId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_details_id": callDetailsId,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}get_lead_followup_details",
          data: formData);
      FollowupDetailsModel model = FollowupDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadProgressbar(token, fromDate, toDate, callStatus,
      {List<String>? staffIds}) async {
    Map<String, dynamic> map = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "callStatus": callStatus,
    };
    if (staffIds != null && staffIds.isNotEmpty) {
      if (staffIds.length == 1) {
        map["staffId"] = staffIds.first;
      } else {
        map["staffId"] = staffIds.join(',');
      }
    }
    var formData = FormData.fromMap(map);

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}lead_progressbar_data",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future newleadProgressbar(token, fromDate, toDate, callStatus,
      {List<String>? staffIds}) async {
    Map<String, dynamic> map = {
      "token": token,
      "fromDate": "",
      "toDate": "",
      "callStatus": "",
    };
    if (staffIds != null && staffIds.isNotEmpty) {
      if (staffIds.length == 1) {
        map["staffId"] = staffIds.first;
      } else {
        map["staffId"] = staffIds.join(',');
      }
    }
    var formData = FormData.fromMap(map);

    try {
      var result = await _dio
          .post("${await Config.getUrl()}new_lead_progressbar", data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future followupleadProgressbar(token, fromDate, toDate, callStatus,
      {List<String>? staffIds}) async {
    Map<String, dynamic> map = {
      "token": token,
      "fromDate": "",
      "toDate": "",
      "callStatus": "",
    };
    if (staffIds != null && staffIds.isNotEmpty) {
      if (staffIds.length == 1) {
        map["staffId"] = staffIds.first;
      } else {
        map["staffId"] = staffIds.join(',');
      }
    }
    var formData = FormData.fromMap(map);

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}followup_lead_progressbar",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future missedleadProgressbar(token, fromDate, toDate, callStatus,
      {List<String>? staffIds}) async {
    Map<String, dynamic> map = {
      "token": token,
      "fromDate": "",
      "toDate": "",
      "callStatus": "",
    };
    if (staffIds != null && staffIds.isNotEmpty) {
      if (staffIds.length == 1) {
        map["staffId"] = staffIds.first;
      } else {
        map["staffId"] = staffIds.join(',');
      }
    }
    var formData = FormData.fromMap(map);

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}missed_lead_progressbar",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future calledleadProgressbar(token, fromDate, toDate, callStatus,
      {List<String>? staffIds}) async {
    Map<String, dynamic> map = {
      "token": token,
      "fromDate": "",
      "toDate": "",
      "callStatus": "",
    };
    if (staffIds != null && staffIds.isNotEmpty) {
      if (staffIds.length == 1) {
        map["staffId"] = staffIds.first;
      } else {
        map["staffId"] = staffIds.join(',');
      }
    }
    var formData = FormData.fromMap(map);

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}called_lead_progressbar",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future transferredleadProgressbar(token, fromDate, toDate, callStatus,
      {List<String>? staffIds}) async {
    Map<String, dynamic> map = {
      "token": token,
      "fromDate": "",
      "toDate": "",
      "callStatus": "",
    };
    if (staffIds != null && staffIds.isNotEmpty) {
      if (staffIds.length == 1) {
        map["staffId"] = staffIds.first;
      } else {
        map["staffId"] = staffIds.join(',');
      }
    }
    var formData = FormData.fromMap(map);

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}transferred_lead_progressbar",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadProgressbarStaff(
      token, fromDate, toDate, callStatus, staffId) async {
    var formData = FormData.fromMap({
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "callStatus": callStatus,
      "staffId": staffId,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}staff_lead_progressbar_data",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLead(token, callMasterId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}delete_lead_master",
          data: formData);
      DeleteLeadModel model = DeleteLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future bulkDeleteLead(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}lead_bulk_delete",
          data: jsonEncode(body));

      BulkDeleteLeadModel model = BulkDeleteLeadModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future bulkTransferLead(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}bulk_transfer_leads",
          data: jsonEncode(body));

      BulkTransferLeadModel model = BulkTransferLeadModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addBulkContactGroup(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}lead_bulk_message",
          data: jsonEncode(body));

      AddBulkContactGroupModel model =
          AddBulkContactGroupModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addCloudCall(token, callMasterId, phoneNumber) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
      "phoneNumber": phoneNumber,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}add_cloud_call",
          data: formData);
      // t(result);
      CloudCallModel model = CloudCallModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callHistory(token, userId, fromDate, toDate,
      {String? callType}) async {
    //t(userId);
    var formData = FormData.fromMap({
      "token": token,
      "staff_id": userId,
      "fromDate": fromDate,
      "toDate": toDate,
      "callType": callType ?? "",
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}call_history",
          data: formData);
      //t(result);
      CallHistoryModel model = CallHistoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future searchLead(token, search) async {
    var params = {
      "token": token,
      "searchKey": search,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}search_lead_clients",
          queryParameters: params);
      SearchModel model = SearchModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future menuList(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}get_package_menus",
          queryParameters: params);
      MenuModel model = MenuModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editMenuList(token, designationId) async {
    var formData = FormData.fromMap({
      "token": token,
      "designation_id": designationId,
    });

    try {
      var result = await _dio
          .post("${await Config.getUrl()}designation_details", data: formData);
      //t(result);
      EditDesignationDetailsModel model =
          EditDesignationDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postSubMenu(body) async {
    //t(body);
    try {
      var result = await _dio.post("${await Config.getUrl()}post_designation",
          data: jsonEncode(body));

      PostSubmenuModel model = PostSubmenuModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postEditSubMenu(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}edit_designation",
          data: jsonEncode(body));

      PostEditSubmenuModel model = PostEditSubmenuModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postEditStaffSubMenu(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}edit_staff_modules",
          data: jsonEncode(body));

      PostEditStaffSubmenuModel model =
          PostEditStaffSubmenuModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postEditStaffPermission(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}edit_staff_permissions",
          data: jsonEncode(body));

      PostEditStaffPermissionModel model =
          PostEditStaffPermissionModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future designationList(token) async {
    var params = {
      "token": token,
    };

    try {
      var result = await _dio.get(
          "${await Config.getUrl()}get_designation_list",
          queryParameters: params);

      DesignationListModel model = DesignationListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewStaffs(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });

    try {
      var result =
          await _dio.post("${await Config.getUrl()}staff_list", data: formData);
      ViewStaffModel model = ViewStaffModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addUserCommonData(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}userDetailsData",
          data: formData);
      AddUserCommonDataModel model =
          AddUserCommonDataModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  // static Future postUserData(body) async {
  //   try {
  //     var result = await _dio.post("${await Config.getUrl()}add_staff",
  //         data: jsonEncode(body));
  //     AddUserModel model = AddUserModel.fromJson(result.data);
  //     return model;
  //   } catch (e) {
  //     log("error: $e");
  //   }
  // }
  static Future<AddUserModel> postUserData(FormData formData) async {
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}add_staff",
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      AddUserModel model = AddUserModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");

      return AddUserModel(
        status: false,
        message: 'Failed to add user: $e',
      );
    }
  }

  static Future editUserBasicData(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}update_staff",
          data: jsonEncode(body));
      EditUserBasicDetailsModel model =
          EditUserBasicDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future uploadImages(formData) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}add_staff_image",
          data: formData);
      AddUserImageModel model = AddUserImageModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateStaffImage(formData) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}update_staff_image",
          data: formData);
      AddUserImageModel model = AddUserImageModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteStaff(staffId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
      "staffUserId": staffId,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}delete_staff",
          data: formData);

      DeleteStaffModel model = DeleteStaffModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future changePassword(token, confirmPassword, staffUserId) async {
    var formData = FormData.fromMap({
      "token": token,
      "staffUserId": staffUserId,
      "password": confirmPassword,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}change_staff_password",
          data: formData);
      ChangePasswordModel model = ChangePasswordModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future staffDetails(token, staffId) async {
    var params = {"token": token, "staff_id": staffId};
    try {
      var result = await _dio.get("${await Config.getUrl()}staff_details",
          queryParameters: params);
      StaffDetailsModel model = StaffDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* User Management Ends Here..*/
/* Settings Starts Hers */
  static Future whatsappSettings(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}get_whatsapp_settings",
          queryParameters: params);

      WhatsappSettingsModel model = WhatsappSettingsModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addWhatsappSettings(
      accessToken, instanceId, token, phoneNumber) async {
    var params = {
      "accessToken": accessToken,
      "instanceId": instanceId,
      "token": token,
      "phoneNumber": phoneNumber
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_unofficial_whatsapp",
          queryParameters: params);

      AddWhatsappSettingsModel model =
          AddWhatsappSettingsModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addWhatsappSettingsOffical(
      phoneNumberId, accountId, token, permanentToken) async {
    var params = {
      "accountId": accountId,
      "permanentToken": permanentToken,
      "token": token,
      "phoneNumberId": phoneNumberId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_official_whatsapp",
          queryParameters: params);

      AddWhatsappSettingsOffModel model =
          AddWhatsappSettingsOffModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future mainDashboard(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });
    try {
      log("${await Config.getUrl()}get_active_package");
      var result = await _dio.post("${await Config.getUrl()}get_active_package",
          data: formData);
      if (result.statusCode == 200) {
        DashboardModel model = DashboardModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  Future<String?> apiViewPdf(String id, String type) async {
    final token = await Common.getSharedPref("token");
    try {
      final formData =
          FormData.fromMap({"token": token, "id": id, "type": type});
      final response = await _dio.post(
        "${await Config.getUrl()}api_view_pdf",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/quotation_$id.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      log("apiViewPdf error: $e");
      return null;
    }
  }

  static Future changeUserPassword(token, password) async {
    var formData = FormData.fromMap({
      "token": token,
      "password": password,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}reset_password",
          data: formData);
      UserChangePasswordModel model =
          UserChangePasswordModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future contactGroup(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_contact_group",
          data: formData);

      ContactGroupModel model = ContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future contactGroupDetails(token, id) async {
    var formData = FormData.fromMap({
      "token": token,
      "group_id": id,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_group_messages",
          data: formData);
      ContactGroupDeatailsModel model =
          ContactGroupDeatailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future sendWhatsappBulkMessage(formData) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}send_bulk_message",
          data: formData);

      SendMessageModel model = SendMessageModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addContactGroup(token, groupName, numbers) async {
    var formData = FormData.fromMap({
      "token": token,
      "group_name": groupName,
      "contact_numbers": numbers,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}add_new_contact_group",
          data: formData);

      AddContactGroupModel model = AddContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future groupInfo(token, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "group_id": groupId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_group_details",
          data: formData);
      GroupInfoModel model = GroupInfoModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editContactGroupName(token, groupName, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contact_group_name": groupName,
      "contact_group_id": groupId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}update_group_name",
          data: formData);
      EditContactGroupModel model = EditContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteContactGroup(token, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contact_group_id": groupId,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}delete_contact_group", data: formData);
      DeleteContactGroupModel model =
          DeleteContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addContactNumber(token, numbers, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contact_group_id": groupId,
      "contact_numbers": numbers,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}add_contact_numbers", data: formData);
      AddContactNumberModel model = AddContactNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editContactNumber(token, number, contactNumberId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contct_number_id": contactNumberId,
      "contact_number": number,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}edit_contact_number", data: formData);
      EditContactNumberModel model =
          EditContactNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteContactNumber(token, id) async {
    var formData = FormData.fromMap({
      "token": token,
      "contct_number_id": id,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}delete_contact_number",
          data: formData);

      DeleteContactNumberModel model =
          DeleteContactNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* Contact Group Ends Here...*/

  static Future verifyPhone(phoneNumber) async {
    var params = {
      "phoneNumber": phoneNumber,
    };
    try {
      log("${await Config.getUrl()}verify_phone");
      var result = await _dio.get("${await Config.getUrl()}verify_phone",
          queryParameters: params);
      if (result.statusCode == 200) {
        VerifyPhoneModel model = VerifyPhoneModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
      Common.toastMessaage("Something went wrong", Colors.red);
    }
  }

  static Future resetPassword(phoneNumber, password) async {
    var params = {
      "phoneNumber": phoneNumber,
      "password": password,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}forgot_password",
          queryParameters: params);
      ResetPasswordModel model = ResetPasswordModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future removeUser(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_user",
          queryParameters: params);
      RemoveUserModel model = RemoveUserModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future createFolder(token, callMaterId, path) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}createFolder",
          data: formData);
      CreateFolderModel model = CreateFolderModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future uploadRecord(
      token, callMaterId, path, uploadFile, fileName) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
      "file_name": fileName,
      "uploadFile": await MultipartFile.fromFile(uploadFile),
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}uploadFile", data: formData);
      UploadAudioRecord model = UploadAudioRecord.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future listFolderAndFiles(token, callMaterId, path) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}getUploads", data: formData);
      if (result.statusCode == 200) {
        ListFolderNameModel model = ListFolderNameModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadFolderAndFiles(
      token, callMasterId, path, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      'call_master_id': callMasterId,
      "path": path,
      "row_id": rawId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteUploads",
          data: formData);
      DeleteFolderAndFileModel model =
          DeleteFolderAndFileModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future renameFolder(
      token, callMaterId, path, prevName, newName, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
      "prev_name": prevName,
      "new_name": newName,
      "row_id": rawId
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}renameUploadedFile",
          data: formData);
      RenameFolderModel model = RenameFolderModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fetchData(page, pageSize) async {
    var params = {"page": page, "pageSize": pageSize};

    try {
      var result = await _dio.get("${await Config.getUrl()}view_leads_test",
          queryParameters: params);
      TestListApiModel model = TestListApiModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future listAddonDet(token, callMaterId) async {
    var params = {"token": token, "call_master_id": callMaterId};

    try {
      var result = await _dio.get("${await Config.getUrl()}lead_details_data",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      if (result.statusCode == 200) {
         print('client_id: $result');
        LeadDeatailsModelAdd model = LeadDeatailsModelAdd.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadFollowupData(token, callMaterId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}lead_details_followUpData",
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        LeadFollowupData model = LeadFollowupData.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future<CallHistoryResponse?> callDetailsData(
      token, callMasterId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}lead_details_callHistory",
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        return CallHistoryResponse.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }
    return null;
  }

  static Future<ActivityDetails?> activityMode(token, callMasterId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}lead_details_activities",
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        return ActivityDetails.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }
    return null;
  }

  static Future fileManagerPermission(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}file_manager_data",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      FileManagerPermissionModel model =
          FileManagerPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateReminder(token, detailsId, checked, time) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_details_id": detailsId,
      "reminder": checked,
      "time_before": time,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}update_followup_reminder",
          data: formData);
      UpdateReminderSetting model = UpdateReminderSetting.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteDesignation(token, designationId) async {
    var params = {
      "token": token,
      "designation_id": designationId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_designation",
          queryParameters: params);
      DeleteDesignationModel model =
          DeleteDesignationModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fileManagerPermissionMain(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}file_manager_permission",
          queryParameters: params);
      MainFileManagerPermissionModel model =
          MainFileManagerPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future mainListFolderAndFiles(token, path) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": path,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getUploadsData",
          data: formData);
      FileManagerModel model = FileManagerModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fileUpload(token, folderName, uploadFile, fileName) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": folderName,
      "file_name": fileName,
      "uploadFile": await MultipartFile.fromFile(uploadFile),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}uploadNewFile",
          data: formData);
      UploadAudioRecord model = UploadAudioRecord.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future renameFile(token, folderName, prevName, newName, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": folderName,
      "prev_name": prevName,
      "new_name": newName,
      "row_id": rawId
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}renameFile", data: formData);
      RenameFileModel model = RenameFileModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteFiles(token, folderName, fileName, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": folderName,
      "fileName": fileName,
      "row_id": rawId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteUploadFile",
          data: formData);
      DeleteFileModel model = DeleteFileModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future unsetReminder(token, callDetailsId) async {
    var params = {
      "token": token,
      "call_details_id": callDetailsId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}unset_reminder",
          queryParameters: params);
      UnsetReminderModel model = UnsetReminderModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fbDetails(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}fbSettingDetails",
          queryParameters: params);
      FacebookSettingsModel model = FacebookSettingsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateAssignStaffFbLead(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}update_fb_lead_assigned_staff",
          data: jsonEncode(body));
      UpdateFbLeadAssignStaff model =
          UpdateFbLeadAssignStaff.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteFbLeads(token, fbLeadId) async {
    var params = {
      "token": token,
      "fb_settings_id": fbLeadId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_fb_settings",
          queryParameters: params);
      DeleteFbLeadsModel model = DeleteFbLeadsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future sendLeadNotification(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}update_push_notification_staff",
          data: jsonEncode(body));
      SendNotificationModel model = SendNotificationModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogUpload(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}add_phone_call_log",
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        CallLogUploadModel model = CallLogUploadModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogHistory(token, fromDate, toDate, staffId,
      {String? callType}) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "staffId": staffId,
      "callType": callType ?? "",
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}get_phone_call_log",
          queryParameters: params);
      CallLogHistoryModel model = CallLogHistoryModel.fromJson(result.data);
      if (result.statusCode == 200) {
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteCallHistoryLogs(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}delete_phone_call_log",
          data: jsonEncode(body));
      DeleteCallHistoryModel model =
          DeleteCallHistoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future mainClients(
      token, searchKey, fromDate, toDate, page, pageSize) async {
    var params = {
      "token": token,
      "search_key": searchKey,
      "from_date": fromDate == "From Date" ? "" : fromDate,
      "to_date": toDate == "To Date" ? "" : toDate,
      "page": page,
      "page_size": pageSize
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}mainClientList",
          queryParameters: params);
      if (result.statusCode == 200) {
        MainClientListModel model = MainClientListModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future mainClientDetails(token, clientId) async {
    var params = {"token": token, "clientId": clientId};
    try {
      var result = await _dio.get("${await Config.getUrl()}mainClientDetails",
          queryParameters: params);
      if (result.statusCode == 200) {
        MainClientDetailsModel model =
            MainClientDetailsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteMainClients(token, clientId) async {
    var params = {"token": token, "client_id": clientId};
    try {
      var result = await _dio.get("${await Config.getUrl()}deleteMainClients",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteMainClientModel model =
            DeleteMainClientModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadConvertToClient(token, leadId, addCustomField) async {
    var params = {
      "token": token,
      "lead_id": leadId,
      "add_custom_fields": addCustomField
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}convert_lead",
          queryParameters: params);
      LeadConvertToClientModel model =
          LeadConvertToClientModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addClients(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}postClient", data: body);
      AddClientsModel model = AddClientsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceCommonDetails(token, clientId) async {
    var params = {
      "token": token,
      "client_id": clientId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getInvoiceDetails",
          queryParameters: params);
      InvoiceAddCommonDetailsModel model =
          InvoiceAddCommonDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceCommonDetailsTemp(token, clientId) async {
    var params = {
      "token": token,
      "client_id": clientId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}getInvoiceDetailsTemp",
          queryParameters: params);
      InvoiceAddCommonDetailsModelTemp model =
          InvoiceAddCommonDetailsModelTemp.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceCommonDetailsGst(token, clientId) async {
    var params = {
      "token": token,
      "client_id": clientId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}getInvoiceDetailsGST",
          queryParameters: params);
      InvoiceAddCommonDetailsModelGST model =
          InvoiceAddCommonDetailsModelGST.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addInvoice(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}postInvoice", data: body);

      if (result.statusCode == 200) {
        AddInvoiceModel model = AddInvoiceModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addInvoiceUpdated(Map<String, dynamic> body) async {
    try {
      final formData = FormData.fromMap(body);
      var result = await _dio.post(
        "${await Config.getUrl()}postInvoiceUpdated",
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (result.statusCode == 200) {
        AddInvoiceModel model = AddInvoiceModel.fromJson(result.data);
        return model;
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e, stack) {
      log("Error in addInvoiceUpdated: $e\n$stack");
    }
  }

  static Future addInvoiceProforma(body) async {
    try {
      var result = await _dio
          .post("${await Config.getUrl()}postInvoiceProforma", data: body);

      if (result.statusCode == 200) {
        AddInvoiceModel model = AddInvoiceModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editInvoice(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}updateInvoice", data: body);

      EditInvoiceModel model = EditInvoiceModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future gstInvoice(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}gstInvoice", data: body);
      AddInvoiceGSTModel model = AddInvoiceGSTModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editInvoiceTemp(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}updateInvoiceTemp",
          data: body);

      EditInvoiceModel model = EditInvoiceModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editInvoiceGst(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}updateInvoiceGST",
          data: body);

      EditInvoiceModel model = EditInvoiceModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  // static Future invoiceList(
  //   String token,
  //   String fromDate,
  //   String toDate,
  //   String clientId,
  //   String collectedByStaffIds,
  //   String createdByStaffIds,
  //   String staff,
  //   String statusName,
  //   String type,
  // ) async {
  //   var formData = FormData.fromMap({
  //     'token': token,
  //     'from_date': fromDate,
  //     'to_date': toDate,
  //     'client_id': clientId,
  //     'collected_by': collectedByStaffIds,
  //     'created_by': createdByStaffIds,
  //     'staff_id': staff,
  //     'status_name': statusName,
  //     'invoice_type': type
  //   });
  //   try {
  //     var result = await _dio.post("${await Config.getUrl()}getInvoiceLists",
  //         data: formData);
  //     InvoiceListModel model = InvoiceListModel.fromJson(result.data);
  //     return model;
  //   } catch (e) {
  //     log("error: $e");
  //   }
  // }
  static Future invoiceList(
    String token,
    String custId,
    String fromDash,
    String fromDate,
    String toDate,
    String clientId,
    String collectedByStaffIds,
    String createdByStaffIds,
    String staffId,
    String statusName,
    String type,
  ) async {
    var formData = FormData.fromMap({
      'token': token,
      'cust_id': custId,
      'from_dashboard': fromDash,
      'from_date': fromDate,
      'to_date': toDate,
      'client_id': clientId,
      'collected_by': collectedByStaffIds,
      // 'created_by_staff_ids': createdByStaffIds,
      'created_by': staffId,
      'status_name': statusName,
      'invoice_type': type
    });
    print('Sending to API:');
    print('client_id: $clientId');
    print('collected_by_staff_ids: $collectedByStaffIds');
    print('created_by_staff_ids: $createdByStaffIds');
    print('staff_id: $staffId');
    print('status_name: $statusName');
    print('invoice_type: $type');

    try {
      var result = await _dio.post("${await Config.getUrl()}getInvoiceLists",
          data: formData);
      InvoiceListModel model = InvoiceListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceListTemp(
    String token,
    String isDash,
    String status,
    String custId,
    String fromDate,
    String toDate,
    String clientId,
    String collectedBy,
    String createdBy,
    String staff,
    String type,
    String statusFilter,
  ) async {
    var formData = FormData.fromMap({
      'token': token,
      'from_dashboard': isDash,
      'status': status,
      'cust_id': custId,
      'from_date': fromDate,
      'to_date': toDate,
      'client_id': clientId,
      'collected_by': collectedBy,
      'created_by': createdBy,
      'staff_id': staff,
      'invoice_type': type,
      'status': statusFilter
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}getInvoiceListsTemp", data: formData);
      InvoiceListModelTemp model = InvoiceListModelTemp.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  // static Future invoiceListGst(
  //     token, fromDate, toDate, clientId, staff, type) async {
  //   var formData = FormData.fromMap({
  //     'token': token,
  //     'from_date': fromDate,
  //     'to_date': toDate,
  //     'client_id': clientId,
  //     'collected_by': staff,
  //     'invoice_type': type
  //   });
  //   try {
  //     var result = await _dio.post("${await Config.getUrl()}getInvoiceListsGST",
  //         data: formData);
  //     InvoiceListModelGST model = InvoiceListModelGST.fromJson(result.data);
  //     return model;
  //   } catch (e) {
  //     log("error: $e");
  //   }
  // }
  static Future<InvoiceListModelGST?> invoiceListGst(
    String token,
    String fromDate,
    String toDate,
    String clientId,
    String collectedBy,
    String createdBy,
    String staff,
    String type,
  ) async {
    var formData = FormData.fromMap({
      'token': token,
      'from_date': fromDate,
      'to_date': toDate,
      'client_id': clientId,
      'collected_by': collectedBy,
      'created_by': createdBy,
      'staff_id': staff,
      'invoice_type': type
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}getInvoiceListsGST",
          data: formData);
      InvoiceListModelGST model = InvoiceListModelGST.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
      return null;
    }
  }

  static Future pendingInvoiceList(token, customerId) async {
    var formData = FormData.fromMap({
      'token': token,
      'client_id': customerId,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getPendingInvoiceLists",
          data: formData);
      PendingInvoiceListModel model =
          PendingInvoiceListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteInvoice(token, invoiceId) async {
    var params = {"token": token, "invoice_id": invoiceId};
    try {
      var result = await _dio.get("${await Config.getUrl()}deleteInvoice",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteInvoiceModel model = DeleteInvoiceModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future<HideInvoiceModel?> hideInvoice(
    String token,
    String invoiceId,
  ) async {
    try {
      final formData = FormData.fromMap({
        "token": token,
        "invoice_id": invoiceId,
      });

      final result = await _dio.post(
        "${await Config.getUrl()}hide_invoice",
        data: formData,
      );

      if (result.statusCode == 200 && result.data is Map<String, dynamic>) {
        return HideInvoiceModel.fromJson(result.data);
      }
    } catch (e, s) {
      log("hideInvoice error: $e");
      log("stacktrace: $s");
    }
    return null;
  }

  static Future deleteInvoiceTemp(token, invoiceId) async {
    var params = {"token": token, "invoice_id": invoiceId};
    try {
      var result = await _dio.get("${await Config.getUrl()}deleteInvoiceTemp",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteInvoiceModel model = DeleteInvoiceModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteInvoiceGst(token, invoiceId) async {
    var params = {"token": token, "invoice_id": invoiceId};
    try {
      var result = await _dio.get("${await Config.getUrl()}deleteInvoiceGST",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteInvoiceModel model = DeleteInvoiceModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future customerList(
    token,
  ) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getCustomerLists",
          queryParameters: params);
      CustomerListModel model = CustomerListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getInvoiceSearch(
    token,
  ) async {
    var formData = FormData.fromMap({"token": token});
    try {
      var result = await _dio
          .post("${await Config.getUrl()}getInvoiceSearchData", data: formData);
      GetInvoiceSearchData model = GetInvoiceSearchData.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getInvoiceSearchTemp(
    token,
  ) async {
    var formData = FormData.fromMap({"token": token});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getInvoiceSearchDataTemp",
          data: formData);
      GetInvoiceSearchData model = GetInvoiceSearchData.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getInvoiceSearchGst(
    token,
  ) async {
    var formData = FormData.fromMap({"token": token});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getInvoiceSearchDataGST",
          data: formData);
      GetInvoiceSearchData model = GetInvoiceSearchData.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future receptList(token, custId, fromDash, fromDate, toDate, page,
      pageSize, headId, searchKey, type) async {
    var formData = FormData.fromMap({
      'token': token,
      'cust_id': custId,
      'from_dashboard': fromDash,
      'from_date': fromDate == "From Date" ? "" : fromDate,
      'to_date': toDate == "To Date" ? "" : toDate,
      'page': page,
      'page_size': pageSize,
      'head_id': headId,
      'search_key': searchKey,
      "type": type
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getReceiptLists",
          data: formData);
      if (result.statusCode == 200) {
        ReceiptListModel model = ReceiptListModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceReceptList(token, invoiceId) async {
    var formData = FormData.fromMap({'token': token, 'invoice_id': invoiceId});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getInvoiceReceiptLists",
          data: formData);
      ReceiptByInvModel model = ReceiptByInvModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteReceipt(token, receiptId) async {
    var formData = FormData.fromMap({
      'token': token,
      'receipt_id': receiptId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteReceipt",
          data: formData);
      if (result.statusCode == 200) {
        ReceiptDeleteModel model = ReceiptDeleteModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future receiptCommonDetails(token, clientId, invoiceId) async {
    var params = {
      "token": token,
      "client_id": clientId,
      "invoice_id": invoiceId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getReceiptDetails",
          queryParameters: params);
      ReceiptAddCommonDetailsModel model =
          ReceiptAddCommonDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editClientDetails(token, clientId) async {
    var params = {"token": token, "clientId": clientId};

    try {
      var result = await _dio.get("${await Config.getUrl()}getClientById",
          queryParameters: params);
      EditClientDetailsModel model =
          EditClientDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editClients(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}updateClient", data: body);
      EditClientsModel model = EditClientsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  // static Future fetchPostOffice(postalCode) async {
  //   try {
  //     var result =
  //         // ignore: prefer_interpolation_to_compose_strings
  //         await _dio.get("https://api.postalpincode.in/pincode/" + postalCode);
  //     PostalCodeModel model = PostalCodeModel.fromJson(result.data[0]);
  //     return model;
  //   } catch (e) {
  //     log("error: $e");
  //   }
  // }

  static Future<PostalCodeModel> fetchPostOffice(postalCode) async {
    try {
      FormData formData = FormData.fromMap({
        'id': postalCode,
      });

      var result = await _dio.post("${await Config.getUrl()}get_post_office",
          data: formData);

      if (result.data is List && result.data.isNotEmpty) {
        return PostalCodeModel.fromJson(result.data[0]);
      } else {
        return PostalCodeModel(
            message: "No details found", status: "Error", postOffice: []);
      }
    } catch (e) {
      log('Error in fetchPostOffice: $e');
      return PostalCodeModel(
          message: "Error loading post office: $e",
          status: "Error",
          postOffice: []);
    }
  }

  static Future addReceipt(
      token,
      invoiceId,
      clientId,
      receiptNumber,
      receiptDate,
      paidAmount,
      collectedBy,
      paymentMethod,
      templateImage,
      targetGroup) async {
    var formData = FormData.fromMap({
      'token': token,
      'invoice_id': invoiceId,
      'client_id': clientId,
      'receipt_number': receiptNumber,
      'receipt_date': receiptDate,
      'paid_amount': paidAmount,
      'collected_staff': collectedBy,
      'payment_method': paymentMethod,
      'upload_file': templateImage != null
          ? await MultipartFile.fromFile(templateImage.toString())
          : '',
      "target_group": jsonEncode(targetGroup),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}postReceipt",
          data: formData);
      if (result.statusCode == 200) {
        ReceiptAddModel model = ReceiptAddModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editReceiptDetails(token, receiptId) async {
    var params = {
      "token": token,
      "receipt_id": receiptId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getReceiptById",
          queryParameters: params);
      EditReceiptModelDetailsModel model =
          EditReceiptModelDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editReceipt(token, receiptId, receiptDate, paidAmount,
      collectedBy, paymentMethod, templateImage, targetGroup) async {
    var formData = FormData.fromMap({
      'token': token,
      'receipt_id': receiptId,
      'receipt_date': DateFormat("dd-MM-yyyy")
          .format(DateTime.parse(receiptDate.toString())),
      'paid_amount': paidAmount,
      'collected_staff': collectedBy,
      'payment_method': paymentMethod,
      'upload_file': templateImage != null
          ? await MultipartFile.fromFile(templateImage.toString())
          : '',
      "target_group": jsonEncode(targetGroup)
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}updateReceipt",
          data: formData);
      EditReceiptModel model = EditReceiptModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadMileStone(token, subCategoryId) async {
    var params = {
      "token": token,
      "leadMasterId": subCategoryId,
    };

    try {
      var result = await _dio.get("${await Config.getUrl()}get_milestones",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      LeadMileStoneListModel model =
          LeadMileStoneListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addMileStone(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}add_lead_milestones",
          data: jsonEncode(body));
      AddMileStoneModel model = AddMileStoneModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  // static Future leadNotificationList(token) async {
  //   var params = {
  //     "token": token,
  //   };

  //   try {
  //     var result = await _dio.get(
  //         "${await Config.getUrl()}get_all_lead_milestones",
  //         queryParameters: params);
  //     LeadNotificationListModel model =
  //         LeadNotificationListModel.fromJson(result.data);
  //     return model;
  //   } catch (e) {
  //     log("error: $e");
  //   }
  // }
  static Future leadNotificationList(token) async {
  print("API Token: $token");

  var params = {
    "token": token,
  };

  try {
    var result = await _dio.get(
      "${await Config.getUrl()}get_all_lead_milestones",
      queryParameters: params,
    );

    print("URL: ${result.realUri}");
    print("Response: ${result.data}");

    return LeadNotificationListModel.fromJson(result.data);
  } catch (e) {
    log("error: $e");
  }
}

  static Future deleteNotification(token, String notificaionId) async {
    var params = {
      "token": token,
      "notification_id": notificaionId,
    };

    try {
      var result = await _dio.get("${await Config.getUrl()}delete_notification",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteNotification model = DeleteNotification.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future readLeadNotification(token, notificationId) async {
    var params = {
      "token": token,
      "notification_id": notificationId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_notification_read_status",
          queryParameters: params);
      ReadLeadNotificationModel model =
          ReadLeadNotificationModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteMileStoneLeads(token, leadMileStoneId) async {
    var params = {
      "token": token,
      "lead_milestone_id": leadMileStoneId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}delete_lead_milestones",
          queryParameters: params);
      DeleteLeadMileStoneModel model =
          DeleteLeadMileStoneModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future checkLeadPhoneNumber(token, contactNumber, code) async {
    var params = {
      "token": token,
      "contactNumber": code + contactNumber,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}check_lead_contact_exist",
          queryParameters: params);
      CheckLeadPhoneNumberModel model =
          CheckLeadPhoneNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getBranchList(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}getBranch", data: formData);
      // ${await Config.getUrl()}getBranch
      BranchListModel model = BranchListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceEditDetails(token, invId) async {
    var formData = FormData.fromMap({
      "token": token,
      "invoice_id": invId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getInvoiceById",
          data: formData);
      EditInvoiceDetailsModel model =
          EditInvoiceDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future<String?> printInvoice(String token, String invId) async {
    try {
      var formData = FormData.fromMap({
        "token": token,
        "invoice_id": invId,
      });

      var response = await _dio.post(
        "${await Config.getUrl()}printInvoice",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/invoice_$invId.pdf");
      await file.writeAsBytes(response.data);

      return file.path;
    } catch (e) {
      log("❌ Error in printInvoice: $e");
      return null;
    }
  }

  static Future<String?> printInvoiceTemp(String token, String invId) async {
    try {
      var formData = FormData.fromMap({
        "token": token,
        "invoice_id": invId,
      });

      var response = await _dio.post(
        "${await Config.getUrl()}printInvoiceTemp",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/invoice_$invId.pdf");
      await file.writeAsBytes(response.data);

      return file.path;
    } catch (e) {
      log("❌ Error in printInvoice: $e");
      return null;
    }
  }

  static Future<String?> printInvoiceGST(String token, String invId) async {
    try {
      var formData = FormData.fromMap({
        "token": token,
        "invoice_id": invId,
      });

      var response = await _dio.post(
        "${await Config.getUrl()}printInvoiceGST",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/invoice_$invId.pdf");
      await file.writeAsBytes(response.data);

      return file.path;
    } catch (e) {
      log("❌ Error in printInvoice: $e");
      return null;
    }
  }

  static Future invoiceEditDetailsTemp(token, invId) async {
    var formData = FormData.fromMap({
      "token": token,
      "invoice_id": invId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getInvoiceByIdTemp",
          data: formData);
      EditInvoiceDetailsModelTemp model =
          EditInvoiceDetailsModelTemp.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceEditDetailsGst(token, invId) async {
    var formData = FormData.fromMap({
      "token": token,
      "invoice_id": invId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getInvoiceByIdGST",
          data: formData);
      EditInvoiceDetailsModelGST model =
          EditInvoiceDetailsModelGST.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadVoiceUpload(
      token, leadMasterId, leadDetailsId, uploadFile) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": leadMasterId,
      "call_details_id": leadDetailsId,
      "uploadFile": await MultipartFile.fromFile(uploadFile),
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}add_follow_up_voice_note",
          data: formData);
      if (result.statusCode == 200) {
        UploadAudioRecord model = UploadAudioRecord.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadVoice(token, leadMasterId, leadDetailsId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": leadMasterId,
      "call_details_id": leadDetailsId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteVoiceNote",
          data: formData);
      DeleteLeadVoiceModel model = DeleteLeadVoiceModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callResultReasonLiat(token, callResultId) async {
    var params = {"token": token, "callResultId": callResultId};
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}get_lead_result_reasons",
          queryParameters: params);
      CallResultResonModel model = CallResultResonModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future<UserPermissionModel?> userPermissionCheck(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}user_permissions",
          queryParameters: params);
      UserPermissionModel model = UserPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
      return null;
    }
  }

  static Future deleteReceiptFile(token, receiptId) async {
    var formData = FormData.fromMap({
      'token': token,
      'receipt_id': receiptId,
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}deleteFile", data: formData);
      ReceiptFileDeleteModel model =
          ReceiptFileDeleteModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewReceiptPdf(token, receiptId) async {
    var params = {
      "token": token,
      "receipt_id": receiptId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}viewReceiptById",
          queryParameters: params);
      ViewReceiptPdfModel model = ViewReceiptPdfModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static fetchChatList(searchKey, page, pageSize) async {
    try {
      var response = await _dio
          .get("${await Config.getUrl()}official_whatsapp", queryParameters: {
        "searchKey": searchKey,
        "token": await Common.getSharedPref("token"),
        "pageNo": page,
        "pageSize": pageSize,
      });
      if (response.statusCode == 200) {
        ChatListModel chatListModel = ChatListModel.fromJson(response.data);
        return chatListModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log("Exception: $e");
    }
  }

  static getLoginorNot_first() async {
    try {
      var response = await _dio.post(
        "${await Config.getUrl()}getLoginorNot",
        data: {
          "token": await Common.getSharedPref("token"),
        },
      );
      if (response.statusCode == 200) {
        var commonResponse = CommonResponse.fromJson(response.data);
        return commonResponse;
      }
    } catch (e) {
      log("Exception: $e");
    }
  }

  static Future getLoginorNot(token) async {
    var formData = FormData.fromMap({
      'token': token,
    });
    try {
      var response = await _dio.post("${await Config.getUrl()}getLoginorNot",
          data: formData);
      if (response.statusCode == 200) {
        var commonResponse = CommonResponse.fromJson(response.data);
        return commonResponse;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getCurrentLoginStatus(token) async {
    var formData = FormData.fromMap({
      'token': token,
    });
    try {
      var response = await _dio.post(
          "${await Config.getUrl()}getLoginorNotCurrentState",
          data: formData);
      if (response.statusCode == 200) {
        var commonResponse = CommonDataResponse.fromJson(response.data);
        return commonResponse;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getStaffid(token) async {
    var formData = FormData.fromMap({
      'token': token,
    });
    try {
      var response =
          await _dio.post("${await Config.getUrl()}getStaffid", data: formData);
      if (response.statusCode == 200) {
        var commonResponse = SubmitResponse.fromJson(response.data);
        return commonResponse;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static fetchCampaignsList(searchKey) async {
    try {
      var response = await _dio
          .get("${await Config.getUrl()}get_campaigns", queryParameters: {
        "token": await Common.getSharedPref("token"),
      });

      CampaignsListModel campaignsListModel =
          CampaignsListModel.fromJson(response.data);

      return campaignsListModel;
    } catch (e) {
      log("Exception: $e");
    }
  }

  static addContact(
    contactName,
    contryCode,
    contaCtNumber,
  ) async {
    var formData = FormData.fromMap({
      "contact_name": contactName,
      'country_code': contryCode,
      'contact_number': contaCtNumber,
      "token": await Common.getSharedPref("token"),
    });
    try {
      var response = await _dio.post(
          "${await Config.getUrl()}add_new_whatsapp_contact",
          data: formData);
      if (response.statusCode == 200) {
        AddContactModel addContactModel =
            AddContactModel.fromJson(response.data);
        return addContactModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      // t("Exception: $e");
    } finally {}
  }

  static officialMessage(groupId, page, pageSize) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}official_whatsapp_messages",
          queryParameters: {
            "group_id": groupId,
            "token": await Common.getSharedPref("token"),
            "pageNo": page,
            "pageSize": pageSize,
          });
      if (response.statusCode == 200) {
        OfficialMessageModel officialMessageModel =
            OfficialMessageModel.fromJson(response.data);
        return officialMessageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static officialMessageCampaigns(groupId, page, pageSize) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}get_campaigns_messages",
          queryParameters: {
            "group_id": groupId,
            "token": await Common.getSharedPref("token"),
            "pageNo": page,
            "pageSize": pageSize,
          });
      if (response.statusCode == 200) {
        CampaignsOfficialMessageModel officialMessageModel =
            CampaignsOfficialMessageModel.fromJson(response.data);
        return officialMessageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log("Exception: $e");
    } finally {}
  }

  static socketChat(String groupId) async {
    try {
      var formData = FormData.fromMap({
        "group_id": groupId,
        "token": await Common.getSharedPref("token"),
      });
      var response = await _dio
          .post("${await Config.getUrl()}getWhatsappMessage", data: formData);

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static socketCampaign(String groupId) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}official_whatsapp_messages",
          queryParameters: {
            "group_id": groupId,
            "token": await Common.getSharedPref("token"),
          });
      if (response.statusCode == 200) {
        List<CampaignMessage> socket =
            CampaignMessage.fromJson(response.data) as List<CampaignMessage>;
        return socket;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static getTemplate() async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}get_official_whatsapp_templates",
          queryParameters: {
            "token": await Common.getSharedPref("token"),
          });
      if (response.statusCode == 200) {
        TemplateModel templateModel = TemplateModel.fromJson(response.data);
        return templateModel;
      } else if (response.statusCode == 500) {
      } else {}
    } finally {}
  }

  static getTemplateContent(templateId) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}get_whatsapp_template_message_data",
          queryParameters: {
            "template_id": templateId,
            "token": await Common.getSharedPref("token"),
          });

      if (response.statusCode == 200) {
        TemplateContentModel templateContentMoel =
            TemplateContentModel.fromJson(response.data);
        return templateContentMoel;
      } else if (response.statusCode == 500) {
      } else {}
    } finally {}
  }

  static sendTemplateMessage(groupId, format, templateName, language, template,
      fileName, isFile, type, List argList) async {
    try {
      // log(jsonEncode(argList).toString());
      var formData = FormData.fromMap({
        "group_id": groupId,
        'format': format,
        'template_name': templateName,
        'language': language,
        'template': template,
        'fileName': type == "file_manager" || isFile == false
            ? fileName
            : await MultipartFile.fromFile(fileName),
        'type': type,
        'is_file': isFile.toString(),
        "token": await Common.getSharedPref("token"),
        "arg_list": jsonEncode(argList)
      });
      var response = await _dio.post(
          "${await Config.getUrl()}sendTemplatewhatsappMessage",
          data: formData);
      if (response.statusCode == 200) {
        SendTemplateMesaageModel sendTemplateMesaageModel =
            SendTemplateMesaageModel.fromJson(response.data);
        return sendTemplateMesaageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log("Exception: $e");
    }
  }

  // static sendMessage(
  //   groupId,
  //   messageData,
  //   fileName,
  //   isImage,
  // ) async {
  //   var formData = FormData.fromMap({
  //     "group_id": groupId,
  //     'message_data': messageData,
  //     'fileName': isImage == true ? await MultipartFile.fromFile(fileName) : '',
  //     'is_image': isImage,
  //     "token": await Common.getSharedPref("token"),
  //   });

  //   try {
  //     var response = await _dio.post("${await Config.getUrl()}sendMessage",
  //         data: formData);

  //     if (response.statusCode == 200) {
  //       SendMesaageModel sendMesaageModel =
  //           SendMesaageModel.fromJson(response.data);
  //       return sendMesaageModel;
  //     } else if (response.statusCode == 500) {
  //     } else {}
  //   } catch (e) {
  //     // t("Exception: $e");
  //   } finally {}
  // }

  static Future<SendMesaageModel?> sendMessage(
    String groupId,
    String messageData,
    dynamic filePaths,
    bool isImage,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      final Map<String, dynamic> formMap = {
        "group_id": groupId,
        "message_data": messageData,
        "is_image": isImage,
        "token": token,
      };
      if (filePaths != null) {
        final List<String> files = filePaths is String
            ? [filePaths]
            : filePaths is List<String>
                ? filePaths
                : filePaths is List<XFile>
                    ? filePaths.map((x) => x.path).toList()
                    : [];
        if (files.isNotEmpty) {
          final multipartFiles = <MultipartFile>[];
          for (final filePath in files) {
            if (filePath.isNotEmpty) {
              final fileExtension = filePath.split('.').last.toLowerCase();
              MediaType contentType;
              if (fileExtension == 'mp3') {
                contentType = MediaType('audio', 'mpeg');
              } else if (fileExtension == 'wav') {
                contentType = MediaType('audio', 'wav');
              } else if (fileExtension == 'mp4') {
                contentType = MediaType('video', 'mp4');
              } else if (fileExtension == 'mov') {
                contentType = MediaType('video', 'quicktime');
              } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
                contentType = MediaType('image', 'jpeg');
              } else if (fileExtension == 'png') {
                contentType = MediaType('image', 'png');
              } else if (fileExtension == 'gif') {
                contentType = MediaType('image', 'gif');
              } else if (fileExtension == 'webp') {
                contentType = MediaType('image', 'webp');
              } else if (fileExtension == 'pdf') {
                contentType = MediaType('application', 'pdf');
              } else if (fileExtension == 'doc' || fileExtension == 'docx') {
                contentType = MediaType('application', 'msword');
              } else if (fileExtension == 'xls' || fileExtension == 'xlsx') {
                contentType = MediaType('application', 'vnd.ms-excel');
              } else if (fileExtension == 'ppt' || fileExtension == 'pptx') {
                contentType = MediaType('application', 'vnd.ms-powerpoint');
              } else if (fileExtension == 'txt') {
                contentType = MediaType('text', 'plain');
              } else {
                contentType = MediaType('application', 'octet-stream');
              }
              final multipartFile = await MultipartFile.fromFile(
                filePath,
                filename: filePath.split('/').last,
                contentType: contentType,
              );
              multipartFiles.add(multipartFile);
            }
          }

          if (multipartFiles.isNotEmpty) {
            if (multipartFiles.length == 1) {
              formMap["fileName"] = multipartFiles.first;
            } else {
              formMap["fileName[]"] = multipartFiles;
            }
          }
        }
      }

      final formData = FormData.fromMap(formMap);
      final response = await _dio.post(
        "${await Config.getUrl()}sendMessage",
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          responseType: ResponseType.json,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return SendMesaageModel.fromJson(response.data);
      } else {
        print("Send message failed with status: ${response.statusCode}");
        print("Response data: ${response.data}");
        return null;
      }
    } catch (e, st) {
      print("Exception in sendMessage: $e");
      print(st);
      return null;
    }
  }

  static sendMessageFile(groupId, messageData, fileName) async {
    var formData = FormData.fromMap({
      "group_id": groupId,
      'message_data': messageData,
      'fileName': fileName,
      "token": await Common.getSharedPref("token"),
    });

    try {
      var response = await _dio.post("${await Config.getUrl()}sendMessageFiles",
          data: formData);

      if (response.statusCode == 200) {
        SendMesaageModel sendMesaageModel =
            SendMesaageModel.fromJson(response.data);
        return sendMesaageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      // t("Exception: $e");
    } finally {}
  }

  static Future getTemplateMedia(format) async {
    var params = {
      "token": await Common.getSharedPref("token"),
      "fileType": format
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getMediaFiles",
          queryParameters: params);
      MediaModel model = MediaModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogUploadPermission(body) async {
    try {
      var result = await _dio.get("${await Config.getUrl()}call_log_checking",
          queryParameters: body);

      CallLogUploadPermissionModel model =
          CallLogUploadPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogUploadPermissionUpdate(body) async {
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_user_call_permission",
          queryParameters: body);

      CallLogUploadPermissionUpdateModel model =
          CallLogUploadPermissionUpdateModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future officialWhatsAppConfigure() async {
    var params = {
      "token": await Common.getSharedPref("token"),
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}official_whatsapp_config",
          queryParameters: params);
      OfficialWhatsappConfigeModel model =
          OfficialWhatsappConfigeModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }
  /*  Complaints Ansar */

  static Future<GetModel?> getComplaintDetails() async {
    // log(await Common.getSharedPref("token"));
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}getComplaintDetails", data: formData);

      if (response.statusCode == 200) {
        GetModel getModel = GetModel.fromJson(response.data);
        return getModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<PostModel?> postComplaint(
    List type,
    String compBy,
    String custName,
    String custPhone,
    String custEmail,
    String date,
    String description,
    // List compAgainst,
    remark,
    String status,
    List nature,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
      "complaint_type": jsonEncode(type),
      "complaint_report_by": compBy,
      "coustmer_name": custName,
      "coustmer_contact_number": custPhone,
      "coustmer_email": custEmail,
      "incident_date": date,
      "complaint_description": description,
      // "complaint_agianst": jsonEncode(compAgainst),
      "employee_remarks": jsonEncode(remark),
      "complaint_status": status,
      "complaint_nature": jsonEncode(nature),
    });

    try {
      final response = await _dio.post("${await Config.getUrl()}postComplaint",
          data: formData);
      if (response.statusCode == 200) {
        PostModel postModel = PostModel.fromJson(response.data);
        return postModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<ListModel?> getList(String fDate, String tDate, String compType,
      String repBy, String comNature) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "from_date": fDate,
      "to_date": tDate,
      "complaint_type": compType,
      "reported_by": repBy,
      "complaint_nature": comNature,
    });

    try {
      //log("${await Config.getUrl()}");
      final response = await _dio.post("${await Config.getUrl()}getComplaints",
          data: formData);

      if (response.statusCode == 200) {
        ListModel listModel = ListModel.fromJson(response.data);
        return listModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<AddItemModel?> addItems(String status, String value) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "status": status,
      "field_val": value
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}postComplaintStatus", data: formData);

      if (response.statusCode == 200) {
        AddItemModel addItemModel = AddItemModel.fromJson(response.data);
        return addItemModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<DetailsModel?> getDetails(String compId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_id": compId,
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}getComplaintById", data: formData);

      if (response.statusCode == 200) {
        DetailsModel detailsModel = DetailsModel.fromJson(response.data);
        return detailsModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<PostRemarkModel?> postRemark(
      String compId, String remark) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_id": compId,
      "remarks": remark
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}postComplaintRemarks", data: formData);

      if (response.statusCode == 200) {
        PostRemarkModel postRemarkModel =
            PostRemarkModel.fromJson(response.data);
        return postRemarkModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<DeleteModel?> deleteComplaint(String compId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_id": compId,
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}deleteComplaint", data: formData);

      if (response.statusCode == 200) {
        DeleteModel deleteModel = DeleteModel.fromJson(response.data);
        return deleteModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<UpdateComplaintModel?> updateComplaint(
      List type,
      String compBy,
      String custName,
      String custPhone,
      String custEmail,
      String date,
      String description,
      // List compAgainst,
      remark,
      String status,
      List nature,
      String compId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_type": jsonEncode(type),
      "complaint_report_by": compBy,
      "coustmer_name": custName,
      "coustmer_contact_number": custPhone,
      "coustmer_email": custEmail,
      "incident_date": date,
      "complaint_description": description,
      // "complaint_agianst": jsonEncode(compAgainst),
      "employee_remarks": jsonEncode(remark),
      "complaint_status": status,
      "complaint_nature": jsonEncode(nature),
      "complaint_id": compId
    });

    try {
      final response = await _dio
          .post("${await Config.getUrl()}updateComplaint", data: formData);
      if (response.statusCode == 200) {
        UpdateComplaintModel complaintUpdateModel =
            UpdateComplaintModel.fromJson(response.data);
        return complaintUpdateModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<UserDashboardModel?> getStaffDashboard(
      String userId, String fDate, String tDate) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "from_date": fDate,
      "to_date": tDate,
      "user_id": userId
    };
    try {
      final response = await _dio.get(
          "${await Config.getUrl()}view_staff_dashboard",
          queryParameters: params);

      if (response.statusCode == 200) {
        UserDashboardModel? userDashboardModel =
            UserDashboardModel.fromJson(response.data);
        return userDashboardModel;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<UserDashboardModel?> getStaffDashboardNew(
      String userId, String fDate, String tDate) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "from_date": fDate,
      "to_date": tDate,
      "user_id": userId
    };
    try {
      final response = await _dio.get(
          "${await Config.getUrl()}get_staff_report_view",
          queryParameters: params);

      if (response.statusCode == 200) {
        UserDashboardModel? userDashboardModel =
            UserDashboardModel.fromJson(response.data);
        return userDashboardModel;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<StaffCallDuration?> getStaffCallDuration(
      String staffId, String date) async {
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_call_details",
        data: {
          "token": await Common.getSharedPref('token'),
          "staff_id": staffId,
          "date": date,
        },
      );
      if (response.statusCode == 200) {
        return StaffCallDuration.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<StaffCalldetailsModel?> getStaffCallDetails(
      String userId, String fDate, String tDate) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "from_date": fDate,
      "to_date": tDate,
      "user_id": userId
    };
    try {
      final response = await _dio.get(
          "${await Config.getUrl()}view_staff_call_details",
          queryParameters: params);

      if (response.statusCode == 200) {
        StaffCalldetailsModel? staffCalldetailsModel =
            StaffCalldetailsModel.fromJson(response.data);
        return staffCalldetailsModel;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  //// Renewal Management ////

  static Future renewalDashboard() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}renewalDashboard",
          data: formData);
      if (result.statusCode == 200) {
        RenewalDashboardModel response =
            RenewalDashboardModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future<ProjectList?> getProjectList() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}get_projects",
          data: formData);

      if (result.statusCode == 200) {
        return ProjectList.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }

    return null;
  }

  static Future<TitleList?> getTitleList(selectedProjectId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "project_id": selectedProjectId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_title_list",
          data: formData);
      if (result.statusCode == 200) {
        return TitleList.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }
    return null;
  }

  static Future<WorkStatusModel?> getWorkStatus({int? isPaused}) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      if (isPaused != null) "is_paused": isPaused.toString(),
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}get_works", data: formData);

      if (result.statusCode == 200) {
        return WorkStatusModel.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }
    return null;
  }

  // static Future<AssignedWorkStatusModel?> getAssinedWorkStatus(
  //     workId, sectionId) async {
  //   var formData = FormData.fromMap({
  //     "token": await Common.getSharedPref('token'),
  //     "work_id": workId,
  //     "section_id": sectionId,
  //   });
  //   try {
  //     var result = await _dio.post("${await Config.getUrl()}get_assigned_works",
  //         data: formData);
  //     if (result.statusCode == 200) {
  //       return AssignedWorkStatusModel.fromJson(result.data);
  //     }
  //   } catch (e) {
  //     log("error: $e");
  //   }
  //   return null;
  // }
  static Future<AssignedWorkStatusModel?> getAssinedWorkStatus(
      workId, sectionId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "work_id": workId,
      "section_id": sectionId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_assigned_works",
          data: formData);
      if (result.statusCode == 200) {
        print('getAssinedWorkStatus Response: ${result.data}');
        if (result.data != null &&
            result.data['data'] != null &&
            result.data['data'] is List &&
            result.data['data'].isNotEmpty) {
          return AssignedWorkStatusModel.fromJson(result.data);
        }
        return AssignedWorkStatusModel(
          data: [],
          status: result.data['status'] ?? false,
          message: result.data['message'] ?? "No data",
        );
      }
    } catch (e) {
      log("error in getAssinedWorkStatus: $e");
    }
    return null;
  }

  static Future<WorkStatusModel?> getWorkStatusPaused(selectedWorkId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "work_id": selectedWorkId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_paused_works",
          data: formData);

      if (result.statusCode == 200) {
        return WorkStatusModel.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }

    return null;
  }

  static Future<TimeDetailsModel?> getimeDetails() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}get_workstatus_summary",
          data: formData);

      if (result.statusCode == 200) {
        return TimeDetailsModel.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }

    return null;
  }

  static Future<WorkDetailsModel?> getWorkStatusDetails(String date,
      {String? staffId}) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "date": date,
      "staff_id": staffId,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}get_workstatus_details",
          data: formData);
      if (result.statusCode == 200) {
        return WorkDetailsModel.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }
    return null;
  }

  static Future<SubmitResponse> updateWorkData(
      Map<String, dynamic> workData) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "work_id": workData['work_id'],
      "project_id": workData['project_id'],
      "title": workData['title'],
      "assigned_id": workData['assignedId'],
      //   "attendance_id": workData['attendance_id'],
      "title_id": workData['title_id'],
      "latitude": workData['latitude'],
      "longitude": workData['longitude'],
      "action": workData['action'] ?? '',
      "tasks": jsonEncode(workData['tasks']),
    });
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}end_work",
        data: formData,
      );
      if (result.statusCode == 200) {
        return SubmitResponse.fromJson(json.decode(result.data));
      }
      throw Exception("Failed to update work");
    } catch (e) {
      log("Update work error: $e");
      rethrow;
    }
  }

// static Future<SubmitResponse> saveWorkData(Map<String, dynamic> workData) async {
//   var formData = FormData.fromMap({
//     "token": await Common.getSharedPref('token'),
//     "work_id": workData['work_id'],
//     "project_id": workData['project_id'],
//     "title": workData['title'],
//     "tasks": jsonEncode(workData['tasks']),
//   });

//   try {
//     var result = await _dio.post(
//       "${await Config.getUrl()}save_work",
//       data: formData,
//     );

//     if (result.statusCode == 200) {
//       return SubmitResponse.fromJson(json.decode(result.data));
//     }
//     throw Exception("Failed to update work");
//   } catch (e) {
//     log("Update work error: $e");
//     rethrow;
//   }
// }

  static Future<SubmitResponse> saveWorkData(
      Map<String, dynamic> workData) async {
    final data = {
      "token": await Common.getSharedPref('token'),
      "work_id": workData['work_id'],
      "project_id": workData['project_id'],
      "project_name": workData['project_name'] ?? '',
      "title": workData['title'],
      "title_id": workData['title_id'],
      "assigned_id": workData['assignedId'],
      "latitude": workData['latitude'],
      "longitude": workData['longitude'],
      "action": workData['action'] ?? '',
      "tasks": workData['tasks'],
    };
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}save_work",
        data: jsonEncode(data),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (result.statusCode == 200) {
        return SubmitResponse.fromJson(json.decode(result.data));
      }
      throw Exception("Failed to save work");
    } catch (e) {
      log("Save work error: $e");
      rethrow;
    }
  }

  static Future<SubmitResponse> submitWorkData(
      Map<String, dynamic> workData) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "project_id": workData['project_id'],
      "project_name": workData['project_name'],
      'work_start_time': workData['work_time'],
      "title": workData['title'],
      "title_id": workData['title_id'],
      'attendance_id': workData['attendance_id'],
      "latitude": workData['latitude'],
      "longitude": workData['longitude'],
      "action": workData['action'] ?? '',
      "tasks": jsonEncode(workData['tasks']),
    });
    // try {
    var result = await _dio.post(
      "${await Config.getUrl()}submit_work",
      data: formData,
    );
    if (result.statusCode == 200) {
      return SubmitResponse.fromJson(json.decode(result.data));
    } else {
      throw Exception("Failed to submit work");
    }
    // }
    // catch (e) {
    //   throw Exception("HTTP error: $e");
    // }
  }

  static Future<SubmitResponse> assignWorkData(
      Map<String, dynamic> workData) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "project_id": workData['project_id'],
      "call_master_id": workData['call_master_id'],
      "project_name": workData['project_name'],
      "title": workData['title'],
      "title_id": workData['title_id'],
      "due_date": workData['due_date'],
      "priority": workData['priority'],
      "assigned_to": workData['assigned_to'],
      "task_type": workData['task_type'],
      "category": workData['category'],
      "latitude": workData['latitude'],
      "longitude": workData['longitude'],
      "tasks": jsonEncode(workData['tasks']),
      "work_start_time": workData['work_time'],
      "whatsapp_notification": workData['notification']['whatsapp'] ?? false,
      "push_notification": workData['notification']['push'] ?? false,
      "notify_to_assigned":
          workData['notification']['notify_to_assigned'] ?? false,
      "notify_on_status_change":
          workData['notification']['notify_on_status_change'] ?? false,
      "notify_other_people":
          workData['notification']['notify_other_people'] ?? false,
      "notify_staff_ids": workData['notification']['staff_ids'] ?? '',
      "notify_on_start": workData['notification']['on_start'] ?? false,
      "notify_on_complete": workData['notification']['on_complete'] ?? false,
      "participant_ids": workData['participant_ids'] ?? '',
    });
    // try {
    var result = await _dio.post(
      "${await Config.getUrl()}assign_work",
      data: formData,
    );
    if (result.statusCode == 200) {
      print("product by id response: ${result.data}");
      return SubmitResponse.fromJson(result.data);
    } else {
      throw Exception("Failed to submit work");
    }
    // }
    // catch (e) {
    //   throw Exception("HTTP error: $e");
    // }
  }

  static Future<SubmitResponse> pauseWorkData(
      Map<String, dynamic> workData) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "work_id": workData['work_id'],
      "project_id": workData['project_id'],
      "project_name": workData['project_name'],
      'work_end_time': workData['work_time'],
      "title": workData['title'],
      "title_id": workData['title_id'],
      "assigned_id": workData['assignedId'],
      "latitude": workData['latitude'],
      "longitude": workData['longitude'],
      "tasks": jsonEncode(workData['tasks']),
    });
    // try {
    var result = await _dio.post(
      "${await Config.getUrl()}pause_work",
      data: formData,
    );
    if (result.statusCode == 200) {
      return SubmitResponse.fromJson(json.decode(result.data));
    } else {
      throw Exception("Failed to submit work");
    }
    // }
    // catch (e) {
    //   throw Exception("HTTP error: $e");
    // }
  }

  static Future<SubmitResponse> restartWork(
      Map<String, dynamic> workData) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "work_id": workData['work_id'],
      "project_id": workData['project_id'],
      "project_name": workData['project_name'],
      'work_start_time': workData['work_time'],
      'attendance_id': workData['attendance_id'],
      "title": workData['title'],
      "title_id": workData['title_id'],
      "latitude": workData['latitude'],
      "longitude": workData['longitude'],
      "tasks": jsonEncode(workData['tasks']),
    });
    // try {
    var result = await _dio.post(
      "${await Config.getUrl()}submit_work",
      data: formData,
    );
    if (result.statusCode == 200) {
      return SubmitResponse.fromJson(json.decode(result.data));
    } else {
      throw Exception("Failed to Restart work");
    }
    // }
    // catch (e) {
    //   throw Exception("HTTP error: $e");
    // }
  }

  static Future getRenewalDetails() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getAddRenewalData",
          data: formData);
      if (result.statusCode == 200) {
        RenewalDetailslModel response =
            RenewalDetailslModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getAddRenewalFollowUpDetails(renewalId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": renewalId,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getAddRenewalFollowUpDetails",
          data: formData);
      if (result.statusCode == 200) {
        RenewalFollowupDetailsModel response =
            RenewalFollowupDetailsModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getRenewalDetailsById(String id, String type) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_type": type,
      "renewal_id": id
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getRenewalById",
          data: formData);
      if (result.statusCode == 200) {
        RenewalByIdModel response = RenewalByIdModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postExistingQuick(
      renewalProducts,
      clientId,
      cost,
      templateId,
      startDate,
      endDate,
      remarks,
      branchId,
      isPaid,
      actualCost,
      createInvoice,
      checkIdVal) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_product": jsonEncode(renewalProducts),
      "client_id": clientId,
      "cost": cost,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "is_paid": isPaid,
      "actual_cost": actualCost,
      "create_invoice": createInvoice,
      "check_id_val": checkIdVal
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postexistingCustomerRenewal",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postNewQuick(
      isPaid,
      branchId,
      countryCode,
      contactNo,
      whatsappCountryCode,
      whatsappContactNo,
      clientName,
      address1,
      address2,
      address3,
      postOffice,
      pincode,
      gstNum,
      remarks,
      products,
      startDate,
      endDate,
      cost,
      email,
      actualCost,
      createInvoice,
      templateId,
      checkIdVal) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "is_paid": isPaid,
      "branch_id": branchId ?? "",
      "country_code": countryCode,
      "contact_no": contactNo,
      "whatsapp_country_code": whatsappCountryCode,
      "whatsapp_contact_no": whatsappContactNo,
      "client_name": clientName,
      "address": address1,
      "address2": address2,
      "address3": address3,
      "post_office": postOffice,
      "pincode": pincode,
      "gst_num": gstNum,
      "remarks": remarks,
      "renewal_product": jsonEncode(products),
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "cost": cost,
      "email_id ": email,
      "actual_cost": actualCost,
      "create_invoice": createInvoice,
      "check_id_val": checkIdVal
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postNewCustomerRenewal",
          data: formData);
      if (result.statusCode == 200) {
        AddCustomerModel response = AddCustomerModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postExistingCustom(
      renewalProducts,
      clientId,
      templateId,
      startDate,
      endDate,
      remarks,
      branchId,
      actualCost,
      checkIdVal,
      invoiceNum,
      invoiceDate,
      invoiceSl,
      subTotal,
      tax,
      discount,
      shipping,
      totalAmount,
      paidAmount,
      payStatus,
      payMethod,
      collectedStaff,
      createInvoice,
      targetGroup) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "product_details": jsonEncode(renewalProducts),
      "client_id": clientId,
      "reminder_template": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "actual_cost": actualCost,
      "check_id_val": checkIdVal,
      "invoice_number": invoiceNum,
      "invoice_date": invoiceDate,
      "invoice_sl_number": invoiceSl,
      "sub_total": subTotal,
      "estimated_tax": tax,
      "discount_amount": discount,
      "shipping_amount": shipping,
      "total_amount_paid": totalAmount,
      "amount_paid_customer": paidAmount,
      "payment_status": payStatus,
      "payment_method": payMethod,
      "collected_staff": collectedStaff,
      "create_invoice": createInvoice,
      "target_group": jsonEncode(targetGroup)
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postExistingCustomRenewal",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postNewCustom(
      branchId,
      countryCode,
      contactNo,
      whatsappCountryCode,
      whatsappContactNo,
      clientName,
      address1,
      address2,
      address3,
      postOffice,
      pincode,
      gstNum,
      remarks,
      renewalProducts,
      startDate,
      endDate,
      cost,
      email,
      actualCost,
      templateId,
      checkIdVal,
      invoiceNum,
      invoiceDate,
      invoiceSl,
      subTotal,
      tax,
      discount,
      shipping,
      totalAmount,
      paidAmount,
      payStatus,
      payMethod,
      collectedStaff,
      createInvoice,
      targetGroup) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "branch_id": branchId ?? "",
      "country_code": countryCode,
      "contact_no": contactNo,
      "whatsapp_country_code": whatsappCountryCode,
      "whatsapp_contact_no": whatsappContactNo,
      "client_name": clientName,
      "address": address1,
      "address2": address2,
      "address3": address3,
      "post_office": postOffice,
      "pincode": pincode,
      "gst_num": gstNum,
      "remarks": remarks,
      "product_details": jsonEncode(renewalProducts),
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "email_id ": email,
      "actual_cost": actualCost,
      "check_id_val": checkIdVal,
      "invoice_number": invoiceNum,
      "invoice_date": invoiceDate,
      "invoice_sl_number": invoiceSl,
      "sub_total": subTotal,
      "estimated_tax": tax,
      "discount_amount": discount,
      "shipping_amount": shipping,
      "total_amount_paid": totalAmount,
      "amount_paid_customer": paidAmount,
      "payment_status": payStatus,
      "payment_method": payMethod,
      "collected_staff": collectedStaff,
      "create_invoice": createInvoice,
      "target_group": jsonEncode(targetGroup)
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}postCustomRenewal",
          data: formData);
      if (result.statusCode == 200) {
        AddCustomerModel response = AddCustomerModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future renewalList(
    custId,
    page,
    pageSize,
    clientId,
    fromDate,
    toDate,
    daysToExpire,
    String searchKey,
    searchMonth,
    String expireIn,
    String search,
    String renewalStatus,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "page": page,
      "cust_id": custId,
      "page_size": pageSize,
      "client_id": clientId,
      "from_date": fromDate ?? "",
      "to_date": toDate ?? "",
      "days_to_expire": daysToExpire,
      "search_key": searchKey,
      "search_month": searchMonth,
      "expiry_in_days": expireIn,
      "renewal_customer": search,
      "renewal_status": renewalStatus,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}getAllRenewalReports", data: formData);
      if (result.statusCode == 200) {
        RenewalListModel response = RenewalListModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateCustomRenewal(
    rowId,
    customerId,
    branchId,
    startDate,
    endDate,
    renewalType,
    renewalProduct,
    templateId,
    remarks,
    cartId,
    subTotal,
    estimatedTax,
    discountAmount,
    shippingAmount,
    totalAmount,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_type": renewalType,
      "cart_id": cartId,
      "row_id": rowId,
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
      "renewal_product": jsonEncode(renewalProduct),
      "customer_id": customerId,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "total_amount_paid": totalAmount,
      "cost": totalAmount,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}updateRenewalDetails", data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateQuickRenewal(
    rowId,
    renewalType,
    customerId,
    branchId,
    startDate,
    endDate,
    renewalProduct,
    templateId,
    remarks,
    cost,
    actualCost,
    isPaid,
    createInvoice,
    invoiceId,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
      "renewal_type": renewalType,
      "create_invoice": createInvoice,
      "row_id": rowId,
      "is_paid": isPaid,
      "renewal_product": jsonEncode(renewalProduct),
      "customer_id": customerId,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "actual_cost": actualCost,
      "cost": cost,
      "invoice_id": invoiceId,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}updateRenewalDetails", data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future hideRenewal(String recordId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "record_id": recordId});
    try {
      var result = await _dio
          .post("${await Config.getUrl()}hideRenewalCustomer", data: formData);
      if (result.statusCode == 200) {
        HideModel response = HideModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future hiddenList(
      page, pageSize, clientId, fromDate, toDate, daysToExpire) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "page": page,
      "page_size": pageSize,
      "client_id": clientId,
      "from_date": fromDate ?? "",
      "to_date": toDate ?? "",
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getRenewalHidden",
          data: formData);
      if (result.statusCode == 200) {
        HiddenListModel response = HiddenListModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future paymentReport(
      page, pageSize, clientId, fromDate, toDate, daysToExpire) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "page": page,
      "page_size": pageSize,
      "client_id": clientId,
      "from_date": fromDate ?? "",
      "to_date": toDate ?? "",
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getRenewalPaymentReport",
          data: formData);
      if (result.statusCode == 200) {
        PaymentReportModel response = PaymentReportModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postRenewQuick(
    branchId,
    rowId,
    startDate,
    endDate,
    cost,
    remarks,
    renewalProduct,
    customerId,
    isPaid,
    createInvoice,
    renewalType,
    templateId,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "branch_id": branchId ?? "",
      "row_id": rowId,
      "start_date": startDate,
      "end_date": endDate,
      "cost": cost,
      "remarks": remarks,
      "customer_id": customerId,
      "is_paid": isPaid,
      "create_invoice": createInvoice,
      "renewal_product": jsonEncode(renewalProduct),
      "renewal_type": renewalType,
      "template_id": templateId,
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
    });
    log(jsonEncode(renewalProduct));

    try {
      var result = await _dio.post("${await Config.getUrl()}postRenewDetails",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postRenewCustom(
      rowId,
      customerId,
      branchId,
      startDate,
      endDate,
      renewalType,
      renewalProduct,
      templateId,
      remarks,
      invoiceId,
      paymentStatus,
      paymentMethod,
      cartId,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      totalAmount,
      paidAmount,
      invoiceDate,
      collectedStaff,
      targetGroup) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_type": renewalType,
      "row_id": rowId,
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
      "renewal_product": jsonEncode(renewalProduct),
      "customer_id": customerId,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "invoice_id": invoiceId,
      "invoice_date": invoiceDate,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "total_amount_paid": totalAmount,
      "amount_paid_customer": paidAmount,
      "payment_status": paymentStatus ?? "",
      "payment_method": paymentMethod ?? "",
      "collected_staff": collectedStaff ?? "",
      "target_group": jsonEncode(targetGroup)
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}postRenewDetails",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future rivertRenewal(String recordId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "record_id": recordId});
    try {
      var result = await _dio
          .post("${await Config.getUrl()}revertRenewalClient", data: formData);
      if (result.statusCode == 200) {
        RivertModel response = RivertModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteRenewalClient(String recordId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "record_id": recordId});
    try {
      var result = await _dio
          .post("${await Config.getUrl()}deleteRenewalClient", data: formData);
      if (result.statusCode == 200) {
        DeleteRenewalModel response = DeleteRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewHistory(String id) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": id,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getRenewalReminderHistory",
          data: formData);
      if (result.statusCode == 200) {
        ReminderHistoryModel response =
            ReminderHistoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getRenewalFollowUpDashboard(String id) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": id,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getRenewalFollowUpDashboard",
          data: formData);
      if (result.statusCode == 200) {
        FollowupDashboardModel response =
            FollowupDashboardModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future isCustomerExists(String id, String phoneNumber) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "customer_id": id,
      "phone_number": "91$phoneNumber"
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}isCustomerExists",
          data: formData);
      if (result.statusCode == 200) {
        IsCustomerExistModel response =
            IsCustomerExistModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getRenewalReminderMessage(String renId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": renId,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getRenewalReminderMessage",
          data: formData);
      if (result.statusCode == 200) {
        RenewalTemplateModel response =
            RenewalTemplateModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postReminder(String renId, String contactNumber, templateType,
      templateName, templateId, customerId, messageContent) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "row_id": renId,
      "contact_no": contactNumber,
      "template_type": templateType,
      "template_name": templateName,
      "template_id": templateId,
      "medium": "official",
      "customer_id": customerId,
      "message_content": messageContent
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}sendRenewalReminder", data: formData);
      if (result.statusCode == 200) {
        PostReminderModel response = PostReminderModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future bulkReminder(List recordId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": jsonEncode(recordId),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}sendBulkReminder",
          data: formData);
      if (result.statusCode == 200) {
        BulkRemindModel response = BulkRemindModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postRenewalFollowup(
      token,
      leadStatusId,
      nextFollowupDate,
      cost,
      leadId,
      remarks,
      callMasterId,
      calledDate,
      customerId,
      checked,
      timeBefore,
      callResponseId,
      reasonId,
      invoiceDate,
      productList,
      reminderTemplate,
      totalAmount,
      startDate,
      endDate,
      paymentStatus,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      paymentMethod,
      paidAmount,
      collectedStaff,
      targetGroup) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResponseId,
      "lead_id": leadId,
      "lead_status": leadStatusId,
      "cost": cost,
      "remarks": remarks,
      "renewal_id": callMasterId,
      "called_date": calledDate,
      "customer_id": customerId,
      "reminder": checked,
      "time_before": timeBefore,
      "reason_id": reasonId,
      "invoice_date": invoiceDate,
      "product_list": leadStatusId == '2' ? "" : jsonEncode(productList),
      "follow_up_products": leadStatusId == '2' ? jsonEncode(productList) : "",
      "reminder_template": reminderTemplate,
      "total_amount_paid": totalAmount,
      "start_date": startDate,
      "end_date": endDate,
      "payment_status": paymentStatus,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "payment_method": paymentMethod,
      "amount_paid_customer": paidAmount,
      "collected_staff": collectedStaff,
      "target_group": jsonEncode(targetGroup)
    });

    try {
      var result = await _dio
          .post("${await Config.getUrl()}postRenewalFollowup", data: formData);
      AddLeadFollowupModel model = AddLeadFollowupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  /// product mannagement ///

  static Future getProductCategory() async {
    var formData =
        FormData.fromMap({"token": await Common.getSharedPref('token')});
    try {
      var result = await _dio.post("${await Config.getUrl()}getProductCategory",
          data: formData);
      if (result.statusCode == 200) {
        ProductCategoriesModel response =
            ProductCategoriesModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getProductSubCategory(String id) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "category_id": id});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        SubCategoriesModel response = SubCategoriesModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  // static Future getProductLists(String subId) async {
  //   var formData = FormData.fromMap({
  //     "token": await Common.getSharedPref('token'),
  //     // "sub_category_id": subId
  //   });
  //   try {
  //     var result = await _dio.post("${await Config.getUrl()}getProductLists",
  //         data: formData);
  //     if (result.statusCode == 200) {
  //       ProductListModel response = ProductListModel.fromJson(result.data);
  //       return response;
  //     }
  //   } catch (e) {
  //     log("error: $e");
  //   }
  // }
  static Future<ProductListModel?> getProductLists(String subId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      // "sub_category_id": subId
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getProductLists",
        data: formData,
      );

      if (result.statusCode == 200 && result.data['status'] == true) {
        ProductListModel response = ProductListModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("getProductLists error: $e");
    }

    return null;
  }

  static Future postProducts(
    String contentId,
    String categoryId,
    String subCategoryId,
    String productName,
    String productCode,
    String productUCode,
    String productMrp,
    String noOfDays,
    String remindBefore,
    String sellingPrice,
    String purchasePrice,
    String barcode,
    String taxPercent,
    String totalAmount,
    String description,
    productImage,
    String productType,
    String hsnCode,
    String brand,
    String discount,
    String expiryDays, {
    String addStock = "0",
    String checkStock = "0",
    String openingStock = "",
    String currentStock = "",
    String stockStatus = "In Stock",
    String? unit,
    String? unitId,
    bool? hasWarranty,
    List<String>? pipelines,
    bool? addPublish,
    String? publishStatus,
    String? visibility,
    String? expiryDate,
    String? warrantyNumber,
    String? serviceCycle,
    String? freeService,
    String? paidService,
    List<Map<String, dynamic>>? complaints,
    String? serviceNoOfDays,
    String? serviceWeeks,
    String? serviceMonthDays,
    String? serviceYearDays,
    String? serviceYearMonth,
  }) async {
    Map<String, dynamic> data = {
      "token": await Common.getSharedPref('token'),
      "content_id": contentId,
      "category_id": categoryId,
      "sub_category_id": subCategoryId,
      "product_name": productName,
      "product_code": productCode,
      "product_u_code": productUCode,
      "product_mrp": productMrp,
      "no_of_days": noOfDays,
      "remind_before": remindBefore,
      "purchase_price": purchasePrice,
      "barcode": barcode,
      "tax_percent": taxPercent,
      "total_amount": totalAmount,
      "description": description,
      "product_type": productType,
      "brand": brand,
      "discount": discount,
      "add_stock": addStock,
      "check_stock": checkStock,
      "opening_stock": openingStock,
      "current_stock": currentStock,
      "stock_status": stockStatus,
    };

    if (productImage != null && productImage != "null" && productImage != "") {
      data["product_image"] =
          await MultipartFile.fromFile(productImage.toString());
    } else {
      data["product_image"] = "";
    }

    if (productType == "Rental") {
      data["rentalPrice"] = sellingPrice;
      data["hsnSacCode"] = hsnCode;
      data["unit"] = unit ?? "";
      data["unit_id"] = unitId ?? "";
      data["is_publish"] = addPublish == true ? 1 : 0;
      if (addPublish == true) {
        data["publish_status"] = publishStatus;
        data["visibility"] = visibility;
      }
    } else if (productType == "Ecommerce") {
      data["selling_price"] = sellingPrice;
      data["hsn_code"] = hsnCode;
      data["unit"] = unit ?? "";
      data["unit_id"] = unitId ?? "";
      data["is_publish"] = addPublish == true ? 1 : 0;
      if (addPublish == true) {
        data["publish_status"] = publishStatus;
        data["visibility"] = visibility;
      }
    } else if (productType == "Service") {
      data["selling_price"] = sellingPrice;
      data["sacCode"] = hsnCode;
      data["warranty"] = hasWarranty == true ? "Yes" : "No";
      if (hasWarranty == true) {
        data["expiry_date"] = expiryDate;
        data["warranty_number"] = warrantyNumber;
        data["service_cycle"] = serviceCycle;
      }
      data["free_service"] = freeService;
      data["paid_service"] = paidService;
      if (serviceCycle == "N Days") {
        data["no_of_days"] = serviceNoOfDays;
      } else if (serviceCycle == "Weekly") {
        data["weeks"] = serviceWeeks;
      } else if (serviceCycle == "Monthly") {
        data["month_days"] = serviceMonthDays;
      } else if (serviceCycle == "Yearly") {
        data["year_days"] = serviceYearDays;
        data["year_month"] = serviceYearMonth;
      }
      if (pipelines != null && pipelines.isNotEmpty) {
        data["pipelines"] = jsonEncode(pipelines);
      }
      if (complaints != null && complaints.isNotEmpty) {
        data["complaints"] = jsonEncode(complaints);
      }
    } else if (productType == "Material") {
      data["selling_price"] = sellingPrice;
      data["hsnSacCode"] = hsnCode;
      data["unit"] = unit ?? "";
      data["unit_id"] = unitId ?? "";
    } else {
      data["selling_price"] = sellingPrice;
      data["hsn_code"] = hsnCode;
      data["expiry_days"] = expiryDays;
    }

    var formData = FormData.fromMap(data);
    try {
      var result = await _dio.post("${await Config.getUrl()}postProduct",
          data: formData);
      if (result.statusCode == 200) {
        PostProductModel response = PostProductModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getProductById(String id) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": id});
    try {
      var result = await _dio.post("${await Config.getUrl()}getProductById",
          data: formData);
      if (result.statusCode == 200) {
        
        print("product by id response: ${result.data}");
        ProdectsByIdModel response = ProdectsByIdModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateProduct(
    String contentId,
    String categoryId,
    String subCategoryId,
    String productName,
    String productCode,
    String productUCode,
    String productMrp,
    String noOfDays,
    String remindBefore,
    String sellingPrice,
    String purchasePrice,
    String barcode,
    String taxPercent,
    String totalAmount,
    String description,
    productImage,
    String productId, {
    String productType = "",
    String brand = "",
    String discount = "",
    String expiryDays = "",
    String addStock = "0",
    String checkStock = "0",
    String openingStock = "",
    String currentStock = "",
    String stockStatus = "In Stock",
    String unit = "",
    String unitId = "",
    bool hasWarranty = false,
    List<String>? pipelines,
    bool addPublish = false,
    String publishStatus = "Published",
    String visibility = "Public",
    String? expiryDate,
    String? warrantyNumber,
    String? serviceCycle,
    String? freeService,
    String? paidService,
    List<Map<String, dynamic>>? complaints,
    String? serviceNoOfDays,
    String? serviceWeeks,
    String? serviceMonthDays,
    String? serviceYearDays,
    String? serviceYearMonth,
  }) async {
    Map<String, dynamic> data = {
      "token": await Common.getSharedPref('token'),
      "content_id": contentId,
      "category_id": categoryId,
      "sub_category_id": subCategoryId,
      "product_name": productName,
      "product_code": productCode,
      "product_u_code": productUCode,
      "product_mrp": productMrp,
      "no_of_days": noOfDays,
      "remind_before": remindBefore,
      "purchase_price": purchasePrice,
      "purchase_amount": purchasePrice,
      "barcode": barcode,
      "bar_code": barcode,
      "tax_percent": taxPercent,
      "total_amount": totalAmount,
      "description": description,
      "product_type": productType,
      "brand": brand,
      "discount": discount,
      "add_stock": addStock,
      "check_stock": checkStock,
      "opening_stock": openingStock,
      "current_stock": currentStock,
      "stock_status": stockStatus,
      "row_id": productId,
    };

    if (productImage != null &&
        productImage != "null" &&
        productImage != "" &&
        !productImage.toString().startsWith("http")) {
      data["product_image"] =
          await MultipartFile.fromFile(productImage.toString());
    }

    if (productType == "Rental") {
      data["rentalPrice"] = sellingPrice;
      data["hsnSacCode"] = productCode;
      data["unit"] = unit;
      data["unit_id"] = unitId;
      data["is_publish"] = addPublish ? 1 : 0;
      if (addPublish) {
        data["publish_status"] = publishStatus;
        data["visibility"] = visibility;
      }
    } else if (productType == "Ecommerce") {
      data["selling_price"] = sellingPrice;
      data["hsn_code"] = productCode;
      data["unit"] = unit;
      data["unit_id"] = unitId;
      data["is_publish"] = addPublish ? 1 : 0;
      if (addPublish) {
        data["publish_status"] = publishStatus;
        data["visibility"] = visibility;
      }
    } else if (productType == "Service") {
      data["selling_price"] = sellingPrice;
      data["sacCode"] = productCode;
      data["warranty"] = hasWarranty ? "Yes" : "No";
      if (hasWarranty) {
        data["expiry_date"] = expiryDate;
        data["warranty_number"] = warrantyNumber;
        data["service_cycle"] = serviceCycle;
      }
      data["free_service"] = freeService;
      data["paid_service"] = paidService;
      if (serviceCycle == "N Days") {
        data["no_of_days"] = serviceNoOfDays;
      } else if (serviceCycle == "Weekly") {
        data["weeks"] = serviceWeeks;
      } else if (serviceCycle == "Monthly") {
        data["month_days"] = serviceMonthDays;
      } else if (serviceCycle == "Yearly") {
        data["year_days"] = serviceYearDays;
        data["year_month"] = serviceYearMonth;
      }
      if (pipelines != null && pipelines.isNotEmpty) {
        data["pipelines"] = jsonEncode(pipelines);
      }
      if (complaints != null && complaints.isNotEmpty) {
        data["complaints"] = jsonEncode(complaints);
      }
    } else if (productType == "Material") {
      data["selling_price"] = sellingPrice;
      data["hsnSacCode"] = productCode;
      data["unit"] = unit;
      data["unit_id"] = unitId;
    } else {
      data["selling_price"] = sellingPrice;
      data["hsn_code"] = productCode;
      data["expiry_days"] = expiryDays;
    }

    var formData = FormData.fromMap(data);
    try {
      var result = await _dio.post("${await Config.getUrl()}updateProduct",
          data: formData);
      if (result.statusCode == 200) {
        PostProductModel response = PostProductModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteProduct(String id) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": id});
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteProduct",
          data: formData);
      if (result.statusCode == 200) {
        DeleteProductModel response = DeleteProductModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postProductCategory(String categoryName) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_name": categoryName
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}postProductCategory", data: formData);
      if (result.statusCode == 200) {
        PostProductCategoryModel response =
            PostProductCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateProductCategory(String categoryName, String rowId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_name": categoryName,
      "row_id": rowId
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}updateProductCategory",
          data: formData);
      if (result.statusCode == 200) {
        UpdateProductCategoryModel response =
            UpdateProductCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteProductCategory(String rowId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": rowId});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}deleteProductCategory",
          data: formData);
      if (result.statusCode == 200) {
        DeleteProductCategoryModel response =
            DeleteProductCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postProductSubCategory(
      String categoryId, String subCategory) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_id": categoryId,
      "sub_category": subCategory
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        PostProductSubCategoryModel response =
            PostProductSubCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateProductSubCategory(
      String subCategory, String rowId, String catId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_id": catId,
      "sub_category": subCategory,
      "row_id": rowId
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}updateProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        UpdateProductSubCategoryModel response =
            UpdateProductSubCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteProductSubCategory(String rowId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": rowId});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}deleteProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        DeleteProductSubCategoryModel response =
            DeleteProductSubCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  /// product mannagement ///

  /// whatsapp Profile

  static addCampaignContact(
    String campaignId,
    String contactName,
    String countryCode,
    String contactNumber,
  ) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "campaign_id": campaignId,
        "contact_name": contactName,
        "country_code": countryCode,
        "contact_number": contactNumber,
      });
      var response = await _dio.post(
          "${await Config.getUrl()}add_contact_to_campaign",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel addContact =
            CampaignSampleModel.fromJson(response.data);
        return addContact;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static editGroupName(String groupId, String groupName, String mobile) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "group_id": groupId,
        "group_name": groupName,
        "mobile": mobile,
      });
      var response = await _dio.post("${await Config.getUrl()}edit_campaign",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel campaignEdit =
            CampaignSampleModel.fromJson(response.data);
        return campaignEdit;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static removeContactCampaign(
    String id,
  ) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "id": id,
      });
      var response = await _dio.post(
          "${await Config.getUrl()}remove_contact_from_campaign",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel removeContact =
            CampaignSampleModel.fromJson(response.data);
        return removeContact;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static deleteWhatsAppGroup(
    String id,
  ) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "group_id": id,
      });
      var response = await _dio.post("${await Config.getUrl()}delete_group",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel deleteGroup =
            CampaignSampleModel.fromJson(response.data);
        return deleteGroup;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static viewMessageStatus(String id, String messageId) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "group_id": id,
        "message_id": messageId
      });
      var response = await _dio
          .post("${await Config.getUrl()}view_message_status", data: formData);
      if (response.statusCode == 200) {
        MessageViewStatusModel getResponse =
            MessageViewStatusModel.fromJson(response.data);
        return getResponse;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  ///------ Expense ------///
  static Future expenseList(fdate, tdate, page, pageSize, catId, headId,
      staffId, fromHeadIds, toHeadIds, searchKey) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "from_date": fdate == "Tap to select" ? "" : fdate,
      "to_date": tdate == "Tap to select" ? "" : tdate,
      "page": page,
      "page_size": pageSize,
      "category_id": catId,
      "head_id": headId,
      "staff_id": staffId,
      "from_ids": fromHeadIds,
      "to_ids": toHeadIds,
      "search_key": searchKey
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}expense_list",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpenseListModel model = ExpenseListModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future expenseMasterData() async {
    var params = {
      "token": await Common.getSharedPref('token'),
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}expense_master_data",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpenseMasterData model = ExpenseMasterData.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future<PendingResponse?> pendingExpenseMasterData(
      Map<String, dynamic> data) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      ...data,
    };

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}add_pending_expense",
        data: FormData.fromMap(params),
      );

      if (result.statusCode == 200) {
        return PendingResponse.fromJson(result.data);
      }
    } catch (e) {
      log("error in pendingExpenseMasterData: $e");
      rethrow;
    }
    return null;
  }

  static Future postExpense(
    String catId,
    String amount,
    String fromAcc,
    String toAcc,
    String date,
    String remarks,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryId": catId,
      "amount": amount,
      "fromAccount": fromAcc,
      "toPerson": toAcc,
      "date": date,
      "remarks": remarks,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}add_expense",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateExpense(
    String expId,
    String catId,
    String amount,
    String fromAcc,
    String toAcc,
    String date,
    String remarks,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "cmpExpId": expId,
      "categoryId": catId,
      "amount": amount,
      "fromAccount": fromAcc,
      "toPerson": toAcc,
      "date": date,
      "remarks": remarks,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}edit_expense",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteExpense(
    String expId,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "cmpnyExId": expId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_expense",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future expenseCategoryList() async {
    var params = {
      "token": await Common.getSharedPref('token'),
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}list_expense_category",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpenseCategoryList model = ExpenseCategoryList.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getBankAccountDetails(fdate, tdate, staff) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "staff": staff,
      "from_date": fdate,
      "to_date": tdate
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getBankAccountDetails",
          data: formData);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        BankAccountList model = BankAccountList.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getCustomerLog(custId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "customer_id": custId,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getCustomerLogHistory",
          data: formData);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CustomerLogModel model = CustomerLogModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getPendingExpense(status,
      {String? fromDate, String? toDate}) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "status": status,
      "from_date": fromDate,
      "to_date": toDate,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getPendingExpense",
          data: formData);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        PendingExpenseModel model = PendingExpenseModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getAccountHead() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}getAccountHeadLists", data: formData);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        AccountHeadModel model = AccountHeadModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addExpenseCategory(
    String cat,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryName": cat,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}expense_category_add",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateExpenseCategory(String cat, String catId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryName": cat,
      "categoryId": catId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}expense_category_edit",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteExpenseCategory(String catId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryId": catId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}expense_category_delete",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future expenseHistory(String expId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "expense_id": expId
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}expense_history",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensehistoryModel model = ExpensehistoryModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future accountsDashboard(fDate, tdate) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "fromDate": fDate,
      "toDate": tdate
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}expense_dashboard",
          data: formData);
      if (result.statusCode == 200) {
        AccountDashboardModel model =
            AccountDashboardModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getSearchData(String searchKey,
      {int page = 1, int pageSize = 10}) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "searchKey": searchKey,
      "page": page,
      "page_size": pageSize
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getSearchData",
          data: formData);
      if (result.statusCode == 200) {
        SearchDataModel model = SearchDataModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getRenewalFollowUp(
      fdate, tdate, page, pageSize, products, clientId, status) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "from_date": fdate == "Tap to select" ? "" : fdate,
      "to_date": tdate == "Tap to select" ? "" : tdate,
      "page": page,
      "page_size": pageSize,
      "product_id": jsonEncode(products),
      "client_id": clientId,
      "renewal_status": status
    });
    try {
      log(products.toString());
      var result = await _dio.post("${await Config.getUrl()}getRenewalFollowUp",
          data: formData);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        RenewalFollowupListModel model =
            RenewalFollowupListModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postBranch(
    String branch,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "branch_name": branch,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}postBranch",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateBranch(String branch, String branchId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "branch_name": branch,
      "branch_id": branchId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}expense_category_edit",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        CommonResponse model = CommonResponse.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getWhatsappGroupid(
      String name, String countryCode, String phoneNumber) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "client_name": name,
      "country_code": countryCode,
      "phone_number": phoneNumber
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}getChatId", data: formData);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        GetWhatsappChat model = GetWhatsappChat.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getWhatsappContacts(
      int page, int pageSize, String searchKey) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "page": page,
      "page_size": pageSize,
      "search_key": searchKey
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getContacts",
          data: formData);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        WhatsappContacts model = WhatsappContacts.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future<WorkCompanyDetailsModel?> getWorkCompanyStatusDetails(
      String date) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "date": date,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}get_companyworkstatus_details",
          data: formData);
      if (result.statusCode == 200) {
        return WorkCompanyDetailsModel.fromJson(result.data);
      }
    } catch (e) {
      log("error: $e");
    }
    return null;
  }

// static Future<void> submitTitle({
//   required BuildContext context,
//   required String projectId,
//   required String title,
// }) async {
//   var response = await _dio.post("${await Config.getUrl()}submitttitle", data: {
//     'project_id': projectId,
//     'title': title,
//   });

//   if (response.statusCode == 200) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Title Added Successfully',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.green,
//       ),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Failed to submit title',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }

  static Future<TitleListDet?> submitTitle({
    required BuildContext context,
    required String projectId,
    required String title,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'project_id': projectId,
        'title': title,
      });

      var response = await _dio.post(
        "${await Config.getUrl()}submitttitle",
        data: formData,
        options: Options(
          contentType: 'multipart/form-data', // important
        ),
      );

      final responseData =
          response.data is String ? json.decode(response.data) : response.data;

      print("RESPONSE DATA: $responseData");

      if (response.statusCode == 200 && responseData['status'] == true) {
        final data = responseData["data"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Title Added Successfully',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        return TitleListDet(
          id: data["id"].toString(),
          name: data["name"].toString(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData["message"] ?? 'Failed to submit title',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }
  static Future<TitleListDet?> submitModule({
  required BuildContext context,
  required String leadId,
  required String title,
}) async {
  try {
    final token = await Common.getSharedPref("token");

    FormData formData = FormData.fromMap({
      'token': token,
      'lead_id': leadId,
      'title': title,
    });

    var response = await _dio.post(
      "${await Config.getUrl()}submitttitle",
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final responseData =
        response.data is String ? json.decode(response.data) : response.data;

    print("RESPONSE DATA: $responseData");

    if (response.statusCode == 200 &&
    responseData['status'] == true) {
  final data = responseData["data"];

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Module Added Successfully',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    ),
  );

  return TitleListDet(
    id: data["id"]?.toString() ?? '',
    name: data["name"]?.toString() ?? '',
  );
} else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            responseData["message"] ?? 'Failed to add module',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: $e',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  return null;
}
  static Future<CommonResponse?> startWork(
    DateTime startTime, {
    required double latitude,
    required double longitude,
    required String? faceData,
  }) async {
    var body = {
      "token": await Common.getSharedPref("token"),
      "start_time": startTime.toIso8601String(),
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      'face_data': faceData ?? '',
    };

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}start_work",
        data: body,
      );
      CommonResponse model = CommonResponse.fromJson(result.data);
      return model;
    } catch (e) {
      log("Error in startWork: $e");
      return null;
    }
  }

  static Future<CommonResponse?> stopWork(
    DateTime endTime, {
    required double latitude,
    required double longitude,
    String? ideal_time,
    String? work_time,
  }) async {
    var body = {
      "token": await Common.getSharedPref("token"),
      "end_time": endTime.toIso8601String(),
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "ideal_time": ideal_time,
      "work_time": work_time,
    };
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}stop_work",
        data: body,
      );
      CommonResponse model = CommonResponse.fromJson(result.data);
      return model;
    } catch (e) {
      log("Error in startWork: $e");
      return null;
    }
  }

  static Future<WorkLoginAndOutModel?> getLoginAndLogout(
      String staffId, String date) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
      "staff_id": staffId,
      "current_date": date,
    });
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getLoginAndLogout",
        data: formData,
      );
      if (result.statusCode == 200 && result.data != null) {
        return WorkLoginAndOutModel.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getLoginAndLogout error: $e");
    }
    return null;
  }

  static Future<CommonResponse?> postLeadCategory(
      String leadName, String cost, String? subcategory) async {
    final token = await Common.getSharedPref('token');
    final data = {
      "token": token,
      "lead_category": leadName,
      "cost": cost,
      "sub_category": subcategory?.trim() ?? "",
    };

    try {
      final result = await _dio.post(
        "${await Config.getUrl()}postLeadCategory",
        data: FormData.fromMap(data),
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        return CommonResponse.fromJson(result.data);
      }
    } catch (e) {
      log("postLeadCategory error: $e");
    }
    return null;
  }

  static Future<CommonResponse?> postLeadSource(
    String leadSourceName,
  ) async {
    final token = await Common.getSharedPref('token');
    final data = {
      "token": token,
      "lead_source": leadSourceName,
    };

    try {
      final result = await _dio.post(
        "${await Config.getUrl()}postSource",
        data: FormData.fromMap(data),
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        return CommonResponse.fromJson(result.data);
      }
    } catch (e) {
      log("postLeadSource error: $e");
    }
    return null;
  }

  static Future<CommonResponse?> addStaffDisable({
    required String staffId,
  }) async {
    final token = await Common.getSharedPref('token');
    final data = {
      "token": token,
      "staff_id": staffId,
    };

    try {
      final result = await _dio.post(
        "${await Config.getUrl()}disableStaff",
        data: FormData.fromMap(data),
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        return CommonResponse.fromJson(result.data);
      }
    } catch (e) {
      log("addStaffDisable error: $e");
    }
    return null;
  }

  static Future<CommonResponse?> addCategoryExpense({
    required String newCategory,
  }) async {
    final token = await Common.getSharedPref('token');
    final data = {
      "token": token,
      "new_catgeory": newCategory,
    };

    try {
      final result = await _dio.post(
        "${await Config.getUrl()}addNewExpenseCategory",
        data: FormData.fromMap(data),
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        return CommonResponse.fromJson(result.data);
      }
    } catch (e) {
      log("addStaffDisable error: $e");
    }
    return null;
  }

  static Future<CommonResponse?> addAccountHead({
    required String accountType,
    required String accountName,
    required String personName,
    required String phone,
    required String address,
    required String email,
    required String purpose,
    required String remark,
    required String openingBalance,
    required String openingBalanceType,
    required bool isImportant,
  }) async {
    final token = await Common.getSharedPref('token');
    final data = {
      "token": token,
      "account_type": accountType,
      "account_name": accountName,
      "person_name": personName,
      "phone": phone,
      "address": address,
      "email": email,
      "purpose": purpose,
      "remark": remark,
      "opening_balance": openingBalance,
      "balance_type": openingBalanceType,
      "is_important": isImportant ? "Y" : "N",
    };

    try {
      final result = await _dio.post(
        "${await Config.getUrl()}addAccountHead",
        data: FormData.fromMap(data),
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      if (result.statusCode == 200) {
        return CommonResponse.fromJson(result.data);
      }
    } catch (e) {
      log("addAccountHead error: $e");
    }
    return null;
  }

  static Future<StaffListModel?> getStaffs() async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_staffs",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return StaffListModel.fromJson(response.data);
      } else {
        log("getStaffs failed: ${response.data}");
      }
    } catch (e) {
      log("getStaffs error: $e");
    }
    return null;
  }

  static Future<StaffListModel?> getWorkedStaffs(String date) async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
        'date': date,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_worked_staffs",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return StaffListModel.fromJson(response.data);
      } else {
        log("getStaffs failed: ${response.data}");
      }
    } catch (e) {
      log("getStaffs error: $e");
    }
    return null;
  }

  static Future<StaffListModel?> getStaffsAccessible() async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_staffs_accessible",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return StaffListModel.fromJson(response.data);
      } else {
        log("getStaffs failed: ${response.data}");
      }
    } catch (e) {
      log("getStaffs error: $e");
    }
    return null;
  }

  static Future<StaffListModel?> getStaffsTelecaller() async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_telecaller_list",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        // print("Telecaller List Response: ${response.data}");
        return StaffListModel.fromJson(response.data);
      } else {
        log("getStaffs failed: ${response.data}");
      }
    } catch (e) {
      log("getStaffs error: $e");
    }
    return null;
  }

  static Future<StaffListModel?> getStaffsSomeof() async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}getAccessibleStaffs",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return StaffListModel.fromJson(response.data);
      } else {
        log("getStaffs failed: ${response.data}");
      }
    } catch (e) {
      log("getStaffs error: $e");
    }
    return null;
  }

  static Future<CustomerExpenseListModel?> getCustomers() async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_customers",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return CustomerExpenseListModel.fromJson(response.data);
      } else {
        log("getCustomers failed: ${response.data}");
      }
    } catch (e) {
      log("getCustomers error: $e");
    }
    return null;
  }

  static Future<ProjectListCustModel?> getProjectsLists() async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_projects_customers",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ProjectListCustModel.fromJson(response.data);
      } else {
        log("getCustomers failed: ${response.data}");
      }
    } catch (e) {
      log("getCustomers error: $e");
    }
    return null;
  }

  static Future<AttendanceDataModel?> getAttendanceData(
      String staffId, String yearMonth,
      {required String monthYear}) async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
        'staff_id': staffId,
        'month': yearMonth,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_staff_calendar_data",
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200 && response.data['status'] == "success") {
        return AttendanceDataModel.fromJson(response.data);
      } else {
        log("Server returned error: ${response.statusCode} ${response.data}");
      }
    } catch (e, stacktrace) {
      log("getAttendanceData error: $e");
      log("Stacktrace: $stacktrace");
    }
    return null;
  }

  static Future<bool> saveWork({
    required String staffId,
    required String date,
    required String workStatus,
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final formData = FormData.fromMap({
        'token': token,
        'staff_id': staffId,
        'date': date,
        'work_status': workStatus,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}save_work_status",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      }
    } catch (e) {
      log("saveWork error: $e");
    }
    return false;
  }

  static Future<bool> saveLeave({
    required String staffId,
    required String date,
    required String remarks,
    required String leaveType,
    required bool isHalfDay,
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final formData = FormData.fromMap({
        'token': token,
        'staff_id': staffId,
        'date': date,
        'remarks': remarks,
        'leave_type': leaveType,
        'half_day': isHalfDay ? "1" : "0",
      });

      final response = await _dio.post(
        "${await Config.getUrl()}save_leave",
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return true;
      }
    } catch (e) {
      log("saveLeave error: $e");
    }
    return false;
  }

  static Future<bool> saveLeaveOfficial({
    //  required String staffId,
    required String date,
    required String remarks,
    required String leaveType,
    required bool isHalfDay,
    String? session,
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final formData = FormData.fromMap({
        'token': token,
        //'staff_id': staffId,
        'date': date,
        'remarks': remarks,
        'leave_type': leaveType,
        'half_day': isHalfDay ? "1" : "0",
        //if (session != null) 'half_day_session': session,
        if (session != null) 'session': session,
        // if (session != null) 'half_day_type': session,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}save_leave_official",
        data: formData,
      );

      if (response.statusCode == 200) {
        var status = response.data['status'];
        if (status == true ||
            status == 'success' ||
            status == 'true' ||
            status == 1 ||
            status == '1') {
          return true;
        } else {
          log("saveLeaveOfficial failure: ${response.data['message']}");
        }
      } else {
        log("saveLeaveOfficial HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("saveLeave error: $e");
    }
    return false;
  }

  static Future<TargetDetails?> getTargetDetails(
      String groupId, String fromDate, String toDate) async {
    var token = await Common.getSharedPref('token');
    try {
      // FormData formData = FormData.fromMap({
      //   'token': token,
      //   'group_id': groupId,

      // });
      FormData formData = FormData.fromMap({
        'token': token,
        'group_id': groupId,
        'from_date': fromDate,
        'to_date': toDate,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_target_details",
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return TargetDetails.fromJson(response.data);
      } else {
        log("Server returned error: ${response.statusCode} ${response.data}");
      }
    } catch (e, stacktrace) {
      log("getAttendanceData error: $e");
      log("Stacktrace: $stacktrace");
    }
    return null;
  }

  static Future<StaffWorkSummery?> getAllDoneworks(String date) async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
        'date': date,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}staff_work_summary",
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          return StaffWorkSummery.fromJson(response.data);
        } else {
          log("API returned failure status: ${response.data['message']}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      log("getAllDoneworks error: $e");
      log("Stacktrace: $stacktrace");
    }
    return null;
  }

  static Future<StaffCallSummery?> getAllDonecalls(String date) async {
    var token = await Common.getSharedPref('token');
    try {
      FormData formData = FormData.fromMap({
        'token': token,
        'date': date,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}staff_call_summary",
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          return StaffCallSummery.fromJson(response.data);
        } else {
          log("API returned failure status: ${response.data['message']}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      log("getAllDoneworks error: $e");
      log("Stacktrace: $stacktrace");
    }

    return null;
  }

  static Future<TargetGroupModel?> getAllTargetReport(
      String fromDate, String toDate) async {
    var token = await Common.getSharedPref('token');

    try {
      FormData formData = FormData.fromMap({
        'token': token,
        'from_date': fromDate,
        'to_date': toDate,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_target_group_report",
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return TargetGroupModel.fromJson(response.data);
        } else {
          log("API returned failure status: ${response.data['message']}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      log("getAllTargetReport error: $e");
      log("Stacktrace: $stacktrace");
    }
    return null;
  }

  static Future<bool> addProjectsCustomers({
    required String customerId,
    required String projectName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final formMap = {
        'token': token,
        'customer_id': customerId,
        'project_name': projectName,
      };
      if (startDate != null) {
        formMap['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
      }
      if (endDate != null) {
        formMap['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);
      }
      final response = await _dio.post(
        "${await Config.getUrl()}addProjectCustomer",
        data: FormData.fromMap(formMap),
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        print("❌ Failed: ${response.data}");
        return false;
      }
    } catch (e) {
      print("🔥 Error adding project: $e");
      return false;
    }
  }

  static Future<bool> updateProject({
    required String id,
    required String customerId,
    required String projectName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await Common.getSharedPref('token');
    try {
      final formMap = {
        'token': token,
        'id': id,
        'customer_id': customerId,
        'project_name': projectName,
      };

      if (startDate != null) {
        formMap['from_date'] = DateFormat('yyyy-MM-dd').format(startDate);
      }
      if (endDate != null) {
        formMap['to_date'] = DateFormat('yyyy-MM-dd').format(endDate);
      }

      final response = await _dio.post(
        "${await Config.getUrl()}update_project",
        data: FormData.fromMap(formMap),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        log("❌ Update failed: ${response.data}");
        return false;
      }
    } catch (e) {
      log("🔥 Error updating project: $e");
      return false;
    }
  }

  static Future<bool> deleteProject(String id) async {
    final token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_project_customer",
        data: FormData.fromMap({
          'token': token,
          'id': id,
        }),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        log("❌ Delete failed: ${response.data}");
        return false;
      }
    } catch (e) {
      log("🔥 Error deleting project: $e");
      return false;
    }
  }

  static Future<bool> markHoliday({
    required String date,
    required String name,
    String? description,
  }) async {
    final token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}mark_holiday",
        data: FormData.fromMap({
          'token': token,
          'date': date,
          'name': name,
          'description': description ?? '',
        }),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        log("❌ Mark holiday failed: ${response.data}");
        return false;
      }
    } catch (e) {
      log("🔥 Error in markHoliday: $e");
      return false;
    }
  }

  static Future<bool> markLeave({
    required String date,
    required List<String> staffIds,
    required String leaveType,
    required String reason,
    required bool isHalfDay,
  }) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}mark_leave",
        data: FormData.fromMap({
          'token': token,
          'date': date,
          'staff_ids': staffIds.join(','),
          'leave_type': leaveType,
          'reason': reason,
          'half_day': isHalfDay ? '1' : '0',
        }),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        log("❌ Mark leave failed: ${response.data}");
        return false;
      }
    } catch (e) {
      log("🔥 Error in markLeave: $e");
      return false;
    }
  }

  static Future<bool> markAttendance({
    required String date,
    required List<String> staffIds,
    required bool isHalfDay,
  }) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}mark_attendance",
        data: FormData.fromMap({
          'token': token,
          'date': date,
          'staff_ids': staffIds.join(','),
          'half_day': isHalfDay ? '1' : '0',
        }),
      );
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      log("🔥 Error in markAttendance: $e");
      return false;
    }
  }

  static Future<AttendanceDataAllModel?> getAttendanceAllData(
      {required String date}) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_totalattendance",
        data: FormData.fromMap({
          'token': token,
          'date': date,
        }),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return AttendanceDataAllModel.fromJson(response.data);
      } else {
        log("❌ Invalid response: ${response.data}");
        return null;
      }
    } catch (e) {
      log("🔥 Error fetching attendance data: $e");
      return null;
    }
  }

  static Future<CalendarDataAllModel?> getMonthyearWork(
      {required String monthyear}) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_monthly_calendar_data",
        data: FormData.fromMap({
          'token': token,
          'monthyear': monthyear,
        }),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return CalendarDataAllModel.fromJson(response.data);
      } else {
        log("❌ Invalid response: ${response.data}");
        return null;
      }
    } catch (e) {
      log("🔥 Error fetching attendance data: $e");
      return null;
    }
  }

  static Future<bool> deleteHoliday({
    required String date,
  }) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_holiday",
        data: FormData.fromMap({
          'token': token,
          'date': date,
        }),
      );
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      log("🔥 Error in markAttendance: $e");
      return false;
    }
  }

  static Future<DailyDataModel?> getDailyCount({required String date}) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_dailycount",
        data: FormData.fromMap({
          'token': token,
          'date': date,
        }),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return DailyDataModel.fromJson(response.data);
      } else {
        log("❌ Invalid response: ${response.data}");
        return null;
      }
    } catch (e) {
      log("🔥 Error fetching attendance data: $e");
      return null;
    }
  }

  static Future<SalaryList?> getSalaryList({required String monthYear}) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_salary_report",
        data: FormData.fromMap({
          'token': token,
          'monthyear': monthYear,
        }),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return SalaryList.fromJson(response.data);
      } else {
        log("❌ Invalid response: ${response.data}");
        return null;
      }
    } catch (e) {
      log("🔥 Error fetching salary list: $e");
      return null;
    }
  }

  static Future<SalaryDetailsModel?> getSalaryDetails(String id) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_salary_summary",
        data: FormData.fromMap({
          "token": token,
          "id": id,
        }),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return SalaryDetailsModel.fromJson(response.data);
      } else {
        debugPrint("❌ Failed response: ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Error fetching salary details: $e");
      return null;
    }
  }

  static Future<bool> saveStaffAccounts({
    required String userId,
    required String salary,
    required String openingBalance,
    required String openingDate,
    required String type,
    required String isSalary,
    required String isPettyCash,
    String? pettyOpeningBalance,
    String? pettyOpeningDate,
    String? pettyType,
  }) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}saveStaffAccounts",
        data: FormData.fromMap({
          "token": token,
          "staff_id": userId,
          "salary": salary,
          "is_salary": isSalary,
          "opening_balance": openingBalance,
          "opening_date": openingDate,
          "type": type,
          "is_petty_cash": isPettyCash,
          if (isPettyCash == "1") "petty_opening_balance": pettyOpeningBalance,
          if (isPettyCash == "1") "petty_opening_date": pettyOpeningDate,
          if (isPettyCash == "1") "petty_type": pettyType,
        }),
      );
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      debugPrint("🔥 Error adding salary details: $e");
      return false;
    }
  }

  // static Future<StaffSummaryReport?> pendingStaffWorks(
  //     {Map<String, dynamic>? filters}) async {
  //   final token = await Common.getSharedPref('token');
  //   debugPrint("📤 Sending token: $token, filters: $filters");

  //   try {
  //     final formMap = {
  //       "token": token,
  //       if (filters != null) ...filters,
  //     };

  //     final response = await _dio.post(
  //       "${await Config.getUrl()}staffwise_pending_works",
  //       data: FormData.fromMap(formMap),
  //     );

  //     debugPrint("📥 Raw response: ${response.data}");

  //     if (response.statusCode == 200 && response.data['status'] == true) {
  //       return StaffSummaryReport.fromJson(response.data);
  //     } else {
  //       debugPrint("❌ API error or status false: ${response.data}");
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint("🔥 Exception in pendingStaffWorks: $e");
  //     return null;
  //   }
  // }

  static Future<StaffSummaryReport?> pendingStaffWorks({
    Map<String, dynamic>? filters,
  }) async {
    final token = await Common.getSharedPref('token');
    final formData = FormData();
    formData.fields.add(MapEntry('token', token ?? ''));

    if (filters != null) {
      filters.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            formData.fields.add(MapEntry('$key[]', item.toString()));
          }
        } else if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });
    }
    try {
      final response = await _dio.post(
        '${await Config.getUrl()}staffwise_pending_works',
        data: formData,
      );
      debugPrint("📥 Raw response: ${response.data}");
      if (response.statusCode == 200 && response.data['status'] == true) {
        return StaffSummaryReport.fromJson(response.data);
      } else {
        debugPrint("❌ API error or status false: ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Exception in pendingStaffWorks: $e");
      return null;
    }
  }

  static Future<ProjectPendingReport?> pendingProjectWorks(
      {String? date}) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}projectwise_pending",
        data: FormData.fromMap({
          "token": token,
          if (date != null) "date": date,
        }),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return ProjectPendingReport.fromJson(response.data);
      } else {
        debugPrint("❌ Project Pending Error: ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Exception in pendingProjectWorks: $e");
      return null;
    }
  }

  static Future<TaskStatus?> getTaskState() async {
    //   var token = await Common.getSharedPref('token');
    try {
      // FormData formData = FormData.fromMap({
      //   'token': token,
      // });

      final response = await _dio.post(
        "${await Config.getUrl()}get_work_status",
        // data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return TaskStatus.fromJson(response.data);
      } else {
        log("getStaffs failed: ${response.data}");
      }
    } catch (e) {
      log("getStaffs error: $e");
    }
    return null;
  }

  static Future<PriorityStatus?> getPrioState() async {
    //   var token = await Common.getSharedPref('token');
    try {
      // FormData formData = FormData.fromMap({
      //   'token': token,
      // });

      final response = await _dio.post(
        "${await Config.getUrl()}get_priority_list",
        // data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return PriorityStatus.fromJson(response.data);
      } else {
        log("getStaffs failed: ${response.data}");
      }
    } catch (e) {
      log("getStaffs error: $e");
    }
    return null;
  }

  // static Future<List<AssignedWork>> getAssignedWorks(
  //     {Map<String, dynamic>? filters}) async {
  //   final token = await Common.getSharedPref('token');
  //   final formData = {
  //     'token': token,
  //     if (filters != null) ...filters,
  //   };
  //   final response = await _dio.post(
  //     '${await Config.getUrl()}get_assigned_worklist',
  //     data: FormData.fromMap(formData),
  //   );
  //   if (response.statusCode == 200 && response.data['status'] == true) {
  //     List data = response.data['data'];
  //     return data.map((e) => AssignedWork.fromJson(e)).toList();
  //   } else {
  //     throw Exception('Failed to fetch assigned works');
  //   }
  // }

  // static Future<List<AssignedWork>> getAssignedWorks(
  //     {Map<String, dynamic>? filters,String?sectionId}) async {
  //   final token = await Common.getSharedPref('token');
  //   final formData = FormData();
  //   formData.fields.add(MapEntry('token', token ?? ''));
  //     if (sectionId != null && sectionId.isNotEmpty) {
  //   formData.fields.add(MapEntry('section_id', sectionId));
  // }

  //   if (filters != null) {
  //     filters.forEach((key, value) {
  //       if (value is List) {
  //         for (var item in value) {
  //           formData.fields.add(MapEntry('$key[]', item.toString()));
  //         }
  //       } else if (value != null) {
  //         formData.fields.add(MapEntry(key, value.toString()));
  //       }
  //     });
  //   }
  //   final response = await _dio.post(
  //     '${await Config.getUrl()}get_assigned_worklist',
  //     data: formData,
  //   );
  //   if (response.statusCode == 200 && response.data['status'] == true) {
  //     List data = response.data['data'];
  //     return data.map((e) => AssignedWork.fromJson(e)).toList();
  //   } else {
  //     throw Exception('Failed to fetch assigned works');
  //   }
  // }

  static Future<List<AssignedWork>> getAssignedWorks({
    Map<String, dynamic>? filters,
    String? sectionId,
    String? unassigned,
  }) async {
    final token = await Common.getSharedPref('token');
    final formData = FormData();
    formData.fields.add(MapEntry('token', token ?? ''));

    if (sectionId != null && sectionId.isNotEmpty) {
      formData.fields.add(MapEntry('section_id', sectionId));
    }
    if (unassigned != null && unassigned.isNotEmpty) {
      formData.fields.add(MapEntry('is_unassigned', unassigned));
    }

    if (sectionId != null && sectionId.isNotEmpty) {
      formData.fields.add(MapEntry('section_id', sectionId));
      if (sectionId == "1") {
        filters ??= {};
        if (!filters.containsKey('status_ids') ||
            filters['status_ids'] == null) {
          filters['status_ids'] = ["1"];
        } else if (filters['status_ids'] is List) {
          if (!filters['status_ids'].contains("1")) {
            filters['status_ids'].add("1");
          }
        }
      }
      if (sectionId == "3") {
        filters ??= {};
        if (!filters.containsKey('status_ids') ||
            filters['status_ids'] == null) {
          filters['status_ids'] = ["3"];
        } else if (filters['status_ids'] is List) {
          if (!filters['status_ids'].contains("3")) {
            filters['status_ids'].add("3");
          }
        }
      }
    }

    if (filters != null) {
      filters.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            formData.fields.add(MapEntry('$key[]', item.toString()));
          }
        } else if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });
    }

    final response = await _dio.post(
      '${await Config.getUrl()}get_assigned_worklist',
      data: formData,
    );

    if (response.statusCode == 200 && response.data['status'] == true) {
      List data = response.data['data'];
      return data.map((e) => AssignedWork.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch assigned works');
    }
  }

  static Future<bool> alertWorkNotification(Map<String, String> data) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}alert_work_notification",
        data: FormData.fromMap({
          'token': token,
          ...data,
        }),
      );

      final responseData = jsonDecode(response.data);
      print("🔍 Decoded Response data: $responseData");

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      log("🔥 Error in alertWorkNotification: $e");
      return false;
    }
  }

  static Future<GetWorkMessageModel?> getWorkChatMessages(
      String groupId) async {
    var token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}getWorkMessages",
        data: FormData.fromMap({
          'token': token,
          'group_id': groupId,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return GetWorkMessageModel.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception: $e");
      return null;
    }
  }

  static Future<GetWorkMessageModel?> markRead(String groupId) async {
    var token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}markRead",
        data: FormData.fromMap({
          'token': token,
          'work_id': groupId,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return GetWorkMessageModel.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception: $e");
      return null;
    }
  }

  static Future<bool> sendWorkChatMessage(
    String groupId,
    String message,
    String assignedToId, {
    String whatsappMessage = '0',
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}assigned_work_chat",
        data: FormData.fromMap({
          'token': token,
          'assigned_work_id': groupId,
          'message': message,
          'assigned_to_id': assignedToId,
          'whatsappMessage': whatsappMessage,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      print("🔥 Error sending message: $e");
      return false;
    }
  }

  static Future<CompanyLocationModel?> getCompanyLocations() async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_company_location",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return CompanyLocationModel.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching company location: $e");
      return null;
    }
  }

  static Future<bool> submitCompanyLocation({
    required String companyId,
    required String location,
  }) async {
    var token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}submit_company_location",
        data: FormData.fromMap({
          'token': token,
          'company_id': companyId,
          'location': location,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      print("🔥 Exception while submitting company location: $e");
      return false;
    }
  }

  static Future<bool> submitTarget(Map<String, dynamic> payload) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}submit_target",
        data: FormData.fromMap({
          'token': token,
          ...payload,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      print("🔥 Exception while submitting target: $e");
      return false;
    }
  }

  static Future<IndividualTargetModel?> getIndividualTargets() async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}individualTarget",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return IndividualTargetModel.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching company location: $e");
      return null;
    }
  }

  static Future<GroupTargetModel?> getGroupTargets() async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}groupTarget",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return GroupTargetModel.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching company location: $e");
      return null;
    }
  }

  static Future<CompanyTargetModel?> getCompanyTargets() async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}companyTarget",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return CompanyTargetModel.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching company location: $e");
      return null;
    }
  }

  static Future<bool> removeLocation({
    required String companyId,
    required String nickname,
    required String lat,
    required String lng,
  }) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}deleteLocation",
        data: FormData.fromMap({
          'token': token,
          'company_id': companyId,
          'nickname': nickname,
          'lat': lat,
          'lng': lng,
        }),
      );
      final responseData = jsonDecode(response.data);
      print("🔍 Decoded Response data: $responseData");
      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      log("🔥 Error in removeLocation: $e");
      return false;
    }
  }

  static Future<ProjectCountModel?> dashboardCounts(
      {required String token}) async {
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}work_dashboard",
        data: FormData.fromMap({
          'token': token,
        }),
      );

      final responseData = response.data;

      print("🔍 Decoded Response data: $responseData");

      if (responseData['status'] == true) {
        return ProjectCountModel.fromJson(responseData);
      } else {
        print("❌ Error response: $responseData");
        return null;
      }
    } catch (e) {
      log("🔥 Error in dashboardCounts: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDashboards() async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}getDashboards",
        data: FormData.fromMap({
          'token': token,
        }),
      );
      final responseData = response.data as Map<String, dynamic>;
      print("🔍 Decoded Response data: $responseData");

      if (responseData['status'] == true) {
        return responseData;
      }
      return null;
    } catch (e) {
      log("🔥 Error in getDashboards: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSelectedDashboard() async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}getSelectedDashboard",
        data: FormData.fromMap({
          'token': token,
        }),
      );

      final responseData = response.data as Map<String, dynamic>;
      print("🔍 Decoded Response data: $responseData");

      if (responseData['status'] == true) {
        return responseData;
      }
      return null;
    } catch (e) {
      log("🔥 Error in getSelectedDashboard: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateSelectedDashboard(
      String userId, String dashboardId) async {
    final token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}updateSelectedDashboard",
        data: FormData.fromMap({
          'token': token,
          'user_id': userId,
          'dashboard_id': dashboardId,
        }),
      );
      final responseData = response.data;
      print("🔍 Update dashboard response: $responseData");

      return responseData;
    } catch (e, stack) {
      log("🔥 Error in updateSelectedDashboard: $e\n$stack");
      return null;
    }
  }

  static Future<AttendanceHistoryModel?> getAttendanceHistory({
    required String staffId,
    required DateTime date,
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_history",
        data: FormData.fromMap({
          'token': token,
          'date': DateFormat("dd-MM-yyyy").format(date).toString(),
          'staff_id': staffId,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return AttendanceHistoryModel.fromJson(data);
        } else {
          print("❌ API returned false status: ${data['message']}");
          return null;
        }
      } else {
        print("❌ HTTP error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching attendance history: $e");
      return null;
    }
  }

  static Future<ExpenseTypePending?> get_expense_type() async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_expense_type",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ExpenseTypePending.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching attendance history: $e");
      return null;
    }
  }

  static Future<PendingList?> get_pending_list() async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_pending_list",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return PendingList.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching attendance history: $e");
      return null;
    }
  }

  static Future<UpdatePendingData?> editPendingHistory(
      Map<String, dynamic> data) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      ...data,
    };
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}update_pending_expense",
        data: FormData.fromMap(params),
      );
      if (result.statusCode == 200) {
        return UpdatePendingData.fromJson(result.data);
      }
    } catch (e) {
      print("❌ editPendingHistory error: $e");
    }
    return null;
  }

  static Future<CommonResponse?> deletePendingHistory(String expenseId) async {
    try {
      var params = {
        "token": await Common.getSharedPref('token'),
        "id": expenseId,
      };

      var result = await _dio.post(
        "${await Config.getUrl()}delete_pending_expense",
        data: FormData.fromMap(params),
      );

      if (result.statusCode == 200) {
        return CommonResponse.fromJson(result.data);
      }
    } catch (e) {
      print("❌ delete_pending_expense error: $e");
    }
    return null;
  }

  static Future<bool> sendLogs(Map<String, dynamic> logData) async {
    try {
      final url = "${await Config.getUrl()}send_logs";
      FormData formData = FormData.fromMap(logData);
      Response response = await _dio.post(url, data: formData);
      if (response.statusCode == 200) {
        print("Log sent successfully");
        return true;
      } else {
        print("Failed to send log: ${response.statusCode} ${response.data}");
        return false;
      }
    } catch (e) {
      print("Error sending log: $e");
      return false;
    }
  }

  static Future<StaffReportModel?> get_staff_list() async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_staff_report",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return StaffReportModel.fromJson(response.data);
      } else {
        print("❌ Error response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while fetching attendance history: $e");
      return null;
    }
  }

  static Future<TransferWorkResponse?> transferWork({
    required String workId,
    required List<String> staffIds,
    required String description,
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}transfer_work",
        data: FormData.fromMap({
          'token': token,
          'workId': workId,
          'staffIds': staffIds.join(','),
          'description': description,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      print("🟢 Raw response data type: ${response.data.runtimeType}");
      print("🟢 Raw response data: ${response.data}");
      dynamic responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }
      if (response.statusCode == 200 && responseData['status'] == true) {
        return TransferWorkResponse.fromJson(responseData);
      } else {
        print("❌ Error response: $responseData");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while transferring work: $e");
      return null;
    }
  }

  static Future<TransferWorkResponse?> editAssignedWork({
    required String workId,
    required String projectName,
    required String moduleName,
    required String clientName,
    required String description,
    required String priority,
    required String dueDate,
    required List<String> staffIds,
  }) async {
    var token = await Common.getSharedPref('token');
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}edit_assigned_work",
        data: FormData.fromMap({
          'token': token,
          'work_id': workId,
          'project_name': projectName,
          'module_name': moduleName,
          'client_name': clientName,
          'description': description,
          'priority': priority,
          'due_date': dueDate,
          'staff_ids': staffIds.join(','),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return TransferWorkResponse.fromJson(response.data);
      } else {
        print("❌ Edit work failed: ${response.data}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception while editing work: $e");
      return null;
    }
  }

  static Future<ReceiptListAccountsModel?> receptListAccounts(
    String token,
    String fromDash,
    String custId,
    String fromDate,
    String toDate,
    int page,
    int pageSize,
    String headId,
    String searchKey,
    String type,
  ) async {
    var formData = FormData.fromMap({
      'token': token,
      'from_dashboard': fromDash,
      'cust_id': custId,
      'from_date': fromDate == "From Date" ? "" : fromDate,
      'to_date': toDate == "To Date" ? "" : toDate,
      'page': page,
      'page_size': pageSize,
      'head_id': headId,
      'search_key': searchKey,
      "type": type,
    });

    try {
      final url = "${await Config.getUrl()}getReceiptListsAccounts";
      final result = await _dio.post(url, data: formData);

      if (result.statusCode == 200 && result.data != null) {
        return ReceiptListAccountsModel.fromJson(result.data);
      } else {
        log("API Error: Status Code ${result.statusCode}");
        return null;
      }
    } catch (e) {
      log("Exception @receptListAccounts: $e");
      return null;
    }
  }

  static Future<DocumentListModel?> getDocumentType(String staffId) async {
    try {
      final token = await Common.getSharedPref('token');

      final response = await _dio.post(
        "${await Config.getUrl()}getDocumentTypes",
        data: FormData.fromMap({
          'token': token,
          'staff_id': staffId,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == true) {
          return DocumentListModel.fromJson(data);
        } else {
          print("⚠️ Server returned false status: ${data['message']}");
          return null;
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      print("🔥 Exception while fetching document types: $e");
      print(stackTrace);
      return null;
    }
  }

  static Future<bool> approveProforma(String id) async {
    var token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}approve_proforma",
        data: FormData.fromMap({
          'token': token,
          'id': id,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        print("✅ Proforma approved successfully: ${response.data}");
        return true;
      } else {
        print("❌ Approve proforma failed: ${response.data}");
        return false;
      }
    } catch (e) {
      print("🔥 Exception while approving proforma: $e");
      return false;
    }
  }

  static Future<bool> rejectProforma(String id) async {
    final token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}reject_proforma",
        data: FormData.fromMap({
          'token': token,
          'id': id,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Reject proforma response: ${response.data}");

      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("🔥 Exception while rejecting proforma: $e");
      return false;
    }
  }

  static Future<QuotationListModel?> getQuotationList(
    dynamic status,
    String? fromDate,
    String? toDate,
    List<String>? staffIds,
    List<String>? statuses,
  ) async {
    final token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}quotation_list_api",
        data: FormData.fromMap({
          'token': token,
          'status': status.toString(),
          if (fromDate != null) "from_date": fromDate,
          if (toDate != null) "to_date": toDate,
          if (staffIds != null && staffIds.isNotEmpty)
            "created_by": staffIds.join(","),
          if (statuses != null && statuses.isNotEmpty)
            "status": statuses.join(","),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Quotation list response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return QuotationListModel.fromJson(response.data);
        } else {
          print(
            "⚠️ Invalid data format in getQuotationList response: Expected Map, got ${response.data.runtimeType}",
          );
        }
      } else {
        print(
          "⚠️ Unexpected status code in getQuotationList: ${response.statusCode}",
        );
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in getQuotationList: $e");
      print("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<String> deleteQuotation(String id) async {
    final token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}deleteQuotation_api",
        data: FormData.fromMap({
          'token': token,
          'quote_id': id,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Delete quotation response: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['status'] == 'success') {
          return 'success';
        } else {
          return 'failed';
        }
      } else {
        return 'failed';
      }
    } catch (e) {
      print("🔥 Exception while deleting quotation: $e");
      return 'failed';
    }
  }

  static Future<MaterialListModel?> getMaterials() async {
    try {
      final token = await Common.getSharedPref("token");
      final response = await _dio.post(
        "${await Config.getUrl()}get_materials",
        data: FormData.fromMap({"token": token}),
        options: Options(contentType: "multipart/form-data"),
      );
      print("🟢 Materials Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        return MaterialListModel.fromJson(response.data);
      }
    } catch (e, stackTrace) {
      log("🔥 getMaterials error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<CustomerModel?> getCustomerList() async {
    final token = await Common.getSharedPref('token');

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}getCustomerName",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Customer List Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return CustomerModel.fromJson(response.data);
      } else {
        print("⚠️ Unexpected status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        print("🔥 DioException in getCustomerList:");
        print("➡ Message: ${e.message}");
        print("➡ Type: ${e.type}");
        print("➡ Response: ${e.response?.data}");
        print("➡ Status Code: ${e.response?.statusCode}");
      } else {
        print("🔥 Unknown Exception in getCustomerList: $e");
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> submitQuotation(FormData formData) async {
    try {
      final token = await Common.getSharedPref("token");
      formData.fields.add(MapEntry("token", token ?? ""));
      final response = await _dio.post(
        "${await Config.getUrl()}addQuotation",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );
      print("🟢 Submit Quotation Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        log("❌ Quotation submission failed: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 Error in submitQuotation: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<QuotationTemplateModel?> getTemplateList() async {
    try {
      final token = await Common.getSharedPref("token");
      final response = await _dio.post(
        "${await Config.getUrl()}getTemplateName_api",
        data: FormData.fromMap({"token": token}),
        options: Options(contentType: "multipart/form-data"),
      );
      print("🟢 Template Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == 'success') {
          return QuotationTemplateModel.fromJson(data);
        } else {
          log("⚠️ API returned failure: ${data['message']}");
        }
      } else {
        log("⚠️ Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stack) {
      log("🔥 getTemplateList error: $e");
      log("Stack trace: $stack");
    }
    return null;
  }

  Future<QuotationTemplateDetailsModel?> getTemplateDetails(String id) async {
    try {
      final token = await Common.getSharedPref("token");

      final response = await _dio.post(
        "${await Config.getUrl()}fetchTemplatesByID",
        data: FormData.fromMap({"token": token, "id": id}),
        options: Options(contentType: "multipart/form-data"),
      );

      print("🟢 Template Details Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          return QuotationTemplateDetailsModel.fromJson(data);
        } else {
          log("Invalid format: Expected Map, got ${data.runtimeType}");
        }
      } else {
        log("Unexpected status: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 getTemplateDetails error: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  Future<CustomerDetailsModel?> getCustomerDetails(String customerId) async {
    try {
      final token = await Common.getSharedPref("token");

      final formData = FormData.fromMap({
        "token": token,
        "customer_id": customerId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}getCustomerDetails",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        log("getCustomerDetails API Response: ${jsonEncode(data)}");

        if (data is Map<String, dynamic>) {
          return CustomerDetailsModel.fromJson(data);
        } else {
          log("Invalid response format: Expected Map, got ${data.runtimeType}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("getCustomerDetails error: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  Future<CustomerWorkDetailsModel?> getWorkorderId(String id) async {
    try {
      final token = await Common.getSharedPref("token");

      final formData = FormData.fromMap({"token": token, "customer_id": id});

      final response = await _dio.post(
        "getCustomerWorkDetails",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          return CustomerWorkDetailsModel.fromJson(data);
        } else {
          log(
            "Invalid data format in workOrder response: Expected Map, got ${data.runtimeType}",
          );
        }
      } else {
        log("Unexpected status code in workOrder: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("workOrder error: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  Future<QuotationDetailsModel?> getQuotationEdit(String id) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({"id": id});
      formData.fields.removeWhere((field) => field.key == "token");
      formData.fields.add(MapEntry("token", token ?? ""));
      final response = await _dio.post(
        "${await Config.getUrl()}api_edit_quotation",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );
      print("🟢 Quotation Edit Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          if (data["status"] == "success") {
            return QuotationDetailsModel.fromJson(data);
          } else {
            log("API returned status: ${data['status']}");
          }
        } else {
          log("Invalid response format: Expected Map, got ${data.runtimeType}");
        }
      } else {
        log("Unexpected status code in getQuotationEdit: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 getQuotationEdit error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateQuotation(FormData formData) async {
    try {
      final token = await Common.getSharedPref("token");
      formData.fields.removeWhere((field) => field.key == "token");
      formData.fields.add(MapEntry("token", token ?? ""));
      final response = await _dio.post(
        "${await Config.getUrl()}updateQuotation_api",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );
      print("🟢 Update Quotation Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          log("Invalid format: Expected Map, got ${data.runtimeType}");
        }
      } else {
        log("Unexpected status: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 updateQuotation error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<QuotationDashboardResponse?> getQuotationDashboard() async {
    try {
      final token = await Common.getSharedPref("token");

      final response = await _dio.post(
        "${await Config.getUrl()}quote_dashboard_api",
        data: FormData.fromMap({
          "token": token,
        }),
      );

      log("🟢 Quotation Dashboard Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data;

        if (json is Map<String, dynamic>) {
          final dashboardResponse = QuotationDashboardResponse.fromJson(json);

          if (dashboardResponse.status == "success") {
            return dashboardResponse;
          } else {
            log("❌ API Error: ${dashboardResponse.message}");
          }
        } else {
          log("❌ Invalid response format: ${json.runtimeType}");
        }
      } else {
        log("❌ HTTP Error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 getQuotationDashboard error: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  Future<QuotationRequestList?> getQuotationRequestList(
      String requestType) async {
    try {
      final token = await Common.getSharedPref("token") ?? '';
      final response = await _dio.post(
        "${await Config.getUrl()}dashboard_list_api",
        data: FormData.fromMap({
          'token': token,
          'status': requestType,
        }),
      );

      log("🟢 Quotation Dashboard Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data;

        if (json is Map<String, dynamic>) {
          final dashboardResponse = QuotationRequestList.fromJson(json);

          if (dashboardResponse.status == "success") {
            if (requestType == "all" || requestType == "rate") {
              return dashboardResponse;
            }
            final filtered = dashboardResponse.data.where((item) {
              if (requestType == "1") {
                return item.status.toLowerCase().contains("requested") ||
                    item.status.toLowerCase().contains("pending");
              } else if (requestType == "2") {
                return item.status.toLowerCase().contains("completed");
              }
              return true;
            }).toList();
            return QuotationRequestList(
              status: dashboardResponse.status,
              message: dashboardResponse.message,
              data: filtered,
            );
          } else {
            log("❌ API Error: ${dashboardResponse.message}");
          }
        } else {
          log("❌ Invalid response format: ${json.runtimeType}");
        }
      } else {
        log("❌ HTTP Error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 getQuotationDashboard error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<Map<String, dynamic>?> createQuotationRequest(
      FormData formData) async {
    try {
      final token = await Common.getSharedPref("token");

      formData.fields.add(MapEntry("token", token ?? ""));

      final response = await _dio.post(
        "${await Config.getUrl()}postquote_request_api",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      print("🟢 Create Quotation Request Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        log("❌ Quotation request creation failed: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 Error in createQuotationRequest: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<DeleteQuotationRequestModel> deleteRequestQuotation(
      String requestId) async {
    try {
      final token = await Common.getSharedPref('token');

      final response = await _dio.post(
        "${await Config.getUrl()}delete_quotation_request",
        data: FormData.fromMap({
          'token': token,
          'request_id': requestId,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Delete Quotation Request Response: ${response.data}");

      if (response.statusCode == 200) {
        return DeleteQuotationRequestModel.fromJson(response.data);
      } else {
        return DeleteQuotationRequestModel(
          status: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in deleteRequestQuotation: $e");
      print("StackTrace: $stackTrace");

      return DeleteQuotationRequestModel(
        status: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>?> importQuotation(FormData formData) async {
    try {
      final token = await Common.getSharedPref("token");
      formData.fields.add(MapEntry("token", token ?? ""));

      final response = await _dio.post(
        "${await Config.getUrl()}importQuotation_post",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      print("🟢 Import Quotation Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        log("❌ Import quotation failed: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("🔥 Error in importQuotation: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<UploadedQuotationModel?> getUploadedQuotationDetails(
      String id) async {
    try {
      final token = await Common.getSharedPref('token');

      final response = await _dio.post(
        "${await Config.getUrl()}api_edit_uploaded_quotation",
        data: FormData.fromMap({
          'token': token,
          'id': id,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Get Uploaded Quotation Details Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return UploadedQuotationModel.fromJson(response.data);
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in getUploadedQuotationDetails: $e");
      print("StackTrace: $stackTrace");

      // Return null on error
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUploadedQuotation(
      FormData formData) async {
    try {
      final token = await Common.getSharedPref('token');
      formData.fields.add(MapEntry("token", token ?? ""));

      final response = await _dio.post(
        "${await Config.getUrl()}api_update_uploaded_quotation",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      print("🟢 Update Uploaded Quotation Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        print("⚠️ Update uploaded quotation failed: ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in updateUploadedQuotation: $e");
      print("StackTrace: $stackTrace");
      return null;
    }
  }

  static Future<QuoRequestDetailsResponse?> getRequestQuotationDetails(
      String id) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';

      final response = await _dio.post(
        "${await Config.getUrl()}api_edit_request",
        data: FormData.fromMap({
          'token': token,
          'request_id': id,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Get Request Quotation Details Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final result = QuoRequestDetailsResponse.fromJson(response.data);

        if (result.status.toLowerCase() == 'success') {
          return result;
        } else {
          print("⚠️ API Failed: ${result.message}");
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in getRequestQuotationDetails: $e");
      print("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> updateQuotationRequest(
      FormData formData) async {
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}editquote_request_api",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Update Request Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in updateQuotationRequest: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';

      final formData = FormData.fromMap({
        'token': token,
        'request_id': requestId,
        'status': status,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}update_request_api",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Update Status Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in updateRequestStatus: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> changeQuotationStatus({
    required String quotationId,
    required String status,
  }) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';

      final formData = FormData.fromMap({
        'token': token,
        'quotation_id': quotationId,
        'status': status,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}update_quotationStatus",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      print("🟢 Update Status Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in updateRequestStatus: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
    return null;
  }

  static Future<RequestResponseModel?> createRequestDetails(String id) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';

      if (token.isEmpty) {
        print("⚠️ Token is empty");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}get_requestdata_for_quotation_api",
        data: FormData.fromMap({
          'token': token,
          'request_id': id,
        }),
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      print("🟢 Get Request Quotation Details Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        try {
          final result = RequestResponseModel.fromJson(response.data);

          if (result.status?.toLowerCase() == 'success') {
            return result;
          } else {
            print("⚠️ API Failed: ${result.message}");
          }
        } catch (e) {
          print("🔥 Error parsing response: $e");
          print("Response data: ${response.data}");
          return null;
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
        print("Response: ${response.data}");
      }
    } on DioException catch (e) {
      print("🔥 DioException in getRequestQuotationDetails: $e");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Response status: ${e.response?.statusCode}");
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in getRequestQuotationDetails: $e");
      print("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<RequestDetailsResponseModel?> requestDetails(String id) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';

      if (token.isEmpty) {
        print("⚠️ Token is empty");
        return null;
      }

      if (id.isEmpty) {
        print("⚠️ Request ID is empty");
        return null;
      }

      print("🔍 Fetching request details for ID: $id");

      final response = await _dio.post(
        "${await Config.getUrl()}view_request_api",
        data: FormData.fromMap({
          'token': token,
          'request_id': id,
        }),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print("🟢 Get Request Details Response Status: ${response.statusCode}");
      if (response.data == null) {
        print("⚠️ Null response data received");
        return null;
      }

      if (response.statusCode == 200) {
        try {
          final result = RequestDetailsResponseModel.fromJson(response.data);

          if (result.status?.toLowerCase() == 'success') {
            print("✅ Request details fetched successfully");
            print("📊 Customer: ${result.data?.request?.customerName}");
            print(
                "📊 Products count: ${result.data?.request?.products?.length ?? 0}");
            return result;
          } else {
            print("⚠️ API Failed: ${result.message}");
            // You might want to show this to the user
            // Common.showToast(result.message ?? 'Request failed');
          }
        } catch (e, stack) {
          print("🔥 Error parsing response: $e");
          print("Stack: $stack");
          print("Response data: ${response.data}");
          return null;
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
        print("Response: ${response.data}");
      }
    } on DioException catch (e) {
      print("🔥 DioException in requestDetails: $e");
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          print("⏰ Timeout error: ${e.message}");
          break;
        case DioExceptionType.badResponse:
          print("🚫 Bad response: ${e.response?.statusCode}");
          print("Response data: ${e.response?.data}");
          break;
        case DioExceptionType.cancel:
          print("❌ Request cancelled");
          break;
        case DioExceptionType.unknown:
          print("❓ Unknown error: ${e.message}");
          break;
        default:
          print("⚠️ Other Dio error: ${e.type}");
      }

      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Response status: ${e.response?.statusCode}");
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in requestDetails: $e");
      print("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<String?> printReceipt(String receiptId, String invId) async {
    final token = await Common.getSharedPref('token') ?? '';

    try {
      final formData = FormData.fromMap({
        "token": token,
        "receipt_id": receiptId,
        "invoice_id": invId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}printReceipt",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/receipt_$receiptId.pdf");

      await file.writeAsBytes(response.data, flush: true);

      return file.path;
    } catch (e) {
      log("❌ Error in printReceipt: $e");
      return null;
    }
  }

  static Future<RoomDashboardResponse?> getRoomDashboard() async {
    try {
      final token = await Common.getSharedPref('token') ?? '';

      final response = await _dio.post(
        "${await Config.getUrl()}getRoomDashboard",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Get Room Dashboard Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final result = RoomDashboardResponse.fromJson(response.data);

        if (result.status == true) {
          return result;
        } else {
          print("⚠️ API Failed: ${result.message}");
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in getRoomDashboard: $e");
      print("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<RoomListResponse?> getRoomList(String status) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';
      final response = await _dio.post(
        "${await Config.getUrl()}getBookingLists",
        data: FormData.fromMap({
          'token': token,
          'status': status,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      print("🟢 Get Room List Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final result = RoomListResponse.fromJson(response.data);
        if (result.status == true) {
          print(
              "✅ Room list fetched successfully. Count: ${result.data.length}");
          return result;
        } else {
          print("⚠️ API Failed: ${result.message}");
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("🔥 DioException in getRoomList: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e, stackTrace) {
      print("🔥 Exception in getRoomList: $e");
      print("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> sendQuotation({
    required String workOrderId,
  }) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';

      final formData = FormData.fromMap({
        'token': token,
        'id': workOrderId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}send_quotation",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      print("🟢 Send Quotation Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in sendQuotation: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
    return null;
  }

  static Future<RoomTypeResponse?> getRoomTypes() async {
    try {
      final token = await Common.getSharedPref('token') ?? '';
      final response = await _dio.post(
        "${await Config.getUrl()}getRoomType",
        data: FormData.fromMap({
          'token': token,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      print("🟢 Get Room Type Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic>? responseData = response.data;
        if (responseData != null) {
          final result = RoomTypeResponse.fromJson(responseData);
          if (result.status == true) {
            print(
                "✅ Room types fetched successfully. Count: ${result.data.length}");
            return result;
          } else {
            print("⚠️ API Failed: ${result.message}");
            return result;
          }
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("🔥 DioException in getRoomTypes: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e, stackTrace) {
      print("🔥 Exception in getRoomTypes: $e");
      print("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<RoomNumberListResponse?> getRoomNumbers(
      String roomTypeId) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';
      final response = await _dio.post(
        "${await Config.getUrl()}fetchRoomsByType",
        data: FormData.fromMap({
          'token': token,
          'room_type_id': roomTypeId,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      print("🟢 Get Room Numbers Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic>? responseData = response.data;
        if (responseData != null) {
          final result = RoomNumberListResponse.fromJson(responseData);
          if (result.status == true) {
            print(
                "✅ Room numbers fetched successfully. Count: ${result.data.length}");
            return result;
          } else {
            print("⚠️ API Failed: ${result.message}");
            return result;
          }
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("🔥 DioException in getRoomNumbers: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e, stackTrace) {
      print("🔥 Exception in getRoomNumbers: $e");
      print("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<RoomProductListModel?> getRoomProducts() async {
    try {
      final token = await Common.getSharedPref('token') ?? '';
      final response = await _dio.post(
        "${await Config.getUrl()}getProducts",
        data: FormData.fromMap({
          'token': token,
          'product_type': "Material",
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      print("🟢 Get Room Products Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic>? responseData = response.data;
        if (responseData != null) {
          final result = RoomProductListModel.fromJson(responseData);
          if (result.status == true) {
            print(
                "✅ Room products fetched successfully. Count: ${result.data.length}");
            return result;
          } else {
            print("⚠️ API Failed: ${result.message}");
            return result;
          }
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("🔥 DioException in getRoomProducts: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e, stackTrace) {
      print("🔥 Exception in getRoomProducts: $e");
      print("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<BookingResponse?> submitBooking({
    required Map<String, dynamic> bookingData,
    File? idProofFile,
    bool isEdit = false,
  }) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';
      final endpoint = isEdit ? 'updateBooking' : 'createBooking';
      final url = "${await Config.getUrl()}$endpoint";
      print("🟢 ${isEdit ? 'Updating' : 'Submitting'} booking data to API...");
      print("📦 Booking data payload: $bookingData");
      print(
          "📁 ID Proof file: ${idProofFile != null ? idProofFile.path : 'No file'}");
      print("🔗 API URL: $url");
      print("📝 Mode: ${isEdit ? 'Edit' : 'Create'}");
      final formData = FormData.fromMap({
        'token': token,
        'booking_data': jsonEncode(bookingData),
      });
      if (isEdit && bookingData['bookingId'] != null) {
        formData.fields.add(MapEntry('booking_id', bookingData['bookingId']));
        print("📝 Edit Mode: Booking ID = ${bookingData['bookingId']}");
      }
      if (idProofFile != null && idProofFile.existsSync()) {
        final fileName = idProofFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'id_proof',
            await MultipartFile.fromFile(
              idProofFile.path,
              filename: fileName,
            ),
          ),
        );
        print("📎 Attached file: $fileName");
      } else if (idProofFile != null) {
        print("⚠️ File does not exist at path: ${idProofFile.path}");
      }
      print("📤 Sending multipart request...");
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      print(
          "🟢 ${isEdit ? 'Update' : 'Submit'} Booking Response Status: ${response.statusCode}");
      print(
          "📄 ${isEdit ? 'Update' : 'Submit'} Booking Response Body: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic>? responseData = response.data;
        if (responseData != null) {
          final result = BookingResponse.fromJson(responseData);
          if (result.status == true) {
            print("✅ Booking ${isEdit ? 'updated' : 'created'} successfully!");
            if (!isEdit) {
              print("📋 Booking ID: ${result.bookingId}");
            }
            print("📋 Message: ${result.message}");
            return result;
          } else {
            print("⚠️ API Failed: ${result.message}");
            print("📋 Error details: ${result.errorDetails}");
            return result;
          }
        }
      } else {
        print("⚠️ Unexpected status code: ${response.statusCode}");
        print("📋 Response body: ${response.data}");
      }
    } on DioException catch (e) {
      print(
          "🔥 DioException in ${isEdit ? 'update' : 'submit'}Booking: ${e.message}");
      print("🔍 Error type: ${e.type}");
      if (e.response != null) {
        print("📋 Response status: ${e.response!.statusCode}");
        print("📋 Response data: ${e.response!.data}");
        print("📋 Response headers: ${e.response!.headers}");
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        print(
            "⏱️ Connection timeout while ${isEdit ? 'updating' : 'submitting'} booking");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        print(
            "⏱️ Receive timeout while ${isEdit ? 'updating' : 'submitting'} booking");
      } else if (e.type == DioExceptionType.sendTimeout) {
        print(
            "⏱️ Send timeout while ${isEdit ? 'updating' : 'submitting'} booking");
      } else if (e.type == DioExceptionType.badResponse) {
        print("❌ Bad response from server");
      } else if (e.type == DioExceptionType.cancel) {
        print("❌ Request cancelled");
      } else if (e.type == DioExceptionType.unknown) {
        print("❓ Unknown Dio error: ${e.error}");
      }
    } catch (e, stackTrace) {
      print("🔥 Exception in ${isEdit ? 'update' : 'submit'}Booking: $e");
      print("📋 StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<BookingDetailsResponse?> getListDataOnEdit(
      String bookingId) async {
    try {
      final token = await Common.getSharedPref('token') ?? '';
      if (token.isEmpty) {
        print('❌ Token is empty');
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}edit_booking",
        data: FormData.fromMap({
          'token': token,
          'booking_id': bookingId,
        }),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      print("🟢 Get Booking Details Response Status: ${response.statusCode}");
      print("🟢 Response Data: ${response.data}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.isEmpty) {
          print("⚠️ Response data is empty");
          return null;
        }
        try {
          final result = BookingDetailsResponse.fromJson(responseData);
          if (result.status == true) {
            print("✅ Booking details fetched successfully");
            if (result.data != null) {
              print("📋 Booking ID: ${result.data!.bookingDetails.id}");
              print("📋 Invoice: ${result.data!.bookingDetails.invoiceNumber}");
              print(
                  "📋 Total Amount: ${result.data!.bookingDetails.totalAmount}");
              print("📋 Rooms: ${result.data!.bookingRoomsList.length}");
            }

            return result;
          } else {
            print("⚠️ API returned false status: ${result.message}");
            return null;
          }
        } catch (e) {
          print("❌ Error parsing response to model: $e");
          print("❌ Raw response: ${response.data}");
          return null;
        }
      } else {
        print("❌ Unexpected status code: ${response.statusCode}");
        print("❌ Response: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      print("🔥 DioException in getListDataOnEdit: ${e.message}");

      if (e.type == DioExceptionType.connectionTimeout) {
        print("⏱️ Connection timeout");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        print("⏱️ Receive timeout");
      } else if (e.type == DioExceptionType.sendTimeout) {
        print("⏱️ Send timeout");
      }

      if (e.response != null) {
        print("📊 Response status: ${e.response?.statusCode}");
        print("📊 Response data: ${e.response?.data}");
      }

      return null;
    } catch (e, stackTrace) {
      print("🔥 Unexpected error in getListDataOnEdit: $e");
      print("📜 StackTrace: $stackTrace");
      return null;
    }
  }

  Future<Uint8List?> fetchInvoicePdfBytes(String bookingId) async {
    final token = await Common.getSharedPref("token");
    try {
      final formData = FormData.fromMap({
        "token": token,
        "booking_id": bookingId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}printBookingInvoice",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      log("PDF fetch error: $e");
      return null;
    }
  }

  Future<WorkCategoryModelGraph?> getCategoryGraph() async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({"token": token});

      final response = await _dio.post(
        "${await Config.getUrl()}get_work_category_stats",
        data: formData,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return WorkCategoryModelGraph.fromJson(response.data);
      } else {
        log(
          "getCategoryGraph: Unexpected response or status code ${response.statusCode}",
        );
      }
    } catch (e, stackTrace) {
      log("getCategoryGraph error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<GetRoleModel?> getRoleId() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getRoleId",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return GetRoleModel.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<WorkModelPage?> getWorkList(
    String staffId,
    String date,
    String typeId,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
      "status": typeId,
    });
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}api_workorders",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return WorkModelPage.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("api_workorders error: $e");
    }
    return null;
  }

  Future<CurrentStatus?> checkCurrentWorkStatus() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}checkCurrentWorkStatus",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return CurrentStatus.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<WorkTypeModel?> getWorkType() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getWorkType",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return WorkTypeModel.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> startWorkService(
    String workId,
    String remarks,
    String? milestone,
    String? productId,
    List<Map<String, dynamic>> selectedMaterials,
    String? selectedCustomerId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "workId": workId,
        "remarks": remarks,
        "milestone": milestone,
        "product_id": productId,
        "materials": jsonEncode(selectedMaterials),
        "customer_id": selectedCustomerId,
      });
      final result = await _dio.post(
        "${await Config.getUrl()}startWork",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return result.data;
      }
    } catch (e) {
      log("Error in startWork: $e");
    }
    return {"status": false, "message": "Failed to start work"};
  }

  Future<Map<String, dynamic>> pauseWorkService(
    String workId,
    String status,
    String remarks,
    String? milestone,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "workId": workId,
        "status": status,
        "remarks": remarks,
        "milestone": milestone,
      });
      final result = await _dio.post(
        "${await Config.getUrl()}pauseWork",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return result.data;
      }
    } catch (e) {
      log("Error in pauseWork: $e");
    }
    return {"status": false, "message": "Failed to pause work"};
  }

  Future<Map<String, dynamic>> stopWorkService(
    String workId,
    String status,
    String remarks,
    String? milestone,
    String? productId,
    List<Map<String, dynamic>> selectedMaterials,
    String? selectedCustomerId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "work_order_id": workId,
        "status": status,
        "remark": remarks,
        "stoppipeline_name": milestone,
        "product_id": productId,
        "materials": jsonEncode(selectedMaterials),
        "customer_id": selectedCustomerId,
      });
      final result = await _dio.post(
        "${await Config.getUrl()}stopWork",
        data: formData,
      );
      if (result.statusCode == 200 && result.data != null) {
        return result.data;
      }
    } catch (e) {
      log("Error in stopWork: $e");
    }
    return {"status": false, "message": "Failed to stop work"};
  }

  Future<bool> deleteWorkOrder(String workOrderId) async {
    try {
      final token = await Common.getSharedPref("token");

      final formData = FormData.fromMap({
        "token": token,
        "WorkOrderID": workOrderId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}delete_workorder",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data["status"] == true) {
          return true;
        } else {
          log("Delete failed: ${data["message"]}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("deleteWorkOrder error: $e");
      log("StackTrace: $stackTrace");
    }

    return false;
  }

  Future<CustomerModelService?> getCustomerListService() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });
    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getCustomerName",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return CustomerModelService.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<CustomerTypeModel?> getCustomerType() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getCustomerType",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return CustomerTypeModel.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<WorkOrderDetailsModel?> getWorkEditDetails(String workOrderId) async {
    try {
      final token = await Common.getSharedPref("token");

      final formData = FormData.fromMap({
        "token": token,
        "WorkOrderID": workOrderId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_workorder_for_edit",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return WorkOrderDetailsModel.fromJson(data);
        } else {
          log("Invalid response format: Expected Map, got ${data.runtimeType}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("getCustomerDetails error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<StaffsModel?> getStaffName() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getStaffName",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return StaffsModel.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<WorkCategory?> getWorkCategory() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getWorkCategory",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return WorkCategory.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<ReceivedThroughModel?> getReceivedThrough() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });

    try {
      var result = await _dio.post(
        "${await Config.getUrl()}getReceivedThrough",
        data: formData,
      );

      if (result.statusCode == 200 && result.data != null) {
        return ReceivedThroughModel.fromJson(result.data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e) {
      log("getCustomerList error: $e");
    }
    return null;
  }

  Future<bool> updateWorkService(Map<String, dynamic> body) async {
    try {
      final token = await Common.getSharedPref("token");
      body["token"] = token;

      final formData = FormData.fromMap(body);

      final response = await _dio.post(
        "${await Config.getUrl()}update_workorder",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data["status"] == true) {
            log("✅ Work order updated successfully");
            return true;
          } else {
            log("⚠️ Update failed: ${data["message"]}");
            return false;
          }
        } else {
          log("Invalid response format: Expected Map, got ${data.runtimeType}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("updateWork error: $e");
      log("StackTrace: $stackTrace");
    }
    return false;
  }

  Future<bool> deletePushNotification(String notificationId) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref("token"),
        "notification_id": notificationId,
      });

      var result = await _dio.post(
        "${await Config.getUrl()}delete_push_notification",
        data: formData,
      );

      if (result.statusCode == 200 && result.data['status'] == true) {
        return true;
      } else {
        log("Failed to delete notification: ${result.data}");
        return false;
      }
    } catch (e) {
      log("Error deleting notification: $e");
      return false;
    }
  }

  Future<PushNotificationModel?> getPushNotification() async {
    try {
      final token = await Common.getSharedPref("token");

      final formData = FormData.fromMap({"token": token});

      final response = await _dio.post(
        "${await Config.getUrl()}get_push_notification",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is Map<String, dynamic>) {
          return PushNotificationModel.fromJson(data);
        } else {
          log("Invalid data format in push notification response");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("Push Notification error: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  Future<Map<String, dynamic>?> addWorkService(
      Map<String, dynamic> body) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({"token": token, ...body});
      final result = await _dio.post(
        "${await Config.getUrl()}addWork",
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain,
        ),
      );

      if (result.statusCode == 200 && result.data != null) {
        final data = json.decode(result.data.toString());
        return Map<String, dynamic>.from(data);
      } else {
        log("Unexpected status code: ${result.statusCode}");
      }
    } catch (e, st) {
      log("addWork error: $e");
      log(st.toString());
    }
    return null;
  }

  static Future<CustomerDashboardModel?> getCustomerDashboard(
      String custId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("Token is null or empty");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "cust_id": custId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}customer_dashboard",
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['status'] == true) {
            return CustomerDashboardModel.fromJson(data);
          } else {
            log("API returned false status: ${data['message']}");
            return null;
          }
        } else {
          log("Invalid data format: Expected Map but got ${data.runtimeType}");
          return null;
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
        log("Response: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      log("Dio error in getCustomerDashboard: ${e.message}");

      if (e.response != null) {
        log("Response data: ${e.response?.data}");
        log("Response status: ${e.response?.statusCode}");
      }
      return null;
    } catch (e, stackTrace) {
      log("Unexpected error in getCustomerDashboard: $e");
      log("StackTrace: $stackTrace");
      return null;
    }
  }

  static Future<GetCustomerLeadsModel?> getCustomerLeads(String custId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("Token is null or empty");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "cust_id": custId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_customer_lead",
        data: formData,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is Map<String, dynamic>) {
          if (data.containsKey("status") && data.containsKey("data")) {
            return GetCustomerLeadsModel.fromJson(data);
          } else {
            log("Invalid response structure in Customer Leads: Missing required fields");
            log("Response data: $data");
          }
        } else {
          log("Invalid data format in Customer Leads response");
          log("Response data type: ${data.runtimeType}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
        log("Response data: ${response.data}");
      }
    } on DioException catch (e) {
      log("Dio error in Customer Leads: ${e.message}");
      if (e.response != null) {
        log("Response status: ${e.response?.statusCode}");
        log("Response data: ${e.response?.data}");
      }
    } catch (e, stackTrace) {
      log("Unexpected error in Customer Leads: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<CustomerwiseQuotationList?> getCustomerQuotations(
      String custId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("Token is null or empty");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "cust_id": custId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_customer_quotations",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is Map<String, dynamic>) {
          if (data.containsKey("status") && data.containsKey("data")) {
            return CustomerwiseQuotationList.fromJson(data);
          } else {
            log("Invalid response structure in Customer Leads: Missing required fields");
            log("Response data: $data");
          }
        } else {
          log("Invalid data format in Customer Leads response");
          log("Response data type: ${data.runtimeType}");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
        log("Response data: ${response.data}");
      }
    } on DioException catch (e) {
      log("Dio error in Customer Leads: ${e.message}");
      if (e.response != null) {
        log("Response status: ${e.response?.statusCode}");
        log("Response data: ${e.response?.data}");
      }
    } catch (e, stackTrace) {
      log("Unexpected error in Customer Leads: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<CustomerwiseProjectModel?> getCustomerProjects(
      String custId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("Token is null or empty");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}get_customer_project_list",
        data: FormData.fromMap({
          "token": token,
          "cust_id": custId,
        }),
      );
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(response.data);

        return CustomerwiseProjectModel.fromJson(json);
      }
    } on DioException catch (e) {
      log("Dio error in Customer Projects: ${e.message}");
    } catch (e, stackTrace) {
      log("Unexpected error: $e");
      log("StackTrace: $stackTrace");
    }

    return null;
  }

  static Future<RentalDashboardModel?> getRentalDashboard(String date) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("Token is null or empty");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "date": date,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}rent_dashboard_api",
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is Map<String, dynamic>) {
          try {
            return RentalDashboardModel.fromJson(data);
          } catch (e) {
            log("Error parsing RentalDashboardModel: $e");
            if (data["status"] == true) {
              final emptyDashboardData = RentalDashboardData(
                filterDate: "",
                rentIssued: 0,
                rentReturned: 0,
                pendingReturn: 0,
                rentOverdue: 0,
                todayPayment: 0,
                todayCash: 0,
                todayBank: 0,
                overdueCount: 0,
                overdueList: [],
              );
              return RentalDashboardModel(
                status: true,
                message: data["message"]?.toString() ?? "No data available",
                data: emptyDashboardData,
              );
            } else {
              final emptyDashboardData = RentalDashboardData(
                filterDate: "",
                rentIssued: 0,
                rentReturned: 0,
                pendingReturn: 0,
                rentOverdue: 0,
                todayPayment: 0,
                todayCash: 0,
                todayBank: 0,
                overdueCount: 0,
                overdueList: [],
              );

              return RentalDashboardModel(
                status: false,
                message: data["message"]?.toString() ??
                    "Failed to fetch dashboard data",
                data: emptyDashboardData,
              );
            }
          }
        } else {
          log("Invalid data format in response");
          log("Response data: $data");
        }
      } else {
        log("Unexpected status code: ${response.statusCode}");
        log("Response data: ${response.data}");
      }
    } on DioException catch (e) {
      log("Dio error in getRentalDashboard: ${e.message}");
      if (e.response != null) {
        log("Response status: ${e.response?.statusCode}");
        log("Response data: ${e.response?.data}");
        if (e.response?.statusCode == 401) {
          log("Unauthorized - Token might be expired");
        } else if (e.response?.statusCode == 404) {
          log("Endpoint not found");
        } else if (e.response?.statusCode == 500) {
          log("Server error");
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        log("Request timeout occurred");
      }
    } catch (e, stackTrace) {
      log("Unexpected error in getRentalDashboard: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<RentIssueModel?> getRentalIssueList(
      {Map<String, dynamic>? filters}) async {
    try {
      final token = await Common.getSharedPref("token");
      Map<String, dynamic> formDataMap = {"token": token};
      if (filters != null) {
        formDataMap.addAll(filters);
      }
      final formData = FormData.fromMap(formDataMap);
      final response = await _dio.post(
        "${await Config.getUrl()}rent_issue_list_api",
        data: formData,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return RentIssueModel.fromJson(data);
        }
      }
    } catch (e) {
      log("getRentalIssueList error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createRentalIssue(
      Map<String, dynamic> data) async {
    try {
      final token = await Common.getSharedPref("token");
      data['token'] = token;
      final formData = FormData.fromMap(data);
      final response = await _dio.post(
        "${await Config.getUrl()}create_rental_issue",
        data: formData,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        log("createRentalIssue error: HTTP ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("createRentalIssue error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> editRentalIssue(
      Map<String, dynamic> data) async {
    try {
      final token = await Common.getSharedPref("token");
      data['token'] = token;
      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        "${await Config.getUrl()}update_rental_issue",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        log("editRentalIssue error: HTTP ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("editRentalIssue error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<RentalReturnModel?> getRentalReturnList(
      {Map<String, dynamic>? filters}) async {
    try {
      final token = await Common.getSharedPref("token");
      Map<String, dynamic> formDataMap = {"token": token};
      if (filters != null) formDataMap.addAll(filters);
      final response = await _dio.post(
        "${await Config.getUrl()}rent_return_list_api",
        data: FormData.fromMap(formDataMap),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return RentalReturnModel.fromJson(data);
        }
      }
    } catch (e) {
      log("getRentalReturnListFiltered error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createRentalReturn(
      Map<String, dynamic> data) async {
    try {
      final token = await Common.getSharedPref("token");
      data['token'] = token;
      final response = await _dio.post(
        "${await Config.getUrl()}create_rental_return",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e, stackTrace) {
      log("createRentalReturn error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateRentalReturn(
      Map<String, dynamic> data) async {
    try {
      final token = await Common.getSharedPref("token");
      data['token'] = token;
      final response = await _dio.post(
        "${await Config.getUrl()}update_rental_return",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e, stackTrace) {
      log("updateRentalReturn error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  static Future<RetalLocationModel?> getRentalLocation() async {
    try {
      final token = await Common.getSharedPref("token");
      Map<String, dynamic> formDataMap = {"token": token};

      final formData = FormData.fromMap(formDataMap);
      final response = await _dio.post(
        "${await Config.getUrl()}location_list_api",
        data: formData,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return RetalLocationModel.fromJson(data);
        }
      }
    } catch (e) {
      log("getRentalLocation error: $e");
    }
    return null;
  }

  static Future<CustomerRentalProductListModel?> getCustomerProductRental(
      String customerId) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "customer_id": customerId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_rent_issue_by_customer",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return CustomerRentalProductListModel.fromJson(data);
        }
      }
    } catch (e) {
      log("getCustomerProductRental error: $e");
    }
    return null;
  }

  Future<WorksCountModel?> getCountsWorks() async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({"token": token});

      final response = await _dio.post(
        "${await Config.getUrl()}get_assigned_task_status_counts",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return WorksCountModel.fromJson(data);
      }
    } catch (e) {
      log("getCountsWorks error: $e");
    }
    return null;
  }

  Future<CommonResponse?> deleteWork(String workId) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "work_id": workId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}delete_work",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return CommonResponse.fromJson(data);
        }
      }
    } catch (e) {
      log("deleteWork error: $e");
    }
    return null;
  }

  Future<AttendanceStaffwiseModel?> getStaffwiseWorkedDays() async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({"token": token});

      final response = await _dio.post(
        "${await Config.getUrl()}get_attendance_staff_wise",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return AttendanceStaffwiseModel.fromJson(data);
        } else {
          log("Unexpected response format: $data");
          return null;
        }
      } else {
        log("API returned status code: ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      log("getStaffwiseWorkedDays error: $e");
      log("Stack trace: $stackTrace");
      return null;
    }
  }

  Future<CommonResponse?> updateAssignedWork(Map<String, dynamic> data) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        ...data,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}update_assigned_work",
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return CommonResponse.fromJson(responseData);
        }
      }
    } catch (e) {
      log("updateAssignedWork error: $e");
    }
    return null;
  }

  Future<UnverifiedTransactionModel?> getUnverifiedDetails({
    String? isFiltered,
    String? type,
    String? fromDate,
    String? toDate,
    String? createdBy,
    String? accountHead,
    String? month,
    String? year,
    String? status,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      Map<String, dynamic> mapData = {"token": token};
      if (isFiltered != null) mapData["is_filtered"] = isFiltered;
      if (type != null) mapData["type"] = type;
      if (fromDate != null) mapData["from_date"] = fromDate;
      if (toDate != null) mapData["to_date"] = toDate;
      if (createdBy != null) mapData["created_by"] = createdBy;
      if (accountHead != null) mapData["account_head"] = accountHead;
      if (month != null) mapData["month"] = month;
      if (year != null) mapData["year"] = year;
      if (status != null) mapData["status"] = status;

      final formData = FormData.fromMap(mapData);

      final response = await _dio.post(
        "${await Config.getUrl()}getTransactiondiffer",
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return UnverifiedTransactionModel.fromJson(data);
        } else {
          log("Unexpected response format: Expected Map, got ${data.runtimeType}");
          log("Response data: $data");
          return null;
        }
      } else {
        log("API returned status code: ${response.statusCode}");
        log("Response data: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      log("Dio error in getUnverifiedDetails: $e");
      if (e.response != null) {
        log("Response data: ${e.response?.data}");
        log("Response status: ${e.response?.statusCode}");
      }
      return null;
    } catch (e, stackTrace) {
      log("getUnverifiedDetails error: $e");
      log("Stack trace: $stackTrace");
      return null;
    }
  }

  // Future<StaffwisePendingUpdatedModel?> getStaffwiseWorkPendingNew(
  //     String staffId) async {
  //   try {
  //     final token = await Common.getSharedPref("token");
  //     final formData = FormData.fromMap({"token": token, "staff_id": staffId});

  //     final response = await _dio.post(
  //       "${await Config.getUrl()}staffwisePendingWorks",
  //       data: formData,
  //       options: Options(
  //         receiveTimeout: const Duration(seconds: 30),
  //         sendTimeout: const Duration(seconds: 30),
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       if (data is Map<String, dynamic>) {
  //         return StaffwisePendingUpdatedModel.fromJson(data);
  //       } else {
  //         log("Unexpected response format: ${data.runtimeType}");
  //         return null;
  //       }
  //     } else {
  //       log("API returned status code: ${response.statusCode}");
  //       log("Response data: ${response.data}");
  //       return null;
  //     }
  //   } catch (e, stackTrace) {
  //     log("getStaffwiseWorkedDays error: $e");
  //     log("Stack trace: $stackTrace");
  //     return null;
  //   }
  // }
  Future<StaffwisePendingUpdatedModel?> getStaffwiseWorkPendingNew(
    String staffId,
    String isOverdue,
    String isUnassigned, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "staff_id": staffId,
        "is_overdue": isOverdue,
        "is_unassigned": isUnassigned,
      });
      if (filters != null && filters.isNotEmpty) {
        if (filters.containsKey('assigned_by_ids') &&
            filters['assigned_by_ids'] is List) {
          final assignedByIds = filters['assigned_by_ids'] as List;
          if (assignedByIds.isNotEmpty) {
            formData.fields
                .add(MapEntry('assigned_by_ids[]', assignedByIds.join(',')));
          }
        }
        if (filters.containsKey('assigned_to_ids') &&
            filters['assigned_to_ids'] is List) {
          final assignedToIds = filters['assigned_to_ids'] as List;
          if (assignedToIds.isNotEmpty) {
            formData.fields
                .add(MapEntry('assigned_to_ids[]', assignedToIds.join(',')));
          }
        }
        if (filters.containsKey('status_names') &&
            filters['status_names'] is List) {
          final statusNames = filters['status_names'] as List;
          if (statusNames.isNotEmpty) {
            formData.fields
                .add(MapEntry('status_names[]', statusNames.join(',')));
          }
        }
        if (filters.containsKey('from_date')) {
          formData.fields
              .add(MapEntry('from_date', filters['from_date'].toString()));
        }
        if (filters.containsKey('to_date')) {
          formData.fields
              .add(MapEntry('to_date', filters['to_date'].toString()));
        }
        filters.forEach((key, value) {
          if (![
            'assigned_by_ids',
            'assigned_to_ids',
            'status_names',
            'from_date',
            'to_date'
          ].contains(key)) {
            if (value != null) {
              formData.fields.add(MapEntry(key, value.toString()));
            }
          }
        });
      }
      log("Sending request with filters: ${formData.fields}");
      final response = await _dio.post(
        "${await Config.getUrl()}staffwisePendingWorks",
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return StaffwisePendingUpdatedModel.fromJson(data);
        } else {
          log("Unexpected response format: ${data.runtimeType}");
          return null;
        }
      } else {
        log("API returned status code: ${response.statusCode}");
        log("Response data: ${response.data}");
        return null;
      }
    } catch (e, stackTrace) {
      log("getStaffwiseWorkPendingNew error: $e");
      log("Stack trace: $stackTrace");
      return null;
    }
  }

  Future<StaffwiseCompletedUpdatedModel?> getStaffwiseWorkCompletedNew(
      String staffId) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({"token": token, "staff_id": staffId});

      final response = await _dio.post(
        "${await Config.getUrl()}staffwiseCompletedWorks",
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return StaffwiseCompletedUpdatedModel.fromJson(data);
        } else {
          log("Unexpected response format: ${data.runtimeType}");
          return null;
        }
      } else {
        log("API returned status code: ${response.statusCode}");
        log("Response data: ${response.data}");
        return null;
      }
    } catch (e, stackTrace) {
      log("getStaffwiseWorkedDays error: $e");
      log("Stack trace: $stackTrace");
      return null;
    }
  }

  Future<StaffwiseWorkDataCountModel?> getStaffwiseWorkDataCounts(
      String staffId, String yearMonth) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap(
          {"token": token, "staff_id": staffId, "month_year": yearMonth});

      final response = await _dio.post(
        "${await Config.getUrl()}get_attendance_single_staff",
        data: formData,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          try {
            return StaffwiseWorkDataCountModel.fromJson(data);
          } catch (e) {
            log("Error parsing response: $e");
            return null;
          }
        } else {
          log("Unexpected response format: ${data.runtimeType}");
          return null;
        }
      } else {
        log("API returned status code: ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      log("getStaffwiseWorkDataCounts error: $e");
      log("Stack trace: $stackTrace");
      return null;
    }
  }

  Future<ProfitAndLossModel?> getProfitOrLose(String month, String year) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData =
          FormData.fromMap({"token": token, "month": month, "year": year});

      final response = await _dio.post(
        "${await Config.getUrl()}get_profit_and_loss",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ProfitAndLossModel.fromJson(data);
      }
    } catch (e) {
      log("getCountsWorks error: $e");
    }
    return null;
  }

  static Future<InvoiceHistoryLogModel?> getInvoiceHistory(
      String type, String invId) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData =
          FormData.fromMap({"token": token, "type": type, "inv_id": invId});

      final response = await _dio.post(
        "${await Config.getUrl()}getLogHistory",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return InvoiceHistoryLogModel.fromJson(data);
      }
    } catch (e) {
      log("getCountsWorks error: $e");
    }
    return null;
  }

  static Future<RentalCustomerLocations?> getRentalCustomerLocations(
      String custId) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData =
          FormData.fromMap({"token": token, "customer_id": custId});
      final response = await _dio.post(
        "${await Config.getUrl()}get_locations_by_customer_post",
        data: formData,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return RentalCustomerLocations.fromJson(data);
      }
    } catch (e) {
      log("getRentalCustomerLocations error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> addRentalCustomerLocation(
      String custId, String locationName) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "customer_id": custId,
        "location_name": locationName,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}add_customer_location_post",
        data: formData,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("addRentalCustomerLocation error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> addRentalCollectedStaff(
      String custId, String staffName) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "customer_id": custId,
        "staff_name": staffName,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}add_customer_staff_post",
        data: formData,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("addRentalCollectedStaff error: $e");
    }
    return null;
  }

  static Future<RentalReturnNumberModel?> getRentalReturnNumber() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentalReturnNumber error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({"token": token});
      final response = await _dio.post(
        "${await Config.getUrl()}generate_return_number_post",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return RentalReturnNumberModel.fromJson(data);
      } else {
        log("getRentalReturnNumber error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      log("getRentalReturnNumber error: $e");
    }
    return null;
  }

  static Future<PaymentReportRentalModel?> getRentalPaymentReport(
    String custId,
    String paymentStatus,
    String paymentMethod,
    String fromDate,
    String endDate,
    String productId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      final formData = FormData.fromMap({
        "token": token,
        "customer_id": custId,
        "payment_status": paymentStatus,
        "payment_method": paymentMethod,
        "from_date": fromDate,
        "end_date": endDate,
        "product_id": productId,
      });
      log("getRentalPaymentReport request: ${formData.fields}");
      final response = await _dio.post(
        "${await Config.getUrl()}payment_report_api",
        data: formData,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        log("getRentalPaymentReport response: $data");
        return PaymentReportRentalModel.fromJson(data);
      } else {
        log("getRentalPaymentReport error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      log("getRentalPaymentReport error: $e");
    }
    return null;
  }

  static Future<GetRentalIssueDetailsModel?> getRentalIssueDetails(
    String custId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentalIssueDetails error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "customer_id": custId,
      });
      log("getRentalIssueDetails request - Customer ID: $custId");
      final response = await _dio.post(
        "${await Config.getUrl()}get_rent_issue_by_customer_list",
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        log("getRentalIssueDetails response: $data");
        return GetRentalIssueDetailsModel.fromJson(data);
      } else {
        log("getRentalIssueDetails error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      log("getRentalIssueDetails error: $e");
    }
    return null;
  }

  static Future<GenerateInvoiceNumberRentalModel?> generateInvoiceNumberRental(
    String custId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("generateInvoiceNumberRental error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "customer_id": custId,
      });

      log("generateInvoiceNumberRental request - Customer ID: $custId");

      final response = await _dio.post(
        "${await Config.getUrl()}generate_invoice_number_api",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        log("generateInvoiceNumberRental response: ${response.data}");
        return GenerateInvoiceNumberRentalModel.fromJson(response.data);
      } else {
        log("generateInvoiceNumberRental error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      log("generateInvoiceNumberRental error: $e");
    }
    return null;
  }

  static Future<RentalCollectedByStaffList?> getCollectedStaffRentalList(
    String custId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getCollectedStaffRentalList error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "customer_id": custId,
      });

      log("getCollectedStaffRentalList request - Customer ID: $custId");

      final response = await _dio.post(
        "${await Config.getUrl()}get_customer_staff_by_customer_post",
        data: formData,
      );
      if (response.statusCode == 200 && response.data != null) {
        log("getCollectedStaffRentalList response: ${response.data}");
        if (response.data is Map && response.data['status'] == true) {
          return RentalCollectedByStaffList.fromJson(response.data);
        } else {
          log("getCollectedStaffRentalList: API returned status false or invalid data");
          return null;
        }
      } else {
        log("getCollectedStaffRentalList error: HTTP ${response.statusCode}");
      }
    } on DioError catch (dioError) {
      log("getCollectedStaffRentalList DioError: ${dioError.message}");
      if (dioError.response != null) {
        log("Response data: ${dioError.response?.data}");
        log("Response status: ${dioError.response?.statusCode}");
      }
    } catch (e) {
      log("getCollectedStaffRentalList unexpected error: $e");
    }
    return null;
  }

  static Future<RentalReportHistoryModel?> getRentalReportHistory(
    String rentIssueId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentalReportHistory error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}get_rent_issue_full_details",
        data: FormData.fromMap({
          "token": token,
          "rent_issue_id": rentIssueId,
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return RentalReportHistoryModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentalReportHistory error: $e");
    }
    return null;
  }

  static Future<ReturnDetailsRentalModel?> getReturnDetails(
    String custId,
    String locationId,
    String rentId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getReturnDetails error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}get_single_rent_details_post",
        data: FormData.fromMap({
          "token": token,
          "customer_id": custId,
          "location_id": locationId,
          "rent_id": rentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return ReturnDetailsRentalModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getReturnDetails error: $e");
    }
    return null;
  }

  static Future<RentIdByCustomerReturnModel?> getRentIdsByCustomer(
    String customerId,
    String locationId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}get_rent_issue_by_customer_list_post", // Update with your actual endpoint
        data: FormData.fromMap({
          "token": token,
          "customer_id": customerId,
          "location_id": locationId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return RentIdByCustomerReturnModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<DeletedProformaInvoiceList?>
      getDeletedProformaInvoiceList() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getDeletedProformaList", // Update with your actual endpoint
        data: FormData.fromMap({
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return DeletedProformaInvoiceList.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<RestoreInvoices?> restoreDeletedProforma(
      String proformaInvoiceId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}restoreDeletedProforma", // Update with your actual endpoint
        data: FormData.fromMap({
          "token": token,
          "id": proformaInvoiceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return RestoreInvoices.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<GetDeletedInvoiceList?> getDeletedInvoiceList() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getDeletedInvoiceList",
        data: FormData.fromMap({
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return GetDeletedInvoiceList.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<RestoreInvoices?> restoreDeletedInvoice(
      String invoiceId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}restoreDeletedInvoice", // Update with your actual endpoint
        data: FormData.fromMap({
          "token": token,
          "id": invoiceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return RestoreInvoices.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<DeletedReceiptList?> getDeletedReceiptList() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getDeletedReceiptList", // Update with your actual endpoint
        data: FormData.fromMap({
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return DeletedReceiptList.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<GetGstDeletedModel?> getDeletedGstInvoiceList() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getDeletedGstList", // Update with your actual endpoint
        data: FormData.fromMap({
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return GetGstDeletedModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<RestoreInvoices?> restoreDeletedGstInvoiceList(
      String gstInvoiceId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getRentIdsByCustomer error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}restoreDeletedGst", // Update with your actual endpoint
        data: FormData.fromMap({
          "token": token,
          "id": gstInvoiceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return RestoreInvoices.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("getRentIdsByCustomer error: $e");
    }
    return null;
  }

  static Future<RestoreInvoices?> restoreDeletedReceipt(
      String receiptId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("restoreDeletedReceipt error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}restoreDeletedReceipt", // Actual endpoint
        data: FormData.fromMap({
          "token": token,
          "id": receiptId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return RestoreInvoices.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("restoreDeletedReceipt error: $e");
    }
    return null;
  }

  static Future<RentalIssueDetailsResponse?> rentIssueDetails(
      String rentId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("rentIssueDetails error: Token not found");
        return null;
      }

      log("Fetching rent issue details for ID: $rentId");
      final response = await _dio.post(
        "${await Config.getUrl()}get_rent_issue_view",
        data: FormData.fromMap({
          "token": token,
          "rent_id": rentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) {
          log("rentIssueDetails error: Response data is null");
          return null;
        }
        if (data['status'] == true) {
          return RentalIssueDetailsResponse.fromJson(data);
        } else {
          log("rentIssueDetails API error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        log("rentIssueDetails HTTP error: Status code ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      log("rentIssueDetails exception: $e");
      log("Stack trace: $stackTrace");
    }
    return null;
  }

  static Future<CustomerPaymentReportModel?> customerPaymentReport(
      {String? fromDate, String? toDate, String? lastPaymentDays}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("restoreDeletedReceipt error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}customer_payment_report",
        data: FormData.fromMap({
          "token": token,
          "from_date": fromDate,
          "to_date": toDate,
          "last_payment_days": lastPaymentDays ?? "",
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return CustomerPaymentReportModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("restoreDeletedReceipt error: $e");
    }
    return null;
  }

  static Future<CustomerPaymentResponseModel?> hideCustomerPaymentReport(
      String accountId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("restoreDeletedReceipt error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}hide_customer_payment_report",
        data: FormData.fromMap({
          "token": token,
          "account_id": accountId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return CustomerPaymentResponseModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("restoreDeletedReceipt error: $e");
    }
    return null;
  }

  static Future<CustomerHiddenPaymentReportModel?>
      hiddenCustomerPaymentReport() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("restoreDeletedReceipt error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}customer_payment_report_hidden",
        data: FormData.fromMap({
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return CustomerHiddenPaymentReportModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("restoreDeletedReceipt error: $e");
    }
    return null;
  }

  static Future<CustomerPaymentResponseModel?>
      unhideHiddencustomerPaymentReport(String accountId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("restoreDeletedReceipt error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}unhide_customer_payment_report",
        data: FormData.fromMap({
          "token": token,
          "account_id": accountId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return CustomerPaymentResponseModel.fromJson(data);
        } else {
          log("API error: ${data['message']}");
        }
      }
    } catch (e) {
      log("restoreDeletedReceipt error: $e");
    }
    return null;
  }

  static Future<LeadProductSectionModel?> leadProductSection() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leadProductSection error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}get_products_for_lead",
        data: FormData.fromMap({
          "token": token,
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['status'] == true) {
            return LeadProductSectionModel.fromJson(data);
          } else {
            log("API error: ${data['message'] ?? 'Unknown error'}");
          }
        } else {
          log("leadProductSection error: Invalid response format");
        }
      } else {
        log("leadProductSection error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      log("leadProductSection error: $e");
    }
    return null;
  }

  static Future<LeadExtraSettingsResponse?> leadExtraSettings(
      String callResultId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leadExtraSettings error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}get_call_result_settings",
        data: FormData.fromMap({
          "token": token,
          "call_result_id": callResultId,
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          return LeadExtraSettingsResponse.fromJson(data);
        } else {
          log("leadExtraSettings API error: ${data['message']}");
        }
      } else {
        log("leadExtraSettings HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leadExtraSettings error: $e");
    }
    return null;
  }

  static Future<DashboardLeadsCountsModel?> newDashboardCount(
      {String? fromDate, String? toDate, String? staffId}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("Dashboard error: Token not found");
        return null;
      }

      var formDataMap = <String, dynamic>{
        "token": token,
      };

      if (fromDate != null && fromDate.isNotEmpty) {
        formDataMap["fromDate"] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        formDataMap["toDate"] = toDate;
      }
      if (staffId != null && staffId.isNotEmpty) {
        formDataMap["staffId"] = staffId;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}dashboardLeadsCounts",
        data: FormData.fromMap(formDataMap),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return DashboardLeadsCountsModel.fromJson(response.data);
      }

      log("Dashboard error: ${response.data['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("Dashboard error: $e");
    }
    return null;
  }

  static Future<PendingLeaveListModel?> pendingLeaveList(
      {String? fromDate,
      String? toDate,
      String? leaveType,
      String? staffId,
      String? status,
      String? search}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("pendingLeaveList error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}get_pending_leave_list",
        data: FormData.fromMap({
          "token": token,
          "from_date": fromDate ?? "",
          "to_date": toDate ?? "",
          "leave_type": leaveType ?? "",
          "search": search ?? "",
          "staff_id": staffId ?? "",
          "status": status ?? "",
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true ||
            data['status'] == 'true' ||
            data['status'] == 'success') {
          return PendingLeaveListModel.fromJson(data);
        } else {
          log("pendingLeaveList API error: ${data['message']}");
        }
      } else {
        log("pendingLeaveList HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("pendingLeaveList error: $e");
    }
    return null;
  }

  static Future<ApprovedLeaveListModel?> approvedLeaveList(
      {String? fromDate,
      String? toDate,
      String? leaveType,
      String? staffId,
      String? status,
      String? search}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("approvedLeaveList error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}get_approved_leave_list",
        data: FormData.fromMap({
          "token": token,
          "from_date": fromDate ?? "",
          "to_date": toDate ?? "",
          "leave_type": leaveType ?? "",
          "search": search ?? "",
          "staff_id": staffId ?? "",
          "status": status ?? "",
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return ApprovedLeaveListModel.fromJson(data);
        } else {
          log("approvedLeaveList API error: ${data['message']}");
        }
      } else {
        log("approvedLeaveList HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("approvedLeaveList error: $e");
    }
    return null;
  }

  static Future<SubmitResponse?> approveLeave(
      String id, String selectedDates, String remarks) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}approve_leave",
        data: FormData.fromMap({
          "token": token,
          "leave_id": id,
          "selected_dates": selectedDates,
          "remarks": remarks,
        }),
      );
      if (response.statusCode == 200) {
        return SubmitResponse.fromJson(response.data);
      }
    } catch (e) {
      log("approveLeave error: $e");
    }
    return null;
  }

  static Future<SubmitResponse?> rejectLeave(String id,
      {String? remarks}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}reject_leave",
        data: FormData.fromMap({
          "token": token,
          "leave_id": id,
          if (remarks != null) "remarks": remarks,
        }),
      );
      if (response.statusCode == 200) {
        return SubmitResponse.fromJson(response.data);
      }
    } catch (e) {
      log("rejectLeave error: $e");
    }
    return null;
  }

  static Future<SubmitResponse?> deleteLeaveRequest(String id) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}delete_leave_request",
        data: FormData.fromMap({
          "token": token,
          "leave_id": id,
        }),
      );
      if (response.statusCode == 200) {
        return SubmitResponse.fromJson(response.data);
      }
    } catch (e) {
      log("deleteLeaveRequest error: $e");
    }
    return null;
  }

  static Future<SubmitResponse?> editLeaveRequest({
    required String id,
    required String date,
    required String remarks,
    required String leaveType,
    required bool isHalfDay,
    String? session,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}edit_leave_request",
        data: FormData.fromMap({
          "token": token,
          "leave_id": id,
          "date": date,
          "remarks": remarks,
          "leave_type": leaveType,
          "half_day": isHalfDay ? "1" : "0",
          if (session != null) "half_day_session": session,
          if (session != null) "session": session,
          if (session != null) "half_day_type": session,
        }),
      );
      if (response.statusCode == 200) {
        return SubmitResponse.fromJson(response.data);
      }
    } catch (e) {
      log("editLeaveRequest error: $e");
    }
    return null;
  }

  static Future<DashboardLeadsCountsModel?> dashboardLeadsCounts({
    String? fromDate,
    String? toDate,
    String? userId,
    String? targetFromDate,
    String? targetToDate,
    String? status,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("dashboardLeadsCounts error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}getLeadTargetCount",
        data: FormData.fromMap({
          "token": token,
          "from_date": fromDate ?? "",
          "to_date": toDate ?? "",
          "user_id": userId ?? "",
          "target_from_date": targetFromDate ?? "",
          "target_to_date": targetToDate ?? "",
          "status": status ?? "",
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 1) {
          return DashboardLeadsCountsModel.fromJson(data);
        } else {
          log("dashboardLeadsCounts API error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        log("dashboardLeadsCounts HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("dashboardLeadsCounts error: $e");
    }
    return null;
  }

  static Future<DashboardLeadCounts?> dashboardCountsMain() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("approvedLeaveList error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}leadDashboard",
        data: FormData.fromMap({
          "token": token,
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return DashboardLeadCounts.fromJson(data);
        } else {
          log("approvedLeaveList API error: ${data['message']}");
        }
      } else {
        log("approvedLeaveList HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("approvedLeaveList error: $e");
    }
    return null;
  }

  static Future<LeadProgressBarStaffModel?> leadProgressBarStaff({
    String? fromDate,
    String? toDate,
    String? leadStatus,
    String? selectedType,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leadProgressBarStaff error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}leadProgressBarStaff",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate ?? "",
          "toDate": toDate ?? "",
          "leadStatus": leadStatus ?? "",
          "selectedType": selectedType ?? "",
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 1) {
          return LeadProgressBarStaffModel.fromJson(data);
        } else {
          log("leadProgressBarStaff API error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        log("leadProgressBarStaff HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leadProgressBarStaff error: $e");
    }
    return null;
  }

  static Future<CategoryWiseLeadBarModel?> leadProgressBarCategory({
    String? fromDate,
    String? toDate,
    String? leadStatus,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leadProgressBarCategory error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}leadProgressBarCategory",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate ?? "",
          "toDate": toDate ?? "",
          "leadStatus": leadStatus ?? "",
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 1) {
          return CategoryWiseLeadBarModel.fromJson(data);
        } else {
          log("leadProgressBarCategory API error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        log("leadProgressBarCategory HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leadProgressBarCategory error: $e");
    }
    return null;
  }

  static Future<LeadProgressBarStatusWise?> leadProgressBarStatus({
    String? fromDate,
    String? toDate,
    String? leadStatus,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leadProgressBarCategory error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}leadProgressBarStatus",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate ?? "",
          "toDate": toDate ?? "",
          "leadStatus": leadStatus ?? "",
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 1) {
          return LeadProgressBarStatusWise.fromJson(data);
        } else {
          log("leadProgressBarCategory API error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        log("leadProgressBarCategory HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leadProgressBarCategory error: $e");
    }
    return null;
  }

  static Future<CallStatusReportModel?> callStatusReportData({
    String? fromDate,
    String? toDate,
    String? staffId,
    String? branchId,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getCallStatusReport",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return CallStatusReportModel.fromJson(data);
        }
      }
    } catch (e) {
      log("callStatusReportData error: $e");
    }
    return null;
  }

  static Future<CallStatusReportOntapModel?> callStatusReportOntapData({
    String? fromDate,
    String? toDate,
    String? staffId,
    String? callResponseId,
    String? branchId,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getCallStatusReportFilterResult",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "callResponseId": callResponseId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return CallStatusReportOntapModel.fromJson(data);
        }
      }
    } catch (e) {
      log("callStatusReportDataOntap error: $e");
    }
    return null;
  }

  static Future<StagewiseReportModel?> stagwWiseReportData({
    String? fromDate,
    String? toDate,
    String? staffId,
    //String? callResponseId,
    String? branchId,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getStageReport",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          //  "callResponseId": callResponseId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return StagewiseReportModel.fromJson(data);
        }
      }
    } catch (e) {
      log("StageReportData error: $e");
    }
    return null;
  }

  static Future<StagewiseReportOntapModel?> stagwWiseReportOntapData({
    String? fromDate,
    String? toDate,
    String? staffId,
    String? callResultId,
    String? branchId,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getStageReportFilter",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "callResultId": callResultId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return StagewiseReportOntapModel.fromJson(data);
        }
      }
    } catch (e) {
      log("StageOntapReportData error: $e");
    }
    return null;
  }

  static Future<LeadSourceReportModel?> leadSourceReportData({
    String? fromDate,
    String? toDate,
    String? staffId,
    // String? callResultId,
    String? branchId,
    String? page,
    String? pageSize,
    String? leadCategoryId,
    String? productId,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getLeadSourceReport",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          //  "callResultId": callResultId,
          "branchId": branchId,
          "page": page,
          "pageSize": pageSize,
          "leadCategoryId": leadCategoryId,
          "productId": productId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return LeadSourceReportModel.fromJson(data);
        }
      }
    } catch (e) {
      log("leadSourceReportData error: $e");
    }
    return null;
  }

  static Future<LeadSourceReportOntapModel?> leadSourceReportOntapData({
    String? fromDate,
    String? toDate,
    String? staffId,
    //  String? callResultId,
    String? branchId,
    String? leadSourceId,
    // String? pageSize,
    String? leadCategoryId,
    String? productId,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getLeadSourceReportFilter",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          //  "callResultId": callResultId,
          "branchId": branchId,
          "leadSourceourceId": leadSourceId,
          // "pageSize": pageSize,
          // "leadCategoryId": leadCategoryId,
          // "productId": productId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return LeadSourceReportOntapModel.fromJson(data);
        }
      }
    } catch (e) {
      log("leadSourceOntapReportData error: $e");
    }
    return null;
  }

  static Future<CategoryReportModel?> leadCategoryReportData({
    String? fromDate,
    String? toDate,
    String? staffId,
    // String? callResultId,
    String? branchId,
    String? page,
    String? pageSize,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getLeadCategoryReport",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          //  "callResultId": callResultId,
          "branchId": branchId,
          "page": page,
          "pageSize": pageSize,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true ||
            data['status'] == 'success' ||
            data['status'] == 1 ||
            data['status'] == 'true' ||
            data['status'] == 200) {
          return CategoryReportModel.fromJson(data);
        }
      }
    } catch (e) {
      log("leadCategoryReportData error: $e");
    }
    return null;
  }

  static Future<LeadCategoryReportOntapModel?> leadCategoryReportOntapData({
    String? fromDate,
    String? toDate,
    String? staffId,
    //  String? callResultId,
    String? branchId,
    String? leadCategoryId,
    // String? pageSize,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) return null;

      final response = await _dio.post(
        "${await Config.getUrl()}getLeadCategoryReportFilter",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          //  "callResultId": callResultId,
          "branchId": branchId,
          "leadCategoryId": leadCategoryId,
          // "pageSize": pageSize,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return LeadCategoryReportOntapModel.fromJson(data);
        }
      }
    } catch (e) {
      log("leadCategoryOntapReportData error: $e");
    }
    return null;
  }

  static Future<GetLeaveBalanceModel?> leaveAvailable() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}get_leave_balance",
        data: FormData.fromMap({"token": token}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return GetLeaveBalanceModel.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<CallStatusReportResponse?> callStatusReportTable(
    String? fromDate,
    String? toDate,
    String? staffId,
    String? branchId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getCallStatusReportDetailed",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return CallStatusReportResponse.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<StagewiseReportResponse?> stageWiseReportTable(
    String? fromDate,
    String? toDate,
    String? staffId,
    String? branchId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getStageReportDetailed",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return StagewiseReportResponse.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<LeadSourceReportResponse?> leadSourceReportTable(
    String? fromDate,
    String? toDate,
    String? staffId,
    String? branchId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getSourceReportDetailed",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return LeadSourceReportResponse.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<CategoryReportTableModel?> categoryReportTable(
    String? fromDate,
    String? toDate,
    String? staffId,
    String? branchId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getCategoryReportDetailed",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return CategoryReportTableModel.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<CloudCallReportModel?> cloudCallReport(
    String? fromDate,
    String? toDate,
    String? staffId,
    String? branchId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getCloudCallReport",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return CloudCallReportModel.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<PhoneCallReportModel?> phoneCallReport(
    String? fromDate,
    String? toDate,
    String? staffId,
    String? branchId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getPhoneCallReport",
        data: FormData.fromMap({
          "token": token,
          "fromDate": fromDate,
          "toDate": toDate,
          "staffId": staffId,
          "branchId": branchId,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return PhoneCallReportModel.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<GetLeaveApprovalRejectTemplate?>
      getApprovalRejectTemplate() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("getApprovalRejectTemplate error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}get_templates",
        data: FormData.fromMap({
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          log("getApprovalRejectTemplate: Templates fetched successfully, count: ${(data['data'] as List?)?.length ?? 0}");
          return GetLeaveApprovalRejectTemplate.fromJson(data);
        } else {
          log("getApprovalRejectTemplate API error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        log("getApprovalRejectTemplate HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("getApprovalRejectTemplate error: $e");
    }
    return null;
  }

  static Future<GetAttendanceReportModel?> getAttendanceReport(
    String? fromDate,
    String? toDate,
    String? staffId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }
      final response = await _dio.post(
        "${await Config.getUrl()}getAttendanceReport",
        data: FormData.fromMap({
          "token": token,
          "from_date": fromDate,
          "to_date": toDate,
          "staff_id": staffId,
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return GetAttendanceReportModel.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<GetActiveStatusModel?> getActiveStatus({String? status}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null || token.isEmpty) {
        log("leaveAvailable error: Token not found");
        return null;
      }

      final response = await _dio.post(
        "${await Config.getUrl()}getActiveStatus",
        data: FormData.fromMap({
          "token": token,
          "status": status,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 'success') {
          return GetActiveStatusModel.fromJson(data);
        }
        log("leaveAvailable API error: ${data['message']}");
      } else {
        log("leaveAvailable HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      log("leaveAvailable error: $e");
    }
    return null;
  }

  static Future<GoogleDriveAccountsModel?> getGoogleDriveAccounts() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getGoogleDriveAccounts error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_drive_accounts",
        data: formData,
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GoogleDriveAccountsModel.fromJson(response.data);
      }

      log("getGoogleDriveAccounts error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getGoogleDriveAccounts error: $e");
    }
    return null;
  }

  static Future<GoogleDriveFilesResponse?> getGoogleDriveFiles(
      String callMasterId, String iD, String parentId,
      {String refFunction = "Leads"}) async {
    print("reached here");
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getGoogleDriveAccounts error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "reference_id": callMasterId,
        "reference_function": refFunction,
        "account_id": iD,
        "parent_id": parentId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}get_gdrive_files_list",
        data: formData,
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GoogleDriveFilesResponse.fromJson(response.data);
      }

      log("getGoogleDriveAccounts error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getGoogleDriveAccounts error: $e");
    }
    return null;
  }

  static Future<TagListForFilterModel?> getLeadsTagForFilter(
      String callResultId) async {
    print("reached here tagggsssss");
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("Taggsgssss error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "call_result_id": callResultId,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}getTagLists",
        data: formData,
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return TagListForFilterModel.fromJson(response.data);
      }

      log("Taggsgssss error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("Taggsgssss error: $e");
    }
    return null;
  }

  static Future<CreateGoogleFoldersResponse?> createGoogleFolders(
      String callMasterId, String iD, String parentId, String folderName,
      {String refFunction = "Leads"}) async {
    print("reached here");
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getGoogleDriveAccounts error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "reference_id": callMasterId,
        "reference_function": refFunction,
        "account_id": iD,
        "parent_id": parentId,
        "folder_name": folderName,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}create_gdrive_folder_api",
        data: formData,
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return CreateGoogleFoldersResponse.fromJson(response.data);
      }

      log("getGoogleDriveAccounts error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getGoogleDriveAccounts error: $e");
    }
    return null;
  }

  static Future<UploadGoogleFilesResponse?> uploadGoogleFiles(
      String callMasterId, String iD, String parentId, String File,
      {String refFunction = "Leads", String? customFileName}) async {
    print("reached here");
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getGoogleDriveAccounts error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "call_master_id": callMasterId,
        "ref_function": refFunction,
        "g_account": iD,
        "parent_id": parentId,
        "userfile":
            await MultipartFile.fromFile(File, filename: customFileName),
      });

      final response = await _dio.post(
        "${await Config.getUrl()}upload_gdrive_file_api",
        data: formData,
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return UploadGoogleFilesResponse.fromJson(response.data);
      }

      log("getGoogleDriveAccounts error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getGoogleDriveAccounts error: $e");
    }
    return null;
  }

  static Future<GetLeadSourceModel?> getLeadSourceAddleads() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}getLeadSource",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetLeadSourceModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<ShowTransferHideOrShowModel?> showTransferHideOrShow() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}show_transfer_fresh",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ShowTransferHideOrShowModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<AddGoogleDriveResponseModel?>
      addConnectGoogleAccountApi() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}connect_google_account_api",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return AddGoogleDriveResponseModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<ProductDescriptionModel?> productDescription(
      String productId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "product_id": productId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_description_by_product",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ProductDescriptionModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<DamagedListApiResponse?> damagedListApi(
      String customerId, String productId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "customer_id": customerId,
        "product_id": productId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}damaged_list_api",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return DamagedListApiResponse.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<GetRentReturnModel?> getRentReturnList(String rentId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "return_id": rentId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}edit_rent_return",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetRentReturnModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<RenameGdriveApiModel?> renameGoogleDriveFilesndFolders(
      String fileId, String newName) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "file_id": fileId,
        "new_name": newName,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}rename_gdrive_file_api",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return RenameGdriveApiModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<DeleteGoogleDriveFileModel?> deleteGoogleDriveFilesndFolders(
      String fileId, String accountId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "file_id": fileId,
        "account_id": accountId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}delete_gdrive_file_api",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return DeleteGoogleDriveFileModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<DeleteRentalReturnModel?> deleteRentReturn(
      String rentId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "return_id": rentId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}delete_rent_return",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return DeleteRentalReturnModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<ExpiredListModel?> expiredList() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}expired_returns_api",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ExpiredListModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<GetStaffDocumentListModel?> getStaffDocumentList(
      String referenceFunction, String accountId, String referenceId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("leadSourceAddleads error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "reference_function": "Staff Documents",
        "account_id": accountId,
        "reference_id": referenceId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_staff_documents",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetStaffDocumentListModel.fromJson(response.data);
      }
      log("leadSourceAddleads error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("leadSourceAddleads error: $e");
    }
    return null;
  }

  static Future<StaffDocumentUploadModel?> staffDocumentUpload(
    String accountId,
    List<String> documentTypes,
    List<MultipartFile> documents,
    String staffName,
    String staffId,
  ) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("staffDocumentUpload error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "account_id": accountId,
        "staff_name": staffName,
        "reference_id": staffId,
        for (int i = 0; i < documentTypes.length; i++)
          "document_types[$i]": documentTypes[i],
        for (int i = 0; i < documents.length; i++)
          "documents[$i]": documents[i],
      });

      final response = await _dio.post(
        "${await Config.getUrl()}upload_staff_documents",
        data: formData,
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return StaffDocumentUploadModel.fromJson(response.data);
      }
      log("staffDocumentUpload error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("staffDocumentUpload error: $e");
    }
    return null;
  }

  static Future<RecentReceiptModel?> getRecentReceipt(
      String page, String pageSize,
      {String? fDate, String? tDate, String? createdBy, String? headId}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentReceipt error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "page": page,
        "pageSize": pageSize,
        "from_date": fDate ?? "",
        "to_date": tDate ?? "",
        "created_id": createdBy ?? "",
        "collected_id": headId ?? "",
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_receipt_recent",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return RecentReceiptModel.fromJson(response.data);
      }
      log("getRecentReceipt error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentReceipt error: $e");
    }
    return null;
  }

  static Future<GetCompanyInvoiceModel?> getRecentInvoice(
      String page, String pageSize,
      {String? fDate,
      String? tDate,
      String? customerId,
      String? typeId}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentInvoice error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "page": page,
        "pageSize": pageSize,
        "from_date": fDate ?? "",
        "to_date": tDate ?? "",
        "client_id": customerId ?? "",
        "type": typeId ?? "",
      });
      final response = await _dio.post(
        "${await Config.getUrl()}getCompanyInvoiceRecent",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetCompanyInvoiceModel.fromJson(response.data);
      }
      log("getRecentInvoice error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentInvoice error: $e");
    }
    return null;
  }

  static Future<GetRecentExpenseModel?> getRecentExpense(
      String page, String pageSize,
      {String? fDate, String? tDate}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "page": page,
        "pageSize": pageSize,
        "from_date": fDate ?? "",
        "to_date": tDate ?? "",
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_recent_transaction_expence",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetRecentExpenseModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<GetArchievedInvoiceModel?> getArchievedInvoice(
      String page, String pageSize) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "page": page,
        "pageSize": pageSize,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_archieved_invoice_list",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetArchievedInvoiceModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<UnhideInvoiceModel?> unhideInvoice(String invoiceId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "invoice_id": invoiceId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}unhide_invoice",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return UnhideInvoiceModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<GetRentalViewModel?> getRentalReturnView(
      String returnId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "return_id": returnId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}view_rent_return",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetRentalViewModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<ProjectDetailsResponse?> projectDetailsDashboard(
      String projectId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "project_id": projectId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}project_detail",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ProjectDetailsResponse.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<ProjectTraceResponse?> projectTrace(
      String projectId, String userId,
      {String? fromDate,
      String? toDate,
      String? moduleId,
      String? taskId}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "project_id": projectId,
        "user_id": userId,
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
        if (moduleId != null) "module_id": moduleId,
        if (taskId != null) "task_id": taskId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_staff_task_list",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ProjectTraceResponse.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<AddModuleResponse?> addModule(
      String projectId, String moduleName) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "project_id": projectId,
        "module_name": moduleName,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}insert_module",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return AddModuleResponse.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<AddModuleResponse?> updateModule(
      String moduleId, String moduleName) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("updateModule error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "module_id": moduleId,
        "module_name": moduleName,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}update_module",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return AddModuleResponse.fromJson(response.data);
      }
      log("updateModule error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("updateModule error: $e");
    }
    return null;
  }

  static Future<bool> deleteModule(String moduleId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("deleteModule error: Token not found");
        return false;
      }
      final formData = FormData.fromMap({
        "token": token,
        "module_id": moduleId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}delete_module",
        data: formData,
      );
      return response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success');
    } catch (e) {
      log("deleteModule error: $e");
    }
    return false;
  }

  static Future<ModuleListResponse?> getModuleList(String projectId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "project_id": projectId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_module_list",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ModuleListResponse.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<GetTaskListResponse?> getTaskList(
      String projectId, String userId, String moduleId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "project_id": projectId,
        "user_id": userId,
        "module_id": moduleId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_tasks_by_project",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetTaskListResponse.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<ProductTypeResponse?> getProductTypes() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_selected_product_types",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ProductTypeResponse.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<PostProductModel?> postStocks(
      List<Map<String, dynamic>> products) async {
    final token = await Common.getSharedPref("token");
    Map<String, dynamic> data = {
      "token": token,
      "add_stock": "1",
    };

    for (int i = 0; i < products.length; i++) {
      data["product_id[$i]"] = products[i]["product_id"];
      data["quantity[$i]"] = products[i]["quantity"];
      data["unit_price[$i]"] = products[i]["unit_price"];
      data["unit[$i]"] = products[i]["unit"];
      data["product_name[$i]"] = products[i]["product_name"];
    }

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_stock_register",
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 200) {
        return PostProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("🔥 postStocks error: $e");
    }
    return null;
  }

  // static Future<PostProductModel?> postStock(
  //   String productName,
  //   String purchasePrice,
  //   String sellingPrice,
  //   String mrp,
  //   String productType,
  //   String quantity,
  //   String status, {
  //   String? productId,
  //   String? unit,
  // }) async {
  //   final token = await Common.getSharedPref("token");
  //   Map<String, dynamic> data = {
  //     "token": token,
  //     "product_name": productName,
  //     "purchase_price": purchasePrice,
  //     "selling_price": sellingPrice,
  //     "product_mrp": mrp,
  //     "product_type": productType,
  //     "quantity": quantity,
  //     "stock_status": status,
  //     "add_stock": "1",
  //     if (productId != null) "product_id": productId,
  //     if (unit != null) "unit": unit,
  //   };

  //   try {
  //     final response = await _dio.post(
  //       "${await Config.getUrl()}post_stock_register",
  //       data: FormData.fromMap(data),
  //     );

  //     if (response.statusCode == 200) {
  //       return PostProductModel.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     log("🔥 postStock error: $e");
  //   }
  //   return null;
  // }
  static Future<PostProductModel?> postStock(
    String productName,
    String purchasePrice,
    String sellingPrice,
    String mrp,
    String productType,
    String quantity,
    String status, {
    String? productId,
    String? unit,
  }) async {
    final token = await Common.getSharedPref("token");

    Map<String, dynamic> data = {
      "token": token,
      "product_name": productName,
      "purchase_price": purchasePrice,
      "selling_price": sellingPrice,
      "product_mrp": mrp,
      "product_type": productType,
      "quantity": quantity,
      "stock_status": status,
      "add_stock": "1",
      if (productId != null) "product_id": productId,
      if (unit != null) "unit": unit,
    };

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_stock_register",
        data: data,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        return PostProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("🔥 postStock error: $e");
    }

    return null;
  }

  static Future<GetStockRegisterListModel?> getStockRegisterList(
      String productId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "product_id": productId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_stock_register",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
                print("getStockRegisterList response: ${response.data}");
        return GetStockRegisterListModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<ProductHistoryRentalModel?> getStockHistoryRental(
      String productId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "product_id": productId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_product_history",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ProductHistoryRentalModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<GetOpeningModel?> getOpeningStockList(
      {String? productId, String? locationId}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getOpeningStockList error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        if (productId != null) "product_id": productId,
        if (locationId != null) "location_id": locationId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_opening_stock",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetOpeningModel.fromJson(response.data);
      }
    } catch (e) {
      log("getOpeningStockList error: $e");
    }
    return null;
  }

  static Future<PostProductModel?> postOpeningStocks(String date,
      String locationId, List<Map<String, dynamic>> products) async {
    final token = await Common.getSharedPref("token");
    Map<String, dynamic> data = {
      "token": token,
      "date": date,
      "location_id": locationId,
      "is_opening_stock": "1",
    };

    for (int i = 0; i < products.length; i++) {
      data["product_id[$i]"] = products[i]["product_id"];
      data["quantity[$i]"] = products[i]["quantity"];
      data["unit_price[$i]"] = products[i]["unit_price"];
      data["unit[$i]"] = products[i]["unit"];
      data["product_name[$i]"] = products[i]["product_name"];
      data["description[$i]"] = products[i]["description"];
    }

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_stock_opening",
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 200) {
        return PostProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("🔥 postOpeningStocks error: $e");
    }
    return null;
  }

  static Future<GetStockRequestModel?> getRequestStockList(
      {String? productId,
      String? locationId,
      String? fromDate,
      String? toDate}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getOpeningStockList error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        if (productId != null) "product_id": productId,
        if (locationId != null) "location_id": locationId,
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_stock_request",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
                print("getRequestStockList response: ${response.data}");
        return GetStockRequestModel.fromJson(response.data);
      }
    } catch (e) {
      log("getOpeningStockList error: $e");
    }
    return null;
  }

  static Future<GetOpenstockForEditModel?> getOpenStockForEdit(
      String stockId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "id": stockId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}edit_opening_stock",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetOpenstockForEditModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<DeleteModelOpenstock?> deleteOpenStock(String stockId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "item_id": stockId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}delete_opening_stock",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return DeleteModelOpenstock.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<PostProductModel?> updateOpeningStock({
    required String id,
    required String date,
    required String locationId,
    required String productId,
    required String quantity,
    required String unitPrice,
    required String unit,
    required String description,
  }) async {
    final token = await Common.getSharedPref("token");
    final formData = FormData.fromMap({
      "token": token,
      "id": id,
      "date": date,
      "location_id": locationId,
      "product_id": productId,
      "quantity": quantity,
      "unit_price": unitPrice,
      "unit": unit,
      "description": description,
    });

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}update_opening_stock",
        data: formData,
      );

      if (response.statusCode == 200) {
        return PostProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("🔥 postOpeningStocks error: $e");
    }
    return null;
  }

  static Future<StockConsumptionListModel?> getProductStockConsumedList(
      String productId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "product_id": productId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_stock_consumed",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return StockConsumptionListModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<DeleteModelOpenstock?> deleteStockConsumed(
      String stockId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "id": stockId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}delete_stock_consumption",
        data: formData,
      );
      if (response.statusCode == 200) {
        return DeleteModelOpenstock.fromJson(response.data);
      }
    } catch (e) {
      log("deleteStockConsumed error: $e");
    }
    return null;
  }

  static Future<PostProductModel?> addStockConsumption({
    required String date,
    required String locationId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await Common.getSharedPref("token");
      Map<String, dynamic> data = {
        "token": token,
        "date": date,
        "location_id": locationId,
      };

      for (int i = 0; i < items.length; i++) {
        data["product_id[$i]"] = items[i]["product_id"];
        data["quantity[$i]"] = items[i]["quantity"];
        data["unit_price[$i]"] = items[i]["unit_price"];
        data["unit[$i]"] = items[i]["unit"];
      }

      final response = await _dio.post(
        "${await Config.getUrl()}post_consumed_stock",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return PostProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("addStockConsumption error: $e");
    }
    return null;
  }

  static Future<StockRequestEditDetails?> getStockRequestEditDetails(
      String stockId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "id": stockId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}edit_stock_request",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
                print("getStockRequestEditDetails response: ${response.data}");
        return StockRequestEditDetails.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<DeleteModelOpenstock?> deleteStockRequest(
      String stockId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "id": stockId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}delete_stock_request",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return DeleteModelOpenstock.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<PostProductModel?> postStockRequest(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_stock_request",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return PostProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("postStockRequest error: $e");
    }
    return null;
  }

  static Future<PostProductModel?> updateStockRequest(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}update_stock_request",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return PostProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("updateStockRequest error: $e");
    }
    return null;
  }

  static Future<GetMaterialForStockConsumptionModel?> getMaterialForConsumption(
      String consumedDate, String productId, String locationId) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
        "consumed_date": consumedDate,
        "product_id": productId,
        "location_id": locationId,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}get_material_stock",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return GetMaterialForStockConsumptionModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<GetPurchaseRequestListModel?> purchaseRequestList(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_all_purchase_requests",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetPurchaseRequestListModel.fromJson(response.data);
      }
    } catch (e) {
      log("updateStockRequest error: $e");
    }
    return null;
  }

  static Future<GetPurchaseOrderModel?> purchaseOrderList(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_purchase_orders",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetPurchaseOrderModel.fromJson(response.data);
      }
    } catch (e) {
      log("updateStockRequest error: $e");
    }
    return null;
  }

  static Future<PurchaseBillModel?> purchaseBillList(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_purchase_bill_data",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        print("purchaseBillList response: ${response.data}");
        var responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }
        return PurchaseBillModel.fromJson(responseData);
      }
    } catch (e) {
      log("purchaseBillList error: $e");
    }
    return null;
  }

  static Future<dynamic> postPurchaseRequest(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_purchase_request",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("postPurchaseRequest error: $e");
    }
    return null;
  }

  static Future<dynamic> postPurchaseOrder(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_purchase_order",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("postPurchaseOrder error: $e");
    }
    return null;
  }

  static Future<dynamic> updatePurchaseOrder(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}update_purchase_order",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("updatePurchaseOrder error: $e");
    }
    return null;
  }

  static Future<dynamic> postPurchaseBill(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_purchase_bill",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("postPurchaseBill error: $e");
    }
    return null;
  }

  static Future<dynamic> postPurchaseBillPayment(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_purchase_bill_payment",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("postPurchaseBillPayment error: $e");
    }
    return null;
  }

  static Future<dynamic> updatePurchaseBill(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}update_purchase_bill",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("updatePurchaseBill error: $e");
    }
    return null;
  }

  static Future<dynamic> deletePurchaseBill(String billId) async {
    final token = await Common.getSharedPref("token");
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_purchase_bill",
        data: FormData.fromMap({
          "token": token,
          "id": billId,
        }),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("deletePurchaseBill error: $e");
    }
    return null;
  }

  static Future<dynamic> deletePurchaseOrder(String orderId) async {
    final token = await Common.getSharedPref("token");
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_purchase_order",
        data: FormData.fromMap({
          "token": token,
          "id": orderId,
        }),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("deletePurchaseOrder error: $e");
    }
    return null;
  }

  static Future<GetSupplierListModel?> getSupplierList(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_suppliers",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetSupplierListModel.fromJson(response.data);
      }
    } catch (e) {
      log("getSupplierList error: $e");
    }
    return null;
  }

  static Future<dynamic> addSupplier(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}add_supplier",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("addSupplier error: $e");
    }
    return null;
  }

  static Future<GetPurchaseReturnModel?> purchaseReturnList(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_all_return_purchase",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetPurchaseReturnModel.fromJson(response.data);
      }
    } catch (e) {
      log("updateStockRequest error: $e");
    }
    return null;
  }

  static Future<dynamic> postPurchaseReturn(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}post_purchase_return",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("postPurchaseReturn error: $e");
    }
    return null;
  }

  static Future<dynamic> updatePurchaseReturn(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}update_purchase_return",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("updatePurchaseReturn error: $e");
    }
    return null;
  }

  static Future<dynamic> deletePurchaseReturn(String returnId) async {
    final token = await Common.getSharedPref("token");
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_purchase_return",
        data: FormData.fromMap({
          "token": token,
          "return_id": returnId,
        }),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("deletePurchaseReturn error: $e");
    }
    return null;
  }

  static Future<GetPurchaseReturnAddListModel?> purchaseReturngetForAdd(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_purchase_stock_list",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetPurchaseReturnAddListModel.fromJson(response.data);
      }
    } catch (e) {
      log("updateStockRequest error: $e");
    }
    return null;
  }

  static Future<GetStaffSalaryDetailsModel?> getStaffSalaryDetails(
      String staffId) async {
    final token = await Common.getSharedPref("token");
    final data = {'staff_id': staffId};
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}getSalaryDetails",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetStaffSalaryDetailsModel.fromJson(response.data);
      }
    } catch (e) {
      log("getStaffSalaryDetails error: $e");
    }
    return null;
  }

  static Future<bool> saveSalary({
    String? salaryId,
    required String staffId,
    required String amount,
    required String fromDate,
    required String toDate,
    String? remark,
  }) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
      'staff_id': staffId,
      'amount': amount,
      'from_date': fromDate,
      'to_date': toDate,
      'remark': remark ?? '',
    };
    if (salaryId != null) {
      data['id'] = salaryId;
    }

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}saveSalary",
        data: FormData.fromMap(data),
      );
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      log("saveSalary error: $e");
      return false;
    }
  }

  static Future<bool> deleteSalaryDetails(String salaryId) async {
    final token = await Common.getSharedPref("token");
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}deleteSalary",
        data: FormData.fromMap({
          'token': token,
          'id': salaryId,
        }),
      );
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      log("deleteSalaryDetails error: $e");
      return false;
    }
  }

  static Future<StaffAccountDetailsModel?> getStaffAccountDetails(
      String staffId) async {
    final token = await Common.getSharedPref("token");
    final data = {'staff_id': staffId};
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}getStaffAccounts",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return StaffAccountDetailsModel.fromJson(response.data);
      }
    } catch (e) {
      log("getStaffAccountDetails error: $e");
    }
    return null;
  }

  static Future<GetPurchaseRequestDetailsResponse?> getPurchaseRequestDetails(
      String requestId) async {
    final token = await Common.getSharedPref("token");
    final data = {'id': requestId};
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_request_with_materials",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetPurchaseRequestDetailsResponse.fromJson(response.data);
      }
    } catch (e) {
      log("getPurchaseRequestDetails error: $e");
    }
    return null;
  }

  static Future<dynamic> updatePurchaseRequest(
      Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}update_purchase_request",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("updatePurchaseRequest error: $e");
    }
    return null;
  }

  static Future<GetPurchaseOrderDetailsModel?> getPurchaseOrderDetails(
      String requestId) async {
    final token = await Common.getSharedPref("token");
    final data = {'id': requestId};
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}edit_purchase_order",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetPurchaseOrderDetailsModel.fromJson(response.data);
      }
    } catch (e) {
      log("getPurchaseOrderDetails error: $e");
    }
    return null;
  }

  static Future<DeletePurchaseRequestModel?> deletePurchaseRequest(
      String requestId) async {
    final token = await Common.getSharedPref("token");
    final data = {'id': requestId};
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_purchase_request",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return DeletePurchaseRequestModel.fromJson(response.data);
      }
    } catch (e) {
      log("getPurchaseOrderDetails error: $e");
    }
    return null;
  }

  static Future<GetPurchaseBillDetailsModel?> getPurchaseBillDetailsEdit(
      String requestId) async {
    final token = await Common.getSharedPref("token");
    final data = {'id': requestId};
    data['token'] = token;
    try {
  final response = await _dio.post(
    "${await Config.getUrl()}edit_purchase_bill",
    data: FormData.fromMap(data),
  );

  print("RAW RESPONSE => ${response.data}");

  final model = GetPurchaseBillDetailsModel.fromJson(response.data);

  print("MODEL PARSED SUCCESSFULLY");

  return model;
} catch (e, s) {
  print("PARSING ERROR => $e");
  print("STACK => $s");
}
    return null;
  }

//  static Future<ProfileResponseModel?> getProfileView(
//       Map<String, dynamic> data) async {
//     final token = await Common.getSharedPref("token");
//     data['token'] = token;
//     try {
//       final response = await _dio.post(
//         "${await Config.getUrl()}profView",
//         data: FormData.fromMap(data),
//       );
//       if (response.statusCode == 200) {
//         return ProfileResponseModel.fromJson(response.data);
//       }
//     } catch (e) {
//       log("updateStockRequest error: $e");
//     }
//     return null;
//   }

  static Future<ProfileResponseModel?> getProfileView() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("getRecentExpense error: Token not found");
        return null;
      }
      final formData = FormData.fromMap({
        "token": token,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}profView",
        data: formData,
      );
      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return ProfileResponseModel.fromJson(response.data);
      }
      log("getRecentExpense error: ${response.data?['message'] ?? 'Unknown error'}");
    } catch (e) {
      log("getRecentExpense error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> verifyReceipt(String receiptId,
      {String? title, bool isRevert = false}) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token?.isEmpty ?? true) {
        log("${isRevert ? 'revert' : 'verify'}Receipt error: Token not found");
        return null;
      }

      final formData = FormData.fromMap({
        "token": token,
        "receipt_id": receiptId,
        "title": title,
      });

      final response = await _dio.post(
        "${await Config.getUrl()}${'verify_receipt'}",
        data: formData,
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == true ||
              response.data['status'] == 'success')) {
        return response.data;
      }

      log("${isRevert ? 'revert' : 'verify'}Receipt error: ${response.data?['message'] ?? 'Unknown error'}");
      return null;
    } catch (e) {
      log("${isRevert ? 'revert' : 'verify'}Receipt error: $e");
      return null;
    }
  }

  static Future<GetPurchaseRequestListModel?> purchaseReqAprovalOrReject(
      String requestId, String requestStatus) async {
    final token = await Common.getSharedPref("token");
    final data = {'id': requestId, 'request_status': requestStatus};
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}approve_reject_purchase_request",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetPurchaseRequestListModel.fromJson(response.data);
      }
    } catch (e) {
      log("getPurchaseOrderDetails error: $e");
    }
    return null;
  }

  static Future<DeletePurchaseOrderEditProductModel?>
      deletePurchaseOrderProduct({
    required String pmrId,
  }) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'id': pmrId,
      'token': token,
    };

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_purchase_material_request",
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 200) {
        return DeletePurchaseOrderEditProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("deletePurchaseOrderProduct error: $e");
    }
    return null;
  }

  static Future<DeletePurchaseOrderEditProductModel?>
      deletePurchaseOrderRealProduct({
    // required String productId,
    required String purchaseOrderId,
  }) async {
    final token = await Common.getSharedPref("token");
    final data = {
      //  'item_id': productId,
      'item_id': purchaseOrderId,
      'token': token,
    };

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_purchase_order_material",
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 200) {
        return DeletePurchaseOrderEditProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("deletePurchaseOrderProduct error: $e");
    }
    return null;
  }

  static Future<DeletePurchaseOrderEditProductModel?>
      deletePurchaseOrderBillProduct({
    required String productId,
    required String billId,
  }) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'item_id': productId,
      'bill_id': billId,
      'token': token,
    };

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_billed_item",
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 200) {
        return DeletePurchaseOrderEditProductModel.fromJson(response.data);
      }
    } catch (e) {
      log("deletePurchaseOrderProduct error: $e");
    }
    return null;
  }

  static Future<ContentIdModel?> getContentId({
    required String productType,
  }) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'product_type': productType,
      'token': token,
    };

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_content_id",
        data: FormData.fromMap(data),
      );

      if (response.statusCode == 200) {
        return ContentIdModel.fromJson(response.data);
      }
    } catch (e) {
      log("getContentId error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateAttendanceRemark({
    required String attendanceId,
    // required String staffId,
    // required String? date,
    required String remark,
  }) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'id': attendanceId,
      // 'staff_id': staffId,
      //'date': date,
      'remark': remark,
      'token': token,
    };

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}update_attendance_remark",
        data: FormData.fromMap(data),
      );
    } catch (e) {
      log("updateAttendanceRemark error: $e");
    }
    return null;
  }

  static Future<Uint8List?> downloadStaffTask({
    required String userId,
    required String projectId,
    required String fromDate,
    required String toDate,
  }) async {
    final token = await Common.getSharedPref("token");
    try {
      final formData = FormData.fromMap({
        "token": token,
        "user_id": userId,
        "project_id": projectId,
        "fromdate": fromDate,
        "todate": toDate,
      });
      final response = await _dio.post(
        "${await Config.getUrl()}download_staff_task",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("downloadStaffTask error: $e");
    }
    return null;
  }

  static Future<ViewPurchaseBillResponse?> viewPurcahseBillDetails({
    required String billId,
  }) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'bill_id': billId,
      'token': token,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_purchase_bill_view",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        print("RAW View => ${response.data}");
        return ViewPurchaseBillResponse.fromJson(response.data);
      }
    } catch (e) {
      log("viewPurcahseBillDetails error: $e");
    }
    return null;
  }

  static Future<UnitResponse?> getUnits() async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}getUnits",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return UnitResponse.fromJson(response.data);
      }
    } catch (e) {
      log("getUnits error: $e");
    }
    return null;
  }

  static Future<dynamic> addUnit(String unitName) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
      'unit_name': unitName,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}add_unit",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("addUnit error: $e");
    }
    return null;
  }

  static Future<SupplierDetailsResponse?> getSuppliersDetails() async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_supplier_list",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return SupplierDetailsResponse.fromJson(response.data);
      }
    } catch (e) {
      log("get_supplier_list error: $e");
    }
    return null;
  }

  static Future<dynamic> deleteSupplier(String id) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'id': id,
      'token': token,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}delete_supplier",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("deleteSupplier error: $e");
    }
    return null;
  }

  static Future<dynamic> editSupplier(Map<String, dynamic> data) async {
    final token = await Common.getSharedPref("token");
    data['token'] = token;
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}edit_supplier",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      log("editSupplier error: $e");
    }
    return null;
  }

  static Future<QrCodeProductResponse?> getQrcodeproductDetails(
      String barCode) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
      'bar_code': barCode,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_product_by_barcode",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return QrCodeProductResponse.fromJson(response.data);
      }
    } catch (e) {
      log("get_product_by_barcode error: $e");
    }
    return null;
  }

  static Future<GetCheckStockMaterialsResponse?> getCheckStockMaterial(
      String materialId) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
      'material_id': materialId,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_CheckStock",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return GetCheckStockMaterialsResponse.fromJson(response.data);
      }
    } catch (e) {
      log("GetCheckStockMaterialsResponse error: $e");
    }
    return null;
  }

  static Future<SupplierDashboardResponse?> getSupplierDashboard(
      String supplierId) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
      'supplier_id': supplierId,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_suppler_dashboard",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return SupplierDashboardResponse.fromJson(response.data);
      }
    } catch (e) {
      log("SupplierDashboardResponse error: $e");
    }
    return null;
  }

  static Future<SupplierLedgerResponse?> getSupplierLedger(
      String supplierId) async {
    final token = await Common.getSharedPref("token");
    final data = {
      'token': token,
      'supplier_id': supplierId,
    };
    try {
      final response = await _dio.post(
        "${await Config.getUrl()}get_supplier_ledger",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return SupplierLedgerResponse.fromJson(response.data);
      }
    } catch (e) {
      log("SupplierLedgerResponse error: $e");
    }
    return null;
  }

  static Future<CheckBarcodeDuplicateModel?> checkBarcodeDuplicate(
    String barCode,
    String productId,
  ) async {
    final token = await Common.getSharedPref("token");

    final data = {
      'token': token,
      'bar_code': barCode,
      'product_id': productId,
    };

    try {
      final response = await _dio.post(
        "${await Config.getUrl()}checkBarcodeDuplicate",
        data: FormData.fromMap(data),
      );

      print("TYPE = ${response.data.runtimeType}");
      print("DATA = ${response.data}");

      if (response.statusCode == 200) {
        if (response.data is String) {
          return checkBarcodeDuplicateModelFromJson(response.data);
        }

        return CheckBarcodeDuplicateModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }
    } catch (e) {
      log("checkBarcodeDuplicate error: $e");
    }

    return null;
  }
static Future<Map<String, dynamic>?> approveRejectStockRequest(
  String requestId,
  String status,
) async {
  final token = await Common.getSharedPref("token");

  final data = {
    'token': token,
    'request_id': requestId,
    'request_status': status == "Approved" ? 1 : 3,
  };

  try {
    final response = await _dio.post(
      "${await Config.getUrl()}approve_reject_stock_request",
      data: FormData.fromMap(data),
    );

    if (response.statusCode == 200 &&
        response.data['status'] == true) {
      return response.data['data'];
    }
  } catch (e) {
    log("approveRejectStockRequest error: $e");
  }

  return null;
}
static Future<LeadModuleModel?> getLeadModules(String callMasterId) async {
  final token = await Common.getSharedPref("token");

  final data = {
    'token': token,
    'lead_id': callMasterId, // callMasterId goes here
  };

  try {
    final response = await _dio.post(
      "${await Config.getUrl()}get_lead_modules",
      data: FormData.fromMap(data),
    );

    if (response.statusCode == 200) {
      return LeadModuleModel.fromJson(response.data);
    }
  } catch (e) {
    log("getLeadModules Error: $e");
  }

  return null;
}
static Future<LeadWorkDetailsModel?> getLeadWorkDetails(
    String callMasterId) async {
  try {
    final token = await Common.getSharedPref("token");

    print("lead_id = $callMasterId");

    final response = await _dio.post(
      "${await Config.getUrl()}getLeadWorkDetails",
      data: FormData.fromMap({
        "token": token,
        "lead_id": callMasterId,
      }),
    );

    print("Response = ${response.data}");

    if (response.statusCode == 200) {
      return LeadWorkDetailsModel.fromJson(response.data);
    }
  } catch (e) {
    print(e);
  }

  return null;
}
}
