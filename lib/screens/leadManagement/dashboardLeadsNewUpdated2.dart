import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_auto_orientation/flutter_auto_orientation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/leadDetailsModel.dart';
import 'package:login2/models/lead_management/leadDetailsModelAdd.dart';
import 'package:login2/models/lead_management/leadMileStoneListModel.dart';
import 'package:login2/models/lead_management/listFolderName.dart';
import 'package:login2/models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart' as af;
import 'package:login2/models/lead_management/leadProductsModel.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/complaints/complaint_list_screen.dart';
import 'package:login2/screens/fileManager/fileManagerList.dart';
import 'package:login2/screens/leadManagement/activeLeads.dart';
import 'package:login2/screens/leadManagement/add_leads_new.dart';
import 'package:login2/screens/leadManagement/allReport.dart';
import 'package:login2/screens/leadManagement/callHistoryPageNew.dart';
import 'package:login2/screens/leadManagement/newLeads.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
import 'package:login2/screens/leadManagement/transferLeadReport.dart';
import 'package:login2/screens/leadManagement/viewLeadsNew.dart';
import 'package:login2/screens/leadManagement/viewallcompanyworks.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/officialWhatsapp/chat_home_screen.dart';
import 'package:login2/screens/product_mannagement/product_list.dart';
import 'package:login2/screens/roombooking/hotelDashboard.dart';
import 'package:login2/screens/serviceman/dashboard_page.dart';
import 'package:login2/screens/settings/whatsappSettings.dart';
import 'package:login2/screens/sidebarscreens/leadSidebarScreen.dart';
import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:login2/screens/userManagement/viewUsers.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/common.dart';
import '../../service/service.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/dashboardModel.dart';
import 'package:login2/models/lead_management/dashboardLeadsCountsModel.dart';
import 'package:login2/models/lead_management/leadDashboardCountNewModel.dart';
import 'package:login2/models/expense/staffListModel.dart' as sl;
import '../../models/lead_management/leadDashboardModel.dart' as ld;
import '../../models/lead_management/viewLeadsModel.dart';
import '../../models/lead_management/leadProgressbarModel.dart' as lp;
import '../../models/lead_management/leadProgressBarStaffModel.dart' as lps;
import '../../models/lead_management/categoryWiseLeadBarModel.dart' as clb;
import '../../models/lead_management/leadProgressBarStatusWise.dart' as lpbsw;
import '../../models/lead_management/leadCategoryStaffWiseModel.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../models/renewal/renewal_dashboard_model.dart';
import '../../models/lead_management/callStatusReportModel.dart' as csr;
import '../../models/lead_management/callStatusReportTableModel.dart' as csrt;
import '../../models/lead_management/callStatusReportOntapModel.dart' as csro;
import '../../models/lead_management/stagewiseReportModel.dart' as swr;
import '../../models/lead_management/stagewiseTableModel.dart' as swrt;
import '../../models/lead_management/stagewiseReportOntap.dart' as swro;
import '../../models/lead_management/lead_source_report_model.dart' as lsr;
import '../../models/lead_management/leadSourceReportOntapModel.dart' as lsro;
import '../../models/lead_management/leadSourceTableModel.dart' as lsrt;
import '../../models/lead_management/categoryReportModel.dart' as catr;
import '../../models/lead_management/leadCategoryReportOntapModel.dart'
    as catro;
import '../../models/lead_management/categoryReportTableModel.dart' as catrt;
import '../../models/lead_management/cloudCallReportModel.dart' as ccr;
import '../../models/lead_management/phoneCallReportModel.dart' as pcr;
import '../../models/clients/customerListModel.dart';
import '../authentication/login.dart';
import '../authentication/deep_link_handler.dart';
import '../bottom_navigation_bar.dart';
import '../homePage.dart';
import '../search/search.dart';
import '../leadManagement/notification_page.dart';
import '../leadManagement/lead_details_popup.dart';
import '../leadManagement/projectDashboard.dart';
import '../leadManagement/minimalDashboard.dart';
import '../accounts/renewal_mannagement/renewal_dashboard.dart';
import '../accounts/dashboard/accounts_dashboard.dart';
import '../../widgets/viewLeadsFilterWidget.dart';
import '../../widgets/togglebutton_start.dart';
import '../drawerScreen.dart';
import '../../models/lead_management/BulkTransferLeadModel.dart';
import '../../models/lead_management/showTransferHideorShowModel.dart';

class DashboardLeadNewUpdatedTwo extends StatefulWidget {
  final String? token;
  final GlobalKey<_DashboardLeadNewUpdatedTwoState>? dashboardKey;

  const DashboardLeadNewUpdatedTwo(this.token, {super.key, this.dashboardKey});

  @override
  State<DashboardLeadNewUpdatedTwo> createState() =>
      _DashboardLeadNewUpdatedTwoState();
}

