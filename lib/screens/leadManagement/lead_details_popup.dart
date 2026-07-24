import 'dart:developer';
import 'dart:io';
import 'package:call_e_log/call_log.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/models/callLogUploadPermissionModel.dart';
import 'package:login2/models/callLogs/callLogUploadModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/deleteLeadModel.dart';
import 'package:login2/models/lead_management/leadTransferModel.dart';
import 'package:login2/models/lead_management/uploadAudioRecoed.dart';
import 'package:login2/models/lead_management/leadExtraSettings.dart';
import 'package:login2/models/lead_management/lead_work_details_model.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart' as af;
import 'package:login2/models/lead_management/callResultResonModel.dart' as cr;
import 'package:login2/models/lead_management/leadSubTypeModel.dart' as lst;
import 'package:login2/models/renewal/renewal_details.dart' as rn;
import 'package:login2/screens/leadManagement/add_leads_new.dart';
import 'package:login2/screens/leadManagement/audio_controller.dart';
import 'package:login2/screens/leadManagement/editLeadNew.dart';
import 'package:login2/screens/leadManagement/imageUploadController.dart';
import 'package:login2/service/service.dart';
import '../../core/common.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/leadDetailsModelAdd.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import '../../models/lead_management/leadMileStoneListModel.dart';
import '../../models/lead_management/listFolderName.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/showTransferHideorShowModel.dart';

import 'package:login2/models/lead_management/get_chat_id.dart';
import 'package:login2/models/lead_management/activityModel.dart';
import 'package:login2/models/lead_management/callDataModel.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import '../../models/lead_management/leadProductsModel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'add_followup.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:login2/models/lead_management/deleteLeadFollowupModel.dart';
import 'playWidget.dart';
import '../customer/customerDasboard.dart';
import 'editFollowup.dart';
import '../../models/lead_management/fileManagerPermissionModel.dart';
import 'docViewWebView.dart';
import 'package:login2/models/lead_management/updateReminderSetings.dart';
import 'package:login2/models/lead_management/unsetReminderModel.dart';
import 'package:path/path.dart' as p;
import 'package:login2/screens/authentication/googleDriveAccountsModel.dart';
import 'package:login2/screens/authentication/googleDriveFilesModel.dart';
import 'package:login2/models/lead_management/deleteGoogleDriveFileModel.dart';
import 'package:login2/models/lead_management/renameGdriveApiModel.dart';
import 'package:login2/screens/leadManagement/assignwork_lead.dart';
class LeadDetailsPopup extends StatefulWidget {
  final String token;
  final bool editLead;
  final bool deleteLead;
  final bool cloudCall;
  final String callMasterId;
  final LeadDeatailsModel leadDetails;
  final LeadDeatailsModelAdd? leadDetailsAdditional;
  final ListFolderNameModel? listFolder;
  final LeadMileStoneListModel? mileStone;
  final af.LeadFollowupData? leadDetailsFollowup;
  final AddLeadCommonDataModel? commonDetails;
  final String pageName;
  final String? status;
  final String? staff;
  final bool? isCalled;
  final String? fromDate;
  final String? toDate;
  final String? category;
  final String? leadType;
  final VoidCallback onDataChanged;
  final bool autoExpandFollowup;

  const LeadDetailsPopup({
    Key? key,
    required this.token,
    required this.editLead,
    required this.deleteLead,
    required this.cloudCall,
    required this.callMasterId,
    required this.leadDetails,
    this.leadDetailsAdditional,
    this.listFolder,
    this.mileStone,
    this.leadDetailsFollowup,
    this.commonDetails,
    required this.pageName,
    this.status,
    this.staff,
    this.isCalled,
    this.fromDate,
    this.toDate,
    this.category,
    this.leadType,
    required this.onDataChanged,
    this.autoExpandFollowup = false,
  }) : super(key: key);

  @override
  State<LeadDetailsPopup> createState() => _LeadDetailsPopupState();
}

class _LeadDetailsPopupState extends State<LeadDetailsPopup>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late TabController _tabController;
  final List<Color> _colors = [
    const Color(0xFF2196F3), // Vibrant Blue (index 0)
    const Color(0xFF2196F3), // Blue at index 1 for "New"
    const Color(0xFFFFC107), // Amber/Yellow for Followup (index 2)
    const Color.fromARGB(
        255, 255, 36, 7), // Amber/Yellow at index 3 for Followup
    const Color(0xFF4CAF50), // Green 500 (index 4) - Standardized for Closed
    const Color(0xFFF44336), // Red 500 (index 5) - Standardized for Rejected
    const Color(0xFF9C27B0), // Purple 500 (index 6)
    const Color(0xFF2a84c9), // Primary Blue (index 7)
    const Color(0xFF009688), // Teal (index 8)
    const Color(0xFFFF6F00), // Amber 900 (index 9)
    const Color(0xFFD32F2F), // Red 700 (index 10)
    const Color(0xFF1B5E20), // Green 900 (index 11)
    const Color(0xFF0D47A1), // Blue 900 (index 12)
    const Color(0xFF3F51B5), // Indigo (index 13)
  ];

  String? contactPermission;
  String? transferPermission;
  String? cloudCallPermission;
  String? createRenewalPermission;
  String? customerAddInvoicePermission;
  String? createCustomerInvoice;
  String? voiceListerningPermission;
  String? whatsappOfficial;
  String? name;
  String? userId;
  String? phoneCallLogPermission;
  String? accessCallRecordingPermission;
  String? callMasterId;
  LeadDeatailsModel? leadDetails;
  LeadDeatailsModelAdd? leadDetailsAdditional;
  FileManagerPermissionModel? fileManagerPermission;
  ListFolderNameModel? listFolder;
  LeadMileStoneListModel? mileStone;
  af.LeadFollowupData? leadDetailsFollowup;
  AddLeadCommonDataModel? commonDetails;
  ActivityMode? activeMode;
  CallHistoryResponse? callDetailsDataS;
  bool isActivityLoading = false;
  bool showTransferFreshValue = false;
  bool isCallHistoryLoading = false;
  String viewLeadCategoryOnly = '';
  String viewAllCategory = '';
  TextEditingController contactFName = TextEditingController();
  TextEditingController contactLName = TextEditingController();
  TextEditingController contactMobile = TextEditingController();
  TextEditingController transferRemark = TextEditingController();
  TextEditingController folderName = TextEditingController();
  TextEditingController fileName = TextEditingController();
  TextEditingController fileNameEdit = TextEditingController();
  final TextEditingController expectedClosingDate = TextEditingController();
LeadWorkDetailsModel? workDetails;
bool isLoadingWorkDetails = false;
  final AudioRecordController audioCreateController =
      Get.put(AudioRecordController());
  final ImageUploadController imageUploadController =
      Get.put(ImageUploadController());

  bool isPlay = false;
  bool isBack = false;
  bool isExpanded = false;
  bool isFile = false;
  bool folderActionEnable = false;
  String path = '';
  String listPath = '';
  String backPath = '';
  String listPathAudio = '';
  String deletePath = '';
  String rawId = '';
  String selectedRawIndex = '';
  String editableName = '';
  bool checked = false;
  PlatformFile? file;
  List checkedItems = [];
  List checkedItemsName = [];
  String selectedDocumentType = 'none'; // none, s3, drive
  String drivePath = '';

  // Followup form variables
  String callResultId = '2';
  String callResult = 'Followup';
  String callResponseId = '';
  String callResponse = 'Call Response';
  String leadTypeId = '';
  String leadType = 'Lead Category';
  String leadSubTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String priorityId = '2';
  String priority = 'Normal';
  String callResultReasonName = 'Tags';
  String callResultReasonId = '';
  String templateId = "";
  String invoiceNumber = '';
  String typeDuration = "";
  String? createLeadCategory = '';
  String? addLeadSource = '';

  TextEditingController calledDate1 = TextEditingController();
  TextEditingController nextFollowupDate1 = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController callResultVal = TextEditingController();
  TextEditingController callResponseVal = TextEditingController();
  TextEditingController leadTypeVal = TextEditingController();
  TextEditingController leadSubTypeVal = TextEditingController();
  TextEditingController priorityVal = TextEditingController();
  TextEditingController callReasonVal = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController timeBefore = TextEditingController(text: "10");
  TextEditingController renewalRemarks = TextEditingController();
  TextEditingController whatsappLead = TextEditingController();
  TextEditingController emailLead = TextEditingController();

  TextEditingController productDescription = TextEditingController();
  TextEditingController productRate = TextEditingController();
  TextEditingController productQty = TextEditingController(text: "1");
  TextEditingController productTaxPercent = TextEditingController();
  TextEditingController productTaxAmount = TextEditingController();
  TextEditingController productTotalAmount = TextEditingController();
  TextEditingController productTotalAmountTotal = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController shippingCharge = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController reminderTemplate = TextEditingController();
  TextEditingController renProductRate = TextEditingController();
  TextEditingController renProductQty = TextEditingController(text: "1");
  TextEditingController renProductTaxPercent = TextEditingController();
  TextEditingController renProductTaxAmount = TextEditingController();
  TextEditingController renProductTotalAmount = TextEditingController();

  bool isSavingFollowup = false;
  bool isCreatingOrder = false;
  bool isCreatingRenewal = false;
  bool showReminders = false;
  bool createOrder = false;
  bool createRenewal = false;
  bool createCustomer = false;
  LeadSettings? leadSettings;
  bool isLoadingSettings = false;
  bool isDifrent = false;
  bool isMoreDetails = false;
  bool timeOut = false;
  bool result = true;
  bool isChecked = false;
  bool isExpand = false;
  bool isCreatingOrderOnly = false;
  String? creatingOrderFollowupId;

  bool refresh = false;
  String? permissionAccess = '';
  String? uploadPermission = '';
  String roleId = "";
  bool deleteAccess = false;
  int from =
      DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
  CallLogUploadPermissionModel? callUploadPermission;
  List<HiveCaallHistoryModel> fullHiveData = [];
  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];

  double totalRenAmount = 0;
  String totalProdAmount = "";

bool get _showAssignWorkButton {
  final currentCallResultId =
      leadDetails?.data?.callResultId?.toString() ?? callResultId;

  return currentCallResultId == "7" ||
      currentCallResultId == "8" ||
      currentCallResultId == "10";
}

  LeadProductSectionModel? productSectionModel;
  List<LeadProduct> _selectedProducts = [];
  String? _expandedProductId;
  final Map<String, String> _productDescriptions = {};
  final Map<String, bool> _descriptionLoading = {};

  Future<void> _fetchProductDescription(String productId) async {
    if (_productDescriptions.containsKey(productId)) return;
    setState(() => _descriptionLoading[productId] = true);
    try {
      final response = await HttpService.productDescription(productId);
      if (mounted) {
        setState(() {
          _descriptionLoading[productId] = false;
          if (response != null && response.status == true) {
            _productDescriptions[productId] = response.data;
          } else {
            _productDescriptions[productId] = "";
          }
        });
      }
    } catch (e) {
      log("Error fetching product description: $e");
      if (mounted) {
        setState(() {
          _descriptionLoading[productId] = false;
          _productDescriptions[productId] = "Failed to load description.";
        });
      }
    }
  }

  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];

  void _showProductPopup() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (productSectionModel == null ||
        productSectionModel!.data == null ||
        productSectionModel!.data!.isEmpty) {
      Common.toastMessaage('No Products found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(productSectionModel!.data!);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select Products'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = productSectionModel!.data!
                          .where((p) => (p.productName ?? "")
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        bool isSelected =
                            _selectedProducts.any((item) => item.id == p.id);
                        return ListTile(
                          title: Text(p.productName ?? ''),
                          subtitle: Text("Rs ${p.totalAmount}"),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                          onTap: () {
                            if (isSelected) {
                              _removeFollowupProduct(p);
                            } else {
                              _addFollowupProduct(p);
                            }
                            setDialogState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('DONE'),
              ),
            ],
          );
        });
      },
    );
  }

  List<DriveAccount> googleDriveAccounts = [];
  DriveAccount? selectedDriveAccount;
  bool isDriveAccountsLoading = false;
  List<GoogleDriveFile> googleDriveFiles = [];
  bool isDriveFilesLoading = false;
  String? selectedFolderId;
  String? currentFolderName;
  List<Map<String, String>> driveBreadcrumbs = [
    {'id': 'root', 'name': 'Drive'}
  ];
  bool isUploading = false;

  static const Color appBarStart = Color(0xFF2a86c9);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  rn.RenewalDetailslModel? detailsResponse;
  cr.CallResultResonModel? callResultReason;
  lst.LeadSubTypeModel? leadSubTypeList;
  List<rn.Template> filteredTemplates = [];
  List<rn.Product> productsList = [];
  List<rn.Product> filteredProducts = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> renProducts = [];
  List<ColloctedStaff> filteredStaffList = [];
  List<TargetGroup> filteredTargetsList = [];
  List targetGroups = [];
  List targetGroupNames = [];

  double subTotal = 0.00;
  double subTotalGrand = 0.00;
  double totalTaxAmount = 0.00;
  double allTotal = 0.00;
  dynamic paymentMethod;
  dynamic paymentStatus;
  String productId = "";
  String renProductId = "";
  String staffId = "";
  String staffName = "Choose Staff";
  String productName = "Choose Product";
  String renProductName = "";
  var invoiceDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    isExpand = widget.autoExpandFollowup;
    _initializeData();

    _tabController = TabController(length: _getTabCount(), vsync: this);
    _tabController.addListener(() {
  setState(() {
    selectedIndex = _tabController.index;
  });

  final labels = _getTabLabels();

  if (_tabController.index < labels.length &&
      labels[_tabController.index] == "Work Details" &&
      workDetails == null &&
      !isLoadingWorkDetails) {
    _loadWorkDetails();
  }
});
    _loadUserPreferences();
    if (leadDetails != null) {
      contactFName.text = leadDetails!.data!.clientName ?? '';
      contactMobile.text = '+${leadDetails!.data!.contactNumber1 ?? ''}';

      // Initialize followup form defaults
      calledDate1.text =
          DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
      cost.text = leadDetails!.data!.cost ?? '';
      address.text = leadDetails!.data!.address ?? '';
      leadType = leadDetails!.data!.leadCategory ?? '';
      leadTypeId = leadDetails!.data!.leadCategoryId ?? '';
      leadSubType = leadDetails!.data!.leadSubCategory ?? '';
      leadSubTypeId = leadDetails!.data!.leadSubCategoryId ?? '';
      priority = leadDetails!.data!.priority ?? '';
      priorityId = leadDetails!.data!.priorityId ?? '';
    }
  }

  int _getTabCount() {
    int count = 5; // Followup, Activities, Details, Documents
    if (widget.leadDetails.data?.callHistoryPermission == true) count++;
    if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false) count++;
    return count;
  }
bool get _showFollowupButton {
  final callResultId =
      widget.leadDetails.data?.callResultId?.toString();

  return callResultId == "7" ||
      callResultId == "8" ||
      callResultId == "10";
}
  // List<String> _getTabLabels() {
  //   List<String> labels = ['Followup', 'Activities', 'Details', 'File Manager','Work Details'];
  //   if (widget.leadDetails.data?.callHistoryPermission == true) {
  //     labels.insert(1, 'Call Logs');
  //   }
  //   if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false) {
  //     labels.add('Milestones');
  //   }
  //   return labels;
  // }
