// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/BulkTransferLeadModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/bulkDeleteLeadModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../bottom_navigation_bar.dart';
import '../../service/service.dart';
import '../../models/lead_management/leadFollowupAdd.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/leadDetailsModelAdd.dart';
import '../../models/lead_management/listFolderName.dart';
import '../../models/lead_management/leadMileStoneListModel.dart';
import '../../models/lead_management/districtModel.dart';
import '../../models/lead_management/stateModel.dart';
import '../../models/lead_management/fileManagerPermissionModel.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../models/clients/postalCodeModel.dart';
import '../../models/expense/expense_post.dart';
import 'lead_details_popup.dart';
import '../../widgets/viewLeadsFilterWidget.dart';
import '../../models/lead_management/leadProductsModel.dart';
import '../../models/lead_management/showTransferHideorShowModel.dart';

// ignore: must_be_immutable
class ViewLeadsNew extends StatefulWidget {
  final String? token;
  final bool editLead;
  final bool deleteLead;
  final bool cloudCall;
  final String? fromDate;
  final String? toDate;
  final String? staffId;
  final String? status;
  final String? category;
  final String? staff;
  final String? categoryName;
  final String? staffName;
  final String? pageName;
  final bool? isCalled;
  final int? scrollToIndex;
  final int? page;
  final int? pageSize;
  final String? leadType;
  final String? callStatus;
  final String? callResId;
  final String? callResName;
  final DateTime? preservedFromDate;
  final DateTime? preservedToDate;
  final String? preservedSortOrder;
  final bool? preservedSortAscending;
  final List<String>? preservedCategoryItems;
  final List<String>? preservedPriorityItems;
  final List<String>? preservedAssignedStaffItems;
  final List<String>? preservedResponseItems;
  final List<StateList>? stateDetails;
  final String? leadSourceId;
  final String? isCallStatus;
  final String? isActiveReport;
  final String? isLeadSource;
  final String? isLeadCategory;
  final String? isAllLeads;
  final String? notificationLeadId;
  final String? isFollowup;

  const ViewLeadsNew(
    this.token,
    this.editLead,
    this.deleteLead,
    this.cloudCall, {
    super.key,
    this.fromDate,
    this.toDate,
    this.staffId,
    this.status,
    this.category,
    this.staff,
    this.pageName,
    this.isCalled,
    this.scrollToIndex,
    this.page,
    this.pageSize,
    this.leadType,
    this.categoryName,
    this.staffName,
    this.callStatus,
    this.callResId,
    this.callResName,
    this.preservedFromDate,
    this.preservedToDate,
    this.preservedSortOrder,
    this.preservedSortAscending,
    this.preservedCategoryItems,
    this.preservedPriorityItems,
    this.preservedAssignedStaffItems,
    this.preservedResponseItems,
    this.stateDetails,
    this.leadSourceId,
    this.isCallStatus,
    this.isActiveReport,
    this.isLeadSource,
    this.isLeadCategory,
    this.isAllLeads,
    this.notificationLeadId,
    this.isFollowup,
  });

  @override
  State<ViewLeadsNew> createState() => _ViewLeadsNewState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewLeadsNew &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          pageName == other.pageName;

  @override
  int get hashCode => Object.hash(token, pageName);
}