class _DashboardLeadNewUpdatedTwoState extends State<DashboardLeadNewUpdatedTwo>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ld.LeadDashboardModel? leadDashboard;
  CommonConfigureModel? configure;
  LeadCategoryStaffWiseModel? staffWise;
  DashboardModel? userDashboard;
  RenewalDashboardModel? renewalDashboard;
  ProjectList? projectList;
  WorkStatusModel? workStatus;
  CommonResponse? loginOrNot;
  List<String> selectedIUsers = [];
  List<String> selectedUserNumbers = [];
  String transferStaffToggleName = "Staff";
  String transferStaffToggleId = "";
  List<TransferStaff> filteredTransferStaff = [];
  String transferPermission = "false";
  AccountDashboardModel? accountDashboard;
  AddLeadCommonDataModel? commonDetails;
  lp.LeadProgressbarModel? object1;
  lps.LeadProgressBarStaffModel? staffProgressData;
  clb.CategoryWiseLeadBarModel? categoryProgressData;
  lpbsw.LeadProgressBarStatusWise? statusProgressData;
  String? firebaseToken;
  bool isLoading = true;
  bool timeOut = false;
  bool isExpired = false;
  bool isWorkStarted = false;
  bool loadmore = false;
  bool moreloading = false;
  List<Detail> listTabLeads = [];
  bool _isListTabLoading = false;

  bool _isGraphViewActive = false;
  String _activeGraphCategory = "New";
  bool isVisible = true;
  bool toggle = false;
  static const String keyCallStatusReport = "cache_call_status_report_v2";
  static const String keyCallStatusLastUpdated = "cache_call_status_updated_v2";
  static const String keyStageWiseReport = "cache_stage_wise_report_v2";
  static const String keyStageWiseLastUpdated = "cache_stage_wise_updated_v2";
  static const String keyLeadSourceReport = "cache_lead_source_report_v2";
  static const String keyLeadSourceLastUpdated = "cache_lead_source_updated_v2";
  static const String keyCategoryReport = "cache_category_report_v2";
  static const String keyCategoryLastUpdated = "cache_category_updated_v2";
  static const String keyCloudCallReport = "cache_cloud_call_report_v2";
  static const String keyCloudCallLastUpdated = "cache_cloud_call_updated_v2";
  static const String keyPhoneCallReport = "cache_phone_call_report_v2";
  static const String keyPhoneCallLastUpdated = "cache_phone_call_updated_v2";
  static const String keyCallStatusTableLastUpdated =
      "cache_call_status_table_updated_v2";
  static const String keyStageWiseTableLastUpdated =
      "cache_stage_wise_table_updated_v2";
  static const String keyLeadSourceTableLastUpdated =
      "cache_lead_source_table_updated_v2";
  static const String keyCategoryTableLastUpdated =
      "cache_category_table_updated_v2";
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime fromDateClosed = DateTime.now();
  DateTime toDateClosed = DateTime.now();
  DateTime fromDateLost = DateTime.now();
  DateTime toDateLost = DateTime.now();
  String closedCount = "0";
  String lostCount = "0";
  bool isClosedDateFiltered = false;
  bool isLostDateFiltered = false;
  DateTime fromDate1 = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate1 = DateTime.now();
  DateTime targetFromDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime targetToDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  );
  String name = '';
  String role = '';
  String userId = '';
  String staffId = '';
  String notificationCount = '0';
  String accPermission = "";
  String renewalPermission = "false";
  String createLeadPermission = '';
  String viewLeadPermission = '';
  String viewAllWorkPermission = '';
  String viewTargetReportPermission = '';
  String addWorkPermission = '';
  String startAndStopWorkPermission = '';
  String workWithoutLogin = '';
  String adminCheckPermission = '';
  String viewAttendanceSection = '';
  String multipleUsersCheck = '';
  String multipleWorksCheck = '';
  String viewWorkReportPermission = '';
  String hasPhonecallAccess = '';
  String updateLeadPermission = '';
  String deleteLeadPermission = '';
  String phoneCallLogPermission = '';
  String accessCallHistoryPermission = '';
  String viewLeadCategoryPermission = '';
  String cloudCallPermission = '';
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String startAndStopWork = '';
  String accessCallRecordingPermission = '';
  String visibleP = '';
  String assignWork = "";
  String updateDashboard = "";
  String viewPendingWorks = "";
  String approvePayroll = "";
  String proformaInvoiceMenu = "";
  String gstInvoiceMenu = "";
  String pendingInvoiceMenu = "";
  String receiptMenu = "";
  String staffType = "";
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? viewLeadCategoryOnly;
  String? viewAllCategory;
  String? NewleadDashboardPermission;
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool accessCallRecordingPermission1 = false;
  bool viewTargetReportPermission1 = false;
  bool showTransferFreshValue = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _listTabRefreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  DashboardLeadsCountsModel? dashboardCounts;
  DashboardLeadCounts? dashboardMainCounts;
  bool isDashboardCountsLoading = false;
  String? targetStaffId = "";
  List<sl.Staff> staffList = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController staffSearchController = TextEditingController();
  final Color primaryBlue = const Color(0xFF2a86c9);
  final Color darkBlue = const Color(0xFF1a5a8c);
  final Color lightBlue = const Color(0xFF64b5f6);
  final Color veryLightBlue = const Color(0xFFe3f2fd);
  bool _isCompactView = false;
  bool _isFlipSummaryView = false;
  String _listTabFilter = 'New';
  int _listTabPage = 1;
  bool _hasMoreListTabLeads = true;
  bool _isListTabLoadingMore = false;
  int _totalLeads = 0;
  String? _listTabCurrentStatus = '1';
  String? _listTabCurrentLeadType;
  String? _listTabCurrentCallStatus;
  bool? _listTabCurrentIsCalled;
  bool _listTabCallPermission = true;
  bool _isTab0Loaded = false;
  bool _isTab1Loaded = false;
  bool _isTab2Loaded = false;
  final Set<String> _expandedLeadIds = {};
  List<String> _listTabSelectedStatusIds = [];
  List<String> _listTabSelectedStaffIds = [];
  List<String> _listTabSelectedCategoryIds = [];
  List<String> _listTabSelectedPriorityIds = [];
  List<String> _listTabSelectedProductIds = [];
  List<String> _listTabSelectedTagIds = [];
  bool _isListTabFilterApplied = false;
  bool _isListTabDateFiltered = false;
  bool _isGlobalDateFiltered = false;
  String _listTabSortOrder = 'desc';

  bool _isSortAscending = false;
  static const Color appBarStart = Color(0xFF2a86c9);
  static const Color callGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFF44336);
  static const Color followupBlue = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color borderLight = Color(0xFFECF0F1);
  static const Color backgroundLight = Color.fromARGB(255, 247, 249, 252);
  String _reportType1 = "Call Status Report";
  String _reportType2 = "Active Lead Summary";
  String _reportType3 = "Lead Source Report";
  String _reportType4 = "Category Report";
  bool _isFlipped1 = false;
  bool _isFlipped2 = false;
  bool _isFlipped3 = false;
  bool _isFlipped4 = false;
  final List<Color> _colors = [
    const Color(0xFF2196F3),
    const Color(0xFF2196F3),
    const Color(0xFFFFC107),
    const Color.fromARGB(
      255,
      255,
      7,
      7,
    ),
    const Color(0xFF4CAF50),
    const Color(0xFFF44336),
    const Color(0xFF9C27B0),
    const Color(0xFF2a84c9),
    const Color(0xFF009688),
    const Color(0xFFFF6F00),
    const Color(0xFFD32F2F),
    const Color(0xFF1B5E20),
    const Color(0xFF0D47A1),
    const Color(0xFF3F51B5),
  ];
  Map<String, double> reportDataMap = {};
  int catNew = 0,
      catPending = 0,
      catFollowup = 0,
      catRejected = 0,
      catClosed = 0;
  bool isCallStatusLoading = false;
  List<String> callStatusStaffs = [];
  lp.LeadProgressbarModel? callStatusData;
  csr.CallStatusReportModel? callStatusReport;
  DateTime? stageWiseFromDate;
  DateTime? stageWiseToDate;
  DateTime? callStatusFromDate;
  DateTime? callStatusToDate;
  List<String> stageWiseStaffs = [];
  bool isStageWiseLoading = false;
  LeadCategoryStaffWiseModel? stageWiseData;
  swr.StagewiseReportModel? stagewiseReport;
  DateTime? stageWiseLastUpdated;
  csrt.CallStatusReportResponse? callStatusTableData;
  swrt.StagewiseReportResponse? stageWiseTableData;
  bool isCallStatusTableLoading = false;
  bool isStageWiseTableLoading = false;
  bool isLeadSourceTableLoading = false;
  lsrt.LeadSourceReportResponse? leadSourceTableData;
  catrt.CategoryReportTableModel? categoryTableData;
  bool isCategoryTableLoading = false;
  DateTime? leadSourceFromDate;
  DateTime? leadSourceToDate;
  List<String> leadSourceStaffs = [];
  List<String> leadSourceProducts = [];
  List<String> leadSourceCategories = [];
  bool isLeadSourceLoading = false;
  lsr.LeadSourceReportModel? leadSourceReport;
  DateTime? leadSourceLastUpdated;
  int leadSourcePage = 1;
  int leadSourcePageSize = 10;
  bool hasMoreLeadSource = true;
  bool isLeadSourceMoreLoading = false;
  List<lsr.LeadSourceDetail> leadSourceDetails = [];
  DateTime? categoryFromDate;
  DateTime? categoryToDate;
  List<String> categoryStaffs = [];
  bool isCategoryLoading = false;
  LeadCategoryStaffWiseModel? categoryData;
  catr.CategoryReportModel? categoryReport;
  DateTime? categoryLastUpdated;
  int categoryPage = 1;
  int categoryPageSize = 10;
  bool hasMoreCategory = true;
  bool isCategoryMoreLoading = false;
  List<catr.CategoryDetail> categoryDetails = [];
  ccr.CloudCallReportModel? cloudCallReportData;
  pcr.PhoneCallReportModel? phoneCallReportData;
  bool isCloudCallLoading = false;
  bool isPhoneCallLoading = false;
  DateTime? cloudCallLastUpdated;
  DateTime? phoneCallLastUpdated;
  DateTime? callStatusTableLastUpdated;
  DateTime? stageWiseTableLastUpdated;
  DateTime? leadSourceTableLastUpdated;
  DateTime? categoryTableLastUpdated;
  LeadProductSectionModel? productSectionModel;
  DateTime? callStatusLastUpdated;
  bool isCallStatusExpanded = false;
  bool isStageWiseExpanded = false;
  bool isLeadSourceExpanded = false;
  bool isCategoryExpanded = false;
  bool showCallStatusTable = false;
  bool showStageWiseTable = false;
  bool showLeadSourceTable = false;
  bool showCategoryTable = false;
  bool showCloudCallTable = false;
  bool showPhoneCallTable = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadReportStates().then((_) {
      _loadReportsFromCache();
    });
    _initializeData();
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
    _clearListTabFilters(); // Clear filters when switching main tabs
    _fetchDataForTab(_tabController.index);
  }

  void _clearListTabFilters() {
    _listTabSelectedStatusIds.clear();
    _listTabSelectedStaffIds.clear();
    _listTabSelectedCategoryIds.clear();
    _listTabSelectedPriorityIds.clear();
    _listTabSelectedProductIds.clear();
    _listTabSelectedTagIds.clear();
    _isListTabFilterApplied = false;
    _isListTabDateFiltered = false;
    searchController.clear();
    setState(() {});
  }

  int _getTabCount() {
    return 3;
  }

  Future<void> _loadReportStates() async {
    _reportType1 =
        await Common.getSharedPref("reportType1") ?? "Call Status Report";
    _reportType2 =
        await Common.getSharedPref("reportType2") ?? "Active Lead Summary";
    _reportType3 =
        await Common.getSharedPref("reportType3") ?? "Lead Source Report";
    _reportType4 =
        await Common.getSharedPref("reportType4") ?? "Category Report";
    showCallStatusTable =
        (await Common.getSharedPref("showCallStatusTable")) == "true";
    showStageWiseTable =
        (await Common.getSharedPref("showStageWiseTable")) == "true";
    showLeadSourceTable =
        (await Common.getSharedPref("showLeadSourceTable")) == "true";
    showCategoryTable =
        (await Common.getSharedPref("showCategoryTable")) == "true";
    showCloudCallTable =
        (await Common.getSharedPref("showCloudCallTable")) == "true";
    showPhoneCallTable =
        (await Common.getSharedPref("showPhoneCallTable")) == "true";
    String? csFrom = await Common.getSharedPref("callStatusFromDate");
    String? csTo = await Common.getSharedPref("callStatusToDate");
    if (csFrom != null) callStatusFromDate = DateTime.parse(csFrom);
    if (csTo != null) callStatusToDate = DateTime.parse(csTo);
    String? swFrom = await Common.getSharedPref("stageWiseFromDate");
    String? swTo = await Common.getSharedPref("stageWiseToDate");
    if (swFrom != null) stageWiseFromDate = DateTime.parse(swFrom);
    if (swTo != null) stageWiseToDate = DateTime.parse(swTo);
    String? lsFrom = await Common.getSharedPref("leadSourceFromDate");
    String? lsTo = await Common.getSharedPref("leadSourceToDate");
    if (lsFrom != null) {
      leadSourceFromDate = DateTime.parse(lsFrom);
    }
    if (lsTo != null) {
      leadSourceToDate = DateTime.parse(lsTo);
    }
    String? catFrom = await Common.getSharedPref("categoryFromDate");

    String? viewLeadCategoryOnly =
        await Common.getSharedPref("viewLeadCategoryOnly");
    String? viewAllCategory = await Common.getSharedPref("viewAllCategory");
    String? catTo = await Common.getSharedPref("categoryToDate");
    if (catFrom != null) categoryFromDate = DateTime.parse(catFrom);
    if (catTo != null) categoryToDate = DateTime.parse(catTo);
    String? csStaffs = await Common.getSharedPref("callStatusStaffIdStr");
    if (csStaffs != null && csStaffs.isNotEmpty) {
      callStatusStaffs = csStaffs.split(",");
    }
    String? swStaffs = await Common.getSharedPref("stageWiseStaffIdStr");
    if (swStaffs != null && swStaffs.isNotEmpty) {
      stageWiseStaffs = swStaffs.split(",");
    }
    String? lsStaffs = await Common.getSharedPref("leadSourceStaffIdStr");
    if (lsStaffs != null && lsStaffs.isNotEmpty) {
      leadSourceStaffs = lsStaffs.split(",");
    }
    String? lsProds = await Common.getSharedPref("leadSourceProductIdStr");
    if (lsProds != null && lsProds.isNotEmpty) {
      leadSourceProducts = lsProds.split(",");
    }
    String? lsCats = await Common.getSharedPref("leadSourceCategoryIdStr");
    if (lsCats != null && lsCats.isNotEmpty) {
      leadSourceCategories = lsCats.split(",");
    }
    String? catStaffs = await Common.getSharedPref("categoryStaffIdStr");
    if (catStaffs != null && catStaffs.isNotEmpty) {
      categoryStaffs = catStaffs.split(",");
    }
    setState(() {});
  }

  void _updateTabController() {
    if (!mounted) return;
    final newLength = _getTabCount();
    if (_tabController.length != newLength) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: newLength,
        vsync: this,
        initialIndex: oldIndex < newLength ? oldIndex : 0,
      );
      _tabController.addListener(_handleTabSelection);
      setState(() {});
    }
  }

  Future<void> _initializeData() async {
    String? flipView = await Common.getSharedPref("isFlipSummaryView");
    if (flipView != null) {
      setState(() {
        _isFlipSummaryView = flipView == "true";
      });
    }
    productSectionModel = await HttpService.leadProductSection();
    await getData(widget.token, fromDate, toDate, isDateFiltered: false);
    _loadWorkStatus();
    _checkDashboardPermission();
    _updateTabController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deepLinkHandler.getPendingDeepLink().then((data) {
        if (data != null && mounted) {
          deepLinkHandler.validateAndNavigate(context, data);
        }
      });
    });
  }

  void _checkDashboardPermission() async {
    proformaInvoiceMenu =
        await Common.getSharedPref("proformaInvoiceMenu") ?? "";
    gstInvoiceMenu = await Common.getSharedPref("gstInvoiceMenu") ?? "";
    pendingInvoiceMenu = await Common.getSharedPref("pendingInvoiceMenu") ?? "";
    receiptMenu = await Common.getSharedPref("receiptMenu") ?? "";
    staffType = await Common.getSharedPref("staffType") ?? "";
    if (staffType == "4" || staffType == "5") {
      setState(() {
        _isGraphViewActive = true;
      });
      _fetchProgressBarLeads("New");
    }
    ProjectDashboardPermission = await Common.getSharedPref(
      "ProjectDashboardPermission",
    );
    AccountsDashboardPermission = await Common.getSharedPref(
      "AccountsDashboardPermission",
    );
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission = await Common.getSharedPref(
      "RenewalDashboardPermission",
    );
    NewleadDashboardPermission = await Common.getSharedPref(
      "NewleadDashboardPermission",
    );
    setState(() {});
  }

  void _loadWorkStatus() async {
    String? status = await Common.getSharedPref("is_work_started");
    setState(() {
      isWorkStarted = status == "true";
    });
  }

  Future<void> _fetchDataForTab(int index) async {
    if (index == 0) {
      if (!_isTab0Loaded) {
        _isTab0Loaded = true;
        if (_isGraphViewActive) {
          await _fetchProgressBarLeads(_listTabFilter);
        } else {
          _listTabFilter == "Followup"
              ? await _fetchTabLeadsActive()
              : await _fetchTabLeads();
        }
        await _fetchDashboardTabContent();
      }
    } else if (index == 1) {
      if (!_isTab1Loaded) {
        _isTab1Loaded = true;
        await _fetchDashboardTabContent();
      }
    } else if (index == 2) {
      if (!_isTab2Loaded) {
        _isTab2Loaded = true;
        await _fetchReportTabContent();
      }
    }
  }

  Future<void> _fetchDashboardTabContent({String? staffId}) async {
    setState(() => isDashboardCountsLoading = true);
    try {
      final fDate = DateFormat('dd-MM-yyyy').format(fromDate);
      final tDate = DateFormat('dd-MM-yyyy').format(toDate);
      final targetFDate = DateFormat('dd-MM-yyyy').format(targetFromDate);
      final targetTDate = DateFormat('dd-MM-yyyy').format(targetToDate);
      final countsData = await HttpService.dashboardLeadsCounts(
        fromDate: fDate,
        toDate: tDate,
        userId: staffId ?? targetStaffId ?? userId,
        targetFromDate: targetFDate,
        targetToDate: targetTDate,
      );
      final staffResponse = await HttpService.getStaffsSomeof();
      if (staffResponse != null && staffResponse.status) {
        staffList = staffResponse.data;
      }
      if (countsData != null && countsData.status == true) {
        setState(() {
          dashboardCounts = countsData;
        });
      }
      final mainCounts = await HttpService.dashboardCountsMain();
      if (mainCounts != null) {
        setState(() {
          dashboardMainCounts = mainCounts;
        });
      }
      await Future.wait([
        getAccountDash(),
        getRenewalDashboard(),
        getCustomerList(),
      ]);
    } catch (e) {
      log("Error fetching dashboard counts: $e");
    } finally {
      if (mounted) setState(() => isDashboardCountsLoading = false);
    }
  }

  Future<void> _fetchReportTabContent() async {
    if (callStatusReport == null) _fetchCallStatusReport();
    if (stagewiseReport == null) _fetchStageWiseReport();
    if (leadSourceReport == null) _fetchLeadSourceReport();
    if (categoryReport == null) _fetchCategoryReport();
  }

  Future<void> getData(
    String? token,
    DateTime fromDate,
    DateTime toDate, {
    bool isRefresh = false,
    bool? isDateFiltered,
  }) async {
    if (isDateFiltered != null) {
      _isGlobalDateFiltered = isDateFiltered;
    }
    setState(() {
      if (!isRefresh) {
        isLoading = true;
      } else {
        _isListTabLoading = true;
      }
      timeOut = false;
    });
    if (isRefresh) {
      _isTab0Loaded = false;
      _isTab1Loaded = false;
      if (_tabController.index == 2) {
        _isTab2Loaded = false;
      }
    }
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          isLoading = false;
          _isListTabLoading = false;
          timeOut = true;
        });
        return;
      }
      await _loadUserPermissions();
      _updateTabController();
      firebaseToken = await FirebaseMessaging.instance.getToken();
      if (firebaseToken != null) {
        var loginCheck = await HttpService.loginCheck(token, firebaseToken!);
        if (loginCheck == null || loginCheck.data == false) {
          if (mounted) {
            Common.toastMessaage('Session Expired', Colors.red);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
            );
          }
          return;
        }
      }
      final results = await Future.wait([
        HttpService.configure(token),
        HttpService.mainDashboard(widget.token),
        HttpService.getLoginorNot(widget.token),
        HttpService.addLeadCommonData(token),
        HttpService.leadDashboard(
          token,
          fromDate,
          toDate,
          fromDate1.toString(),
          toDate1.toString(),
        ),
        _fetchDataForTab(_tabController.index),
      ]);
      configure = results[0] as CommonConfigureModel?;
      if (configure != null) {
        isExpired = configure!.data!.isExpired!;
      }
      userDashboard = results[1] as DashboardModel?;
      loginOrNot = results[2] as CommonResponse?;
      commonDetails = results[3] as AddLeadCommonDataModel?;
      leadDashboard = results[4] as ld.LeadDashboardModel?;
      await _checkLoginPrompt();
      if (userDashboard != null) {
        await Common.saveSharedPref(
          "profile_pic",
          userDashboard!.data.profilePic,
        );
        await Common.saveSharedPref(
          "whatsapp",
          userDashboard!.data.isWhatsappConfigured.toString(),
        );
      }
      if (leadDashboard != null) {
        notificationCount =
            leadDashboard?.data.unreadNotification.toString() ?? '0';
      }
      setState(() {
        isLoading = false;
        _isListTabLoading = false;
      });
    } catch (e) {
      log("Error loading data: $e");
      setState(() {
        isLoading = false;
        _isListTabLoading = false;
        timeOut = true;
      });
    }
  }

  Future<void> _loadUserPermissions() async {
    name = await Common.getSharedPref("name") ?? '';
    role = await Common.getSharedPref("role") ?? '';
    userId = await Common.getSharedPref("userId") ?? '';
    staffId = await Common.getSharedPref("staffId") ?? '';
    viewLeadCategoryOnly =
        await Common.getSharedPref("viewLeadCategoryOnly") ?? '';
    viewAllCategory = await Common.getSharedPref("viewAllCategory") ?? '';
    createLeadPermission =
        await Common.getSharedPref("createLeadPermission") ?? '';
    viewLeadPermission = await Common.getSharedPref("viewLeadPermission") ?? '';
    viewAllWorkPermission =
        await Common.getSharedPref("viewAllWorkPermission") ?? '';
    viewTargetReportPermission =
        await Common.getSharedPref("viewTargetReportPermission") ?? '';
    addWorkPermission = await Common.getSharedPref("addWorkPermission") ?? '';
    startAndStopWorkPermission =
        await Common.getSharedPref("startAndStopWorkPermission") ?? '';
    workWithoutLogin = await Common.getSharedPref("workWithoutLogin") ?? '';
    adminCheckPermission =
        await Common.getSharedPref("adminCheckPermission") ?? '';
    viewAttendanceSection =
        await Common.getSharedPref("viewAttendanceSection") ?? '';
    multipleUsersCheck = await Common.getSharedPref("multipleUsers") ?? '';
    multipleWorksCheck = await Common.getSharedPref("multipleWorks") ?? '';
    hasPhonecallAccess = await Common.getSharedPref("hasPhonecallAccess") ?? '';
    updateLeadPermission =
        await Common.getSharedPref("updateLeadPermission") ?? '';
    deleteLeadPermission =
        await Common.getSharedPref("deleteLeadPermission") ?? '';
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission") ?? '';
    accessCallHistoryPermission =
        await Common.getSharedPref("accessCallHistoryPermission") ?? '';
    transferPermission = await Common.getSharedPref("transferLeads") ?? '';
    viewLeadCategoryPermission =
        await Common.getSharedPref("viewLeadCategoryPermission") ?? '';
    cloudCallPermission =
        await Common.getSharedPref("cloudCallPermission") ?? '';
    createLeadCategory = await Common.getSharedPref("createLeadCategory") ?? '';
    updateLeadCategory = await Common.getSharedPref("updateLeadCategory") ?? '';
    deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory") ?? '';
    assignWork = await Common.getSharedPref("assignWork") ?? '';
    viewPendingWorks = await Common.getSharedPref("viewPendingWorks") ?? '';
    approvePayroll = await Common.getSharedPref("approvePayroll") ?? '';
    updateDashboard = await Common.getSharedPref("updateDashboard") ?? '';
    accessCallRecordingPermission =
        await Common.getSharedPref("accessCallRecordingPermission") ?? '';
    visibleP = await Common.getSharedPref("isVisible") ?? '';
    updateLeadPermission1 = updateLeadPermission == 'true';
    deleteLeadPermission1 = deleteLeadPermission == 'true';
    cloudCallPermission1 = cloudCallPermission == 'true';
    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';
    accessCallRecordingPermission1 = accessCallRecordingPermission == 'true';
    viewTargetReportPermission1 = viewTargetReportPermission == 'true';
    isVisible = visibleP != 'true';
    renewalPermission =
        await Common.getSharedPref("renewalPermission") ?? "false";
    accPermission = await Common.getSharedPref("accPermission") ?? "";
    String tog = await Common.getSharedPref("acc_toggle") ?? "";
    toggle = tog == "true";
    targetStaffId ??= userId;
    HttpService.showTransferHideOrShow().then((value) {
      if (value != null && value.status == true) {
        setState(() {
          showTransferFreshValue = value.data ?? false;
        });
      }
    });
  }

  Future<void> _checkLoginPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedDate = prefs.getString('loginPromptDismissedDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (dismissedDate != today && startAndStopWorkPermission == "true") {
      if (loginOrNot?.data != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showLoginPrompt(context);
          }
        });
      } else {
        await prefs.setString('loginPromptDismissedDate', today);
        _handleLocationCheckOnly();
      }
    } else if (loginOrNot?.data == true) {
      _handleLocationCheckOnly();
    }
  }

  Future<void> _handleLocationCheckOnly() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          final bool allowed = await Common.showLocationDisclosure(context);
          if (allowed) {
            await Geolocator.requestPermission();
          }
        }
      });
    }
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Start Your Day",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie.asset(
              //   'assets/lottie/morning_login.json',
              //   height: 120,
              //   repeat: true,
              // ),
              // const SizedBox(height: 16),
              const Text(
                "You haven't logged in today. Start your work session now?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final today = DateTime.now().toIso8601String().substring(0, 10);
                await prefs.setString('loginPromptDismissedDate', today);
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text("Later", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _handleLogin();
              },
              child: const Text("Start Work"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Lottie.asset(
                  'assets/lottie/location_loader.json',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Logging in...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final position = await _getLocation();
      if (position == null) return;
      final now = DateTime.now();
      final res = await HttpService.startWork(
        now,
        latitude: position.latitude,
        longitude: position.longitude,
        faceData: null,
      );
      if (!mounted) return;
      Navigator.of(context).pop();

      if (res?.status == true) {
        await Common.saveSharedPref("is_work_started", "true");
        setState(() => isWorkStarted = true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Started at ${DateFormat('hh:mm a').format(now)}"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        getData(widget.token, fromDate, toDate);
      } else {
        _showError(res?.message ?? "Failed to start work");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showError("Error: $e");
    }
  }

  Future<Position?> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (mounted) {
        final bool allowed = await Common.showLocationDisclosure(context);
        if (!allowed) {
          _showError("Location permission denied by user.");
          return null;
        }
      }
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Location permission required");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Location permission permanently denied");
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> getAccountDash() async {
    String fDate = DateFormat('dd-MM-yyyy').format(fromDate1);
    String tDate = DateFormat('dd-MM-yyyy').format(toDate1);
    accountDashboard = await HttpService.accountsDashboard(fDate, tDate);
    setState(() {});
  }

  Future<void> getRenewalDashboard() async {
    renewalDashboard = await HttpService.renewalDashboard();
    setState(() {});
  }

  Future<void> getCustomerList() async {
    try {
      CustomerListModel? customerData = await HttpService.customerList(
        widget.token,
      );
      if (customerData?.status == true) {}
    } catch (e) {
      print("Error loading customers: $e");
    }
  }

  Future<void> getStaffwise() async {
    if (moreloading) return;
    setState(() => moreloading = true);
    staffWise = await HttpService.leadDashboard1(
      widget.token,
      fromDate,
      toDate,
      fromDate1.toString(),
      toDate1.toString(),
    );
    await getLeadProgressbar(widget.token!, fromDate, toDate, "");
    _fetchCallStatusReport();
    _fetchStageWiseReport();
    _fetchLeadSourceReport();
    _fetchCategoryReport();
    if (staffWise != null) {
      _processReportData();
    }
    setState(() => moreloading = false);
  }

  void _processReportData() {
    reportDataMap.clear();
    for (int i = 0; i < (staffWise?.data?.categoryGraph?.length ?? 0); i++) {
      reportDataMap.addAll({
        staffWise!.data!.categoryGraph![i].categoryName.toString():
            staffWise!.data!.categoryGraph![i].categoryCount!.toDouble(),
      });
    }
    catNew = 0;
    catPending = 0;
    catFollowup = 0;
    catRejected = 0;
    catClosed = 0;
    for (int i = 0; i < (staffWise?.data?.categoryLeads?.length ?? 0); i++) {
      catNew += int.tryParse(
            staffWise!.data!.categoryLeads![i].newCount.toString(),
          ) ??
          0;
      catPending += int.tryParse(
            staffWise!.data!.categoryLeads![i].pendingCount.toString(),
          ) ??
          0;
      catFollowup += int.tryParse(
            staffWise!.data!.categoryLeads![i].followupCount.toString(),
          ) ??
          0;
      catRejected += int.tryParse(
            staffWise!.data!.categoryLeads![i].rejectedCount.toString(),
          ) ??
          0;
      catClosed += int.tryParse(
            staffWise!.data!.categoryLeads![i].confirmedCount.toString(),
          ) ??
          0;
    }
  }

  Future<void> getLeadProgressbar(
    String token,
    dynamic fromDate,
    dynamic toDate,
    String callStatus,
  ) async {
    object1 = await HttpService.leadProgressbar(
      token,
      fromDate.toString(),
      toDate.toString(),
      callStatus,
    );
  }

  Future<void> getLeadProgressbarNew(
    String token,
    dynamic fromDate,
    dynamic toDate,
    String callStatus,
  ) async {
    object1 = await HttpService.newleadProgressbar(
      token,
      fromDate.toString(),
      toDate.toString(),
      callStatus,
    );
  }

  Future<void> getLeadProgressbarFollowup(
    String token,
    dynamic fromDate,
    dynamic toDate,
    String callStatus,
  ) async {
    object1 = await HttpService.followupleadProgressbar(
      token,
      fromDate.toString(),
      toDate.toString(),
      callStatus,
    );
  }

  Future<void> getLeadProgressbarMissed(
    String token,
    dynamic fromDate,
    dynamic toDate,
    String callStatus,
  ) async {
    object1 = await HttpService.missedleadProgressbar(
      token,
      fromDate.toString(),
      toDate.toString(),
      callStatus,
    );
  }

  Future<void> getLeadProgressbarTransferred(
    String token,
    dynamic fromDate,
    dynamic toDate,
    String callStatus,
  ) async {
    object1 = await HttpService.transferredleadProgressbar(
      token,
      fromDate.toString(),
      toDate.toString(),
      callStatus,
    );
  }

  Future<void> getLeadProgressbarCalled(
    String token,
    dynamic fromDate,
    dynamic toDate,
    String callStatus,
  ) async {
    object1 = await HttpService.calledleadProgressbar(
      token,
      fromDate.toString(),
      toDate.toString(),
      callStatus,
    );
  }

  Future<void> getLeadProgressBarStaffData({
    required String leadStatus,
    required String selectedType,
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    staffProgressData = await HttpService.leadProgressBarStaff(
      fromDate: customFromDate?.toString() ?? fromDate.toString(),
      toDate: customToDate?.toString() ?? toDate.toString(),
      leadStatus: leadStatus,
      selectedType: selectedType,
    );
  }

  Future<void> getLeadProgressBarCategoryData({
    required String leadStatus,
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    categoryProgressData = await HttpService.leadProgressBarCategory(
      fromDate: customFromDate?.toString() ?? fromDate.toString(),
      toDate: customToDate?.toString() ?? toDate.toString(),
      leadStatus: leadStatus,
    );
  }

  Future<void> getLeadProgressBarStatusData({
    required String leadStatus,
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    statusProgressData = await HttpService.leadProgressBarStatus(
      fromDate: customFromDate?.toString() ?? fromDate.toString(),
      toDate: customToDate?.toString() ?? toDate.toString(),
      leadStatus: leadStatus,
    );
  }

  Future<void> _fetchCallStatusReport() async {
    if (isCallStatusLoading) return;
    setState(() => isCallStatusLoading = true);
    final data = await HttpService.callStatusReportData(
      fromDate: DateFormat(
        'dd-MM-yyyy',
      ).format(callStatusFromDate ?? DateTime.now()),
      toDate: DateFormat(
        'dd-MM-yyyy',
      ).format(callStatusToDate ?? DateTime.now()),
      staffId: callStatusStaffs.join(','),
    );
    if (!mounted) return;
    setState(() {
      callStatusReport = data;
      isCallStatusLoading = false;
      if (data != null && data.status == true) {
        callStatusLastUpdated = DateTime.now();
        _storeReportData(
          keyCallStatusReport,
          data,
          updatedKey: keyCallStatusLastUpdated,
        );
      }
    });
  }

  Future<void> _storeReportData(
    String key,
    dynamic data, {
    String? updatedKey,
  }) async {
    if (data == null) return;
    try {
      String jsonStr = jsonEncode(data.toJson());
      await Common.saveSharedPref(key, jsonStr);
      if (updatedKey != null) {
        await Common.saveSharedPref(
          updatedKey,
          DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      log("Error caching $key: $e");
    }
  }

  Future<void> _loadReportsFromCache() async {
    try {
      String? csJson = await Common.getSharedPref(keyCallStatusReport);
      if (csJson != null && csJson.isNotEmpty) {
        String? updatedStr = await Common.getSharedPref(
          keyCallStatusLastUpdated,
        );
        setState(() {
          callStatusReport = csr.CallStatusReportModel.fromJson(
            jsonDecode(csJson),
          );
          if (updatedStr != null) {
            callStatusLastUpdated = DateTime.parse(updatedStr);
          }
        });
      }

      String? swJson = await Common.getSharedPref(keyStageWiseReport);
      if (swJson != null && swJson.isNotEmpty) {
        String? updatedStr = await Common.getSharedPref(
          keyStageWiseLastUpdated,
        );
        setState(() {
          stagewiseReport = swr.StagewiseReportModel.fromJson(
            jsonDecode(swJson),
          );
          if (updatedStr != null) {
            stageWiseLastUpdated = DateTime.parse(updatedStr);
          }
        });
      }

      String? lsJson = await Common.getSharedPref(keyLeadSourceReport);
      if (lsJson != null && lsJson.isNotEmpty) {
        String? updatedStr = await Common.getSharedPref(
          keyLeadSourceLastUpdated,
        );
        setState(() {
          leadSourceReport = lsr.LeadSourceReportModel.fromJson(
            jsonDecode(lsJson),
          );
          leadSourceDetails = List.from(leadSourceReport!.data.details);
          if (updatedStr != null) {
            leadSourceLastUpdated = DateTime.parse(updatedStr);
          }
        });
      }

      String? catJson = await Common.getSharedPref(keyCategoryReport);
      if (catJson != null && catJson.isNotEmpty) {
        String? updatedStr = await Common.getSharedPref(keyCategoryLastUpdated);
        setState(() {
          categoryReport = catr.CategoryReportModel.fromJson(
            jsonDecode(catJson),
          );
          categoryDetails = List.from(categoryReport!.data.details);
          if (updatedStr != null) {
            categoryLastUpdated = DateTime.parse(updatedStr);
          }
        });
      }

      String? ccJson = await Common.getSharedPref(keyCloudCallReport);
      if (ccJson != null && ccJson.isNotEmpty) {
        String? updatedStr = await Common.getSharedPref(
          keyCloudCallLastUpdated,
        );
        setState(() {
          cloudCallReportData = ccr.CloudCallReportModel.fromJson(
            jsonDecode(ccJson),
          );
          if (updatedStr != null) {
            cloudCallLastUpdated = DateTime.parse(updatedStr);
          }
        });
      }

      String? pcJson = await Common.getSharedPref(keyPhoneCallReport);
      if (pcJson != null && pcJson.isNotEmpty) {
        String? updatedStr = await Common.getSharedPref(
          keyPhoneCallLastUpdated,
        );
        setState(() {
          phoneCallReportData = pcr.PhoneCallReportModel.fromJson(
            jsonDecode(pcJson),
          );
          if (updatedStr != null) {
            phoneCallLastUpdated = DateTime.parse(updatedStr);
          }
        });
      }

      // Load table updated timestamps
      String? cstStr = await Common.getSharedPref(
        keyCallStatusTableLastUpdated,
      );
      if (cstStr != null) {
        setState(() => callStatusTableLastUpdated = DateTime.parse(cstStr));
      }
      String? swtStr = await Common.getSharedPref(keyStageWiseTableLastUpdated);
      if (swtStr != null) {
        setState(() => stageWiseTableLastUpdated = DateTime.parse(swtStr));
      }
      String? lstStr = await Common.getSharedPref(
        keyLeadSourceTableLastUpdated,
      );
      if (lstStr != null) {
        setState(() => leadSourceTableLastUpdated = DateTime.parse(lstStr));
      }
      String? cattStr = await Common.getSharedPref(keyCategoryTableLastUpdated);
      if (cattStr != null) {
        setState(() => categoryTableLastUpdated = DateTime.parse(cattStr));
      }
    } catch (e) {
      log("Error loading reports from cache: $e");
    }
  }

  Future<void> _fetchCallStatusTableReport() async {
    setState(() => isCallStatusTableLoading = true);
    final data = await HttpService.callStatusReportTable(
      DateFormat('dd-MM-yyyy').format(callStatusFromDate ?? DateTime.now()),
      DateFormat('dd-MM-yyyy').format(callStatusToDate ?? DateTime.now()),
      callStatusStaffs.join(','),
      '',
    );
    if (!mounted) return;
    setState(() {
      callStatusTableData = data;
      isCallStatusTableLoading = false;
      if (data != null && data.status == true) {
        callStatusTableLastUpdated = DateTime.now();
        Common.saveSharedPref(
          keyCallStatusTableLastUpdated,
          callStatusTableLastUpdated!.toIso8601String(),
        );
      }
    });
  }

  Future<void> _fetchStageWiseReport() async {
    if (isStageWiseLoading) return;
    setState(() => isStageWiseLoading = true);
    final data = await HttpService.stagwWiseReportData(
      fromDate: stageWiseFromDate != null
          ? DateFormat('dd-MM-yyyy').format(stageWiseFromDate!)
          : "",
      toDate: stageWiseToDate != null
          ? DateFormat('dd-MM-yyyy').format(stageWiseToDate!)
          : "",
      staffId: stageWiseStaffs.join(','),
    );
    if (!mounted) return;
    setState(() {
      stagewiseReport = data;
      isStageWiseLoading = false;
      if (data != null &&
          (data.status == true || data.status.toString() == "success")) {
        stageWiseLastUpdated = DateTime.now();
        _storeReportData(
          keyStageWiseReport,
          data,
          updatedKey: keyStageWiseLastUpdated,
        );
      }
    });
  }

  Future<void> _fetchStageWiseTableReport() async {
    setState(() => isStageWiseTableLoading = true);
    final data = await HttpService.stageWiseReportTable(
      stageWiseFromDate != null
          ? DateFormat('dd-MM-yyyy').format(stageWiseFromDate!)
          : "",
      stageWiseToDate != null
          ? DateFormat('dd-MM-yyyy').format(stageWiseToDate!)
          : "",
      stageWiseStaffs.join(','),
      '',
    );
    if (!mounted) return;
    setState(() {
      stageWiseTableData = data;
      isStageWiseTableLoading = false;
      if (data != null &&
          (data.status == true || data.status.toString() == "success")) {
        stageWiseTableLastUpdated = DateTime.now();
        Common.saveSharedPref(
          keyStageWiseTableLastUpdated,
          stageWiseTableLastUpdated!.toIso8601String(),
        );
      }
    });
  }

  Future<void> _fetchLeadSourceReport({bool isLoadMore = false}) async {
    if (isLeadSourceLoading || isLeadSourceMoreLoading) return;

    if (isLoadMore) {
      if (!hasMoreLeadSource) return;
      setState(() => isLeadSourceMoreLoading = true);
      leadSourcePage++;
    } else {
      setState(() {
        isLeadSourceLoading = true;
        leadSourcePage = 1;
        leadSourceDetails.clear();
        hasMoreLeadSource = true;
      });
    }

    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    String from = leadSourceFromDate != null
        ? DateFormat('dd-MM-yyyy').format(leadSourceFromDate!)
        : DateFormat('dd-MM-yyyy').format(firstDayOfMonth);
    String to = leadSourceToDate != null
        ? DateFormat('dd-MM-yyyy').format(leadSourceToDate!)
        : DateFormat('dd-MM-yyyy').format(now);

    final data = await HttpService.leadSourceReportData(
      fromDate: from,
      toDate: to,
      staffId: leadSourceStaffs.join(','),
      page: leadSourcePage.toString(),
      pageSize: leadSourcePageSize.toString(),
      leadCategoryId: leadSourceCategories.join(','),
      productId: leadSourceProducts.join(','),
    );

    if (!mounted) return;
    setState(() {
      if (isLoadMore) {
        isLeadSourceMoreLoading = false;
      } else {
        isLeadSourceLoading = false;
      }

      if (data != null && data.status == true) {
        leadSourceReport = data;
        leadSourceLastUpdated = DateTime.now();
        _storeReportData(
          keyLeadSourceReport,
          data,
          updatedKey: keyLeadSourceLastUpdated,
        );
        var newDetails = data.data.details;

        for (var item in newDetails) {
          if (!leadSourceDetails.any(
            (existing) => existing.leadSourceId == item.leadSourceId,
          )) {
            leadSourceDetails.add(item);
          }
        }

        if (newDetails.length < leadSourcePageSize) {
          hasMoreLeadSource = false;
        }
      } else {
        hasMoreLeadSource = false;
      }
    });
  }

  Future<void> _fetchLeadSourceTableReport() async {
    setState(() => isLeadSourceTableLoading = true);

    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    String from = leadSourceFromDate != null
        ? DateFormat('dd-MM-yyyy').format(leadSourceFromDate!)
        : DateFormat('dd-MM-yyyy').format(firstDayOfMonth);
    String to = leadSourceToDate != null
        ? DateFormat('dd-MM-yyyy').format(leadSourceToDate!)
        : DateFormat('dd-MM-yyyy').format(now);

    final data = await HttpService.leadSourceReportTable(
      from,
      to,
      leadSourceStaffs.join(','),
      '',
    );
    if (!mounted) return;
    setState(() {
      leadSourceTableData = data;
      isLeadSourceTableLoading = false;
      if (data != null && data.status == true) {
        leadSourceTableLastUpdated = DateTime.now();
        Common.saveSharedPref(
          keyLeadSourceTableLastUpdated,
          leadSourceTableLastUpdated!.toIso8601String(),
        );
      }
    });
  }

  Future<void> _fetchCategoryReport({bool isLoadMore = false}) async {
    if (isCategoryLoading || isCategoryMoreLoading) return;

    if (isLoadMore) {
      if (!hasMoreCategory) return;
      setState(() => isCategoryMoreLoading = true);
      categoryPage++;
    } else {
      setState(() {
        isCategoryLoading = true;
        categoryPage = 1;
        categoryDetails.clear();
        hasMoreCategory = true;
      });
    }

    final now = DateTime.now();

    String from = categoryFromDate != null
        ? DateFormat('dd-MM-yyyy').format(categoryFromDate!)
        : DateFormat('dd-MM-yyyy').format(now);
    String to = categoryToDate != null
        ? DateFormat('dd-MM-yyyy').format(categoryToDate!)
        : DateFormat('dd-MM-yyyy').format(now);

    final data = await HttpService.leadCategoryReportData(
      fromDate: from,
      toDate: to,
      staffId: categoryStaffs.join(','),
      page: categoryPage.toString(),
      pageSize: categoryPageSize.toString(),
    );

    if (!mounted) return;
    setState(() {
      if (isLoadMore) {
        isCategoryMoreLoading = false;
      } else {
        isCategoryLoading = false;
      }

      if (data != null && data.status == true) {
        categoryReport = data;
        categoryLastUpdated = DateTime.now();
        _storeReportData(
          keyCategoryReport,
          data,
          updatedKey: keyCategoryLastUpdated,
        );
        var newDetails = data.data.details;

        for (var item in newDetails) {
          if (!categoryDetails.any(
            (existing) => existing.leadCategoryId == item.leadCategoryId,
          )) {
            categoryDetails.add(item);
          }
        }

        if (newDetails.length < categoryPageSize) {
          hasMoreCategory = false;
        }
      } else {
        hasMoreCategory = false;
      }
    });
  }

  Future<void> _fetchCategoryTableReport() async {
    setState(() => isCategoryTableLoading = true);
    final data = await HttpService.categoryReportTable(
      DateFormat('dd-MM-yyyy').format(categoryFromDate ?? DateTime.now()),
      DateFormat('dd-MM-yyyy').format(categoryToDate ?? DateTime.now()),
      categoryStaffs.join(','),
      '',
    );
    if (!mounted) return;
    setState(() {
      categoryTableData = data;
      isCategoryTableLoading = false;
      if (data != null && data.status == true) {
        categoryTableLastUpdated = DateTime.now();
        Common.saveSharedPref(
          keyCategoryTableLastUpdated,
          categoryTableLastUpdated!.toIso8601String(),
        );
      }
    });
  }

  Future<void> _shareTableDataAsPdf(String title, dynamic tableData) async {
    if (tableData == null) return;

    try {
      final pdf = pw.Document();
      List<String> headers = [];
      List<List<String>> rows = [];

      String dateRange = "";
      if (title.contains("Call Status")) {
        dateRange =
            "${DateFormat('dd-MM-yyyy').format(callStatusFromDate ?? DateTime.now())} to ${DateFormat('dd-MM-yyyy').format(callStatusToDate ?? DateTime.now())}";
      } else if (title.contains("Stage-wise") ||
          title.contains("Active Lead Summary")) {
        dateRange =
            "${DateFormat('dd-MM-yyyy').format(stageWiseFromDate ?? DateTime.now())} to ${DateFormat('dd-MM-yyyy').format(stageWiseToDate ?? DateTime.now())}";
      } else if (title.contains("Lead Source")) {
        dateRange =
            "${DateFormat('dd-MM-yyyy').format(leadSourceFromDate ?? DateTime.now())} to ${DateFormat('dd-MM-yyyy').format(leadSourceToDate ?? DateTime.now())}";
      } else if (title.contains("Category")) {
        dateRange =
            "${DateFormat('dd-MM-yyyy').format(categoryFromDate ?? DateTime.now())} to ${DateFormat('dd-MM-yyyy').format(categoryToDate ?? DateTime.now())}";
      }

      if (tableData is String &&
          (tableData == "Cloud Call Report" ||
              tableData == "Phone Call Report")) {
        headers = ["Staff", "Total", "Connected", "Duration"];
        rows = [
          ["John Doe", "45", "32", "02:15:30"],
          ["Jane Smith", "38", "28", "01:45:12"],
          ["Mike Johnson", "52", "41", "03:10:45"],
        ];
      } else if (tableData is csrt.CallStatusReportResponse ||
          (tableData is List<csrt.CallStatusReportData>)) {
        final List<csrt.CallStatusReportData> items =
            tableData is csrt.CallStatusReportResponse
                ? tableData.data
                : List<csrt.CallStatusReportData>.from(tableData);
        if (items.isNotEmpty) {
          headers = ["Staff Name"];
          headers.addAll(items.first.statuses.map((s) => s.callResponse));
          headers.add("Total");

          for (var item in items) {
            List<String> row = [item.staffName];
            row.addAll(item.statuses.map((s) => s.total.toString()));
            row.add(item.totalCount.toString());
            rows.add(row);
          }
        }
      } else if (tableData is swrt.StagewiseReportResponse ||
          (tableData is List<swrt.StagewiseReportData>)) {
        final List<swrt.StagewiseReportData> items =
            tableData is swrt.StagewiseReportResponse
                ? tableData.data
                : List<swrt.StagewiseReportData>.from(tableData);
        if (items.isNotEmpty) {
          headers = ["Staff Name"];
          headers.addAll(items.first.statuses.map((s) => s.callResult));
          headers.add("Total");

          for (var item in items) {
            List<String> row = [item.staffName];
            row.addAll(item.statuses.map((s) => s.total.toString()));
            row.add(item.totalCount.toString());
            rows.add(row);
          }
        }
      } else if (tableData is lsrt.LeadSourceReportResponse ||
          (tableData is List<lsrt.LeadSourceReportData>)) {
        final List<lsrt.LeadSourceReportData> items =
            tableData is lsrt.LeadSourceReportResponse
                ? tableData.data
                : List<lsrt.LeadSourceReportData>.from(tableData);
        if (items.isNotEmpty) {
          headers = ["Staff Name"];
          headers.addAll(items.first.statuses.map((s) => s.leadSource));
          headers.add("Total");

          for (var item in items) {
            List<String> row = [item.staffName];
            row.addAll(item.statuses.map((s) => s.total.toString()));
            row.add(item.totalCount.toString());
            rows.add(row);
          }
        }
      } else if (tableData is catrt.CategoryReportTableModel ||
          (tableData is List<catrt.StaffCategoryData>)) {
        final List<catrt.StaffCategoryData> items =
            tableData is catrt.CategoryReportTableModel
                ? (tableData.data ?? [])
                : List<catrt.StaffCategoryData>.from(tableData);
        if (items.isNotEmpty) {
          headers = ["Staff Name"];
          headers.addAll(
            items.first.statuses?.map((s) => s.leadCategory ?? '') ?? [],
          );
          headers.add("Total");

          for (var item in items) {
            List<String> row = [item.staffName ?? 'N/A'];
            row.addAll(
              item.statuses?.map((s) => s.total?.toString() ?? '0') ?? [],
            );
            row.add(item.totalCount?.toString() ?? '0');
            rows.add(row);
          }
        }
      }

      if (headers.isNotEmpty) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
              width: PdfPageFormat.a4.height,
              height: PdfPageFormat.a4.width,
            ),
            build: (pw.Context context) => [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(title),
                    if (dateRange.isNotEmpty)
                      pw.Text(
                        "Date: $dateRange",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                  ],
                ),
              ),
              pw.Table.fromTextArray(
                headers: headers,
                data: rows,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellHeight: 30,
                cellAlignments: {0: pw.Alignment.centerLeft},
              ),
            ],
          ),
        );

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/${title.replaceAll(' ', '_')}.pdf");
        await file.writeAsBytes(await pdf.save());

        await Share.shareXFiles([XFile(file.path)], text: title);
      }
    } catch (e) {
      log("Error generating PDF: $e");
      Common.toastMessaage("Error generating PDF", accentRed);
    }
  }

  Future<void> _openFilterForSection(String title) async {
    if (title.contains('Lead Source') && productSectionModel == null) {
      productSectionModel = await HttpService.leadProductSection();
    }
    DateTime initialFrom;
    DateTime initialTo;
    List<String> initialStaffs;
    List<String>? initialProducts;
    List<String>? initialCategorys;

    if (title.contains('Call Status')) {
      initialFrom = callStatusFromDate ?? DateTime.now();
      initialTo = callStatusToDate ?? DateTime.now();
      initialStaffs = callStatusStaffs;
    } else if (title.contains('Active Lead Summary') ||
        title.contains('Stage-wise')) {
      initialFrom = stageWiseFromDate ?? DateTime.now();
      initialTo = stageWiseToDate ?? DateTime.now();
      initialStaffs = stageWiseStaffs;
    } else if (title.contains('Lead Source')) {
      DateTime now = DateTime.now();
      initialFrom = leadSourceFromDate ?? DateTime(now.year, now.month, 1);
      DateTime lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0);
      initialTo = leadSourceToDate ??
          (lastDayOfCurrentMonth.isAfter(now) ? now : lastDayOfCurrentMonth);
      initialStaffs = leadSourceStaffs;
      initialProducts = leadSourceProducts;
      initialCategorys = leadSourceCategories;
    } else {
      initialFrom = categoryFromDate ?? fromDate1;
      initialTo = categoryToDate ?? toDate1;
      initialStaffs = categoryStaffs;
    }

    _showReportFilterDialog(
      title: title,
      initialFromDate: initialFrom,
      initialToDate: initialTo,
      initialStaffIds: initialStaffs,
      initialProductIds: initialProducts,
      initialCategoryIds: initialCategorys,
      onApply: (from, to, staffIds, productIds, categoryIds) async {
        if (title.contains('Call Status')) {
          setState(() {
            callStatusFromDate = from;
            callStatusToDate = to;
            callStatusStaffs = staffIds;
          });
          await Common.saveSharedPref(
            "callStatusFromDate",
            from.toIso8601String(),
          );
          await Common.saveSharedPref("callStatusToDate", to.toIso8601String());
          await Common.saveSharedPref(
            "callStatusStaffIdStr",
            staffIds.join(","),
          );
          await _fetchCallStatusReport();
          if (showCallStatusTable) await _fetchCallStatusTableReport();
          if (title == "Cloud Call Report") await _fetchCloudCallReport();
          if (title == "Phone Call Report") await _fetchPhoneCallReport();
        } else if (title.contains('Active Lead Summary') ||
            title.contains('Stage-wise')) {
          setState(() {
            stageWiseFromDate = from;
            stageWiseToDate = to;
            stageWiseStaffs = staffIds;
          });
          await Common.saveSharedPref(
            "stageWiseFromDate",
            from.toIso8601String(),
          );
          await Common.saveSharedPref("stageWiseToDate", to.toIso8601String());
          await Common.saveSharedPref(
            "stageWiseStaffIdStr",
            staffIds.join(","),
          );
          await _fetchStageWiseReport();
          if (showStageWiseTable) await _fetchStageWiseTableReport();
        } else if (title.contains('Lead Source')) {
          setState(() {
            leadSourceFromDate = from;
            leadSourceToDate = to;
            leadSourceStaffs = staffIds;
            leadSourceProducts = productIds ?? [];
            leadSourceCategories = categoryIds ?? [];
          });
          await Common.saveSharedPref(
            "leadSourceFromDate",
            from.toIso8601String(),
          );
          await Common.saveSharedPref("leadSourceToDate", to.toIso8601String());
          await Common.saveSharedPref(
            "leadSourceStaffIdStr",
            staffIds.join(","),
          );
          await Common.saveSharedPref(
            "leadSourceProductIdStr",
            (productIds ?? []).join(","),
          );
          await Common.saveSharedPref(
            "leadSourceCategoryIdStr",
            (categoryIds ?? []).join(","),
          );
          await _fetchLeadSourceReport();
          if (showLeadSourceTable) await _fetchLeadSourceTableReport();
        } else {
          setState(() {
            categoryFromDate = from;
            categoryToDate = to;
            categoryStaffs = staffIds;
          });
          await Common.saveSharedPref(
            "categoryFromDate",
            from.toIso8601String(),
          );
          await Common.saveSharedPref("categoryToDate", to.toIso8601String());
          await Common.saveSharedPref("categoryStaffIdStr", staffIds.join(","));
          await _fetchCategoryReport();
          if (showCategoryTable) await _fetchCategoryTableReport();
        }
      },
    );
  }

  void _showReportFilterDialog({
    required String title,
    required DateTime initialFromDate,
    required DateTime initialToDate,
    required List<String> initialStaffIds,
    List<String>? initialProductIds,
    List<String>? initialCategoryIds,
    required Function(
      DateTime from,
      DateTime to,
      List<String> staffIds,
      List<String>? productIds,
      List<String>? categoryIds,
    ) onApply,
  }) {
    DateTime? tempFrom = initialFromDate;
    DateTime tempTo = initialToDate;
    List<String> tempStaffIds = List.from(initialStaffIds);
    List<String> tempProductIds = List.from(initialProductIds ?? []);
    List<String> tempCategoryIds = List.from(initialCategoryIds ?? []);
    final staffs = staffList;
    final categories = commonDetails?.data.leadCategory ?? [];

    String selectedCategory = 'Date Range';
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    TextEditingController searchController = TextEditingController();
    TextEditingController searchProductController = TextEditingController();
    TextEditingController searchCategoryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildCategoryItem(String categoryName, IconData icon) {
              final isSelected = selectedCategory == categoryName;
              bool hasFilters = false;
              if (categoryName == 'Date Range') {
                hasFilters = true;
              }
              if (categoryName == 'Staff') {
                hasFilters = tempStaffIds.isNotEmpty;
              }
              if (categoryName == 'Products') {
                hasFilters = tempProductIds.isNotEmpty;
              }
              if (categoryName == 'Categories') {
                hasFilters = tempCategoryIds.isNotEmpty;
              }

              return GestureDetector(
                onTap: () =>
                    setModalState(() => selectedCategory = categoryName),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: isSelected
                        ? const Border(
                            left: BorderSide(color: Colors.blue, width: 3),
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Icon(
                            icon,
                            color: isSelected
                                ? Colors.blue
                                : const Color(0xFF8F9BB3),
                            size: 24,
                          ),
                          if (hasFilters)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.blue
                              : const Color(0xFF8F9BB3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget buildDateField(
              String label,
              DateTime? value,
              bool isFrom,
              Function(DateTime) onSelect,
            ) {
              return InkWell(
                onTap: () async {
                  final dateFilterMonths = await Common.getDateFilter();
                  final DateTime now = DateTime.now();

                  DateTime firstDate;
                  DateTime lastDate;
                  DateTime initialDate;

                  if (isFrom) {
                    if (tempTo != null) {
                      lastDate = tempTo!;
                      if (dateFilterMonths != null && dateFilterMonths > 0) {
                        firstDate = Common.subtractMonths(tempTo!, dateFilterMonths);
                      } else {
                        firstDate = DateTime(2020);
                      }
                    } else {
                      firstDate = DateTime(2020);
                      lastDate = DateTime(2100);
                    }
                    initialDate = value ?? lastDate;
                    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
                    if (initialDate.isAfter(lastDate)) initialDate = lastDate;
                  } else {
                    if (tempFrom != null) {
                      firstDate = tempFrom!;
                      if (dateFilterMonths != null && dateFilterMonths > 0) {
                        lastDate = Common.addMonths(tempFrom!, dateFilterMonths);
                      } else {
                        lastDate = DateTime(2100);
                      }
                    } else {
                      firstDate = DateTime(2020);
                      lastDate = DateTime(2100);
                    }
                    initialDate = value ?? firstDate;
                    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
                    if (initialDate.isAfter(lastDate)) initialDate = lastDate;
                  }

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                  );

                  if (picked != null) {
                    if (isFrom) {
                      setModalState(() {
                        tempFrom = picked;
                        if (dateFilterMonths != null && dateFilterMonths > 0) {
                          final maxTo = Common.addMonths(picked, dateFilterMonths);
                          if (tempTo != null &&
                              (tempTo!.isBefore(picked) || tempTo!.isAfter(maxTo))) {
                            tempTo = picked;
                          }
                        } else if (tempTo != null && tempTo!.isBefore(picked)) {
                          tempTo = picked;
                        }
                      });
                      onSelect(picked);
                    } else {
                      setModalState(() {
                        tempTo = picked;
                        if (dateFilterMonths != null && dateFilterMonths > 0) {
                          final minFrom = Common.subtractMonths(picked, dateFilterMonths);
                          if (tempFrom != null &&
                              (tempFrom!.isBefore(minFrom) || tempFrom!.isAfter(picked))) {
                            tempFrom = null; // Clear/reset From Date if invalid
                          }
                        } else if (tempFrom != null && tempFrom!.isAfter(picked)) {
                          tempFrom = null;
                        }
                      });
                      onSelect(picked);
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE4E9F2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8F9BB3),
                            ),
                          ),
                          Text(
                            value != null
                                ? formatter.format(value)
                                : 'Select Date',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget buildQuickDateFilters({
              required VoidCallback onToday,
              required VoidCallback onThisMonth,
            }) {
              final now = DateTime.now();
              final isTodaySelected = tempFrom != null &&
                  tempFrom!.year == now.year &&
                  tempFrom!.month == now.month &&
                  tempFrom!.day == now.day &&
                  tempTo.year == now.year &&
                  tempTo.month == now.month &&
                  tempTo.day == now.day;

              final firstDayOfMonth = DateTime(now.year, now.month, 1);
              final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
              final isThisMonthSelected = tempFrom != null &&
                  tempFrom!.year == firstDayOfMonth.year &&
                  tempFrom!.month == firstDayOfMonth.month &&
                  tempFrom!.day == firstDayOfMonth.day &&
                  tempTo.year == lastDayOfMonth.year &&
                  tempTo.month == lastDayOfMonth.month &&
                  tempTo.day == lastDayOfMonth.day;

              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onToday,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTodaySelected
                            ? Colors.blue
                            : const Color(0xFFE3F2FD),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 40),
                      ),
                      child: Text(
                        "Today",
                        style: TextStyle(
                          fontSize: 12,
                          color: isTodaySelected ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onThisMonth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isThisMonthSelected
                            ? Colors.blue
                            : const Color(0xFFE3F2FD),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 40),
                      ),
                      child: Text(
                        "This Month",
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isThisMonthSelected ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            Widget buildDateOptions() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date Range',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  buildDateField(
                    'From Date',
                    tempFrom,
                    true,
                    (date) => setModalState(() => tempFrom = date),
                  ),
                  const SizedBox(height: 12),
                  buildDateField(
                    'To Date',
                    tempTo,
                    false,
                    (date) => setModalState(() => tempTo = date),
                  ),
                  const SizedBox(height: 16),
                  buildQuickDateFilters(
                    onToday: () async {
                      final now = DateTime.now();
                      final dateFilterMonths = await Common.getDateFilter();
                      setModalState(() {
                        tempTo = now;
                        tempFrom = now;
                        if (dateFilterMonths != null && dateFilterMonths > 0) {
                          final minFrom = Common.subtractMonths(now, dateFilterMonths);
                          if (tempFrom!.isBefore(minFrom)) {
                            tempFrom = minFrom;
                          }
                        }
                      });
                    },
                    onThisMonth: () async {
                      final now = DateTime.now();
                      final dateFilterMonths = await Common.getDateFilter();
                      final firstDayOfMonth = DateTime(now.year, now.month, 1);
                      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
                      setModalState(() {
                        tempTo = lastDayOfMonth;
                        DateTime fromCandidate = firstDayOfMonth;
                        if (dateFilterMonths != null && dateFilterMonths > 0) {
                          final minFrom = Common.subtractMonths(lastDayOfMonth, dateFilterMonths);
                          if (fromCandidate.isBefore(minFrom)) {
                            fromCandidate = minFrom;
                          }
                        }
                        tempFrom = fromCandidate;
                      });
                    },
                  ),
                ],
              );
            }

            Widget buildStaffOptions() {
              return Column(
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search Staff...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: staffs.length,
                      itemBuilder: (context, index) {
                        final item = staffs[index];
                        final name = item.name;
                        final id = item.userIdStaff.toString();

                        if (searchController.text.isNotEmpty &&
                            !name.toLowerCase().contains(
                                  searchController.text.toLowerCase(),
                                )) {
                          return const SizedBox.shrink();
                        }

                        final isSelected = tempStaffIds.contains(id);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) => setModalState(() {
                            if (isSelected) {
                              tempStaffIds.remove(id);
                            } else {
                              tempStaffIds.add(id);
                            }
                          }),
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            Widget buildProductOptions() {
              final products = productSectionModel?.data ?? [];
              return Column(
                children: [
                  TextField(
                    controller: searchProductController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search Products...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        final name = item.productName ?? "";
                        final id = item.id?.toString() ?? "";

                        if (searchProductController.text.isNotEmpty &&
                            !name.toLowerCase().contains(
                                  searchProductController.text.toLowerCase(),
                                )) {
                          return const SizedBox.shrink();
                        }

                        final isSelected = tempProductIds.contains(id);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) => setModalState(() {
                            if (isSelected) {
                              tempProductIds.remove(id);
                            } else {
                              tempProductIds.add(id);
                            }
                          }),
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            Widget buildCategoryOptions() {
              return Column(
                children: [
                  TextField(
                    controller: searchCategoryController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search Categories...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final item = categories[index];
                        final name = item.leadCategory;
                        final id = item.leadCategoryId.toString();

                        if (searchCategoryController.text.isNotEmpty &&
                            !name.toLowerCase().contains(
                                  searchCategoryController.text.toLowerCase(),
                                )) {
                          return const SizedBox.shrink();
                        }

                        final isSelected = tempCategoryIds.contains(id);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) => setModalState(() {
                            if (isSelected) {
                              tempCategoryIds.remove(id);
                            } else {
                              tempCategoryIds.add(id);
                            }
                          }),
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return Container(
              margin: EdgeInsets.only(top: AppBar().preferredSize.height),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$title Filters',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A59),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF2E3A59),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 350,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFE4E9F2)),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                buildCategoryItem(
                                  'Date Range',
                                  Icons.calendar_today,
                                ),
                                buildCategoryItem(
                                  'Staff',
                                  Icons.people_outline,
                                ),
                                if (initialProductIds != null)
                                  buildCategoryItem(
                                    'Products',
                                    Icons.inventory_2_outlined,
                                  ),
                                if (initialCategoryIds != null)
                                  buildCategoryItem(
                                    'Categories',
                                    Icons.category_outlined,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: selectedCategory == 'Date Range'
                                ? buildDateOptions()
                                : selectedCategory == 'Staff'
                                    ? buildStaffOptions()
                                    : selectedCategory == 'Products'
                                        ? buildProductOptions()
                                        : buildCategoryOptions(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final dateFilterMonths = await Common.getDateFilter();
                              final now = DateTime.now();
                              DateTime defaultFrom = now.subtract(const Duration(days: 30));
                              if (dateFilterMonths != null && dateFilterMonths > 0) {
                                final minFrom = Common.subtractMonths(now, dateFilterMonths);
                                if (defaultFrom.isBefore(minFrom)) {
                                  defaultFrom = minFrom;
                                }
                              }
                              setModalState(() {
                                tempStaffIds.clear();
                                tempFrom = defaultFrom;
                                tempTo = now;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFE4E9F2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Color(0xFF2E3A59)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final dateFilterMonths = await Common.getDateFilter();
                              DateTime finalFrom = tempFrom ?? tempTo;
                              if (dateFilterMonths != null && dateFilterMonths > 0) {
                                final minFrom = Common.subtractMonths(tempTo, dateFilterMonths);
                                if (finalFrom.isBefore(minFrom)) {
                                  finalFrom = minFrom;
                                }
                              }
                              if (finalFrom.isAfter(tempTo)) {
                                finalFrom = tempTo;
                              }
                              Navigator.pop(context);
                              onApply(
                                finalFrom,
                                tempTo,
                                tempStaffIds,
                                tempProductIds,
                                tempCategoryIds,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: veryLightBlue,
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        endDrawer: DraweScreen(widget.token!),
        bottomNavigationBar: configure != null
            ? BottomNavigation(
                widget.token!,
                phoneCallLogPermission: phoneCallLogPermission,
                name: name,
                userId: userId,
                scaffoldKey: _scaffoldKey,
                showMenuIcon: false,
              )
            : const SizedBox(),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Warning"),
        content: const Text("Are you sure to exit app?"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              exit(0);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildBody() {
    if (timeOut) {
      return _buildErrorWidget();
    }

    return RefreshIndicator(
      onRefresh: () => getData(widget.token, fromDate, toDate, isRefresh: true),
      color: primaryBlue,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _buildTabBar(),
              ),
            ),
          ];
        },
        body: _buildDashboardContent(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 65,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryBlue,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          _buildProfileSection(),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
      actions: [const SizedBox.shrink()],
    );
  }

  Widget _buildProfileSection() {
    return InkWell(
      onTap: () async {
        try {
          final result = await HttpService.getWorkStatus();
          if (result != null && result.data.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout Blocked'),
                content: const Text(
                  'Work is in progress. Please close all work before logging out.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            logout(context);
          }
        } catch (e) {
          log('Error checking work status: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to check work status')),
          );
        }
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: userDashboard != null
                  ? NetworkImage(userDashboard!.data.profilePic)
                  : null,
              child: userDashboard == null
                  ? const Icon(Icons.person, color: Color(0xFF2a86c9))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (startAndStopWorkPermission == "true" && userDashboard != null)
          StartStopToggle(
            initialStatus: userDashboard!.data.loginCheck,
            onToggle: (bool started) {
              setState(() {
                userDashboard!.data.loginCheck = started;
              });
            },
            setDashboardLoading: (bool loading) {
              setState(() => isLoading = loading);
            },
          ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (notificationCount != '0')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(
                    widget.token,
                    createLeadCategory1,
                    updateLeadCategory1,
                    deleteLeadCategory1,
                  ),
                ),
              ).then((_) => getData(widget.token, fromDate, toDate));
            },
          ),
        ),
        const SizedBox(width: 8),
        SettingsMenuWidget(
          token: widget.token!,
          name: name,
          userId: userId,
          staffId: staffId,
          isExpired: isExpired,
          configure: configure,
          leadDashboard: leadDashboard,
          fromdate: fromDate.toString(),
          todate: toDate.toString(),
          loadmore: loadmore,
          onDataRefresh: () => getData(widget.token, fromDate, toDate),
          onStaffwiseRefresh: getStaffwise,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: primaryBlue,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: [
          _buildAnimatedTab('LIST', 0),
          _buildAnimatedTab('DASHBOARD', 1),
          _buildAnimatedTab('REPORT', 2),
        ],
      ),
    );
  }

  Widget _buildAnimatedTab(String text, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          double offset = _tabController.animation!.value - index;
          double scale = 1.0 + (0.15 * (1.0 - offset.abs().clamp(0.0, 1.0)));
          return Transform.scale(
            scale: scale,
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (isLoading) {
      return _buildShimmerLoading();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        RefreshIndicator(
          key: _listTabRefreshIndicatorKey,
          onRefresh: () =>
              getData(widget.token, fromDate, toDate, isRefresh: true),
          displacement: 40,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isListTabLoadingMore &&
                  _hasMoreListTabLeads &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                _listTabFilter == "Followup"
                    ? _fetchTabLeadsActive(isLoadMore: true)
                    : _fetchTabLeads(isLoadMore: true);
                return true;
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildListTab(),
            ),
          ),
        ),
        RefreshIndicator(
          onRefresh: () =>
              getData(widget.token, fromDate, toDate, isRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: _buildDashboardTab(),
          ),
        ),
        RefreshIndicator(
          onRefresh: () =>
              getData(widget.token, fromDate, toDate, isRefresh: true),
          child: _buildReportTab(),
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuickActions(),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.05,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          children: [
            _buildDashboardBox(
              title: 'New',
              mainValue:
                  (dashboardCounts?.data?.leads?.newLeads ?? 0).toString(),
              color: const Color(0xFF2a86c9),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewLeads(
                                widget.token,
                                updateLeadPermission1,
                                deleteLeadPermission1,
                                cloudCallPermission1,
                                pageName: "Today's Leads",
                                fromDate: "",
                                toDate: "",
                                status: '1',
                                apiType: 'today',
                              ),
                            ),
                          ).then((_) {
                            getData(widget.token, fromDate, toDate);
                          });
                        },
                        child: Column(
                          children: [
                            const Text(
                              "Today's",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (dashboardCounts?.data?.leads?.newToday ?? 0)
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.white54),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewLeads(
                                widget.token,
                                updateLeadPermission1,
                                deleteLeadPermission1,
                                cloudCallPermission1,
                                pageName: "Missed Leads",
                                fromDate: "",
                                toDate: "",
                                status: '1',
                                apiType: 'missed',
                              ),
                            ),
                          ).then((_) {
                            getData(widget.token, fromDate, toDate);
                          });
                        },
                        child: Column(
                          children: [
                            const Text(
                              "Missed",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (dashboardCounts?.data?.leads?.newMissed ?? 0)
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDashboardBox(
              title: 'Active',
              mainValue:
                  (dashboardCounts?.data?.leads?.activeLeads ?? 0).toString(),
              color: Colors.orange,
              child: _buildBoxIcons('Active', '2', 'Active Leads'),
            ),
            _buildDashboardBox(
              title: 'Closed',
              mainValue: isClosedDateFiltered
                  ? closedCount
                  : (dashboardCounts?.data?.leads?.closedLeads ?? 0).toString(),
              color: callGreen,
              child: _buildBoxIcons(
                'Closed',
                '4',
                'Closed Leads',
                customFromDate:
                    isClosedDateFiltered ? fromDateClosed : fromDate,
                customToDate: isClosedDateFiltered ? toDateClosed : toDate,
              ),
            ),
            _buildDashboardBox(
              title: 'Lost',
              mainValue: isLostDateFiltered
                  ? lostCount
                  : (dashboardCounts?.data?.leads?.rejectedLeads ?? 0)
                      .toString(),
              color: accentRed,
              child: _buildBoxIcons(
                'Lost',
                '3',
                'Lost Leads',
                customFromDate: isLostDateFiltered ? fromDateLost : fromDate,
                customToDate: isLostDateFiltered ? toDateLost : toDate,
              ),
            ),
          ],
        ),
        if (viewTargetReportPermission1) ...[
          const SizedBox(height: 24),
          _buildTargetSection(),
        ],
        if (isVisible) ...[const SizedBox(height: 24), _buildModuleCarousel()],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTargetSection() {
    List<Target> targets = dashboardCounts?.data?.target ?? [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Targets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            _buildTargetCalendar(),
            const Spacer(),
            GestureDetector(
              onTap: _showStaffSelectionModal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: appBarStart.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_pin_rounded,
                      color: appBarStart,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      targetStaffId != null && targetStaffId!.isNotEmpty
                          ? (staffList
                              .firstWhere(
                                (s) =>
                                    s.userIdStaff.toString() == targetStaffId,
                                orElse: () => sl.Staff(
                                  id: '',
                                  name: 'All Staff',
                                  userIdStaff: '',
                                ),
                              )
                              .name)
                          : "All Staff",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: appBarStart,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: appBarStart,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (targets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No targets available"),
          )
        else
          ...targets.map((target) => _buildTargetItem(target)),
      ],
    );
  }

  Widget _buildTargetItem(Target target) {
    final double progress =
        double.tryParse(target.progressPercentage ?? "0.0") ?? 0.0;
    final double progressFraction = (progress / 100).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.groupName ?? 'Target',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const Text(
                        'Performance tracker',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: borderLight,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 10,
                    width: constraints.maxWidth * progressFraction,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTargetStat(
                'Target Amount',
                '₹${target.maxAmount ?? "0"}',
                Icons.outlined_flag,
              ),
              _buildTargetStat(
                'Total Achieved',
                '₹${target.achieved ?? "0"}',
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardBox({
    required String title,
    required String mainValue,
    required Color color,
    required Widget child,
  }) {
    return InkWell(
      onTap: () {
        if (title.contains('New')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewLeads(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'New Leads',
                fromDate: "",
                toDate: "",
                status: '1',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate, isRefresh: true);
          });
        } else if (title.contains('Followup') || title.contains('Active')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveLeads(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Active Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '2',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate, isRefresh: true);
          });
        } else if (title.contains('Closed')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Closed Leads',
                fromDate: isClosedDateFiltered
                    ? fromDateClosed.toString()
                    : fromDate.toString(),
                toDate: isClosedDateFiltered
                    ? toDateClosed.toString()
                    : toDate.toString(),
                status: '4',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate, isRefresh: true);
          });
        } else if (title.contains('Lost')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Lost Leads',
                fromDate: isLostDateFiltered
                    ? fromDateLost.toString()
                    : fromDate.toString(),
                toDate: isLostDateFiltered
                    ? toDateLost.toString()
                    : toDate.toString(),
                status: '3',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate, isRefresh: true);
          });
        } else if (title.contains('Missed')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Missed Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '0',
                leadType: '1',
                callStatus: '-1',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate, isRefresh: true);
          });
        } else if (title.contains('Called')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Called Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '0',
                leadType: '-1',
                callStatus: '1',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate, isRefresh: true);
          });
        } else if (title.contains('Transferred')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Transferred Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '0',
                leadType: '2',
                callStatus: '-2',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate, isRefresh: true);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                _getBoxIcon(title),
                size: 50,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (title == 'Closed' || title == 'Lost')
                        GestureDetector(
                          onTap: () => _showStatusDateRangePickerDialog(title),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.filter_list_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mainValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBoxIcon(String title) {
    if (title.contains('New')) return Icons.person_add_alt_1_rounded;
    if (title.contains('Active')) return Icons.bolt_rounded;
    if (title.contains('Closed')) return Icons.check_circle_rounded;
    if (title.contains('Lost')) return Icons.do_not_disturb_on_rounded;
    if (title.contains('Target')) return Icons.track_changes_rounded;
    return Icons.apps_rounded;
  }

  Widget _buildModuleCarousel() {
    if (userDashboard == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Quick Modules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: userDashboard!.data.modules.length,
            itemBuilder: (context, index) {
              final module = userDashboard!.data.modules[index];
              return _buildModernModuleItem(module);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernModuleItem(dynamic module) {
    return GestureDetector(
      onTap: () => _handleModuleNavigation(module.menuName),
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue.withOpacity(0.8), darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    module.image != null && module.image.toString().isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: module.image.toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              _getModuleIcon(module.menuName),
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                        : Icon(
                            _getModuleIcon(module.menuName),
                            color: Colors.white,
                            size: 24,
                          ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              module.categoryName ?? '',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModuleIcon(String? menuName) {
    switch (menuName) {
      case 'call_management':
        return Icons.call_rounded;
      case 'Staff_management':
        return Icons.people_rounded;
      case 'Service':
        return Icons.build_rounded;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'room_management':
        return Icons.hotel_rounded;
      case 'Settings':
        return Icons.settings_rounded;
      case 'file_manager':
        return Icons.folder_rounded;
      case 'customers':
        return Icons.people_alt_rounded;
      case 'invoices':
        return Icons.receipt_rounded;
      case 'quotation':
        return Icons.description_rounded;
      case 'reports':
        return Icons.bar_chart_rounded;
      case 'renewal':
        return Icons.autorenew_rounded;
      case 'Work':
        return Icons.work_rounded;
      case 'complaints':
        return Icons.report_problem_rounded;
      case 'products':
        return Icons.inventory_2_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Future<void> _fetchProgressBarLeads(String category) async {
    setState(() {
      _isListTabLoading = true;
      _activeGraphCategory = category;
      object1 = null;
      staffProgressData = null;
      categoryProgressData = null;
      statusProgressData = null;
    });

    try {
      String effectiveGraphStatus = _listTabFilter == 'New'
          ? '1'
          : _listTabFilter == 'Followup'
              ? '2'
              : _listTabFilter == 'Missed'
                  ? '0'
                  : _listTabFilter == 'Called'
                      ? '1'
                      : _listTabFilter == 'Transferred'
                          ? '2'
                          : _listTabFilter == 'Closed'
                              ? '4'
                              : '';

      dynamic fDate = fromDate;
      dynamic tDate = toDate;

      if (category == "New") {
        await getLeadProgressbarNew(
          widget.token!,
          fDate,
          tDate,
          effectiveGraphStatus,
        );
      } else if (category == "Followup") {
        await getLeadProgressbarFollowup(
          widget.token!,
          fDate,
          tDate,
          effectiveGraphStatus,
        );
      } else if (category == "Missed") {
        await getLeadProgressbarMissed(
          widget.token!,
          fDate,
          tDate,
          effectiveGraphStatus,
        );
      } else if (category == "Called") {
        await getLeadProgressbarCalled(
          widget.token!,
          fDate,
          tDate,
          effectiveGraphStatus,
        );
      } else if (category == "Transferred") {
        await getLeadProgressbarTransferred(
          widget.token!,
          fDate,
          tDate,
          effectiveGraphStatus,
        );
      } else {
        if (category == "Closed") {
          if (!isClosedDateFiltered) {
            fDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
            tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
          } else {
            fDate = DateFormat('dd-MM-yyyy').format(fromDateClosed);
            tDate = DateFormat('dd-MM-yyyy').format(toDateClosed);
          }
        }
        await getLeadProgressbar(
          widget.token!,
          fDate,
          tDate,
          effectiveGraphStatus,
        );
      }

      List<Detail> newLeads = [];
      if (object1?.data != null) {
        if (object1!.data!.staffLeads != null) {
          for (var sl in object1!.data!.staffLeads!) {
            newLeads.add(
              Detail(
                callDetailsId: "",
                callMasterId: sl.staffId ?? "",
                calledDate: "",
                createdDate: "",
                lastCalledDate: "",
                callResultId: 0,
                callStatusId: "",
                isNewCall: false,
                followupDate: "",
                nextFollowupDate: "",
                scheduledDate: "",
                clientName: sl.staffName ?? "Unknown Staff",
                contactNumber1: sl.staffCount ?? "0",
                callResult: "${sl.staffPercentage ?? "0"}%",
                proPicThumb: "",
                staffName: sl.staffName ?? "",
                leadCategory: category,
                priority: "1",
                priorityName: "",
                categoryCount: sl.staffCount ?? "0",
                leadCategoryId: "",
                leadSubCategoryId: "",
                cost: "",
                address: "",
                leadSubCategory: "",
                profilePic: "",
                isCalled: false,
                isSelected: false,
                custId: "",
                isCustomer: false,
              ),
            );
          }
        }
      }

      setState(() {
        listTabLeads = [];
        _totalLeads = int.tryParse(object1?.data?.totalCount ?? "0") ?? 0;
        _isListTabLoading = false;
      });
    } catch (e) {
      log("Error fetching progress leads: $e");
      setState(() => _isListTabLoading = false);
    }
  }

  Widget _buildGraphViewContent() {
    final String currentTitle = "$_activeGraphCategory Analytics";
    String currentStatus = "0";
    String currentType = "";
    String? currentCallStatus;

    if (_activeGraphCategory == "New") {
      currentStatus = "1";
      currentType = "";
    } else if (_activeGraphCategory == "Followup") {
      currentStatus = "2";
      currentType = "";
    } else if (_activeGraphCategory == "Missed") {
      currentType = "1";
      currentCallStatus = "-1";
    } else if (_activeGraphCategory == "Called") {
      currentType = "-1";
      currentCallStatus = "1";
    } else if (_activeGraphCategory == "Transferred") {
      currentType = "2";
      currentCallStatus = "-2";
    }

    if (object1 == null || object1!.data == null) {
      if (_isListTabLoading) return const SizedBox();
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text(
            "No analytics data found",
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }

    final data = object1!.data!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.staffLeads != null && data.staffLeads!.isNotEmpty) ...[
                  _buildSectionHeader(
                    "Agent Wise",
                    "${data.staffLeads!.length}",
                  ),
                  const SizedBox(height: 12),
                  ...data.staffLeads!.asMap().entries.map((entry) {
                    return _buildCompactProgressItem(
                      name: entry.value.staffName ?? "N/A",
                      count: entry.value.staffCount ?? "0",
                      percentage: (double.tryParse(data.totalCount ?? "0") ??
                                  0) >
                              0
                          ? (double.tryParse(entry.value.staffCount ?? "0") ??
                                  0) /
                              (double.tryParse(data.totalCount ?? "0") ?? 0)
                          : 0,
                      color: _getStaffColor(entry.key),
                      onTap: () => _activeGraphCategory == "Followup"
                          ? _navigateToFilteredLeadsActive(
                              context: context,
                              staffName: entry.value.staffName,
                              staffId: entry.value.staffId,
                              title: currentTitle,
                              status: currentStatus,
                              type: currentType,
                              callStatus: currentCallStatus,
                              isFollowup: "1",
                            )
                          : _navigateToFilteredLeads(
                              context: context,
                              staffName: entry.value.staffName,
                              staffId: entry.value.staffId,
                              title: currentTitle,
                              status: currentStatus,
                              type: currentType,
                              callStatus: currentCallStatus,
                            ),
                    );
                  }),
                ],
                if (data.categoryLeads != null &&
                    data.categoryLeads!.isNotEmpty) ...[
                  if ((data.staffLeads?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Colors.grey.shade100),
                    ),
                  _buildSectionHeader(
                    "Category Wise",
                    "${data.categoryLeads!.length}",
                  ),
                  const SizedBox(height: 12),
                  ...data.categoryLeads!.asMap().entries.map((entry) {
                    return _buildCompactProgressItem(
                      name: entry.value.categoryName ?? "N/A",
                      count: entry.value.categoryCount ?? "0",
                      percentage:
                          (double.tryParse(data.totalCount ?? "0") ?? 0) > 0
                              ? (double.tryParse(
                                        entry.value.categoryCount ?? "0",
                                      ) ??
                                      0) /
                                  (double.tryParse(data.totalCount ?? "0") ?? 0)
                              : 0,
                      color: _getStaffColor(entry.key + 3),
                      onTap: () => _navigateToFilteredLeads(
                        context: context,
                        categoryName: entry.value.categoryName,
                        categoryId: entry.value.categoryId,
                        title: currentTitle,
                        status: currentStatus,
                        type: currentType,
                        callStatus: currentCallStatus,
                      ),
                    );
                  }),
                ],
                if (data.missedLeads != null &&
                    data.missedLeads!.isNotEmpty) ...[
                  if ((data.staffLeads?.isNotEmpty ?? false) ||
                      (data.categoryLeads?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Colors.grey.shade100),
                    ),
                  _buildSectionHeader(
                    "Staff Wise",
                    "${data.missedLeads!.length}",
                  ),
                  const SizedBox(height: 12),
                  ...data.missedLeads!.asMap().entries.map((entry) {
                    return _buildCompactProgressItem(
                      name: entry.value.missedstaffName ?? "N/A",
                      count: entry.value.missedstaffCount ?? "0",
                      percentage:
                          (double.tryParse(data.totalCount ?? "0") ?? 0) > 0
                              ? (double.tryParse(
                                        entry.value.missedstaffCount ?? "0",
                                      ) ??
                                      0) /
                                  (double.tryParse(data.totalCount ?? "0") ?? 0)
                              : 0,
                      color: _getStaffColor(entry.key + 6),
                      onTap: () => _navigateToFilteredLeads(
                        context: context,
                        staffName: entry.value.missedstaffName,
                        staffId: entry.value.missedstaffId,
                        title: currentTitle,
                        status: currentStatus,
                        type: currentType,
                        callStatus: currentCallStatus,
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: appBarStart.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total $_activeGraphCategory Generated",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        "${data.totalCount ?? "0"} Leads",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: appBarStart,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _navigateToFilteredLeads({
    required BuildContext context,
    String? staffName,
    String? staffId,
    String? categoryName,
    String? categoryId,
    String? title,
    String? status,
    String? type,
    String? callStatus,
    String? callResName,
    String? callResId,
    DateTime? from,
    DateTime? to,
    bool isGlobalContext = false,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewLeadsNew(
          widget.token,
          updateLeadPermission1,
          deleteLeadPermission1,
          cloudCallPermission1,
          pageName: title ?? 'Leads',
          fromDate: from != null
              ? from.toString()
              : (isGlobalContext
                  ? (_isGlobalDateFiltered ? fromDate.toString() : null)
                  : (_isListTabDateFiltered ? fromDate.toString() : null)),
          toDate: to != null
              ? to.toString()
              : (isGlobalContext
                  ? (_isGlobalDateFiltered ? toDate.toString() : null)
                  : (_isListTabDateFiltered ? toDate.toString() : null)),
          status: status ?? '0',
          leadType: type ?? '',
          staffName: staffName,
          staff: staffId,
          categoryName: categoryName,
          category: categoryId,
          callResId: callResId,
          callResName: callResName,
          callStatus: callStatus,
        ),
      ),
    ).then((r) {
      getData(widget.token, fromDate, toDate, isRefresh: true);
    });
  }

  Future<void> _navigateToFilteredLeadsActive({
    required BuildContext context,
    String? staffName,
    String? staffId,
    String? categoryName,
    String? categoryId,
    String? title,
    String? status,
    String? type,
    String? callStatus,
    String? callResName,
    String? callResId,
    DateTime? from,
    DateTime? to,
    String? isFollowup,
    bool isGlobalContext = false,
  }) {
    return Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ViewLeadsNew(
      widget.token,
      updateLeadPermission1,
      deleteLeadPermission1,
      cloudCallPermission1,
      pageName: title ?? 'Leads',
      fromDate: from != null
          ? from.toString()
          : (isGlobalContext
              ? (_isGlobalDateFiltered ? fromDate.toString() : null)
              : (_isListTabDateFiltered ? fromDate.toString() : null)),
      toDate: to != null
          ? to.toString()
          : (isGlobalContext
              ? (_isGlobalDateFiltered ? toDate.toString() : null)
              : (_isListTabDateFiltered ? toDate.toString() : null)),
      status: status ?? '0',
      leadType: type ?? '',
      staffName: staffName,
      staff: staffId,
      categoryName: categoryName,
      category: categoryId,
      callResId: callResId,
      callResName: callResName,
      isActiveReport: "1",
      isFollowup: isFollowup,
      callStatus: callStatus,
    ),
  ),
).then((r) {
  getData(widget.token, fromDate, toDate, isRefresh: true);
});
  
  }

  void _navigateToFilteredLeadsActiveActive({
    required BuildContext context,
    String? staffName,
    String? staffId,
    String? categoryName,
    String? categoryId,
    String? title,
    String? status,
    String? type,
    String? callStatus,
    String? callResName,
    String? callResId,
    DateTime? from,
    DateTime? to,
    bool isGlobalContext = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveLeads(
          widget.token,
          updateLeadPermission1,
          deleteLeadPermission1,
          cloudCallPermission1,
          pageName: title ?? 'Leads',
          fromDate: from != null
              ? from.toString()
              : (isGlobalContext
                  ? (_isGlobalDateFiltered ? fromDate.toString() : null)
                  : (_isListTabDateFiltered ? fromDate.toString() : null)),
          toDate: to != null
              ? to.toString()
              : (isGlobalContext
                  ? (_isGlobalDateFiltered ? toDate.toString() : null)
                  : (_isListTabDateFiltered ? toDate.toString() : null)),
          status: status ?? '0',
          leadType: type ?? '',
          staffName: staffName,
          staff: staffId,
          categoryName: categoryName,
          category: categoryId,
          callResId: callResId,
          callResName: callResName,
          //  isActiveReport: "1",
          callStatus: callStatus,
        ),
      ),
    ).then((r) => getData(widget.token, fromDate, toDate, isRefresh: true));
  }

  Widget _buildSectionHeader(String title, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.indigo.shade800,
              letterSpacing: 1.5,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.indigo.shade200, width: 1),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProgressItem({
    required String name,
    required String count,
    required double percentage,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              animation: true,
              lineHeight: 4.0,
              animationDuration: 600,
              percent: percentage.clamp(0.0, 1.0),
              barRadius: const Radius.circular(2),
              progressColor: color,
              backgroundColor: Colors.grey.shade50,
              trailing: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "${(percentage * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTab() {
    if (_isListTabLoading) {
      return _buildListShimmer();
    }

    return Container(
      color: _getListTabBackgroundColor(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          if (leadDashboard?.data != null) ...[
            _buildSummaryRowSection(leadDashboard!.data),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    color: _getListTabPrimaryColor().withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isGraphViewActive
                                  ? '$_listTabFilter '
                                  : _listTabFilter == 'New'
                                      ? 'New Leads'
                                      : _listTabFilter == 'Followup'
                                          ? 'Followup Leads'
                                          : _listTabFilter == 'Missed'
                                              ? 'Missed Leads'
                                              : _listTabFilter == 'Called'
                                                  ? 'Called Leads'
                                                  : _listTabFilter ==
                                                          'Transferred'
                                                      ? 'Transferred Leads'
                                                      : 'Total Leads',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                //color: _getListTabPrimaryColor(),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_totalLeads Leads',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                // _getListTabPrimaryColor().withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (selectedIUsers.isNotEmpty) {
                                  if (transferPermission == 'true') {
                                    _transferLeads(context);
                                  } else {
                                    Common.toastMessaage(
                                      "No Permission for Transfer",
                                      Colors.red,
                                    );
                                  }
                                } else {
                                  if (createLeadPermission == 'true') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddLeadsNew(widget.token),
                                      ),
                                    ).then(
                                      (_) => getData(
                                        widget.token,
                                        fromDate,
                                        toDate,
                                        isRefresh: true,
                                      ),
                                    );
                                  } else {
                                    _showPermissionDialog();
                                  }
                                }
                              },
                              onLongPress: () {
                                if (selectedIUsers.isNotEmpty) {
                                  _transferLeads(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selectedIUsers.isNotEmpty
                                      ? appBarStart.withOpacity(0.1)
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedIUsers.isNotEmpty
                                        ? appBarStart.withOpacity(0.2)
                                        : Colors.green.shade100,
                                  ),
                                ),
                                child: Icon(
                                  selectedIUsers.isNotEmpty
                                      ? Icons.compare_arrows_rounded
                                      : Icons.add_rounded,
                                  color: selectedIUsers.isNotEmpty
                                      ? appBarStart
                                      : Colors.green,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isGraphViewActive = !_isGraphViewActive;
                                });
                                if (_isGraphViewActive) {
                                  _fetchProgressBarLeads(_listTabFilter);
                                } else {
                                  if (_listTabFilter == "Followup") {
                                    _fetchTabLeadsActive();
                                  } else {
                                    _fetchTabLeads();
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isGraphViewActive
                                      ? const Color.fromARGB(255, 255, 214, 214)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isGraphViewActive
                                        ? const Color.fromARGB(
                                            255,
                                            240,
                                            193,
                                            193,
                                          )
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Icon(
                                  Icons.bar_chart_rounded,
                                  color: _isGraphViewActive
                                      ? const Color.fromARGB(255, 138, 58, 58)
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => ViewLeadsFilterWidget(
                                    commonDetails: commonDetails,
                                    productSectionModel: productSectionModel,
                                    currentTab: _listTabFilter,
                                    initialFilters: {
                                      'isDateFiltered': _isListTabDateFiltered,
                                      'fromDate': fromDate,
                                      'toDate': toDate,
                                      'statusIds': _listTabSelectedStatusIds,
                                      'staffIds': _listTabSelectedStaffIds,
                                      'categoryIds':
                                          _listTabSelectedCategoryIds,
                                      'priorityIds':
                                          _listTabSelectedPriorityIds,
                                      'productIds': _listTabSelectedProductIds,
                                    },
                                    isActiveLeads:
                                        _listTabFilter == "Followup" ? "1" : "",
                                    onApplyFilters: (filters) {
                                      setState(() {
                                        _isListTabLoading = true;
                                        listTabLeads = [];
                                        fromDate = filters['fromDate'] ??
                                            DateTime.now();
                                        toDate =
                                            filters['toDate'] ?? DateTime.now();

                                        _listTabSelectedStatusIds =
                                            List<String>.from(
                                          filters['statusIds'] ?? [],
                                        );
                                        _listTabSelectedStaffIds =
                                            List<String>.from(
                                          filters['staffIds'] ?? [],
                                        );
                                        _listTabSelectedCategoryIds =
                                            List<String>.from(
                                          filters['categoryIds'] ?? [],
                                        );
                                        _listTabSelectedPriorityIds =
                                            List<String>.from(
                                          filters['priorityIds'] ?? [],
                                        );
                                        _listTabSelectedProductIds =
                                            List<String>.from(
                                          filters['productIds'] ?? [],
                                        );
                                        _listTabSelectedTagIds =
                                            List<String>.from(
                                          filters['tagIds'] ?? [],
                                        );

                                        _isListTabDateFiltered =
                                            filters['isDateFiltered'] ?? false;
                                        _isListTabFilterApplied =
                                            _listTabSelectedStatusIds
                                                    .isNotEmpty ||
                                                _listTabSelectedStaffIds
                                                    .isNotEmpty ||
                                                _listTabSelectedCategoryIds
                                                    .isNotEmpty ||
                                                _listTabSelectedPriorityIds
                                                    .isNotEmpty ||
                                                _listTabSelectedProductIds
                                                    .isNotEmpty ||
                                                _listTabSelectedTagIds
                                                    .isNotEmpty ||
                                                _isListTabDateFiltered;

                                        _listTabPage = 1;
                                      });
                                      getData(
                                        widget.token,
                                        fromDate,
                                        toDate,
                                        isRefresh: true,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.filter_alt_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Search(
                                      token: widget.token!,
                                      editLead: updateLeadPermission1,
                                      deleteLead: deleteLeadPermission1,
                                      cloudCall: cloudCallPermission1,
                                      leadType: '',
                                    ),
                                  ),
                                ).then(
                                  (_) => getData(
                                    widget.token,
                                    fromDate,
                                    toDate,
                                    isRefresh: true,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: appBarStart,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: appBarStart.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isSortAscending = !_isSortAscending;
                                  _listTabSortOrder =
                                      _isSortAscending ? 'asc' : 'desc';
                                });
                                if (_listTabFilter == "Followup") {
                                  _fetchTabLeadsActive();
                                } else {
                                  _fetchTabLeads();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _isSortAscending ? '' : '',
                                      style: const TextStyle(
                                        color: textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isSortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: appBarStart,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isCompactView = !_isCompactView;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isCompactView
                                      ? appBarStart.withOpacity(0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isCompactView
                                        ? appBarStart.withOpacity(0.2)
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Icon(
                                  _isCompactView
                                      ? Icons.view_agenda_rounded
                                      : Icons.view_headline_rounded,
                                  color: _isCompactView
                                      ? appBarStart
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_isGraphViewActive)
                  _buildGraphViewContent()
                else if (listTabLeads.isEmpty && !_isListTabLoading)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No leads found for this category',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  )
                else
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listTabLeads.length,
                    itemBuilder: (context, index) {
                      final lead = listTabLeads[index];
                      return _buildLeadListItem(lead, index);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLeadDetailsPopup(
    int index, {
    bool autoExpandFollowup = false,
    String? customCallMasterId,
  }) async {
    final String targetCallMasterId;
    if (customCallMasterId != null) {
      targetCallMasterId = customCallMasterId;
    } else {
      if (index < 0 || index >= listTabLeads.length) return;
      targetCallMasterId = listTabLeads[index].callMasterId;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: appBarStart,
              strokeWidth: 3,
            ),
          ),
        );
      },
    );

    try {
      final results = await Future.wait([
        HttpService.leadDetails(widget.token!, targetCallMasterId),
        HttpService.listAddonDet(widget.token!, targetCallMasterId),
        HttpService.listFolderAndFiles(
          widget.token!,
          targetCallMasterId,
          '',
        ),
        HttpService.leadMileStone(widget.token!, targetCallMasterId),
        HttpService.leadFollowupData(widget.token!, targetCallMasterId),
        if (commonDetails == null) HttpService.addLeadCommonData(widget.token!),
      ]);

      if (!mounted) return;
      Navigator.pop(context);

      final leadDetails = results[0] as LeadDeatailsModel?;
      if (leadDetails == null) {
        Common.toastMessaage("Failed to load lead details", accentRed);
        return;
      }

      final leadDetailsAdditional = results[1] as LeadDeatailsModelAdd?;
      final listFolder = results[2] as ListFolderNameModel?;
      final mileStone = results[3] as LeadMileStoneListModel?;
      final leadDetailsFollowup = results[4] as af.LeadFollowupData?;
      if (commonDetails == null && results.length > 5) {
        commonDetails = results[5] as AddLeadCommonDataModel?;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LeadDetailsPopup(
          token: widget.token!,
          editLead: updateLeadPermission1,
          deleteLead: deleteLeadPermission1,
          cloudCall: cloudCallPermission1,
          callMasterId: targetCallMasterId,
          leadDetails: leadDetails,
          leadDetailsAdditional: leadDetailsAdditional,
          listFolder: listFolder,
          mileStone: mileStone,
          leadDetailsFollowup: leadDetailsFollowup,
          commonDetails: commonDetails,
          pageName: 'Dashboard',
          autoExpandFollowup: autoExpandFollowup,
          onDataChanged: () {
            // Programmatically trigger the pull-to-refresh visual spinner and sequence
            if (_listTabRefreshIndicatorKey.currentState != null) {
              _listTabRefreshIndicatorKey.currentState!.show();
            } else {
              getData(widget.token, fromDate, toDate, isRefresh: true);
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      log("Error loading lead details: $e");
      Common.toastMessaage("Error loading details", accentRed);
    }
  }

  Future<void> _refreshLeadData(int index) async {
    if (index < 0 || index >= listTabLeads.length) return;
    String cmId = listTabLeads[index].callMasterId;
    try {
      final response = await HttpService.leadDetails(widget.token!, cmId);
      if (response != null && response.data != null) {
        final d = response.data!;
        if (mounted) {
          setState(() {
            final String newStatusIdStr = d.callResultId ?? '';
            bool shouldRemove = false;

            if (_listTabSelectedStatusIds != null &&
                _listTabSelectedStatusIds!.isNotEmpty) {
              if (!_listTabSelectedStatusIds!.contains(newStatusIdStr)) {
                shouldRemove = true;
              }
            } else {
              if (_listTabFilter == 'New') {
                if (newStatusIdStr != '1') {
                  shouldRemove = true;
                }
              } else if (_listTabFilter == 'Followup') {
                if (newStatusIdStr != '2') {
                  shouldRemove = true;
                }
              } else if (_listTabFilter == 'Missed') {
                if (newStatusIdStr != '3') {
                  shouldRemove = true;
                }
              } else if (_listTabFilter == 'Called') {
                // For Called tab, the backend returns all called leads regardless of callResultId.
                // Therefore, we should never remove a lead from Called tab locally.
                shouldRemove = false;
              } else if (_listTabFilter == 'Transferred') {
                if (newStatusIdStr != '5') {
                  shouldRemove = true;
                }
              } else if (_listTabFilter == 'Closed') {
                if (newStatusIdStr != '6') {
                  shouldRemove = true;
                }
              }
            }

            if (shouldRemove) {
              listTabLeads.removeAt(index);
              _totalLeads = (_totalLeads - 1).clamp(0, 999999);
            } else {
              var lead = listTabLeads[index];
              lead.clientName = d.clientName ?? lead.clientName;
              lead.contactNumber1 = d.contactNumber1 ?? lead.contactNumber1;
              lead.calledDate = d.calledDate ?? lead.calledDate;
              lead.lastCalledDate = d.calledDate ?? lead.lastCalledDate;
              lead.nextFollowupDate =
                  d.nextFollowupDate ?? lead.nextFollowupDate;
              lead.callResult = d.callResult ?? lead.callResult;
              lead.callResultId =
                  int.tryParse(d.callResultId ?? "0") ?? lead.callResultId;
              lead.leadCategory = d.leadCategory ?? lead.leadCategory;
              lead.leadCategoryId = d.leadCategoryId ?? lead.leadCategoryId;
              lead.leadSubCategory = d.leadSubCategory ?? lead.leadSubCategory;
              lead.leadSubCategoryId =
                  d.leadSubCategoryId ?? lead.leadSubCategoryId;
              lead.priority = d.priorityId ?? lead.priority;
              lead.priorityName = d.priority ?? lead.priorityName;
              lead.cost = d.cost ?? lead.cost;
              lead.address = d.address ?? lead.address;
              lead.staffName = d.staffName ?? lead.staffName;
              lead.isCalled = true;
              lead.isNewCall = false;
            }
          });
          // Update counts in background to keep dashboard consistent
          _fetchDashboardTabContent();
        }
      }
    } catch (e) {
      log("Error refreshing single lead: $e");
    }
  }

  Future<dynamic> chooseCallDialog(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final item = listTabLeads[index];
        return AlertDialog(
          title: const Text('Choose Call Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cloudCallPermission1) ...[
                ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.cloud_circle_rounded,
                    color: appBarStart,
                  ),
                  title: const Text('Cloud Call'),
                  onTap: () async {
                    Common.showProgressDialog(context, "Loading..");
                    var object1 = await HttpService.addCloudCall(
                      widget.token,
                      item.callMasterId,
                      item.contactNumber1,
                    );
                    if (object1.data == true) {
                      if (context.mounted) {
                        Common.toastMessaage(object1.message, callGreen);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } else {
                      Common.toastMessaage(object1.message, accentRed);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
                const Divider(height: 1),
              ],
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.phone_android_rounded,
                  color: callGreen,
                ),
                title: const Text('Phone Call'),
                onTap: () async {
                  Navigator.pop(context);
                  Common.dialPad(item.contactNumber1);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCallPermissionDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Permission Denied'),
        content: const Text('You do not have permission to make calls.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTabLeadsActive({
    String? status,
    String? leadType,
    String? callStatus,
    bool? isCalled,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      if (_isListTabLoadingMore || !_hasMoreListTabLeads) return;
      setState(() {
        _isListTabLoadingMore = true;
      });
      _listTabPage++;
    } else {
      setState(() {
        _isListTabLoading = true;
        _listTabPage = 1;
        _hasMoreListTabLeads = true;
        if (status != null) _listTabCurrentStatus = status;
        if (leadType != null) _listTabCurrentLeadType = leadType;
        if (callStatus != null) _listTabCurrentCallStatus = callStatus;
        if (isCalled != null) _listTabCurrentIsCalled = isCalled;
      });
    }

    // For Followup tab filtering, selected stages IDs should be passed as leadType, and callResultId should be empty
    bool isFollowupFiltering =
        (_listTabFilter == "Followup" || status == "2") &&
            (_listTabSelectedStatusIds?.isNotEmpty ?? false);

    Map<String, dynamic> body = {
      "token": widget.token,
      "callResultId": isFollowupFiltering
          ? ""
          : (_listTabCurrentIsCalled == true
              ? ((_listTabSelectedStatusIds != null && _listTabSelectedStatusIds!.isNotEmpty)
                  ? _listTabSelectedStatusIds!.join(',')
                  : (_listTabFilter == "New" ? "1" : ""))
              : (_listTabCurrentStatus == "0"
                  ? ""
                  : (_listTabCurrentStatus ?? ""))),
      "leadCategoryId": _listTabSelectedCategoryIds,
      "leadSubcategoryId": [],
      "callResponseId": isFollowupFiltering
          ? []
          : (_listTabCurrentIsCalled == true
              ? []
              : (_listTabSelectedStatusIds ?? [])),
      "callStatus": _listTabCurrentCallStatus ?? "",
      "staffId": _listTabSelectedStaffIds,
      "isCalled": _listTabCurrentIsCalled ?? true,
      "productId": _listTabSelectedProductIds,
      "sort": _listTabSortOrder,
      "page": _listTabPage,
      "pageSize": 10,
      "isFirst": !isLoadMore,
      "leadType": isFollowupFiltering
          ? (_listTabSelectedStatusIds?.join(',') ?? "")
          : (_listTabCurrentLeadType ?? ""),
      "priority": _listTabSelectedPriorityIds,
      "call_result_reason": _listTabSelectedTagIds,
    };

    bool shouldSendDates = _isListTabDateFiltered ||
        (_listTabCurrentLeadType == "-1" ||
            _listTabCurrentLeadType == "1" ||
            _listTabCurrentLeadType == "2" ||
            _listTabCurrentStatus == "4");
    body["filterStatus"] = shouldSendDates ? 1 : 0;
    body["fromDate"] =
        shouldSendDates ? DateFormat('yyyy-MM-dd').format(fromDate) : "";
    body["toDate"] =
        shouldSendDates ? DateFormat('yyyy-MM-dd').format(toDate) : "";

    try {
      final response = await HttpService.viewLeadsforActive(body);
      if (response != null && response.data != null) {
        final newLeads = response.data.details;
        setState(() {
          if (isLoadMore) {
            listTabLeads.addAll(newLeads);
          } else {
            listTabLeads = newLeads;
          }
          _listTabCallPermission = response.data.callPermission ?? true;
          _totalLeads = response.data.totalLeads;
          _hasMoreListTabLeads = newLeads.length >= 10;
          _isListTabLoading = false;
          _isListTabLoadingMore = false;
        });
      } else {
        setState(() {
          if (!isLoadMore) {
            listTabLeads = [];
            _totalLeads = 0;
          }
          _hasMoreListTabLeads = false;
          _isListTabLoading = false;
          _isListTabLoadingMore = false;
        });
      }
    } catch (e) {
      log("Error fetching tab leads: $e");
      setState(() {
        if (!isLoadMore) listTabLeads = [];
        _isListTabLoading = false;
        _isListTabLoadingMore = false;
      });
    }
  }

  Future<void> _fetchTabLeads({
    String? status,
    String? leadType,
    String? callStatus,
    bool? isCalled,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      if (_isListTabLoadingMore || !_hasMoreListTabLeads) return;
      setState(() {
        _isListTabLoadingMore = true;
      });
      _listTabPage++;
    } else {
      setState(() {
        _isListTabLoading = true;
        _listTabPage = 1;
        _hasMoreListTabLeads = true;
        if (status != null) _listTabCurrentStatus = status;
        if (leadType != null) _listTabCurrentLeadType = leadType;
        if (callStatus != null) _listTabCurrentCallStatus = callStatus;
        if (isCalled != null) _listTabCurrentIsCalled = isCalled;
      });
    }

    Map<String, dynamic> body = {
      "token": widget.token,
      "callResultId": (_listTabCurrentIsCalled == true)
          ? ((_listTabSelectedStatusIds != null && _listTabSelectedStatusIds!.isNotEmpty)
              ? _listTabSelectedStatusIds!.join(',')
              : (_listTabFilter == "New" ? "1" : ""))
          : (_listTabCurrentStatus == "0" ? "" : (_listTabCurrentStatus ?? "")),
      "leadCategoryId": _listTabSelectedCategoryIds,
      "leadSubcategoryId": [],
      "callResponseId": (_listTabCurrentIsCalled == true)
          ? []
          : (_listTabSelectedStatusIds ?? []),
      "callStatus": _listTabCurrentCallStatus ?? "",
      "staffId": _listTabSelectedStaffIds,
      "isCalled": _listTabCurrentIsCalled ?? true,
      "productId": _listTabSelectedProductIds,
      "sort": _listTabSortOrder,
      "page": _listTabPage,
      "pageSize": 10,
      "isFirst": !isLoadMore,
      "leadType": _listTabCurrentLeadType ?? "",
      "priority": _listTabSelectedPriorityIds,
      "call_result_reason": _listTabSelectedTagIds,
    };

    bool shouldSendDates = _isListTabDateFiltered ||
        (_listTabCurrentLeadType == "-1" ||
            _listTabCurrentLeadType == "1" ||
            _listTabCurrentLeadType == "2" ||
            _listTabCurrentStatus == "4");
    body["filterStatus"] = shouldSendDates ? 1 : 0;
    body["fromDate"] =
        shouldSendDates ? DateFormat('yyyy-MM-dd').format(fromDate) : "";
    body["toDate"] =
        shouldSendDates ? DateFormat('yyyy-MM-dd').format(toDate) : "";
    try {
      final response = await HttpService.leadReport(body);
      if (response != null && response.data != null) {
        final newLeads = response.data.details;
        setState(() {
          if (isLoadMore) {
            listTabLeads.addAll(newLeads);
          } else {
            listTabLeads = newLeads;
          }
          _listTabCallPermission = response.data.callPermission ?? true;
          _totalLeads = response.data.totalLeads;
          _hasMoreListTabLeads = newLeads.length >= 10;
          _isListTabLoading = false;
          _isListTabLoadingMore = false;
        });
      } else {
        setState(() {
          if (!isLoadMore) {
            listTabLeads = [];
            _totalLeads = 0;
          }
          _hasMoreListTabLeads = false;
          _isListTabLoading = false;
          _isListTabLoadingMore = false;
        });
      }
    } catch (e) {
      log("Error fetching tab leads: $e");
      setState(() {
        if (!isLoadMore) listTabLeads = [];
        _isListTabLoading = false;
        _isListTabLoadingMore = false;
      });
    }
  }

  Widget _buildLeadListItem(Detail lead, int index) {
    bool isCreatedToday = false;
    try {
      if (lead.createdDate.isNotEmpty) {
        String dateStr = lead.createdDate.split(' ')[0];
        String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
        String todayAlt = DateFormat('yyyy-MM-dd').format(DateTime.now());
        if (dateStr == today || dateStr == todayAlt) {
          isCreatedToday = true;
        }
      }
    } catch (_) {}

    bool isDetailed = _isCompactView
        ? _expandedLeadIds.contains(lead.callMasterId)
        : !_expandedLeadIds.contains(lead.callMasterId);
    if (!isDetailed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: lead.isSelected
                ? appBarStart.withOpacity(0.08)
                : (isCreatedToday ? const Color(0xFFE8F5E9) : backgroundLight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: lead.isSelected ? appBarStart : borderLight,
              width: lead.isSelected ? 2 : 1,
            ),
          ),
          child: Slidable(
            key: ValueKey(lead.callMasterId),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) =>
                      _showLeadDetailsPopup(index, autoExpandFollowup: true),
                  backgroundColor: followupBlue,
                  foregroundColor: Colors.white,
                  icon: Icons.add_comment_rounded,
                  label: 'Followup',
                ),
                SlidableAction(
                  onPressed: (context) => Common.dialPad(lead.contactNumber1),
                  backgroundColor: callGreen,
                  foregroundColor: Colors.white,
                  icon: Icons.phone_rounded,
                  label: 'Call',
                ),
                SlidableAction(
                  onPressed: (context) =>
                      Common.openWhatsApp(lead.contactNumber1),
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'WhatsApp',
                ),
                SlidableAction(
                  onPressed: (context) =>
                      getData(widget.token, fromDate, toDate, isRefresh: true),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  icon: Icons.refresh_rounded,
                  label: 'Reload',
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (selectedIUsers.isNotEmpty) {
                  _handleLongPress(index);
                } else {
                  _showLeadDetailsPopup(index);
                }
              },
              onLongPress: () => _handleLongPress(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 75,
                      color: lead.priority == '1'
                          ? Colors.grey.shade300
                          : lead.priority == '2'
                              ? callGreen
                              : lead.priority == '3'
                                  ? accentRed
                                  : lead.priority == '4'
                                      ? textSecondary
                                      : Colors.grey.shade300,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _showLeadDetailsPopup(index),
                                    child: Text(
                                      lead.clientName.isEmpty ||
                                              lead.clientName == "null"
                                          ? "Unknown"
                                          : lead.clientName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: lead.isCustomer
                                            ? callGreen
                                            : textPrimary,
                                        decoration: lead.priority == '4'
                                            ? TextDecoration.lineThrough
                                            : null,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentRed.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: accentRed.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    lead.leadCategory,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: accentRed,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                if (int.parse(lead.categoryCount) > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: IgnorePointer(
                                      ignoring: selectedIUsers.isNotEmpty,
                                      child: InkWell(
                                        onTap: () => _showCategoryPopup(lead),
                                        child: Container(
                                          height: 18,
                                          width: 18,
                                          decoration: const BoxDecoration(
                                            color: accentOrange,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              lead.categoryCount,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      String id = lead.callMasterId;
                                      if (_expandedLeadIds.contains(id)) {
                                        _expandedLeadIds.remove(id);
                                      } else {
                                        _expandedLeadIds.add(id);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: backgroundLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (lead.lastCalledDate.isNotEmpty ||
                                lead.nextFollowupDate.isNotEmpty) ...[
                              Row(
                                children: [
                                  if (lead.lastCalledDate.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.phone_callback,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Called: ${lead.lastCalledDate}",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (lead.lastCalledDate.isNotEmpty &&
                                      lead.nextFollowupDate.isNotEmpty)
                                    const SizedBox(width: 8),
                                  if (lead.nextFollowupDate.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.event_note,
                                            size: 12,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Next: ${lead.nextFollowupDate}",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: lead.callResultId >= 0 &&
                                            lead.callResultId < _colors.length
                                        ? _colors[lead.callResultId]
                                            .withOpacity(0.15)
                                        : accentOrange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: lead.callResultId >= 0 &&
                                              lead.callResultId < _colors.length
                                          ? _colors[lead.callResultId]
                                              .withOpacity(0.4)
                                          : accentOrange.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: lead.callResultId >= 0 &&
                                                  lead.callResultId <
                                                      _colors.length
                                              ? _colors[lead.callResultId]
                                              : accentOrange,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        lead.callResult.isEmpty
                                            ? "Pending"
                                            : lead.callResult,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: lead.callResultId >= 0 &&
                                                  lead.callResultId <
                                                      _colors.length
                                              ? _colors[lead.callResultId]
                                              : accentOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildMiniActionButton(
                                      icon: Icons.call,
                                      color: callGreen,
                                      isEnabled: selectedIUsers.isEmpty,
                                      onTap: () {
                                        if (_listTabCallPermission == false) {
                                          _showCallPermissionDialog(index);
                                        } else {
                                          if (cloudCallPermission1) {
                                            chooseCallDialog(context, index);
                                          } else {
                                            Common.dialPad(lead.contactNumber1);
                                          }
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    _buildMiniActionButton(
                                      icon: FontAwesomeIcons.whatsapp,
                                      color: const Color(0xFF25D366),
                                      isEnabled: selectedIUsers.isEmpty,
                                      onTap: () {
                                        if (lead.contactNumber1.isNotEmpty) {
                                          Common.openWhatsApp(
                                            lead.contactNumber1,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
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
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey('expanded_${lead.callMasterId}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) =>
                  _showLeadDetailsPopup(index, autoExpandFollowup: true),
              backgroundColor: followupBlue,
              foregroundColor: Colors.white,
              icon: Icons.add_comment_rounded,
              label: 'Followup',
            ),
            SlidableAction(
              onPressed: (context) => Common.dialPad(lead.contactNumber1),
              backgroundColor: callGreen,
              foregroundColor: Colors.white,
              icon: Icons.phone_rounded,
              label: 'Call',
            ),
            SlidableAction(
              onPressed: (context) => Common.openWhatsApp(lead.contactNumber1),
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              icon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
            ),
            SlidableAction(
              onPressed: (context) =>
                  getData(widget.token, fromDate, toDate, isRefresh: true),
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              icon: Icons.refresh_rounded,
              label: 'Reload',
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (selectedIUsers.isNotEmpty) {
              _handleLongPress(index);
            } else {
              _showLeadDetailsPopup(index);
            }
          },
          onLongPress: () => _handleLongPress(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: lead.isSelected
                  ? appBarStart.withOpacity(0.05)
                  : (isCreatedToday
                      ? const Color(0xFFE8F5E9) // Light green for today
                      : Colors.white),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: lead.isSelected ? appBarStart : borderLight,
                width: lead.isSelected ? 2 : 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderLight, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lead.priority == '1'
                              ? Colors.grey
                              : lead.priority == '2'
                                  ? callGreen
                                  : lead.priority == '3'
                                      ? accentRed
                                      : lead.priority == '4'
                                          ? textSecondary
                                          : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lead.clientName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            decoration: lead.priority == '4'
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: accentRed,
                            color: lead.isCustomer ? callGreen : textPrimary,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lead.leadCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            color: accentRed,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (int.parse(lead.categoryCount) > 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: IgnorePointer(
                            ignoring: selectedIUsers.isNotEmpty,
                            child: InkWell(
                              onTap: () => _showCategoryPopup(lead),
                              child: Container(
                                height: 18,
                                width: 18,
                                decoration: const BoxDecoration(
                                  color: accentOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    lead.categoryCount,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            String id = lead.callMasterId;
                            if (_expandedLeadIds.contains(id)) {
                              _expandedLeadIds.remove(id);
                            } else {
                              _expandedLeadIds.add(id);
                            }
                          });
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 16,
                                color: primaryBlue.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lead.contactNumber1,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 16,
                                color: primaryBlue.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lead.staffName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (lead.lastCalledDate.isNotEmpty ||
                          lead.nextFollowupDate.isNotEmpty) ...[
                        Row(
                          children: [
                            if (lead.lastCalledDate.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_callback,
                                      size: 12,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Called: ${lead.lastCalledDate}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (lead.lastCalledDate.isNotEmpty &&
                                lead.nextFollowupDate.isNotEmpty &&
                                lead.nextFollowupDate != "00-00-0000 12:00 AM")
                              const SizedBox(width: 8),
                            if (lead.nextFollowupDate.isNotEmpty &&
                                lead.nextFollowupDate != "00-00-0000" &&
                                lead.nextFollowupDate != "00-00-0000 12:00 AM")
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.event_note,
                                      size: 12,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Next: ${lead.nextFollowupDate}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: lead.callResultId >= 0 &&
                                      lead.callResultId < _colors.length
                                  ? _colors[lead.callResultId].withOpacity(0.15)
                                  : const Color.fromARGB(
                                      255,
                                      247,
                                      185,
                                      62,
                                    ).withOpacity(0.17),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: lead.callResultId >= 0 &&
                                        lead.callResultId < _colors.length
                                    ? _colors[lead.callResultId].withOpacity(
                                        0.4,
                                      )
                                    : const Color.fromARGB(
                                        255,
                                        245,
                                        231,
                                        108,
                                      ).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              lead.callResult.isEmpty
                                  ? "Pending"
                                  : lead.callResult,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: lead.callResultId >= 0 &&
                                        lead.callResultId < _colors.length
                                    ? _colors[lead.callResultId]
                                    : accentOrange,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _buildMiniActionButton(
                                icon: Icons.call,
                                color: callGreen,
                                isEnabled: selectedIUsers.isEmpty,
                                onTap: () {
                                  if (_listTabCallPermission == false) {
                                    _showCallPermissionDialog(index);
                                  } else {
                                    if (cloudCallPermission1) {
                                      chooseCallDialog(context, index);
                                    } else {
                                      Common.dialPad(lead.contactNumber1);
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildMiniActionButton(
                                icon: FontAwesomeIcons.whatsapp,
                                color: const Color(0xFF25D366),
                                isEnabled: selectedIUsers.isEmpty,
                                onTap: () {
                                  if (lead.contactNumber1.isNotEmpty) {
                                    Common.openWhatsApp(lead.contactNumber1);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryPopup(Detail lead) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final leadDetails = await HttpService.leadDetails(
        widget.token!,
        lead.callMasterId,
      );

      if (mounted) Navigator.pop(context);

      if (leadDetails != null && leadDetails.data?.leadCategories != null) {
        final categories = leadDetails.data!.leadCategories!;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Lead Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: appBarStart,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: categories.length,
                        separatorBuilder: (context, _) =>
                            const Divider(color: borderLight, height: 8),
                        itemBuilder: (context, i) {
                          final category = categories[i];
                          return InkWell(
                            // onTap: () {
                            //   Navigator.pop(context);
                            //   _fetchTabLeads();
                            // },
                            onTap: () {
                              if (viewLeadCategoryOnly == "true") return;

                              Navigator.pop(context);
                              _showLeadDetailsPopup(
                                listTabLeads.indexOf(lead),
                                customCallMasterId: category.callMasterId,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderLight),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        category.isSelected == true
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 18,
                                        color: category.isSelected == true
                                            ? callGreen
                                            : textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          category.leadCategory ?? "-",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (category.leadStatus ?? "") ==
                                                  "New"
                                              ? appBarStart.withOpacity(0.1)
                                              : (category.leadStatus ?? "") ==
                                                      "Follow Up"
                                                  ? accentOrange
                                                      .withOpacity(0.1)
                                                  : (category.leadStatus ??
                                                              "") ==
                                                          "Rejected"
                                                      ? accentRed
                                                          .withOpacity(0.1)
                                                      : accentOrange
                                                          .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          category.leadStatus ?? "-",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: (category.leadStatus ??
                                                        "") ==
                                                    "New"
                                                ? appBarStart
                                                : (category.leadStatus ?? "") ==
                                                        "Follow Up"
                                                    ? accentOrange
                                                    : (category.leadStatus ??
                                                                "") ==
                                                            "Rejected"
                                                        ? accentRed
                                                        : accentOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "👤 ${category.staffName ?? "-"}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Text(
                                        "📅 ${category.createdDate ?? "-"}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (error) {
      if (mounted) Navigator.pop(context);
      Common.toastMessaage("Failed to load categories", accentRed);
    }
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isEnabled
                ? color.withOpacity(0.12)
                : Colors.grey.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isEnabled ? color : Colors.grey, size: 18),
        ),
      ),
    );
  }

  //============================================================================
  // REPORT SECTION - MAIN ENTRY POINT
  //============================================================================
  Widget _buildReportTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReportSection(1),
          const SizedBox(height: 10),
          _buildReportSection(2),
          const SizedBox(height: 10),
          _buildReportSection(3),
          const SizedBox(height: 10),
          _buildReportSection(4),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildReportSection(int index) {
    String title;
    bool isTableActive;
    VoidCallback onToggleView;
    VoidCallback onRefresh;
    Widget reportContent;
    IconData icon;
    bool isFlipped;
    VoidCallback onFlip;

    if (index == 1) {
      title = _reportType1;
      if (title == "Cloud Call Report") {
        isTableActive = showCloudCallTable;
        onToggleView = () {
          setState(() => showCloudCallTable = !showCloudCallTable);
          Common.saveSharedPref(
            "showCloudCallTable",
            showCloudCallTable.toString(),
          );
          if (showCloudCallTable && cloudCallReportData == null) {
            _fetchCloudCallReport();
          }
        };
        onRefresh = _fetchCloudCallReport;
      } else if (title == "Phone Call Report") {
        isTableActive = showPhoneCallTable;
        onToggleView = () {
          setState(() => showPhoneCallTable = !showPhoneCallTable);
          Common.saveSharedPref(
            "showPhoneCallTable",
            showPhoneCallTable.toString(),
          );
          if (showPhoneCallTable && phoneCallReportData == null) {
            _fetchPhoneCallReport();
          }
        };
        onRefresh = _fetchPhoneCallReport;
      } else {
        isTableActive = showCallStatusTable;
        onToggleView = () {
          setState(() => showCallStatusTable = !showCallStatusTable);
          Common.saveSharedPref(
            "showCallStatusTable",
            showCallStatusTable.toString(),
          );
          if (showCallStatusTable && callStatusTableData == null) {
            _fetchCallStatusTableReport();
          }
        };
        onRefresh = () {
          _fetchCallStatusReport();
          if (showCallStatusTable) _fetchCallStatusTableReport();
        };
      }
      icon = title == "Cloud Call Report"
          ? Icons.cloud_outlined
          : (title == "Phone Call Report"
              ? Icons.phone_outlined
              : Icons.call_rounded);
      isFlipped = _isFlipped1;
      onFlip = () => setState(() => _isFlipped1 = !_isFlipped1);
    } else if (index == 2) {
      title = _reportType2;
      isTableActive = showStageWiseTable;
      onToggleView = () {
        setState(() => showStageWiseTable = !showStageWiseTable);
        Common.saveSharedPref(
          "showStageWiseTable",
          showStageWiseTable.toString(),
        );
        if (showStageWiseTable && stageWiseTableData == null) {
          _fetchStageWiseTableReport();
        }
      };
      onRefresh = () {
        _fetchStageWiseReport();
        if (showStageWiseTable) _fetchStageWiseTableReport();
      };
      icon = Icons.pie_chart_rounded;
      isFlipped = _isFlipped2;
      onFlip = () => setState(() => _isFlipped2 = !_isFlipped2);
    } else if (index == 3) {
      title = _reportType3;
      isTableActive = showLeadSourceTable;
      onToggleView = () {
        setState(() => showLeadSourceTable = !showLeadSourceTable);
        Common.saveSharedPref(
          "showLeadSourceTable",
          showLeadSourceTable.toString(),
        );
        if (showLeadSourceTable && leadSourceTableData == null) {
          _fetchLeadSourceTableReport();
        }
      };
      onRefresh = () {
        _fetchLeadSourceReport();
        if (showLeadSourceTable) _fetchLeadSourceTableReport();
      };
      icon = Icons.source_outlined;
      isFlipped = _isFlipped3;
      onFlip = () => setState(() => _isFlipped3 = !_isFlipped3);
    } else {
      title = _reportType4;
      isTableActive = showCategoryTable;
      onToggleView = () {
        setState(() => showCategoryTable = !showCategoryTable);
        Common.saveSharedPref(
          "showCategoryTable",
          showCategoryTable.toString(),
        );
        if (showCategoryTable && categoryTableData == null) {
          _fetchCategoryTableReport();
        }
      };
      onRefresh = () {
        _fetchCategoryReport();
        if (showCategoryTable) _fetchCategoryTableReport();
      };
      icon = Icons.category_rounded;
      isFlipped = _isFlipped4;
      onFlip = () => setState(() => _isFlipped4 = !_isFlipped4);
    }

    if (title == "Cloud Call Report") {
      reportContent = _buildCloudCallReport(isFlipped: isFlipped);
    } else if (title == "Phone Call Report") {
      reportContent = _buildPhoneCallReport(isFlipped: isFlipped);
    } else if (title == "Cloud Call Graph") {
      reportContent = _buildCloudCallGraph();
    } else if (title == "Phone Call Graph") {
      reportContent = _buildPhoneCallGraph();
    } else {
      if (index == 1) {
        reportContent = _buildCallStatusReport(isFlipped: isFlipped);
      } else if (index == 2)
        reportContent = _buildStageWiseReport(isFlipped: isFlipped);
      else if (index == 3)
        reportContent = _buildLeadSourceReport(isFlipped: isFlipped);
      else
        reportContent = _buildCategoryReport(isFlipped: isFlipped);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildReportSectionHeader(
          title,
          icon,
          isTableActive: isTableActive,
          onToggleView: onToggleView,
          onRefresh: onRefresh,
          onTypeChange: (newType) {
            String key = index == 1
                ? "reportType1"
                : (index == 2
                    ? "reportType2"
                    : (index == 3 ? "reportType3" : "reportType4"));
            Common.saveSharedPref(key, newType);
            setState(() {
              if (index == 1) {
                _reportType1 = newType;
              } else if (index == 2)
                _reportType2 = newType;
              else if (index == 3)
                _reportType3 = newType;
              else
                _reportType4 = newType;
            });
          },
          isFlipped: isFlipped,
          onFlip: onFlip,
          showMoreMenu: index == 1,
          onTypeSelected: (newType) {
            if ((newType == "Cloud Call Report" ||
                    newType == "Cloud Call Graph") &&
                cloudCallReportData == null) {
              _fetchCloudCallReport();
            } else if ((newType == "Phone Call Report" ||
                    newType == "Phone Call Graph") &&
                phoneCallReportData == null) {
              _fetchPhoneCallReport();
            }
          },
        ),
        reportContent,
      ],
    );
  }

  Widget _buildReportSectionHeader(
    String title,
    IconData icon, {
    required bool isTableActive,
    required VoidCallback onToggleView,
    required VoidCallback onRefresh,
    required Function(String) onTypeChange,
    required bool isFlipped,
    required VoidCallback onFlip,
    bool showMoreMenu = false,
    Function(String)? onTypeSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appBarStart.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: appBarStart, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_alt_outlined,
              size: 20,
              color: appBarStart,
            ),
            onPressed: () => _openFilterForSection(title),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: Icon(
              isTableActive ? Icons.bar_chart_rounded : Icons.description,
              size: 20,
              color: appBarStart,
            ),
            onPressed: onToggleView,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(),
          ),
          if (showMoreMenu)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appBarStart.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: appBarStart,
                ),
              ),
              padding: EdgeInsets.zero,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 40),
              onSelected: (val) {
                onTypeChange(val);
                if (onTypeSelected != null) onTypeSelected(val);
              },
              itemBuilder: (context) => [
                _buildPopupItem(
                  "Call Status Report",
                  Icons.analytics_outlined,
                  title == "Call Status Report",
                ),
                if (cloudCallPermission1)
                  _buildPopupItem(
                    "Cloud Call Report",
                    Icons.cloud_outlined,
                    title == "Cloud Call Report",
                  ),
                _buildPopupItem(
                  "Phone Call Report",
                  Icons.phone_outlined,
                  title == "Phone Call Report",
                ),
              ],
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    bool isSelected,
  ) {
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isSelected ? appBarStart : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? appBarStart : textPrimary,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle_rounded, size: 16, color: appBarStart),
        ],
      ),
    );
  }

  Widget _buildCallStatusReport({bool isFlipped = false}) {
    if (isCallStatusLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    var details = callStatusReport?.data?.details ?? [];
    if (details.isEmpty) return _buildEmptyReport();

    String staffNames = "";
    if (callStatusStaffs.isNotEmpty && staffList.isNotEmpty) {
      staffNames = staffList
          .where((s) => callStatusStaffs.contains(s.userIdStaff.toString()))
          .map((s) => s.name)
          .join(", ");
    }
    int totalCount =
        int.tryParse(callStatusReport?.data?.totalCount ?? "0") ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReportHeader(
            staffNames,
            showCallStatusTable
                ? callStatusTableLastUpdated
                : callStatusLastUpdated,
            fromDate: callStatusFromDate ?? DateTime.now(),
            toDate: callStatusToDate ?? DateTime.now(),
            onRefresh: showCallStatusTable
                ? _fetchCallStatusTableReport
                : _fetchCallStatusReport,
          ),
          showCallStatusTable
              ? _buildCallStatusMatrixTable(isFlipped: isFlipped)
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      setState(() => showCallStatusTable = true);
                      if (callStatusTableData == null) {
                        _fetchCallStatusTableReport();
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 8, top: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Response Analytics",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: appBarStart.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Total: $totalCount",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: appBarStart,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: isCallStatusExpanded
                              ? details.length
                              : (details.length > 6 ? 6 : details.length),
                          itemBuilder: (context, index) {
                            final item = details[index];
                            final count = int.tryParse(item.total ?? "0") ?? 0;
                            final color = _getReportItemColor(
                              item.callResponse,
                              index,
                            );
                            final percentage = totalCount > 0
                                ? (count / totalCount).clamp(0.0, 1.0)
                                : 0.0;
                            return InkWell(
                              onTap: () => _showCallStatusDrillDown(
                                item.callResponse ?? "N/A",
                                item.callResponseId ?? "",
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.callResponse ?? "N/A",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          "$count",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: percentage,
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (details.length > 6)
                          TextButton.icon(
                            onPressed: () => setState(
                              () =>
                                  isCallStatusExpanded = !isCallStatusExpanded,
                            ),
                            icon: Icon(
                              isCallStatusExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                            label: Text(
                              isCallStatusExpanded ? "Show Less" : "Show More",
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _showCallStatusDrillDown(
    String title,
    String callResultId,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final csro.CallStatusReportOntapModel? result =
        await HttpService.callStatusReportOntapData(
      fromDate: DateFormat(
        'dd-MM-yyyy',
      ).format(callStatusFromDate ?? DateTime.now()),
      toDate: DateFormat(
        'dd-MM-yyyy',
      ).format(callStatusToDate ?? DateTime.now()),
      staffId: callStatusStaffs.join(','),
      callResponseId: callResultId,
    );

    if (mounted) Navigator.pop(context);

    if (result != null) {
      final drillDownDetails = result.data?.details
              ?.map(
                (s) => {
                  'name': s.staffName,
                  'count': s.total.toString(),
                  'staffId': s.userId,
                },
              )
              .toList() ??
          [];
      _showReportDetailsDialog(
        title,
        drillDownDetails,
        Colors.blue,
        onStaffTap: (staffItem) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: title,
                fromDate: callStatusFromDate != null
                    ? DateFormat('yyyy-MM-dd').format(callStatusFromDate!)
                    : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                toDate: callStatusToDate != null
                    ? DateFormat('yyyy-MM-dd').format(callStatusToDate!)
                    : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                callResId: callResultId,
                callResName: title,
                staff: staffItem['staffId'],
                staffName: staffItem['name'],
                isCallStatus: "1",
              ),
            ),
          ).then((_) {
            _fetchCallStatusReport();
          });
        },
      );
    }
  }

  Widget _buildStageWiseReport({bool isFlipped = false}) {
    if (isStageWiseLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    var details = stagewiseReport?.data.details ?? [];
    int totalCount = stagewiseReport?.data.totalCount ?? 0;

    if (details.isEmpty) {
      return _buildEmptyReport();
    }

    String staffNames = "";
    if (stageWiseStaffs.isNotEmpty && staffList.isNotEmpty) {
      staffNames = staffList
          .where((s) => stageWiseStaffs.contains(s.userIdStaff.toString()))
          .map((s) => s.name)
          .join(", ");
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReportHeader(
            staffNames,
            showStageWiseTable
                ? stageWiseTableLastUpdated
                : stageWiseLastUpdated,
            fromDate: stageWiseFromDate,
            toDate: stageWiseToDate,
            onRefresh: showStageWiseTable
                ? _fetchStageWiseTableReport
                : _fetchStageWiseReport,
          ),
          showStageWiseTable
              ? _buildStageWiseMatrixTable(isFlipped: isFlipped)
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      setState(() => showStageWiseTable = true);
                      if (stageWiseTableData == null) {
                        _fetchStageWiseTableReport();
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(26, 20, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: (isStageWiseExpanded
                                    ? details
                                    : details.take(6).toList())
                                .map((item) {
                              int index = details.indexOf(item);
                              final color = _getReportItemColor(
                                item.callResult,
                                index,
                              );
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == details.length - 1 ? 0 : 20,
                                ),
                                child: _buildStageItem(
                                  item.callResult,
                                  item.total,
                                  color,
                                  totalCount,
                                  item.callResultId,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (details.length > 6)
                          TextButton.icon(
                            onPressed: () => setState(
                              () => isStageWiseExpanded = !isStageWiseExpanded,
                            ),
                            icon: Icon(
                              isStageWiseExpanded
                                  ? Icons.keyboard_arrow_left
                                  : Icons.keyboard_arrow_right,
                            ),
                            label: Text(
                              isStageWiseExpanded ? "Show Less" : "Show More",
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStageItem(
    String title,
    int count,
    Color color,
    int totalCount,
    String callResultId,
  ) {
    return InkWell(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final swro.StagewiseReportOntapModel? result =
            await HttpService.stagwWiseReportOntapData(
          fromDate: stageWiseFromDate != null
              ? DateFormat('dd-MM-yyyy').format(stageWiseFromDate!)
              : null,
          toDate: stageWiseToDate != null
              ? DateFormat('dd-MM-yyyy').format(stageWiseToDate!)
              : null,
          staffId: stageWiseStaffs.join(','),
          callResultId: callResultId,
        );

        if (mounted) Navigator.pop(context);
        if (result != null) {
          final drillDownDetails = result.data.details
              .map(
                (s) => {
                  'name': s.staffName,
                  'count': s.total.toString(),
                  'staffId': s.userId,
                },
              )
              .toList();
          _showReportDetailsDialog(
            '$title Stage',
            drillDownDetails,
            color,
            onStaffTap: (staffItem) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewLeadsNew(
                    widget.token,
                    updateLeadPermission1,
                    deleteLeadPermission1,
                    cloudCallPermission1,
                    pageName: '$title Stage',
                    fromDate: stageWiseFromDate != null
                        ? DateFormat('yyyy-MM-dd').format(stageWiseFromDate!)
                        : null,
                    toDate: stageWiseToDate != null
                        ? DateFormat('yyyy-MM-dd').format(stageWiseToDate!)
                        : null,
                    leadType: callResultId,
                    staffName: staffItem['name'],
                    staff: staffItem['staffId'],
                    isActiveReport: "1",
                  ),
                ),
              ).then((_) {
                _fetchStageWiseReport();
              });
            },
          );
        }
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: totalCount > 0
                      ? (count / totalCount).clamp(0.1, 1.0)
                      : 0.1,
                  strokeWidth: 4,
                  color: color,
                  backgroundColor: color.withOpacity(0.1),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadSourceReport({bool isFlipped = false}) {
    if (isLeadSourceLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    String staffNames = "";
    if (leadSourceStaffs.isNotEmpty && staffList.isNotEmpty) {
      staffNames = staffList
          .where((s) => leadSourceStaffs.contains(s.userIdStaff.toString()))
          .map((s) => s.name)
          .join(", ");
    }
    int totalCount = leadSourceReport?.data.totalCount ?? 0;

    if (leadSourceDetails.isEmpty) {
      return _buildEmptyReport();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReportHeader(
            staffNames,
            showLeadSourceTable
                ? leadSourceTableLastUpdated
                : leadSourceLastUpdated,
            fromDate: leadSourceFromDate ??
                DateTime(DateTime.now().year, DateTime.now().month, 1),
            toDate: leadSourceToDate ?? DateTime.now(),
            onRefresh: showLeadSourceTable
                ? _fetchLeadSourceTableReport
                : _fetchLeadSourceReport,
          ),
          showLeadSourceTable
              ? _buildLeadSourceMatrixTable(isFlipped: isFlipped)
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      setState(() => showLeadSourceTable = true);
                      if (leadSourceTableData == null) {
                        _fetchLeadSourceTableReport();
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 243, 243),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: isLeadSourceExpanded
                              ? leadSourceDetails.length
                              : (leadSourceDetails.length > 6
                                  ? 6
                                  : leadSourceDetails.length),
                          itemBuilder: (context, index) {
                            final item = leadSourceDetails[index];
                            final percent = totalCount > 0
                                ? (item.total / totalCount).clamp(0.0, 1.0)
                                : 0.0;
                            final color = _colors[index % _colors.length];

                            return InkWell(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                final lsro.LeadSourceReportOntapModel? result =
                                    await HttpService.leadSourceReportOntapData(
                                  fromDate: DateFormat('dd-MM-yyyy').format(
                                    leadSourceFromDate ??
                                        DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          1,
                                        ),
                                  ),
                                  toDate: DateFormat('dd-MM-yyyy').format(
                                    leadSourceToDate ?? DateTime.now(),
                                  ),
                                  staffId: leadSourceStaffs.join(','),
                                  leadSourceId: item.leadSourceId.toString(),
                                );

                                if (mounted) Navigator.pop(context);

                                if (result != null) {
                                  final drillDownDetails = result.data.details
                                      .map(
                                        (s) => {
                                          'name': s.staffName,
                                          'count': s.total.toString(),
                                          'staffId': s.userId,
                                        },
                                      )
                                      .toList();
                                  _showReportDetailsDialog(
                                    '${item.leadSource} Source',
                                    drillDownDetails,
                                    color,
                                    onStaffTap: (staffItem) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeadsNew(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName:
                                                '${item.leadSource} Source',
                                            fromDate:
                                                DateFormat('yyyy-MM-dd').format(
                                              leadSourceFromDate ??
                                                  DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month,
                                                    1,
                                                  ),
                                            ),
                                            toDate:
                                                DateFormat('yyyy-MM-dd').format(
                                              leadSourceToDate ??
                                                  DateTime.now(),
                                            ),
                                            leadSourceId: item.leadSourceId,
                                            staff: staffItem['staffId'],
                                            staffName: staffItem['name'],
                                            isLeadSource: "1",
                                          ),
                                        ),
                                      ).then((_) {
                                        _fetchLeadSourceReport();
                                      });
                                    },
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.leadSource,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                              177,
                                              0,
                                              0,
                                              0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item.total.toString(),
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          height: 10,
                                          width: (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  72) *
                                              (percent > 1 ? 1 : percent),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color,
                                                color.withOpacity(0.7),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: color.withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (leadSourceDetails.length > 6 || hasMoreLeadSource)
                          TextButton.icon(
                            onPressed: () {
                              if (!isLeadSourceExpanded && hasMoreLeadSource) {
                                _fetchLeadSourceReport(isLoadMore: true);
                              }
                              setState(
                                () => isLeadSourceExpanded =
                                    !isLeadSourceExpanded,
                              );
                            },
                            icon: isLeadSourceMoreLoading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                  )
                                : Icon(
                                    isLeadSourceExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white70,
                                  ),
                            label: Text(
                              isLeadSourceExpanded ? "Show Less" : "Show More",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryReport({bool isFlipped = false}) {
    if (isCategoryLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    String staffNames = "";
    if (categoryStaffs.isNotEmpty && staffList.isNotEmpty) {
      staffNames = staffList
          .where((s) => categoryStaffs.contains(s.userIdStaff.toString()))
          .map((s) => s.name)
          .join(", ");
    }
    int totalCount = categoryReport?.data.totalCount ?? 0;

    if (categoryDetails.isEmpty) {
      return _buildEmptyReport();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReportHeader(
            staffNames,
            showCategoryTable ? categoryTableLastUpdated : categoryLastUpdated,
            fromDate: categoryFromDate ?? DateTime.now(),
            toDate: categoryToDate ?? DateTime.now(),
            onRefresh: showCategoryTable
                ? _fetchCategoryTableReport
                : _fetchCategoryReport,
          ),
          showCategoryTable
              ? _buildCategoryMatrixTable(isFlipped: isFlipped)
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      setState(() => showCategoryTable = true);
                      if (categoryTableData == null) {
                        _fetchCategoryTableReport();
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: isCategoryExpanded
                              ? categoryDetails.length
                              : (categoryDetails.length > 6
                                  ? 6
                                  : categoryDetails.length),
                          itemBuilder: (context, index) {
                            final item = categoryDetails[index];
                            final percent = totalCount > 0
                                ? (item.total / totalCount).clamp(0.0, 1.0)
                                : 0.0;
                            final color = _colors[index % _colors.length];

                            return InkWell(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                final catro.LeadCategoryReportOntapModel?
                                    result = await HttpService
                                        .leadCategoryReportOntapData(
                                  fromDate: categoryFromDate != null
                                      ? DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(categoryFromDate!)
                                      : DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(DateTime.now()),
                                  toDate: categoryToDate != null
                                      ? DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(categoryToDate!)
                                      : DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(DateTime.now()),
                                  staffId: categoryStaffs.join(','),
                                  leadCategoryId:
                                      item.leadCategoryId.toString(),
                                );

                                if (mounted) Navigator.pop(context);

                                if (result != null) {
                                  final drillDownDetails = result.data.details
                                      .map(
                                        (s) => {
                                          'name': s.staffName,
                                          'count': s.total.toString(),
                                          'staffId': s.userId,
                                        },
                                      )
                                      .toList();
                                  _showReportDetailsDialog(
                                    '${item.leadCategory} Category',
                                    drillDownDetails,
                                    color,
                                    onStaffTap: (staffItem) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeadsNew(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName:
                                                '${item.leadCategory} Category',
                                            fromDate: categoryFromDate != null
                                                ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(categoryFromDate!)
                                                : DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(DateTime.now()),
                                            toDate: categoryToDate != null
                                                ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(categoryToDate!)
                                                : DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(DateTime.now()),
                                            category:
                                                item.leadCategoryId.toString(),
                                            categoryName: item.leadCategory,
                                            staff: staffItem['staffId'],
                                            staffName: staffItem['name'],
                                            isLeadCategory: "1",
                                          ),
                                        ),
                                      ).then((_) {
                                        _fetchCategoryReport();
                                      });
                                    },
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.leadCategory,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          item.total.toString(),
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          height: 10,
                                          width: (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  72) *
                                              (percent > 1 ? 1 : percent),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color,
                                                color.withOpacity(0.7),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: color.withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (categoryDetails.length > 6 || hasMoreCategory)
                          TextButton.icon(
                            onPressed: () {
                              if (!isCategoryExpanded && hasMoreCategory) {
                                _fetchCategoryReport(isLoadMore: true);
                              }
                              setState(
                                () => isCategoryExpanded = !isCategoryExpanded,
                              );
                            },
                            icon: isCategoryMoreLoading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: appBarStart,
                                    ),
                                  )
                                : Icon(
                                    isCategoryExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                            label: Text(
                              isCategoryExpanded ? "Show Less" : "Show More",
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCallStatusMatrixTable({bool isFlipped = false}) {
    if (isCallStatusTableLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (callStatusTableData == null || callStatusTableData!.data.isEmpty) {
      return _buildEmptyReport();
    }

    final headers = callStatusTableData!.data.first.statuses;

    final data = List<csrt.CallStatusReportData>.from(
      callStatusTableData!.data,
    );

    csrt.CallStatusReportData? totalRow;
    final regularData = <csrt.CallStatusReportData>[];

    for (var item in data) {
      if (item.staffName.toLowerCase() == 'total' ||
          item.staffName.toLowerCase() == 'totals') {
        totalRow = item;
      } else {
        regularData.add(item);
      }
    }
    if (totalRow == null && regularData.isNotEmpty) {
      final totalStatuses = <csrt.CallStatus>[];
      if (regularData.first.statuses.isNotEmpty) {
        for (int i = 0; i < regularData.first.statuses.length; i++) {
          final headerStatus = regularData.first.statuses[i];
          int sum = 0;
          for (var staff in regularData) {
            if (i < staff.statuses.length) {
              sum += staff.statuses[i].total;
            }
          }
          totalStatuses.add(
            csrt.CallStatus(
              callResponse: headerStatus.callResponse,
              callResponseId: headerStatus.callResponseId,
              total: sum,
            ),
          );
        }
      }
      int totalOverall = 0;
      for (var status in totalStatuses) {
        totalOverall += status.total;
      }
      totalRow = csrt.CallStatusReportData(
        staffName: 'TOTAL',
        userId: '',
        statuses: totalStatuses,
        totalCount: totalOverall,
      );
    }

    regularData.sort((a, b) => a.staffName.compareTo(b.staffName));
    final table = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: appBarStart.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.screen_rotation_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () {
                            if (_isFlipped1) {
                              FlutterAutoOrientation.portraitUpMode();
                            } else {
                              FlutterAutoOrientation.landscapeLeftMode();
                            }
                            setState(() => _isFlipped1 = !_isFlipped1);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () => _shareTableDataAsPdf(
                            _reportType1,
                            callStatusTableData!.data,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // const SizedBox(width: 4),
                        // Expanded(
                        //   child: Text(
                        //     'STAFF NAME',
                        //     style: TextStyle(
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.w900,
                        //       color: appBarStart.withOpacity(0.8),
                        //       letterSpacing: 0.5,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Staff name rows
                  ...regularData.asMap().entries.map((entry) {
                    final staff = entry.value;
                    return Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: entry.key % 2 == 0
                            ? Colors.white
                            : appBarStart.withOpacity(0.02),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade50),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        staff.staffName,
                        134,
                        total: staff.totalCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewLeadsNew(
                                widget.token,
                                updateLeadPermission1,
                                deleteLeadPermission1,
                                cloudCallPermission1,
                                pageName: 'Leads for ${staff.staffName}',
                                fromDate: callStatusFromDate != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(callStatusFromDate!)
                                    : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                toDate: callStatusToDate != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(callStatusToDate!)
                                    : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                staffId: staff.userId,
                                isCallStatus: "1",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  // Total row in left column
                  if (totalRow != null)
                    Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.1),
                        border: Border(
                          top: BorderSide(
                            color: appBarStart.withOpacity(0.3),
                            width: 2,
                          ),
                          bottom: BorderSide(
                            color: appBarStart.withOpacity(0.2),
                          ),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        'TOTAL',
                        134,
                        isTotal: true,
                        total: totalRow.totalCount,
                        // Removed fontWeight parameter
                      ),
                    ),
                ],
              ),
            ),
            // Scrollable right columns with status counts
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header row for status columns
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appBarStart.withOpacity(0.12),
                            appBarStart.withOpacity(0.04),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          ...headers.map((h) {
                            final idx = headers.indexOf(h);
                            final color = _getReportItemColor(
                              h.callResponse,
                              idx,
                            );
                            return _buildMatrixHeaderCell(
                              h.callResponse,
                              Icons.call_rounded,
                              _getColWidth(h.callResponse),
                              color: color,
                            );
                          }),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // Data rows for each staff
                    ...regularData.asMap().entries.map((entry) {
                      final s = entry.value;
                      return Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: entry.key % 2 == 0
                              ? Colors.transparent
                              : appBarStart.withOpacity(0.02),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...s.statuses.map(
                              (st) => _buildMatrixCountCell(
                                st.total.toString(),
                                _getReportItemColor(
                                  st.callResponse,
                                  s.statuses.indexOf(st),
                                ),
                                _getColWidth(st.callResponse),
                                onTap: () {
                                  final fromDateLocal = callStatusFromDate;
                                  final toDateLocal = callStatusToDate;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                        widget.token,
                                        updateLeadPermission1,
                                        deleteLeadPermission1,
                                        cloudCallPermission1,
                                        pageName: st.callResponse,
                                        fromDate: fromDateLocal != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(fromDateLocal)
                                            : DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(DateTime.now()),
                                        toDate: toDateLocal != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(toDateLocal)
                                            : DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(DateTime.now()),
                                        staffId: s.userId,
                                        callResId: st.callResponseId,
                                        isCallStatus: "1",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    }),
                    // Total row in right columns
                    if (totalRow != null)
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: appBarStart.withOpacity(0.08),
                          border: Border(
                            top: BorderSide(
                              color: appBarStart.withOpacity(0.3),
                              width: 2,
                            ),
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...totalRow.statuses.map(
                              (st) => _buildMatrixCountCell(
                                st.total.toString(),
                                _getReportItemColor(
                                  st.callResponse,
                                  totalRow!.statuses.indexOf(st),
                                ),
                                _getColWidth(st.callResponse),
                                isTotal: true,
                                // Removed fontWeight parameter
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return table;
  }

  Widget _buildStageWiseMatrixTable({bool isFlipped = false}) {
    if (isStageWiseTableLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (stageWiseTableData == null || stageWiseTableData!.data.isEmpty) {
      return _buildEmptyReport();
    }

    final data = List<swrt.StagewiseReportData>.from(stageWiseTableData!.data);

    swrt.StagewiseReportData? totalRow;
    final regularData = <swrt.StagewiseReportData>[];

    for (var item in data) {
      if (item.staffName.toLowerCase() == 'total' ||
          item.staffName.toLowerCase() == 'totals') {
        totalRow = item;
      } else {
        regularData.add(item);
      }
    }

    // If no total row exists in the data, create one
    if (totalRow == null && regularData.isNotEmpty) {
      // Create a total row by summing all values
      final totalStatuses = <swrt.StageStatus>[];

      // Use the headers from the first staff member as template
      if (regularData.first.statuses.isNotEmpty) {
        for (int i = 0; i < regularData.first.statuses.length; i++) {
          final headerStatus = regularData.first.statuses[i];
          int sum = 0;

          // Sum this status type across all staff
          for (var staff in regularData) {
            if (i < staff.statuses.length) {
              sum += staff.statuses[i].total;
            }
          }

          // Create a new StageStatus object with the sum
          totalStatuses.add(
            swrt.StageStatus(
              callResult: headerStatus.callResult,
              callResultId: headerStatus.callResultId,
              total: sum,
            ),
          );
        }
      }

      // Calculate total overall count
      int totalOverall = 0;
      for (var status in totalStatuses) {
        totalOverall += status.total;
      }

      // Create the total row
      totalRow = swrt.StagewiseReportData(
        staffName: 'TOTAL',
        userId: '',
        statuses: totalStatuses,
        totalCount: totalOverall,
      );
    }

    regularData.sort((a, b) => a.staffName.compareTo(b.staffName));

    final headers = stageWiseTableData!.data.first.statuses;

    final table = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            // Fixed left column with staff names
            Container(
              width: 154,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header for staff name column
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: appBarStart.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.screen_rotation_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () {
                            if (_isFlipped2) {
                              FlutterAutoOrientation.portraitUpMode();
                            } else {
                              FlutterAutoOrientation.landscapeLeftMode();
                            }
                            setState(() => _isFlipped2 = !_isFlipped2);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () =>
                              _shareTableDataAsPdf("Stage-wise Report", data),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // const SizedBox(width: 4),
                        // Expanded(
                        //   child: Text(
                        //     'STAFF NAME',
                        //     style: TextStyle(
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.w900,
                        //       color: appBarStart.withOpacity(0.8),
                        //       letterSpacing: 0.5,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Staff name rows
                  ...regularData.asMap().entries.map((entry) {
                    final staff = entry.value;
                    return Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: entry.key % 2 == 0
                            ? Colors.white
                            : appBarStart.withOpacity(0.02),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade50),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        staff.staffName,
                        134,
                        total: staff.totalCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewLeadsNew(
                                widget.token,
                                updateLeadPermission1,
                                deleteLeadPermission1,
                                cloudCallPermission1,
                                pageName: 'Leads for ${staff.staffName}',
                                fromDate: stageWiseFromDate != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(stageWiseFromDate!)
                                    : null,
                                toDate: stageWiseToDate != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(stageWiseToDate!)
                                    : null,
                                staffId: staff.userId,
                                isActiveReport: "1",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  // Total row in left column
                  if (totalRow != null)
                    Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.12),
                        border: Border(
                          top: BorderSide(
                            color: appBarStart.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        'TOTAL',
                        134,
                        isTotal: true,
                        total: totalRow.totalCount,
                      ),
                    ),
                ],
              ),
            ),
            // Scrollable right columns with status counts
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header row for status columns
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          ...headers.map(
                            (h) => _buildMatrixHeaderCell(
                              h.callResult,
                              Icons.pie_chart_rounded,
                              _getColWidth(h.callResult),
                            ),
                          ),
                          _buildMatrixHeaderCell(
                            'Total',
                            Icons.summarize_rounded,
                            70,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // Data rows for each staff
                    ...regularData.asMap().entries.map((entry) {
                      final s = entry.value;
                      return Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: entry.key % 2 == 0
                              ? Colors.transparent
                              : appBarStart.withOpacity(0.02),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...s.statuses.map(
                              (st) => _buildMatrixCountCell(
                                st.total.toString(),
                                _getReportItemColor(
                                  st.callResult,
                                  s.statuses.indexOf(st),
                                ),
                                _getColWidth(st.callResult),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                        widget.token,
                                        updateLeadPermission1,
                                        deleteLeadPermission1,
                                        cloudCallPermission1,
                                        pageName: st.callResult,
                                        fromDate: stageWiseFromDate != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(stageWiseFromDate!)
                                            : null,
                                        toDate: stageWiseToDate != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(stageWiseToDate!)
                                            : null,
                                        staffId: s.userId,
                                        status: st.callResultId,
                                        isActiveReport: "1",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            _buildMatrixTotalCell(s.totalCount.toString(), 70),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    }),
                    // Total row in right columns
                    if (totalRow != null)
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: appBarStart.withOpacity(0.08),
                          border: Border(
                            top: BorderSide(
                              color: appBarStart.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...totalRow.statuses.map(
                              (st) => _buildMatrixCountCell(
                                st.total.toString(),
                                _getReportItemColor(
                                  st.callResult,
                                  totalRow!.statuses.indexOf(st),
                                ),
                                _getColWidth(st.callResult),
                                isTotal: true,
                              ),
                            ),
                            _buildMatrixTotalCell(
                              totalRow.totalCount.toString() ?? '0',
                              70,
                              isSubTotal: true,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return table;
  }

  Widget _buildLeadSourceMatrixTable({bool isFlipped = false}) {
    if (isLeadSourceTableLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (leadSourceTableData == null || leadSourceTableData!.data.isEmpty) {
      return _buildEmptyReport();
    }

    final data = List<lsrt.LeadSourceReportData>.from(
      leadSourceTableData!.data,
    );

    lsrt.LeadSourceReportData? totalRow;
    final regularData = <lsrt.LeadSourceReportData>[];

    for (var item in data) {
      if (item.staffName.toLowerCase() == 'total' ||
          item.staffName.toLowerCase() == 'totals') {
        totalRow = item;
      } else {
        regularData.add(item);
      }
    }

    // If no total row exists in the data, create one
    if (totalRow == null && regularData.isNotEmpty) {
      // Create a total row by summing all values
      final totalStatuses = <lsrt.LeadSourceStatus>[];

      // Use the headers from the first staff member as template
      if (regularData.first.statuses.isNotEmpty) {
        for (int i = 0; i < regularData.first.statuses.length; i++) {
          final headerStatus = regularData.first.statuses[i];
          int sum = 0;

          // Sum this source type across all staff
          for (var staff in regularData) {
            if (i < staff.statuses.length) {
              sum += staff.statuses[i].total;
            }
          }

          // Create a new LeadSourceStatus object with the sum
          totalStatuses.add(
            lsrt.LeadSourceStatus(
              leadSource: headerStatus.leadSource,
              leadSourceId: headerStatus.leadSourceId,
              total: sum,
            ),
          );
        }
      }

      // Calculate total overall count
      int totalOverall = 0;
      for (var status in totalStatuses) {
        totalOverall += status.total;
      }

      // Create the total row
      totalRow = lsrt.LeadSourceReportData(
        staffName: 'TOTAL',
        userId: '',
        statuses: totalStatuses,
        totalCount: totalOverall,
      );
    }

    regularData.sort((a, b) => a.staffName.compareTo(b.staffName));

    final headers = leadSourceTableData!.data.first.statuses;

    if (isFlipped) {
      return _buildVerticalTableRedesign(
        title: "Lead Source Report",
        data: data,
        headers: headers.map((s) => s.leadSource).toList(),
        onFlip: () => setState(() => _isFlipped3 = !_isFlipped3),
      );
    }

    final table = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            // Fixed left column with staff names
            Container(
              width: 154,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header for staff name column
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: appBarStart.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.screen_rotation_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () {
                            if (_isFlipped3) {
                              FlutterAutoOrientation.portraitUpMode();
                            } else {
                              FlutterAutoOrientation.landscapeLeftMode();
                            }
                            setState(() => _isFlipped3 = !_isFlipped3);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () =>
                              _shareTableDataAsPdf("Lead Source Report", data),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // const SizedBox(width: 4),
                        // Expanded(
                        //   child: Text(
                        //     'STAFF NAME',
                        //     style: TextStyle(
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.w900,
                        //       color: appBarStart.withOpacity(0.8),
                        //       letterSpacing: 0.5,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Staff name rows
                  ...regularData.asMap().entries.map((entry) {
                    final staff = entry.value;
                    return Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: entry.key % 2 == 0
                            ? Colors.white
                            : appBarStart.withOpacity(0.02),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade50),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        staff.staffName,
                        134,
                        total: staff.totalCount,
                        onTap: () {
                          final fromDateLocal = leadSourceFromDate;
                          final toDateLocal = leadSourceToDate;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewLeadsNew(
                                widget.token,
                                updateLeadPermission1,
                                deleteLeadPermission1,
                                cloudCallPermission1,
                                pageName: 'Leads for ${staff.staffName}',
                                fromDate: fromDateLocal != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(fromDateLocal)
                                    : DateFormat('yyyy-MM-dd').format(
                                        DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          1,
                                        ),
                                      ),
                                toDate: toDateLocal != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(toDateLocal)
                                    : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                staffId: staff.userId,
                                isLeadSource: "1",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  // Total row in left column
                  if (totalRow != null)
                    Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.12),
                        border: Border(
                          top: BorderSide(
                            color: appBarStart.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        'TOTAL',
                        134,
                        isTotal: true,
                        total: totalRow.totalCount,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          ...headers.map(
                            (h) => _buildMatrixHeaderCell(
                              h.leadSource,
                              Icons.source_rounded,
                              _getColWidth(h.leadSource),
                            ),
                          ),
                          _buildMatrixHeaderCell(
                            'Total',
                            Icons.summarize_rounded,
                            70,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // Data rows for each staff
                    ...regularData.asMap().entries.map((entry) {
                      final s = entry.value;
                      return Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: entry.key % 2 == 0
                              ? Colors.transparent
                              : appBarStart.withOpacity(0.02),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...s.statuses.map(
                              (st) => _buildMatrixCountCell(
                                st.total.toString(),
                                _getReportItemColor(
                                  st.leadSource,
                                  s.statuses.indexOf(st),
                                ),
                                _getColWidth(st.leadSource),
                                onTap: () {
                                  final fromDateLocal = leadSourceFromDate;
                                  final toDateLocal = leadSourceToDate;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                        widget.token,
                                        updateLeadPermission1,
                                        deleteLeadPermission1,
                                        cloudCallPermission1,
                                        pageName: st.leadSource,
                                        fromDate: fromDateLocal != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(fromDateLocal)
                                            : DateFormat('yyyy-MM-dd').format(
                                                DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  1,
                                                ),
                                              ),
                                        toDate: toDateLocal != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(toDateLocal)
                                            : DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(DateTime.now()),
                                        staffId: s.userId,
                                        leadSourceId: st.leadSourceId,
                                        isLeadSource: "1",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            _buildMatrixTotalCell(s.totalCount.toString(), 70),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    }),
                    // Total row in right columns
                    if (totalRow != null)
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: appBarStart.withOpacity(0.08),
                          border: Border(
                            top: BorderSide(
                              color: appBarStart.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...totalRow.statuses.map(
                              (st) => _buildMatrixCountCell(
                                st.total.toString(),
                                _getReportItemColor(
                                  st.leadSource,
                                  totalRow!.statuses.indexOf(st),
                                ),
                                _getColWidth(st.leadSource),
                                isTotal: true,
                              ),
                            ),
                            _buildMatrixTotalCell(
                              totalRow.totalCount.toString(),
                              70,
                              isSubTotal: true,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return table;
  }

  Widget _buildCategoryMatrixTable({bool isFlipped = false}) {
    if (isCategoryTableLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (categoryTableData == null ||
        (categoryTableData!.data?.isEmpty ?? true)) {
      return _buildEmptyReport();
    }

    final data = List<catrt.StaffCategoryData>.from(
      categoryTableData!.data ?? [],
    );

    catrt.StaffCategoryData? totalRow;
    final regularData = <catrt.StaffCategoryData>[];
    for (var item in data) {
      if (item.staffName?.toLowerCase() == 'total' ||
          item.staffName?.toLowerCase() == 'totals') {
        totalRow = item;
      } else {
        regularData.add(item);
      }
    }

    // If no total row exists in the data, create one
    if (totalRow == null && regularData.isNotEmpty) {
      // Create a total row by summing all values
      final totalStatuses = <catrt.CategoryStatus>[];

      // Use the headers from the first staff member as template
      if (regularData.first.statuses?.isNotEmpty ?? false) {
        for (int i = 0; i < regularData.first.statuses!.length; i++) {
          final headerStatus = regularData.first.statuses![i];
          int sum = 0;

          // Sum this category across all staff
          for (var staff in regularData) {
            if (staff.statuses != null && i < staff.statuses!.length) {
              final statusTotal = staff.statuses![i].total;
              if (statusTotal != null) {
                sum += int.tryParse(statusTotal.toString()) ?? 0;
              }
            }
          }

          // Create a new CategoryStatus object with the sum
          totalStatuses.add(
            catrt.CategoryStatus(
              leadCategory: headerStatus.leadCategory,
              leadCategoryId: headerStatus.leadCategoryId,
              total: sum.toString(),
            ),
          );
        }
      }

      // Calculate total overall count
      int totalOverall = 0;
      for (var status in totalStatuses) {
        totalOverall += int.tryParse(status.total ?? '0') ?? 0;
      }

      // Create the total row
      totalRow = catrt.StaffCategoryData(
        staffName: 'TOTAL',
        userId: '',
        statuses: totalStatuses,
        totalCount: totalOverall,
      );
    }

    regularData.sort(
      (a, b) => (a.staffName ?? '').compareTo(b.staffName ?? ''),
    );

    final headers = data.isNotEmpty ? (data.first.statuses ?? []) : [];

    if (isFlipped) {
      return _buildVerticalTableRedesign(
        title: "Category Report",
        data: data,
        headers: headers.map((s) => s.leadCategory?.toString() ?? '').toList(),
        onFlip: () => setState(() => _isFlipped4 = !_isFlipped4),
      );
    }

    final table = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Container(
              width: 154,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: appBarStart.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.screen_rotation_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () {
                            if (_isFlipped4) {
                              FlutterAutoOrientation.portraitUpMode();
                            } else {
                              FlutterAutoOrientation.landscapeLeftMode();
                            }
                            setState(() => _isFlipped4 = !_isFlipped4);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () =>
                              _shareTableDataAsPdf("Category Report", data),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // const SizedBox(width: 4),
                        // Expanded(
                        //   child: Text(
                        //     'STAFF NAME',
                        //     style: TextStyle(
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.w900,
                        //       color: appBarStart.withOpacity(0.8),
                        //       letterSpacing: 0.5,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  ...regularData.asMap().entries.map((entry) {
                    final s = entry.value;
                    return Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: entry.key % 2 == 0
                            ? Colors.white
                            : appBarStart.withOpacity(0.02),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade50),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        s.staffName ?? 'N/A',
                        134,
                        total: s.totalCount,
                        onTap: () {
                          final fromDateLocal = categoryFromDate;
                          final toDateLocal = categoryToDate;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewLeadsNew(
                                widget.token,
                                updateLeadPermission1,
                                deleteLeadPermission1,
                                cloudCallPermission1,
                                pageName: 'Leads for ${s.staffName}',
                                fromDate: fromDateLocal != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(fromDateLocal)
                                    : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                toDate: toDateLocal != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(toDateLocal)
                                    : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                staffId: s.userId,
                                staff: s.userId,
                                staffName: s.staffName,
                                isLeadCategory: "1",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  if (totalRow != null)
                    Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.12),
                        border: Border(
                          top: BorderSide(
                            color: appBarStart.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        'TOTAL',
                        134,
                        isTotal: true,
                        total: totalRow.totalCount,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          ...headers.map(
                            (h) => _buildMatrixHeaderCell(
                              h.leadCategory ?? 'N/A',
                              Icons.category_rounded,
                              _getColWidth(h.leadCategory ?? ''),
                            ),
                          ),
                          _buildMatrixHeaderCell(
                            'Total',
                            Icons.summarize_rounded,
                            70,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    ...regularData.asMap().entries.map((entry) {
                      final s = entry.value;
                      return Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: entry.key % 2 == 0
                              ? Colors.transparent
                              : appBarStart.withOpacity(0.02),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...(s.statuses ?? []).map(
                              (st) => _buildMatrixCountCell(
                                st.total?.toString() ?? '0',
                                _getReportItemColor(
                                  st.leadCategory ?? '',
                                  (s.statuses ?? []).indexOf(st),
                                ),
                                _getColWidth(st.leadCategory ?? ''),
                                onTap: () {
                                  final fromDateLocal = categoryFromDate;
                                  final toDateLocal = categoryToDate;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                        widget.token,
                                        updateLeadPermission1,
                                        deleteLeadPermission1,
                                        cloudCallPermission1,
                                        pageName: 'Leads for ${s.staffName}',
                                        fromDate: fromDateLocal != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(fromDateLocal)
                                            : DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(DateTime.now()),
                                        toDate: toDateLocal != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(toDateLocal)
                                            : DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(DateTime.now()),
                                        staffId: s.userId,
                                        staff: s.userId,
                                        staffName: s.staffName,
                                        category: st.leadCategoryId?.toString(),
                                        categoryName: st.leadCategory,
                                        isLeadCategory: "1",

                                        // widget.token,
                                        // updateLeadPermission1,
                                        // deleteLeadPermission1,
                                        // cloudCallPermission1,
                                        // pageName: st.leadCategory ?? 'Leads',
                                        // fromDate: fromDateLocal != null
                                        //     ? DateFormat('yyyy-MM-dd')
                                        //         .format(fromDateLocal)
                                        //     : DateFormat('yyyy-MM-dd')
                                        //         .format(DateTime.now()),
                                        // toDate: toDateLocal != null
                                        //     ? DateFormat('yyyy-MM-dd')
                                        //         .format(toDateLocal)
                                        //     : DateFormat('yyyy-MM-dd')
                                        //         .format(DateTime.now()),
                                        // staffId: s.userId,
                                        // category: st.leadCategoryId?.toString(),
                                        // isLeadCategory: "1",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            _buildMatrixTotalCell(
                              s.totalCount?.toString() ?? '0',
                              70,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    }),
                    if (totalRow != null)
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: appBarStart.withOpacity(0.08),
                          border: Border(
                            top: BorderSide(
                              color: appBarStart.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            ...(totalRow.statuses ?? []).map(
                              (st) => _buildMatrixCountCell(
                                st.total?.toString() ?? '0',
                                _getReportItemColor(
                                  st.leadCategory ?? '',
                                  totalRow!.statuses!.indexOf(st),
                                ),
                                _getColWidth(st.leadCategory ?? ''),
                                isTotal: true,
                              ),
                            ),
                            _buildMatrixTotalCell(
                              totalRow.totalCount?.toString() ?? '0',
                              70,
                              isSubTotal: true,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isFlipped) {
      return RotatedBox(quarterTurns: 1, child: table);
    }
    return table;
  }

  Widget _buildVerticalTableRedesign({
    required String title,
    required List<dynamic> data,
    required List<String> headers,
    required VoidCallback onFlip,
  }) {
    // Separate total row from regular data
    dynamic totalRow;
    final regularData = <dynamic>[];

    for (var item in data) {
      final String staffName = _getStaffName(item);
      if (staffName.toLowerCase() == 'total' ||
          staffName.toLowerCase() == 'totals') {
        totalRow = item;
      } else {
        regularData.add(item);
      }
    }

    // Sort regular data alphabetically
    regularData.sort((a, b) => _getStaffName(a).compareTo(_getStaffName(b)));

    // Build the horizontal table
    Widget horizontalTable = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            // Left column with staff names
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with flip and share buttons
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: appBarStart.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.screen_rotation_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: onFlip,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: appBarStart,
                          ),
                          onPressed: () => _shareTableDataAsPdf(title, data),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // const SizedBox(width: 4),
                        // Expanded(
                        //   child: Text(
                        //     'STAFF NAME',
                        //     style: TextStyle(
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.w900,
                        //       color: appBarStart.withOpacity(0.8),
                        //       letterSpacing: 0.5,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Staff name rows
                  ...regularData.asMap().entries.map((entry) {
                    final staff = entry.value;
                    final staffName = _getStaffName(staff);
                    final total = _getGrandTotal(staff);
                    final userId = _getUserId(staff);

                    return Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: entry.key % 2 == 0
                            ? Colors.white
                            : appBarStart.withOpacity(0.02),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade50),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        staffName,
                        134,
                        total: total,
                        onTap: userId != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewLeadsNew(
                                      widget.token,
                                      updateLeadPermission1,
                                      deleteLeadPermission1,
                                      cloudCallPermission1,
                                      pageName: 'Leads for $staffName',
                                      fromDate: "",
                                      toDate: "",
                                      staffId: userId,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    );
                  }),
                  // Total row
                  if (totalRow != null)
                    Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.1),
                        border: Border(
                          top: BorderSide(
                            color: appBarStart.withOpacity(0.3),
                            width: 2,
                          ),
                          bottom: BorderSide(
                            color: appBarStart.withOpacity(0.2),
                          ),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        'TOTAL',
                        134,
                        isTotal: true,
                        total: _getGrandTotal(totalRow),
                      ),
                    ),
                ],
              ),
            ),
            // Right section with status columns
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row with status names
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appBarStart.withOpacity(0.12),
                            appBarStart.withOpacity(0.04),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10),
                          ...headers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final header = entry.value;
                            final color = _getReportItemColor(header, idx);
                            final colWidth = _getColWidth(header);
                            return SizedBox(
                              width: colWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.call_rounded,
                                    size: 12,
                                    color: color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    header.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // Data rows for regular staff
                    ...regularData.asMap().entries.map((entry) {
                      final staff = entry.value;
                      final statuses = _getStatuses(staff);
                      final userId = _getUserId(staff);

                      return Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: entry.key % 2 == 0
                              ? Colors.transparent
                              : appBarStart.withOpacity(0.02),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 10),
                            ...statuses.asMap().entries.map((statusEntry) {
                              final st = statusEntry.value;
                              final idx = statusEntry.key;
                              final val = _getStatusValue(st);
                              final label = _getStatusLabel(st);
                              final statusId = _getStatusId(st);

                              return _buildMatrixCountCell(
                                val,
                                _getReportItemColor(label, idx),
                                _getColWidth(label),
                                onTap: userId != null && statusId != null
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewLeadsNew(
                                              widget.token,
                                              updateLeadPermission1,
                                              deleteLeadPermission1,
                                              cloudCallPermission1,
                                              pageName: label,
                                              fromDate: "",
                                              toDate: "",
                                              staffId: userId,
                                              callResId: statusId,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                              );
                            }),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    }),
                    // Total row
                    if (totalRow != null)
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: appBarStart.withOpacity(0.08),
                          border: Border(
                            top: BorderSide(
                              color: appBarStart.withOpacity(0.3),
                              width: 2,
                            ),
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 10),
                            ..._getStatuses(totalRow).asMap().entries.map((
                              entry,
                            ) {
                              final st = entry.value;
                              final idx = entry.key;
                              final val = _getStatusValue(st);
                              final label = _getStatusLabel(st);

                              return _buildMatrixCountCell(
                                val,
                                _getReportItemColor(label, idx),
                                _getColWidth(label),
                                isTotal: true,
                              );
                            }),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // If we are using flutter_auto_orientation, we don't need RotatedBox
    // The screen orientation itself handles the rotation
    return horizontalTable;
  }

  // Widget _buildVerticalTableRedesign({
  //   required String title,
  //   required List<dynamic> data,
  //   required List<String> headers,
  //   required VoidCallback onFlip,
  // }) {
  //   // Separate total row from regular data
  //   dynamic totalRow;
  //   final regularData = <dynamic>[];

  //   for (var item in data) {
  //     final String staffName = _getStaffName(item);
  //     if (staffName.toLowerCase() == 'total' ||
  //         staffName.toLowerCase() == 'totals') {
  //       totalRow = item;
  //     } else {
  //       regularData.add(item);
  //     }
  //   }

  //   // Sort regular data alphabetically
  //   regularData.sort((a, b) => _getStaffName(a).compareTo(_getStaffName(b)));

  //   // Get all status values for each header
  //   final Map<String, List<String>> statusValues = {};
  //   for (var header in headers) {
  //     statusValues[header] = [];
  //   }

  //   // Collect all values for each status
  //   for (var item in regularData) {
  //     final statuses = _getStatuses(item);
  //     for (var i = 0; i < statuses.length; i++) {
  //       final status = statuses[i];
  //       if (i < headers.length) {
  //         final header = headers[i];
  //         statusValues[header]?.add(_getStatusValue(status));
  //       }
  //     }
  //   }

  //   // Add total row values if exists
  //   if (totalRow != null) {
  //     final totalStatuses = _getStatuses(totalRow);
  //     for (var i = 0; i < totalStatuses.length; i++) {
  //       if (i < headers.length) {
  //         final header = headers[i];
  //         statusValues[header]?.add(_getStatusValue(totalStatuses[i]));
  //       }
  //     }
  //   }

  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(24),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.06),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //       border: Border.all(color: Colors.grey.shade100),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(24),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Fixed left column with status names (now becomes the row headers)
  //           Container(
  //             width: 140,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               border: Border(
  //                 right: BorderSide(color: Colors.grey.shade200, width: 1),
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: const Offset(4, 0),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               children: [
  //                 // Header with flip and share buttons
  //                 Container(
  //                   height: 60,
  //                   padding: const EdgeInsets.only(left: 8),
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [
  //                         appBarStart.withOpacity(0.12),
  //                         appBarStart.withOpacity(0.04)
  //                       ],
  //                       begin: Alignment.topCenter,
  //                       end: Alignment.bottomCenter,
  //                     ),
  //                     border: Border(
  //                       bottom: BorderSide(color: Colors.grey.shade200),
  //                     ),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       IconButton(
  //                         icon: const Icon(Icons.screen_rotation_rounded,
  //                             size: 18, color: appBarStart),
  //                         onPressed: onFlip,
  //                         padding: EdgeInsets.zero,
  //                         constraints: const BoxConstraints(),
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.share_rounded,
  //                             size: 18, color: appBarStart),
  //                         onPressed: () => _shareTableDataAsPdf(title, data),
  //                         padding: EdgeInsets.zero,
  //                         constraints: const BoxConstraints(),
  //                       ),
  //                       const SizedBox(width: 4),
  //                       Expanded(
  //                         child: Text(
  //                           'STATUS',
  //                           style: TextStyle(
  //                             fontSize: 10,
  //                             fontWeight: FontWeight.w900,
  //                             color: appBarStart.withOpacity(0.8),
  //                             letterSpacing: 0.5,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 // Status name rows (headers now become rows)
  //                 ...headers.asMap().entries.map((entry) {
  //                   final idx = entry.key;
  //                   final header = entry.value;
  //                   final color = _getReportItemColor(header, idx);

  //                   return Container(
  //                     height: 55,
  //                     padding: const EdgeInsets.only(left: 16),
  //                     decoration: BoxDecoration(
  //                       color: idx % 2 == 0
  //                           ? Colors.white
  //                           : appBarStart.withOpacity(0.02),
  //                       border: Border(
  //                         bottom: BorderSide(color: Colors.grey.shade50),
  //                       ),
  //                     ),
  //                     alignment: Alignment.centerLeft,
  //                     child: Row(
  //                       children: [
  //                         Container(
  //                           width: 30,
  //                           height: 30,
  //                           decoration: BoxDecoration(
  //                             color: color.withOpacity(0.1),
  //                             shape: BoxShape.circle,
  //                           ),
  //                           child: Center(
  //                             child: Icon(Icons.circle, color: color, size: 12),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 8),
  //                         Expanded(
  //                           child: Text(
  //                             header,
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.w600,
  //                               color: textPrimary,
  //                             ),
  //                             overflow: TextOverflow.ellipsis,
  //                             maxLines: 1,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }).toList(),
  //                 // Total row header
  //                 Container(
  //                   height: 55,
  //                   padding: const EdgeInsets.only(left: 16),
  //                   decoration: BoxDecoration(
  //                     color: appBarStart.withOpacity(0.1),
  //                     border: Border(
  //                       top: BorderSide(
  //                         color: appBarStart.withOpacity(0.3),
  //                         width: 2,
  //                       ),
  //                       bottom: BorderSide(
  //                         color: appBarStart.withOpacity(0.2),
  //                       ),
  //                     ),
  //                   ),
  //                   alignment: Alignment.centerLeft,
  //                   child: Row(
  //                     children: [
  //                       Container(
  //                         width: 30,
  //                         height: 30,
  //                         decoration: BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: [accentOrange, Colors.orange.shade700],
  //                             begin: Alignment.topLeft,
  //                             end: Alignment.bottomRight,
  //                           ),
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: const Center(
  //                           child: Icon(Icons.auto_graph_rounded,
  //                               color: Colors.white, size: 14),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 8),
  //                       const Text(
  //                         'TOTAL',
  //                         style: TextStyle(
  //                           fontSize: 11,
  //                           fontWeight: FontWeight.w900,
  //                           color: appBarStart,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           // Scrollable right section with staff columns (now becomes the data columns)
  //           Expanded(
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               physics: const BouncingScrollPhysics(),
  //               child: Row(
  //                 children: [
  //                   // Regular staff columns
  //                   ...regularData.asMap().entries.map((staffEntry) {
  //                     final staffIndex = staffEntry.key;
  //                     final staff = staffEntry.value;
  //                     final staffName = _getStaffName(staff);
  //                     final userId = _getUserId(staff);
  //                     final statuses = _getStatuses(staff);

  //                     return Container(
  //                       width: 110,
  //                       decoration: BoxDecoration(
  //                         border: Border(
  //                           right: BorderSide(color: Colors.grey.shade100),
  //                         ),
  //                       ),
  //                       child: Column(
  //                         children: [
  //                           // Staff header cell
  //                           Container(
  //                             height: 60,
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 8),
  //                             decoration: BoxDecoration(
  //                               gradient: LinearGradient(
  //                                 colors: [
  //                                   appBarStart.withOpacity(0.12),
  //                                   appBarStart.withOpacity(0.04)
  //                                 ],
  //                                 begin: Alignment.topCenter,
  //                                 end: Alignment.bottomCenter,
  //                               ),
  //                               border: Border(
  //                                 bottom:
  //                                     BorderSide(color: Colors.grey.shade200),
  //                               ),
  //                             ),
  //                             alignment: Alignment.center,
  //                             child: InkWell(
  //                               onTap: userId != null
  //                                   ? () {
  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                           builder: (context) => ViewLeadsNew(
  //                                             widget.token,
  //                                             updateLeadPermission1,
  //                                             deleteLeadPermission1,
  //                                             cloudCallPermission1,
  //                                             pageName: 'Leads for $staffName',
  //                                             fromDate: "",
  //                                             toDate: "",
  //                                             staffId: userId,
  //                                           ),
  //                                         ),
  //                                       );
  //                                     }
  //                                   : null,
  //                               child: Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   Container(
  //                                     width: 24,
  //                                     height: 24,
  //                                     decoration: BoxDecoration(
  //                                       gradient: LinearGradient(
  //                                         colors: [
  //                                           appBarStart,
  //                                           appBarStart.withOpacity(0.7)
  //                                         ],
  //                                         begin: Alignment.topLeft,
  //                                         end: Alignment.bottomRight,
  //                                       ),
  //                                       shape: BoxShape.circle,
  //                                     ),
  //                                     child: Center(
  //                                       child: Text(
  //                                         staffName.isNotEmpty
  //                                             ? staffName[0].toUpperCase()
  //                                             : '?',
  //                                         style: const TextStyle(
  //                                           color: Colors.white,
  //                                           fontSize: 10,
  //                                           fontWeight: FontWeight.bold,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 4),
  //                                   Expanded(
  //                                     child: Text(
  //                                       staffName,
  //                                       style: const TextStyle(
  //                                         fontSize: 9,
  //                                         fontWeight: FontWeight.w700,
  //                                         color: textPrimary,
  //                                       ),
  //                                       overflow: TextOverflow.ellipsis,
  //                                       maxLines: 1,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                           // Status value cells for each header
  //                           ...headers.asMap().entries.map((headerEntry) {
  //                             final headerIndex = headerEntry.key;
  //                             final header = headerEntry.value;
  //                             final color =
  //                                 _getReportItemColor(header, headerIndex);

  //                             // Find the corresponding status value for this staff and header
  //                             String value = '0';
  //                             String? statusId;
  //                             String label = '';

  //                             if (headerIndex < statuses.length) {
  //                               final status = statuses[headerIndex];
  //                               value = _getStatusValue(status);
  //                               label = _getStatusLabel(status);
  //                               statusId = _getStatusId(status);
  //                             }

  //                             return Container(
  //                               height: 55,
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 4),
  //                               decoration: BoxDecoration(
  //                                 color: staffIndex % 2 == 0 &&
  //                                         headerIndex % 2 == 0
  //                                     ? Colors.transparent
  //                                     : appBarStart.withOpacity(0.02),
  //                                 border: Border(
  //                                   bottom:
  //                                       BorderSide(color: Colors.grey.shade50),
  //                                 ),
  //                               ),
  //                               alignment: Alignment.center,
  //                               child: _buildMatrixCountCell(
  //                                 value,
  //                                 color,
  //                                 90,
  //                                 onTap: userId != null && statusId != null
  //                                     ? () {
  //                                         Navigator.push(
  //                                           context,
  //                                           MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 ViewLeadsNew(
  //                                               widget.token,
  //                                               updateLeadPermission1,
  //                                               deleteLeadPermission1,
  //                                               cloudCallPermission1,
  //                                               pageName: label,
  //                                               fromDate: "",
  //                                               toDate: "",
  //                                               staffId: userId,
  //                                               callResId: statusId,
  //                                             ),
  //                                           ),
  //                                         );
  //                                       }
  //                                     : null,
  //                               ),
  //                             );
  //                           }).toList(),
  //                           // Total cell for this staff
  //                           Container(
  //                             height: 55,
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 4),
  //                             decoration: BoxDecoration(
  //                               color: appBarStart.withOpacity(0.05),
  //                               border: Border(
  //                                 top: BorderSide(
  //                                   color: appBarStart.withOpacity(0.15),
  //                                   width: 1.5,
  //                                 ),
  //                               ),
  //                             ),
  //                             alignment: Alignment.center,
  //                             child: _buildMatrixTotalCell(
  //                               _getGrandTotal(staff).toString(),
  //                               90,
  //                               isSubTotal: false,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }).toList(),

  //                   // Total column
  //                   if (totalRow != null)
  //                     Container(
  //                       width: 110,
  //                       decoration: BoxDecoration(
  //                         border: Border(
  //                           right: BorderSide(color: Colors.grey.shade100),
  //                         ),
  //                       ),
  //                       child: Column(
  //                         children: [
  //                           // Total header cell
  //                           Container(
  //                             height: 60,
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 8),
  //                             decoration: BoxDecoration(
  //                               gradient: LinearGradient(
  //                                 colors: [
  //                                   accentOrange.withOpacity(0.15),
  //                                   accentOrange.withOpacity(0.08)
  //                                 ],
  //                                 begin: Alignment.topCenter,
  //                                 end: Alignment.bottomCenter,
  //                               ),
  //                               border: Border(
  //                                 bottom:
  //                                     BorderSide(color: Colors.grey.shade200),
  //                               ),
  //                             ),
  //                             alignment: Alignment.center,
  //                             child: Row(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 Container(
  //                                   width: 24,
  //                                   height: 24,
  //                                   decoration: BoxDecoration(
  //                                     gradient: LinearGradient(
  //                                       colors: [
  //                                         accentOrange,
  //                                         Colors.orange.shade700
  //                                       ],
  //                                       begin: Alignment.topLeft,
  //                                       end: Alignment.bottomRight,
  //                                     ),
  //                                     shape: BoxShape.circle,
  //                                   ),
  //                                   child: const Center(
  //                                     child: Icon(Icons.auto_graph_rounded,
  //                                         color: Colors.white, size: 12),
  //                                   ),
  //                                 ),
  //                                 const SizedBox(width: 4),
  //                                 const Text(
  //                                   'TOTAL',
  //                                   style: TextStyle(
  //                                     fontSize: 9,
  //                                     fontWeight: FontWeight.w900,
  //                                     color: accentOrange,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           // Status total values
  //                           ...headers.asMap().entries.map((headerEntry) {
  //                             final headerIndex = headerEntry.key;
  //                             final header = headerEntry.value;
  //                             final color =
  //                                 _getReportItemColor(header, headerIndex);

  //                             final totalStatuses = _getStatuses(totalRow);
  //                             String value = '0';
  //                             if (headerIndex < totalStatuses.length) {
  //                               value =
  //                                   _getStatusValue(totalStatuses[headerIndex]);
  //                             }

  //                             return Container(
  //                               height: 55,
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 4),
  //                               decoration: BoxDecoration(
  //                                 color: appBarStart.withOpacity(0.08),
  //                                 border: Border(
  //                                   bottom:
  //                                       BorderSide(color: Colors.grey.shade50),
  //                                 ),
  //                               ),
  //                               alignment: Alignment.center,
  //                               child: _buildMatrixCountCell(
  //                                 value,
  //                                 color,
  //                                 90,
  //                                 isTotal: true,
  //                               ),
  //                             );
  //                           }).toList(),
  //                           // Grand total cell
  //                           Container(
  //                             height: 55,
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 4),
  //                             decoration: BoxDecoration(
  //                               color: appBarStart.withOpacity(0.1),
  //                               border: Border(
  //                                 top: BorderSide(
  //                                   color: appBarStart.withOpacity(0.2),
  //                                   width: 1.5,
  //                                 ),
  //                               ),
  //                             ),
  //                             alignment: Alignment.center,
  //                             child: _buildMatrixTotalCell(
  //                               _getGrandTotal(totalRow).toString(),
  //                               90,
  //                               isSubTotal: true,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildVerticalTableRedesign({
  //   required String title,
  //   required List<dynamic> data,
  //   required List<String> headers,
  //   required VoidCallback onFlip,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(24),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.06),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //       border: Border.all(color: Colors.grey.shade100),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(24),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             width: 140,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               border: Border(
  //                 right: BorderSide(color: Colors.grey.shade200, width: 1),
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: const Offset(4, 0),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               children: [
  //                 Container(
  //                   height: 60,
  //                   padding: const EdgeInsets.only(left: 16),
  //                   decoration: BoxDecoration(
  //                     color: appBarStart.withOpacity(0.08),
  //                     border: Border(
  //                         bottom: BorderSide(color: Colors.grey.shade200)),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       IconButton(
  //                         icon: const Icon(Icons.screen_rotation_rounded,
  //                             size: 18, color: appBarStart),
  //                         onPressed: onFlip,
  //                         padding: EdgeInsets.zero,
  //                         constraints: const BoxConstraints(),
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.share_rounded,
  //                             size: 18, color: appBarStart),
  //                         onPressed: () => _shareTableDataAsPdf(title, data),
  //                         padding: EdgeInsets.zero,
  //                         constraints: const BoxConstraints(),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 ...headers.map((h) => Container(
  //                       height: 55,
  //                       padding: const EdgeInsets.only(left: 16),
  //                       decoration: BoxDecoration(
  //                         border: Border(
  //                             bottom: BorderSide(color: Colors.grey.shade50)),
  //                       ),
  //                       alignment: Alignment.centerLeft,
  //                       child: Text(
  //                         h,
  //                         style: const TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w600,
  //                           color: textSecondary,
  //                         ),
  //                       ),
  //                     )),
  //                 Container(
  //                   height: 55,
  //                   padding: const EdgeInsets.only(left: 16),
  //                   decoration: BoxDecoration(
  //                     color: appBarStart.withOpacity(0.05),
  //                     border: Border(
  //                         top: BorderSide(
  //                             color: appBarStart.withOpacity(0.2), width: 1.5)),
  //                   ),
  //                   alignment: Alignment.centerLeft,
  //                   child: const Text(
  //                     'TOTAL',
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.bold,
  //                       color: appBarStart,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               physics: const BouncingScrollPhysics(),
  //               child: Row(
  //                 children: data.map((item) {
  //                   final String staffName = (item is csrt.CallStatusReportData)
  //                       ? item.staffName
  //                       : ((item is swrt.StagewiseReportData)
  //                           ? item.staffName
  //                           : ((item is lsrt.LeadSourceReportData)
  //                               ? item.staffName
  //                               : ((item is catrt.StaffCategoryData)
  //                                   ? item.staffName ?? 'N/A'
  //                                   : 'N/A')));

  //                   final int grandTotal = (item is csrt.CallStatusReportData)
  //                       ? item.totalCount
  //                       : ((item is swrt.StagewiseReportData)
  //                           ? item.totalCount
  //                           : ((item is lsrt.LeadSourceReportData)
  //                               ? item.totalCount
  //                               : ((item is catrt.StaffCategoryData)
  //                                   ? item.totalCount ?? 0
  //                                   : 0)));

  //                   final List<dynamic> statuses =
  //                       (item is csrt.CallStatusReportData)
  //                           ? item.statuses
  //                           : ((item is swrt.StagewiseReportData)
  //                               ? item.statuses
  //                               : ((item is lsrt.LeadSourceReportData)
  //                                   ? item.statuses
  //                                   : ((item is catrt.StaffCategoryData)
  //                                       ? item.statuses ?? []
  //                                       : [])));

  //                   final bool isGrandTotalRow =
  //                       staffName.toLowerCase() == 'total' ||
  //                           staffName.toLowerCase() == 'totals';

  //                   return Container(
  //                     width: 110,
  //                     decoration: BoxDecoration(
  //                       border: Border(
  //                           right: BorderSide(color: Colors.grey.shade100)),
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         Container(
  //                           height: 60,
  //                           padding: const EdgeInsets.symmetric(horizontal: 8),
  //                           decoration: BoxDecoration(
  //                             color: isGrandTotalRow
  //                                 ? appBarStart.withOpacity(0.12)
  //                                 : appBarStart.withOpacity(0.04),
  //                             border: Border(
  //                                 bottom:
  //                                     BorderSide(color: Colors.grey.shade200)),
  //                           ),
  //                           alignment: Alignment.center,
  //                           child: Text(
  //                             staffName,
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.bold,
  //                               color:
  //                                   isGrandTotalRow ? appBarStart : textPrimary,
  //                             ),
  //                           ),
  //                         ),
  //                         ...statuses.map((s) {
  //                           String val = "0";
  //                           String label = "";
  //                           if (s is csrt.CallStatus) {
  //                             val = s.total.toString();
  //                             label = s.callResponse;
  //                           } else if (s is swrt.StageStatus) {
  //                             val = s.total.toString();
  //                             label = s.callResult;
  //                           } else if (s is lsrt.LeadSourceStatus) {
  //                             val = s.total.toString();
  //                             label = s.leadSource;
  //                           } else if (s is catrt.CategoryStatus) {
  //                             val = s.total ?? '0';
  //                             label = s.leadCategory ?? '';
  //                           }

  //                           return Container(
  //                             height: 55,
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 4),
  //                             decoration: BoxDecoration(
  //                               border: Border(
  //                                   bottom:
  //                                       BorderSide(color: Colors.grey.shade50)),
  //                             ),
  //                             alignment: Alignment.center,
  //                             child: _buildMatrixCountCell(
  //                                 val,
  //                                 _getReportItemColor(
  //                                     label, statuses.indexOf(s)),
  //                                 90),
  //                           );
  //                         }),
  //                         Container(
  //                           height: 55,
  //                           padding: const EdgeInsets.symmetric(horizontal: 4),
  //                           decoration: BoxDecoration(
  //                             color: appBarStart.withOpacity(0.05),
  //                             border: Border(
  //                                 top: BorderSide(
  //                                     color: appBarStart.withOpacity(0.15),
  //                                     width: 1.5)),
  //                           ),
  //                           alignment: Alignment.center,
  //                           child: _buildMatrixTotalCell(
  //                               grandTotal.toString(), 90,
  //                               isSubTotal: isGrandTotalRow),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _fetchCloudCallReport() async {
    setState(() => isCloudCallLoading = true);
    try {
      final data = await HttpService.cloudCallReport(
        callStatusFromDate != null
            ? DateFormat('dd-MM-yyyy').format(callStatusFromDate!)
            : null,
        callStatusToDate != null
            ? DateFormat('dd-MM-yyyy').format(callStatusToDate!)
            : null,
        callStatusStaffs.join(','),
        null,
      );
      if (data != null && data.status == true) {
        setState(() {
          cloudCallReportData = data;
          cloudCallLastUpdated = DateTime.now();
        });
        _storeReportData(
          keyCloudCallReport,
          data,
          updatedKey: keyCloudCallLastUpdated,
        );
      }
    } catch (e) {
      log("Error fetching cloud call report: $e");
    } finally {
      if (mounted) setState(() => isCloudCallLoading = false);
    }
  }

  Future<void> _fetchPhoneCallReport() async {
    setState(() => isPhoneCallLoading = true);
    try {
      final data = await HttpService.phoneCallReport(
        callStatusFromDate != null
            ? DateFormat('dd-MM-yyyy').format(callStatusFromDate!)
            : null,
        callStatusToDate != null
            ? DateFormat('dd-MM-yyyy').format(callStatusToDate!)
            : null,
        callStatusStaffs.join(','),
        null,
      );
      if (data != null && data.status == true) {
        setState(() {
          phoneCallReportData = data;
          phoneCallLastUpdated = DateTime.now();
        });
        _storeReportData(
          keyPhoneCallReport,
          data,
          updatedKey: keyPhoneCallLastUpdated,
        );
      }
    } catch (e) {
      log("Error fetching phone call report: $e");
    } finally {
      if (mounted) setState(() => isPhoneCallLoading = false);
    }
  }

  Widget _buildCloudCallReport({bool isFlipped = false}) {
    if (isCloudCallLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (cloudCallReportData == null ||
        cloudCallReportData!.data == null ||
        cloudCallReportData!.data!.isEmpty) {
      return _buildEmptyReport();
    }
    String staffNames = "";
    if (callStatusStaffs.isNotEmpty && staffList.isNotEmpty) {
      staffNames = staffList
          .where((s) => callStatusStaffs.contains(s.userIdStaff.toString()))
          .map((s) => s.name)
          .join(", ");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildReportHeader(
          staffNames,
          cloudCallLastUpdated,
          fromDate: callStatusFromDate ?? DateTime.now(),
          toDate: callStatusToDate ?? DateTime.now(),
          onRefresh: _fetchCloudCallReport,
        ),
        showCloudCallTable
            ? _buildRealCallReportTable(
                "Cloud Call Report",
                cloudCallReportData!.data!,
                isFlipped,
              )
            : _buildCloudCallGraph(),
      ],
    );
  }

  Widget _buildPhoneCallReport({bool isFlipped = false}) {
    if (isPhoneCallLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (phoneCallReportData == null ||
        phoneCallReportData!.data == null ||
        phoneCallReportData!.data!.isEmpty) {
      return _buildEmptyReport();
    }
    String staffNames = "";
    if (callStatusStaffs.isNotEmpty && staffList.isNotEmpty) {
      staffNames = staffList
          .where((s) => callStatusStaffs.contains(s.userIdStaff.toString()))
          .map((s) => s.name)
          .join(", ");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildReportHeader(
          staffNames,
          phoneCallLastUpdated,
          fromDate: callStatusFromDate ?? DateTime.now(),
          toDate: callStatusToDate ?? DateTime.now(),
          onRefresh: _fetchPhoneCallReport,
        ),
        showPhoneCallTable
            ? _buildRealCallReportTable(
                "Phone Call Report",
                phoneCallReportData!.data!,
                isFlipped,
              )
            : _buildPhoneCallGraph(),
      ],
    );
  }

  Widget _buildRealCallReportTable(
    String title,
    List<dynamic> data,
    bool isFlipped,
  ) {
    bool isCloud = title.contains("Cloud");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            // Fixed left column with staff names
            Container(
              width: 154,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header for staff name column
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: appBarStart.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'STAFF NAME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: appBarStart.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Staff name rows
                  ...data.asMap().entries.map((entry) {
                    final item = entry.value;
                    return Container(
                      height: 55,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: entry.key % 2 == 0
                            ? Colors.white
                            : appBarStart.withOpacity(0.02),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade50),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: _buildMatrixStaffCell(
                        item.staffName ?? "-",
                        134,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewLeadsNew(
                                widget.token,
                                updateLeadPermission1,
                                deleteLeadPermission1,
                                cloudCallPermission1,
                                pageName: isCloud
                                    ? 'Cloud Calls: ${item.staffName}'
                                    : 'Phone Calls: ${item.staffName}',
                                fromDate: callStatusFromDate != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(callStatusFromDate!)
                                    : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                toDate: callStatusToDate != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(callStatusToDate!)
                                    : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(DateTime.now()),
                                staffId: item.userId?.toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header row
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: appBarStart.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          _buildMatrixHeaderCell(
                            'Total Calls',
                            Icons.call_rounded,
                            85,
                          ),
                          _buildMatrixHeaderCell(
                            'Connected',
                            Icons.phonelink_ring_rounded,
                            85,
                          ),
                          _buildMatrixHeaderCell(
                            'Duration',
                            Icons.timer_rounded,
                            85,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),

                    ...data.asMap().entries.map((entry) {
                      final item = entry.value;
                      return Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: entry.key % 2 == 0
                              ? Colors.transparent
                              : appBarStart.withOpacity(0.02),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            _buildMatrixCountCell(
                              item.totalCalls?.toString() ?? "0",
                              appBarStart,
                              90,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewLeadsNew(
                                      widget.token,
                                      updateLeadPermission1,
                                      deleteLeadPermission1,
                                      cloudCallPermission1,
                                      pageName: isCloud
                                          ? 'Cloud Calls: ${item.staffName}'
                                          : 'Phone Calls: ${item.staffName}',
                                      fromDate: callStatusFromDate != null
                                          ? DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(callStatusFromDate!)
                                          : DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(DateTime.now()),
                                      toDate: callStatusToDate != null
                                          ? DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(callStatusToDate!)
                                          : DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(DateTime.now()),
                                      staffId: item.userId?.toString(),
                                      isCalled: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildMatrixCountCell(
                              item.totalConnected?.toString() ?? "0",
                              callGreen,
                              90,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewLeadsNew(
                                      widget.token,
                                      updateLeadPermission1,
                                      deleteLeadPermission1,
                                      cloudCallPermission1,
                                      pageName: isCloud
                                          ? 'Connected (Cloud): ${item.staffName}'
                                          : 'Connected (Phone): ${item.staffName}',
                                      fromDate: callStatusFromDate != null
                                          ? DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(callStatusFromDate!)
                                          : DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(DateTime.now()),
                                      toDate: callStatusToDate != null
                                          ? DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(callStatusToDate!)
                                          : DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(DateTime.now()),
                                      staffId: item.userId?.toString(),
                                      isCalled: true,
                                      callStatus: 'Connected',
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildMatrixCountCell(
                              item.totalDuration?.toString() ?? "00:00:00",
                              accentOrange,
                              90,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudCallGraph() {
    return _buildRealCallGraph(
      cloudCallReportData?.data ?? [],
      "Cloud Call",
      (label, color) => _showCloudCallDrillDown(label, color),
    );
  }

  Widget _buildPhoneCallGraph() {
    return _buildRealCallGraph(
      phoneCallReportData?.data ?? [],
      "Phone Call",
      (label, color) => _showPhoneCallDrillDown(label, color),
    );
  }

  Widget _buildRealCallGraph(
    List<dynamic> data,
    String title,
    void Function(String, Color) onDrillDownTapped,
  ) {
    if (data.isEmpty) return _buildEmptyReport();

    int totalCallsOverall = 0;
    int connectedOverall = 0;

    for (var item in data) {
      totalCallsOverall +=
          int.tryParse(item.totalCalls?.toString() ?? "0") ?? 0;
      connectedOverall +=
          int.tryParse(item.totalConnected?.toString() ?? "0") ?? 0;
    }

    int notConnected = totalCallsOverall - connectedOverall;
    if (notConnected < 0) notConnected = 0;

    final results = [
      {'label': 'Connected', 'count': connectedOverall, 'color': callGreen},
      {'label': 'Not Connected', 'count': notConnected, 'color': appBarStart},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: appBarStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Total: $totalCallsOverall",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: appBarStart,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...results.map((res) {
            final double percentage = totalCallsOverall > 0
                ? (res['count'] as int) / totalCallsOverall
                : 0.0;
            final Color color = res['color'] as Color;
            return InkWell(
              onTap: () => onDrillDownTapped(res['label'] as String, color),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          res['label'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          "${res['count']}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showCloudCallDrillDown(String label, Color color) {
    if (cloudCallReportData?.data == null) return;
    final List<Map<String, dynamic>> details = cloudCallReportData!.data!.map((
      item,
    ) {
      int tot = int.tryParse(item.totalCalls?.toString() ?? "0") ?? 0;
      int con = int.tryParse(item.totalConnected?.toString() ?? "0") ?? 0;
      return {
        'name': item.staffName ?? "N/A",
        'count': label == 'Connected' ? con : (tot - con),
        'staffId': item.userId,
      };
    }).toList();

    _showReportDetailsDialog("Cloud Call: $label", details, color);
  }

  void _showPhoneCallDrillDown(String label, Color color) {
    if (phoneCallReportData?.data == null) return;
    final List<Map<String, dynamic>> details = phoneCallReportData!.data!.map((
      item,
    ) {
      int tot = int.tryParse(item.totalCalls?.toString() ?? "0") ?? 0;
      int con = int.tryParse(item.totalConnected?.toString() ?? "0") ?? 0;
      return {
        'name': item.staffName ?? "N/A",
        'count': label == 'Connected' ? con : (tot - con),
        'staffId': item.userId,
      };
    }).toList();

    _showReportDetailsDialog("Phone Call: $label", details, color);
  }

  double _getColWidth(String label) {
    if (label.isEmpty) return 60;
    double base = 35;
    double contentWidth = label.length * 6.5;
    return (base + contentWidth).clamp(65.0, 130.0);
  }

  Widget _buildMatrixHeaderCell(
    String label,
    IconData icon,
    double width, {
    Color? color,
  }) {
    final displayColor = color ?? appBarStart;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: displayColor),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: displayColor,
              fontSize: 8.5,
              letterSpacing: 0.2,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixStaffCell(
    String name,
    double width, {
    bool isTotal = false,
    int? total,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 55,
        alignment: Alignment.centerLeft,
        color: Colors.transparent,
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isTotal
                          ? [accentOrange, Colors.orange.shade700]
                          : [appBarStart, appBarStart.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isTotal ? accentOrange : appBarStart)
                            .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isTotal
                          ? 'T'
                          : (name.isNotEmpty ? name[0].toUpperCase() : '?'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (total != null && total > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        total.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isTotal ? 11 : 10,
                  fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                  color: isTotal ? appBarStart : textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixCountCell(
    String count,
    Color color,
    double width, {
    bool isTotal = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 55,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(isTotal ? 0.4 : 0.1),
              width: isTotal ? 1.5 : 0.5,
            ),
            boxShadow: isTotal
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              count,
              style: TextStyle(
                color: color,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
                fontSize: count.length > 2 ? 10 : 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixTotalCell(
    String count,
    double width, {
    bool isSubTotal = false,
  }) {
    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSubTotal ? 16 : 14,
            vertical: isSubTotal ? 10 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSubTotal
                  ? [accentOrange, Colors.orange.shade800]
                  : [appBarStart, primaryBlue.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isSubTotal ? Colors.orange : appBarStart).withOpacity(
                  0.25,
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return "Never";
    final now = DateTime.now();
    final dateStr = DateFormat('dd-MM-yyyy').format(lastUpdated);
    final todayStr = DateFormat('dd-MM-yyyy').format(now);
    final yesterdayStr = DateFormat(
      'dd-MM-yyyy',
    ).format(now.subtract(const Duration(days: 1)));

    String prefix = "";
    if (dateStr == todayStr) {
      prefix = "Today ";
    } else if (dateStr == yesterdayStr) {
      prefix = "Yesterday ";
    } else {
      prefix = "${DateFormat('dd MMM').format(lastUpdated)} ";
    }

    return "Updated $prefix${DateFormat('hh:mm a').format(lastUpdated)}";
  }

  String _getFormattedDateRange(DateTime? from, DateTime? to) {
    if (from == null && to == null) return "Showing all data";
    if (from == null || to == null) return "";
    final today = DateTime.now();
    final isToday = from.year == today.year &&
        from.month == today.month &&
        from.day == today.day &&
        to.year == today.year &&
        to.month == today.month &&
        to.day == today.day;
    if (isToday) return "Showing today's data";
    final isFullMonth = from.day == 1 &&
        to.day == DateTime(to.year, to.month + 1, 0).day &&
        from.month == to.month &&
        from.year == to.year;
    if (isFullMonth) {
      return "Showing ${DateFormat('MMMM').format(from)}'s data";
    }
    return "Showing data from ${DateFormat('dd MMM yyyy').format(from)} to ${DateFormat('dd MMM yyyy').format(to)}";
  }

  Widget _buildReportHeader(
    String staffNames,
    DateTime? lastUpdated, {
    DateTime? fromDate,
    DateTime? toDate,
    VoidCallback? onRefresh,
  }) {
    String dateRangeStr = _getFormattedDateRange(fromDate, toDate);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 0, left: 48),
        width: double.infinity,
        child: Transform.translate(
          offset: const Offset(0, -6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dateRangeStr.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: appBarStart.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateRangeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: appBarStart.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  if (lastUpdated != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 11,
                          color: textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatLastUpdated(lastUpdated),
                          style: TextStyle(
                            fontSize: 10,
                            color: textSecondary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  if (onRefresh != null) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onRefresh,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: appBarStart.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 13,
                          color: appBarStart,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (staffNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: appBarStart.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: appBarStart.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.people_rounded,
                            size: 12,
                            color: appBarStart,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            staffNames,
                            style: TextStyle(
                              fontSize: 10,
                              color: appBarStart.withOpacity(0.85),
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetailsDialog(
    String title,
    List<Map<String, dynamic>> details,
    Color primaryColor, {
    void Function(Map<String, dynamic>)? onStaffTap,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (details.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text(
                      "No data found",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final item = details[index];
                        return InkWell(
                          onTap: onStaffTap != null
                              ? () => onStaffTap(item)
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      child: Text(
                                        item['name'][0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item['count'].toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyReport({Color? bgColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: bgColor != null ? Colors.white24 : Colors.grey.shade300,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No report data available',
            style: TextStyle(
              color: bgColor != null ? Colors.white38 : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: primaryBlue.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(Icons.calendar_month, size: 14, color: primaryBlue),
              //       const SizedBox(width: 4),
              //       Text(
              //         'Period',
              //         style: TextStyle(
              //           fontSize: 10,
              //           fontWeight: FontWeight.bold,
              //           color: primaryBlue,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionChip(
                icon: Icons.person_add_rounded,
                label: 'Add Lead',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  if (createLeadPermission == 'true') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddLeadsNew(widget.token),
                      ),
                    ).then((_) => getData(widget.token, fromDate, toDate));
                  } else {
                    _showPermissionDialog();
                  }
                },
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                icon: Icons.search_rounded,
                label: 'Search',
                color: primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(
                        token: widget.token!,
                        editLead: updateLeadPermission1,
                        deleteLead: deleteLeadPermission1,
                        cloudCall: cloudCallPermission1,
                        leadType: '',
                      ),
                    ),
                  ).then((_) => getData(widget.token, fromDate, toDate));
                },
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                icon: Icons.history_rounded,
                label: 'Call History',
                color: const Color(0xFFFF9800),
                onTap: () {
                  if (accessCallHistoryPermission == 'true') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallHistoryPageTwo(
                          widget.token!,
                          name,
                          userId,
                          accessCallRecordingPermission1,
                        ),
                      ),
                    );
                  } else {
                    _showPermissionDialog();
                  }
                },
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // Container(
          //   padding: const EdgeInsets.all(4),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade50,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: Colors.grey.shade200),
          //   ),
          //   child: Row(
          //     children: [
          //       _buildCompactDateChip(
          //         label: DateFormat('dd MMM').format(fromDate),
          //         onTap: () => _showDatePicker(isFrom: true),
          //       ),
          //       Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 8),
          //         child: Icon(Icons.arrow_forward_rounded,
          //             size: 14, color: Colors.grey.shade400),
          //       ),
          //       _buildCompactDateChip(
          //         label: DateFormat('dd MMM').format(toDate),
          //         onTap: () => _showDatePicker(isFrom: false),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStaffSelectionModal() {
    staffSearchController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredStaff = staffList
                .where(
                  (s) => s.name.toLowerCase().contains(
                        staffSearchController.text.toLowerCase(),
                      ),
                )
                .toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Staff",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: staffSearchController,
                        onChanged: (val) {
                          setModalState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Search staff...",
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredStaff.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildStaffItem(
                            context,
                            id: "",
                            name: "All Staff",
                            isSelected:
                                targetStaffId == "" || targetStaffId == null,
                            onTap: () {
                              setState(() {
                                targetStaffId = "";
                              });
                              getData(
                                widget.token,
                                fromDate,
                                toDate,
                                isRefresh: true,
                              );
                              Navigator.pop(context);
                            },
                          );
                        }
                        final staff = filteredStaff[index - 1];
                        return _buildStaffItem(
                          context,
                          id: staff.userIdStaff.toString(),
                          name: staff.name,
                          isSelected:
                              targetStaffId == staff.userIdStaff.toString(),
                          onTap: () {
                            setState(() {
                              targetStaffId = staff.userIdStaff.toString();
                            });
                            getData(
                              widget.token,
                              fromDate,
                              toDate,
                              isRefresh: true,
                            );
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaffItem(
    BuildContext context, {
    required String? id,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? appBarStart.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? appBarStart.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [appBarStart, appBarStart.withOpacity(0.7)]
                        : [Colors.grey[300]!, Colors.grey[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? appBarStart : Colors.grey[800],
                      ),
                    ),
                    if (isSelected)
                      Text(
                        "Current Selection",
                        style: TextStyle(
                          fontSize: 11,
                          color: appBarStart.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: appBarStart, size: 24)
              else
                Icon(Icons.circle_outlined, color: Colors.grey[300], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _handleModuleNavigation(String? menuName) {
    if (menuName == null) return;

    if (menuName == 'call_management') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardLeadNewUpdatedTwo(widget.token),
        ),
      );
    } else if (menuName == 'Staff_management') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewUsers(widget.token)),
      );
    } else if (menuName == 'Service') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else if (menuName == 'whatsapp') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatHomeScreen()),
      );
    } else if (menuName == 'room_management') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RoomDashboard()),
      );
    } else if (menuName == 'Settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WhatsappSettings(widget.token)),
      );
    } else if (menuName == 'file_manager') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FileMangerList(widget.token)),
      );
    } else if (menuName == 'customers') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientList(widget.token!, _scaffoldKey),
        ),
      );
    } else if (menuName == 'invoices') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AccountsDashboard(token: widget.token.toString()),
        ),
      ).then((_) {
        getData(widget.token, fromDate, toDate);
        if (loadmore) getStaffwise();
      });
    } else if (menuName == 'quotation') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuotationDashboard()),
      ).then((_) {
        getData(widget.token, fromDate, toDate);
        if (loadmore) getStaffwise();
      });
    } else if (menuName == 'reports') {
      _showReportsDialog();
    } else if (menuName == 'renewal') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RenewalDashboard()),
      );
    } else if (menuName == 'Work') {
      if (adminCheckPermission == "true") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewCompanyWorkPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewWorkPage(staffId: ''),
            settings: RouteSettings(arguments: {"staffId": staffId}),
          ),
        );
      }
    } else if (menuName == 'complaints') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ComplaintListScreen()),
      );
    } else if (menuName == 'products') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductList(
            catId: "widget.catId",
            subCatId: "11",
            title: "",
            subCat: " widget.title",
          ),
        ),
      );
    } else {
      _showComingSoonDialog(menuName);
    }
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xFF2a86c9)),
              title: const Text('Lead Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllReport(
                      widget.token!,
                      true,
                      true,
                      true,
                      pageName: 'AllLeads',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF2a86c9)),
              title: const Text('Transfer Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferLeadReport(
                      widget.token!,
                      true,
                      true,
                      true,
                      pageName: 'transferLeads',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2a86c9)),
              title: const Text('Staff Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffReportDashboard(id: userId),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(feature),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToAppropriateDashboard,
      backgroundColor: primaryBlue,
      child: Image.asset(
        "assets/icons/menu.png",
        width: 24,
        color: Colors.white,
      ),
    );
  }

  void _navigateToAppropriateDashboard() {
    if (ProjectDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProjectDashboard()),
      );
    } else if (AccountsDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccountsDashboard(token: widget.token!),
        ),
      );
    } else if (MenuDashboard == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(widget.token)),
      );
    } else if (RenewalDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RenewalDashboard()),
      );
    } else if (NewleadDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MinimalDashboard(widget.token)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardLeadNewUpdatedTwo(widget.token),
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/no_network.json', height: 200),
          const SizedBox(height: 20),
          const Text(
            'Connection Error',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            timeOut
                ? 'Temporary issue. Please try again.'
                : 'No internet connection',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => getData(widget.token, fromDate, toDate),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Access Denied'),
        content: const Text(
          'You do not have permission to access this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowSection(ld.Data data) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: const Text(
                  'Lead Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  setState(() {
                    _isFlipSummaryView = !_isFlipSummaryView;
                  });
                  await Common.saveSharedPref(
                    "isFlipSummaryView",
                    _isFlipSummaryView.toString(),
                  );
                },
                child: const Icon(
                  Icons.flip_camera_android_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isFlipSummaryView
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8, bottom: 4),
                    child: Row(
                      children: [
                        _buildListSummaryItemOld(
                          'New',
                          dashboardMainCounts != null
                              ? (dashboardMainCounts?.data.leads.newLeads ?? 0)
                                  .toString()
                              : data.newLeads.toString(),
                          Icons.person_add_rounded,
                          _colors[1], // Standardized Blue
                          '1',
                          isCalled: true,
                        ),
                        _buildListSummaryItemOldAcive(
                          'Followup',
                          dashboardMainCounts != null
                              ? (dashboardMainCounts
                                          ?.data.leads.followupLeads ??
                                      0)
                                  .toString()
                              : data.followupLeads.toString(),
                          Icons.schedule_rounded,
                          _colors[2],
                          '2',
                          isCalled: false,
                        ),
                        _buildListSummaryItemOld(
                          'Missed',
                          dashboardMainCounts != null
                              ? (dashboardMainCounts?.data.leads.missedLeads ??
                                      0)
                                  .toString()
                              : data.missedLeads.toString(),
                          Icons.event_busy_rounded,
                          _colors[5],
                          '0',
                          leadType: '1',
                          callStatus: '-1',
                          isCalled: true,
                          graphId: '-3',
                        ),
                        _buildListSummaryItemOld(
                          'Called',
                          dashboardMainCounts != null
                              ? (dashboardMainCounts?.data.leads.calledCount ??
                                      0)
                                  .toString()
                              : data.totalCalled.toString(),
                          Icons.phone_in_talk_rounded,
                          _colors[6],
                          '0',
                          leadType: '-1',
                          callStatus: '1',
                          isCalled: true,
                          graphId: '-1',
                        ),
                        _buildListSummaryItemOld(
                          'Transferred',
                          dashboardMainCounts != null
                              ? (dashboardMainCounts
                                          ?.data.leads.transferLeads ??
                                      0)
                                  .toString()
                              : data.transferLeads.toString(),
                          Icons.swap_horiz_rounded,
                          _colors[8],
                          '0',
                          leadType: '2',
                          callStatus: '-2',
                          isCalled: true,
                        ),
                        _buildListSummaryItemOld(
                          'Closed',
                          dashboardMainCounts != null
                              ? (dashboardMainCounts?.data.leads.closedLeads ??
                                      0)
                                  .toString()
                              : '0',
                          Icons.check_circle_outline_rounded,
                          _colors[4],
                          '4',
                          isCalled: false,
                          graphId: '4',
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildListSummaryItem(
                            'New',
                            dashboardMainCounts != null
                                ? (dashboardMainCounts?.data.leads.newLeads ??
                                        0)
                                    .toString()
                                : data.newLeads.toString(),
                            Icons.person_add_rounded,
                            _colors[1],
                            '1',
                            isCalled: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildListSummaryItemActive(
                            'Followup',
                            dashboardMainCounts != null
                                ? (dashboardMainCounts
                                            ?.data.leads.followupLeads ??
                                        0)
                                    .toString()
                                : data.followupLeads.toString(),
                            Icons.schedule_rounded,
                            _colors[2],
                            '2',
                            isCalled: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildListSummaryItem(
                            'Missed',
                            dashboardMainCounts != null
                                ? (dashboardMainCounts
                                            ?.data.leads.missedLeads ??
                                        0)
                                    .toString()
                                : data.missedLeads.toString(),
                            Icons.event_busy_rounded,
                            _colors[5],
                            '0',
                            leadType: '1',
                            callStatus: '-1',
                            isCalled: true,
                            graphId: '-3',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildListSummaryItem(
                            'Called',
                            dashboardMainCounts != null
                                ? (dashboardMainCounts
                                            ?.data.leads.calledCount ??
                                        0)
                                    .toString()
                                : data.totalCalled.toString(),
                            Icons.phone_in_talk_rounded,
                            _colors[6],
                            '0',
                            leadType: '-1',
                            callStatus: '1',
                            isCalled: true,
                            graphId: '-1',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildListSummaryItem(
                            'Transferred',
                            dashboardMainCounts != null
                                ? (dashboardMainCounts
                                            ?.data.leads.transferLeads ??
                                        0)
                                    .toString()
                                : data.transferLeads.toString(),
                            Icons.swap_horiz_rounded,
                            _colors[8], // Teal for Transferred
                            '0',
                            leadType: '2',
                            callStatus: '-2',
                            isCalled: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildListSummaryItem(
                            'Closed',
                            dashboardCounts != null
                                ? (dashboardCounts?.data?.leads?.closedLeads ??
                                        0)
                                    .toString()
                                : '0',
                            Icons.check_circle_outline_rounded,
                            _colors[4], // Standardized Green for Closed
                            '4',
                            isCalled: false,
                            graphId: '4',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildListSummaryItemOldAcive(
    String label,
    String count,
    IconData icon,
    Color color,
    String status, {
    String? leadType,
    String? callStatus,
    bool? isCalled,
    String? graphId,
  }) {
    bool isSelected = _listTabFilter == label;

    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              bool labelChanged = _listTabFilter != label;
              setState(() {
                _listTabFilter = label;
                if (labelChanged) {
                  _clearListTabFilters();
                }
                _listTabCurrentStatus = status;
                _listTabCurrentLeadType = leadType ?? "";
                _listTabCurrentCallStatus = callStatus ?? "";
                _listTabCurrentIsCalled = isCalled;
              });
              if (_isGraphViewActive) {
                _fetchProgressBarLeads(label);
              } else {
                _fetchTabLeadsActive(
                  status: status,
                  leadType: leadType ?? "",
                  callStatus: callStatus ?? "",
                  isCalled: isCalled,
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.4) : borderLight,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 12,
                        color: isSelected ? color : textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          count,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () async {
                Common.showProgressDialog(context, "Loading Analytics..");
                Common.saveSharedPref("statusWise", 'no');
                String effectiveGraphStatus = graphId ??
                    ((status == '0' && callStatus != null)
                        ? callStatus
                        : status);
                label == "New"
                    ? await getLeadProgressbarNew(
                        widget.token!,
                        fromDate,
                        toDate,
                        effectiveGraphStatus,
                      )
                    : label == "Followup"
                        ? await getLeadProgressbarFollowup(
                            widget.token!,
                            fromDate,
                            toDate,
                            effectiveGraphStatus,
                          )
                        : label == "Missed"
                            ? await getLeadProgressbarMissed(
                                widget.token!,
                                fromDate,
                                toDate,
                                effectiveGraphStatus,
                              )
                            : label == "Called"
                                ? await getLeadProgressbarCalled(
                                    widget.token!,
                                    fromDate,
                                    toDate,
                                    effectiveGraphStatus,
                                  )
                                : label == "Transferred"
                                    ? await getLeadProgressbarTransferred(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      )
                                    : await getLeadProgressbar(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      );

                if (object1!.status == true) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    leadProgressbarDialog(
                      context,
                      label,
                      "\$label Leads",
                      status,
                      leadType ?? "",
                      callStatus: callStatus,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSummaryItemOld(
    String label,
    String count,
    IconData icon,
    Color color,
    String status, {
    String? leadType,
    String? callStatus,
    bool? isCalled,
    String? graphId,
  }) {
    bool isSelected = _listTabFilter == label;

    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              bool labelChanged = _listTabFilter != label;
              setState(() {
                _listTabFilter = label;
                if (labelChanged) {
                  _clearListTabFilters();
                }
                _listTabCurrentStatus = status;
                _listTabCurrentLeadType = leadType ?? "";
                _listTabCurrentCallStatus = callStatus ?? "";
                _listTabCurrentIsCalled = isCalled;
              });
              if (_isGraphViewActive) {
                _fetchProgressBarLeads(label);
              } else {
                _fetchTabLeads(
                  status: status,
                  leadType: leadType ?? "",
                  callStatus: callStatus ?? "",
                  isCalled: isCalled,
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.4) : borderLight,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 12,
                        color: isSelected ? color : textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          count,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () async {
                Common.showProgressDialog(context, "Loading Analytics..");
                Common.saveSharedPref("statusWise", 'no');
                String effectiveGraphStatus = graphId ??
                    ((status == '0' && callStatus != null)
                        ? callStatus
                        : status);
                label == "New"
                    ? await getLeadProgressbarNew(
                        widget.token!,
                        fromDate,
                        toDate,
                        effectiveGraphStatus,
                      )
                    : label == "Followup"
                        ? await getLeadProgressbarFollowup(
                            widget.token!,
                            fromDate,
                            toDate,
                            effectiveGraphStatus,
                          )
                        : label == "Missed"
                            ? await getLeadProgressbarMissed(
                                widget.token!,
                                fromDate,
                                toDate,
                                effectiveGraphStatus,
                              )
                            : label == "Called"
                                ? await getLeadProgressbarCalled(
                                    widget.token!,
                                    fromDate,
                                    toDate,
                                    effectiveGraphStatus,
                                  )
                                : label == "Transferred"
                                    ? await getLeadProgressbarTransferred(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      )
                                    : await getLeadProgressbar(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      );

                if (object1!.status == true) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    leadProgressbarDialog(
                      context,
                      label,
                      "\$label Leads",
                      status,
                      leadType ?? "",
                      callStatus: callStatus,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSummaryItem(
    String label,
    String count,
    IconData icon,
    Color color,
    String status, {
    String? leadType,
    String? callStatus,
    bool? isCalled,
    String? graphId,
  }) {
    bool isSelected = _listTabFilter == label;

    return SizedBox(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: InkWell(
              onTap: () {
                bool labelChanged = _listTabFilter != label;
                setState(() {
                  _listTabFilter = label;
                  if (label == 'Closed') {
                    fromDate = DateTime.now();
                    toDate = DateTime.now();
                  }
                  if (labelChanged) {
                    _clearListTabFilters();
                  }
                  _listTabCurrentStatus = status;
                  _listTabCurrentLeadType = leadType ?? "";
                  _listTabCurrentCallStatus = callStatus ?? "";
                  _listTabCurrentIsCalled = isCalled;
                });
                if (_isGraphViewActive) {
                  _fetchProgressBarLeads(label);
                } else {
                  _fetchTabLeads(
                    status: status,
                    leadType: leadType ?? "",
                    callStatus: callStatus ?? "",
                    isCalled: isCalled,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [color.withOpacity(0.25), color.withOpacity(0.1)]
                        : [color.withOpacity(0.15), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color.withOpacity(0.5)
                        : color.withOpacity(0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 0),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? color : textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                Common.showProgressDialog(context, "Loading Analytics..");
                Common.saveSharedPref("statusWise", 'no');
                String effectiveGraphStatus = graphId ??
                    ((status == '0' && callStatus != null)
                        ? callStatus
                        : status);
                label == "New"
                    ? await getLeadProgressbarNew(
                        widget.token!,
                        fromDate,
                        toDate,
                        effectiveGraphStatus,
                      )
                    : label == "Followup"
                        ? await getLeadProgressbarFollowup(
                            widget.token!,
                            fromDate,
                            toDate,
                            effectiveGraphStatus,
                          )
                        : label == "Missed"
                            ? await getLeadProgressbarMissed(
                                widget.token!,
                                fromDate,
                                toDate,
                                effectiveGraphStatus,
                              )
                            : label == "Called"
                                ? await getLeadProgressbarCalled(
                                    widget.token!,
                                    fromDate,
                                    toDate,
                                    effectiveGraphStatus,
                                  )
                                : label == "Transferred"
                                    ? await getLeadProgressbarTransferred(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      )
                                    : await getLeadProgressbar(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      );

                if (object1!.status == true) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    leadProgressbarDialog(
                      context,
                      label,
                      "$label Leads",
                      status,
                      leadType ?? "",
                      callStatus: callStatus,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSummaryItemActive(
    String label,
    String count,
    IconData icon,
    Color color,
    String status, {
    String? leadType,
    String? callStatus,
    bool? isCalled,
    String? graphId,
  }) {
    bool isSelected = _listTabFilter == label;

    return SizedBox(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: InkWell(
              onTap: () {
                bool labelChanged = _listTabFilter != label;
                setState(() {
                  _listTabFilter = label;
                  if (label == 'Closed') {
                    fromDate = DateTime.now();
                    toDate = DateTime.now();
                  }
                  if (labelChanged) {
                    _clearListTabFilters();
                  }
                  _listTabCurrentStatus = status;
                  _listTabCurrentLeadType = leadType ?? "";
                  _listTabCurrentCallStatus = callStatus ?? "";
                  _listTabCurrentIsCalled = isCalled;
                });
                if (_isGraphViewActive) {
                  _fetchProgressBarLeads(label);
                } else {
                  _fetchTabLeadsActive(
                    status: status,
                    leadType: leadType ?? "",
                    callStatus: callStatus ?? "",
                    isCalled: isCalled,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [color.withOpacity(0.25), color.withOpacity(0.1)]
                        : [color.withOpacity(0.15), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color.withOpacity(0.5)
                        : color.withOpacity(0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 0),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? color : textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                Common.showProgressDialog(context, "Loading Analytics..");
                Common.saveSharedPref("statusWise", 'no');
                String effectiveGraphStatus = graphId ??
                    ((status == '0' && callStatus != null)
                        ? callStatus
                        : status);
                label == "New"
                    ? await getLeadProgressbarNew(
                        widget.token!,
                        fromDate,
                        toDate,
                        effectiveGraphStatus,
                      )
                    : label == "Followup"
                        ? await getLeadProgressbarFollowup(
                            widget.token!,
                            fromDate,
                            toDate,
                            effectiveGraphStatus,
                          )
                        : label == "Missed"
                            ? await getLeadProgressbarMissed(
                                widget.token!,
                                fromDate,
                                toDate,
                                effectiveGraphStatus,
                              )
                            : label == "Called"
                                ? await getLeadProgressbarCalled(
                                    widget.token!,
                                    fromDate,
                                    toDate,
                                    effectiveGraphStatus,
                                  )
                                : label == "Transferred"
                                    ? await getLeadProgressbarTransferred(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      )
                                    : await getLeadProgressbar(
                                        widget.token!,
                                        fromDate,
                                        toDate,
                                        effectiveGraphStatus,
                                      );

                if (object1!.status == true) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    leadProgressbarDialogActive(
                      context,
                      label,
                      "$label Leads",
                      status,
                      leadType ?? "",
                      callStatus: callStatus,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Object?> leadProgressBarStaffDialog(
    BuildContext context,
    String title,
    String status, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff-wise $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Staff-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.groups_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    staffProgressData?.data?.staffTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (staffProgressData?.data?.staffLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Staff Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${staffProgressData!.data!.staffLeads!.length} Staffs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: staffProgressData!.data!.staffLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final staff = staffProgressData!.data!.staffLeads![i];
                          double total = double.tryParse(
                                staffProgressData?.data?.staffTotal
                                        ?.toString() ??
                                    "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(staff.staffCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  staffName: staff.staffName,
                                  staffId: staff.staffId,
                                  title: title,
                                  status: status,
                                  from: customFrom,
                                  to: customTo,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (staff.staffName?.isNotEmpty ==
                                                      true)
                                                  ? staff.staffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff.staffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Contribution Progress",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              staff.staffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressBarStaffDialogActive(
    BuildContext context,
    String title,
    String status, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff-wise $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Staff-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.groups_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    staffProgressData?.data?.staffTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (staffProgressData?.data?.staffLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Staff Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${staffProgressData!.data!.staffLeads!.length} Staffs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: staffProgressData!.data!.staffLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final staff = staffProgressData!.data!.staffLeads![i];
                          double total = double.tryParse(
                                staffProgressData?.data?.staffTotal
                                        ?.toString() ??
                                    "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(staff.staffCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeadsActiveActive(
                                  context: context,
                                  staffName: staff.staffName,
                                  staffId: staff.staffId,
                                  title: title,
                                  status: status,
                                  from: customFrom,
                                  to: customTo,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (staff.staffName?.isNotEmpty ==
                                                      true)
                                                  ? staff.staffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff.staffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Contribution Progress",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              staff.staffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressBarCategoryDialogActive(
    BuildContext context,
    String title,
    String status, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category-wise $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Category-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.pie_chart_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    categoryProgressData?.data?.categoryTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (categoryProgressData?.data?.categoryLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${categoryProgressData!.data!.categoryLeads!.length} Categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            categoryProgressData!.data!.categoryLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final cat =
                              categoryProgressData!.data!.categoryLeads![i];
                          double total = double.tryParse(
                                categoryProgressData?.data?.categoryTotal
                                        ?.toString() ??
                                    "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(cat.categoryCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeadsActiveActive(
                                  context: context,
                                  categoryName: cat.categoryName,
                                  categoryId: cat.categoryId,
                                  title: title,
                                  status: status,
                                  from: customFrom,
                                  to: customTo,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (cat.categoryName?.isNotEmpty ==
                                                      true)
                                                  ? cat.categoryName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.categoryName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Category Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              cat.categoryCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressBarCategoryDialog(
    BuildContext context,
    String title,
    String status, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category-wise $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Category-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.pie_chart_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    categoryProgressData?.data?.categoryTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (categoryProgressData?.data?.categoryLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${categoryProgressData!.data!.categoryLeads!.length} Categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            categoryProgressData!.data!.categoryLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final cat =
                              categoryProgressData!.data!.categoryLeads![i];
                          double total = double.tryParse(
                                categoryProgressData?.data?.categoryTotal
                                        ?.toString() ??
                                    "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(cat.categoryCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  categoryName: cat.categoryName,
                                  categoryId: cat.categoryId,
                                  title: title,
                                  status: status,
                                  from: customFrom,
                                  to: customTo,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (cat.categoryName?.isNotEmpty ==
                                                      true)
                                                  ? cat.categoryName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.categoryName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Category Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              cat.categoryCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressBarStatusDialogActive(
    BuildContext context,
    String title,
    String status, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stage Wise $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Stage-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.analytics_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    statusProgressData?.data?.statusTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (statusProgressData?.data?.statusLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stage Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${statusProgressData!.data!.statusLeads!.length} Stages',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            statusProgressData!.data!.statusLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final st = statusProgressData!.data!.statusLeads![i];
                          double total = double.tryParse(
                                statusProgressData?.data?.statusTotal
                                        ?.toString() ??
                                    "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(st.statusCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getReportItemColor(st.statusName, i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeadsActiveActive(
                                  context: context,
                                  title: title,
                                  status: "",
                                  type: st.statusId,
                                  from: customFrom,
                                  to: customTo,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (st.statusName?.isNotEmpty ==
                                                      true)
                                                  ? st.statusName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                st.statusName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Stage Progression",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              st.statusCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressBarStatusDialog(
    BuildContext context,
    String title,
    String status, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stage Wise $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Stage-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.analytics_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    statusProgressData?.data?.statusTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (statusProgressData?.data?.statusLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stage Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${statusProgressData!.data!.statusLeads!.length} Stages',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            statusProgressData!.data!.statusLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final st = statusProgressData!.data!.statusLeads![i];
                          double total = double.tryParse(
                                statusProgressData?.data?.statusTotal
                                        ?.toString() ??
                                    "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(st.statusCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getReportItemColor(st.statusName, i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  title: title,
                                  status: status,
                                  type: st.statusId,
                                  from: customFrom,
                                  to: customTo,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (st.statusName?.isNotEmpty ==
                                                      true)
                                                  ? st.statusName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                st.statusName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Stage Progression",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              st.statusCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressbarDialog(
    BuildContext context,
    String label,
    String title,
    String status,
    String type, {
    String? callStatus,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Detailed analytics and distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.trending_up_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Generated $label',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    object1?.data?.totalCount?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (object1?.data?.staffLeads?.isNotEmpty ?? false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Staff Contribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.staffLeads!.length} Agents',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.staffLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final staff = object1!.data!.staffLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(staff.staffCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  staffName: staff.staffName,
                                  staffId: staff.staffId,
                                  title: title ?? 'Leads',
                                  status: status ?? '0',
                                  type: type ?? '',
                                  callStatus: callStatus,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (staff.staffName?.isNotEmpty ==
                                                      true)
                                                  ? staff.staffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff.staffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Active Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              staff.staffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.categoryLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.categoryLeads!.length} Categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.categoryLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final cat = object1!.data!.categoryLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(cat.categoryCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 3);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  categoryName: cat.categoryName,
                                  categoryId: cat.categoryId,
                                  title: title,
                                  status: status,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (cat.categoryName?.isNotEmpty ==
                                                      true)
                                                  ? cat.categoryName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.categoryName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Category Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              cat.categoryCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.missedLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Missed Leads Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.missedLeads!.length} Staffs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.missedLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final missed = object1!.data!.missedLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(missed.missedstaffCount ?? "0") ??
                                  0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 5);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  staffName: missed.missedstaffName,
                                  staffId: missed.missedstaffId,
                                  title: title,
                                  status: status,
                                  type: type,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (missed.missedstaffName
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? missed.missedstaffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                missed.missedstaffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Staff Missed Leads",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              missed.missedstaffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.statusLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.statusLeads!.length} Stages',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.statusLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final statusLead = object1!.data!.statusLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(statusLead.statusCount ?? "0") ??
                                  0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 7);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  status: statusLead.statusId,
                                  title: title,
                                  type: type,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (statusLead.statusName
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? statusLead.statusName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                statusLead.statusName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Status Progress",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              statusLead.statusCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressbarDialogActive(
    BuildContext context,
    String label,
    String title,
    String status,
    String type, {
    String? callStatus,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Detailed analytics and distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.trending_up_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Generated $label',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    object1?.data?.totalCount?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (object1?.data?.staffLeads?.isNotEmpty ?? false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Staff Contribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.staffLeads!.length} Agents',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.staffLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final staff = object1!.data!.staffLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(staff.staffCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () async {
                                // Navigator.pop(context);

                                await _navigateToFilteredLeadsActive(
                                  context: context,
                                  staffName: staff.staffName,
                                  staffId: staff.staffId,
                                  title: title,
                                  status: status,
                                  type: type,
                                  callStatus: callStatus,
                                  isGlobalContext: true,
                                  isFollowup: "1",
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (staff.staffName?.isNotEmpty ==
                                                      true)
                                                  ? staff.staffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff.staffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Active Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              staff.staffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.categoryLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.categoryLeads!.length} Categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.categoryLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final cat = object1!.data!.categoryLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(cat.categoryCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 3);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  categoryName: cat.categoryName,
                                  categoryId: cat.categoryId,
                                  title: title,
                                  status: status,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (cat.categoryName?.isNotEmpty ==
                                                      true)
                                                  ? cat.categoryName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.categoryName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Category Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              cat.categoryCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.missedLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Missed Leads Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.missedLeads!.length} Staffs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.missedLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final missed = object1!.data!.missedLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(missed.missedstaffCount ?? "0") ??
                                  0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 5);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  staffName: missed.missedstaffName,
                                  staffId: missed.missedstaffId,
                                  title: title,
                                  status: status,
                                  type: type,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (missed.missedstaffName
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? missed.missedstaffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                missed.missedstaffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Staff Missed Leads",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              missed.missedstaffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.statusLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.statusLeads!.length} Stages',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.statusLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final statusLead = object1!.data!.statusLeads![i];
                          double total = double.tryParse(
                                object1?.data?.totalCount?.toString() ?? "0",
                              ) ??
                              0;
                          double count =
                              double.tryParse(statusLead.statusCount ?? "0") ??
                                  0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 7);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToFilteredLeads(
                                  context: context,
                                  status: statusLead.statusId,
                                  title: title,
                                  type: type,
                                  isGlobalContext: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (statusLead.statusName
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? statusLead.statusName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                statusLead.statusName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Status Progress",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              statusLead.statusCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStaffColor(dynamic key) {
    if (key is int) return _colors[key % _colors.length];
    if (key is String) {
      return _colors[key.length % _colors.length];
    }
    return Colors.blue;
  }

  Color _getListTabBackgroundColor() {
    switch (_listTabFilter) {
      case 'New':
        return _colors[1].withOpacity(0.08);
      case 'Followup':
        return _colors[2].withOpacity(0.08);
      case 'Missed':
        return _colors[5].withOpacity(0.08);
      case 'Called':
        return _colors[6].withOpacity(0.08);
      case 'Transferred':
        return _colors[8].withOpacity(0.08);
      case 'Closed':
        return _colors[4].withOpacity(0.08);
      default:
        return backgroundLight;
    }
  }

  Color _getListTabPrimaryColor() {
    switch (_listTabFilter) {
      case 'New':
        return _colors[1];
      case 'Followup':
        return _colors[2];
      case 'Missed':
        return _colors[5];
      case 'Called':
        return _colors[6];
      case 'Transferred':
        return _colors[8];
      case 'Closed':
        return _colors[4];
      default:
        return textPrimary;
    }
  }

  Widget _buildListShimmer() {
    return Container(
      color: _getListTabBackgroundColor(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCalendar() {
    return GestureDetector(
      onTap: () => _showTargetDateRangePicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: appBarStart.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined, color: appBarStart, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showTargetDateRangePicker() async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Select Target Period"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today, color: appBarStart),
                title: const Text("From Date"),
                subtitle: Text(DateFormat('dd-MM-yyyy').format(targetFromDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetFromDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => targetFromDate = picked);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.event, color: appBarStart),
                title: const Text("To Date"),
                subtitle: Text(DateFormat('dd-MM-yyyy').format(targetToDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetToDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => targetToDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
                _refreshTargetCounts();
              },
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshTargetCounts() async {
    setState(() => isDashboardCountsLoading = true);
    try {
      final fDate = DateFormat('dd-MM-yyyy').format(fromDate);
      final tDate = DateFormat('dd-MM-yyyy').format(toDate);
      final targetFDate = DateFormat('dd-MM-yyyy').format(targetFromDate);
      final targetTDate = DateFormat('dd-MM-yyyy').format(targetToDate);
      final countsData = await HttpService.dashboardLeadsCounts(
        fromDate: fDate,
        toDate: tDate,
        userId: targetStaffId ?? userId,
        targetFromDate: targetFDate,
        targetToDate: targetTDate,
      );

      if (countsData != null && countsData.status == true) {
        setState(() {
          dashboardCounts = countsData;
        });
      }
    } catch (e) {
      log("Error fetching dashboard counts: $e");
    } finally {
      setState(() => isDashboardCountsLoading = false);
    }
  }

  void _handleLongPress(int index) {
    setState(() {
      final lead = listTabLeads[index];
      lead.isSelected = !lead.isSelected;
      if (lead.isSelected) {
        selectedIUsers.add(lead.callMasterId);
        selectedUserNumbers.add(lead.contactNumber1);
      } else {
        selectedIUsers.remove(lead.callMasterId);
        selectedUserNumbers.remove(lead.contactNumber1);
      }
    });
  }

  void _nuclearReset() {
    setState(() {
      selectedIUsers.clear();
      selectedUserNumbers.clear();
      transferStaffToggleName = "Staff";
      transferStaffToggleId = "";
      for (var item in listTabLeads) {
        item.isSelected = false;
      }
    });
    if (_listTabFilter == "Followup") {
      _fetchTabLeadsActive();
    } else {
      _fetchTabLeads();
    }
  }

  Future<dynamic> _transferLeads(BuildContext context) {
    int transferFresh = 0;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: appBarStart.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.swap_horiz_rounded,
                            color: appBarStart,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transfer Leads',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              'Select target staff to assign',
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

                    // Label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "ASSIGN TO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Selector
                    InkWell(
                      onTap: () async {
                        await _collectedStaffDialog(context);
                        setDialogState(() {});
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color: appBarStart.withOpacity(0.8),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                transferStaffToggleName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.unfold_more_rounded,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                            horizontal: 14,
                            vertical: 12,
                          ),
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
                                    duration: const Duration(milliseconds: 200),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
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
                                if (transferStaffToggleId.isEmpty) {
                                  Common.toastMessaage(
                                    "Please select a staff",
                                    accentRed,
                                  );
                                  return;
                                }

                                Common.showProgressDialog(
                                  context,
                                  "Transferring leads...",
                                );

                                try {
                                  Map<String, dynamic> body = {
                                    "token": widget.token,
                                    'leadMasterIds': selectedIUsers,
                                    'staffId': transferStaffToggleId,
                                    'transfer_fresh': transferFresh,
                                  };

                                  BulkTransferLeadModel bulkTransfer =
                                      await HttpService.bulkTransferLead(body);

                                  if (bulkTransfer.status == true) {
                                    Common.toastMessaage(
                                      bulkTransfer.message,
                                      callGreen,
                                    );

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      _nuclearReset();
                                    }
                                  } else {
                                    Common.toastMessaage(
                                      bulkTransfer.message,
                                      accentRed,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Common.toastMessaage(
                                      "Transfer failed: $e",
                                      accentRed,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appBarStart,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<dynamic> _collectedStaffDialog(BuildContext context) {
    if (commonDetails == null) return Future.value();
    filteredTransferStaff = List.from(commonDetails!.data.transferStaffs);

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autocorrect: false,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          filteredTransferStaff =
                              commonDetails!.data.transferStaffs
                                  .where(
                                    (item) => item.tranStaffName
                                        .toLowerCase()
                                        .contains(value.toLowerCase()),
                                  )
                                  .toList();
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8),
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .3,
                    width: MediaQuery.of(context).size.width * .7,
                    child: ListView.builder(
                      itemCount: filteredTransferStaff.length,
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          onTap: () {
                            transferStaffToggleName =
                                filteredTransferStaff[index].tranStaffName;
                            transferStaffToggleId =
                                filteredTransferStaff[index].tranStaffId;
                            filteredTransferStaff.clear();
                            filteredTransferStaff.addAll(
                              commonDetails!.data.transferStaffs,
                            );
                            this.setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(
                            filteredTransferStaff[index].tranStaffName,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    filteredTransferStaff.clear();
                    filteredTransferStaff.addAll(
                      commonDetails!.data.transferStaffs,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showStatusDateRangePickerDialog(String statusType) async {
    DateTime currentFrom =
        statusType == 'Closed' ? fromDateClosed : fromDateLost;
    DateTime currentTo = statusType == 'Closed' ? toDateClosed : toDateLost;
    String status = statusType == 'Closed' ? '4' : '3';
    String pageName = statusType == 'Closed' ? 'Closed Leads' : 'Lost Leads';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Gradient
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [appBarStart, appBarStart.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          statusType == 'Closed'
                              ? Icons.check_circle_outline_rounded
                              : Icons.do_not_disturb_on_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$statusType Leads",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "Filters & Analytics",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TIME PERIOD",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogDateButton(
                              label: "From",
                              date: currentFrom,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: currentFrom,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setDialogState(() => currentFrom = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDialogDateButton(
                              label: "To",
                              date: currentTo,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: currentTo,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setDialogState(() => currentTo = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        "ANALYTICS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDialogAnalyticsButton(
                        icon: Icons.people_rounded,
                        title: "Staff Wise Breakdown",
                        subtitle: "View agent performance for this period",
                        color: Colors.blue.shade600,
                        onTap: () {
                          Navigator.pop(context);
                          _handleStaffIconTap(
                            status,
                            pageName,
                            customFromDate: currentFrom,
                            customToDate: currentTo,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDialogAnalyticsButton(
                        icon: Icons.category_rounded,
                        title: "Category Insights",
                        subtitle: "See which lead categories are converting",
                        color: Colors.purple.shade600,
                        onTap: () {
                          Navigator.pop(context);
                          _handleCategoryIconTap(
                            status,
                            pageName,
                            customFromDate: currentFrom,
                            customToDate: currentTo,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        if (statusType == 'Closed') {
                          fromDateClosed = currentFrom;
                          toDateClosed = currentTo;
                          isClosedDateFiltered = true;
                        } else {
                          fromDateLost = currentFrom;
                          toDateLost = currentTo;
                          isLostDateFiltered = true;
                        }
                      });
                      _fetchStatusLeadCount(statusType);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBarStart,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: appBarStart.withOpacity(0.4),
                    ),
                    child: const Text(
                      "Apply Filter",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: appBarStart),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM').format(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogAnalyticsButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchStatusLeadCount(String statusType) async {
    final status = statusType == 'Closed' ? '4' : '3';
    final from = statusType == 'Closed' ? fromDateClosed : fromDateLost;
    final to = statusType == 'Closed' ? toDateClosed : toDateLost;

    final response = await HttpService.dashboardLeadsCounts(
      fromDate: DateFormat('dd-MM-yyyy').format(from),
      toDate: DateFormat('dd-MM-yyyy').format(to),
      userId: targetStaffId ?? userId,
      status: status,
    );

    if (response != null && response.status == true) {
      setState(() {
        if (statusType == 'Closed') {
          closedCount = (response.data?.leads?.closedLeads ?? 0).toString();
        } else {
          lostCount = (response.data?.leads?.rejectedLeads ?? 0).toString();
        }
      });
    }
  }

  void _handleStaffIconTap(
    String status,
    String pageName, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    Common.showProgressDialog(context, "Loading Staff Analytics..");
    await getLeadProgressBarStaffData(
      leadStatus: status,
      selectedType: "1",
      customFromDate: customFromDate,
      customToDate: customToDate,
    );
    if (staffProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarStaffDialog(
          context,
          pageName,
          status,
          customFrom: customFromDate,
          customTo: customToDate,
        );
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _handleCategoryIconTap(
    String status,
    String pageName, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    Common.showProgressDialog(context, "Loading Category Analytics..");
    await getLeadProgressBarCategoryData(
      leadStatus: status,
      customFromDate: customFromDate,
      customToDate: customToDate,
    );
    if (categoryProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarCategoryDialog(
          context,
          pageName,
          status,
          customFrom: customFromDate,
          customTo: customToDate,
        );
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _handleStageIconTap(
    String status,
    String pageName, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    Common.showProgressDialog(context, "Loading Stage Analytics..");
    await getLeadProgressBarStatusData(
      leadStatus: status,
      customFromDate: customFromDate,
      customToDate: customToDate,
    );
    if (statusProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarStatusDialog(
          context,
          pageName,
          status,
          customFrom: customFromDate,
          customTo: customToDate,
        );
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _handleStageIconTapActive(
    String status,
    String pageName, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    Common.showProgressDialog(context, "Loading Stage Analytics..");
    await getLeadProgressBarStatusData(
      leadStatus: status,
      customFromDate: customFromDate,
      customToDate: customToDate,
    );
    if (statusProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarStatusDialogActive(
          context,
          pageName,
          status,
          customFrom: customFromDate,
          customTo: customToDate,
        );
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _handleCategoryIconTapActive(
    String status,
    String pageName, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    Common.showProgressDialog(context, "Loading Category Analytics..");
    await getLeadProgressBarCategoryData(
      leadStatus: status,
      customFromDate: customFromDate,
      customToDate: customToDate,
    );
    if (categoryProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarCategoryDialogActive(
          context,
          pageName,
          status,
          customFrom: customFromDate,
          customTo: customToDate,
        );
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  // void _handleStaffIconTapActive(String status, String pageName) async {
  //   Common.showProgressDialog(context, "Loading Stage Analytics..");
  //   await getLeadProgressBarStatusData(
  //     leadStatus: status,
  //   );
  //   if (statusProgressData?.status == true) {
  //     if (context.mounted) {
  //       Navigator.pop(context);
  //       leadProgressBarStatusDialogActive(context, "$pageName", status);
  //     }
  //   } else {
  //     if (context.mounted) Navigator.pop(context);
  //   }
  // }

  void _handleStaffIconTapActive(
    String status,
    String pageName, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    Common.showProgressDialog(context, "Loading Staff Analytics..");
    await getLeadProgressBarStaffData(
      leadStatus: status,
      selectedType: "1",
      customFromDate: customFromDate,
      customToDate: customToDate,
    );
    if (staffProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarStaffDialogActive(
          context,
          pageName,
          status,
          customFrom: customFromDate,
          customTo: customToDate,
        );
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _buildBoxIcons(
    String boxType,
    String status,
    String pageName, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) {
    if (boxType == 'Closed' || boxType == 'Lost') {
      final isClosed = boxType == 'Closed';
      final todayVal = isClosed
          ? (dashboardCounts?.data?.leads?.todaysClosed ?? 0)
          : (dashboardCounts?.data?.leads?.todaysLost ?? 0);
      final monthVal = isClosed
          ? (dashboardCounts?.data?.leads?.thisMonthClosed ?? 0)
          : (dashboardCounts?.data?.leads?.thisMonthLost ?? 0);

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  final now = DateTime.now();
                  final dateStr = DateFormat('yyyy-MM-dd').format(now);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewLeadsNew(
                        widget.token,
                        updateLeadPermission1,
                        deleteLeadPermission1,
                        cloudCallPermission1,
                        pageName:
                            isClosed ? 'Today\'s Closed' : 'Today\'s Lost',
                        fromDate: dateStr,
                        toDate: dateStr,
                        status: isClosed ? '4' : '3',
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      "Today's",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$todayVal",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 24, color: Colors.white54),
            Expanded(
              child: InkWell(
                onTap: () {
                  final now = DateTime.now();
                  final firstDay = DateTime(now.year, now.month, 1);
                  final lastDay = DateTime(now.year, now.month + 1, 0);
                  final fromStr = DateFormat('yyyy-MM-dd').format(firstDay);
                  final toStr = DateFormat('yyyy-MM-dd').format(lastDay);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewLeadsNew(
                        widget.token,
                        updateLeadPermission1,
                        deleteLeadPermission1,
                        cloudCallPermission1,
                        pageName:
                            isClosed ? 'This Month Closed' : 'This Month Lost',
                        fromDate: fromStr,
                        toDate: toStr,
                        status: isClosed ? '4' : '3',
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      "This month",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$monthVal",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (boxType != 'Active' && boxType != 'Closed' && boxType != 'Lost')
            _buildBoxActionIcon(
              icon: Icons.people_outline,
              onTap: () => _handleStaffIconTap(
                status,
                pageName,
                customFromDate: customFromDate,
                customToDate: customToDate,
              ),
            ),
          if (boxType != 'Active' && boxType != 'Closed' && boxType != 'Lost')
            _buildBoxActionIcon(
              icon: Icons.category_outlined,
              onTap: () => _handleCategoryIconTap(
                status,
                pageName,
                customFromDate: customFromDate,
                customToDate: customToDate,
              ),
            ),

          /////////////////////// Activveeeee boxxxxxxxxxxxxxx
          if (boxType == 'Active')
            _buildBoxActionIcon(
              icon: Icons.people_outline,
              onTap: () => _handleStaffIconTapActive(
                status,
                pageName,
                customFromDate: customFromDate,
                customToDate: customToDate,
              ),
            ),
          if (boxType == 'Active')
            _buildBoxActionIcon(
              icon: Icons.category_outlined,
              onTap: () => _handleCategoryIconTapActive(
                status,
                pageName,
                customFromDate: customFromDate,
                customToDate: customToDate,
              ),
            ),
          if (boxType == 'Active')
            _buildBoxActionIcon(
              icon: Icons.assignment_outlined,
              onTap: () => _handleStageIconTapActive(
                status,
                pageName,
                customFromDate: customFromDate,
                customToDate: customToDate,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoxActionIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // Widget _buildEmptyReport() {
  //   return Container(
  //     padding: const EdgeInsets.all(40),
  //     alignment: Alignment.center,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(Icons.insert_chart_outlined,
  //             size: 48, color: Colors.grey.shade300),
  //         const SizedBox(height: 16),
  //         Text(
  //           "No data available",
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.grey.shade400,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _getStaffName(dynamic item) {
    if (item is csrt.CallStatusReportData) return item.staffName;
    if (item is swrt.StagewiseReportData) return item.staffName;
    if (item is lsrt.LeadSourceReportData) return item.staffName;
    if (item is catrt.StaffCategoryData) return item.staffName ?? 'N/A';
    return 'N/A';
  }

  String? _getUserId(dynamic item) {
    if (item is csrt.CallStatusReportData) return item.userId;
    if (item is swrt.StagewiseReportData) return item.userId;
    if (item is lsrt.LeadSourceReportData) return item.userId;
    if (item is catrt.StaffCategoryData) return item.userId;
    return null;
  }

  List<dynamic> _getStatuses(dynamic item) {
    if (item is csrt.CallStatusReportData) return item.statuses;
    if (item is swrt.StagewiseReportData) return item.statuses;
    if (item is lsrt.LeadSourceReportData) return item.statuses;
    if (item is catrt.StaffCategoryData) return item.statuses ?? [];
    return [];
  }

  String _getStatusValue(dynamic status) {
    if (status is csrt.CallStatus) return status.total.toString();
    if (status is swrt.StageStatus) return status.total.toString();
    if (status is lsrt.LeadSourceStatus) return status.total.toString();
    if (status is catrt.CategoryStatus) return status.total ?? '0';
    return '0';
  }

  String _getStatusLabel(dynamic status) {
    if (status is csrt.CallStatus) return status.callResponse;
    if (status is swrt.StageStatus) return status.callResult;
    if (status is lsrt.LeadSourceStatus) return status.leadSource;
    if (status is catrt.CategoryStatus) return status.leadCategory ?? '';
    return '';
  }

  String? _getStatusId(dynamic status) {
    if (status is csrt.CallStatus) return status.callResponseId;
    if (status is swrt.StageStatus) return status.callResultId;
    if (status is lsrt.LeadSourceStatus) return status.leadSourceId;
    if (status is catrt.CategoryStatus) {
      return status.leadCategoryId?.toString();
    }
    return null;
  }

  int _getGrandTotal(dynamic item) {
    if (item is csrt.CallStatusReportData) return item.totalCount;
    if (item is swrt.StagewiseReportData) return item.totalCount;
    if (item is lsrt.LeadSourceReportData) return item.totalCount;
    if (item is catrt.StaffCategoryData) return item.totalCount ?? 0;
    return 0;
  }

  // Widget _buildMatrixCountCell(String count, Color color, double width,
  //     {bool isTotal = false, VoidCallback? onTap}) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Container(
  //       width: width,
  //       height: 55,
  //       alignment: Alignment.center,
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //         decoration: BoxDecoration(
  //           color: isTotal ? color.withOpacity(0.15) : Colors.transparent,
  //           borderRadius: BorderRadius.circular(8),
  //           border: isTotal ? Border.all(color: color.withOpacity(0.3)) : null,
  //         ),
  //         child: Text(
  //           count,
  //           style: TextStyle(
  //             fontSize: 13,
  //             fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
  //             color: isTotal ? color : textPrimary,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMatrixTotalCell(String total, double width,
  //     {bool isSubTotal = false}) {
  //   return Container(
  //     width: width,
  //     height: 55,
  //     alignment: Alignment.center,
  //     child: Text(
  //       total,
  //       style: TextStyle(
  //         fontSize: 14,
  //         fontWeight: FontWeight.w900,
  //         color: isSubTotal ? appBarStart : textPrimary,
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    staffSearchController.dispose();
    super.dispose();
  }

  Color _getReportItemColor(String? name, int index) {
    if (name == null) return _colors[index % _colors.length];
    String n = name.toLowerCase();

    // Standardized mapping for status names and IDs
    if (n == 'new' || n == '1') return _colors[1];
    if (n == 'followup' || n == '2' || n == '3') return _colors[2];
    if (n == 'closed' || n == '4' || n == '7') {
      return _colors[4]; // Standard Green for Closed/Success
    }
    if (n == 'rejected' || n == 'lost' || n == '0' || n.contains('missed')) {
      return _colors[5]; // Standard Red for Rejected/Missed
    }
    if (n == 'called' || n == '6') return _colors[6];
    if (n == 'transferred') return _colors[8]; // Teal

    // Fallback logic for specific phrases
    if (n.contains("new")) return _colors[1];
    if (n.contains("followup") || n.contains("follow up")) {
      return _colors[2];
    }
    if (n.contains("rejected")) return _colors[5];
    if (n.contains("completed")) return _colors[4];
    if (n.contains("pending")) return _colors[6];
    if (n.contains("not responding")) return _colors[5];

    return _colors[index % _colors.length];
  }
}