List<String> _getTabLabels() {
  List<String> labels = [
    'Followup',
    'Activities',
    'Details',
    'File Manager',
    'Work Details',
  ];

  if (widget.leadDetails.data?.callHistoryPermission == true) {
    labels.insert(1, 'Call Logs');
  }

  if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false) {
    labels.add('Milestones');
  }

  return labels;
}
  Future<void> _initializeData() async {
    contactPermission = await Common.getSharedPref("getContactPermission");
    transferPermission = await Common.getSharedPref("transferLeads");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    createRenewalPermission =
        await Common.getSharedPref("createRenewalPermission");
    customerAddInvoicePermission =
        await Common.getSharedPref("customerAddInvoicePermission");
    createCustomerInvoice = await Common.getSharedPref("createCustomerInvoice");
    voiceListerningPermission =
        await Common.getSharedPref("voiceListerningPermission");
    whatsappOfficial = await Common.getSharedPref("officialWhatsapp");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");
     viewLeadCategoryOnly =
        await Common.getSharedPref("viewLeadCategoryOnly") ?? '';
    viewAllCategory = await Common.getSharedPref("viewAllCategory") ?? '';
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    accessCallRecordingPermission =
        await Common.getSharedPref("accessCallRecordingPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    addLeadSource = await Common.getSharedPref("addLeadSource");

    setState(() {
      callMasterId = widget.callMasterId;
      leadDetails = widget.leadDetails;
      leadDetailsAdditional = widget.leadDetailsAdditional;
      listFolder = widget.listFolder;
      mileStone = widget.mileStone;
      leadDetailsFollowup = widget.leadDetailsFollowup;
      commonDetails = widget.commonDetails;
      if (commonDetails == null) {
        _fetchCommonDetails();
      } else {
        _initializeAdditionalFields();
      }

      if (leadDetails != null) {
        final data = leadDetails!.data!;
        contactFName.text = data.clientName ?? '';
        contactMobile.text = data.contactNumber1 ?? '';
        address.text = data.address ?? '';
        cost.text = data.cost ?? '';
        leadTypeId = data.leadCategoryId ?? '';
        leadType = data.leadCategory ?? 'Lead Category';
        leadSubTypeId = data.leadSubCategoryId ?? '';
        leadSubType = data.leadSubCategory ?? 'Lead Sub Category';
        priorityId = data.priorityId ?? '2';
        priority = data.priority ?? 'Normal';
        whatsappLead.text = data.whatsaAppNumber ?? '';
        emailLead.text = data.emailId ?? '';

        // Initialize followup date
        calledDate1.text =
            DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
      }
    });

    _fetchRenewalDetails();
    _fetchCallResultReason();
    _fetchLeadSubType();
    _fetchActivitiesAndCallHistory();
    _fetchProductSection();
    listFolderList(widget.token, widget.callMasterId, '');
    _fetchGoogleDriveAccounts();

    if (Platform.isAndroid) {
      getSharedData();
      getPermission();
    }
  }

  getPermission() async {
    Map<String, dynamic> body2 = {
      "token": await Common.getSharedPref("token"),
    };
    callUploadPermission = await HttpService.callLogUploadPermission(body2);
    if (callUploadPermission != null) {
      setState(() {});
    }
  }

  getSharedData() async {
    log('getSharedData called');
    try {
      refresh = true;
      permissionAccess = await Common.getSharedPref("callLogPermission");
      final isAllowed = permissionAccess == 'true';
      debugPrint("callLogPermission now: $isAllowed");
      uploadPermission = await Common.getSharedPref("uploadCallLog");

      String? deleteAccessStr =
          await Common.getSharedPref("accessCallHistoryPermission");
      roleId = await Common.getSharedPref("roleId") ?? "";

      contactPermission = await Common.getSharedPref("getContactPermission");
      transferPermission = await Common.getSharedPref("transferLeads");
      cloudCallPermission = await Common.getSharedPref("cloudCallPermission") ?? "";
      whatsappOfficial = await Common.getSharedPref("officialWhatsapp") ?? "";

      if (uploadPermission != "true" && Platform.isIOS) {
        selectedIndex = -1;
      }
      setState(() {
        deleteAccess = deleteAccessStr == "true";
      });
      if (permissionAccess == 'true') {
        if (await Permission.phone.request().isGranted) {
          final List<CallLogToggleEvent> toggleHistory =
              await ToggleStorage.getToggleHistory();
          int to = DateTime.now().millisecondsSinceEpoch;

          final Iterable<CallLogEntry> result = await CallLog.query(
            dateFrom: from,
            dateTo: to,
          );
          final filteredLogs = result.where((entry) {
            return isLogAllowed(
                entry.timestamp ?? 0, entry.callType!, toggleHistory);
          }).toList();

          final List<HiveCaallHistoryModel> hiveData =
              await HiveUtil.getAllCallLogs();
          log('hiveData 1: $hiveData');
          log('hiveData 0: ${hiveData.length}');
          log('================================== HIVE DATA IN GET SHARED DATA ========================================');
          log('hiveData LENGTH 1 : ${hiveData.length}');
          for (var datassss in hiveData) {
            log('hiveData LENGTH 2 : ${datassss.name} || ${datassss.phoneNumber} || ${datassss.isUploaded}');
          }

          setState(() {
            fullHiveData = hiveData;
            _callLogEntries = filteredLogs;
            refresh = false;
          });
        }
      }
      // !   UPDATE MISSING CALL LOG
      final int callLogCount = await HiveUtil.getCallLogCount();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<HiveCaallHistoryModel> callLogData = <HiveCaallHistoryModel>[];
      callLogData.clear();
      final String dateTimeFrom =
          prefs.getString('callLogsStartingTime').toString();
      if (callLogCount == 0) {
        log('No call logs found in Hive.');
        final DateTime startingTime = DateTime.parse(dateTimeFrom);
        int to = DateTime.now().millisecondsSinceEpoch;
        final Iterable<CallLogEntry> result = await CallLog.query(
          dateFrom: from,
          dateTo: to,
        );
        final List<CallLogEntry> filteredLogs = result.where((entry) {
          final DateTime callTime =
              DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
          return callTime.isAfter(startingTime);
        }).toList();
        log('filteredLogs : ${filteredLogs.length}');
        if (filteredLogs.isNotEmpty) {
          List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
          log('callTypes : $callTypesQ');
          List<HiveCaallHistoryModel> listOfCallLogNeedToAddHive = [];
          for (var callLog in filteredLogs) {
            bool isAllowed = false;

            if (callTypesQ.contains('Incoming') &&
                callLog.callType.toString().contains('incoming')) {
              isAllowed = true;
            } else if (callTypesQ.contains('Outgoing') &&
                callLog.callType.toString().contains('outgoing')) {
              isAllowed = true;
            } else if (callTypesQ.contains('Incoming') &&
                callLog.callType.toString().contains('missed')) {
              isAllowed = true;
            }
            log('isAllowed : $isAllowed');
            HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                id: callLog.timestamp.toString(),
                name: callLog.name.toString(),
                phoneNumber: callLog.number.toString(),
                callType: callLog.callType
                    .toString()
                    .substring(callLog.callType.toString().indexOf('.') + 1),
                duration: callLog.duration.toString(),
                timeStamp: callLog.timestamp!.toString(),
                simSlot: callLog.simDisplayName ?? "NIL",
                callRecordFilePath: "",
                isUploaded: false,
                isDeleted: false,
                isEnabled: isAllowed);
            listOfCallLogNeedToAddHive.add(hiveCallLog);
          }

          log('listOfCallLogNeedToAddHive : $listOfCallLogNeedToAddHive');
          log('listOfCallLogNeedToAddHive : ${listOfCallLogNeedToAddHive.length}');
          List<HiveCaallHistoryModel> allowedCallLogs =
              listOfCallLogNeedToAddHive
                  .where((log) => log.isEnabled == true)
                  .toList();

          log('allowedCallLogs (for upload): ${allowedCallLogs.length}');

          if (allowedCallLogs.isNotEmpty) {
            await uploadMissingLogsToServer(allowedCallLogs);
          }

          if (listOfCallLogNeedToAddHive.isNotEmpty) {
            await HiveUtil.addCallLogs(listOfCallLogNeedToAddHive);
          }
          await loadHiveData();
          return;
        } else {
          log('No call logs found');
          return;
        }
      } else {
        log('call logs found in Hive.');

        callLogData.clear();
        final String dateTimeFrom =
            prefs.getString('callLogsStartingTime').toString();
        final DateTime startingTime = DateTime.parse(dateTimeFrom);

        int to = DateTime.now().millisecondsSinceEpoch;
        final Iterable<CallLogEntry> result = await CallLog.query(
          dateFrom: from,
          dateTo: to,
        );
        final List<CallLogEntry> callLogsFromDevice = result.where((entry) {
          final DateTime callTime =
              DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
          return callTime.isAfter(startingTime);
        }).toList();
        log('Call logs from device : $callLogsFromDevice');
        log('Call logs from length : ${callLogsFromDevice.length}');
        if (callLogsFromDevice.isEmpty) {
          log('no call logs in device');
          return;
        }

        final deviceLatestCallLogTime =
            parseCallLogTime(callLogsFromDevice.first.timestamp.toString());

        final List<HiveCaallHistoryModel> hiveData =
            await HiveUtil.getAllCallLogs();

        final HiveCaallHistoryModel latestHiveCallLog2 =
            await HiveUtil.getLatestCallLogByTime() ?? hiveData.first;
        log('latestHiveCallLog2 : ${latestHiveCallLog2.name} || ${latestHiveCallLog2.phoneNumber} || ${latestHiveCallLog2.isUploaded} || ${latestHiveCallLog2.isEnabled}');

        final hiveLatestDateTime =
            parseCallLogTime(latestHiveCallLog2.timeStamp);

        if (hiveLatestDateTime == deviceLatestCallLogTime) {
          log('Latest Hive Call Log and Device Call Log are same.');
          log('first call log : ${latestHiveCallLog2.isUploaded}');
          return;
        } else {
          log('Latest Hive Call Log and Device Call Log are not same.');
          final DateTime startingTime = DateTime.parse(dateTimeFrom);
          final Iterable<CallLogEntry> result = await CallLog.query(
            dateFrom: from,
            dateTo: to,
          );
          log('result : ${result.length}');
          final List<CallLogEntry> allCallLogsAfterHiveLatestData =
              result.where((entry) {
            final DateTime callTime =
                DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
            return callTime.isAfter(startingTime);
          }).toList();
          log('Call logs from device after latest hive data : $allCallLogsAfterHiveLatestData');
          log('Call logs from length after latest hive data : ${allCallLogsAfterHiveLatestData.length}');
          callLogData.clear();

          if (allCallLogsAfterHiveLatestData.isNotEmpty) {
            List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
            log('callTypes : $callTypesQ');

            for (var callLog in allCallLogsAfterHiveLatestData) {
              bool isAllowed = false;

              if (callTypesQ.contains('Incoming') &&
                  callLog.callType.toString().contains('incoming')) {
                isAllowed = true;
              } else if (callTypesQ.contains('Outgoing') &&
                  callLog.callType.toString().contains('outgoing')) {
                isAllowed = true;
              } else if (callTypesQ.contains('Incoming') &&
                  callLog.callType.toString().contains('missed')) {
                isAllowed = true;
              }

              log('isAllowed : $isAllowed');
              HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                id: callLog.timestamp.toString(),
                name: callLog.name.toString(),
                phoneNumber: callLog.number.toString(),
                callType: callLog.callType
                    .toString()
                    .substring(callLog.callType.toString().indexOf('.') + 1),
                duration: callLog.duration.toString(),
                timeStamp: callLog.timestamp!.toString(),
                simSlot: callLog.simDisplayName ?? "NIL",
                callRecordFilePath: "",
                isUploaded: false,
                isDeleted: false,
                isEnabled: isAllowed,
              );
              callLogData.add(hiveCallLog);
            }

            log('callLogData : $callLogData');
            log('callLogData : ${callLogData.length}');
            final List<HiveCaallHistoryModel> hiveData =
                await HiveUtil.getAllCallLogs();
            log('hiveData 1: $hiveData');
            log('hiveData 0: ${hiveData.length}');

            Map<String, bool> existingItems = {};

            for (var item in hiveData) {
              String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
              existingItems[uniqueKey] = true;
            }

            log('existingItems: $existingItems');
            log('existingItems length: ${existingItems.length}');

            List<HiveCaallHistoryModel> nonDuplicates = [];

            for (var item in callLogData) {
              String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
              if (!existingItems.containsKey(uniqueKey)) {
                log('Unique item found: ${item.phoneNumber} - ${item.timeStamp}');
                nonDuplicates.add(item);
              } else {
                log('Duplicate item found: ${item.phoneNumber} - ${item.timeStamp}');
              }
            }

            log('nonDuplicates: $nonDuplicates');
            log('nonDuplicates length: ${nonDuplicates.length}');

            nonDuplicates =
                nonDuplicates.where((log) => log.isDeleted != true).toList();
            nonDuplicates =
                nonDuplicates.where((log) => log.isUploaded != true).toList();
            nonDuplicates = nonDuplicates.reversed.toList();

            log('callLogData        : $callLogData');
            log('callLogData length : ${callLogData.length}');

            List<HiveCaallHistoryModel> allowedCallLogs =
                nonDuplicates.where((log) => log.isEnabled == true).toList();

            log('allowedCallLogs (for upload): ${allowedCallLogs.length}');

            if (allowedCallLogs.isNotEmpty) {
              await uploadMissingLogsToServer(allowedCallLogs);
            }

            if (nonDuplicates.isNotEmpty) {
              await HiveUtil.addCallLogs(nonDuplicates);
            }

            await loadHiveData();
            return;
          } else {
            log('No NEW Call Logs found in device.');
          }
        }
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        setState(() {
          refresh = false;
        });
      }
    }
  }

  Future<void> uploadMissingLogsToServer(
      List<HiveCaallHistoryModel> callLogData) async {
    log("uploadMissingLogsToServer function called");

    List<Map<String, dynamic>> missingLogs = callLogData
        .map((log) => {
              "name": log.name,
              "phone_number": log.phoneNumber,
              "callTypes": log.callType
                  .toString()
                  .substring(log.callType.toString().indexOf('.') + 1),
              "time":
                  DateTime.fromMillisecondsSinceEpoch(int.parse(log.timeStamp))
                      .toString(),
              "duration": log.duration,
              "simName": log.simSlot ?? "NIL",
              "timeStamp": log.timeStamp,
            })
        .toList();

    log("⚠️ Found ${missingLogs.length} missing logs.");

    if (missingLogs.isNotEmpty) {
      log('~~ OUTGOING CALL missingLogs : $missingLogs ~~~');
      log('~~ OUTGOING CALL length : ${missingLogs.length} ~~~');

      Map<String, dynamic> body = {
        "token": await Common.getSharedPref("token"),
        'log': missingLogs,
      };
      log('~~ OUTGOING CALL BODY : $body ~~~');

      CallLogUploadModel object1 = await HttpService.callLogUpload(body);
      log('~~ OUTGOING CALL missingLogs object : ${object1.data} ~~~');
      if (object1.data == true) {
        log('~~ OUTGOING CALL success ~~~');
      } else {
        log('~~ OUTGOING CALL failure ~~~');
      }
    }
  }

  Future<void> loadHiveData() async {
    fullHiveData.clear();
    final List<HiveCaallHistoryModel> hiveData =
        await HiveUtil.getAllCallLogs();
    log('hiveData LENGTH MAIN: ${hiveData.length}');
    for (var entry in hiveData) {
      log('Entry 1 MAIN : ${entry.name} || ${entry.phoneNumber} || ${entry.isUploaded} || ${entry.timeStamp}');
    }

    setState(() {
      fullHiveData = hiveData;
      refresh = false;
    });
  }

  Future<void> _fetchCommonDetails() async {
    try {
      final response = await HttpService.addLeadCommonData(widget.token);
      if (response != null && mounted) {
        setState(() {
          commonDetails = response;
        });
        _initializeAdditionalFields();
      }
    } catch (e) {
      log("Error fetching common details: $e");
    }
  }

  listFolderList(token, callMasterId, pathValue) async {
    listFolder =
        await HttpService.listFolderAndFiles(token, callMasterId, pathValue);
    if (listFolder != null) {
      fileManagerPermissionFunction(widget.token);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _initializeAdditionalFields() {
    if (commonDetails?.data.additionalFields != null) {
      if (_additionalCtrls.length !=
          commonDetails!.data.additionalFields.length) {
        _additionalCtrls.clear();
        for (int i = 0; i < commonDetails!.data.additionalFields.length; i++) {
          final commonField = commonDetails!.data.additionalFields[i];
          String existingValue = "";

          if (leadDetailsAdditional?.data.additionalFields != null) {
            for (var f in leadDetailsAdditional!.data.additionalFields) {
              if (f.id == commonField.id) {
                existingValue = f.value;
                break;
              }
            }
          }

          _additionalCtrls.add(TextEditingController(text: existingValue));
        }
      }
    }
  }

  List<Widget> _buildAdditionalFieldsUI() {
    if (commonDetails == null ||
        commonDetails!.data.additionalFields.isEmpty ||
        _additionalCtrls.length < commonDetails!.data.additionalFields.length) {
      return [];
    }
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: _additionalCtrls[i],
          decoration: InputDecoration(
            labelText: commonDetails!.data.additionalFields[i].fieldName,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      );
    });
  }

  fileManagerPermissionFunction(token) async {
    fileManagerPermission = await HttpService.fileManagerPermission(token);
    if (fileManagerPermission != null) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _fetchProductSection() async {
    final res = await HttpService.leadProductSection();
    if (res != null && mounted) {
      setState(() {
        productSectionModel = res;
        if (leadDetails?.data?.productsOnAdd != null &&
            leadDetails!.data!.productsOnAdd!.isNotEmpty) {
          List<String> ids = leadDetails!.data!.productsOnAdd!.split(',');
          _selectedProducts =
              res.data?.where((p) => ids.contains(p.id.toString())).toList() ??
                  [];
        }
      });
    }
  }

  Future<void> _fetchActivitiesAndCallHistory() async {
    if (widget.leadDetails.data?.callHistoryPermission == true) {
      _fetchCallHistory();
    }
    _fetchActivities();
  }

  Future<void> _fetchCallHistory() async {
    if (!mounted) return;
    setState(() => isCallHistoryLoading = true);
    try {
      final response =
          await HttpService.callDetailsData(widget.token, callMasterId!);
      if (mounted) {
        setState(() {
          callDetailsDataS = response;
          isCallHistoryLoading = false;
        });
      }
    } catch (e) {
      log("Error fetching call history: $e");
      if (mounted) setState(() => isCallHistoryLoading = false);
    }
  }

  Future<void> _fetchActivities() async {
    if (!mounted) return;
    setState(() => isActivityLoading = true);
    try {
      final response =
          await HttpService.activityMode(widget.token, callMasterId!);
      if (mounted) {
        setState(() {
          activeMode = response?.data;
          isActivityLoading = false;
        });
      }
    } catch (e) {
      log("Error fetching activities: $e");
      if (mounted) setState(() => isActivityLoading = false);
    }
  }

  Future<void> _fetchRenewalDetails() async {
    try {
      final response = await HttpService.getRenewalDetails();
      if (response != null) {
        setState(() {
          detailsResponse = response;
          invoiceNumber = response.data.invoiceNumber.toString();
          productsList = response.data.products;
          filteredTemplates = response.data.template;
          filteredProducts.addAll(productsList);
        });
      }
    } catch (e) {
      log("Error fetching renewal details: $e");
    }
  }

  Future<void> _fetchLeadExtraSettings(String callResultId) async {
    setState(() {
      isLoadingSettings = true;
    });
    try {
      final response = await HttpService.leadExtraSettings(callResultId);
      if (mounted) {
        setState(() {
          isLoadingSettings = false;
          if (response != null && response.status == true) {
            leadSettings = response.data.settings;
          } else {
            leadSettings = null;
          }
        });
      }
    } catch (e) {
      log("Error fetching lead extra settings: $e");
      if (mounted) {
        setState(() {
          isLoadingSettings = false;
          leadSettings = null;
        });
      }
    }
  }

  Future<void> _fetchCallResultReason() async {
    if (callResultId.isNotEmpty) {
      try {
        final response =
            await HttpService.callResultReasonLiat(widget.token, callResultId);
        setState(() {
          callResultReason = response;
        });
      } catch (e) {
        log("Error fetching call result reasons: $e");
      }
    }
  }

  Future<void> _fetchLeadSubType() async {
    if (leadTypeId.isNotEmpty) {
      try {
        final response = await HttpService.leadSubType(leadTypeId);
        setState(() {
          leadSubTypeList = response;
        });
      } catch (e) {
        log("Error fetching lead sub types: $e");
      }
    }
  }

  Future<void> _loadUserPreferences() async {
    contactPermission = await Common.getSharedPref("saveContactPermission");
    transferPermission = await Common.getSharedPref("transferLeads");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    whatsappOfficial = await Common.getSharedPref("officialWhatsApp");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    accessCallRecordingPermission =
        await Common.getSharedPref("accessCallRecordingPermission");

    HttpService.showTransferHideOrShow().then((value) {
      if (value != null && value.status == true) {
        setState(() {
          showTransferFreshValue = value.data ?? false;
        });
      }
    });

    setState(() {});
  }

  Future<void> _fetchGoogleDriveAccounts() async {
    if (!mounted) return;
    setState(() => isDriveAccountsLoading = true);
    try {
      final response = await HttpService.getGoogleDriveAccounts();
      if (mounted && response != null && response.status) {
        setState(() {
          googleDriveAccounts = response.data;
          try {
            final defaultAccount = googleDriveAccounts.firstWhere(
              (account) => account.isActive == "1",
            );
            selectedDriveAccount = defaultAccount;
            drivePath = '@root';
            _fetchGoogleDriveFiles(defaultAccount.id);
          } catch (e) {
            if (googleDriveAccounts.isNotEmpty) {
              selectedDriveAccount = null;
            }
          }
          isDriveAccountsLoading = false;
        });
      } else {
        if (mounted) setState(() => isDriveAccountsLoading = false);
      }
    } catch (e) {
      log("Error fetching drive accounts: $e");
      if (mounted) setState(() => isDriveAccountsLoading = false);
    }
  }

  Future<void> _addDriveAccount() async {
    Common.showProgressDialog(context, "Generating connection link...");
    try {
      final res = await HttpService.addConnectGoogleAccountApi();
      if (mounted) Navigator.pop(context);
      if (res != null && res.status == true && res.authUrl != null) {
        final url = Uri.parse(res.authUrl!);
        //  if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        // } else {
        //   Common.toastMessaage("Could not launch Google Auth URL", Colors.red);
        // }
      } else {
        Common.toastMessaage(
            "Failed to get connection link. Please try again.", Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      log("Error in _addDriveAccount: $e");
      Common.toastMessaage("Error connecting account: $e", Colors.red);
    }
  }

  // Future<void> _fetchGoogleDriveFiles(String accountId,
  //     {String parentId = ""}) async {
  //   if (!mounted) return;
  //   setState(() {
  //     isDriveFilesLoading = true;
  //     googleDriveFiles = [];
  //   });
  //   try {
  //     final response = await HttpService.getGoogleDriveFiles(
  //         (callMasterId ?? widget.callMasterId), accountId, parentId);
  //     if (mounted && response != null && response.status) {
  //       setState(() {
  //         googleDriveFiles = response.data;
  //         isDriveFilesLoading = false;
  //       });
  //     } else {
  //       if (mounted) {
  //         setState(() {
  //           isDriveFilesLoading = false;
  //         });
  //         Common.toastMessaage(
  //             response?.message ?? "Failed to load Files", Colors.red);
  //       }
  //     }
  //   } catch (e) {
  //     log("Error fetching drive files: $e");
  //     if (mounted) setState(() => isDriveFilesLoading = false);
  //   }
  // }
Future<void> _fetchGoogleDriveFiles(
  String accountId, {
  String parentId = "",
}) async {
  if (!mounted) return;

  setState(() {
    isDriveFilesLoading = true;
    googleDriveFiles = [];
  });

  try {
    final leadId = callMasterId ?? widget.callMasterId;

    print("accountId = $accountId");
    print("parentId = $parentId");
    print("callMasterId = $leadId");

    final response = await HttpService.getGoogleDriveFiles(
      leadId,
      accountId,
      parentId,
    );

    print("Drive Response = $response");

    if (!mounted) return;

    if (response != null && response.status == true) {
      setState(() {
        googleDriveFiles = response.data;
        isDriveFilesLoading = false;
      });
    } else {
      setState(() {
        isDriveFilesLoading = false;
      });

      print("Drive API Error: ${response?.message}");

      Common.toastMessaage(
        response?.message ?? "Failed to load Files",
        Colors.red,
      );
    }
  } catch (e, s) {
    print("Error fetching drive files: $e");
    print(s);

    if (mounted) {
      setState(() {
        isDriveFilesLoading = false;
      });
    }
  }
}
Future<void> _loadWorkDetails() async {
  if (isLoadingWorkDetails) return;

  setState(() {
    isLoadingWorkDetails = true;
  });

  try {
    print("Loading Work Details...");
    print("Call Master ID = ${widget.callMasterId}");

    final response = await HttpService.getLeadWorkDetails(
  widget.callMasterId,
);

if (mounted) {
  setState(() {
    workDetails = response;
  });
}
    print("ASSIGN WORK RESULT = TRUE");
    if (mounted) {
      setState(() {
        workDetails = response;
      });
    }

    print(
      "Work Details Response Count = ${workDetails?.data.length}",
    );
  } catch (e) {
    print("Work Details Error: $e");
  } finally {
    if (mounted) {
      setState(() {
        isLoadingWorkDetails = false;
      });
    }
  }
}
  void _updateBreadcrumbs(String id, String name) {
    setState(() => driveBreadcrumbs.add({'id': id, 'name': name}));
  }

  void _popBreadcrumb() {
    if (driveBreadcrumbs.length > 1) {
      setState(() => driveBreadcrumbs.removeLast());
      final parent = driveBreadcrumbs.last;
      setState(() {
        selectedFolderId = parent['id'] == 'root' ? null : parent['id'];
        currentFolderName = parent['id'] == 'root' ? null : parent['name'];
      });
      _fetchGoogleDriveFiles(selectedDriveAccount!.id,
          parentId: selectedFolderId ?? "");
    } else {
      setState(() {
        selectedDriveAccount = null;
        selectedDocumentType = 'none';
      });
    }
  }

  void _viewGoogleDriveFile(GoogleDriveFile file) async {
    String extension = file.fileName.split('.').last.toLowerCase();
    String url = file.webContentLink;

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic']
        .contains(extension)) {
      // Use direct view link for Google Drive images to avoid auth prompts in WebView
      url =
          "https://drive.google.com/uc?export=view&id=${file.fileId ?? file.id}";
    }

    if (['m4a', 'wav', 'mp3'].contains(extension)) {
      _showAudioPlayerSimple(file.fileName, url);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentViewerScreen(
            documentUrl: url,
            title: file.fileName,
            extension: extension,
            fileSize: 'N/A',
            createdDate: file.uploadedAt,
            createdBy: 'Google Drive',
          ),
        ),
      );
    }
  }

  void _showAudioPlayerSimple(String name, String url) {
    final player = AudioPlayer();
    Duration duration = Duration.zero;
    Duration position = Duration.zero;
    bool isPlaying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          player.onDurationChanged.listen((d) {
            if (ctx.mounted) setSheetState(() => duration = d);
          });
          player.onPositionChanged.listen((p) {
            if (ctx.mounted) setSheetState(() => position = p);
          });
          player.onPlayerStateChanged.listen((s) {
            if (ctx.mounted)
              setSheetState(() => isPlaying = s == PlayerState.playing);
          });

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 32),
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble() > 0
                      ? duration.inSeconds.toDouble()
                      : 1,
                  value: position.inSeconds.toDouble().clamp(
                      0,
                      duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1),
                  activeColor: const Color(0xFF2a86c9),
                  onChanged: (v) => player.seek(Duration(seconds: v.toInt())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      Text(_formatDuration(duration),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _audioActionIcon(
                        Icons.replay_10_rounded,
                        () => player
                            .seek(position - const Duration(seconds: 10))),
                    const SizedBox(width: 32),
                    GestureDetector(
                      onTap: () => isPlaying
                          ? player.pause()
                          : player.play(UrlSource(url)),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                            color: Color(0xFF2a86c9), shape: BoxShape.circle),
                        child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40),
                      ),
                    ),
                    const SizedBox(width: 32),
                    _audioActionIcon(
                        Icons.forward_10_rounded,
                        () => player
                            .seek(position + const Duration(seconds: 10))),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    ).then((_) => player.dispose());
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}";
  }

  Widget _audioActionIcon(IconData icon, VoidCallback onTap) => IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.grey.shade700, size: 32));

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Lead summary card
              SliverToBoxAdapter(child: _buildLeadSummaryCard()),

              // Pinned Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF2a86c9),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2a86c9).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelColor: Colors.grey.shade600,
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        tabAlignment: TabAlignment.start,
                        tabs: _getTabLabels()
                            .map((label) => Tab(
                                  height: 40,
                                  child: Text(label),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            // children: [
            //   _buildFollowupTab(),
            //   if (widget.leadDetails.data?.callHistoryPermission == true)
            //     _buildCallHistoryTab(),
            //   _buildActivitiesTab(),
            //   _buildDetailsTab(),
            //   _buildDocumentsTab(),
            //   if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false)
            //     _buildMilestonesTab(),
            // ],
            children: [
  _buildFollowupTab(),

  if (widget.leadDetails.data?.callHistoryPermission == true)
    _buildCallHistoryTab(),

  _buildActivitiesTab(),

  _buildDetailsTab(),

  _buildDocumentsTab(),

  _buildWorkDetailsTab(),

  if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false)
    _buildMilestonesTab(),
],
          ),
        ),
      ),
    );
  }