class _ViewLeadsNewState extends State<ViewLeadsNew>
    with AutomaticKeepAliveClientMixin {
  static const Color appBarStart = Color(0xFF2a86c9);
  static const Color appBarEnd = Color(0xFF406dbe);
  static const Color callGreen = Color(0xFF4CAF50);
  static const Color followupBlue = Color(0xFF2196F3);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFF44336);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color borderLight = Color(0xFFECF0F1);
  static const Color backgroundLight = Color.fromARGB(255, 247, 249, 252);

  ViewLeadsModel? viewLeads;
  AddLeadCommonDataModel? commonDetails;
  LeadSubTypeModel? leadSubTypeList;
  CommonConfigureModel? configure;
  LeadDeatailsModel? leadDetails;
  LeadDeatailsModelAdd? leadDetailsAdditional;
  StateModel? stateDetails;
  LeadMileStoneListModel? mileStone;
  ListFolderNameModel? listFolder;
  FileManagerPermissionModel? fileManagerPermission;
  PostalCodeModel? postalCodeModel;
  LeadProductSectionModel? productSectionModel;
  DateTime? fromdateUpdated;
  DateTime? todateUpdated;
  bool isDateFilteredUpdated = false;
  // State variables
  String searchText = '';
  bool? result = true;
  bool? result1 = true;
  DateTime? fromdate;
  DateTime? todate;
  String currentSortOrder = 'desc';
  bool sortAscending = false;
  final outputFormat = DateFormat('yyyy-MM-dd');
  dynamic status;
  dynamic staff;
  dynamic priority;
  bool? isCalled = true;
  List<String> selectedIUsers = [];
  List<String> selectedUserNumbers = [];
  bool searchField = false;
  String callMasterId = "";
  String whatsappNo = '';
  String whatsappNo1 = '';
  bool _isSelectAll = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Detail> _filteredItems = [];
  final TextEditingController contactFName = TextEditingController();
  final TextEditingController contactLName = TextEditingController();
  final TextEditingController contactMobile = TextEditingController();
  final TextEditingController stateVal = TextEditingController();
  final TextEditingController pinCode = TextEditingController();
  final TextEditingController districtVal = TextEditingController();
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  bool isDistrictLoading = false;
  bool _isLoading = false;
  bool isFilterApplied = false;
  bool isDateFiltered = false;
  bool _isCompactView = false;
  final Set<String> _expandedLeadIds = {};
  String? StateId;
  String? DistrictId;
  List<String> selectedTagIds = [];
  String? selectedDateType;
  int _lastVisibleIndex = 0;
  final List<Color> _colors = [
    const Color(0xFF2196F3), // Vibrant Blue (index 0)
    const Color(0xFF2196F3), // Blue at index 1 for "New"
    const Color(0xFFFFC107), // Amber/Yellow for Followup (index 2)
    const Color.fromARGB(
        255, 255, 7, 7), // Amber/Yellow at index 3 for Followup
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

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<Detail> items = [];
  int page = 1;
  int pageSize = 10;
  bool isLoading = false;
  bool isInitialLoad = true;
  bool timeOut = false;
  List<String> checkedResponseItems = [];
  List<String> checkedresponseItemsName = [];
  List<String> checkedCategoryItems = [];
  List<String> checkedCategoryItemsName = [];
  List<String> checkedPriorityItems = [];
  List<String> checkedPriorityItemsName = [];
  List<String> checkedAssignedStaffItems = [];
  List<String> checkedAssignedStaffItemsName = [];
  List<String> checkedProductItems = [];
  List<String> checkedProductItemsName = [];
  List<String> checkedSubCategoryItems = [];
  List<String> checkedSubCategoryItemsName = [];
  List<String> checkedClassItems = [];
  List<String> checkedStreamItems = [];
  List<String> checkedSyllabusItems = [];
  List<String> checkedSchoolDistrictItems = [];
  List<String> checkedAbroadItems = [];
  List<String> checkedSchoolItems = [];
  List<TransferStaff> filteredStaff = [];
  String staffId = "";
  String staffName = "Staff";
  bool showTransferFreshValue = false;
  bool hasMore = true;

  String name = '';
  String viewLeadCategoryOnly = '';
  String viewAllCategory = '';
  String userId = '';
  String statusWise = '';
  String statusWiseId = '';
  String statusCatId = '';
  String type = '';
  String? branch;
  String roleId = '';
  String multiBranch = '';
  String transferPermission = '';
  String phoneCallLogPermission = '';

  // Data management
  CommonResponse? loginOrNot;
  bool _isDataLoaded = false;
  String? _currentCacheKey;
  final Map<String, List<dynamic>> _categorySubcategories = {};
  final Set<String> _loadedLeadIds = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
    initListner();
    loadStates();
    if (widget.notificationLeadId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openLeadDetailsByMasterId(widget.notificationLeadId!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    contactFName.dispose();
    contactLName.dispose();
    contactMobile.dispose();
    stateVal.dispose();
    pinCode.dispose();
    districtVal.dispose();
    super.dispose();
  }

  void _initializeData() {
    isDateFiltered = (widget.fromDate != null && widget.fromDate != "") ||
        (widget.toDate != null && widget.toDate != "");
    isFilterApplied = isDateFiltered;
    fromdate = widget.preservedFromDate ??
        ((widget.fromDate != null && widget.fromDate!.isNotEmpty)
            ? DateTime.parse(widget.fromDate!)
            : null);

    todate = widget.preservedToDate ??
        ((widget.toDate != null && widget.toDate!.isNotEmpty)
            ? DateTime.parse(widget.toDate!)
            : null);

    print('From Date: $fromdate');
    print('To Date: $todate');
    currentSortOrder = widget.preservedSortOrder ?? 'desc';
    sortAscending = widget.preservedSortAscending ?? false;
    _initializeFilterItems();

    if (widget.page != null) page = widget.page!;
    if (widget.pageSize != null) pageSize = widget.pageSize!;

    status = widget.status == "0" ? null : widget.status;
    staff = widget.staff;
    _handlePageSpecificLogic();
    _isDataLoaded = false;
    _searchController.addListener(_onSearchChanged);

    getData(currentSortOrder, true, status);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _filterItems();
    });
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(items);
    } else {
      _filteredItems = items.where((item) {
        final name = item.clientName?.toLowerCase() ?? '';
        final phone = item.contactNumber1?.toLowerCase() ?? '';
        final staffName = item.staffName?.toLowerCase() ?? '';
        final category = item.leadCategory?.toLowerCase() ?? '';

        return name.contains(_searchQuery) ||
            phone.contains(_searchQuery) ||
            staffName.contains(_searchQuery) ||
            category.contains(_searchQuery);
      }).toList();
    }
  }

  void _showCallInitiatedMessage() {
    Common.toastMessaage("Call initiated", callGreen);
  }

  void _initializeFilterItems() {
    if (widget.preservedCategoryItems != null) {
      checkedCategoryItems = List.from(widget.preservedCategoryItems!);
    }
    if (widget.preservedPriorityItems != null) {
      checkedPriorityItems = List.from(widget.preservedPriorityItems!);
    }
    if (widget.preservedAssignedStaffItems != null) {
      checkedAssignedStaffItems =
          List.from(widget.preservedAssignedStaffItems!);
    }
    if (widget.preservedResponseItems != null) {
      checkedResponseItems = List.from(widget.preservedResponseItems!);
    }
    if (widget.staff != null) {
      checkedAssignedStaffItems.add(widget.staff!);
      checkedAssignedStaffItemsName.add(widget.staffName ?? '');
    }
    if (widget.category != null) {
      checkedCategoryItems.add(widget.category!);
      checkedCategoryItemsName.add(widget.categoryName ?? '');
    }
    if (widget.callResId != null) {
      checkedResponseItems.add(widget.callResId!);
      checkedresponseItemsName.add(widget.callResName ?? '');
    }
  }

  void _handlePageSpecificLogic() {
    if (widget.pageName == "Followup Leads") {
      isCalled = false;
      fromdate =
          widget.fromDate != null ? DateTime.parse(widget.fromDate!) : null;
    } else if (widget.pageName == "Closed Leads" ||
        widget.pageName == "Total Called" ||
        widget.pageName == "Rejected Leads") {
      fromdate =
          widget.fromDate != null ? DateTime.parse(widget.fromDate!) : null;
      todate = widget.toDate != null ? DateTime.parse(widget.toDate!) : null;
    }
  }

  String _generateCacheKey() {
    return '${fromdate?.toIso8601String()}_${todate?.toIso8601String()}_$status'
        '_${checkedCategoryItems.join()}_${checkedSubCategoryItems.join()}'
        '_${checkedResponseItems.join()}_${checkedAssignedStaffItems.join()}'
        '_${checkedPriorityItems.join()}_$currentSortOrder'
        '_${branch ?? ""}_${StateId ?? ""}_${DistrictId ?? ""}_${widget.pageName}';
  }

  Future<void> loadStates() async {
    if (stateDetails == null) {
      var result = await HttpService.getState();
      log("States loaded: ${result?.data.length}");
      setState(() {
        stateDetails = result;
      });
    }
  }

  void initListner() {
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isEmpty || isLoading || !hasMore) return;

      final lastIndex = positions.last.index;
      if (lastIndex >= items.length - 3) {
        getData(currentSortOrder, false, status);
      }
    });
  }

  List<Detail> _getUniqueItems(
      List<Detail> newItems, List<Detail> existingItems) {
    final existingIds = existingItems.map((item) => item.callMasterId).toSet();
    return newItems
        .where((newItem) => !existingIds.contains(newItem.callMasterId))
        .toList();
  }

  Future<void> getData(String sort, bool isFirst, dynamic status1,{String search = ''}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final currentPage = page;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet)) {
        setState(() {
          result = true;
        });
      } else {
        setState(() {
          result = false;
          isLoading = false;
        });
        return;
      }

      await _loadUserPreferences();

      ViewLeadsModel? apiResponse;
      if (statusWise == 'yes') {
        apiResponse = await HttpService.viewLeadsSts(
            widget.token,
            fromdate != null ? DateFormat('dd-MM-yyyy').format(fromdate!) : "",
            todate != null ? DateFormat('dd-MM-yyyy').format(todate!) : "",
            type,
            statusCatId,
            statusWiseId,
            sort,
            currentPage,
            pageSize,
            isFirst,
            branch,
            search
            );
      } else {
        Map<String, dynamic> body =
            _buildRequestBody(status1, sort, currentPage, isFirst);
        log("API Request Body: $body");
        // apiResponse = await HttpService.viewLeads(body);
        if (widget.isCallStatus == "1") {
          apiResponse = await HttpService.leadReportCallStatus(body);
        } else if (widget.isFollowup == "1") {
          apiResponse = await HttpService.viewLeadsforActive(body);
        } else if (widget.isActiveReport == "1") {
          apiResponse = await HttpService.leadReportActiveStatus(body);
        } else if (widget.isLeadSource == "1") {
          apiResponse = await HttpService.leadReportLeadSource(body);
        } else if (widget.isLeadCategory == "1") {
          apiResponse = await HttpService.leadReportLeadCategory(body);
        } else if (widget.isAllLeads == "1") {
          apiResponse = await HttpService.leadReportAll(body);
        } else {
          apiResponse = await HttpService.leadReport(body);
        }
      }

      if (apiResponse != null) {
        await _processApiResponse(apiResponse, currentPage, isFirst);
      }
    } catch (e) {
      log("Error loading data: $e");
      setState(() {
        isLoading = false;
        timeOut = true;
        _isDataLoaded = false;
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    statusWise = await Common.getSharedPref("statusWise") ?? "";
    roleId = await Common.getSharedPref("roleId") ?? "";
    multiBranch = await Common.getSharedPref("multiBranch") ?? "";
    transferPermission = await Common.getSharedPref("transferLeads") ?? "";
    userId = await Common.getSharedPref("userId") ?? "";
    name = await Common.getSharedPref("name") ?? "";
    viewLeadCategoryOnly =
        await Common.getSharedPref("viewLeadCategoryOnly") ?? '';
    viewAllCategory = await Common.getSharedPref("viewAllCategory") ?? '';
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission") ?? "";

    HttpService.showTransferHideOrShow().then((value) {
      if (value != null && value.status == true) {
        setState(() {
          showTransferFreshValue = value.data ?? false;
        });
      }
    });

    if (statusWise == 'yes') {
      statusWiseId = await Common.getSharedPref("statusWisId") ?? "";
      statusCatId = await Common.getSharedPref("statusCatId") ?? "";
      type = await Common.getSharedPref("type") ?? "";
    }

    if (commonDetails == null) {
      commonDetails = await HttpService.addLeadCommonData(widget.token);
      if (commonDetails != null) {
        filteredStaff.addAll(commonDetails!.data.transferStaffs);
      }
    }

    if (configure == null) {
      configure = await HttpService.configure(widget.token);
    }

    if (productSectionModel == null) {
      productSectionModel = await HttpService.leadProductSection();
    }
  }

  Map<String, dynamic> _buildRequestBody(
      dynamic status1, String sort, int currentPage, bool isFirst) {
    Map<String, dynamic> body = {
      "token": widget.token,
      "callResultId": status1 ?? "",
      "leadCategoryId": checkedCategoryItems,
      "leadSubcategoryId": checkedSubCategoryItems,
      "callResponseId": checkedResponseItems,
      "staffId": (checkedAssignedStaffItems.isNotEmpty)
          ? checkedAssignedStaffItems
          : (widget.staffId != null && widget.staffId!.isNotEmpty)
              ? [widget.staffId!]
              : [],
      "isCalled": isCalled,
      "priority": checkedPriorityItems,
      "sort": sort,
      "page": currentPage,
      "pageSize": pageSize,
      "isFirst": isFirst,
      "leadType": widget.leadType ?? "",
      "state": StateId ?? "",
      "district": DistrictId ?? "",
      "branchId": branch ?? "",
      "tagIds": selectedTagIds ?? "",
      "leadSourceId": widget.leadSourceId ?? "",
      "productId": checkedProductItems,
      "selectedType": selectedDateType,
      "class_id": checkedClassItems,
      "stream": checkedStreamItems,
      "syllabus": checkedSyllabusItems,
      "school_district_id": checkedSchoolDistrictItems,
      "abroad": checkedAbroadItems,
      "school_name": checkedSchoolItems,
      "search": searchText,
    };

    bool shouldSendDates = isFilterApplied ||
        isDateFiltered ||
        (widget.fromDate != null && widget.fromDate != "") ||
        (widget.toDate != null && widget.toDate != "") ||
        widget.leadType == "-1" ||
        (status1 != null && (status1 == "4" || status1 == "0")) ||
        (widget.callResId != null);
    body["filterStatus"] = shouldSendDates ? 1 : 0;
    body["fromDate"] = shouldSendDates && fromdate != null
        ? outputFormat.format(fromdate!)
        : "";
    body["toDate"] =
        shouldSendDates && todate != null ? outputFormat.format(todate!) : "";

    return body;
  }

  Future<void> _processApiResponse(
      ViewLeadsModel apiResponse, int currentPage, bool isFirst) async {
    final newItems = apiResponse.data.details;
    final totalLeads = apiResponse.data.totalLeads;

    hasMore = items.length + newItems.length < totalLeads;
    final itemsToAdd = _getUniqueItems(newItems, items);

    setState(() {
      if (isFirst) {
        _loadedLeadIds.clear();
        items.clear();
        items.addAll(itemsToAdd);
        for (var item in itemsToAdd) {
          _loadedLeadIds.add(item.callMasterId);
        }
        page = 2;
      } else {
        items.addAll(itemsToAdd);
        page = currentPage + 1;
      }
      viewLeads = apiResponse;
      isLoading = false;
      _isDataLoaded = true;
      isInitialLoad = false;
      _filterItems();
    });
  }

  Future<StateList?> selectStateDialog(BuildContext context) async {
    return showDialog<StateList>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select State"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: stateDetails?.data.length ?? 0,
              itemBuilder: (context, index) {
                final stateItem = stateDetails!.data[index];
                return ListTile(
                  title: Text(stateItem.name),
                  onTap: () {
                    Navigator.pop(context, stateItem);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> loadPostOffices(String pin) async {
    PostalCodeModel postalCodeModel = await HttpService.fetchPostOffice(pin);
    setState(() {
      postOffices = postalCodeModel.postOffice ?? [];
      if (postOffices.isNotEmpty) {
        selectedPostOffice = postOffices.first;
      }
    });
  }

  Future<void> listFolderList(
      String token, String callMasterId, String path) async {
    if (listFolder == null) {
      listFolder =
          await HttpService.listFolderAndFiles(token, callMasterId, path);
      if (listFolder != null) {
        fileManagerPermissionFunction(token);
        setState(() {});
      }
    }
  }

  Future<void> fileManagerPermissionFunction(String token) async {
    if (fileManagerPermission == null) {
      fileManagerPermission = await HttpService.fileManagerPermission(token);
      setState(() {});
    }
  }

  Future<void> listMileStone(String token, String callMasterId) async {
    if (mileStone == null) {
      mileStone = await HttpService.leadMileStone(token, callMasterId);
      setState(() {});
    }
  }

  Future<void> listAddonDet(String token, String callMasterId) async {
    if (leadDetailsAdditional == null) {
      leadDetailsAdditional =
          await HttpService.listAddonDet(token, callMasterId);
      setState(() {});
    }
  }

  Future<void> _loadLeadDetails(String callMasterId) async {
    if (leadDetails == null || this.callMasterId != callMasterId) {
      leadDetails = await HttpService.leadDetails(widget.token, callMasterId);
      if (leadDetails != null) {
        this.callMasterId = callMasterId;
        contactMobile.text =
            await Common.addPlus(leadDetails!.data!.contactNumber1.toString());
        setState(() {
          whatsappNo1 = leadDetails!.data!.contactNumber1.toString();
          whatsappNo = leadDetails!.data!.contactNumber1.toString();
          contactFName.text = leadDetails!.data!.clientName.toString();
          contactMobile.text = '+${leadDetails!.data!.contactNumber1}';
        });
        listAddonDet(widget.token!, callMasterId);
        listFolderList(widget.token!, callMasterId, '');
        listMileStone(widget.token!, callMasterId);
      }
    }
  }

  void _toggleSortOrder() {
    setState(() {
      sortAscending = !sortAscending;
      currentSortOrder = sortAscending ? 'asc' : 'desc';
    });
    _clearCacheIfNeeded();
    getData(currentSortOrder, true, status);
  }

  void _clearCacheIfNeeded() {
    final newCacheKey = _generateCacheKey();
    if (_currentCacheKey != newCacheKey) {
      items.clear();
      page = 1;
      _currentCacheKey = newCacheKey;
    }
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _showLeadDetailsPopup(int index,
      {bool autoExpandFollowup = false, String? customCallMasterId}) async {
    final String targetCallMasterId;
    if (customCallMasterId != null) {
      targetCallMasterId = customCallMasterId;
    } else {
      if (index < 0 || index >= items.length) return;
      targetCallMasterId =
          (_searchQuery.isEmpty ? items[index] : _filteredItems[index])
              .callMasterId;
    }

    final displayItem =
        _searchQuery.isEmpty ? items[index] : _filteredItems[index];

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
        HttpService.listFolderAndFiles(widget.token!, targetCallMasterId, ''),
        HttpService.leadMileStone(widget.token!, targetCallMasterId),
        HttpService.leadFollowupData(widget.token!, targetCallMasterId),
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
      final leadDetailsFollowup = results[4] as LeadFollowupData?;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LeadDetailsPopup(
          token: widget.token!,
          editLead: widget.editLead,
          deleteLead: widget.deleteLead,
          cloudCall: widget.cloudCall,
          callMasterId: targetCallMasterId,
          leadDetails: leadDetails,
          leadDetailsAdditional: leadDetailsAdditional,
          listFolder: listFolder,
          mileStone: mileStone,
          leadDetailsFollowup: leadDetailsFollowup,
          commonDetails: commonDetails,
          pageName: widget.pageName ?? '',
          status: widget.status,
          staff: widget.staff,
          isCalled: widget.isCalled,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          category: widget.category,
          leadType: widget.leadType,
          autoExpandFollowup: autoExpandFollowup,
          onDataChanged: () {
            _refreshList();
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Common.toastMessaage(
          "Error loading lead details: ${e.toString()}", accentRed);
    }
  }

  Future<void> _showCategoryPopup(Detail lead, int index) async {
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
                            onTap: () {
                              if (viewLeadCategoryOnly == "true") return;

                              Navigator.pop(context);
                              _showLeadDetailsPopup(
                                index,
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

  Future<void> _openLeadDetailsByMasterId(String cmId) async {
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
        HttpService.leadDetails(widget.token!, cmId),
        HttpService.listAddonDet(widget.token!, cmId),
        HttpService.listFolderAndFiles(widget.token!, cmId, ''),
        HttpService.leadMileStone(widget.token!, cmId),
        HttpService.leadFollowupData(widget.token!, cmId),
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
      final leadDetailsFollowup = results[4] as LeadFollowupData?;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LeadDetailsPopup(
          token: widget.token!,
          editLead: widget.editLead,
          deleteLead: widget.deleteLead,
          cloudCall: widget.cloudCall,
          callMasterId: cmId,
          leadDetails: leadDetails,
          leadDetailsAdditional: leadDetailsAdditional,
          listFolder: listFolder,
          mileStone: mileStone,
          leadDetailsFollowup: leadDetailsFollowup,
          commonDetails: commonDetails,
          pageName: 'notification',
          status: widget.status,
          staff: widget.staff,
          isCalled: widget.isCalled,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          category: widget.category,
          leadType: widget.leadType,
          onDataChanged: () {
            getData(currentSortOrder, true, status);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Common.toastMessaage(
          "Error loading lead details: ${e.toString()}", accentRed);
    }
  }

  // void _refreshList() {
  //   setState(() {
  //     _loadedLeadIds.clear();
  //     items.clear();
  //     page = 1;
  //     hasMore = true;
  //     _isDataLoaded = false;
  //   });
  //   getData(currentSortOrder, true, status);
  // }
void _refreshList() async {
  final positions = itemPositionsListener.itemPositions.value;

  if (positions.isNotEmpty) {
    _lastVisibleIndex = positions
        .where((p) => p.itemLeadingEdge >= 0)
        .reduce((min, p) =>
            p.index < min.index ? p : min)
        .index;
  }

  setState(() {
    _loadedLeadIds.clear();
    items.clear();
    page = 1;
    hasMore = true;
    _isDataLoaded = false;
  });

  await getData(currentSortOrder, true, status);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (itemScrollController.isAttached &&
        _lastVisibleIndex < items.length) {
      itemScrollController.scrollTo(
        index: _lastVisibleIndex,
        duration: const Duration(milliseconds: 300),
      );
    }
  });
}
  Future<void> _updateSingleLead(
      int index, String callMasterId, bool isFiltered) async {
    try {
      final updatedDetails =
          await HttpService.leadDetails(widget.token!, callMasterId);
      if (updatedDetails != null && updatedDetails.data != null) {
        final data = updatedDetails.data!;
        setState(() {
          bool removed = false;

          bool shouldRemove = false;
          String newStatusIdStr = data.callResultId ?? '';

          if (statusWise == 'yes' && statusWiseId.isNotEmpty) {
            if (newStatusIdStr != statusWiseId) {
              shouldRemove = true;
            }
          } else if (status != null && status != "0") {
            if (newStatusIdStr != status.toString()) {
              shouldRemove = true;
            }
          } else if (checkedResponseItems.isNotEmpty) {
            if (!checkedResponseItems.contains(newStatusIdStr)) {
              shouldRemove = true;
            }
          } else if (isCalled == false) {
            if (newStatusIdStr != '1') {
              shouldRemove = true;
            }
          }

          if (!shouldRemove && fromdate != null && todate != null) {
            String? nextFollowupStr = data.nextFollowupDate;
            if (nextFollowupStr != null && nextFollowupStr.isNotEmpty) {
              try {
                DateTime nextDt;
                if (nextFollowupStr.contains('-')) {
                  if (nextFollowupStr.split('-')[0].length == 4) {
                    nextDt = DateTime.parse(nextFollowupStr);
                  } else {
                    nextDt =
                        DateFormat('dd-MM-yyyy HH:mm').parse(nextFollowupStr);
                  }
                } else {
                  nextDt = DateTime.parse(nextFollowupStr);
                }

                DateTime begin =
                    DateTime(fromdate!.year, fromdate!.month, fromdate!.day);
                DateTime end = DateTime(
                    todate!.year, todate!.month, todate!.day, 23, 59, 59);

                if (nextDt.isBefore(begin) || nextDt.isAfter(end)) {
                  shouldRemove = true;
                }
              } catch (e) {
                log("Error parsing date in _updateSingleLead: $e");
              }
            }
          }

          if (shouldRemove) {
            items.removeWhere((it) => it.callMasterId == callMasterId);
            _filteredItems.removeWhere((it) => it.callMasterId == callMasterId);

            if (viewLeads != null) {
              viewLeads!.data.totalLeads =
                  (viewLeads!.data.totalLeads - 1).clamp(0, 999999);
            }
            removed = true;
          }

          if (!removed) {
            _updateLeadInList(items, callMasterId, data);
            _updateLeadInList(_filteredItems, callMasterId, data);
            _sortItemsLocally();
          }
        });
      }
    } catch (e) {
      log("Error updating single lead: $e");
      _refreshList();
    }
  }

  void _updateLeadInList(List<Detail> list, String callMasterId, var data) {
    int idx = list.indexWhere((it) => it.callMasterId == callMasterId);
    if (idx != -1) {
      final item = list[idx];
      item.callResult = data.callResult ?? item.callResult;
      item.callResultId =
          int.tryParse(data.callResultId ?? '') ?? item.callResultId;
      item.clientName = data.clientName ?? item.clientName;
      item.contactNumber1 = data.contactNumber1 ?? item.contactNumber1;
      item.staffName = data.staffName ?? item.staffName;
      item.leadCategory = data.leadCategory ?? item.leadCategory;
      item.leadCategoryId = data.leadCategoryId ?? item.leadCategoryId;
      item.leadSubCategory = data.leadSubCategory ?? item.leadSubCategory;
      item.leadSubCategoryId = data.leadSubCategoryId ?? item.leadSubCategoryId;
      item.priority = data.priorityId ?? item.priority;
      item.priorityName = data.priority ?? item.priorityName;
      item.cost = data.cost ?? item.cost;
      item.address = data.address ?? item.address;
      item.followupDate = data.nextFollowupDate ?? item.followupDate;
      item.calledDate = data.calledDate ?? item.calledDate;
    }
  }

  void _sortItemsLocally() {
    Comparator<Detail> comparator = (a, b) {
      DateTime dateA =
          _parseDate(a.followupDate.isNotEmpty ? a.followupDate : a.calledDate);
      DateTime dateB =
          _parseDate(b.followupDate.isNotEmpty ? b.followupDate : b.calledDate);

      if (currentSortOrder == 'asc') {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    };

    items.sort(comparator);
    if (_searchQuery.isNotEmpty) {
      _filteredItems.sort(comparator);
    }
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) return DateTime(1900);
    try {
      if (dateStr.contains('-')) {
        List<String> parts = dateStr.split(' ');
        List<String> dateParts = parts[0].split('-');
        if (dateParts[0].length == 4) {
          return DateTime.parse(dateStr);
        } else {
          String formatted = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";
          if (parts.length > 1) formatted += " ${parts[1]}";
          return DateTime.parse(formatted);
        }
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      log("Error parsing date: $dateStr -> $e");
      return DateTime(1900);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isDataLoaded = false;
          items.clear();
          _filteredItems.clear();
          _searchController.clear();
          _searchQuery = '';
          selectedIUsers.clear();
          selectedUserNumbers.clear();
          _isSelectAll = false;
          page = 1;
        });

        await getData(currentSortOrder, true, status);
      },
      color: appBarStart,
      child: result == true && timeOut == false
          ? Scaffold(
              backgroundColor: backgroundLight,
              appBar: _buildAppBar(),
              body: viewLeads != null && configure != null
                  ? Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: viewLeads!.data.details.isNotEmpty
                              ? ScrollablePositionedList.builder(
                                  padding: const EdgeInsets.all(12),
                                  initialScrollIndex: (widget.scrollToIndex !=
                                              null &&
                                          widget.scrollToIndex! < items.length)
                                      ? widget.scrollToIndex!
                                      : 0,
                                  itemCount: (_searchQuery.isEmpty
                                          ? items.length
                                          : _filteredItems.length) +
                                      (isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        (_searchQuery.isEmpty
                                            ? items.length
                                            : _filteredItems.length)) {
                                      return _buildLoaderListItem();
                                    }

                                    final itemIndex =
                                        _searchQuery.isEmpty ? index : index;
                                    final displayItems = _searchQuery.isEmpty
                                        ? items
                                        : _filteredItems;

                                    if (itemIndex >= displayItems.length) {
                                      return Container();
                                    }

                                    return Dismissible(
                                      key: Key(
                                          '${displayItems[itemIndex].callMasterId}_$index'),
                                      background:
                                          _buildDismissibleBackground(true),
                                      secondaryBackground:
                                          _buildDismissibleBackground(false),
                                      confirmDismiss: (direction) async {
                                        if (direction ==
                                            DismissDirection.endToStart) {
                                          return await _handleFollowupAction(
                                              itemIndex);
                                        } else if (direction ==
                                            DismissDirection.startToEnd) {
                                          return await _handleCallAction(
                                              itemIndex);
                                        }
                                        return false;
                                      },
                                      onDismissed: (direction) {
                                        // Items are no longer dismissed on swipe
                                      },
                                      child: InkWell(
                                        onLongPress: () =>
                                            _handleLongPress(itemIndex),
                                        onTap: () {
                                          if (selectedIUsers.isNotEmpty) {
                                            _handleLongPress(itemIndex);
                                          } else {
                                            _showLeadDetailsPopup(itemIndex);
                                          }
                                        },
                                        child:
                                            leadListWidget(context, itemIndex),
                                      ),
                                    );
                                  },
                                  itemScrollController: itemScrollController,
                                  itemPositionsListener: itemPositionsListener,
                                )
                              : _buildEmptyState(),
                        ),
                      ],
                    )
                  : _buildLoadingState(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                backgroundColor: appBarStart,
                elevation: 4,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DashboardLeadNewUpdatedTwo(widget.token)),
                  );
                },
                child: Image.asset("assets/icons/menu.png",
                    width: 25, color: Colors.white),
              ),
              bottomNavigationBar: configure != null
                  ? BottomNavigation(
                      widget.token!,
                      phoneCallLogPermission: phoneCallLogPermission,
                      name: name,
                      userId: userId,
                    )
                  : const SizedBox())
          : _buildErrorState(),
    );
  }

  Widget _buildDismissibleBackground(bool isCall) {
    return Container(
      decoration: BoxDecoration(
        color: isCall ? callGreen : followupBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Align(
        alignment: isCall ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isCall ? Icons.call : Icons.add_comment,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                isCall ? " Call" : "Add Followup",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _handleFollowupAction(int index) {
    if (index >= items.length) return Future.value(false);

    final displayItem =
        _searchQuery.isEmpty ? items[index] : _filteredItems[index];

    if (displayItem.callResult != "Confirmed") {
      _showLeadDetailsPopup(index, autoExpandFollowup: true);
    } else {
      Common.toastMessaage(
          "You can't follow up on confirmed leads", accentOrange);
    }
    return Future.value(false);
  }

  Future<bool?> _handleCallAction(int index) async {
    if (index >= items.length) return false;

    final displayItem =
        _searchQuery.isEmpty ? items[index] : _filteredItems[index];

    try {
      if (viewLeads!.data.callPermission == false) {
        _showCallPermissionDialog(index);
        return false;
      } else {
        if (widget.cloudCall == true) {
          await chooseCallDialog(context, index);
          return false;
        } else {
          Common.dialPad(displayItem.contactNumber1);
          _showCallInitiatedMessage();
          return false;
        }
      }
    } catch (e) {
      log("Error in call action: $e");
      Common.toastMessaage("Failed to initiate call", accentRed);
      return false;
    }
  }

  void _handleLongPress(int index) {
    if (index >= items.length) return;

    final displayItem =
        _searchQuery.isEmpty ? items[index] : _filteredItems[index];

    setState(() {
      displayItem.isSelected = !displayItem.isSelected;
      if (displayItem.isSelected) {
        if (!selectedIUsers.contains(displayItem.callMasterId)) {
          selectedIUsers.add(displayItem.callMasterId);
          selectedUserNumbers.add(displayItem.contactNumber1);
        }
      } else {
        selectedIUsers.remove(displayItem.callMasterId);
        selectedUserNumbers.remove(displayItem.contactNumber1);
      }
      _updateSelectAllState();
    });
  }

  void _updateSelectAllState() {
    final visibleItems = _searchQuery.isEmpty ? items : _filteredItems;
    if (visibleItems.isEmpty) {
      _isSelectAll = false;
      return;
    }
    final allSelected = visibleItems.every((item) => item.isSelected);
    setState(() {
      _isSelectAll = allSelected;
    });
  }

  void _showCallPermissionDialog(int index) {
    final displayItem =
        _searchQuery.isEmpty ? items[index] : _filteredItems[index];

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Alert !!!',
            style: TextStyle(color: accentOrange),
          ),
          content: Text(viewLeads!.data.warningMessage.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarStart,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _showLeadDetailsPopup(index, autoExpandFollowup: true);
              },
              child: const Text('Followup'),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [appBarStart, appBarEnd],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10.0, top: 10.0, bottom: 10.0, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            shape: BoxShape.circle),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                    // if (selectedIUsers.isNotEmpty)
                    //   Text(
                    //     '${selectedIUsers.length} selected',
                    //     style:
                    //         const TextStyle(color: Colors.white, fontSize: 18),
                    //   )
                    Text(
                      selectedIUsers.isNotEmpty
                          ? ''
                          : widget.pageName.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    // else
                    //   Expanded(
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text(
                    //           widget.pageName.toString(),
                    //           style: const TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //         if (widget.staffName != null &&
                    //             widget.staffName!.isNotEmpty)
                    //           Text(
                    //             widget.staffName!,
                    //             style: const TextStyle(
                    //               color: Colors.white,
                    //               fontSize: 12,
                    //             ),
                    //             maxLines: 1,
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (selectedIUsers.isEmpty) ...[
                    // View Toggle Button
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isCompactView = !_isCompactView;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Icon(
                          _isCompactView
                              ? Icons.view_agenda_outlined
                              : Icons.view_headline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                  InkWell(
                    onTap: _toggleSortOrder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            sortAscending ? 'Oldest' : 'Newest',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedIUsers.isNotEmpty) ..._buildSelectionActions(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSelectionActions() {
    return [
      InkWell(
        onTap: _toggleSelectAll,
        child: Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                _isSelectAll ? Icons.check_box : Icons.check_box_outline_blank,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 2),
              const Text(
                'All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Text(
            selectedIUsers.length.toString(),
            style: const TextStyle(color: appBarStart, fontSize: 14),
          ),
        ),
      ),
      const SizedBox(width: 12),
      if (transferPermission == "true")
        InkWell(
          onTap: () => transferLeads(context),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child:
                const Icon(Icons.compare_arrows_rounded, color: Colors.white),
          ),
        ),
      const SizedBox(width: 8),
      if (widget.deleteLead)
        InkWell(
          onTap: _showDeleteConfirmationDialog,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: accentRed),
          ),
        ),
    ];
  }

  void _toggleSelectAll() {
    setState(() {
      _isSelectAll = !_isSelectAll;

      if (_isSelectAll) {
        final itemsToSelect = _searchQuery.isEmpty ? items : _filteredItems;
        for (var item in itemsToSelect) {
          if (!item.isSelected) {
            item.isSelected = true;
            if (!selectedIUsers.contains(item.callMasterId)) {
              selectedIUsers.add(item.callMasterId);
              selectedUserNumbers.add(item.contactNumber1);
            }
          }
        }
      } else {
        for (var item in items) {
          item.isSelected = false;
        }
        selectedIUsers.clear();
        selectedUserNumbers.clear();
      }
    });
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total Leads Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        color: appBarStart, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Total Leads : ${viewLeads?.data.totalLeads ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons Section (Filter and Search)
              Row(
                children: [
                  // Filter Button
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ViewLeadsFilterWidget(
                          currentTab: widget.pageName,
                          isActiveLeads: widget.isFollowup == "1" ? "1" : "",
                          commonDetails: commonDetails,
                          productSectionModel: productSectionModel,
                          initialFilters: {
                            'isDateFiltered': isDateFiltered,
                            'fromDate': fromdate,
                            'toDate': todate,
                            'statusIds':
                                (status != null) ? [status.toString()] : [],
                            'staffIds': checkedAssignedStaffItems,
                            'categoryIds': checkedCategoryItems,
                            'priorityIds': checkedPriorityItems,
                            'productIds': checkedProductItems,
                            'classIds': checkedClassItems,
                            'streamNames': checkedStreamItems,
                            'syllabusIds': checkedSyllabusItems,
                            'schoolDistrictIds': checkedSchoolDistrictItems,
                            'abroadIds': checkedAbroadItems,
                            'schoolIds': checkedSchoolItems,
                            'dateType': selectedDateType,
                          },
                          onApplyFilters: (filters) {
                            setState(() {
                              fromdate = filters['fromDate'];
                              todate = filters['toDate'];
                              selectedDateType =
                                  filters['dateType'] ?? 'created';

                              checkedAssignedStaffItems =
                                  List<String>.from(filters['staffIds'] ?? []);

                              checkedCategoryItems =
                                  List<String>.from(filters['categoryIds'] ?? []);

                              checkedPriorityItems =
                                  List<String>.from(filters['priorityIds'] ?? []);

                              checkedProductItems =
                                  List<String>.from(filters['productIds'] ?? []);

                              checkedClassItems =
                                  List<String>.from(filters['classIds'] ?? filters['class_id'] ?? []);

                              checkedStreamItems =
                                  List<String>.from(filters['streamNames'] ?? filters['stream'] ?? []);

                              checkedSyllabusItems =
                                  List<String>.from(filters['syllabusIds'] ?? filters['syllabus'] ?? []);

                              checkedSchoolDistrictItems =
                                  List<String>.from(filters['schoolDistrictIds'] ?? filters['school_district_id'] ?? []);

                              checkedAbroadItems =
                                  List<String>.from(filters['abroadIds'] ?? filters['abroad'] ?? []);

                              checkedSchoolItems =
                                  List<String>.from(filters['schoolIds'] ?? filters['school_name'] ?? []);

                              final statusIds =
                                  List<String>.from(filters['statusIds'] ?? []);

                              status =
                                  statusIds.isNotEmpty ? statusIds.first : null;

                              fromdateUpdated = filters['fromDateUpdated'];
                              todateUpdated = filters['toDateUpdated'];

                              selectedTagIds =
                                  List<String>.from(filters['tagIds'] ?? []);

                              isDateFiltered =
                                  filters['isDateFiltered'] ?? false;

                              isDateFilteredUpdated =
                                  filters['isDateFilteredUpdated'] ?? false;

                              isFilterApplied = true;
                              _isDataLoaded = false;

                              page = 1;
                              items.clear();
                            });

                            getData(
                              currentSortOrder,
                              true,
                              status,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderLight,
                          width: 1.5,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 22,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Search Toggle Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        searchField = !searchField;

                        if (!searchField) {
                          _searchController.clear();
                          searchText = '';

                          page = 1;
                          items.clear();
                          _isDataLoaded = false;

                          getData(
                            currentSortOrder,
                            true,
                            status,
                          );
                        }
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: searchField
                            ? appBarStart
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: searchField
                              ? appBarStart
                              : borderLight,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          searchField
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          color: searchField
                              ? Colors.white
                              : appBarStart.withOpacity(0.8),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),

        // Expandable Search Bar
        if (searchField)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,

                      onChanged: (value) {
                        searchText = value.trim();
                        setState(() {});
                      },

                      onSubmitted: (value) async {
                        searchText = value.trim();

                        page = 1;
                        items.clear();
                        _isDataLoaded = false;

                        await getData(
                          currentSortOrder,
                          true,
                          status,
                        );
                      },

                      decoration: InputDecoration(
                        hintText: 'Search by name, phone or staff...',
                        hintStyle: TextStyle(
                          color: textSecondary.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: appBarStart,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),

                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      searchText = _searchController.text.trim();

                      page = 1;
                      items.clear();
                      _isDataLoaded = false;

                      await getData(
                        currentSortOrder,
                        true,
                        status,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 20,
                    ),
                  ), 

                  // Clear Button
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () async {
                        _searchController.clear();
                        searchText = '';

                        page = 1;
                        items.clear();
                        _isDataLoaded = false;

                        await getData(
                          currentSortOrder,
                          true,
                          status,
                        );

                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget leadListWidget(BuildContext context, int index) {
    final displayItem =
        _searchQuery.isEmpty ? items[index] : _filteredItems[index];

    // Determine if this specific item should show compact or detailed view
    // If the ID is in _expandedLeadIds, it toggles the global _isCompactView state for this item
    bool isDetailed = _isCompactView
        ? _expandedLeadIds.contains(displayItem.callMasterId.toString())
        : !_expandedLeadIds.contains(displayItem.callMasterId.toString());

    bool isCreatedToday = false;
    if (displayItem.createdDate.isNotEmpty) {
      String dateStr = displayItem.createdDate.split(' ')[0];
      String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      String todayAlt = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (dateStr == today || dateStr == todayAlt) {
        isCreatedToday = true;
      }
    }

    if (!isDetailed) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: displayItem.isSelected
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
              color: displayItem.isSelected ? appBarStart : borderLight,
              width: displayItem.isSelected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Left Priority Indicator Bar
                Container(
                  width: 5,
                  height: 75, // Approximate height for compact view
                  color: displayItem.priority == '1'
                      ? Colors.grey.shade300
                      : displayItem.priority == '2'
                          ? callGreen
                          : displayItem.priority == '3'
                              ? accentRed
                              : displayItem.priority == '4'
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
                              child: Text(
                                displayItem.clientName == "null" ||
                                        displayItem.clientName.isEmpty
                                    ? "Unknown"
                                    : displayItem.clientName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: displayItem.isCustomer
                                      ? callGreen
                                      : textPrimary,
                                  decoration: displayItem.priority == "4"
                                      ? TextDecoration.lineThrough
                                      : null,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentRed.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: accentRed.withOpacity(0.2)),
                              ),
                              child: Text(
                                displayItem.leadCategory.isEmpty
                                    ? "General"
                                    : displayItem.leadCategory,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: accentRed,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (int.tryParse(displayItem.categoryCount) !=
                                    null &&
                                int.parse(displayItem.categoryCount) > 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: InkWell(
                                  onTap: () =>
                                      _showCategoryPopup(displayItem, index),
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: const BoxDecoration(
                                      color: accentOrange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        displayItem.categoryCount.toString(),
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
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  String id =
                                      displayItem.callMasterId.toString();
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
                                child: Icon(Icons.keyboard_arrow_down_rounded,
                                    color: textSecondary, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (displayItem.lastCalledDate.isNotEmpty ||
                            (displayItem.nextFollowupDate.isNotEmpty &&
                                displayItem.nextFollowupDate !=
                                    "00-00-0000 12:00 AM")) ...[
                          Row(
                            children: [
                              if (displayItem.lastCalledDate.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone_callback,
                                          size: 12, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Called: ${displayItem.lastCalledDate}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (displayItem.lastCalledDate.isNotEmpty &&
                                  displayItem.nextFollowupDate.isNotEmpty &&
                                  displayItem.nextFollowupDate !=
                                      "00-00-0000 12:00 AM")
                                const SizedBox(width: 8),
                              if (displayItem.nextFollowupDate.isNotEmpty &&
                                  displayItem.nextFollowupDate !=
                                      "00-00-0000 12:00 AM")
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.event_note,
                                          size: 12, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Next: ${displayItem.nextFollowupDate}",
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
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: displayItem.callResultId >= 0 &&
                                        displayItem.callResultId <
                                            _colors.length
                                    ? _colors[displayItem.callResultId]
                                        .withOpacity(0.15)
                                    : accentOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: displayItem.callResultId >= 0 &&
                                          displayItem.callResultId <
                                              _colors.length
                                      ? _colors[displayItem.callResultId]
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
                                      color: displayItem.callResultId >= 0 &&
                                              displayItem.callResultId <
                                                  _colors.length
                                          ? _colors[displayItem.callResultId]
                                          : accentOrange,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    displayItem.callResult.isEmpty
                                        ? "Pending"
                                        : displayItem.callResult,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: displayItem.callResultId >= 0 &&
                                              displayItem.callResultId <
                                                  _colors.length
                                          ? _colors[displayItem.callResultId]
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
                                  onTap: () async {
                                    if (viewLeads!.data.callPermission ==
                                        false) {
                                      _showCallPermissionDialog(index);
                                    } else {
                                      if (widget.cloudCall == true) {
                                        chooseCallDialog(context, index);
                                      } else {
                                        Common.dialPad(
                                            displayItem.contactNumber1);
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
                                    if (displayItem.contactNumber1.isNotEmpty) {
                                      Common.openWhatsApp(
                                          displayItem.contactNumber1);
                                    }
                                  },
                                ),
                                // const SizedBox(width: 12),
                                // _buildMiniActionButton(
                                //   icon: Icons.inventory_2_rounded,
                                //   color: Colors.blue,
                                //   onTap: () {
                                //     showModalBottomSheet(
                                //       context: context,
                                //       isScrollControlled: true,
                                //       backgroundColor: Colors.transparent,
                                //       builder: (context) =>
                                //           const ProductDetailsPopup(),
                                //     );
                                //   },
                                // ),
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
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: displayItem.isSelected
              ? appBarStart.withOpacity(0.05)
              : (isCreatedToday ? const Color(0xFFE8F5E9) : Colors.white),
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
            color: displayItem.isSelected ? appBarStart : borderLight,
            width: displayItem.isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      color: displayItem.priority == '1'
                          ? Colors.grey
                          : displayItem.priority == '2'
                              ? callGreen
                              : displayItem.priority == '3'
                                  ? accentRed
                                  : displayItem.priority == '4'
                                      ? textSecondary
                                      : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayItem.clientName == "null" ||
                              displayItem.clientName.isEmpty
                          ? "Unknown"
                          : displayItem.clientName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        decoration: displayItem.priority == "4"
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: accentRed,
                        color: displayItem.isCustomer ? callGreen : textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayItem.leadCategory.isEmpty
                          ? "General"
                          : displayItem.leadCategory,
                      style: const TextStyle(
                        fontSize: 12,
                        color: accentRed,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (int.tryParse(displayItem.categoryCount) != null &&
                      int.parse(displayItem.categoryCount) > 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: InkWell(
                        onTap: () => _showCategoryPopup(displayItem, index),
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: const BoxDecoration(
                            color: accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              displayItem.categoryCount.toString(),
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
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        String id = displayItem.callMasterId.toString();
                        if (_expandedLeadIds.contains(id)) {
                          _expandedLeadIds.remove(id);
                        } else {
                          _expandedLeadIds.add(id);
                        }
                      });
                    },
                    child: Icon(Icons.keyboard_arrow_up_rounded,
                        color: textSecondary, size: 22),
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  // Date section at top
                  if (displayItem.callResultId == 1)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: backgroundLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Image.asset("assets/icons/calendar.png",
                              width: 14, color: appBarStart),
                          const SizedBox(width: 4),
                          const Text(
                            'Created: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            displayItem.createdDate.isEmpty
                                ? "--"
                                : displayItem.createdDate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (displayItem.lastCalledDate.isNotEmpty ||
                      (displayItem.nextFollowupDate.isNotEmpty &&
                          displayItem.nextFollowupDate !=
                              "00-00-0000 12:00 AM"))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          if (displayItem.lastCalledDate.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_callback,
                                      size: 12, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Called: ${displayItem.lastCalledDate}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (displayItem.lastCalledDate.isNotEmpty &&
                              displayItem.nextFollowupDate.isNotEmpty &&
                              displayItem.nextFollowupDate !=
                                  "00-00-0000 12:00 AM")
                            const SizedBox(width: 8),
                          if (displayItem.nextFollowupDate.isNotEmpty &&
                              displayItem.nextFollowupDate !=
                                  "00-00-0000 12:00 AM")
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_note,
                                      size: 12, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Next: ${displayItem.nextFollowupDate}",
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
                    ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.phone_rounded,
                                    size: 16,
                                    color: appBarStart.withOpacity(0.8)),
                                const SizedBox(width: 6),
                                Text(
                                  displayItem.contactNumber1.isEmpty
                                      ? "No phone"
                                      : displayItem.contactNumber1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.person_outline_rounded,
                                    size: 16,
                                    color: appBarStart.withOpacity(0.8)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Assigned to : ${displayItem.staffName.isEmpty ? "Unassigned" : displayItem.staffName}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary.withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Profile image
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderLight, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: displayItem.profilePic.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(displayItem.profilePic),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: displayItem.profilePic.isEmpty
                            ? const Icon(Icons.person,
                                color: textSecondary, size: 20)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Action Buttons Row with Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: displayItem.callResultId >= 0 &&
                                  displayItem.callResultId < _colors.length
                              ? _colors[displayItem.callResultId]
                                  .withOpacity(0.15)
                              : const Color.fromARGB(255, 59, 140, 233)
                                  .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: displayItem.callResultId >= 0 &&
                                      displayItem.callResultId < _colors.length
                                  ? _colors[displayItem.callResultId]
                                      .withOpacity(0.4)
                                  : const Color.fromARGB(255, 59, 140, 233)
                                      .withOpacity(0.7),
                              width: 1),
                        ),
                        child: Text(
                          displayItem.callResult.isEmpty
                              ? "Pending"
                              : displayItem.callResult,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: displayItem.callResultId >= 0 &&
                                    displayItem.callResultId < _colors.length
                                ? _colors[displayItem.callResultId]
                                : const Color.fromARGB(255, 43, 107, 145),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          // Call button
                          IgnorePointer(
                            ignoring: selectedIUsers.isNotEmpty,
                            child: GestureDetector(
                              onTap: () async {
                                if (viewLeads!.data.callPermission == false) {
                                  _showCallPermissionDialog(index);
                                } else {
                                  if (widget.cloudCall == true) {
                                    chooseCallDialog(context, index);
                                  } else {
                                    Common.dialPad(displayItem.contactNumber1);
                                  }
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selectedIUsers.isEmpty
                                      ? callGreen
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (selectedIUsers.isEmpty
                                              ? callGreen
                                              : Colors.grey)
                                          .withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.call,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Call',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // WhatsApp button
                          IgnorePointer(
                            ignoring: selectedIUsers.isNotEmpty,
                            child: GestureDetector(
                              onTap: () {
                                if (displayItem.contactNumber1.isNotEmpty) {
                                  Common.openWhatsApp(
                                      displayItem.contactNumber1);
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 36,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: selectedIUsers.isEmpty
                                      ? const Color(0xFF25D366)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (selectedIUsers.isEmpty
                                              ? const Color(0xFF25D366)
                                              : Colors.grey)
                                          .withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(FontAwesomeIcons.whatsapp,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ),
                          // const SizedBox(width: 6),

                          // // View Products button
                          // InkWell(
                          //   onTap: () {
                          //     showModalBottomSheet(
                          //       context: context,
                          //       isScrollControlled: true,
                          //       backgroundColor: Colors.transparent,
                          //       builder: (context) =>
                          //           const ProductDetailsPopup(),
                          //     );
                          //   },
                          //   child: Container(
                          //     width: 36,
                          //     height: 28,
                          //     decoration: BoxDecoration(
                          //       color: Colors.blue,
                          //       borderRadius: BorderRadius.circular(8),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: Colors.blue.withOpacity(0.2),
                          //           blurRadius: 4,
                          //           offset: const Offset(0, 2),
                          //         ),
                          //       ],
                          //     ),
                          //     child: const Center(
                          //       child: Icon(Icons.inventory_2_rounded,
                          //           color: Colors.white, size: 16),
                          //     ),
                          //   ),
                          // ),
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
    );
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

  Widget _buildLoadingState() {
    return Center(
      child: Lottie.asset('assets/main/loading.json',
          width: 350, height: 150, fit: BoxFit.fill),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Image.asset("assets/icons/nodatafound.png"),
          ),
          const Text('Result Not Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'No leads match your current filters',
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      DashboardLeadNewUpdatedTwo(widget.token)));
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: 36,
              decoration: BoxDecoration(
                color: appBarStart,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text('Go Back',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(timeOut == true
                        ? 'assets/icons/server_error.png'
                        : 'assets/icons/noNetwork.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                textAlign: TextAlign.center,
                timeOut == true
                    ? "Temporary issue!\nPlease retry"
                    : 'No Network Found',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _isDataLoaded = false;
                    page = 1;
                    items.clear();
                  });
                  getData('desc', true, status);
                },
                child: Container(
                  width: 100,
                  height: 32,
                  decoration: BoxDecoration(
                    color: appBarStart,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: Text(
              'Are you sure you want to delete ${selectedIUsers.length} selected leads?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _performBulkDelete();
                },
                child:
                    const Text('Delete', style: TextStyle(color: accentRed))),
          ],
        );
      },
    );
  }

  Future<void> _performBulkDelete() async {
    Common.showProgressDialog(context, "Deleting leads...");

    try {
      Map<String, dynamic> body = {
        "token": widget.token,
        'leadMasterIds': selectedIUsers,
      };

      BulkDeleteLeadModel deleteBulk = await HttpService.bulkDeleteLead(body);

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (deleteBulk.data == true) {
        Common.toastMessaage(
            '${selectedIUsers.length} lead(s) deleted successfully', callGreen);
        _refreshListAfterDelete();
      } else {
        Common.toastMessaage(deleteBulk.message, accentRed);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      Common.toastMessaage("Delete failed: ${e.toString()}", accentRed);
    }
  }

  void _refreshListAfterDelete() {
    final deletedCount = selectedIUsers.length;

    setState(() {
      selectedIUsers.clear();
      selectedUserNumbers.clear();
      _isSelectAll = false;
      for (var item in items) {
        item.isSelected = false;
      }
    });

    if (viewLeads != null) {
      viewLeads!.data.totalLeads = (viewLeads!.data.totalLeads - deletedCount)
          .clamp(0, double.maxFinite.toInt());
    }

    _reloadCurrentData();
  }

  void _reloadCurrentData() {
    setState(() {
      _isDataLoaded = false;
      isLoading = false;
    });

    items.clear();
    page = 1;

    getData(currentSortOrder, true, status).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<dynamic> transferLeads(BuildContext context) {
    int transferFresh = 0;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                          child: Icon(Icons.swap_horiz_rounded,
                              color: appBarStart, size: 24),
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
                        await collectedStaffDialog(context);
                        setDialogState(() {});
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                color: appBarStart.withOpacity(0.8), size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                staffName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.unfold_more_rounded,
                                color: Colors.grey.shade400, size: 18),
                          ],
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

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                                if (staffId.isEmpty) {
                                  Common.toastMessaage(
                                      "Please select a staff", accentRed);
                                  return;
                                }

                                Common.showProgressDialog(
                                    context, "Transferring leads...");

                                try {
                                  Map<String, dynamic> body = {
                                    "token": widget.token,
                                    'leadMasterIds': selectedIUsers,
                                    'staffId': staffId,
                                    'transfer_fresh': transferFresh
                                  };

                                  BulkTransferLeadModel bulkTransfer =
                                      await HttpService.bulkTransferLead(body);

                                  if (bulkTransfer.data == true) {
                                    Common.toastMessaage(
                                        bulkTransfer.message, callGreen);

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      _nuclearReset();
                                    }
                                  } else {
                                    Common.toastMessaage(
                                        bulkTransfer.message, accentRed);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Common.toastMessaage(
                                        "Transfer failed: $e", accentRed);
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
                                    fontWeight: FontWeight.w900, fontSize: 14),
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

  void _nuclearReset() {
    setState(() {
      selectedIUsers.clear();
      selectedUserNumbers.clear();
      _isSelectAll = false;
      staffName = "Staff";
      staffId = "";
      _loadedLeadIds.clear();
      items.clear();
      _filteredItems.clear();
      _searchController.clear();
      _searchQuery = '';
      page = 1;
      hasMore = true;
      _isDataLoaded = false;
      isLoading = false;
      isInitialLoad = true;
      for (var item in items) {
        item.isSelected = false;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceReloadData();
    });
  }

  void _forceReloadData() {
    viewLeads = null;
    getData(currentSortOrder, true, status).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<dynamic> collectedStaffDialog(BuildContext context) {
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
                          filteredStaff = commonDetails!.data.transferStaffs
                              .where((item) => item.tranStaffName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
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
                      itemCount: filteredStaff.length,
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          onTap: () {
                            staffName = filteredStaff[index].tranStaffName;
                            staffId = filteredStaff[index].tranStaffId;
                            filteredStaff.clear();
                            filteredStaff
                                .addAll(commonDetails!.data.transferStaffs);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredStaff[index].tranStaffName,
                              style: const TextStyle(fontSize: 13)),
                        );
                      },
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      filteredStaff.clear();
                      filteredStaff.addAll(commonDetails!.data.transferStaffs);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Close")),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoaderListItem() {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: List.generate(
            2,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // New filter implementation integrated via ViewLeadsFilterWidget
  // Legacy filtrationSheet and related builders removed for professional UI upgrade.

  Future<dynamic> chooseCallDialog(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final item =
            _searchQuery.isEmpty ? items[index] : _filteredItems[index];
        return AlertDialog(
          title: const Text('Choose Call Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                leading:
                    const Icon(Icons.cloud_circle_rounded, color: appBarStart),
                title: const Text('Cloud Call'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  Common.showProgressDialog(context, "Loading..");

                  try {
                    final result = await HttpService.addCloudCall(
                      widget.token,
                      item.callMasterId,
                      item.contactNumber1,
                    );

                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog

                      if (result != null && result.data == true) {
                        Common.toastMessaage(
                            result.message ?? "Call initiated successfully",
                            callGreen);
                        Navigator.pop(context); // Pop the previous screen
                      } else {
                        Common.toastMessaage(
                            result?.message ?? "Failed to initiate call",
                            accentRed);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog on error
                      Common.toastMessaage("An error occurred: $e", accentRed);
                    }
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                leading:
                    const Icon(Icons.phone_android_rounded, color: callGreen),
                title: const Text('Phone Call'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  Common.dialPad(item.contactNumber1);
                  _showCallInitiatedMessage();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class MessageViewWidget extends StatelessWidget {
  const MessageViewWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _ViewLeadsNewState.appBarStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: _ViewLeadsNewState.appBarStart, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _ViewLeadsNewState.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