Widget _buildWorkDetailsTab() {
  if (isLoadingWorkDetails) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (workDetails == null || workDetails!.data.isEmpty) {
    return const Center(
      child: Text(
        "No Work Details Found",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

 final allTasks = workDetails!.data
    .expand((work) => work.tasks)
    .toList();


// final overallProgress = workDetails!.data.isNotEmpty
//     ? workDetails!.data.first.progress
//     : null;
final allProgress = workDetails!.data
    .map((work) => work.progress)
    .toList();
return SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TASK LIST
        ...allTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task :',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task.taskName.isEmpty
                            ? '-'
                            : task.taskName,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Staff :',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        (task.staffName ?? '')
                                .isEmpty
                            ? '-'
                            : task.staffName!,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documents :',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (task.documents.isEmpty)
                        const Text('No files uploaded')
                      else
                        ...task.documents.map(
                          (doc) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    doc.fileId, // or doc.documentName if available
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    final uri = Uri.parse(doc.fileUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const Divider(height: 30),

const Text(
  'Progress',
  style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

...allProgress.map((progress) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progress.text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${progress.percentage}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.percentage / 100,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              color: progress.percentage >= 100
                  ? Colors.green
                  : progress.percentage >= 75
                      ? Colors.lightGreen
                      : progress.percentage >= 50
                          ? Colors.orange
                          : Colors.red,
            ),
          ),
      ],
    ),
  );
}).toList(),

        const SizedBox(height: 20),

ExpansionTile(
  tilePadding: EdgeInsets.zero,
  title: const Text(
    'Work Log',
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  children: [
    if (allTasks.every((task) => task.workLog.isEmpty))
      const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No work logs available'),
      ),

    ...allTasks.expand((task) {
      return task.workLog.map(
        (log) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Task : ${task.taskName}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text("Staff : ${task.staffName ?? '-'}"),

              const Divider(),

              Text("Date : ${log.createdAt}"),

              const SizedBox(height: 5),

              Text("Start : ${log.startTime}"),

              const SizedBox(height: 5),

              Text("End : ${log.endTime}"),

              const SizedBox(height: 5),

              Text("Duration : ${log.timeTaken}"),

              if (log.remarks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text("Remark : ${log.remarks}"),
              ],

              if (log.logDocuments.isNotEmpty) ...[
                const SizedBox(height: 12),

                const Text(
                  "Files",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                ...log.logDocuments.map(
                  (doc) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: Colors.red,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            doc.logFileId,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.download,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            final uri =
                                Uri.parse(doc.logFileUrl);

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList(),
  ],
),
      ],
    ),
  
  ),
);
}

  Widget _buildHeader() {
    return Container(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Lead Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadSummaryCard() {
    final data = leadDetails!.data!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.clientName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: data.priorityId == "4"
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF44336)
                                .withOpacity(0.08), // accentRed
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFF44336)
                                    .withOpacity(0.2)), // accentRed
                          ),
                          child: Text(
                            data.leadCategory == null ||
                                    data.leadCategory!.isEmpty
                                ? "General"
                                : data.leadCategory!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFF44336), // accentRed
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(data.priorityId),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data.priority ?? 'Normal',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(data.callResultId).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _getStatusColor(data.callResultId)
                              .withOpacity(0.4)),
                    ),
                    child: Text(
                      data.callResult ?? 'New',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(data.callResultId),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (data.leadCategories != null &&
                      data.leadCategories!.length > 1) ...[
                    const SizedBox(height: 8),
                    PopupMenuButton<int>(
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                              border: Border.all(color: Colors.blue.shade200),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        itemBuilder: (context) {
                          return [
                            for (int i = 0;
                                i < data.leadCategories!.length;
                                i++)
                              PopupMenuItem<int>(
                                value: int.parse(data
                                    .leadCategories![i].callMasterId
                                    .toString()),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        data.leadCategories![i].isSelected ==
                                                true
                                            ? Border.all(
                                                color: Colors.green, width: 1.5)
                                            : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Title row with selection indicator
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Selection indicator
                                          if (data.leadCategories![i]
                                                  .isSelected ==
                                              true)
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 18,
                                              ),
                                            ),

                                          // Category name
                                          Expanded(
                                            child: Text(
                                              data.leadCategories![i]
                                                  .leadCategory
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF2C3E50),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(data
                                                  .leadCategories![i].leadStatus
                                                  .toString()),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              data.leadCategories![i].leadStatus
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      // Details row
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            // Staff info
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person_outline,
                                                  size: 14,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  data.leadCategories![i]
                                                      .staffName
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              child: Text(
                                                '•',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ),

                                            // Date info
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(data
                                                      .leadCategories![i]
                                                      .createdDate
                                                      .toString()),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            // PopupMenuItem<int>(
                            //   value: int.parse(data
                            //       .leadCategories![i].callMasterId
                            //       .toString()),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Row(
                            //         children: [
                            //           data.leadCategories![i].isSelected ==
                            //                   true
                            //               ? const Icon(
                            //                   Icons.done,
                            //                   size: 20,
                            //                   color: Colors.green,
                            //                 )
                            //               : const SizedBox(width: 15),
                            //           const SizedBox(width: 10),
                            //           SizedBox(
                            //             width: MediaQuery.of(context)
                            //                     .size
                            //                     .width *
                            //                 0.5,
                            //             child: Text(
                            //               data.leadCategories![i].leadCategory
                            //                   .toString(),
                            //               maxLines: 3,
                            //               overflow: TextOverflow.ellipsis,
                            //             ),
                            //           ),
                            //           Flexible(
                            //             child: Container(
                            //               padding: const EdgeInsets.symmetric(
                            //                   horizontal: 6, vertical: 2),
                            //               decoration: BoxDecoration(
                            //                 color: data.leadCategories![i]
                            //                             .leadStatus ==
                            //                         "New"
                            //                     ? Colors.blue
                            //                     : data.leadCategories![i]
                            //                                 .leadStatus ==
                            //                             "Follow Up"
                            //                         ? Colors.yellow
                            //                         : data.leadCategories![i]
                            //                                     .leadStatus ==
                            //                                 "Rejected"
                            //                             ? Colors.red
                            //                             : const Color
                            //                                 .fromARGB(
                            //                                 255, 96, 66, 226),
                            //                 borderRadius:
                            //                     BorderRadius.circular(4),
                            //               ),
                            //               child: Text(
                            //                 data.leadCategories![i].leadStatus
                            //                     .toString(),
                            //                 style: const TextStyle(
                            //                   color: Colors.white,
                            //                   fontSize: 7.5,
                            //                   fontWeight: FontWeight.bold,
                            //                 ),
                            //                 overflow: TextOverflow.ellipsis,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       const SizedBox(height: 4),
                            //       SingleChildScrollView(
                            //         scrollDirection: Axis.horizontal,
                            //         child: Row(
                            //           children: [
                            //             Padding(
                            //               padding:
                            //                   const EdgeInsets.only(left: 25),
                            //               child: Text(
                            //                 'Staff: ${data.leadCategories![i].staffName.toString()}',
                            //                 style: const TextStyle(
                            //                   fontSize: 11,
                            //                   color: Colors.grey,
                            //                 ),
                            //                 overflow: TextOverflow.ellipsis,
                            //               ),
                            //             ),
                            //             Padding(
                            //               padding:
                            //                   const EdgeInsets.only(left: 10),
                            //               child: Text(
                            //                 'Created Date: ${data.leadCategories![i].createdDate.toString()}',
                            //                 style: const TextStyle(
                            //                   fontSize: 11,
                            //                   color: Colors.grey,
                            //                 ),
                            //                 overflow: TextOverflow.ellipsis,
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ];
                        },
                        onSelected: (value) {
                            if (viewLeadCategoryOnly == "true") return;
                          _refreshData(value.toString());
                        }),
                  ]
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          // Info Grid
          Row(
            children: [
              _buildInfoItem(
                  Icons.phone_android_rounded, data.contactNumber1 ?? 'N/A'),
              const SizedBox(width: 16),
              _buildInfoItem(
                  Icons.person_outline_rounded, data.staffName ?? 'Unassigned'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoItem(
                  Icons.calendar_today_rounded, data.createdDate ?? 'N/A'),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    _getSourceIcon(data.leadSource),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        data.leadSource ?? 'Other',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (data.address?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_rounded,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data.address!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () => _handleCallAction(),
                child: _buildActionColumn(
                  icon: Icons.call,
                  label: 'Call',
                  color: Colors.green,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final String? phone = leadDetails?.data?.contactNumber1;
                  if (phone == null) return;

                  if (value == "1") {
                    final whatsappLink = "https://wa.me/$phone";
                    await launchUrl(Uri.parse(whatsappLink));
                  } else if (value == "2") {
                    Common.showProgressDialog(context, "Loading...");
                    try {
                      GetWhatsappChat whatsappGroup =
                          await HttpService.getWhatsappGroupid(
                        leadDetails!.data!.clientName!,
                        leadDetails!.data!.countryCode!,
                        leadDetails!.data!.contactNumber1!,
                      );
                      if (context.mounted) Navigator.pop(context);

                      if (whatsappGroup.status == true && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              groupId: whatsappGroup.data,
                              nav: "",
                            ),
                          ),
                        ).then((_) => widget.onDataChanged());
                      }
                    } catch (e) {
                      if (context.mounted) Navigator.pop(context);
                      log("Error opening official whatsapp: $e");
                    }
                  }
                },
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "1",
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.whatsapp,
                            size: 20, color: const Color(0xFF25D366)),
                        const SizedBox(width: 12),
                        const Text('Personal WhatsApp'),
                      ],
                    ),
                  ),
                  if (whatsappOfficial == 'true')
                    PopupMenuItem(
                      value: "2",
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.whatsapp,
                              size: 20, color: const Color(0xFF075E54)),
                          const SizedBox(width: 12),
                          const Text('Official WhatsApp'),
                        ],
                      ),
                    ),
                ],
                child: _buildActionColumn(
                  imageAsset: "assets/icons/whatsapp_white.png",
                  label: 'WhatsApp',
                  color: Colors.green,
                  isSolid: true,
                ),
              ),
              // WhatsApp
              // PopupMenuButton<String>(
              //   onSelected: (value) async {
              //     final String? phone = leadDetails?.data?.contactNumber1;
              //     if (phone == null) return;
              //     if (value == "1") {
              //       final whatsappLink = "https://wa.me/$phone";
              //       await launchUrl(Uri.parse(whatsappLink));
              //     } else if (value == "2") {
              //       Common.showProgressDialog(context, "Loading...");
              //       try {
              //         GetWhatsappChat whatsappGroup =
              //             await HttpService.getWhatsappGroupid(
              //                 leadDetails!.data!.clientName!,
              //                 leadDetails!.data!.countryCode!,
              //                 leadDetails!.data!.contactNumber1!);
              //         Navigator.pop(context);
              //         if (whatsappGroup.status == true) {
              //           if (context.mounted) {
              //             Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => ChatScreen(
              //                     groupId: whatsappGroup.data,
              //                     nav: "",
              //                   ),
              //                 )).then((_) {
              //               widget.onDataChanged();
              //             });
              //           }
              //         }
              //       } catch (e) {
              //         Navigator.pop(context);
              //         log("Error opening official whatsapp: $e");
              //       }
              //     }
              //   },
              //   itemBuilder: (context) => [
              //     const PopupMenuItem(
              //         value: "1", child: Text("Personal WhatsApp")),
              //     if (whatsappOfficial == 'true')
              //       const PopupMenuItem(
              //           value: "2", child: Text("Official WhatsApp")),
              //   ],
              //   child: _buildActionColumn(
              //     imageAsset: "assets/icons/whatsapp_white.png",
              //     label: 'WhatsApp',
              //     color: Colors.green,
              //     isSolid: true,
              //   ),
              // ),
              // Share
              // InkWell(
              //   onTap: () async {
              //     final String? phone = leadDetails?.data?.contactNumber1;
              //     final String? name = leadDetails?.data?.clientName;
              //       final String? url = leadDetails?.data?.callMasterId;
              //     if (phone == null) return;
              //     final whatsappLink =
              //         "https://wa.me?text=Name: $name\nPhone :$phone";
              //     await launchUrl(Uri.parse(whatsappLink));
              //   },
              //   child: _buildActionColumn(
              //       icon: Icons.share, label: 'Share', color: Colors.brown),
              // ),
              InkWell(
                onTap: () async {
                  final String? phone = leadDetails?.data?.contactNumber1;
                  final String? name = leadDetails?.data?.clientName;
                  final String? callMasterId = leadDetails?.data?.callMasterId;
                  if (phone == null || callMasterId == null) return;
                  String? baseUrl = await Common.getSharedPref("url");
                  baseUrl = baseUrl ?? "https://s2.login2.in";
                  if (baseUrl.contains('index.php')) {
                    baseUrl = baseUrl.replaceAll('index.php', '');
                    baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
                  }
                  List<int> bytes = utf8.encode(callMasterId);
                  String base64EncodedId = base64.encode(bytes);
                  String urlSafeBase64 = base64EncodedId
                      .replaceAll('+', '-')
                      .replaceAll('/', '_')
                      .replaceAll('=', '');
                  String fullUrl = "$baseUrl/redirect/lead/$urlSafeBase64";
                  String message = "Name: $name\nPhone: $phone\nLink: $fullUrl";
                  String encodedMessage = Uri.encodeComponent(message);
                  final whatsappLink = "https://wa.me/?text=$encodedMessage";
                  await launchUrl(Uri.parse(whatsappLink));
                },
                child: _buildActionColumn(
                    icon: Icons.share, label: 'Share', color: Colors.brown),
              ),
              InkWell(
                onTap: () async {
                  if (contactPermission == 'true') {
                    saveContactDialog(context);
                  } else {
                    contactPermissionDialog(context);
                  }
                },
                child: _buildActionColumn(
                  icon: Icons.person_add,
                  label: 'Add',
                  color: Colors.blueAccent,
                ),
              ),

              // InkWell(
              //   onTap: () async {
              //     final String? phone = leadDetails?.data?.contactNumber1;
              //     final String? name = leadDetails?.data?.clientName;
              //     final String? callMasterId = leadDetails?.data?.callMasterId;

              //     if (phone == null || callMasterId == null) return;
              //     String? baseUrl = await Common.getSharedPref("url");
              //     baseUrl = baseUrl ?? "https://s2.login2.in";
              //     List<int> bytes = utf8.encode(callMasterId);
              //     String base64EncodedId = base64.encode(bytes);
              //     String urlSafeBase64 = base64EncodedId
              //         .replaceAll('+', '-')
              //         .replaceAll('/', '_')
              //         .replaceAll('=', '');
              //     String fullUrl = "$baseUrl/redirect/lead/$urlSafeBase64";
              //     String message = "Name: $name\nPhone: $phone\nLink: $fullUrl";
              //     String encodedMessage = Uri.encodeComponent(message);
              //     final whatsappLink = "https://wa.me/?text=$encodedMessage";
              //     await launchUrl(Uri.parse(whatsappLink));
              //   },
              //   child: _buildActionColumn(
              //       icon: Icons.share, label: 'Share', color: Colors.brown),
              // ),
              PopupMenuButton<String>(
                elevation: 8,
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditLeadNew(
                            widget.token,
                            callMasterId!,
                            widget.editLead,
                            widget.deleteLead,
                            widget.cloudCall,
                            pageName: widget.pageName,
                            status: widget.status,
                            staff: widget.staff,
                            isCalled: widget.isCalled,
                            fromDate: widget.fromDate,
                            toDate: widget.toDate,
                            category: widget.category,
                          ),
                        ),
                      ).then((_) {
                        widget.onDataChanged();
                        Navigator.pop(context);
                      });
                      break;
                    case 'transfer':
                      if (transferPermission == "true") {
                        _showTransferDialog();
                      } else {
                        _showPermissionDialog('transfer permission');
                      }
                      break;
                    case 'add':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLeadsNew(
                            widget.token,
                            page: 'leadDetails',
                            leadMasterId: leadDetails!.data!.callMasterId,
                            clientName: leadDetails!.data!.clientName,
                            phoneNumber: leadDetails!.data!.contactNumber1,
                            whatsappNumber: leadDetails!.data!.whatsaAppNumber,
                            countryCode: leadDetails!.data!.countryCode,
                            fromDate: widget.fromDate,
                            toDate: widget.toDate,
                            editLead: widget.editLead,
                            deleteLead: widget.deleteLead,
                            cloudCall: widget.cloudCall,
                            address: leadDetails!.data!.address,
                            email: leadDetails!.data!.emailId,
                            cost: leadDetails!.data!.cost,
                            leadCategoryId: leadDetails!.data!.leadCategoryId,
                            leadSubCategoryId: leadDetails!.data!.leadSubCategoryId,
                            priorityId: leadDetails!.data!.priorityId,
                            leadSourceId: leadDetails!.data!.leadSourceId,
                            remarks: leadDetails!.data!.remarks,
                            pinCode: leadDetails!.data!.pinCode,
                            stateId: leadDetails!.data!.stateId,
                            districtId: leadDetails!.data!.districtId,
                            assignedUserId: leadDetails!.data!.assignedUserId,
                            leadCategory: leadDetails!.data!.leadCategory,
                            leadSubCategory: leadDetails!.data!.leadSubCategory,
                            leadSource: leadDetails!.data!.leadSource,
                            priority: leadDetails!.data!.priority,
                            stateName: leadDetails!.data!.stateName,
                            districtName: leadDetails!.data!.districtName,
                            products: leadDetails!.data!.productsOnAdd,
                            whatsappCode:
                                leadDetails!.data!.whatsappNumberCountryCode,
                            assignStaff: leadDetails!.data!.staffName,
                            postOffice: leadDetails!.data!.postOffice,
                          ),
                        ),
                      ).then((_) => widget.onDataChanged());
                      break;
                    case 'delete':
                      _deleteDialog(context, "", "lead");
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (widget.editLead)
                    _buildPopupItem(
                        'edit', Icons.edit_rounded, 'Edit', Colors.blue),
                  _buildPopupItem('transfer', Icons.swap_horiz_rounded,
                      'Transfer', Colors.orange),
                  _buildPopupItem('add', Icons.person_add_rounded, 'Add Leads',
                      Colors.green),
                  if (widget.deleteLead)
                    _buildPopupItem('delete', Icons.delete_outline_rounded,
                        'Delete', Colors.red),
                ],
                child: _buildActionColumn(
                  icon: Icons.more_vert,
                  label: 'More',
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? id) {
    switch (id) {
      case '1':
        return Colors.grey;
      case '2':
        return Colors.green;
      case '3':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _getSourceIcon(String? source) {
    IconData iconData;
    Color color = Colors.grey;

    switch (source) {
      case 'Direct Entry':
        iconData = FontAwesomeIcons.keyboard;
        color = Colors.blue;
        break;
      case 'Lead From Facebook':
        iconData = FontAwesomeIcons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case 'Lead From CSV':
        iconData = FontAwesomeIcons.fileCsv;
        color = Colors.green;
        break;
      case 'Lead From IVR':
        iconData = FontAwesomeIcons.phoneVolume;
        color = Colors.orange;
        break;
      case 'Lead from offical whatsapp':
        iconData = FontAwesomeIcons.whatsapp;
        color = const Color(0xFF25D366);
        break;
      default:
        iconData = Icons.source_rounded;
    }

    return Icon(iconData, size: 16, color: color);
  }

  Future<void> _refreshData(String newCallMasterId) async {
    Common.showProgressDialog(context, "Loading...");
    try {
      final response =
          await HttpService.leadDetails(widget.token, newCallMasterId);
      if (response != null) {
             print("RESPONSE DATA: $response");
        setState(() {
          callMasterId = newCallMasterId;
          leadDetails = response;

          final data = leadDetails!.data!;
          contactFName.text = data.clientName ?? '';
          contactMobile.text = data.contactNumber1 ?? '';
          address.text = data.address ?? '';
          cost.text = data.cost ?? '';
          leadTypeId = data.leadCategoryId ?? '';
          leadType = data.leadCategory ?? 'Lead Category';
          leadSubTypeId = data.leadSubCategoryId ?? '';
          leadSubType = data.leadSubCategory ?? 'Lead Sub Category';
          priorityId = data.priorityId ?? '2';
          priority = data.priority ?? 'Normal';
        });

        await Future.wait<dynamic>([
          _fetchActivitiesAndCallHistory(),
          _fetchRenewalDetails(),
          _fetchCallResultReason(),
          _fetchLeadSubType(),
          _fetchAdditionalData(newCallMasterId),
          listFolderList(widget.token, newCallMasterId, ''),
        ]);
      }
    } catch (e) {
      log("Error refreshing lead details: $e");
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _fetchAdditionalData(String cmId) async {
    try {
      final addonResponse = await HttpService.listAddonDet(widget.token, cmId);
      final folderResponse =
          await HttpService.listFolderAndFiles(widget.token, cmId, '');
      final milestoneResponse =
          await HttpService.leadMileStone(widget.token, cmId);
      final followupResponse =
          await HttpService.leadFollowupData(widget.token, cmId);

      setState(() {
        leadDetailsAdditional = addonResponse;
        listFolder = folderResponse;
        mileStone = milestoneResponse;
        leadDetailsFollowup = followupResponse;
      });
    } catch (e) {
      log("Error fetching additional lead data: $e");
    }
  }

  Widget _buildActionColumn({
    IconData? icon,
    String? imageAsset,
    required String label,
    required Color color,
    bool isSolid = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSolid ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: imageAsset != null
              ? Image.asset(
                  imageAsset,
                  width: 20,
                  height: 20,
                  color: isSolid ? Colors.white : color,
                )
              : Icon(icon, color: isSolid ? Colors.white : color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String title,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> postFollowup() async {
    if (callResultId.isEmpty) {
      Common.toastMessaage('Select Status', Colors.red);
      return;
    }
    if (callResponseId.isEmpty) {
      Common.toastMessaage('Select Call Result', Colors.red);
      return;
    }

    bool isFollowup =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (isFollowup && nextFollowupDate1.text.isEmpty) {
      Common.toastMessaage('Select Next Followup Date', Colors.red);
      return;
    }
    if (isFollowup && expectedClosingDate.text.isEmpty) {
      Common.toastMessaage('Select Expected Closing Date', Colors.red);
      return;
    }
    bool isReasonReq = leadSettings?.isReasonRequiredBool ?? false;
    if (isReasonReq &&
        (callResultReasonId.isEmpty ||
            callResultReasonId == '0' ||
            callResultReasonId == 'null')) {
      Common.toastMessaage('Select Tags', Colors.red);
      return;
    }
  if (cost.text.trim().isEmpty ||
    (double.tryParse(cost.text.trim()) ?? 0) <= 0) {
  Common.toastMessaage('Enter Cost', Colors.red);
  return;
}

if (leadTypeId.isEmpty || leadTypeId == "0") {
  Common.toastMessaage('Select Category', Colors.red);
  return;
}

if (remarks.text.trim().isEmpty) {
  Common.toastMessaage('Enter Remarks', Colors.red);
  return;
}

if (createOrder == true && products.isEmpty) {
  Common.toastMessaage('Choose at least one product', Colors.red);
  return;
}
    if (createOrder == true && products.isEmpty) {
      Common.toastMessaage('Choose at least one product', Colors.red);
      return;
    } else if (createOrder == true && paymentStatus == null) {
      Common.toastMessaage('Select payment status', Colors.red);
      return;
    } else if (createOrder == true &&
        paymentStatus != 'unpaid' &&
        (paymentMethod == null || paymentMethod!.isEmpty)) {
      Common.toastMessaage('Select payment method', Colors.red);
      return;
    } else if (createOrder == true && staffId == "") {
      Common.toastMessaage(
          'Collected Staff is required to add invoice', Colors.red);
      return;
    } else if (createOrder == true && targetGroups.isEmpty) {
      Common.toastMessaage('Select at least one Target Group', Colors.red);
      return;
    } else if (createRenewal == true &&
        createRenewalPermission == "true" &&
        startDate.text == "") {
      Common.toastMessaage('Start date is required to add renewal', Colors.red);
      return;
    } else if (createRenewal == true &&
        createRenewalPermission == "true" &&
        endDate.text == "") {
      Common.toastMessaage('End date is required to add renewal', Colors.red);
      return;
    } else if (createOrder == true && paymentStatus != 'unpaid') {
      // Additional validation for Paid/Partial status
      double pAmount = double.tryParse(paidAmount.text) ?? 0;
      if (pAmount <= 0) {
        Common.toastMessaage('Paid Amount must be greater than 0', Colors.red);
        return;
      }
      if (paymentStatus == 'paid' && pAmount < allTotal) {
        Common.toastMessaage(
            'Paid Amount cannot be less than Grand Total for Paid status',
            Colors.red);
        return;
      }
    }
    // setState(() {
    //   isSavingFollowup = true;
    // });

    // if (commonDetails == null) {
    //   Common.toastMessaage('Common data not loaded yet', Colors.red);
    //   return;
    // }
    if (commonDetails == null) {
      Common.toastMessaage('Common data not loaded yet', Colors.red);
      return;
    }

    setState(() {
      isSavingFollowup = true;
    });
    _additionalValues.clear();
    for (int i = 0; i < _additionalCtrls.length; i++) {
      if (i < commonDetails!.data.additionalFields.length) {
        _additionalValues.add({
          "id": commonDetails!.data.additionalFields[i].id,
          "name": commonDetails!.data.additionalFields[i].fieldName,
          "value": _additionalCtrls[i].text,
        });
      }
    }

    Common.showProgressDialog(context, "Saving Followup...");

    try {
      String productIds = _selectedProducts.map((p) => p.id).join(',');

      // final result = await HttpService.addLeadsFollowupUpdated(
          final result = await HttpService.addLeadsFollowupUpdated(
  widget.token,
  callResultId,
  nextFollowupDate1.text,
  cost.text,
  address.text,
  leadTypeId,
  leadSubTypeId,
  remarks.text,
  callMasterId ?? widget.callMasterId,
  calledDate1.text,
  expectedClosingDate.text, // <-- Correct
  '',                       // <-- callHistoryId
  priorityId,
  checked,
  timeBefore.text,
  callResponseId,
  callResultReasonId,
  createOrder,
  createRenewal ? "renewal" : "invoice",
  detailsResponse?.data.checkId ?? '',
  invoiceDate,
  products,
  reminderTemplate.text,
  allTotal,
  startDate.text,
  endDate.text,
  paymentStatus,
  subTotal,
  totalTaxAmount,
  discount.text,
  shippingCharge.text,
  paymentMethod,
  paidAmount.text,
  staffId,
  isDifrent,
  renProducts,
  targetGroups,
  _additionalValues,
  products: productIds,
  createCustomer: createCustomer,
  whatsappLead: whatsappLead.text,
  emailLead: emailLead.text,
);
      if (context.mounted) {
        Navigator.pop(context);
        // if (result.status == true) {
        //   Common.toastMessaage(result.message, Colors.green);
        //   widget.onDataChanged();
        //   // if (mounted) {
        //   //   Navigator.pop(context); // Close the details popup
        //   // }
        //   setState(() {
        //     remarks.clear();
        //     isExpand = false;
        //     isChecked = false;
        //     checked = false;
        //   });
        // } 
        if (result.status == true) {
          Common.toastMessaage(result.message, Colors.green);

          // Refresh popup data
          await _refreshData(callMasterId ?? widget.callMasterId);
          if (mounted) {
            setState(() {});
          }
          // Refresh parent page
          widget.onDataChanged();

          setState(() {
            leadDetails?.data?.callResultId = callResultId;
            leadDetails?.data?.callResult = callResult;
            remarks.clear();
            nextFollowupDate1.clear();

            callResponseId = '';
            callResultReasonId = '';

            isExpand = false;
            isChecked = false;
            checked = false;
          });
        }
        else {
          Common.toastMessaage(result.message, Colors.red);
        }
      }
    } catch (e) {
      log("Error saving followup: $e");
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        Common.toastMessaage("Error saving followup: $e", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSavingFollowup = false;
        });
      }
    }
  }

  Widget _buildFollowupTab() {
    if (commonDetails == null) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ));
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          if (isCreatingOrderOnly)
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Order/Invoice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2a86c9),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              isCreatingOrderOnly = false;
                              createOrder = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildOrderSection(),
                    if (createRenewalPermission == true) ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Create Renewal',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        value: createRenewal,
                        onChanged: (value) {
                          setState(() {
                            createRenewal = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF2a86c9),
                      ),
                      if (createRenewal) _buildRenewalSection(),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSavingFollowup ? null : _postOnlyOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isSavingFollowup
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Order',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Add New Followup Form - Restricted for closed leads (Status ID '4' or name 'Closed')
            if (leadDetails?.data?.callResultId != "4" &&
                leadDetails?.data?.callResult != "Closed")
              _buildAddNewFollowupForm()
            else
              const Card(
                margin: EdgeInsets.all(12),
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This lead is Closed. Further followups are restricted.',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          // List of existing followups
          leadDetailsFollowup == null ||
                  leadDetailsFollowup!.data!.followUpData.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No followups found'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount:
                      leadDetailsFollowup?.data?.followUpData?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    final followup =
                        leadDetailsFollowup!.data!.followUpData[index];
                    final fNo =
                        leadDetailsFollowup!.data!.followUpData.length - index;
                    final isLatest = index == 0; // First item is the latest

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildFollowupItem(followup, fNo, isLatest),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildAddNewFollowupForm() {
    if (commonDetails == null) return const SizedBox();
    return Column(
      children: [
        Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
child: Row(
  children: [
    Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            isExpand = !isExpand;
            if (isExpand) {
              calledDate1.text = DateFormat(
                'dd-MM-yyyy hh:mm a',
              ).format(DateTime.now());
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2a86c9),
                Color(0xFF2a86c9),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2a86c9)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExpand
                    ? Icons.close
                    : Icons.add_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isExpand
                    ? "Close Followup Form"
                    : "Add New Followup",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),

    if (_showAssignWorkButton) ...[
      const SizedBox(width: 10),

      Expanded(
        child: InkWell(
          onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AssignWorkPage(
        callMasterId: widget.callMasterId.toString(),
        callLeadId:
            leadDetails?.data?.callLeadId?.toString() ?? '',
        clientName:
            leadDetails?.data?.clientName ?? '',
        onSuccess: () {
          setState(() {});
        },
      ),
    ),
  );

  print("NAV RESULT = $result");

  if (result == true) {
    await _refreshData(
      callMasterId ?? widget.callMasterId,
    );

    await _loadWorkDetails();

    setState(() {});
  }
},
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.deepOrange,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_add,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Assign Work",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ],
),
),
        if (isExpand)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Called Date
                  const Text(
                    'Called Date',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            final dt = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute);
                            calledDate1.text =
                                DateFormat('dd-MM-yyyy hh:mm a').format(dt);
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(calledDate1.text),
                          const Icon(Icons.access_time_filled, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Call Status',
                    isMandatory: true,
                    value: callResponseId.isEmpty ? null : callResponseId,
                    items: commonDetails!.data.callResponseStatus.map((item) {
                      return DropdownMenuItem(
                        value: item.callResponseId.toString(),
                        child: Text(item.callResponse),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        callResponseId = value!;
                        callResponse = commonDetails!.data.callResponseStatus
                            .firstWhere((element) =>
                                element.callResponseId.toString() == value)
                            .callResponse;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Lead Stages',
                    isMandatory: true,
                    value: callResultId.isEmpty ? null : callResultId,
                    items: commonDetails!.data.callResult.map((item) {
                      return DropdownMenuItem(
                        value: item.callResultId.toString(),
                        child: Text(item.callResult),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        callResultId = value!;
                        callResult = commonDetails!.data.callResult
                            .firstWhere((element) =>
                                element.callResultId.toString() == value)
                            .callResult;
                        _fetchCallResultReason();
                        _fetchLeadExtraSettings(callResultId).then((_) {
                          if (leadSettings != null &&
                              !leadSettings!.isFollowupRequiredBool) {
                            if (mounted) {
                              setState(() {
                                nextFollowupDate1.clear();
                                checked = false;
                              });
                            }
                          } else if (leadSettings == null &&
                              callResultId != '2') {
                            if (mounted) {
                              setState(() {
                                nextFollowupDate1.clear();
                                checked = false;
                              });
                            }
                          }
                        });
                      });
                    },
                  ),
                  if (callResultReason != null &&
                      (callResultReason!.data?.isNotEmpty ?? false))
                    _buildDropdown(
                      label: 'Tags',
                      isMandatory: leadSettings?.isReasonRequiredBool ?? false,
                      value: callResultReasonId.isEmpty
                          ? null
                          : callResultReasonId,
                      items: callResultReason!.data!.map((item) {
                        return DropdownMenuItem(
                          value: item.id ?? '',
                          child: Text(item.reason ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          callResultReasonId = value!;
                        });
                      },
                    ),
                  if (leadSettings != null
                      ? leadSettings!.isFollowupRequiredBool
                      : callResultId == '2') // Assuming '2' is Pending/Followup
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                            children: [
                              TextSpan(text: 'Next Followup Date '),
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            DateTime now = DateTime.now();
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: now,
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                final dt = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute);

                                if (!dt.isAfter(now)) {
                                  if (context.mounted) {
                                    Common.toastMessaage(
                                        'You cannot choose a past time for the follow-up date',
                                        Colors.red);
                                  }
                                  return;
                                }

                                setState(() {
                                  nextFollowupDate1.text =
                                      DateFormat('dd-MM-yyyy hh:mm a')
                                          .format(dt);
                                  if (checked && timeBefore.text.isNotEmpty) {
                                    int minutes =
                                        int.tryParse(timeBefore.text) ?? 10;
                                    DateTime reminderTime =
                                        dt.subtract(Duration(minutes: minutes));
                                    if (reminderTime.isBefore(DateTime.now())) {
                                      int maxMinutes = dt
                                          .difference(DateTime.now())
                                          .inMinutes;
                                      if (maxMinutes <= 0) {
                                        timeBefore.text = "0";
                                      } else {
                                        timeBefore.text = maxMinutes.toString();
                                      }
                                      if (context.mounted) {
                                        Common.toastMessaage(
                                            'Reminder time adjusted to ${timeBefore.text} mins before',
                                            Colors.orange);
                                      }
                                    }
                                  }
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nextFollowupDate1.text.isEmpty
                                      ? 'Select Date & Time'
                                      : nextFollowupDate1.text,
                                ),
                                const Icon(Icons.calendar_month, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(text: 'Expected Closing Date '),
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          InkWell(
                            onTap: () async {
                              DateTime now = DateTime.now();

                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: now,
                                lastDate: DateTime(2101),
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  expectedClosingDate.text =
                                      DateFormat('dd-MM-yyyy').format(pickedDate);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    expectedClosingDate.text.isEmpty
                                        ? 'Select Date'
                                        : expectedClosingDate.text,
                                  ),
                                  const Icon(Icons.calendar_month, size: 18),
                                ],
                              ),
                            ),
                          ),
                        // Reminder
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reminder',
                              style: TextStyle(fontSize: 14)),
                          value: checked,
                          onChanged: (value) {
                            setState(() {
                              checked = value!;
                              if (checked &&
                                  nextFollowupDate1.text.isNotEmpty) {
                                try {
                                  DateTime dt = DateFormat('dd-MM-yyyy hh:mm a')
                                      .parse(nextFollowupDate1.text);
                                  int minutes =
                                      int.tryParse(timeBefore.text) ?? 10;
                                  DateTime reminderTime =
                                      dt.subtract(Duration(minutes: minutes));
                                  if (reminderTime.isBefore(DateTime.now())) {
                                    int maxMinutes =
                                        dt.difference(DateTime.now()).inMinutes;
                                    if (maxMinutes <= 0) {
                                      timeBefore.text = "0";
                                    } else {
                                      timeBefore.text = maxMinutes.toString();
                                    }
                                    if (context.mounted) {
                                      Common.toastMessaage(
                                          'Reminder time adjusted to ${timeBefore.text} mins before',
                                          Colors.orange);
                                    }
                                  }
                                } catch (e) {
                                  // Ignore parsing error
                                }
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (checked) ...[
                          Row(
                            children: [
                              const Text('Time Before (min): ',
                                  style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 10),
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: timeBefore,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            int val =
                                                int.tryParse(timeBefore.text) ??
                                                    0;
                                            int newVal = val + 1;

                                            // Validate before incrementing
                                            if (nextFollowupDate1
                                                .text.isNotEmpty) {
                                              try {
                                                DateTime dt = DateFormat(
                                                        'dd-MM-yyyy hh:mm a')
                                                    .parse(
                                                        nextFollowupDate1.text);
                                                DateTime reminderTime =
                                                    dt.subtract(Duration(
                                                        minutes: newVal));
                                                if (reminderTime
                                                    .isBefore(DateTime.now())) {
                                                  Common.toastMessaage(
                                                      'Cannot set reminder time in the past',
                                                      Colors.red);
                                                  return;
                                                }
                                              } catch (e) {
                                                // Ignore
                                              }
                                            }

                                            setState(() => timeBefore.text =
                                                newVal.toString());
                                          },
                                          child: const Icon(Icons.arrow_drop_up,
                                              size: 18),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            int val =
                                                int.tryParse(timeBefore.text) ??
                                                    0;
                                            if (val > 0) {
                                              setState(() => timeBefore.text =
                                                  "${val - 1}");
                                            }
                                          },
                                          child: const Icon(
                                              Icons.arrow_drop_down,
                                              size: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),

                  // const Text(
                  //   'Products',
                  //   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  // ),
                  // const SizedBox(height: 8),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: GestureDetector(
                  //         onTap: () => _showProductPopup(),
                  //         child: AbsorbPointer(
                  //           child: TextFormField(
                  //             key: ValueKey(_selectedProducts.length),
                  //             initialValue: _selectedProducts.isEmpty
                  //                 ? ''
                  //                 : "${_selectedProducts.length} Product(s) Selected",
                  //             decoration: InputDecoration(
                  //               hintText: 'Select Products',
                  //               prefixIcon:
                  //                   const Icon(Icons.shopping_cart, size: 20),
                  //               isDense: true,
                  //               filled: true,
                  //               fillColor: Colors.grey.shade50,
                  //               border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(8),
                  //                 borderSide:
                  //                     BorderSide(color: Colors.grey.shade300),
                  //               ),
                  //               enabledBorder: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(8),
                  //                 borderSide:
                  //                     BorderSide(color: Colors.grey.shade200),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => const AddProducts(),
                  //             )).then((_) {
                  //           _fetchProductSection();
                  //         });
                  //       },
                  //       child: Container(
                  //         height: 42,
                  //         width: 42,
                  //         decoration: BoxDecoration(
                  //           gradient: const LinearGradient(
                  //               colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //         child: const Icon(
                  //           Icons.add,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 12),
                  // if (_selectedProducts.isNotEmpty)
                  //   Column(
                  //     children: _selectedProducts.map((p) {
                  //       bool isExpanded = _expandedProductId == p.id;
                  //       return Column(
                  //         children: [
                  //           InkWell(
                  //             onTap: () {
                  //               setState(() {
                  //                 if (_expandedProductId == p.id) {
                  //                   _expandedProductId = null;
                  //                 } else {
                  //                   _expandedProductId = p.id;
                  //                   if (p.id != null) {
                  //                     _fetchProductDescription(p.id!);
                  //                   }
                  //                 }
                  //               });
                  //             },
                  //             child: Container(
                  //               margin: const EdgeInsets.only(bottom: 8),
                  //               padding: const EdgeInsets.symmetric(
                  //                   horizontal: 12, vertical: 8),
                  //               decoration: BoxDecoration(
                  //                 color: Colors.blue.shade50,
                  //                 borderRadius: BorderRadius.circular(8),
                  //                 border:
                  //                     Border.all(color: Colors.blue.shade100),
                  //               ),
                  //               child: Row(
                  //                 children: [
                  //                   Expanded(
                  //                     child: Text(
                  //                       "${p.productName} - Rs ${p.totalAmount}",
                  //                       style: const TextStyle(
                  //                           fontWeight: FontWeight.w500,
                  //                           color: Color(0xFF2a86c9)),
                  //                     ),
                  //                   ),
                  //                   GestureDetector(
                  //                     onTap: () => _removeFollowupProduct(p),
                  //                     child: const Icon(Icons.cancel,
                  //                         size: 20, color: Colors.red),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //           if (isExpanded &&
                  //               (_descriptionLoading[p.id] == true ||
                  //                   (_productDescriptions[p.id]?.isNotEmpty ??
                  //                       false)))
                  //             Container(
                  //               width: double.infinity,
                  //               padding: const EdgeInsets.all(12),
                  //               margin: const EdgeInsets.only(
                  //                   bottom: 12, left: 4, right: 4),
                  //               decoration: BoxDecoration(
                  //                 color: Colors.grey.shade50,
                  //                 borderRadius: BorderRadius.circular(8),
                  //                 border:
                  //                     Border.all(color: Colors.grey.shade200),
                  //               ),
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   const Text(
                  //                     "Product Description",
                  //                     style: TextStyle(
                  //                         fontSize: 13,
                  //                         fontWeight: FontWeight.bold,
                  //                         color: Colors.black87),
                  //                   ),
                  //                   const SizedBox(height: 4),
                  //                   _descriptionLoading[p.id] == true
                  //                       ? const Center(
                  //                           child: Padding(
                  //                             padding: EdgeInsets.all(8.0),
                  //                             child: SizedBox(
                  //                               height: 20,
                  //                               width: 20,
                  //                               child:
                  //                                   CircularProgressIndicator(
                  //                                 strokeWidth: 2,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         )
                  //                       : Text(
                  //                           _productDescriptions[p.id] ?? "",
                  //                           style: const TextStyle(
                  //                               fontSize: 12,
                  //                               color: Colors.grey),
                  //                         ),
                  //                 ],
                  //               ),
                  //             ),
                  //         ],
                  //       );
                  //     }).toList(),
                  //   ),
                 
                  const SizedBox(height: 12),

                  Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: 'Cost '),
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: cost,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
              prefixIcon: Icon(Icons.currency_rupee, size: 18),
            ),
          ),
        ],
      ),
    ),
  ],
),
const SizedBox(height: 12),
                  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: 'Lead Category '),
          TextSpan(
            text: '*',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    ),
    const SizedBox(height: 6),
    _buildDropdown(
      label: '',
      value: leadTypeId.isEmpty ? null : leadTypeId,
      items: commonDetails!.data.leadCategory.map((item) {
        return DropdownMenuItem(
          value: item.leadCategoryId.toString(),
          child: Text(item.leadCategory),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          leadTypeId = value!;
          leadType = commonDetails!.data.leadCategory
              .firstWhere((element) =>
                  element.leadCategoryId.toString() == value)
              .leadCategory;
          _fetchLeadSubType();
        });
      },
    ),
  ],
),
                  //  const SizedBox(height:12),
                  _buildDropdown(
                    label: 'Sub Category',
                    value: leadSubTypeId.isEmpty ? null : leadSubTypeId,
                    items: (leadSubTypeList?.data ?? []).map((item) {
                      return DropdownMenuItem(
                        value: item.leadSubCategoryId.toString(),
                        child: Text(item.leadSubCategory ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        leadSubTypeId = value!;
                        leadSubType = leadSubTypeList!.data!
                            .firstWhere((element) =>
                                element.leadSubCategoryId.toString() == value)
                            .leadSubCategory!;
                      });
                    },
                  ),

                  // _buildDropdown(
                  //   label: 'Call Result *',
                  //   value: callResponseId.isEmpty ? null : callResponseId,
                  //   items: commonDetails!.data.callResponseStatus.map((item) {
                  //     return DropdownMenuItem(
                  //       value: item.callResponseId.toString(),
                  //       child: Text(item.callResponse),
                  //     );
                  //   }).toList(),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       callResponseId = value!;
                  //       callResponse = commonDetails!.data.callResponseStatus
                  //           .firstWhere((element) =>
                  //               element.callResponseId.toString() == value)
                  //           .callResponse;
                  //     });
                  //   },
                  // ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isMoreDetails = !isMoreDetails;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            isMoreDetails ? 'Less Details' : 'More Details',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            isMoreDetails
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isMoreDetails,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Priority',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: commonDetails!.data.priority.length,
                            itemBuilder: (context, i) {
                              final p = commonDetails!.data.priority[i];
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Radio<String>(
                                        activeColor: p.priorityId.toString() ==
                                                '1'
                                            ? Colors.grey
                                            : p.priorityId.toString() == '2'
                                                ? Colors.green
                                                : p.priorityId.toString() == '3'
                                                    ? Colors.red
                                                    : Colors.purple,
                                        value: p.priorityId.toString(),
                                        groupValue: priorityId,
                                        onChanged: (String? value) {
                                          setState(() {
                                            priorityId = value!;
                                            priority = p.priority;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(p.priority,
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category
                        // _buildDropdown(
                        //   label: 'Category',
                        //   value: leadTypeId.isEmpty ? null : leadTypeId,
                        //   items: commonDetails!.data.leadCategory.map((item) {
                        //     return DropdownMenuItem(
                        //       value: item.leadCategoryId.toString(),
                        //       child: Text(item.leadCategory),
                        //     );
                        //   }).toList(),
                        //   onChanged: (value) {
                        //     setState(() {
                        //       leadTypeId = value!;
                        //       leadType = commonDetails!.data.leadCategory
                        //           .firstWhere((element) =>
                        //               element.leadCategoryId.toString() ==
                        //               value)
                        //           .leadCategory;
                        //       _fetchLeadSubType();
                        //     });
                        //   },
                        // ),
                        // const SizedBox(height: 12),

                        // // Sub Category
                        // _buildDropdown(
                        //   label: 'Sub Category',
                        //   value: leadSubTypeId.isEmpty ? null : leadSubTypeId,
                        //   items: (leadSubTypeList?.data ?? []).map((item) {
                        //     return DropdownMenuItem(
                        //       value: item.leadSubCategoryId.toString(),
                        //       child: Text(item.leadSubCategory ?? ''),
                        //     );
                        //   }).toList(),
                        //   onChanged: (value) {
                        //     setState(() {
                        //       leadSubTypeId = value!;
                        //       leadSubType = leadSubTypeList!.data!
                        //           .firstWhere((element) =>
                        //               element.leadSubCategoryId.toString() ==
                        //               value)
                        //           .leadSubCategory!;
                        //     });
                        //   },
                        // ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WhatsApp Number',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: whatsappLead,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'WhatsApp Number',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.all(12),
                                prefixIcon: const Icon(
                                    FontAwesomeIcons.whatsapp,
                                    size: 18,
                                    color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email ID',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: emailLead,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email ID',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.all(12),
                                prefixIcon: const Icon(Icons.email,
                                    size: 18, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 12),

                        // const Text(
                        //   'Products',
                        //   style: TextStyle(
                        //       fontSize: 13, fontWeight: FontWeight.w500),
                        // ),
                        // const SizedBox(height: 8),
                        // TextField(
                        //   controller: _productSearchCtrl,
                        //   onChanged: _onFollowupProductSearch,
                        //   decoration: InputDecoration(
                        //     hintText: 'Search Product...',
                        //     prefixIcon: const Icon(Icons.search, size: 20),
                        //     isDense: true,
                        //     filled: true,
                        //     fillColor: Colors.grey.shade50,
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(8),
                        //       borderSide:
                        //           BorderSide(color: Colors.grey.shade300),
                        //     ),
                        //   ),
                        // ),
                        // if (_productSearchResults.isNotEmpty)
                        //   Container(
                        //     constraints: const BoxConstraints(maxHeight: 200),
                        //     margin: const EdgeInsets.only(top: 4),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(8),
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Colors.black.withOpacity(0.1),
                        //           blurRadius: 4,
                        //           offset: const Offset(0, 2),
                        //         )
                        //       ],
                        //     ),
                        //     child: ListView.builder(
                        //       shrinkWrap: true,
                        //       itemCount: _productSearchResults.length,
                        //       itemBuilder: (ctx, i) {
                        //         final p = _productSearchResults[i];
                        //         return ListTile(
                        //           title: Text(p.productName ?? ''),
                        //           subtitle: Text("₹ ${p.totalAmount}"),
                        //           onTap: () => _addFollowupProduct(p),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // const SizedBox(height: 8),
                        // Wrap(
                        //   spacing: 8,
                        //   children: _selectedProducts
                        //       .map((p) => Chip(
                        //             label: Text(p.productName ?? ''),
                        //             onDeleted: () => _removeFollowupProduct(p),
                        //             backgroundColor: Colors.blue.shade50,
                        //             deleteIconColor: Colors.red,
                        //           ))
                        //       .toList(),
                        // ),
                        // const SizedBox(height: 12),

                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: TextField(
                        //         controller: cost,
                        //         keyboardType: TextInputType.number,
                        //         decoration: const InputDecoration(
                        //           labelText: 'Cost',
                        //           border: OutlineInputBorder(),
                        //           contentPadding: EdgeInsets.all(12),
                        //           prefixIcon:
                        //               Icon(Icons.currency_rupee, size: 18),
                        //         ),
                        //       ),
                        //     ),
                        //     // const SizedBox(width: 12),
                        //     // Expanded(
                        //     //   child: TextField(
                        //     //     controller: address,
                        //     //     decoration: const InputDecoration(
                        //     //       labelText: 'Address',
                        //     //       border: OutlineInputBorder(),
                        //     //       contentPadding: EdgeInsets.all(12),
                        //     //       prefixIcon: Icon(Icons.home, size: 18),
                        //     //     ),
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Expanded(
                            //   child: TextField(
                            //     controller: cost,
                            //     keyboardType: TextInputType.number,
                            //     decoration: const InputDecoration(
                            //       labelText: 'Cost',
                            //       border: OutlineInputBorder(),
                            //       contentPadding: EdgeInsets.all(12),
                            //       prefixIcon:
                            //           Icon(Icons.currency_rupee, size: 18),
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: address,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(12),
                                  prefixIcon: Icon(Icons.home, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (commonDetails != null &&
                            commonDetails!.data.callResponse.isNotEmpty)
                          SizedBox(
                            height: 35,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  commonDetails!.data.callResponse.length,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        remarks.text = commonDetails!
                                            .data.callResponse[i]
                                            .toString();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Text(
                                          commonDetails!.data.callResponse[i]
                                              .toString(),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),

                        // Remarks
                        Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: 'Remarks '),
          TextSpan(
            text: '*',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    ),
    const SizedBox(height: 6),
    TextField(
      controller: remarks,
      maxLines: 2,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
      ),
    ),
  ],
),
                        const SizedBox(height: 12),

                        if (commonDetails?.data.additionalFields != null &&
                            commonDetails!
                                .data.additionalFields.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0, top: 4.0),
                            child: Text(
                              "Additional Fields",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ..._buildAdditionalFieldsUI(),
                        ],

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Create Order and Create Customer Checkboxes
                  if ((leadSettings != null
                          ? leadSettings!.createInvoiceBool
                          : (callResultId == '4' &&
                              customerAddInvoicePermission == true)) ||
                      (leadSettings?.createCustomerBool ?? false))
                    Row(
                      children: [
                        if (leadSettings != null
                            ? leadSettings!.createInvoiceBool
                            : (callResultId == '4' &&
                                customerAddInvoicePermission == true))
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Create Order',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              value: createOrder,
                              onChanged: (value) {
                                setState(() {
                                  createOrder = value!;
                                  if (!createOrder) createRenewal = false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: const Color(0xFF2a86c9),
                            ),
                          ),
                        if (leadSettings?.createCustomerBool ?? false)
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Create Customer',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              value: createCustomer,
                              onChanged: (value) {
                                setState(() {
                                  createCustomer = value!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: const Color(0xFF2a86c9),
                            ),
                          ),
                      ],
                    ),

                  // Order Details (Conditional)
                  if (createOrder &&
                      (leadSettings != null
                          ? leadSettings!.createInvoiceBool
                          : (callResultId == '4' &&
                              customerAddInvoicePermission == true)))
                    _buildOrderSection(),

                  // Create Renewal Checkbox (Conditional)
                  if (createOrder &&
                      (leadSettings != null
                          ? leadSettings!.createRenewalBool
                          : (callResultId == '4' &&
                              createRenewalPermission == "true")))
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Create Renewal',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      value: createRenewal,
                      onChanged: (value) {
                        setState(() {
                          createRenewal = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF2a86c9),
                    ),

                  // Renewal Details (Conditional)
                  if (createRenewal &&
                      createOrder &&
                      (leadSettings != null
                          ? leadSettings!.createRenewalBool
                          : createRenewalPermission == "true"))
                    _buildRenewalSection(),

                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSavingFollowup
                          ? null
                          : () {
                              if (callResultId == '4' && createOrder == false) {
                                createOrderDialog(context);
                              } else {
                                postFollowup();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2a86c9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: isSavingFollowup
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      
      ],
    );
  }

  Future<void> _postOnlyOrder() async {
    if (creatingOrderFollowupId == null) return;

    if (createOrder && products.isEmpty) {
      Common.toastMessaage('Please add at least one product', Colors.red);
      return;
    }

    if (paymentStatus == null) {
      Common.toastMessaage('Please select payment status', Colors.red);
      return;
    }

    if (paymentStatus != 'unpaid' && paymentMethod == null) {
      Common.toastMessaage('Please select payment method', Colors.red);
      return;
    }

    if (staffId == "") {
      Common.toastMessaage('Please select account head', Colors.red);
      return;
    }

    if (targetGroups.isEmpty) {
      Common.toastMessaage(
          'Please select at least one target group', Colors.red);
      return;
    }

    // Followup validation
    if (callResponseId.isEmpty) {
      Common.toastMessaage('Please select call response', Colors.red);
      return;
    }

    bool isFollowup =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (isFollowup && nextFollowupDate1.text.isEmpty) {
      Common.toastMessaage('Please select next followup date', Colors.red);
      return;
    }

    if (paymentStatus != 'unpaid') {
      double pAmount = double.tryParse(paidAmount.text) ?? 0;
      if (pAmount <= 0) {
        Common.toastMessaage('Paid Amount must be greater than 0', Colors.red);
        return;
      }
      if (paymentStatus == 'paid' && pAmount < allTotal) {
        Common.toastMessaage(
            'Paid Amount cannot be less than Grand Total for Paid status',
            Colors.red);
        return;
      }
    }
    // Costprint("Cost = '${cost.text}'");
// print("LeadTypeId = '$leadTypeId'");
// print("Remarks = '${remarks.text}'");
if (cost.text.trim().isEmpty ||
    (double.tryParse(cost.text.trim()) ?? 0) <= 0) {
  Common.toastMessaage('Please enter a valid cost', Colors.red);
  return;
}

// Category validation
if (leadTypeId.trim().isEmpty || leadTypeId == "0") {
  Common.toastMessaage('Please select category', Colors.red);
  return;
}

// Remarks validation
if (remarks.text.trim().isEmpty) {
  Common.toastMessaage('Please enter remarks', Colors.red);
  return;
}
    setState(() => isSavingFollowup = true);

    try {
      final response = await HttpService.postConfirmedFollowup(
        creatingOrderFollowupId!,
        remarks.text, // Reusing remarks as invoice remarks
        renewalRemarks.text,
        createRenewal ? "renewal" : "invoice",
        detailsResponse!.data.checkId,
        invoiceDate,
        products,
        reminderTemplate.text,
        allTotal,
        startDate.text,
        endDate.text,
        paymentStatus,
        subTotal,
        totalTaxAmount,
        discount.text,
        shippingCharge.text,
        paymentMethod,
        paidAmount.text,
        staffId,
        isDifrent,
        renProducts,
        targetGroups,
        callResultId: callResultId,
        callResponseId: callResponseId,
        nextFollowupDate: nextFollowupDate1.text,
      );

      if (response != null && response.status == true) {
        Common.toastMessaage(response.message, Colors.green);
        setState(() {
          isCreatingOrderOnly = false;
          createOrder = false;
          createRenewal = false;
          products.clear();
          renProducts.clear();
          _recalculateTotals();
        });
        widget.onDataChanged();
        if (mounted) {
          Navigator.pop(context); // Close the details popup
        }
      } else {
        Common.toastMessaage(
            response?.message ?? 'Failed to create order', Colors.red);
      }
    } catch (e) {
      log('Error posting order: $e');
      Common.toastMessaage('Error posting order', Colors.red);
    } finally {
      if (mounted) setState(() => isSavingFollowup = false);
    }
  }

  Widget _buildOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Invoice Number:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Invoice Date:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(
              width: 150,
              child: DateTimePicker(
                type: DateTimePickerType.date,
                initialValue: invoiceDate.toString(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onChanged: (val) {
                  setState(() {
                    invoiceDate = DateTime.parse(val);
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => addProductsDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Product Table
        if (products.isNotEmpty) _buildProductTable(),

        const SizedBox(height: 16),

        // Totals
        _buildTotalRow('Sub Total', subTotal.toStringAsFixed(2)),
        _buildTotalRow('Tax Amount', totalTaxAmount.toStringAsFixed(2)),
        _buildTotalRow('Discount', null, controller: discount,
            onChanged: (val) {
          _recalculateTotals();
        }),
        _buildTotalRow('Shipping Charge', null, controller: shippingCharge,
            onChanged: (val) {
          _recalculateTotals();
        }),
        const Divider(),
        _buildTotalRow('Grand Total', allTotal.toStringAsFixed(2),
            isGrandTotal: true),

        const SizedBox(height: 16),

        // Payment Details
        _buildDropdown(
          label: 'Payment Status',
          isMandatory: true,
          value: paymentStatus,
          items: [
            const DropdownMenuItem(value: 'paid', child: Text('Paid')),
            const DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
            const DropdownMenuItem(value: 'partial', child: Text('Partial')),
          ],
          onChanged: (val) {
            setState(() {
              paymentStatus = val;
              if (paymentStatus == 'paid') {
                paidAmount.text = allTotal.toStringAsFixed(2);
              } else if (paymentStatus == 'unpaid') {
                paidAmount.text = '0.00';
              }
            });
          },
        ),

        if (paymentStatus != 'unpaid')
          Column(
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: paidAmount,
                keyboardType: TextInputType.number,
                readOnly: paymentStatus == 'paid',
                decoration: InputDecoration(
                  label: RichText(
                    text: const TextSpan(
                      text: 'Total Paid Amount ',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(text: '*', style: TextStyle(color: Colors.red))
                      ],
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Payment Details',
                isMandatory: true,
                value: paymentMethod,
                items: detailsResponse?.data.paymentMethods.map((m) {
                      return DropdownMenuItem(
                        value: m.id.toString(),
                        child: Text(m.name),
                      );
                    }).toList() ??
                    [],
                onChanged: (val) {
                  setState(() {
                    paymentMethod = val;
                  });
                },
              ),
            ],
          ),

        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
            children: [
              TextSpan(text: 'Collected staff '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => collectedStaffDialog(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(staffName),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
            children: [
              TextSpan(text: 'Target Group'),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => targetGroupDialog(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    targetGroupNames.isEmpty
                        ? 'Select Target Groups'
                        : targetGroupNames.join(', '),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          'Followup Details',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2a86c9)),
        ),
        const Divider(),
        const SizedBox(height: 8),

        // Stage Dropdown
        _buildDropdown(
          label: 'Stage',
          value: callResultId.isEmpty ? null : callResultId,
          isMandatory: true,
          items: commonDetails!.data.callResult.map((item) {
            return DropdownMenuItem(
              value: item.callResultId.toString(),
              child: Text(item.callResult),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              callResultId = value!;
              callResult = commonDetails!.data.callResult
                  .firstWhere(
                      (element) => element.callResultId.toString() == value)
                  .callResult;
              _fetchCallResultReason();
              _fetchLeadExtraSettings(callResultId);
            });
          },
        ),

        // Call Response Dropdown
        _buildDropdown(
          label: 'Call Response',
          value: callResponseId.isEmpty ? null : callResponseId,
          isMandatory: true,
          items: commonDetails!.data.callResponseStatus.map((item) {
            return DropdownMenuItem(
              value: item.callResponseId.toString(),
              child: Text(item.callResponse),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              callResponseId = value!;
              callResponse = commonDetails!.data.callResponseStatus
                  .firstWhere(
                      (element) => element.callResponseId.toString() == value)
                  .callResponse;
            });
          },
        ),

        // Next Followup Date (Conditional)
        if (leadSettings != null
            ? leadSettings!.isFollowupRequiredBool
            : callResultId == '2')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                  children: [
                    TextSpan(text: 'Next Followup Date '),
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  DateTime now = DateTime.now();
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        final dt = DateTime(pickedDate.year, pickedDate.month,
                            pickedDate.day, pickedTime.hour, pickedTime.minute);
                        nextFollowupDate1.text =
                            DateFormat('dd-MM-yyyy hh:mm a').format(dt);
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        nextFollowupDate1.text.isEmpty
                            ? 'Select Date & Time'
                            : nextFollowupDate1.text,
                      ),
                      const Icon(Icons.calendar_month, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        TextField(
          controller: remarks,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Remarks',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildRenewalSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      children: [
                        TextSpan(text: 'Start Date '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                          if (typeDuration.isNotEmpty) {
                            final end = picked
                                .add(Duration(days: int.parse(typeDuration)));
                            endDate.text = DateFormat('dd-MM-yyyy').format(end);
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(startDate.text.isEmpty
                              ? 'Start Date'
                              : startDate.text),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      children: [
                        TextSpan(text: 'End Date '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              endDate.text.isEmpty ? 'End Date' : endDate.text),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        TextFormField(
          onTap: () {
            dropDialog(context);
          },
          readOnly: true,
          controller: reminderTemplate,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              labelText: 'Remind Template ',
              prefixIcon: Icon(Icons.notifications, color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              labelStyle: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(
          height: 14,
        ),
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Is renewal amount is diffrent?'),
            value: isDifrent, // initial value of the checkbox
            onChanged: (bool? value) {
              setState(() {
                isDifrent = value!;
              });
            },
            controlAffinity: ListTileControlAffinity.leading),
        const SizedBox(
          height: 14,
        ),
        Visibility(
          visible: isDifrent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(1),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.0),
                    1: FlexColumnWidth(1.6),
                    2: FlexColumnWidth(0.8),
                    3: FlexColumnWidth(1.6),
                    4: FlexColumnWidth(2.0),
                    5: FlexColumnWidth(1.0),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: const Color(0xFFece9fd),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Product',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Rate',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Qty',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tax',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Amount',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(' ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              renProducts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No Products !",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Column(
                      children: renProducts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;
                        Color color = index % 2 == 0
                            ? const Color(0xFFF3F3F3)
                            : const Color(0xFFece9fd);
                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2.0),
                              1: FlexColumnWidth(1.6),
                              2: FlexColumnWidth(0.8),
                              3: FlexColumnWidth(1.6),
                              4: FlexColumnWidth(2.0),
                              5: FlexColumnWidth(1.0),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  color: color,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['product_name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['product_rate'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['quantity'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['total_tax_amount'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['total_amount'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      changeAmount(
                                              context,
                                              product['product_name'],
                                              product['product_rate'],
                                              product['quantity'],
                                              product['total_tax_amount'],
                                              product['tax_percent'],
                                              product['total_amount'],
                                              product['product_id'],
                                              product['description'] ?? "nil",
                                              index)
                                          .then((_) {
                                        setState(() {});
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _addFollowupProduct(LeadProduct p) {
    setState(() {
      if (!_selectedProducts.any((item) => item.id == p.id)) {
        _selectedProducts.add(p);
      }
      _updateFollowupCostFromProducts();
    });
  }

  void _removeFollowupProduct(LeadProduct p) {
    setState(() {
      _selectedProducts.removeWhere((item) => item.id == p.id);
      _updateFollowupCostFromProducts();
    });
  }

  void _updateFollowupCostFromProducts() {
    double total = 0;
    for (var p in _selectedProducts) {
      total += double.tryParse(p.totalAmount ?? '0') ?? 0;
    }
    cost.text = total.toStringAsFixed(2);
  }

  Widget _buildProductTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Product',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Amount',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 40),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                dense: true,
                title: Text(p['product_name'],
                    style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                    'Rate: ₹${p['product_rate']} + Tax: ₹${p['total_tax_amount']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('x${p['quantity']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text('₹${p['total_amount']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          _removeProduct(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String? value,
      {TextEditingController? controller,
      ValueChanged<String>? onChanged,
      bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
                  fontSize: isGrandTotal ? 16 : 14)),
          if (controller != null)
            SizedBox(
              width: 100,
              height: 35,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(),
                ),
                onChanged: onChanged,
              ),
            )
          else
            Text('₹ $value',
                style: TextStyle(
                    fontWeight:
                        isGrandTotal ? FontWeight.bold : FontWeight.bold,
                    fontSize: isGrandTotal ? 16 : 14,
                    color:
                        isGrandTotal ? const Color(0xFF2a86c9) : Colors.black)),
        ],
      ),
    );
  }

  void _recalculateTotals() {
    double d = double.tryParse(discount.text) ?? 0.0;
    double s = double.tryParse(shippingCharge.text) ?? 0.0;

    setState(() {
      allTotal = subTotalGrand + s - d;
      if (paymentStatus == 'paid') {
        paidAmount.text = allTotal.toStringAsFixed(2);
      }
    });
  }

  void _removeProduct(int index) {
    subTotalGrand -= double.parse(products[index]['total_amount']);
    subTotal -= (double.parse(products[index]['product_rate']) *
        double.parse(products[index]['quantity']));
    totalTaxAmount -= double.parse(products[index]['total_tax_amount']);

    products.removeAt(index);
    if (renProducts.length > index) renProducts.removeAt(index);

    if (products.isEmpty) {
      discount.clear();
      shippingCharge.clear();
      subTotal = 0.00;
      subTotalGrand = 0.00;
      totalTaxAmount = 0.00;
      allTotal = 0.00;
      paidAmount.text = '0.00';
    } else {
      _recalculateTotals();
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool isMandatory = false,
  }) {
    // 1. Ensure unique items to avoid duplicate value crash
    final seenValues = <String?>{};
    final uniqueItems =
        items.where((item) => seenValues.add(item.value)).toList();

    // 2. Check if the value exists in the unique items list. If not, set to null to avoid crash.
    String? safeValue =
        uniqueItems.any((item) => item.value == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMandatory
            ? RichText(
                text: TextSpan(
                  text: label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                  children: const [
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                  ],
                ),
              )
            : Text(
                label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: safeValue,
              items: uniqueItems,
              onChanged: onChanged,
              hint: Text('Select $label'),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFollowupItem(
      af.FollowUpDatum followup, int followupNumber, bool isLatest) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLatest
                ? Colors
                    .blue.shade50 // Light blue background for latest followup
                : Colors.white, // White background for others
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLatest
                  ? Colors.blue.shade200 // Blue border for latest
                  : Colors.grey.shade200, // Grey border for others
            ),
            // Optional: Add a subtle shadow for the latest followup
            boxShadow: isLatest
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color:
                        isLatest ? Colors.blue.shade300 : Colors.grey.shade300,
                  ),
                  image: followup.proPicThumb.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(followup.proPicThumb),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: followup.proPicThumb.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 20,
                        color: isLatest ? Colors.blue.shade400 : Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            followup.staffName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isLatest
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (followup.isSetReminder == true)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    _showReminderDialog(followup);
                                  },
                                  child: Icon(
                                    Icons.notifications,
                                    color: followup.isReminder == true
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            if (createCustomerInvoice == true &&
                                (leadDetailsFollowup
                                        ?.data?.followUpData?.isNotEmpty ??
                                    false) &&
                                leadDetailsFollowup!
                                        .data!.followUpData[0].callResult ==
                                    "Closed" &&
                                leadDetailsAdditional?.data.isCreateOrder ==
                                    true)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isCreatingOrderOnly = true;
                                    createOrder = true;
                                    creatingOrderFollowupId =
                                        (callMasterId ?? widget.callMasterId);
                                    _fetchRenewalDetails();
                                  });
                                },
                                child: Icon(
                                  Icons.add,
                                  color: isLatest
                                      ? Colors.green.shade600
                                      : Colors.green,
                                  size: 22,
                                ),
                              )
                            else if (leadDetails?.data?.callResultId != "4" &&
                                leadDetails?.data?.callResult != "Closed" &&
                                leadDetailsFollowup!
                                        .data.followUpData[0].callResult ==
                                    "Closed")
                              InkWell(
                                onTap: () {
                                  Get.to(() => CustomerDashboard(
                                        token: widget.token,
                                        name: name ?? '',
                                        userId: userId ?? '',
                                        phoneCallLogPermission:
                                            phoneCallLogPermission,
                                        custId: leadDetailsAdditional!
                                            .data.customerId
                                            .toString(),
                                      ))?.then((r) {
                                    _refreshData(
                                        callMasterId ?? widget.callMasterId);
                                    widget.onDataChanged();
                                  });
                                },
                                child: Icon(
                                  Icons.menu,
                                  color: isLatest
                                      ? Colors.green.shade600
                                      : Colors.green,
                                  size: 22,
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (followup.isEdit == true)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditFollowup(
                                                widget.token,
                                                widget.editLead,
                                                widget.deleteLead,
                                                widget.cloudCall,
                                                (callMasterId ??
                                                    widget.callMasterId),
                                                followup.callDetailsId
                                                    .toString(),
                                                pageName: widget.pageName,
                                                status: widget.status,
                                                staff: widget.staff,
                                                isCalled: widget.isCalled,
                                                fromDate: widget.fromDate,
                                                toDate: widget.toDate,
                                                category: widget.category,
                                              )))?.then((r) {
                                    _refreshData(
                                        callMasterId ?? widget.callMasterId);
                                    widget.onDataChanged();
                                  });
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: isLatest
                                      ? Colors.blue.shade600
                                      : Colors.blue,
                                  size: 18,
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (followup.isDelete == true)
                              InkWell(
                                onTap: () {
                                  _deleteDialog(context, followup.callDetailsId,
                                      "followup");
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: isLatest
                                      ? Colors.red.shade600
                                      : Colors.red,
                                  size: 18,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(followup.callResultId),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                followup.callResult,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (followup.isCalled == false)
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Text(
                                  '( Pending )',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     // children: [
  //                     //   Row(
  //                     //     children: [
  //                     //       followup.callResultId != "3" &&
  //                     //               followup.callResultId != "4"
  //                     //           ? Icon(
  //                     //               Icons.access_time,
  //                     //               size: 12,
  //                     //               color: isLatest
  //                     //                   ? Colors.blue.shade400
  //                     //                   : Colors.grey.shade500,
  //                     //             )
  //                     //           : SizedBox(),
  //                     //       const SizedBox(width: 4),
  //                     //       followup.callResultId != "3" &&
  //                     //               followup.callResultId != "4"
  //                     //           ? Text(
  //                     //               followup.isNewCall == "Y"
  //                     //                   ? 'Created Date: ${followup.scheduledDate}'
  //                     //                   : 'Scheduled Date: ${followup.scheduledDate}',
  //                     //               style: TextStyle(
  //                     //                 fontSize: 11,
  //                     //                 fontWeight: FontWeight.bold, // Added bold
  //                     //                 color: isLatest
  //                     //                     ? Colors.blue.shade600
  //                     //                     : Colors.grey.shade500,
  //                     //                 letterSpacing:
  //                     //                     0.5, // Added for better readability
  //                     //                 shadows: isLatest
  //                     //                     ? [
  //                     //                         // Added shadow effect for "showy" look
  //                     //                         Shadow(
  //                     //                           offset: Offset(0, 0.5),
  //                     //                           blurRadius: 1,
  //                     //                           color: Colors.blue.shade200
  //                     //                               .withOpacity(0.5),
  //                     //                         ),
  //                     //                       ]
  //                     //                     : null,
  //                     //               ),
  //                     //             )
  //                     //           : SizedBox(),
  //                     //       // if (followup.calledDate != "") ...[
  //                     //       //   const SizedBox(width: 4),
  //                     //       //   Text(
  //                     //       //     'Called Date: ${followup.calledDate}',
  //                     //       //     style: TextStyle(
  //                     //       //       fontSize: 11,
  //                     //       //       fontWeight: FontWeight.bold, // Added bold
  //                     //       //       color: isLatest
  //                     //       //           ? Colors.blue.shade600
  //                     //       //           : Colors.grey.shade500,
  //                     //       //       letterSpacing:
  //                     //       //           0.5, // Added for better readability
  //                     //       //       shadows: isLatest
  //                     //       //           ? [
  //                     //       //               // Added shadow effect for "showy" look
  //                     //       //               Shadow(
  //                     //       //                 offset: Offset(0, 0.5),
  //                     //       //                 blurRadius: 1,
  //                     //       //                 color: Colors.blue.shade200
  //                     //       //                     .withOpacity(0.5),
  //                     //       //               ),
  //                     //       //             ]
  //                     //       //           : null,
  //                     //       //     ),
  //                     //       //   ),
  //                     //       //],
  //                     //     ],
  //                     //   ),
                      
  //                     // ],
  //                   children: [
  //   if (followup.callResultId != "3" && followup.callResultId != "4")
  //     Row(
  //       children: [
  //         Icon(
  //           Icons.access_time,
  //           size: 12,
  //           color: isLatest
  //               ? Colors.blue.shade400
  //               : Colors.grey.shade500,
  //         ),
  //         const SizedBox(width: 4),
  //         Text(
  //           followup.isNewCall == "Y"
  //               ? 'Created Date: ${followup.scheduledDate}'
  //               : 'Scheduled Date: ${followup.scheduledDate}',
  //           style: TextStyle(
  //             fontSize: 11,
  //             fontWeight: FontWeight.bold,
  //             color: isLatest
  //                 ? Colors.blue.shade600
  //                 : Colors.grey.shade500,
  //             letterSpacing: 0.5,
  //           ),
  //         ),
  //       ],
  //     ),

  //   if (followup.callResultId != "3" &&
  //       followup.callResultId != "4" &&
  //       followup.expectedClosing.isNotEmpty) ...[
  //     const SizedBox(height: 4),
  //     Row(
  //       children: [
  //         Icon(
  //           Icons.event_available,
  //           size: 12,
  //           color: Colors.green.shade600,
  //         ),
  //         const SizedBox(width: 4),
  //         Text(
  //           'Expected Closing Date: ${followup.expectedClosing}',
  //           style: TextStyle(
  //             fontSize: 11,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.green.shade700,
  //           ),
  //         ),
  //       ],
  //     ),
  //   ],
  // ],
  //                   ),
                    const SizedBox(height: 8),

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (followup.callResultId != "3" &&
        followup.callResultId != "4")
      Row(
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: isLatest
                ? Colors.blue.shade400
                : Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              followup.isNewCall == "Y"
                  ? 'Created Date: ${followup.scheduledDate}'
                  : 'Scheduled Date: ${followup.scheduledDate}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isLatest
                    ? Colors.blue.shade600
                    : Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),

    if (followup.callResultId != "3" &&
        followup.callResultId != "4" &&
        (followup.expectedClosing.trim().isNotEmpty) &&
        followup.expectedClosing != "-") ...[
      const SizedBox(height: 4),
      Row(
        children: [
          Icon(
            Icons.event_available,
            size: 12,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Expected Closing Date: ${followup.expectedClosing}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    ],
  ],
),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (followup.calledDate != "" &&
                                followup.calledDate != "-")
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: isLatest
                                    ? Colors.blue.shade400
                                    : Colors.grey.shade500,
                              ),
                            if (followup.calledDate != "" &&
                                followup.calledDate != "-") ...[
                              const SizedBox(width: 4),
                              Text(
                                'Called Date: ${followup.calledDate}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isLatest
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                  shadows: isLatest
                                      ? [
                                          Shadow(
                                            offset: Offset(0, 0.5),
                                            blurRadius: 1,
                                            color: Colors.blue.shade200
                                                .withOpacity(0.5),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    if (followup.callResponse.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Call Status: ${followup.callResponse}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLatest
                              ? Colors.blue.shade600
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        followup.reason.isNotEmpty
                            ? Text(
                                'Tags: ${followup.reason.isNotEmpty ? followup.reason : ""}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLatest
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : SizedBox(),
                        followup.reason.isNotEmpty
                            ? const SizedBox(width: 107)
                            : SizedBox(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isLatest
                                ? Colors.green.shade100
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "F.No : $followupNumber",
                            style: TextStyle(
                              color: isLatest
                                  ? Colors.green.shade700
                                  : Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (followup.productNames.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Products: ${followup.productNames}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLatest
                              ? Colors.blue.shade600
                              : Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    followup.remarks.isNotEmpty
                        ? Text(
                            'Remarks: ${followup.remarks}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isLatest
                                  ? Colors.blue.shade800
                                  : Colors.grey.shade800,
                            ),
                          )
                        : SizedBox(),

                    // Voice Recording Section
                    if ((followup.playVoicePermission == true ||
                            accessCallRecordingPermission == 'true') &&
                        followup.voiceFile.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _showAudioDialog(
                                followup.voiceFile, followup.callDetailsId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isLatest
                                    ? Colors.green.shade100
                                    : Colors.green.shade50,
                                border: Border.all(
                                  color: isLatest
                                      ? Colors.green.shade400
                                      : Colors.green.shade200,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: isLatest
                                        ? Colors.green.shade700
                                        : Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Play',
                                    style: TextStyle(
                                      color: isLatest
                                          ? Colors.green.shade700
                                          : Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                _deleteVoiceDialog(followup.callDetailsId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: isLatest
                                    ? Colors.red.shade100
                                    : Colors.red.shade50,
                                border: Border.all(
                                  color: isLatest
                                      ? Colors.red.shade400
                                      : Colors.red.shade200,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                color:
                                    isLatest ? Colors.red.shade700 : Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildFollowupItem(af.FollowUpDatum followup, int followupNumber) {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: Colors.grey.shade200),
  //         ),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               width: 36,
  //               height: 36,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 color: Colors.white,
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 image: followup.proPicThumb.isNotEmpty
  //                     ? DecorationImage(
  //                         image: NetworkImage(followup.proPicThumb),
  //                         fit: BoxFit.cover,
  //                       )
  //                     : null,
  //               ),
  //               child: followup.proPicThumb.isEmpty
  //                   ? const Icon(Icons.person, size: 20, color: Colors.grey)
  //                   : null,
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           followup.staffName,
  //                           style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                       Row(
  //                         children: [
  //                           if (leadDetailsAdditional!
  //                                       .data.createCustomerInvoice ==
  //                                   true &&
  //                               leadDetailsFollowup!
  //                                       .data.followUpData[0].callResult ==
  //                                   "Closed" &&
  //                               leadDetailsAdditional!.data.isCreateOrder ==
  //                                   true)
  //                             InkWell(
  //                               onTap: () {
  //                                 setState(() {
  //                                   isCreatingOrderOnly = true;
  //                                   createOrder = true;
  //                                   creatingOrderFollowupId =
  //                                       (callMasterId ?? widget.callMasterId);
  //                                   _fetchRenewalDetails();
  //                                 });
  //                               },
  //                               child: const Icon(Icons.add,
  //                                   color: Colors.green, size: 22),
  //                             )
  //                           else if (leadDetails?.data?.callResultId != "4" &&
  //                               leadDetails?.data?.callResult != "Closed" &&
  //                               leadDetailsFollowup!
  //                                       .data.followUpData[0].callResult ==
  //                                   "Closed")
  //                             InkWell(
  //                               onTap: () {
  //                                 Get.to(() => CustomerDashboard(
  //                                       token: widget.token,
  //                                       name: name ?? '',
  //                                       userId: userId ?? '',
  //                                       phoneCallLogPermission:
  //                                           phoneCallLogPermission,
  //                                       custId: leadDetailsAdditional!
  //                                           .data.customerId
  //                                           .toString(),
  //                                     ))?.then((r) {
  //                                   _refreshData(callMasterId ?? widget.callMasterId);
  //                                   widget.onDataChanged();
  //                                 });
  //                               },
  //                               child: const Icon(Icons.menu,
  //                                   color: Colors.green, size: 22),
  //                             ),
  //                           const SizedBox(width: 8),
  //                           if (followup.isEdit == true)
  //                             InkWell(
  //                               onTap: () {
  //                                 Navigator.push(
  //                                     context,
  //                                     MaterialPageRoute(
  //                                         builder: (context) => EditFollowup(
  //                                               widget.token,
  //                                               widget.editLead,
  //                                               widget.deleteLead,
  //                                               widget.cloudCall,
  //                                               (callMasterId ?? widget.callMasterId),
  //                                               followup.callDetailsId
  //                                                   .toString(),
  //                                               pageName: widget.pageName,
  //                                               status: widget.status,
  //                                               staff: widget.staff,
  //                                               isCalled: widget.isCalled,
  //                                               fromDate: widget.fromDate,
  //                                               toDate: widget.toDate,
  //                                               category: widget.category,
  //                                             )))?.then((r) {
  //                                   _refreshData(callMasterId ?? widget.callMasterId);
  //                                   widget.onDataChanged();
  //                                 });
  //                               },
  //                               child: const Icon(
  //                                 Icons.edit,
  //                                 color: Colors.blue,
  //                                 size: 18,
  //                               ),
  //                             ),
  //                           const SizedBox(width: 8),
  //                           if (followup.isDelete == true)
  //                             InkWell(
  //                               onTap: () {
  //                                 _deleteDialog(
  //                                     context, followup.callDetailsId);
  //                               },
  //                               child: const Icon(
  //                                 Icons.delete,
  //                                 color: Colors.red,
  //                                 size: 18,
  //                               ),
  //                             ),
  //                           const SizedBox(width: 8),
  //                           Container(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 8,
  //                               vertical: 2,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               color: _getStatusColor(followup.callResultId),
  //                               borderRadius: BorderRadius.circular(10),
  //                             ),
  //                             child: Text(
  //                               followup.callResult,
  //                               style: const TextStyle(
  //                                 fontSize: 10,
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     followup.remarks,
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       color: Colors.grey.shade800,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     'Reason: ${followup.reason.isNotEmpty ? followup.reason : "Not Added"}',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.grey.shade600,
  //                       fontStyle: FontStyle.italic,
  //                     ),
  //                   ),
  //                   if (followup.callResponse.isNotEmpty) ...[
  //                     const SizedBox(height: 2),
  //                     Text(
  //                       'Call Response: ${followup.callResponse}',
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: Colors.grey.shade600,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ],
  //                   if (followup.productNames.isNotEmpty) ...[
  //                     const SizedBox(height: 2),
  //                     Text(
  //                       'Products: ${followup.productNames}',
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: Colors.grey.shade600,
  //                         fontStyle: FontStyle.italic,
  //                       ),
  //                     ),
  //                   ],

  //                   // Voice Recording Section
  //                   if (followup.playVoicePermission == true &&
  //                       followup.voiceFile.isNotEmpty) ...[
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         InkWell(
  //                           onTap: () => _showAudioDialog(
  //                               followup.voiceFile, followup.callDetailsId),
  //                           child: Container(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 10, vertical: 5),
  //                             decoration: BoxDecoration(
  //                               color: Colors.green.shade50,
  //                               border:
  //                                   Border.all(color: Colors.green.shade200),
  //                               borderRadius: const BorderRadius.only(
  //                                 topLeft: Radius.circular(6),
  //                                 bottomLeft: Radius.circular(6),
  //                               ),
  //                             ),
  //                             child: const Row(
  //                               children: [
  //                                 Icon(Icons.play_arrow,
  //                                     color: Colors.green, size: 18),
  //                                 SizedBox(width: 4),
  //                                 Text('Play',
  //                                     style: TextStyle(
  //                                         color: Colors.green,
  //                                         fontSize: 11,
  //                                         fontWeight: FontWeight.bold)),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                         InkWell(
  //                           onTap: () =>
  //                               _deleteVoiceDialog(followup.callDetailsId),
  //                           child: Container(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 8, vertical: 5),
  //                             decoration: BoxDecoration(
  //                               color: Colors.red.shade50,
  //                               border: Border.all(color: Colors.red.shade200),
  //                               borderRadius: const BorderRadius.only(
  //                                 topRight: Radius.circular(6),
  //                                 bottomRight: Radius.circular(6),
  //                               ),
  //                             ),
  //                             child: const Icon(Icons.close,
  //                                 color: Colors.red, size: 18),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                   //  else if (followup.voiceUploadPermission == true) ...[
  //                   //   const SizedBox(height: 8),
  //                   //   InkWell(
  //                   //     onTap: () => _showRecordDialog(followup.callDetailsId),
  //                   //     child: Container(
  //                   //       padding: const EdgeInsets.symmetric(
  //                   //           horizontal: 10, vertical: 5),
  //                   //       decoration: BoxDecoration(
  //                   //         color: Colors.blue.shade50,
  //                   //         border: Border.all(color: Colors.blue.shade200),
  //                   //         borderRadius: BorderRadius.circular(6),
  //                   //       ),
  //                   //       child: const Row(
  //                   //         mainAxisSize: MainAxisSize.min,
  //                   //         children: [
  //                   //           Icon(Icons.mic,
  //                   //               color: Color(0xFF2a86c9), size: 18),
  //                   //           SizedBox(width: 4),
  //                   //           Text('Record Voice',
  //                   //               style: TextStyle(
  //                   //                   color: Color(0xFF2a86c9),
  //                   //                   fontSize: 11,
  //                   //                   fontWeight: FontWeight.bold)),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //   ),
  //                   // ],

  //                   const SizedBox(height: 8),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Icon(Icons.access_time,
  //                               size: 12, color: Colors.grey.shade500),
  //                           const SizedBox(width: 4),
  //                           Text(
  //                             followup.scheduledDate,
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               color: Colors.grey.shade500,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       Text(
  //                         "F.No : $followupNumber",
  //                         style: const TextStyle(
  //                           color: Colors.green,
  //                           fontSize: 11,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _deleteDialog(BuildContext context, String id, String type) {
    final isLead = type == 'lead';

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirm Deletion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLead
                      ? 'Are you sure you want to delete this lead?'
                      : 'Are you sure you want to delete this follow-up?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be reversed',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Show brief progress
                Common.showProgressDialog(context, "Deleting...");
                await Future.delayed(const Duration(milliseconds: 500));

                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();

                  if (isLead) {
                    _deleteLead(context);
                  } else {
                    _deleteFollowup(context, id);
                  }

                  Common.toastMessaage(
                    'Deleted successfully',
                    Colors.green,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // void _deleteDialog(BuildContext context, String id, String type) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext ctx) {
  //         return AlertDialog(
  //           title: const Text('Please Confirm'),
  //           content: Text(type == 'lead'
  //               ? 'Are you sure to Delete this Lead?'
  //               : 'Are you sure to Delete this Followup?'),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text('No')),
  //             TextButton(
  //                 onPressed: () async {
  //                   Navigator.of(context).pop();
  //                   if (type == 'lead') {
  //                     _deleteLead(context);
  //                   } else {
  //                     _deleteFollowup(context, id);
  //                   }
  //                 },
  //                 child: const Text('Yes')),
  //           ],
  //         );
  //       });
  // }

  Future<void> _deleteLead(BuildContext context) async {
    Common.showProgressDialog(context, "Deleting Lead..");
    DeleteLeadModel delete = await HttpService.deleteLead(
        widget.token, (callMasterId ?? widget.callMasterId));
    if (delete.data == true) {
      Common.toastMessaage(delete.message, Colors.green);
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        Navigator.pop(context); // Close popup
        widget.onDataChanged();
      }
    } else {
      Common.toastMessaage(delete.message, Colors.red);
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
      }
    }
  }

  Future<void> _deleteFollowup(BuildContext context, String followupId) async {
    Common.showProgressDialog(context, "Deleting..");
    DeleteLeadFollowModel delete = await HttpService.deleteLeadFollowup(
        widget.token, followupId, (callMasterId ?? widget.callMasterId));
    if (delete.data == true) {
      Common.toastMessaage(delete.message, Colors.green);
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        _refreshData(callMasterId ?? widget.callMasterId);
        widget.onDataChanged();
      }
    } else {
      Common.toastMessaage(delete.message, Colors.red);
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
      }
    }
  }

  void _showAudioDialog(String voiceFile, String callDetailsId) {
    showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Obx(() {
          return Align(
            alignment: Alignment.bottomCenter,
            child: IntrinsicHeight(
              child: Container(
                width: double.maxFinite,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Material(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            audioCreateController.stopTimer();
                            audioCreateController.audioPlayer.stop();
                            audioCreateController.resetTimer();
                            setState(() => isPlay = false);
                            Get.back();
                          },
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.redAccent,
                        ),
                      ),
                      const Text(
                        'Voice Recording',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isPlay)
                            FloatingActionButton(
                              heroTag: "play voice",
                              onPressed: () {
                                setState(() => isPlay = true);
                                audioCreateController.playVoice(voiceFile);
                              },
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.green, size: 40),
                            )
                          else
                            const SizedBox(),
                          const SizedBox(width: 20),
                          FloatingActionButton(
                            heroTag: "stop voice",
                            onPressed: () {
                              audioCreateController.stopTimer();
                              audioCreateController.audioPlayer.stop();
                              audioCreateController.resetTimer();
                              setState(() => isPlay = false);
                            },
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.stop_rounded,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  void _showRecordDialog(String callDetailsId) {
    showGeneralDialog(
      barrierLabel: "recordDialog",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Obx(() {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: IntrinsicHeight(
              child: Column(
                children: [
                  if (audioCreateController.isRecording.value ||
                      audioCreateController.audioPath.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        if (audioCreateController.isRecording.value)
                          const Text("Recording...",
                              style: TextStyle(color: Colors.red)),
                      ],
                    )
                  else
                    // const Column(
                    //   children: [
                    //     Icon(Icons.mic, size: 48, color: Color(0xFF2a86c9)),
                    //     SizedBox(height: 12),
                    //     Text('Voice Record',
                    //         style: TextStyle(
                    //             fontSize: 18, fontWeight: FontWeight.bold)),
                    //     SizedBox(height: 8),
                    //     Text("Do you want to record voice?"),
                    //   ],
                    // ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Text('Voice Record',
                        //     style: TextStyle(
                        //         fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2a86c9),
                                    Color(0xFF406dbe)
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mic,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  Text('Record',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -5,
                              right: -5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.fiber_manual_record,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Record',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2a86c9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // const Text(
                        //   'Voice Record',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w500,
                        //     color: Colors.black87,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        const Text(
                          "Do you want to record voice?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!audioCreateController.isRecording.value &&
                          audioCreateController.audioPath.isNotEmpty) ...[
                        FloatingActionButton(
                          heroTag: "play recorded",
                          mini: true,
                          onPressed: () {
                            audioCreateController.resetTimer();
                            audioCreateController.playRcording();
                          },
                          backgroundColor: Colors.green,
                          child:
                              const Icon(Icons.play_arrow, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        FloatingActionButton(
                          heroTag: "delete recorded",
                          mini: true,
                          onPressed: () {
                            audioCreateController.resetTimer();
                            audioCreateController.audioPath.value = "";
                          },
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                      ] else if (audioCreateController.isRecording.value)
                        FloatingActionButton(
                          heroTag: "stop recording",
                          onPressed: () {
                            audioCreateController.stopRecording();
                          },
                          backgroundColor: Colors.red,
                          child: const Text("Stop",
                              style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              if (!audioCreateController.isRecording.value)
                TextButton(
                  onPressed: () {
                    audioCreateController.audioPath.value = "";
                    audioCreateController.resetTimer();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
              if (!audioCreateController.isRecording.value &&
                  audioCreateController.audioPath.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    Common.showProgressDialog(context, "Uploading...");
                    final result = await HttpService.leadVoiceUpload(
                      widget.token,
                      (callMasterId ?? widget.callMasterId),
                      callDetailsId,
                      audioCreateController.audioPath.value,
                    );
                    if (context.mounted)
                      Navigator.pop(context); // Close progress

                    if (result.status == true) {
                      audioCreateController.audioPath.value = '';
                      audioCreateController.resetTimer();
                      Common.toastMessaage(result.message, Colors.green);
                      Navigator.pop(context); // Close dialog
                      _refreshData(callMasterId ?? widget.callMasterId);
                    } else {
                      Common.toastMessaage(result.message, Colors.red);
                    }
                  },
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                )
              else if (!audioCreateController.isRecording.value)
                TextButton(
                  onPressed: () {
                    audioCreateController.startRecording();
                  },
                  child: const Text('Record',
                      style: TextStyle(
                          color: Color(0xFF2a86c9),
                          fontWeight: FontWeight.bold)),
                ),
            ],
          );
        });
      },
    );
  }

  void _deleteVoiceDialog(String callDetailsId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to remove this voice recording?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteVoice(callDetailsId);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVoice(String callDetailsId) async {
    Common.showProgressDialog(context, "Deleting...");
    final result = await HttpService.deleteLeadVoice(
      widget.token,
      (callMasterId ?? widget.callMasterId),
      callDetailsId,
    );
    if (context.mounted) Navigator.pop(context); // Close progress

    if (result.status == true) {
      Common.toastMessaage(result.message, Colors.green);
      _refreshData(callMasterId ?? widget.callMasterId);
    } else {
      Common.toastMessaage(result.message, Colors.red);
    }
  }

  void _showReminderDialog(af.FollowUpDatum followup) {
    timeBefore.text = followup.time.toString();
    showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setState) {
          return Align(
            alignment: Alignment.center,
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  width: double.maxFinite,
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Set Reminder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: timeBefore,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 10, top: 2, bottom: 2),
                              labelText: 'Time Before ( Min )',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon:
                                  Icon(Icons.lock_clock, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        if (followup.isReminder == true)
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  Common.showProgressDialog(
                                      context, "Loading..");
                                  UnsetReminderModel unsetReminder =
                                      await HttpService.unsetReminder(
                                          widget.token,
                                          followup.callDetailsId.toString());
                                  if (context.mounted) Navigator.pop(context);

                                  if (unsetReminder.data == true) {
                                    _refreshData(
                                        callMasterId ?? widget.callMasterId);
                                    widget.onDataChanged();
                                  } else {
                                    Common.toastMessaage(
                                        unsetReminder.message, Colors.red);
                                  }
                                },
                                child: const Text(
                                  'Unset Reminder',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 25),
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375e0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () async {
                              if (timeBefore.text.isEmpty ||
                                  timeBefore.text == '0') {
                                Common.toastMessaage('Set Time', Colors.red);
                              } else {
                                Navigator.pop(context);
                                Common.showProgressDialog(context, "Loading..");
                                UpdateReminderSetting updateReminder =
                                    await HttpService.updateReminder(
                                        widget.token,
                                        followup.callDetailsId,
                                        true,
                                        timeBefore.text);
                                if (context.mounted) Navigator.pop(context);

                                if (updateReminder.status == true) {
                                  Common.toastMessaage(
                                      updateReminder.message, Colors.green);
                                  _refreshData(
                                      callMasterId ?? widget.callMasterId);
                                  widget.onDataChanged();
                                } else {
                                  Common.toastMessaage(
                                      updateReminder.message, Colors.red);
                                }
                              }
                            },
                            child: const Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget _buildActivitiesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final latestColor = const Color(0xFF3375e0); // Blue for latest
    final otherColor = Colors.grey; // Grey for others

    if (isActivityLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: latestColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(latestColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Activities...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: latestColor,
              ),
            ),
          ],
        ),
      );
    }

    if (activeMode == null || activeMode!.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: latestColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 48,
                color: latestColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Activities Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Activities will appear here',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: activeMode!.activities.length,
      itemBuilder: (context, index) {
        final activity = activeMode!.activities[index];
        final isLatest = index == 0;
        final isLastItem = index == activeMode!.activities.length - 1;
        final activityColor = isLatest ? latestColor : otherColor;
        final lightColor = activityColor.withOpacity(0.1);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              // Timeline line
              if (!isLastItem)
                Positioned(
                  top: 50,
                  bottom: -16,
                  left: 40,
                  child: Container(
                    width: 2,
                    color: isLatest
                        ? latestColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),

              // Activity card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dot
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activityColor,
                          width: isLatest ? 2 : 1.5,
                        ),
                        image: activity.proPicThumb.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(activity.proPicThumb),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: activity.proPicThumb.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              size: 24,
                              color: activityColor,
                            )
                          : null,
                    ),

                    // Activity content
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: activityColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          activity.staffName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: isLatest
                                                ? latestColor
                                                : (isDark
                                                    ? Colors.white
                                                    : Colors.black87),
                                          ),
                                        ),
                                        // if (isLatest) ...[
                                        //   const SizedBox(width: 8),
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 8,
                                        //       vertical: 4,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: latestColor,
                                        //       borderRadius:
                                        //           BorderRadius.circular(4),
                                        //     ),
                                        //     child: const Text(
                                        //       'LATEST',
                                        //       style: TextStyle(
                                        //         fontSize: 10,
                                        //         fontWeight: FontWeight.w600,
                                        //         color: Colors.white,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ],
                                      ],
                                    ),
                                  ),

                                  // Time badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: lightColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: activityColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getTimeAgo(activity.createdTime),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: activityColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Remark
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: lightColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getActivityIcon(activity.remark),
                                      size: 18,
                                      color: activityColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        activity.remark,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //const SizedBox(height: 12),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //     Icon(
                              //       Icons.calendar_month_rounded,
                              //       size: 12,
                              //       color: activityColor.withOpacity(0.5),
                              //     ),
                              //     const SizedBox(width: 4),
                              //     Text(
                              //       _formatFullDate(activity.createdTime),
                              //       style: TextStyle(
                              //         fontSize: 11,
                              //         color: activityColor.withOpacity(0.7),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      // Adjust this parsing based on your date format
      // Assuming format: YYYY-MM-DD
      if (dateStr.length >= 10) {
        return dateStr.substring(0, 10); // Returns YYYY-MM-DD
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

// Status color mapping
// Color _getStatusColor(String status) {
//   switch(status) {
//     case 'New':
//       return const Color(0xFF2196F3); // Blue
//     case 'Follow Up':
//       return const Color(0xFFFF9800); // Orange
//     case 'Rejected':
//       return const Color(0xFFF44336); // Red
//     case 'Completed':
//       return const Color(0xFF4CAF50); // Green
//     case 'Pending':
//       return const Color(0xFF9C27B0); // Purple
//     default:
//       return const Color(0xFF607D8B); // Blue Grey
//   }
// }
// Helper methods
  String _getTimeAgo(String createdTime) {
    try {
      final date = DateTime.parse(createdTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${difference.inDays ~/ 7}w';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return createdTime;
    }
  }

  String _formatFullDate(String createdTime) {
    try {
      final date = DateTime.parse(createdTime);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdTime;
    }
  }

  IconData _getActivityIcon(String remark) {
    remark = remark.toLowerCase();
    if (remark.contains('call') || remark.contains('phone')) {
      return Icons.call_rounded;
    } else if (remark.contains('meeting') || remark.contains('visit')) {
      return Icons.groups_rounded;
    } else if (remark.contains('email') || remark.contains('mail')) {
      return Icons.email_rounded;
    } else if (remark.contains('task') || remark.contains('todo')) {
      return Icons.task_alt_rounded;
    } else {
      return Icons.comment_rounded;
    }
  }

  // Widget _buildActivitiesTab() {
  //   if (isActivityLoading) {
  //     return const Center(child: CircularProgressIndicator());
  //   }
  //   if (activeMode == null || activeMode!.activities.isEmpty) {
  //     return const Center(
  //       child: Padding(
  //         padding: EdgeInsets.all(32),
  //         child: Text('No activities found'),
  //       ),
  //     );
  //   }
  //   return ListView.builder(
  //     padding: const EdgeInsets.symmetric(vertical: 16),
  //     itemCount: activeMode!.activities.length,
  //     itemBuilder: (context, index) {
  //       final activity = activeMode!.activities[index];
  //       return Stack(
  //         children: [
  //           Positioned(
  //             top: 0,
  //             bottom: 0,
  //             left: 32,
  //             child: Container(
  //               width: 1.0,
  //               color: Colors.grey.shade300,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Container(
  //                   width: 32,
  //                   height: 32,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     color: Colors.white,
  //                     border: Border.all(color: Colors.grey.shade300),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.grey.withOpacity(0.1),
  //                         blurRadius: 2,
  //                         offset: const Offset(0, 1),
  //                       ),
  //                     ],
  //                     image: activity.proPicThumb.isNotEmpty
  //                         ? DecorationImage(
  //                             image: NetworkImage(activity.proPicThumb),
  //                             fit: BoxFit.cover,
  //                           )
  //                         : null,
  //                   ),
  //                   child: activity.proPicThumb.isEmpty
  //                       ? const Icon(Icons.person, size: 18, color: Colors.grey)
  //                       : null,
  //                 ),
  //                 const SizedBox(width: 16),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         activity.staffName,
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         activity.remark,
  //                         style: TextStyle(
  //                           fontSize: 13,
  //                           color: Colors.grey.shade800,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 6),
  //                       Row(
  //                         children: [
  //                           Icon(Icons.calendar_today,
  //                               size: 12, color: Colors.grey.shade500),
  //                           const SizedBox(width: 4),
  //                           Text(
  //                             activity.createdTime,
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               color: Colors.grey.shade500,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildCallHistoryTab() {
    if (isCallHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (callDetailsDataS == null ||
        callDetailsDataS!.data == null ||
        callDetailsDataS!.data!.lists == null ||
        callDetailsDataS!.data!.lists!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No call history found'),
        ),
      );
    }
    return Column(
      children: [
        if (callDetailsDataS?.data?.totalDuration != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Call Duration:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF2a86c9),
                  ),
                ),
                Text(
                  callDetailsDataS!.data!.totalDuration!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF2a86c9),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: callDetailsDataS!.data!.lists!.length,
            itemBuilder: (context, index) {
              final call = callDetailsDataS!.data!.lists![index];
              return _buildCallHistoryItem(call);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallHistoryItem(CallHistoryData call) {
    bool hasRecord = call.resourceUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.call, color: Colors.green.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.direction,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      call.time,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    Text(
                      call.date,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    call.callDurationHr,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: call.status.toLowerCase() == "attended"
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      call.status,
                      style: TextStyle(
                        fontSize: 10,
                        color: call.status.toLowerCase() == "attended"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasRecord) ...[
            const SizedBox(height: 10),
            AudioItems(
              call.direction,
              call.time,
              true,
              call.startTime,
              call.status,
              call.resourceUrl,
              call.callDurationHr,
              (voiceListerningPermission == "true") ||
                  accessCallRecordingPermission == 'true',
              leadDetails?.data?.clientName ?? "",
              leadDetails?.data?.leadCategory ?? "",
              leadDetails?.data?.callResult ?? "",
              call.callHistoryImage,
              widget.fromDate ?? "",
              widget.toDate ?? "",
              widget.editLead,
              widget.deleteLead,
              widget.cloudCall,
              (callMasterId ?? widget.callMasterId),
              widget.token,
              name,
              userId,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (leadDetails == null || leadDetails!.data == null) {
      return const Center(child: Text('No details available'));
    }
    final data = leadDetails!.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailSection('Client Info', [
            _buildDetailRow('Client Name', data.clientName ?? '-'),
            _buildDetailRow('Company Name', data.companyName ?? '-'),
            _buildDetailRow('Phone', data.contactNumber1 ?? '-'),
            _buildDetailRow('WhatsApp Number', data.whatsaAppNumber ?? '-'),
            // _buildDetailRow(
            //     'WhatsApp (', _stripCountryCode(data.whatsaAppNumber)),
            // _buildDetailRow('Country Code', data.countryCode ?? '-'),
            _buildDetailRow('Email', data.emailId ?? '-'),
            _buildDetailRow('Address', data.address ?? '-'),
            //  _buildDetailRow('Products', data.products ?? '-'),
            _buildDetailRow('State', data.stateName ?? '-'),
            _buildDetailRow('District', data.districtName ?? '-'),
            _buildDetailRow('PIN Code', data.pinCode ?? '-'),
            _buildDetailRow('Post Office', data.postOffice ?? '-'),
            // ]),
            // _buildDetailRow('Category', data.leadCategory ?? '-'),
            // _buildDetailRow('Sub Category', data.leadSubCategory ?? '-'),
            // _buildDetailRow('Assigned to', data.staffName ?? '-'),
            // _buildDetailRow('Created date', data.createdDate ?? '-'),
            // _buildDetailRow('Call Result', data.callResult ?? '-'),
            // _buildDetailRow('Cost', data.cost ?? '-'),
            // _buildDetailRow('Source', data.leadSource ?? '-'),
            // _buildDetailRow('Remark', data.remarks ?? '-'),
          ]),
          const SizedBox(height: 16),
          _buildDetailSection('Lead Info', [
            // _buildDetailRow('Client Name', data.clientName ?? '-'),
            // _buildDetailRow('Phone', data.contactNumber1 ?? '-'),
            // _buildDetailRow('WhatsApp Number', data.whatsaAppNumber ?? '-'),
            // // _buildDetailRow(
            // //     'WhatsApp (', _stripCountryCode(data.whatsaAppNumber)),
            // // _buildDetailRow('Country Code', data.countryCode ?? '-'),
            // _buildDetailRow('Email', data.emailId ?? '-'),
            // _buildDetailRow('Address', data.address ?? '-'),
            // //  _buildDetailRow('Products', data.products ?? '-'),
            // _buildDetailRow('State', data.stateName ?? '-'),
            // _buildDetailRow('District', data.districtName ?? '-'),
            // _buildDetailRow('PIN Code', data.pinCode ?? '-'),
            // _buildDetailRow('Post Office', data.postOffice ?? '-'),
            // // ]),
            _buildDetailRow('Created date', data.createdDate ?? '-'),
            _buildDetailRow('Created by', data.createdStaff ?? '-'),
            _buildDetailRow('Lead Source', data.leadSource ?? '-'),
            _buildDetailRow('Lead Stage', data.callResult ?? '-'),
            _buildDetailRow('Product', data.products ?? '-'),
            _buildDetailRow('Cost', '₹ ${data.cost}' ?? '-'),
            _buildDetailRow('Category', data.leadCategory ?? '-'),
            _buildDetailRow('Sub Category', data.leadSubCategory ?? '-'),
            _buildDetailRow('Remark', data.remarks ?? '-'),
            //  _buildDetailRow('Assigned to', data.staffName ?? '-'),

//            _buildDetailRow('Cost', data.cost ?? '-'),

            // _buildDetailRow('Remark', data.remarks ?? '-'),
          ]),
          // const SizedBox(height: 16),
          // if (_selectedProducts.isNotEmpty) ...[
          //   _buildDetailSection(
          //       'Selected Products',
          //       _selectedProducts
          //           .map((p) => _buildDetailRow(p.productName ?? 'Product',
          //               '₹ ${p.totalAmount ?? '0'}'))
          //           .toList()),
          //   const SizedBox(height: 16),
          // ],
          if (leadDetailsAdditional?.data.additionalFields.isNotEmpty ??
              false) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
                'Additional Fields',
                leadDetailsAdditional!.data.additionalFields
                    .map((field) => _buildDetailRow(field.name, field.value))
                    .toList()),
          ],
          if (data.callHandledUsers != null &&
              data.callHandledUsers!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
              'Lead Handled Staff',
              data.callHandledUsers!
                  .map((staff) => _buildStaffCard(staff))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _stripCountryCode(String? whatsapp) {
    if (whatsapp == null || whatsapp.isEmpty) return '-';
    if (whatsapp.startsWith('91') && whatsapp.length > 10) {
      return whatsapp.substring(2);
    }
    return whatsapp;
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2a86c9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(CallHandledUsers staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade100, width: 2),
              image: staff.proPicThumb != null && staff.proPicThumb!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(staff.proPicThumb!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: staff.proPicThumb == null || staff.proPicThumb!.isEmpty
                ? Icon(Icons.person, color: Colors.blue.shade300, size: 30)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.staffName ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2a86c9),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      staff.phoneNo ?? '-',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call_outlined,
                              size: 12, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            "${staff.callCount}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (staff.email != null && staff.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email_outlined,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        staff.email!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(':', style: TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _dialogue(BuildContext context, title) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: const Text(
              'You have no permission to access the feature please contact the support team'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    if (selectedDocumentType == 'none') {
      return _buildDocumentStorageSelection();
    } else if (selectedDocumentType == 'drive') {
      return _buildDriveDocuments();
    } else {
      return _buildS3Documents();
    }
  }

  Widget _buildDocumentStorageSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Storage Provider',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2a86c9),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStorageOption(
                assetPath: 'assets/icons/drive.png',
                label: 'Google Drive',
                colors: [const Color(0xFF4285F4), const Color(0xFF34A853)],
                onTap: () => setState(() => selectedDocumentType = 'drive'),
                isSelected: selectedDocumentType == 'drive',
              ),
              const SizedBox(width: 40),
              _buildStorageOption(
                assetPath: 'assets/icons/cloud2.jpg',
                label: 'S3 Bucket',
                colors: [const Color(0xFF2a86c9), const Color(0xFF406dbe)],
                onTap: () => setState(() => selectedDocumentType = 's3'),
                isSelected: selectedDocumentType == 's3',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageOption({
    required String assetPath,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected ? colors.first : Colors.grey.shade100,
                  width: isSelected ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.12),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.first.withOpacity(0.1),
                        colors.last.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    assetPath,
                    width: 45,
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.first,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriveDocuments() {
    if (selectedDriveAccount == null) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Drive Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2a86c9),
                  ),
                ),
                Row(
                  children: [
                    if (isDriveAccountsLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (!isDriveAccountsLoading)
                      OutlinedButton(
                        onPressed: _addDriveAccount,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          side: BorderSide(
                            color: const Color(0xFF2a86c9),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: Color(0xFF2a86c9),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Add Account",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2a86c9),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: isDriveAccountsLoading
                ? Center(child: CircularProgressIndicator())
                : googleDriveAccounts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text("No Drive Accounts Linked",
                                style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _addDriveAccount,
                              icon: const Icon(Icons.add),
                              label: const Text("Add Account"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2a86c9),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: googleDriveAccounts.length,
                        itemBuilder: (ctx, idx) =>
                            _buildDriveEmailCard(googleDriveAccounts[idx]),
                      ),
          ),
        ],
      );
    }
    // if (selectedDriveAccount == null) {
    //   return Column(
    //     children: [
    //       const SizedBox(height: 20),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 16),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Select Drive Account",
    //               style: TextStyle(
    //                 fontSize: 16,
    //                 fontWeight: FontWeight.bold,
    //                 color: Color(0xFF2a86c9),
    //               ),
    //             ),
    //             if (isDriveAccountsLoading)
    //               SizedBox(
    //                 width: 16,
    //                 height: 16,
    //                 child: CircularProgressIndicator(strokeWidth: 2),
    //               ),
    //           ],
    //         ),
    //       ),
    //       SizedBox(height: 10),
    //       Expanded(
    //         child: isDriveAccountsLoading
    //             ? Center(child: CircularProgressIndicator())
    //             : googleDriveAccounts.isEmpty
    //                 ? Center(
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Icon(Icons.cloud_off_rounded,
    //                             size: 48, color: Colors.grey.shade400),
    //                         const SizedBox(height: 16),
    //                         Text("No Drive Accounts Linked",
    //                             style: TextStyle(color: Colors.grey.shade600)),
    //                       ],
    //                     ),
    //                   )
    //                 : ListView.builder(
    //                     padding: const EdgeInsets.all(16),
    //                     itemCount: googleDriveAccounts.length,
    //                     itemBuilder: (ctx, idx) =>
    //                         _buildDriveEmailCard(googleDriveAccounts[idx]),
    //                   ),
    //       ),
    //     ],
    //   );
    // }

    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _popBreadcrumb,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            driveBreadcrumbs.length == 1 ? 'Exit' : 'Back',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _driveActionIcon(Icons.mic_none_rounded, Colors.red,
                          _showVoiceUploadDialog),
                      const SizedBox(width: 8),
                      _driveActionIcon(Icons.image_outlined, Colors.green,
                          _showImageUploadDialog),
                      const SizedBox(width: 8),
                      _driveActionIcon(Icons.file_upload_outlined, Colors.blue,
                          _showFileUploadDialog),
                      const SizedBox(width: 8),
                      _driveActionIcon(Icons.create_new_folder_outlined,
                          Colors.orange, _showCreateFolderDialogDrive),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDriveBreadcrumbs(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: isDriveFilesLoading
              ? const Center(child: CircularProgressIndicator())
              : googleDriveFiles.isEmpty
                  ? const Center(child: Text("No Files or Folders Found"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: googleDriveFiles.length,
                      itemBuilder: (context, index) =>
                          _buildGoogleDriveFileItem(googleDriveFiles[index]),
                    ),
        ),
      ],
    );
  }

  Widget _driveActionIcon(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20)));

  Widget _buildDriveBreadcrumbs() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: driveBreadcrumbs.asMap().entries.map((e) {
          bool isLast = e.key == driveBreadcrumbs.length - 1;
          return Row(children: [
            GestureDetector(
              onTap: isLast
                  ? null
                  : () {
                      final target = e.value;
                      int index = driveBreadcrumbs.indexWhere(
                          (element) => element['id'] == target['id']);
                      if (index != -1) {
                        setState(() {
                          driveBreadcrumbs =
                              driveBreadcrumbs.sublist(0, index + 1);
                          selectedFolderId =
                              target['id'] == 'root' ? null : target['id'];
                          currentFolderName =
                              target['id'] == 'root' ? null : target['name'];
                        });
                        _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                            parentId: selectedFolderId ?? "");
                      }
                    },
              child: Text(e.value['name']!,
                  style: TextStyle(
                      fontSize: 11,
                      color: isLast ? Colors.blue : Colors.grey.shade600,
                      fontWeight:
                          isLast ? FontWeight.bold : FontWeight.normal)),
            ),
            if (!isLast)
              Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400)
          ]);
        }).toList()));
  }

  Widget _buildDriveEmailCard(DriveAccount account) {
    bool isDefault = account.isActive == "1";
    bool isSelected = selectedDriveAccount?.id == account.id;

    return InkWell(
      onTap: () {
        setState(() {
          selectedDriveAccount = account;
          driveBreadcrumbs = [
            {'id': 'root', 'name': 'Drive'}
          ];
          selectedFolderId = null;
        });
        _fetchGoogleDriveFiles(account.id);
      },
      borderRadius: BorderRadius.circular(20),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF4285F4) : Colors.grey.shade100,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF4285F4).withOpacity(0.12)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4285F4).withOpacity(0.1),
                          const Color(0xFF34A853).withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/email.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.alternate_email_rounded,
                                    color: Color(0xFF4285F4)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                account.accountEmail,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? const Color(0xFF4285F4)
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isDefault)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF34A853),
                                      Color(0xFF43A047)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.verified_user_rounded
                                  : Icons.account_circle_outlined,
                              size: 12,
                              color: isSelected
                                  ? const Color(0xFF34A853)
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSelected
                                  ? 'Selected Account'
                                  : (isDefault
                                      ? 'Primary Drive'
                                      : 'Connected Account'),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: isSelected
                          ? const Color(0xFF4285F4)
                          : Colors.grey.shade300,
                      size: 24),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF34A853),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleDriveFileItem(GoogleDriveFile file) {
    String extension = file.fileName.split('.').last.toLowerCase();
    IconData icon;
    Color iconColor;

    switch (extension) {
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        iconColor = Colors.red.shade600;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description_rounded;
        iconColor = Colors.blue.shade600;
        break;
      case 'xls':
      case 'xlsx':
        icon = Icons.table_chart_rounded;
        iconColor = Colors.green.shade600;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        icon = Icons.image_rounded;
        iconColor = Colors.purple.shade600;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        iconColor = Colors.orange.shade600;
    }

    return InkWell(
      onTap: () {
        if (file.isFolder == 'Y') {
          log("Entering folder: ${file.fileName} (${file.fileId ?? file.id})");
          _updateBreadcrumbs(file.fileId ?? file.id, file.fileName);
          setState(() {
            selectedFolderId = file.fileId ?? file.id;
            currentFolderName = file.fileName;
          });
          _fetchGoogleDriveFiles(selectedDriveAccount!.id,
              parentId: file.fileId ?? file.id);
        } else {
          _viewGoogleDriveFile(file);
        }
      },
      onLongPress: () {
        _showDriveFileOptions(file);
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: file.isFolder == 'Y'
                  ? Colors.blue.withOpacity(0.1)
                  : iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(file.isFolder == 'Y' ? Icons.folder_rounded : icon,
                color: file.isFolder == 'Y' ? Colors.blue : iconColor,
                size: 30),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              file.fileName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDriveFileOptions(GoogleDriveFile file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: file.isFolder == 'Y'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        file.isFolder == 'Y'
                            ? Icons.folder_rounded
                            : Icons.insert_drive_file_rounded,
                        color: file.isFolder == 'Y' ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        file.fileName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                title: const Text('Rename',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDriveFileDialog(file);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text('Delete',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDriveFileConfirm(file);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDriveFileDialog(GoogleDriveFile file) {
    final renameCtrl = TextEditingController(text: file.fileName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rename Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter a new name for the item. Make sure to include the file extension if applicable.',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: renameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'New name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarStart,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final newName = renameCtrl.text.trim();
                if (newName.isNotEmpty && newName != file.fileName) {
                  Navigator.pop(context);
                  _renameDriveFile(file.fileId ?? file.id, newName);
                } else {
                  Navigator.pop(context);
                }
              },
              child:
                  const Text('Rename', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameDriveFile(String fileId, String newName) async {
    Common.showProgressDialog(context, "Renaming...");
    try {
      final res =
          await HttpService.renameGoogleDriveFilesndFolders(fileId, newName);
      if (mounted) Navigator.pop(context);
      if (res != null && res.status == true) {
        Common.toastMessaage(
            res.message ?? "Renamed successfully", Colors.green);
        _fetchGoogleDriveFiles(selectedDriveAccount!.id,
            parentId: selectedFolderId ?? "");
      } else {
        Common.toastMessaage(res?.message ?? "Failed to rename", Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  void _showDeleteDriveFileConfirm(GoogleDriveFile file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${file.fileName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _deleteDriveFile(file.fileId ?? file.id);
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDriveFile(String fileId) async {
    Common.showProgressDialog(context, "Deleting...");
    try {
      final res = await HttpService.deleteGoogleDriveFilesndFolders(
          fileId, selectedDriveAccount!.id);
      if (mounted) Navigator.pop(context);
      if (res != null && res.status == true) {
        Common.toastMessaage(
            res.message ?? "Deleted successfully", Colors.green);
        _fetchGoogleDriveFiles(selectedDriveAccount!.id,
            parentId: selectedFolderId ?? "");
      } else {
        Common.toastMessaage(res?.message ?? "Failed to delete", Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  void _showCreateFolderDialogDrive() {
    final folderNameCtrl = TextEditingController();
    showGeneralDialog(
      barrierLabel: "showGeneralDialogDrive",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        bool isCreatingFolder = false;
        return StatefulBuilder(builder: (context, setDialogState) {
          return Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        selectedFolderId == null
                            ? 'New Drive Folder'
                            : 'New Folder',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: folderNameCtrl,
                      autofocus: true,
                      enabled: !isCreatingFolder,
                      decoration: InputDecoration(
                        hintText: "Folder Name",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isCreatingFolder
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isCreatingFolder
                                ? null
                                : () async {
                                    if (folderNameCtrl.text.isEmpty) {
                                      Common.toastMessaage(
                                          'Enter folder name', Colors.red);
                                      return;
                                    }

                                    setDialogState(() {
                                      isCreatingFolder = true;
                                    });

                                    final res =
                                        await HttpService.createGoogleFolders(
                                      (callMasterId ?? widget.callMasterId),
                                      selectedDriveAccount!.id,
                                      selectedFolderId ?? "",
                                      folderNameCtrl.text,
                                    );

                                    if (res != null && res.status) {
                                      Common.toastMessaage(
                                          'Drive Folder Created Successfully',
                                          Colors.green);

                                      // Optionally auto-enter the new folder (if API returns the new ID)
                                      // For now we refresh the current level and user clicks to enter.
                                      _fetchGoogleDriveFiles(
                                          selectedDriveAccount!.id,
                                          parentId: selectedFolderId ?? "");
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    } else {
                                      setDialogState(() {
                                        isCreatingFolder = false;
                                      });
                                      Common.toastMessaage(
                                          res?.message ??
                                              'Failed to create folder',
                                          Colors.red);
                                    }
                                  },
                            child: isCreatingFolder
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Create',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildS3Breadcrumbs() {
    final parts = listPath.split('/').where((e) => e.isNotEmpty).toList();
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          const Text("S3 ",
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          ...parts.map((p) => Row(children: [
                const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                GestureDetector(
                  onTap: () {
                    int pIdx = listPath.indexOf(p);
                    if (pIdx != -1) {
                      String newPath = listPath.substring(0, pIdx + p.length);
                      String newBack = "";
                      if (newPath.contains('/')) {
                        newBack =
                            newPath.substring(0, newPath.lastIndexOf('/'));
                      }
                      setState(() {
                        path = "$newPath/";
                        listPath = newPath;
                        backPath = newBack;
                      });
                      listFolderList(widget.token,
                          (callMasterId ?? widget.callMasterId), listPath);
                    }
                  },
                  child: Text(p,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500)),
                )
              ])),
        ]));
  }

  Widget _buildS3Documents() {
    if (listFolder == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (listPath.isNotEmpty)
                InkWell(
                  onTap: () {
                    setState(() {
                      bool checkString = backPath.contains('/');
                      if (checkString) {
                        backPath =
                            backPath.substring(0, backPath.lastIndexOf('/'));
                        path = '$backPath/';
                      } else {
                        backPath = '';
                        path = '';
                      }
                      listPath = backPath;
                      folderActionEnable = false;
                      selectedRawIndex = '';
                      listFolderList(widget.token, callMasterId, backPath);
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedDocumentType = 'none';
                      listPath = '';
                      backPath = '';
                      path = '';
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Exit S3',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _driveActionIcon(Icons.mic_none_rounded, Colors.red,
                        _showVoiceUploadDialog),
                    const SizedBox(width: 8),
                    _driveActionIcon(Icons.image_outlined, Colors.green,
                        _showImageUploadDialog),
                    const SizedBox(width: 8),
                    _driveActionIcon(Icons.file_upload_outlined, Colors.blue,
                        _showFileUploadDialog),
                    const SizedBox(width: 8),
                    _driveActionIcon(
                        Icons.create_new_folder_outlined, Colors.orange, () {
                      if (fileManagerPermission?.data?.createFile == true) {
                        _showCreateFolderDialog();
                      } else {
                        _dialogue(context, 'Create Folder');
                      }
                    }),
                    if (folderActionEnable) ...[
                      const SizedBox(width: 8),
                      _driveActionIcon(Icons.edit_outlined, Colors.blue, () {
                        _showRenameFolderDialog();
                      }),
                      const SizedBox(width: 8),
                      _driveActionIcon(Icons.delete_outline_rounded, Colors.red,
                          () {
                        _showDeleteConfirmDialog();
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildS3Breadcrumbs(),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Builder(builder: (context) {
            final folderData = listFolder?.data ?? [];
            if (folderData.isEmpty) {
              return const Center(child: Text('No documents found'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: folderData.length,
              itemBuilder: (context, index) {
                final item = folderData[index];
                bool isSelected = selectedRawIndex == index.toString();

                return InkWell(
                  onLongPress: () {
                    setState(() {
                      deletePath = '${item.path}';
                      folderActionEnable = true;
                      rawId = item.id.toString();
                      selectedRawIndex = index.toString();
                      editableName = item.name.toString();
                      fileNameEdit.text = editableName;
                    });
                  },
                  onTap: () {
                    if (fileManagerPermission?.data?.openFile == true) {
                      setState(() {
                        folderActionEnable = false;
                        rawId = '';
                        selectedRawIndex = '';
                      });

                      if (item.isFolder == 'Y') {
                        setState(() {
                          backPath = '${item.path}';
                          path = '${item.path}/';
                          listPath = '${item.path}';
                        });
                        listFolderList(widget.token, callMasterId, listPath);
                      } else {
                        _viewDocument(item);
                      }
                    } else {
                      _dialogue(context, 'Open Folder');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2a86c9)
                            : Colors.grey.shade100,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF2a86c9).withOpacity(0.1)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getFileIcon(item),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            item.name ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF2a86c9)
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showCreateFolderDialog() {
    showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('New Folder',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: folderName,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Folder Name",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (folderName.text.isEmpty) {
                                Common.toastMessaage(
                                    'Enter Folder name', Colors.red);
                              } else {
                                final res = await HttpService.createFolder(
                                    widget.token,
                                    callMasterId,
                                    '$path${folderName.text}');
                                if (res.data == true) {
                                  listFolderList(
                                      widget.token, callMasterId, listPath);
                                  folderName.text = '';
                                  if (mounted) Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('Create',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  void _showRenameFolderDialog() {
    showGeneralDialog(
      barrierLabel: "showRenameDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rename Folder',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: fileNameEdit,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Folder Name",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (fileNameEdit.text.isEmpty) {
                                Common.toastMessaage(
                                    'Enter Folder name', Colors.red);
                              } else {
                                final res = await HttpService.renameFolder(
                                  widget.token,
                                  callMasterId,
                                  listPath,
                                  editableName,
                                  fileNameEdit.text,
                                  rawId,
                                );
                                if (res.data == true) {
                                  setState(() {
                                    folderActionEnable = false;
                                    selectedRawIndex = '';
                                  });
                                  listFolderList(
                                      widget.token, callMasterId, listPath);
                                  if (mounted) Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('Rename',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: const Text('Are you sure you want to delete this folder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                final res = await HttpService.deleteLeadFolderAndFiles(
                    widget.token, callMasterId, deletePath, rawId);
                if (res.data == true) {
                  setState(() {
                    folderActionEnable = false;
                    selectedRawIndex = '';
                  });
                  listFolderList(widget.token, callMasterId, listPath);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _viewDocument(dynamic item) {
    String ext = (item.extension ?? '').toLowerCase();
    if (['m4a', 'wav', 'mp3'].contains(ext)) {
      _showAudioPlayerSimple(item.name ?? 'Audio', item.path);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentViewerScreen(
            documentUrl: item.path.toString(),
            title: item.name.toString(),
            extension: item.extension.toString(),
            fileSize: item.fileSize ?? 'N/A',
            createdDate: item.createdAt ?? '',
            createdBy: item.createdBy ?? '',
          ),
        ),
      );
    }
  }

  void _showVoiceUploadDialog() {
    audioCreateController.audioPath.value = "";
    audioCreateController.resetTimer();
    fileName.text = '';
    showGeneralDialog(
      barrierLabel: "VoiceUpload",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Obx(() {
          return AlertDialog(
            content: IntrinsicHeight(
              child: Column(
                children: [
                  if (audioCreateController.isRecording.value ||
                      audioCreateController.audioPath.isNotEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 30),
                        ),
                        if (audioCreateController.isRecording.value)
                          const Text("Voice Recording..."),
                      ],
                    )
                  else
                    // const Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     SizedBox(height: 10),
                    //     Text('Voice Record', style: TextStyle(fontSize: 18)),
                    //     SizedBox(height: 20),
                    //     Text("Do you want to record voice?"),
                    //   ],
                    // ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2a86c9),
                                    Color(0xFF406dbe)
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mic,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: -5,
                              right: -5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.fiber_manual_record,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Record',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2a86c9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // const Text(
                        //   'Voice Record',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w500,
                        //     color: Colors.black87,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        const Text(
                          "Do you want to record voice?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!audioCreateController.isRecording.value &&
                          audioCreateController.audioPath.isNotEmpty)
                        FloatingActionButton(
                          heroTag: "play_new",
                          onPressed: () {
                            audioCreateController.resetTimer();
                            audioCreateController.playRcording();
                          },
                          mini: true,
                          child: const Icon(Icons.play_arrow),
                        ),
                      const SizedBox(width: 20),
                      if (audioCreateController.isRecording.value)
                        FloatingActionButton(
                          heroTag: "stop_new",
                          onPressed: () =>
                              audioCreateController.stopRecording(),
                          backgroundColor: Colors.red,
                          mini: true,
                          child: const Icon(Icons.stop),
                        )
                      else if (audioCreateController.audioPath.isEmpty)
                        FloatingActionButton(
                          heroTag: "start_new",
                          onPressed: () =>
                              audioCreateController.startRecording(),
                          backgroundColor: const Color(0xFF2a86c9),
                          mini: true,
                          child: const Icon(Icons.mic),
                        ),
                      const SizedBox(width: 20),
                      if (!audioCreateController.isRecording.value &&
                          audioCreateController.audioPath.isNotEmpty)
                        FloatingActionButton(
                          heroTag: "delete_new",
                          onPressed: () {
                            audioCreateController.audioPath.value = "";
                            audioCreateController.resetTimer();
                          },
                          backgroundColor: Colors.red,
                          mini: true,
                          child: const Icon(Icons.delete),
                        ),
                    ],
                  ),
                  if (!audioCreateController.isRecording.value &&
                      audioCreateController.audioPath.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: fileName,
                      decoration: const InputDecoration(
                        labelText: 'Voice Name',
                        hintText: 'Enter name for this recording',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  audioCreateController.stopRecording();
                  audioCreateController.resetTimer();
                  audioCreateController.audioPath.value = "";
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
              if (audioCreateController.audioPath.isNotEmpty &&
                  !audioCreateController.isRecording.value)
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (fileName.text.isEmpty) {
                            Common.toastMessaage(
                                "Please enter a name for the voice record",
                                Colors.red);
                            return;
                          }
                          setState(() => isUploading = true);
                          Common.showProgressDialog(context, "Uploading...");
                          try {
                            String fileNameStr = "${fileName.text}.mp3";

                            if (selectedDocumentType == 'drive') {
                              var res = await HttpService.uploadGoogleFiles(
                                (callMasterId ?? widget.callMasterId),
                                selectedDriveAccount!.id,
                                selectedFolderId ?? "",
                                audioCreateController.audioPath.value,
                                customFileName: fileNameStr,
                              );
                              if (context.mounted)
                                Navigator.pop(context); // Close progress
                              if (res != null && res.status) {
                                Common.toastMessaage(res.message, Colors.green);
                                _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                                    parentId: selectedFolderId ?? "");
                                if (context.mounted)
                                  Navigator.pop(context); // Close Dialog
                              } else {
                                Common.toastMessaage(
                                    res?.message ?? "Failed", Colors.red);
                              }
                            } else {
                              UploadAudioRecord res =
                                  await HttpService.uploadRecord(
                                widget.token,
                                (callMasterId ?? widget.callMasterId),
                                listPath,
                                audioCreateController.audioPath.value,
                                fileNameStr,
                              );
                              if (context.mounted)
                                Navigator.pop(context); // Close progress
                              if (res.data == true) {
                                Common.toastMessaage(
                                    res.message ?? "Success", Colors.green);
                                listFolderList(
                                    widget.token,
                                    (callMasterId ?? widget.callMasterId),
                                    listPath);
                                if (context.mounted)
                                  Navigator.pop(context); // Close Dialog
                              } else {
                                Common.toastMessaage(
                                    res.message ?? "Failed", Colors.red);
                              }
                            }
                          } finally {
                            setState(() => isUploading = false);
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Upload'),
                ),
            ],
          );
        });
      },
    );
  }

  void _showImageUploadDialog() {
    imageUploadController.file.value = '';
    fileName.text = '';
    showGeneralDialog(
      barrierLabel: "ImageUpload",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Obx(() {
          return AlertDialog(
            title: const Text('Upload Image'),
            content: IntrinsicHeight(
              child: Column(
                children: [
                  if (imageUploadController.file.value.isEmpty)
                    const Text("Do you want to upload image?")
                  else
                    Column(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(
                                  File(imageUploadController.file.value)),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              imageUploadController.file.value = '',
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: fileName,
                          decoration: const InputDecoration(
                            labelText: 'File Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              if (imageUploadController.file.value.isEmpty)
                TextButton(
                  onPressed: () async {
                    Get.bottomSheet(
                      Container(
                        color: Colors.white,
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Gallery'),
                              onTap: () async {
                                Get.back();
                                imageUploadController
                                    .takePhoto(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Camera'),
                              onTap: () async {
                                Get.back();
                                imageUploadController
                                    .takePhoto(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Choose'),
                )
              else
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          setState(() => isUploading = true);
                          Common.showProgressDialog(context, "Uploading...");
                          try {
                            String name = fileName.text.isNotEmpty
                                ? fileName.text +
                                    p.extension(
                                        imageUploadController.file.value)
                                : p.basename(imageUploadController.file.value);

                            if (selectedDocumentType == 'drive') {
                              var res = await HttpService.uploadGoogleFiles(
                                (callMasterId ?? widget.callMasterId),
                                selectedDriveAccount!.id,
                                selectedFolderId ?? "",
                                imageUploadController.file.value,
                                customFileName: name,
                              );
                              if (context.mounted) Navigator.pop(context);
                              if (res != null && res.status) {
                                Common.toastMessaage(res.message, Colors.green);
                                _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                                    parentId: selectedFolderId ?? "");
                                if (context.mounted) Navigator.pop(context);
                              } else {
                                Common.toastMessaage(
                                    res?.message ?? "Failed", Colors.red);
                              }
                            } else {
                              UploadAudioRecord res =
                                  await HttpService.uploadRecord(
                                widget.token,
                                (callMasterId ?? widget.callMasterId),
                                listPath,
                                imageUploadController.file.value,
                                name,
                              );
                              if (context.mounted) Navigator.pop(context);
                              if (res.data == true) {
                                Common.toastMessaage(
                                    res.message ?? "Success", Colors.green);
                                listFolderList(
                                    widget.token,
                                    (callMasterId ?? widget.callMasterId),
                                    listPath);
                                if (context.mounted) Navigator.pop(context);
                              } else {
                                Common.toastMessaage(
                                    res.message ?? "Failed", Colors.red);
                              }
                            }
                          } finally {
                            setState(() => isUploading = false);
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Upload'),
                ),
            ],
          );
        });
      },
    );
  }

  void _showFileUploadDialog() {
    isFile = false;
    file = null;
    showGeneralDialog(
      barrierLabel: "FileUpload",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Upload Document'),
            content: IntrinsicHeight(
              child: Column(
                children: [
                  if (isFile)
                    Column(
                      children: [
                        const Icon(Icons.insert_drive_file,
                            size: 50, color: Colors.blue),
                        const SizedBox(height: 10),
                        Text(file?.name ?? ""),
                      ],
                    )
                  else
                    const Text("Do you want to upload a document?"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              if (!isFile)
                TextButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: [
                        'pdf',
                        'doc',
                        'docx',
                        'xls',
                        'xlsx',
                        'txt'
                      ],
                    );
                    if (result != null) {
                      setDialogState(() {
                        isFile = true;
                        file = result.files.first;
                      });
                    }
                  },
                  child: const Text('Choose File'),
                )
              else
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          setState(() => isUploading = true);
                          Common.showProgressDialog(context, "Uploading...");
                          try {
                            if (selectedDocumentType == 'drive') {
                              var res = await HttpService.uploadGoogleFiles(
                                (callMasterId ?? widget.callMasterId),
                                selectedDriveAccount!.id,
                                selectedFolderId ?? "",
                                file!.path!,
                              );
                              if (context.mounted) Navigator.pop(context);
                              if (res != null && res.status) {
                                Common.toastMessaage(res.message, Colors.green);
                                _fetchGoogleDriveFiles(selectedDriveAccount!.id,
                                    parentId: selectedFolderId ?? "");
                                if (context.mounted) Navigator.pop(context);
                              } else {
                                Common.toastMessaage(
                                    res?.message ?? "Failed", Colors.red);
                              }
                            } else {
                              UploadAudioRecord res =
                                  await HttpService.uploadRecord(
                                widget.token,
                                (callMasterId ?? widget.callMasterId),
                                listPath,
                                file!.path!,
                                file!.name,
                              );
                              if (context.mounted) Navigator.pop(context);
                              if (res.data == true) {
                                Common.toastMessaage(
                                    res.message ?? "Success", Colors.green);
                                listFolderList(
                                    widget.token,
                                    (callMasterId ?? widget.callMasterId),
                                    listPath);
                                if (context.mounted) Navigator.pop(context);
                              } else {
                                Common.toastMessaage(
                                    res.message ?? "Failed", Colors.red);
                              }
                            }
                          } finally {
                            setState(() => isUploading = false);
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Upload'),
                ),
            ],
          );
        });
      },
    );
  }

  Widget _getFileIcon(dynamic item) {
    if (item.isFolder == 'Y') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.folder_rounded, size: 28, color: Colors.blue),
      );
    }

    String ext = (item.extension ?? '').toLowerCase();
    IconData icon;
    Color color;

    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      icon = Icons.image_rounded;
      color = Colors.purple;
    } else if (ext == 'pdf') {
      icon = Icons.picture_as_pdf_rounded;
      color = Colors.red;
    } else if (['m4a', 'wav', 'mp3'].contains(ext)) {
      icon = Icons.audiotrack_rounded;
      color = Colors.orange;
    } else if (['doc', 'docx'].contains(ext)) {
      icon = Icons.description_rounded;
      color = Colors.blue;
    } else if (['xls', 'xlsx'].contains(ext)) {
      icon = Icons.table_chart_rounded;
      color = Colors.green;
    } else {
      icon = Icons.insert_drive_file_rounded;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28, color: color),
    );
  }

  Widget _buildMilestonesTab() {
    if (mileStone == null || mileStone!.data!.leadMilestones!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No milestones found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: mileStone!.data!.leadMilestones!.length,
      itemBuilder: (BuildContext context, int index) {
        final milestone = mileStone!.data!.leadMilestones![index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  milestone.milestone ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2a86c9),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildMilestoneDetail('Date', milestone.dateTime ?? '-'),
                    _buildMilestoneDetail('Remarks', milestone.remarks ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(':', style: TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusId) {
    if (statusId == null) return const Color(0xFF2196F3);
    String s = statusId.toLowerCase();
    switch (s) {
      case '1':
        return const Color(0xFF2196F3);
      case '2':
        return const Color(0xFFFFC107);
      case '3':
        return const Color.fromARGB(255, 255, 7, 7);
      case '4':
        return const Color(0xFF4CAF50);
      case '5':
        return const Color(0xFF9C27B0);
      case '6':
         return const Color(0xFF9C27B0);
      case '7':
        return const Color(0xFF2196F3);
      case '8':
        return const Color(0xFF1B5E20);
      case '9':
        return const Color(0xFFFF6F00);
      case '10':
        return const Color(0xFFD32F2F);
      case '11':
        return const Color(0xFF1B5E20);
      case '12':
        return const Color(0xFF3F51B5);
    }

    if (s.contains('new')) return const Color(0xFF2196F3);
    if (s.contains('follow up') || s.contains('followup')) {
      return const Color(0xFFFFC107);
    }
    if (s.contains('rejected')) return const Color(0xFFF44336);
    if (s.contains('completed')) return const Color(0xFF4CAF50);
    if (s.contains('pending')) return const Color(0xFF9C27B0);
    if (s.contains('not responding')) return const Color(0xFFF12F2F);

    return const Color(0xFF2a86c9);
  }

  void _handleCallAction() async {
    if (leadDetails!.data!.callPermission == false) {
      _showCallPermissionDialog();
      return;
    }

    if (widget.cloudCall) {
      _showCallTypeDialog();
    } else {
      Common.dialPad(leadDetails!.data!.contactNumber1.toString());
    }
  }

  void _showCallTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Choose Call Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud, color: Colors.blue),
                title: const Text('Cloud Call'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  Common.showProgressDialog(context, "Loading..");

                  final result = await HttpService.addCloudCall(
                    widget.token,
                    (callMasterId ?? widget.callMasterId),
                    leadDetails!.data!.contactNumber1,
                  );
                  if (context.mounted) {
                  //  Navigator.pop(context);
                    if (result != null && result.data == true) {
                      Common.toastMessaage(result.message, Colors.green);
                      Navigator.pop(context);
                    } else {
                      Common.toastMessaage(result?.message ?? "Failed to initiate call", Colors.red);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Phone Call'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  Common.dialPad(leadDetails!.data!.contactNumber1.toString());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCallPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: Text(leadDetails!.data!.warningMessage.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFollowup(
                      widget.token,
                      widget.editLead,
                      widget.deleteLead,
                      widget.cloudCall,
                      leadDetails!.data!.callLeadId.toString(),
                      pageName: widget.pageName,
                      status: widget.status,
                      staff: widget.staff,
                      isCalled: widget.isCalled,
                      fromDate: widget.fromDate,
                      toDate: widget.toDate,
                      category: widget.category,
                      leadType1: widget.leadType,
                    ),
                  ),
                ).then((_) {
                  widget.onDataChanged();
                  _refreshData(callMasterId ?? widget.callMasterId);
                });
              },
              child: const Text('Followup'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog() {
    TextEditingController remarkController = TextEditingController();
    String? selectedStaff;
    int transferFresh = 0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: appBarStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.swap_horiz_rounded,
                                color: appBarStart, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transfer Lead',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                'Reassign this lead to another staff',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "SELECT TARGET STAFF",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dropdown Replacement / Themed Selection
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Choose staff member",
                                style: TextStyle(fontSize: 14)),
                            value: selectedStaff,
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey.shade400),
                            items:
                                commonDetails?.data.transferStaffs.map((staff) {
                              return DropdownMenuItem<String>(
                                value: staff.tranStaffId,
                                child: Text(
                                  staff.tranStaffName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedStaff = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Remark Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "REMARKS (OPTIONAL)",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Remark Field
                      TextField(
                        controller: remarkController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Add a note for the new owner...",
                          hintStyle: TextStyle(
                              fontSize: 13, color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: appBarStart.withOpacity(0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Fresh Data Toggle (Radio style) - Hidden as per request
                      Visibility(
                        visible: showTransferFreshValue,
                        child: InkWell(
                          onTap: () {
                            setDialogState(() {
                              transferFresh = transferFresh == 1 ? 0 : 1;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: transferFresh == 1
                                  ? appBarStart.withOpacity(0.04)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: transferFresh == 1
                                    ? appBarStart.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: transferFresh == 1
                                          ? appBarStart
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: transferFresh == 1
                                            ? appBarStart
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Transfer as Fresh Data",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: textSecondary,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: appBarStart.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (selectedStaff == null) {
                                    Common.toastMessaage(
                                        'Please select staff', Colors.red);
                                    return;
                                  }
                                  // 1. Capture the stable screen context
                                  final screenContext = context;

                                  // 2. Close the transfer selection dialog first
                                  Navigator.pop(dialogContext);

                                  // 3. Show progress using the stable screen context
                                  Common.showProgressDialog(
                                      screenContext, "Transferring...");

                                  LeadTransferModel? result =
                                      await HttpService.leadTransfer(
                                    widget.token,
                                    (callMasterId ?? widget.callMasterId),
                                    selectedStaff!,
                                    remarkController.text,
                                    transferFresh,
                                  );

                                  if (screenContext.mounted) {
                                    // 4. Pop the progress dialog
                                    Navigator.of(screenContext,
                                            rootNavigator: true)
                                        .pop();

                                    if (result == null) {
                                      Common.toastMessaage(
                                          'Failed to connect to server',
                                          Colors.red);
                                      return;
                                    }

                                    // Check for success across various formats
                                    bool isSuccess = result.status == true ||
                                        result.data == true;

                                    if (isSuccess) {
                                      Common.toastMessaage(
                                          result.message ??
                                              'Lead Transferred successfully',
                                          Colors.green);

                                      if (widget.onDataChanged != null) {
                                        widget.onDataChanged();
                                      }

                                      // Close the main details popup
                                      if (Navigator.canPop(screenContext)) {
                                        Navigator.pop(screenContext);
                                      }
                                    } else {
                                      Common.toastMessaage(
                                          result.message ?? 'Transfer failed',
                                          Colors.red);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appBarStart,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPermissionDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: Text(
            'You have no permission to access $feature. Please contact the support team.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> createOrderDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text(
                "CONFIRM",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Would you like to proceed without adding a sale?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                postFollowup();
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Object?> addProductsDialog(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox()
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        productDialog(context, "add");
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    productName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              productCalculation();
                            },
                            controller: productRate,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Rate',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              productCalculation();
                            },
                            controller: productQty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Qty',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              productCalculation();
                            },
                            controller: productTaxPercent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Percent',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: productTaxAmount,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Amount',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      child: TextFormField(
                        controller: productTotalAmount,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Total Amount',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (productName == "Choose Product") {
                              Common.toastMessaage('Add a product', Colors.red);
                            } else if (productRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (productQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (productTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (double.parse(productTaxPercent.text) >
                                    100 ||
                                double.parse(productTaxPercent.text) < 0) {
                              Common.toastMessaage(
                                  'Enter valid tax percentage', Colors.red);
                            } else {
                              products.add({
                                "product_name": productName,
                                "product_id": productId,
                                "description": productDescription.text,
                                "product_rate": productRate.text,
                                "quantity": productQty.text,
                                "tax_percent": productTaxPercent.text,
                                "total_tax_amount": productTaxAmount.text,
                                "total_amount": productTotalAmount.text,
                              });
                              renProducts.add({
                                "product_name": productName,
                                "product_id": productId,
                                "description": productDescription.text,
                                "product_rate": productRate.text,
                                "quantity": productQty.text,
                                "tax_percent": productTaxPercent.text,
                                "total_tax_amount": productTaxAmount.text,
                                "total_amount": productTotalAmount.text,
                              });

                              subTotal += double.parse(
                                      productTotalAmountTotal.text.isEmpty
                                          ? "0"
                                          : productTotalAmountTotal.text) *
                                  double.parse(productQty.text);
                              subTotalGrand +=
                                  double.parse(productTotalAmount.text);
                              totalTaxAmount +=
                                  double.parse(productTaxAmount.text) *
                                      double.parse(productQty.text);
                              allTotal = subTotalGrand +
                                  double.parse(shippingCharge.text == ''
                                      ? '0'
                                      : shippingCharge.text) -
                                  double.parse(discount.text == ''
                                      ? '0'
                                      : discount.text);
                              if (paymentStatus == 'paid') {
                                paidAmount.text = allTotal.toStringAsFixed(2);
                              } else if (paymentStatus == 'unpaid') {
                                paidAmount.text = '0.00';
                              } else if (paymentStatus == 'partial') {
                                // Keep current paidAmount or update it?
                                // Usually for partial, user enters it manually, but we can set it to 0 if empty
                                if (paidAmount.text.isEmpty)
                                  paidAmount.text = '0.00';
                              }

                              productName = "Choose Product";
                              productId = "";
                              productDescription.clear();
                              productRate.clear();
                              productQty.clear();
                              productTaxPercent.clear();
                              productTaxAmount.clear();
                              productTotalAmount.clear();

                              if (typeDuration.isNotEmpty) {
                                final endValue = DateTime.now().add(
                                    Duration(days: int.parse(typeDuration)));
                                endDate.text =
                                    DateFormat('dd-MM-yyyy').format(endValue);
                              }
                              Navigator.of(context).pop();
                              this.setState(() {});
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 25, right: 25),
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Future<dynamic> productDialog(BuildContext context, String type) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Icon(Icons.close)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (value) {
                          setState(() {
                            filteredProducts = productsList
                                .where((item) => item.productName
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFFCFBFA)),
                          child: ListTile(
                            onTap: () {
                              if (type == "add") {
                                if (productQty.text == "") {
                                  productQty.text = "1";
                                }
                                productName =
                                    filteredProducts[index].productName;
                                productId = filteredProducts[index].id;
                                productRate.text =
                                    filteredProducts[index].sellingPrice;
                                productTaxPercent.text =
                                    filteredProducts[index].taxPercent;
                                productTaxAmount.text =
                                    filteredProducts[index].taxAmount;
                                productTotalAmountTotal.text =
                                    ((double.parse(productRate.text)) *
                                            double.parse(productQty.text))
                                        .toString();
                                productTotalAmount.text =
                                    ((double.parse(productRate.text) +
                                                double.parse(
                                                    productTaxAmount.text)) *
                                            double.parse(productQty.text))
                                        .toString();
                                productTotalAmount.text =
                                    double.parse(productTotalAmount.text)
                                        .toStringAsFixed(2);
                                if (paymentStatus == "paid") {
                                  paidAmount.text = productTotalAmount.text;
                                }
                                typeDuration = filteredProducts[index].noOfDays;
                              } else {
                                if (renProductQty.text == "") {
                                  renProductQty.text = "1";
                                }
                                renProductName =
                                    filteredProducts[index].productName;
                                renProductId = filteredProducts[index].id;
                                renProductRate.text =
                                    filteredProducts[index].sellingPrice;
                                renProductTaxPercent.text =
                                    filteredProducts[index].taxPercent;
                                renProductTaxAmount.text =
                                    filteredProducts[index].taxAmount;
                                renProductTotalAmount.text =
                                    ((double.parse(renProductRate.text) +
                                                double.parse(
                                                    renProductTaxAmount.text)) *
                                            double.parse(renProductQty.text))
                                        .toString();
                                renProductTotalAmount.text =
                                    double.parse(renProductTotalAmount.text)
                                        .toStringAsFixed(2);
                              }
                              this.setState(() {});
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            title: Text(filteredProducts[index].productName),
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child:
                                  Text(filteredProducts[index].productName[0]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  Future<Object?> changeAmount(
      BuildContext context,
      String name,
      String rate,
      String qty,
      String tax,
      String taxPerccent,
      String amount,
      String id,
      String des,
      int index) {
    renProductQty.text = qty;
    renProductRate.text = rate;
    renProductTaxPercent.text = taxPerccent;
    renProductTaxAmount.text = tax;
    renProductTotalAmount.text = amount;
    renProductId = id;
    renProductName = name;
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              renProducts.removeAt(index);
                              this.setState(() {});
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        productDialog(context, "edit");
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    renProductName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation(
                                  dialogState: setDialogState);
                            },
                            controller: renProductRate,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Rate',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation(
                                  dialogState: setDialogState);
                            },
                            controller: renProductQty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Qty',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation(
                                  dialogState: setDialogState);
                            },
                            controller: renProductTaxPercent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Percent',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation(
                                  dialogState: setDialogState);
                            },
                            controller: renProductTaxAmount,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Amount',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      child: TextFormField(
                        controller: renProductTotalAmount,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Total Amount',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (renProductRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (renProductQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (renProductTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (renProductTaxAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Amount', Colors.red);
                            } else if (renProductTotalAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Total Amount', Colors.red);
                            } else {
                              renProducts[index] = {
                                "product_name": renProductName,
                                "product_id": renProductId,
                                "description": des,
                                "product_rate": renProductRate.text,
                                "quantity": renProductQty.text,
                                "tax_percent": renProductTaxPercent.text,
                                "total_tax_amount": renProductTaxAmount.text,
                                "total_amount": renProductTotalAmount.text,
                              };
                              _recalculateTotals();
                              Navigator.of(context).pop();
                              this.setState(() {});
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 25, right: 25),
                                child: Text(
                                  'Change',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Future<dynamic> dropDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      height: 40,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onChanged: ((value) {
                          setState(() {
                            filterTemplates(value);
                          });
                        }),
                      ),
                    )
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          reminderTemplate.text =
                              filteredTemplates[index].templateName;
                          templateId = filteredTemplates[index].id;
                          Navigator.pop(context);
                          filterTemplates("");
                        },
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            filteredTemplates[index].templateName.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  void filterTemplates(String query) {
    if (detailsResponse != null) {
      filteredTemplates = detailsResponse!.data.template
          .where((map) =>
              map.templateName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<dynamic> collectedStaffDialog(BuildContext context) {
    if (filteredStaffList.isEmpty && commonDetails != null) {
      filteredStaffList.addAll(commonDetails!.data.colloctedStaff);
    }
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (value) {
                      setState(() {
                        filteredStaffList = commonDetails!.data.colloctedStaff
                            .where((item) => item.accountName
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredStaffList.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            this.setState(() {
                              staffName = filteredStaffList[index].accountName;
                              staffId = filteredStaffList[index].accountId;
                              filteredStaffList.clear();
                              filteredStaffList
                                  .addAll(commonDetails!.data.colloctedStaff);
                            });
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredStaffList[index].accountName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    filteredStaffList.clear();
                    filteredStaffList
                        .addAll(commonDetails!.data.colloctedStaff);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Close")),
            ],
          );
        });
      },
    );
  }

  Future<dynamic> targetGroupDialog(BuildContext context) {
    if (filteredTargetsList.isEmpty && commonDetails != null) {
      filteredTargetsList.addAll(commonDetails!.data.targetGroups);
    }
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Select Target Groups'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        if (commonDetails != null) {
                          setModalState(() {
                            filteredTargetsList = commonDetails!
                                .data.targetGroups
                                .where((item) => item.groupName
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .32,
                    width: MediaQuery.of(context).size.width * .8,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredTargetsList.length,
                      itemBuilder: (context, ind) {
                        return CheckboxListTile(
                          title: SizedBox(
                            width: 200,
                            child: Text(
                              filteredTargetsList[ind].groupName.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                          ),
                          value: targetGroups
                              .contains(filteredTargetsList[ind].id.toString()),
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                targetGroups.add(
                                    filteredTargetsList[ind].id.toString());
                                targetGroupNames.add(filteredTargetsList[ind]
                                    .groupName
                                    .toString());
                              } else {
                                targetGroups.remove(
                                    filteredTargetsList[ind].id.toString());
                                targetGroupNames.remove(filteredTargetsList[ind]
                                    .groupName
                                    .toString());
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  filteredTargetsList.clear();
                  filteredTargetsList.addAll(commonDetails!.data.targetGroups);
                  setState(() {}); // Trigger rebuild of main page
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Done"),
              ),
            ],
          );
        });
      },
    );
  }

  productCalculation() {
    productTaxAmount.text =
        ((double.parse(productRate.text == "" ? "0" : productRate.text) *
                    double.parse(productTaxPercent.text == ""
                        ? "0"
                        : productTaxPercent.text) /
                    100) *
                double.parse(productQty.text == "" ? "0" : productQty.text))
            .toString();
    productTotalAmount.text = ((double.parse(
                    productRate.text == "" ? "0" : productRate.text) *
                double.parse(productQty.text == "" ? "0" : productQty.text)) +
            double.parse(productTaxAmount.text))
        .toString();
    productTotalAmount.text =
        double.parse(productTotalAmount.text).toStringAsFixed(2);
    setState(() {});
  }

  renProductCalculation({void Function(void Function())? dialogState}) {
    renProductTaxAmount.text = ((double.parse(
                    renProductRate.text == "" ? "0" : renProductRate.text) *
                double.parse(renProductTaxPercent.text == ""
                    ? "0"
                    : renProductTaxPercent.text) /
                100) *
            double.parse(renProductQty.text == "" ? "0" : renProductQty.text))
        .toString();
    renProductTotalAmount.text =
        ((double.parse(renProductRate.text == "" ? "0" : renProductRate.text) *
                    double.parse(
                        renProductQty.text == "" ? "0" : renProductQty.text)) +
                double.parse(renProductTaxAmount.text))
            .toString();
    renProductTotalAmount.text =
        double.parse(renProductTotalAmount.text).toStringAsFixed(2);
    if (dialogState != null) {
      dialogState(() {});
    } else {
      setState(() {});
    }
  }

  Future<dynamic> contactPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Permission",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "Our app accesses your contact list to help you easily add leads to our CRM system. This feature allows you to select contacts from your address book and save them as leads in the CRM, making it easier to manage your client relationships.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xffe94040)),
                              child: const Center(
                                child: Text("Deny",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              contactPermission = "true";
                              Navigator.pop(context);
                              setState(() {
                                Common.saveSharedPref(
                                    "saveContactPermission", 'true');
                                saveContactDialog(context);
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.green),
                              child: const Center(
                                child: Text("Allow",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Object?> saveContactDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color.fromARGB(255, 49, 166, 243);

    return showGeneralDialog(
      barrierLabel: "Save Contact Dialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Save to Contacts',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Add contact information',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Form fields
                              _buildTextField(
                                controller: contactFName,
                                label: 'First Name',
                                icon: Icons.person_outline_rounded,
                                isDark: isDark,
                                autofocus: true,
                              ),

                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: contactLName,
                                label: 'Last Name',
                                icon: Icons.person_outline_rounded,
                                isDark: isDark,
                              ),

                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: contactMobile,
                                label: 'Mobile Number',
                                icon: Icons.phone_android_rounded,
                                isDark: isDark,
                                keyboardType: TextInputType.phone,
                              ),

                              const SizedBox(height: 24),

                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: isDark
                                                ? Colors.grey[700]!
                                                : Colors.grey[300]!,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _saveContact(context, setState),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Save Contact',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Permission hint
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]!.withOpacity(0.5)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 16,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Contacts permission will be requested to save this contact',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final fillColor = isDark ? Colors.grey[800]! : Colors.grey[50]!;

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: autofocus,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelStyle: TextStyle(
            color: const Color(0xFF3375e0),
            fontSize: 12,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _saveContact(BuildContext context, StateSetter setState) async {
    if (contactFName.text.isEmpty) {
      Common.toastMessaage('Please enter first name', Colors.red);
      return;
    }

    if (contactMobile.text.isEmpty) {
      Common.toastMessaage('Please enter mobile number', Colors.red);
      return;
    }

    try {
      PermissionStatus permission = await Permission.contacts.status;

      if (permission != PermissionStatus.granted) {
        permission = await Permission.contacts.request();
      }

      if (permission == PermissionStatus.granted) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          Common.showProgressDialog(context, "Saving contact...");
        }

        final newContact = Contact(
          name: Name(
            first: contactFName.text.trim(),
            last: contactLName.text.trim(),
          ),
          displayName:
              "${contactFName.text.trim()} ${contactLName.text.trim()}".trim(),
          phones: [Phone(contactMobile.text.trim())],
        );

        await newContact.insert();

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true)
              .pop(); // Close progress dialog
          Common.toastMessaage('Contact saved successfully!', Colors.green);
        }
      } else {
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Common.toastMessaage(
            'Failed to save contact: ${e.toString()}', Colors.red);
      }
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Contacts permission is needed to save contacts to your phone. '
            'Please enable it in settings to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Future<Object?> saveContactDialog(BuildContext context) {
  //   return showGeneralDialog(
  //     barrierLabel: "showGeneralDialog",
  //     barrierDismissible: true,
  //     barrierColor: Colors.black.withOpacity(0.6),
  //     transitionDuration: const Duration(milliseconds: 400),
  //     context: context,
  //     pageBuilder: (context, _, __) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Align(
  //             alignment: Alignment.bottomCenter,
  //             child: Padding(
  //               padding: EdgeInsets.only(
  //                   bottom: MediaQuery.of(context).viewInsets.bottom),
  //               child: IntrinsicHeight(
  //                 child: Container(
  //                   width: double.maxFinite,
  //                   clipBehavior: Clip.antiAlias,
  //                   padding: const EdgeInsets.all(16),
  //                   decoration: const BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.only(
  //                       topLeft: Radius.circular(16),
  //                       topRight: Radius.circular(16),
  //                     ),
  //                   ),
  //                   child: Material(
  //                     child: Column(
  //                       children: [
  //                         const SizedBox(height: 20),
  //                         const Text(
  //                           'Save Contact to Phone',
  //                           style: TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 20),
  //                         TextFormField(
  //                           controller: contactFName,
  //                           decoration: const InputDecoration(
  //                               contentPadding: EdgeInsets.only(
  //                                   left: 10, top: 2, bottom: 2),
  //                               labelText: 'First Name',
  //                               fillColor: Colors.white,
  //                               filled: true,
  //                               prefixIcon:
  //                                   Icon(Icons.person, color: Colors.grey),
  //                               border: OutlineInputBorder(),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderSide: BorderSide(color: Colors.grey),
  //                               ),
  //                               labelStyle: TextStyle(color: Colors.grey)),
  //                         ),
  //                         const SizedBox(
  //                           height: 13,
  //                         ),
  //                         TextFormField(
  //                           controller: contactLName,
  //                           decoration: const InputDecoration(
  //                               contentPadding: EdgeInsets.only(
  //                                   left: 10, top: 2, bottom: 2),
  //                               labelText: 'Last Name',
  //                               fillColor: Colors.white,
  //                               filled: true,
  //                               prefixIcon:
  //                                   Icon(Icons.person, color: Colors.grey),
  //                               border: OutlineInputBorder(),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderSide: BorderSide(color: Colors.grey),
  //                               ),
  //                               labelStyle: TextStyle(color: Colors.grey)),
  //                         ),
  //                         const SizedBox(
  //                           height: 13,
  //                         ),
  //                         TextFormField(
  //                           controller: contactMobile,
  //                           decoration: const InputDecoration(
  //                               contentPadding: EdgeInsets.only(
  //                                   left: 10, top: 2, bottom: 2),
  //                               labelText: 'Mobile Number',
  //                               fillColor: Colors.white,
  //                               filled: true,
  //                               prefixIcon: Icon(Icons.phone_android_rounded,
  //                                   color: Colors.grey),
  //                               border: OutlineInputBorder(),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderSide: BorderSide(color: Colors.grey),
  //                               ),
  //                               labelStyle: TextStyle(color: Colors.grey)),
  //                         ),
  //                         const SizedBox(
  //                           height: 10,
  //                         ),
  //                         const SizedBox(height: 16),
  //                         Container(
  //                           height: 40,
  //                           width: double.maxFinite,
  //                           decoration: const BoxDecoration(
  //                             color: Color(0xFF3375e0),
  //                             borderRadius:
  //                                 BorderRadius.all(Radius.circular(8)),
  //                           ),
  //                           child: RawMaterialButton(
  //                             onPressed: () async {
  //                               if (contactFName.text.isEmpty) {
  //                                 Common.toastMessaage(
  //                                     'Enter the first name', Colors.red);
  //                               } else if (contactMobile.text.isEmpty) {
  //                                 Common.toastMessaage(
  //                                     'Enter the Mobile number', Colors.red);
  //                               } else {
  //                                 PermissionStatus permission =
  //                                     await Permission.contacts.status;

  //                                 if (permission != PermissionStatus.granted) {
  //                                   await Permission.contacts.request();
  //                                   PermissionStatus permission =
  //                                       await Permission.contacts.status;

  //                                   if (permission ==
  //                                       PermissionStatus.granted) {
  //                                     if (context.mounted) {
  //                                       Navigator.of(context,
  //                                               rootNavigator: true)
  //                                           .pop();
  //                                       Common.showProgressDialog(
  //                                           context, "Saving...");
  //                                     }
  //                                     final newContact = Contact(
  //                                       name: Name(
  //                                         first: contactFName.text,
  //                                         last: contactLName.text,
  //                                       ),
  //                                       displayName:
  //                                           "${contactFName.text} ${contactLName.text}",
  //                                       phones: [Phone(contactMobile.text)],
  //                                     );
  //                                     await newContact.insert();

  //                                     Common.toastMessaage(
  //                                         'Saved', Colors.green);
  //                                   } else {
  //                                     //_handleInvalidPermissions(context);
  //                                   }
  //                                 } else {
  //                                   if (context.mounted) {
  //                                     Navigator.of(context, rootNavigator: true)
  //                                         .pop();
  //                                     Common.showProgressDialog(
  //                                         context, "Saving...");
  //                                   }
  //                                   final newContact = Contact(
  //                                     name: Name(
  //                                       first: contactFName.text,
  //                                       last: contactLName.text,
  //                                     ),
  //                                     displayName:
  //                                         "${contactFName.text} ${contactLName.text}",
  //                                     phones: [Phone(contactMobile.text)],
  //                                   );
  //                                   await newContact.insert();

  //                                   Common.toastMessaage('Saved', Colors.green);
  //                                 }
  //                                 if (context.mounted) {
  //                                   Navigator.of(context, rootNavigator: true)
  //                                       .pop();
  //                                 }
  //                               }
  //                             },
  //                             child: const Center(
  //                               child: Text(
  //                                 'Save',
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w500,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 10),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //   );
  // }

  // void _popBreadcrumb() {
  //   if (driveBreadcrumbs.length > 1) {
  //     setState(() {
  //       driveBreadcrumbs.removeLast();
  //       final last = driveBreadcrumbs.last;
  //       selectedFolderId = last['id'] == 'root' ? null : last['id'];
  //       currentFolderName = last['id'] == 'root' ? null : last['name'];
  //     });
  //     _fetchGoogleDriveFiles(selectedDriveAccount!.id,
  //         parentId: selectedFolderId ?? "");
  //   } else {
  //     setState(() {
  //       selectedDriveAccount = null;
  //       selectedFolderId = null;
  //       currentFolderName = null;
  //       driveBreadcrumbs = [
  //         {'id': 'root', 'name': 'Drive'}
  //       ];
  //     });
  //   }
  // }

  // void _updateBreadcrumbs(String id, String name) {
  //   if (!driveBreadcrumbs.any((element) => element['id'] == id)) {
  //     setState(() {
  //       driveBreadcrumbs.add({'id': id, 'name': name});
  //     });
  //   }
  // }

  // Widget _buildS3Breadcrumbs() {
  //   List<String> parts = path.split('/').where((p) => p.isNotEmpty).toList();
  //   List<Widget> crumbs = [];

  //   crumbs.add(
  //     GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           path = '';
  //           listPath = '';
  //           backPath = '';
  //           listFolderList(widget.token, callMasterId, '');
  //         });
  //       },
  //       child: const Text('S3',
  //           style: TextStyle(
  //               fontSize: 11,
  //               color: Colors.grey,
  //               fontWeight: FontWeight.normal)),
  //     ),
  //   );

  //   String currentP = '';
  //   for (int i = 0; i < parts.length; i++) {
  //     crumbs.add(
  //         Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400));
  //     currentP += (i == 0 ? parts[i] : '/${parts[i]}');
  //     final pTarget = currentP;
  //     bool isLast = i == parts.length - 1;

  //     crumbs.add(
  //       GestureDetector(
  //         onTap: isLast
  //             ? null
  //             : () {
  //                 setState(() {
  //                   path = '$pTarget/';
  //                   listPath = pTarget;
  //                   backPath = pTarget;
  //                   listFolderList(widget.token, callMasterId, listPath);
  //                 });
  //               },
  //         child: Text(parts[i],
  //             style: TextStyle(
  //                 fontSize: 11,
  //                 color: isLast ? Colors.blue : Colors.grey.shade600,
  //                 fontWeight: isLast ? FontWeight.bold : FontWeight.normal)),
  //       ),
  //     );
  //   }

  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(children: crumbs),
  //   );
  // }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 64.0;
  @override
  double get maxExtent => 64.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
