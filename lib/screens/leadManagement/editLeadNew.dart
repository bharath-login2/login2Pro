import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/leadSubTypeModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/models/lead_management/classListModel.dart';
import 'package:login2/models/lead_management/streamListModel.dart';
import 'package:login2/models/lead_management/syllabusListModel.dart';
import 'package:login2/models/lead_management/schoolDistrictListModel.dart';
import 'package:login2/models/lead_management/schoolListModel.dart';
import 'package:login2/models/lead_management/abroadListModel.dart';
import 'package:login2/widgets/AddLeadSourceDialog.dart';
import 'package:login2/widgets/addLeadCateoryPopup.dart';
import 'package:lottie/lottie.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/leadProductsModel.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../service/service.dart';
import '../../models/lead_management/leadExtraSettings.dart';
import 'dart:developer';

class EditLeadNew extends StatefulWidget {
  String? token;
  String callMasterId;
  bool editLeads;
  bool deleteLeads;
  bool cloudCall;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  int? scrolToIndex;
  EditLeadNew(this.token, this.callMasterId, this.editLeads, this.deleteLeads,
      this.cloudCall,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.scrolToIndex});

  @override
  State<EditLeadNew> createState() => _EditLeadNewState();
}

class _EditLeadNewState extends State<EditLeadNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  StateModel? stateDetails;
  CommonConfigureModel? configure;
  LeadSubTypeModel? leadSubTypeList;
  LeadDeatailsModel? leadDetails;
  final ScrollController _scrollController = ScrollController();
  String leadType = 'Lead Category', leadTypeId = '';
  String leadSubType = 'Sub Category', leadSubTypeId = '';
  String assignStaff = 'Assign Staff', assignStaffId = '';
  String leadSource = 'Lead Source', leadSourceId = '';
  String priority = 'Priority', priorityId = '';
  String callResult = 'New', callResultId = '1';
  String callResponse = 'Call Response', callResponseId = '';
  final TextEditingController nextFollowupCtrl = TextEditingController();
  final TextEditingController timeBeforeCtrl =
      TextEditingController(text: '10');
  final TextEditingController callResponseCtrl = TextEditingController();

  final TextEditingController leadTypeCtrl =
      TextEditingController(text: 'Lead Category');
  final TextEditingController leadSubTypeCtrl =
      TextEditingController(text: 'Sub Category');
  final TextEditingController assignStaffCtrl =
      TextEditingController(text: 'Assign Staff');
  final TextEditingController leadSourceCtrl =
      TextEditingController(text: 'Lead Source');
  final TextEditingController priorityCtrl =
      TextEditingController(text: 'Priority');

  final TextEditingController clientNameCtrl = TextEditingController();
  final TextEditingController contactNoCtrl = TextEditingController();
  final TextEditingController costCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController whatsappNoCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  // Student & School Details Fields
  List<ClassItem> classList = [];
  List<SyllabusItem> syllabusList = [];
  List<StreamItem> streamList = [];
  List<SchoolDistrictItem> schoolDistrictList = [];
  List<SchoolItem> schoolList = [];
  List<AbroadItem> abroadList = [];

  String selectedClassId = '', selectedClassName = 'Select Class';
  String selectedSyllabusId = '', selectedSyllabusValue = 'Select Syllabus';
  String selectedStreamName = 'Select Stream';
  String selectedSchoolDistrictId = '', selectedSchoolDistrictTitle = 'Select School District';
  String selectedSchoolId = '', selectedSchoolName = 'Select School Name';
  String selectedAbroadId = '', selectedAbroadName = 'Select Abroad';

  final TextEditingController divisionCtrl = TextEditingController();
  final TextEditingController classCtrl =
      TextEditingController(text: 'Select Class');
  final TextEditingController syllabusCtrl =
      TextEditingController(text: 'Select Syllabus');
  final TextEditingController streamCtrl =
      TextEditingController(text: 'Select Stream');
  final TextEditingController schoolDistrictCtrl =
      TextEditingController(text: 'Select School District');
  final TextEditingController schoolCtrl =
      TextEditingController(text: 'Select School Name');
  final TextEditingController abroadCtrl =
      TextEditingController(text: 'Select Abroad');
  bool isSchoolLoading = false;

  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  LeadProductSectionModel? productSectionModel;
  List<LeadProduct> _selectedProducts = [];
  bool isLoading = true,
      isDistrictLoading = false,
      isPinLoading = false,
      isLoadingSettings = false,
      checked = false;
  LeadSettings? leadSettings;
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

  Future<void> _fetchLeadExtraSettings(String callResultId) async {
    setState(() => isLoadingSettings = true);
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
      if (mounted) setState(() => isLoadingSettings = false);
    }
  }

  String code = '91', whatsappCode = '91', roleId = '', multiBranch = '';
  String? branch;
  String? contactPermission, createLeadCategory, addLeadSource;
  String? StateId, DistrictId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    clientNameCtrl.dispose();
    contactNoCtrl.dispose();
    costCtrl.dispose();
    addressCtrl.dispose();
    remarkCtrl.dispose();
    pinCodeCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    whatsappNoCtrl.dispose();
    emailCtrl.dispose();
    divisionCtrl.dispose();
    classCtrl.dispose();
    syllabusCtrl.dispose();
    streamCtrl.dispose();
    schoolDistrictCtrl.dispose();
    schoolCtrl.dispose();
    abroadCtrl.dispose();
    leadTypeCtrl.dispose();
    leadSubTypeCtrl.dispose();
    assignStaffCtrl.dispose();
    leadSourceCtrl.dispose();
    priorityCtrl.dispose();
    for (var ctrl in _additionalCtrls) ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity is List<ConnectivityResult>) {
      if (!connectivity.contains(ConnectivityResult.mobile) &&
          !connectivity.contains(ConnectivityResult.wifi)) {
        setState(() => isLoading = false);
        return;
      }
    }

    contactPermission = await Common.getSharedPref("getContactPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    addLeadSource = await Common.getSharedPref("addLeadSource");
    roleId = await Common.getSharedPref("roleId") ?? '';
    multiBranch = await Common.getSharedPref("multiBranch") ?? '';
    final String userToken = (widget.token != null && widget.token!.isNotEmpty)
        ? widget.token!
        : (await Common.getSharedPref("token") ?? '');

    commonDetails = await HttpService.addLeadCommonData(userToken);
    stateDetails = await HttpService.getState();
    productSectionModel = await HttpService.leadProductSection();
    configure = await HttpService.configure(userToken);
    leadDetails =
        await HttpService.leadDetails(userToken, widget.callMasterId);
    if (leadDetails?.data != null) {
      final data = leadDetails!.data!;
      clientNameCtrl.text = data.clientName ?? "";
      final cc = data.countryCode?.toString() ?? "";
      code = cc.isEmpty ? '91' : cc;
      final wc = data.whatsappNumberCountryCode?.toString() ?? "";
      whatsappCode = wc.isEmpty ? '91' : wc;
      contactNoCtrl.text = Common.trimCountryCode(
          mobileNumber: data.contactNumber1 ?? "", countryCode: code);
      whatsappNoCtrl.text = data.whatsaAppNumber ?? "";
      emailCtrl.text = data.emailId ?? "";
      costCtrl.text = data.cost?.toString() ?? "";
      addressCtrl.text = data.address ?? "";
      pinCodeCtrl.text = data.pinCode ?? "";
      remarkCtrl.text = data.remarks ?? "";
      branch = data.branchId?.toString();
      leadType = data.leadCategory ?? 'Lead Category';
      leadTypeCtrl.text = leadType;
      leadTypeId = data.leadCategoryId?.toString() ?? '';
      leadSubType = data.leadSubCategory ?? 'Sub Category';
      leadSubTypeCtrl.text = leadSubType;
      leadSubTypeId = data.leadSubCategoryId?.toString() ?? '';
      assignStaff = data.staffName ?? 'Assign Staff';
      assignStaffCtrl.text = assignStaff;
      assignStaffId = data.assignedUserId?.toString() ?? '';
      priority = data.priority ?? 'Priority';
      priorityCtrl.text = priority;
      priorityId = data.priorityId?.toString() ?? '';
      leadSource = data.leadSource ?? 'Lead Source';
      leadSourceId = data.leadSourceId?.toString() ?? '';
      if (commonDetails?.data.leadSource != null) {
        for (var src in commonDetails!.data.leadSource) {
          if (src.leadSourceId.toString() == leadSourceId && src.isRestricted == "Y") {
            leadSource = "${src.leadSource} (Restricted)";
            break;
          }
        }
      }
      leadSourceCtrl.text = leadSource;
      callResult = data.callResult ?? 'New';
      callResultId = data.callResultId?.toString() ?? '1';
      nextFollowupCtrl.text = data.nextFollowupDate ?? "";
      _fetchLeadExtraSettings(callResultId);
      if (leadTypeId.isNotEmpty) {
        leadSubTypeList = await HttpService.leadSubType(leadTypeId);
      }
      if (pinCodeCtrl.text.length == 6) {
        _loadPostOffices(pinCodeCtrl.text, initial: true);
      }
      if (data.stateId != null && data.stateId!.isNotEmpty) {
        StateId = data.stateId;
        stateCtrl.text = data.stateName ?? "";
        _loadDistricts(StateId!, initial: true);
      }
      if (data.productsOnAdd != null && data.productsOnAdd!.isNotEmpty) {
        final productIds = data.productsOnAdd!.split(',');
        if (productSectionModel?.data != null) {
          _selectedProducts = productSectionModel!.data!
              .where((p) => productIds.any((id) => id.trim() == p.id))
              .toList();
        }
      }
      _updateTotalCost();
      final addonDet =
          await HttpService.listAddonDet(userToken, widget.callMasterId);
      if (addonDet?.data != null) {
        for (var field in addonDet!.data.additionalFields) {
          final ctrl =
              TextEditingController(text: field.value?.toString() ?? "");
          _additionalCtrls.add(ctrl);
        }
      }

      final classRes = await HttpService.getClassList(userToken);
      if (classRes?.data != null) {
        classList = classRes!.data!;
      }

      final syllabusRes = await HttpService.getSyllabusList(userToken);
      if (syllabusRes?.data != null) {
        syllabusList = syllabusRes!.data!;
      }

      final streamRes = await HttpService.getStreamList(userToken);
      if (streamRes?.data != null) {
        streamList = streamRes!.data!;
      }

      final districtRes = await HttpService.getDistrictList(userToken);
      if (districtRes?.data != null) {
        schoolDistrictList = districtRes!.data!;
      }

      final abroadRes = await HttpService.getAbroadList(userToken);
      if (abroadRes?.data != null) {
        abroadList = abroadRes!.data!;
      }

      selectedClassId = data.classId ?? '';
      if (selectedClassId.isNotEmpty && classList.isNotEmpty) {
        try {
          final matchedClass = classList.firstWhere(
            (c) => c.classId == selectedClassId,
          );
          selectedClassName = matchedClass.className;
        } catch (_) {
          selectedClassName =
              data.className?.isNotEmpty == true ? data.className! : 'Select Class';
        }
      } else {
        selectedClassName =
            data.className?.isNotEmpty == true ? data.className! : 'Select Class';
      }
      classCtrl.text = selectedClassName;

      divisionCtrl.text = data.division ?? '';

      // Load saved syllabus into syllabusCtrl
      if (data.syllabusValue?.isNotEmpty == true) {
        selectedSyllabusId = data.syllabusValue!;
        selectedSyllabusValue = data.syllabusValue!;
        syllabusCtrl.text = data.syllabusValue!;
      } else {
        selectedSyllabusId = '';
        selectedSyllabusValue = 'Select Syllabus';
        syllabusCtrl.text = 'Select Syllabus';
      }

      // Load saved stream into streamCtrl
      if (data.streamName?.isNotEmpty == true) {
        selectedStreamName = data.streamName!;
        streamCtrl.text = data.streamName!;
      } else {
        selectedStreamName = 'Select Stream';
        streamCtrl.text = 'Select Stream';
      }

      selectedSchoolDistrictId = data.schoolDistrictId ?? '';
      if (selectedSchoolDistrictId.isNotEmpty && schoolDistrictList.isNotEmpty) {
        try {
          final matchedDistrict = schoolDistrictList.firstWhere(
            (d) => d.districtId == selectedSchoolDistrictId,
          );
          selectedSchoolDistrictTitle = matchedDistrict.districtTitle;
        } catch (_) {
          selectedSchoolDistrictTitle = data.schoolDistrictTitle?.isNotEmpty == true
              ? data.schoolDistrictTitle!
              : 'Select School District';
        }
      } else {
        selectedSchoolDistrictTitle = data.schoolDistrictTitle?.isNotEmpty == true
            ? data.schoolDistrictTitle!
            : 'Select School District';
      }
      schoolDistrictCtrl.text = selectedSchoolDistrictTitle;

      selectedSchoolId = data.schoolId ?? '';
      selectedSchoolName =
          data.schoolName?.isNotEmpty == true ? data.schoolName! : 'Select School Name';
      schoolCtrl.text = selectedSchoolName;

      selectedAbroadId = data.abroadId ?? '';
      if (selectedAbroadId.isNotEmpty && abroadList.isNotEmpty) {
        try {
          final matchedAbroad = abroadList.firstWhere(
            (a) => a.placeId == selectedAbroadId,
          );
          selectedAbroadName = matchedAbroad.placeName;
        } catch (_) {
          selectedAbroadName =
              data.abroadName?.isNotEmpty == true ? data.abroadName! : 'Select Abroad';
        }
      } else {
        selectedAbroadName =
            data.abroadName?.isNotEmpty == true ? data.abroadName! : 'Select Abroad';
      }
      abroadCtrl.text = selectedAbroadName;

      if (selectedSchoolDistrictId.isNotEmpty) {
        _fetchSchoolsForDistrict(selectedSchoolDistrictId);
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadPostOffices(String pin, {bool initial = false}) async {
    setState(() => isPinLoading = true);
    final model = await HttpService.fetchPostOffice(pin);
    setState(() {
      isPinLoading = false;
      postalCodeModel = model;
      postOffices = model?.postOffice ?? [];
      if (initial && leadDetails?.data?.postOffice != null) {
        selectedPostOffice = postOffices.firstWhere(
          (po) =>
              po.name?.toLowerCase() ==
              leadDetails!.data!.postOffice!.toLowerCase(),
          orElse: () => postOffices.isNotEmpty ? postOffices.first : null!,
        );
      } else if (!initial) {
        selectedPostOffice = null;
      }
    });
  }

  Future<void> _loadDistricts(String sId, {bool initial = false}) async {
    setState(() => isDistrictLoading = true);
    final result = await HttpService.getDistrict(sId);
    setState(() {
      districtList = result?.data ?? [];
      isDistrictLoading = false;
      if (initial && leadDetails?.data?.districtId != null) {
        final d = districtList.firstWhere(
          (d) => d.id == leadDetails!.data!.districtId,
          orElse: () => districtList.isNotEmpty ? districtList.first : null!,
        );
        DistrictId = d?.id;
        districtCtrl.text = d?.name ?? "";
      } else if (!initial) {
        DistrictId = null;
        districtCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: Lottie.asset('assets/main/loading.json', width: 150))
          : leadDetails == null || commonDetails == null || configure == null
              ? _buildNoNetworkView()
              : configure!.data!.isExpired == true
                  ? _buildExpiredView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Edit Lead',
          style: TextStyle(color: Colors.white, fontSize: 18)),
      backgroundColor: const Color(0xFF2a86c9),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildNoNetworkView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/noNetwork.jpg', width: 200, height: 200),
          const Text('No Network Found!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ElevatedButton(
              onPressed: _initializeData, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildExpiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/main/packageimage.png', height: 160),
          const Text('Package Expired!',
              style: TextStyle(fontSize: 20, color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('UPGRADE')),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (multiBranch == 'true' && roleId == '2') _buildBranchField(),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Customer Details',
              icon: Icons.person_outline,
              children: [
                const SizedBox(height: 12),
                _buildCustomerRow(),
                const SizedBox(height: 12),
                _buildPhoneField(),
                const SizedBox(height: 12),
                _buildLeadCategoryField(),
                const SizedBox(height: 12),
                if (leadSubTypeList?.data?.isNotEmpty ?? false) ...[
                  _buildSubCategoryField(),
                  const SizedBox(height: 12),
                ],
                _buildStaffField(),
                const SizedBox(height: 12),
                _buildClassField(),
                const SizedBox(height: 12),
                _buildDivisionField(),
                const SizedBox(height: 12),
                _buildSyllabusField(),
                const SizedBox(height: 12),
                if (_isClass11Or12(selectedClassName)) ...[
                  _buildStreamField(),
                  const SizedBox(height: 12),
                ],
                _buildSchoolDistrictField(),
                const SizedBox(height: 12),
                _buildSchoolNameField(),
                const SizedBox(height: 12),
                _buildAbroadField(),
                const SizedBox(height: 12),
                _buildAddressField(),
                const SizedBox(height: 12),
                _buildRemarksField(),
                const SizedBox(height: 12),
                _buildLeadSourceField(),
                const SizedBox(height: 12),
                _buildPriorityField(),
                const SizedBox(height: 12),
                _buildStatusField(),
                const SizedBox(height: 12),
                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool
                    : (callResultId == '2'))
                  _buildFollowupRow(),
                const SizedBox(height: 12),

                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool ||
                        callResultId == '2' ||
                        callResultId == '3' ||
                        callResultId == '4'
                    : (callResultId == '2' ||
                        callResultId == '3' ||
                        callResultId == '4'))
                  _buildCallResponseField(),
                
              ],
            ),
            // const SizedBox(height: 12),
            // _buildSectionCard(
            //   title: 'Lead Information',
            //   icon: Icons.info_outline,
            //   children: [
            //     // const SizedBox(height: 12),
            //     // _buildStaffField(),
            //     const SizedBox(height: 12),
            //     _buildLeadCategoryField(),
            //     const SizedBox(height: 12),
            //     if (leadSubTypeList?.data?.isNotEmpty ?? false)
            //       _buildSubCategoryField(),
            //     const SizedBox(height: 12),

            //     _buildLeadSourceField(),
            //     const SizedBox(height: 12),
            //     _buildPriorityField(),
            //     // const SizedBox(height: 12),
            //     // // _buildStaffField(),
            //     // // const SizedBox(height: 12),
            //     // _buildStatusField(),
            //     // const SizedBox(height: 12),
            //     // if (leadSettings != null
            //     //     ? leadSettings!.isFollowupRequiredBool
            //     //     : (callResultId == '2'))
            //     //   _buildFollowupRow(),
            //     // const SizedBox(height: 12),

            //     // if (leadSettings != null
            //     //     ? leadSettings!.isFollowupRequiredBool ||
            //     //         callResultId == '2' ||
            //     //         callResultId == '3' ||
            //     //         callResultId == '4'
            //     //     : (callResultId == '2' ||
            //     //         callResultId == '3' ||
            //     //         callResultId == '4'))
            //     //   _buildCallResponseField(),

            //     const SizedBox(height: 12),
            //     _buildRemarksField(),
            //   ],
            // ),
            // const SizedBox(height: 12),
            // _buildSectionCard(
            //   title: 'Product Info',
            //   icon: Icons.shopping_bag_outlined,
            //   children: [
            //     const SizedBox(height: 12),
            //     _buildProductSelection(),
            //     const SizedBox(height: 12),
            //     _buildCostField(),
            //   ],
            // ),
            if (commonDetails!.data.additionalFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Additional Fields',
                icon: Icons.more_horiz,
                children: [
                  const SizedBox(height: 12),
                  ..._buildAdditionalFieldsUI(),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: _buildSubmitButton()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildBranchField() {
    return DropdownButtonFormField<String>(
      value: branch,
      decoration: _inputDecoration('Select Branch', Icons.business),
      items: commonDetails!.data.branch
          .map((b) => DropdownMenuItem(
              value: b.branchId.toString(), child: Text(b.branchName!)))
          .toList(),
      onChanged: (v) => setState(() => branch = v),
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Expanded(
            child: TextFormField(
                controller: clientNameCtrl,
                decoration: _inputDecoration('Customer Name *', Icons.person),
                validator: (v) => v!.isEmpty ? 'Required' : null)),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => contactPermission == 'true'
              ? _selectContact()
              : _showPermissionDialog(),
          child: Container(
              height: 50,
              width: 60,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.contacts, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: contactNoCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration('Contact Number *', Icons.phone).copyWith(
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (c) => setState(() => code = c.phoneCode)),
          child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("+$code"),
                const Icon(Icons.arrow_drop_down)
              ])),
        ),
      ),
      validator: (v) => (v!.isEmpty)
          ? 'Required'
          : (code == '91' && v.length != 10)
              ? '10 digits'
              : null,
    );
  }

  Widget _buildWhatsappField() {
    return TextFormField(
      controller: whatsappNoCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Whatsapp Number',
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (c) => setState(() => whatsappCode = c.phoneCode),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("+$whatsappCode"),
                const Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (whatsappCode == '91' &&
            v != null &&
            v.isNotEmpty &&
            v.length != 10) {
          return 'Enter 10 digit number';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
        controller: emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: _inputDecoration('Email', Icons.email),
        validator: (v) {
          if (v != null && v.isNotEmpty) {
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
              return 'Invalid';
            }
          }
          return null;
        });
  }

  Widget _buildCostField() {
    return TextFormField(
        controller: costCtrl,
        keyboardType: TextInputType.number,
        decoration: _inputDecoration('Cost', Icons.currency_rupee));
  }

  Widget _buildStaffField() {
    return GestureDetector(
        onTap: () => _showStaffDialog(),
        child: AbsorbPointer(
            child: TextFormField(
                controller: assignStaffCtrl,
                decoration: _inputDecoration('Assign Staff', Icons.person))));
  }

  Widget _buildClassField() {
    return GestureDetector(
      onTap: () => _showClassDialog(),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AbsorbPointer(
            child: TextFormField(
              controller: classCtrl,
              decoration: _inputDecoration('Class', Icons.school).copyWith(
                suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),
          ),
          if (selectedClassId.isNotEmpty)
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    selectedClassId = '';
                    selectedClassName = 'Select Class';
                    classCtrl.text = 'Select Class';
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // Widget _buildDivisionField() {
  //   return TextFormField(
  //     controller: divisionCtrl,
  //     decoration: _inputDecoration('Division', Icons.class_outlined),
  //   );
  // }
Widget _buildDivisionField() {
  return TextFormField(
    controller: divisionCtrl,
    textCapitalization: TextCapitalization.characters,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
    ],
    decoration: _inputDecoration('Division', Icons.class_outlined),
  );
}
  bool _isClass11Or12(String className) {
    final name = className.toLowerCase().trim();
    return name.contains('11') ||
        name.contains('12') ||
        name == 'xi' ||
        name == 'xii' ||
        name.contains('plus one') ||
        name.contains('plus two') ||
        name.contains('+1') ||
        name.contains('+2');
  }

  Widget _buildSyllabusField() {
    return GestureDetector(
      onTap: () => _showSyllabusDialog(),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AbsorbPointer(
            child: TextFormField(
              controller: syllabusCtrl,
              decoration: _inputDecoration('Syllabus', Icons.book_outlined).copyWith(
                suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),
          ),
          if (selectedSyllabusId.isNotEmpty)
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    selectedSyllabusId = '';
                    selectedSyllabusValue = 'Select Syllabus';
                    syllabusCtrl.text = 'Select Syllabus';
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreamField() {
    return GestureDetector(
      onTap: () => _showStreamDialog(),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AbsorbPointer(
            child: TextFormField(
              controller: streamCtrl,
              decoration: _inputDecoration('Stream', Icons.merge_type_outlined).copyWith(
                suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),
          ),
          if (selectedStreamName != 'Select Stream')
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    selectedStreamName = 'Select Stream';
                    streamCtrl.text = 'Select Stream';
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSchoolDistrictField() {
    return GestureDetector(
      onTap: () => _showSchoolDistrictDialog(),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AbsorbPointer(
            child: TextFormField(
              controller: schoolDistrictCtrl,
              decoration: _inputDecoration('School District', Icons.map_outlined).copyWith(
                suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),
          ),
          if (selectedSchoolDistrictId.isNotEmpty)
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    selectedSchoolDistrictId = '';
                    selectedSchoolDistrictTitle = 'Select School District';
                    schoolDistrictCtrl.text = 'Select School District';
                    selectedSchoolId = '';
                    selectedSchoolName = 'Select School Name';
                    schoolCtrl.text = 'Select School Name';
                    schoolList.clear();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSchoolNameField() {
    return GestureDetector(
      onTap: () => _showSchoolDialog(),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AbsorbPointer(
            child: TextFormField(
              controller: schoolCtrl,
              decoration:
                  _inputDecoration('School Name', Icons.account_balance_outlined)
                      .copyWith(
                suffixIcon: isSchoolLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),
          ),
          if (!isSchoolLoading && selectedSchoolId.isNotEmpty)
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    selectedSchoolId = '';
                    selectedSchoolName = 'Select School Name';
                    schoolCtrl.text = 'Select School Name';
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAbroadField() {
    return GestureDetector(
      onTap: () => _showAbroadDialog(),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AbsorbPointer(
            child: TextFormField(
              controller: abroadCtrl,
              decoration: _inputDecoration('Abroad', Icons.flight_takeoff).copyWith(
                suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),
          ),
          if (selectedAbroadId.isNotEmpty)
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    selectedAbroadId = '';
                    selectedAbroadName = 'Select Abroad';
                    abroadCtrl.text = 'Select Abroad';
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // Future<void> _fetchSchoolsForDistrict(String districtId) async {
  //   setState(() => isSchoolLoading = true);
  //   final String userToken = (widget.token != null && widget.token!.isNotEmpty)
  //       ? widget.token!
  //       : (await Common.getSharedPref("token") ?? '');
  //   final schoolRes = await HttpService.getSchoolList(userToken, districtId);
  //   setState(() {
  //     isSchoolLoading = false;
  //     schoolList = schoolRes?.data ?? [];
  //   });
  // }

  Future<void> _fetchSchoolsForDistrict(String districtId) async {
    setState(() => isSchoolLoading = true);
    final String userToken = (widget.token != null && widget.token!.isNotEmpty)
        ? widget.token!
        : (await Common.getSharedPref("token") ?? '');
    final schoolRes = await HttpService.getSchoolList(userToken, districtId);
    setState(() {
      isSchoolLoading = false;
      schoolList = schoolRes?.data ?? [];
      if (selectedSchoolId.isNotEmpty && schoolList.isNotEmpty) {
        try {
          final matchedSchool = schoolList.firstWhere(
            (s) => s.id == selectedSchoolId,
          );
          selectedSchoolName = matchedSchool.schoolName;
          schoolCtrl.text = selectedSchoolName;
        } catch (_) {}
      }
    });
  }

  void _showClassDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (classList.isEmpty) {
      Common.toastMessaage('No Class list found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List<ClassItem>.from(classList);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select Class'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search Class',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = classList
                          .where((c) => c.className
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
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.className),
                          onTap: () {
                            setState(() {
                              selectedClassId = item.classId;
                              selectedClassName = item.className;
                              classCtrl.text = item.className;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showSyllabusDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (syllabusList.isEmpty) {
      Common.toastMessaage('No Syllabus found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List<SyllabusItem>.from(syllabusList);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select Syllabus'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search Syllabus',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = syllabusList
                          .where((s) => s.value
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
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.value),
                          onTap: () {
                            setState(() {
                              selectedSyllabusId = item.id;
                              selectedSyllabusValue = item.value;
                              syllabusCtrl.text = item.value;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showStreamDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (streamList.isEmpty) {
      Common.toastMessaage('No Stream found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List<StreamItem>.from(streamList);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select Stream'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search Stream',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = streamList
                          .where((s) => s.streamName
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
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.streamName),
                          onTap: () {
                            setState(() {
                              selectedStreamName = item.streamName;
                              streamCtrl.text = item.streamName;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showSchoolDistrictDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (schoolDistrictList.isEmpty) {
      Common.toastMessaage('No School District found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List<SchoolDistrictItem>.from(schoolDistrictList);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select School District'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search District',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = schoolDistrictList
                          .where((d) => d.districtTitle
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
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.districtTitle),
                          onTap: () {
                            setState(() {
                              selectedSchoolDistrictId = item.districtId;
                              selectedSchoolDistrictTitle = item.districtTitle;
                              schoolDistrictCtrl.text = item.districtTitle;
                              selectedSchoolId = '';
                              selectedSchoolName = 'Select School Name';
                              schoolCtrl.text = 'Select School Name';
                              schoolList.clear();
                            });
                            Navigator.pop(context);
                            _fetchSchoolsForDistrict(item.districtId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showSchoolDialog() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (selectedSchoolDistrictId.isEmpty) {
      Common.toastMessaage('Please select a School District first', Colors.orange);
      return;
    }
    if (schoolList.isEmpty && !isSchoolLoading) {
      await _fetchSchoolsForDistrict(selectedSchoolDistrictId);
    }
    if (isSchoolLoading) {
      Common.toastMessaage('Loading schools...', Colors.orange);
      return;
    }
    if (schoolList.isEmpty) {
      Common.toastMessaage('No schools found for this district', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List<SchoolItem>.from(schoolList);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select School Name'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search School Name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = schoolList
                          .where((s) => s.schoolName
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
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.schoolName),
                          subtitle: item.schoolCode.isNotEmpty
                              ? Text("Code: ${item.schoolCode}")
                              : null,
                          onTap: () {
                            setState(() {
                              selectedSchoolId = item.id;
                              selectedSchoolName = item.schoolName;
                              schoolCtrl.text = item.schoolName;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showAbroadDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (abroadList.isEmpty) {
      Common.toastMessaage('No Abroad locations found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List<AbroadItem>.from(abroadList);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select Abroad'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search Abroad Location',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = abroadList
                          .where((a) => a.placeName
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
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.placeName),
                          onTap: () {
                            setState(() {
                              selectedAbroadId = item.placeId;
                              selectedAbroadName = item.placeName;
                              abroadCtrl.text = item.placeName;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildStatusField() {
    return GestureDetector(
      onTap: () => _showCallResultDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: callResult),
          decoration:
              _inputDecoration('Feadback', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildCallResponseField() {
    return GestureDetector(
      onTap: () => _showCallResponseDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResponseCtrl,
          decoration: _inputDecoration('Call Response *', Icons.add_call),
        ),
      ),
    );
  }

  Widget _buildFollowupRow() {
    return Row(
      children: [
        Expanded(
          flex: checked ? 3 : 4,
          child: TextFormField(
            controller: nextFollowupCtrl,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final now = DateTime.now();
                  final selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );

                  if (selectedDateTime.isAfter(now)) {
                    nextFollowupCtrl.text =
                        "${_formatDate(date.toString().split(' ')[0])} ${time.format(context)}";
                  } else {
                    Common.toastMessaage(
                      'You cannot choose a past time for the follow-up date',
                      Colors.red,
                    );
                  }
                }
              }
            },
            decoration:
                _inputDecoration('Next Followup Date', Icons.calendar_month),
          ),
        ),
        if (checked)
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: timeBeforeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        int val = int.parse(timeBeforeCtrl.text);
                        timeBeforeCtrl.text = (val + 1).toString();
                      },
                      child: const Icon(Icons.arrow_drop_up, size: 20),
                    ),
                    InkWell(
                      onTap: () {
                        int val = int.parse(timeBeforeCtrl.text);
                        timeBeforeCtrl.text =
                            (val > 0 ? val - 1 : 0).toString();
                      },
                      child: const Icon(Icons.arrow_drop_down, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => setState(() => checked = !checked),
          child: Icon(
            Icons.notifications,
            color: checked ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Future<void> _showCallResultDialog() async {
    if (commonDetails?.data == null) {
      Common.toastMessaage("Common details not loaded", Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Stage'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: commonDetails!.data.callResult.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(commonDetails!.data.callResult[i].callResult),
              onTap: () {
                setState(() {
                  callResult = commonDetails!.data.callResult[i].callResult;
                  callResultId =
                      commonDetails!.data.callResult[i].callResultId.toString();
                  callResponse = 'Call Response';
                  callResponseId = '';
                  callResponseCtrl.clear();
                  _fetchLeadExtraSettings(callResultId);
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCallResponseDialog() async {
    if (commonDetails?.data == null) {
      Common.toastMessaage("Common details not loaded", Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Call Response'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) {
                  // Implement filtering if needed, similar to add_leads_new
                },
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: commonDetails!.data.callResponseStatus.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(commonDetails!
                        .data.callResponseStatus[i].callResponse
                        .toString()),
                    onTap: () {
                      setState(() {
                        callResponse = commonDetails!
                            .data.callResponseStatus[i].callResponse
                            .toString();
                        callResponseId = commonDetails!
                            .data.callResponseStatus[i].callResponseId
                            .toString();
                        callResponseCtrl.text = callResponse;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return "";
    final parts = date.split('-');
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

  Widget _buildLeadCategoryField() =>
      Stack(alignment: Alignment.centerRight, children: [
        GestureDetector(
            onTap: () => _showCategoryDialog(),
            child: AbsorbPointer(
                child: TextFormField(
                    controller: leadTypeCtrl,
                    decoration:
                        _inputDecoration('Lead Category', Icons.category)
                            .copyWith(
                      suffixIcon: leadTypeId.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  leadType = 'Lead Category';
                                  leadTypeCtrl.text = leadType;
                                  leadTypeId = '';
                                  leadSubType = 'Sub Category';
                                  leadSubTypeCtrl.text = leadSubType;
                                  leadSubTypeId = '';
                                  leadSubTypeList = null;
                                });
                              },
                            )
                          : null,
                    )))),
        if (createLeadCategory == 'true')
          Positioned(
              right: 5,
              child: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showAddCategoryDialog())),
      ]);

  Widget _buildSubCategoryField() => GestureDetector(
      onTap: () => _showSubCategoryDialog(),
      child: AbsorbPointer(
          child: TextFormField(
              controller: leadSubTypeCtrl,
              decoration: _inputDecoration(
                  'Sub Category', Icons.subdirectory_arrow_right))));

  Widget _buildLeadSourceField() =>
      Stack(alignment: Alignment.centerRight, children: [
        GestureDetector(
            onTap: () => _showSourceDialog(),
            child: AbsorbPointer(
                child: TextFormField(
                    controller: leadSourceCtrl,
                    decoration:
                        _inputDecoration('Lead Source', Icons.source)))),
        if (addLeadSource == 'true')
          Positioned(
              right: 5,
              child: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showAddSourceDialog())),
      ]);

  Widget _buildPriorityField() => GestureDetector(
      onTap: () => _showPriorityDialog(),
      child: AbsorbPointer(
          child: TextFormField(
              controller: priorityCtrl,
              decoration: _inputDecoration('Priority', Icons.priority_high))));

  Widget _buildAddressField() => TextFormField(
      controller: addressCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Address', Icons.home));

  Widget _buildPinCodeField() {
    return TextFormField(
      controller: pinCodeCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('PIN Code', Icons.pin_drop).copyWith(
        suffixIcon: isPinLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : null,
      ),
      onChanged: (v) {
        if (v.length == 6)
          _loadPostOffices(v);
        else
          setState(() {
            postOffices = [];
            selectedPostOffice = null;
          });
      },
    );
  }

  Widget _buildPostOfficeDropdown() {
    return DropdownButtonFormField<PostOffice>(
        value: selectedPostOffice,
        decoration:
            _inputDecoration('Select Post Office', Icons.local_post_office),
        items: postOffices
            .map(
                (po) => DropdownMenuItem(value: po, child: Text(po.name ?? '')))
            .toList(),
        onChanged: (v) => setState(() => selectedPostOffice = v));
  }

  Widget _buildLocationFields() {
    return Column(children: [
      GestureDetector(
          onTap: () => _showStateDialog(),
          child: AbsorbPointer(
              child: TextFormField(
                  controller: stateCtrl,
                  decoration: _inputDecoration('State', Icons.map)))),
      const SizedBox(height: 12),
      if (isDistrictLoading)
        const Center(child: CircularProgressIndicator())
      else if (districtList.isNotEmpty)
        DropdownButtonFormField<DistrictList>(
            value: districtList.any((d) => d.id == DistrictId)
                ? districtList.firstWhere((d) => d.id == DistrictId)
                : null,
            decoration: _inputDecoration('District', Icons.location_city),
            hint: const Text("Select District"),
            items: districtList
                .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                .toList(),
            onChanged: (v) => setState(() {
                  DistrictId = v?.id;
                  districtCtrl.text = v?.name ?? '';
                })),
    ]);
  }

  Widget _buildRemarksField() => TextFormField(
      controller: remarkCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Remarks', Icons.notes));

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Products",
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showProductSelectionDialog(),
                child: AbsorbPointer(
                  child: TextFormField(
                    key: ValueKey(_selectedProducts.length),
                    initialValue: _selectedProducts.isEmpty
                        ? ''
                        : "${_selectedProducts.length} Product(s) Selected",
                    decoration: _inputDecoration(
                        'Select Products', Icons.shopping_cart,
                        isDense: true),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProducts(),
                    )).then((_) {
                  _initializeData();
                });
              },
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedProducts.isNotEmpty)
          Column(
            children: _selectedProducts.map((p) {
              bool isExpanded = _expandedProductId == p.id;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (_expandedProductId == p.id) {
                          _expandedProductId = null;
                        } else {
                          _expandedProductId = p.id;
                          if (p.id != null) {
                            _fetchProductDescription(p.id!);
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${p.productName} - Rs ${p.totalAmount}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2a86c9)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedProducts.remove(p);
                              _updateTotalCost();
                            }),
                            child: const Icon(Icons.cancel,
                                size: 20, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded &&
                      (_descriptionLoading[p.id] == true ||
                          (_productDescriptions[p.id]?.isNotEmpty ?? false)))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin:
                          const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Product Description",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          _descriptionLoading[p.id] == true
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  _productDescriptions[p.id] ?? "",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                        ],
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  void _updateTotalCost() {
    double total = 0;
    for (var p in _selectedProducts) {
      String amountStr = (p.totalAmount ?? '0').replaceAll(',', '');
      total += double.tryParse(amountStr) ?? 0;
    }
    costCtrl.text = total.toStringAsFixed(2);
  }

  List<Widget> _buildAdditionalFieldsUI() {
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      if (_additionalCtrls.length <= i)
        _additionalCtrls.add(TextEditingController());
      final field = commonDetails!.data.additionalFields[i];
      return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: _additionalCtrls[i],
              decoration:
                  _inputDecoration(field.fieldName, Icons.add_box_outlined)));
    });
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: _submitLead,
      child: const Text('Update Lead',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
          {bool isDense = false}) =>
      InputDecoration(
          isDense: isDense,
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12));

  // Dialogs
  void _showStaffDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (_) {
          var search = TextEditingController();
          var list = List.from(commonDetails!.data.staff);
          return StatefulBuilder(
              builder: (c, setS) => AlertDialog(
                    title: const Text('Assign Agent'),
                    content: SizedBox(
                        width: 300,
                        height: 400,
                        child: Column(children: [
                          TextField(
                              controller: search,
                              decoration:
                                  const InputDecoration(hintText: "Search"),
                              onChanged: (v) => setS(() => list = commonDetails!
                                  .data.staff
                                  .where((s) => s.staffName
                                      .toString()
                                      .toLowerCase()
                                      .contains(v.toLowerCase()))
                                  .toList())),
                          Expanded(
                            child: ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (c, i) {
                                final staff = list[i];
                                return ListTile(
                                  title: Text(staff.staffName!),
                                  onTap: () {
                                    setState(() {
                                      assignStaff = staff.staffName!;
                                      assignStaffCtrl.text = assignStaff;
                                      assignStaffId = staff.userId.toString();
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          )
                        ])),
                  ));
        });
  }

  void _showCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (_) {
          var search = TextEditingController();
          var list = List.from(commonDetails!.data.leadCategory);
          return StatefulBuilder(
              builder: (c, setS) => AlertDialog(
                    title: const Text('Lead Category'),
                    content: SizedBox(
                        width: 300,
                        height: 400,
                        child: Column(children: [
                          TextField(
                              controller: search,
                              decoration:
                                  const InputDecoration(hintText: "Search"),
                              onChanged: (v) => setS(() => list = commonDetails!
                                  .data.leadCategory
                                  .where((cat) => cat.leadCategory
                                      .toLowerCase()
                                      .contains(v.toLowerCase()))
                                  .toList())),
                          Expanded(
                              child: ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (c, i) => ListTile(
                                      title: Text(list[i].leadCategory),
                                      onTap: () async {
                                        setState(() {
                                          leadType = list[i].leadCategory;
                                          leadTypeCtrl.text = leadType;
                                          leadTypeId =
                                              list[i].leadCategoryId.toString();
                                          leadSubType = 'Sub Category';
                                          leadSubTypeCtrl.text = leadSubType;
                                          leadSubTypeId = '';
                                        });
                                        Navigator.pop(context);
                                        leadSubTypeList =
                                            await HttpService.leadSubType(
                                                leadTypeId);
                                        setState(() {});
                                      })))
                        ])),
                  ));
        });
  }

  void _showSubCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: const Text('Sub Category'),
            content: SizedBox(
                width: 300,
                height: 400,
                child: ListView.builder(
                    itemCount: leadSubTypeList?.data?.length ?? 0,
                    itemBuilder: (c, i) => ListTile(
                        title: Text(leadSubTypeList!.data![i].leadSubCategory!),
                        onTap: () {
                          setState(() {
                            leadSubType =
                                leadSubTypeList!.data![i].leadSubCategory!;
                            leadSubTypeCtrl.text = leadSubType;
                            leadSubTypeId = leadSubTypeList!
                                .data![i].leadSubCategoryId
                                .toString();
                          });
                          Navigator.pop(context);
                        })))));
  }

  void _showSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (_) {
          var search = TextEditingController();
          var list = List<LeadSource>.from(commonDetails!.data.leadSource);
          return StatefulBuilder(
              builder: (c, setS) => AlertDialog(
                    title: const Text('Lead Source'),
                    content: SizedBox(
                        width: 300,
                        height: 400,
                        child: Column(children: [
                          TextField(
                              controller: search,
                              decoration:
                                  const InputDecoration(hintText: "Search"),
                              onChanged: (v) => setS(() => list = commonDetails!
                                  .data.leadSource
                                  .where((src) => src.leadSource
                                      .toLowerCase()
                                      .contains(v.toLowerCase()))
                                  .toList())),
                          Expanded(
                              child: ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (c, i) {
                                    final src = list[i];
                                    final bool isRestricted = src.isRestricted == "Y";
                                    return ListTile(
                                      title: Text(
                                        isRestricted
                                            ? "${src.leadSource} (Restricted)"
                                            : src.leadSource,
                                        style: TextStyle(
                                          color: isRestricted
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                      ),
                                      enabled: !isRestricted,
                                      onTap: isRestricted
                                          ? null
                                          : () {
                                              setState(() {
                                                leadSource = src.leadSource;
                                                leadSourceCtrl.text = leadSource;
                                                leadSourceId =
                                                    src.leadSourceId.toString();
                                              });
                                              Navigator.pop(context);
                                            },
                                    );
                                  }))
                        ])),
                  ));
        });
  }

  void _showPriorityDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: const Text('Priority'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: commonDetails!.data.priority
                    .map((p) => ListTile(
                        title: Text(p.priority),
                        onTap: () {
                          setState(() {
                            priority = p.priority;
                            priorityCtrl.text = priority;
                            priorityId = p.priorityId.toString();
                          });
                          Navigator.pop(context);
                        }))
                    .toList())));
  }

  void _showStateDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
        context: context,
        builder: (_) {
          var search = TextEditingController();
          var list = List.from(stateDetails!.data);
          return StatefulBuilder(
              builder: (c, setS) => AlertDialog(
                    title: const Text('Select State'),
                    content: SizedBox(
                        width: 300,
                        height: 400,
                        child: Column(children: [
                          TextField(
                              controller: search,
                              decoration:
                                  const InputDecoration(hintText: "Search"),
                              onChanged: (v) => setS(() => list = stateDetails!
                                  .data
                                  .where((s) => s.name
                                      .toLowerCase()
                                      .contains(v.toLowerCase()))
                                  .toList())),
                          Expanded(
                              child: ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (c, i) => ListTile(
                                      title: Text(list[i].name),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          stateCtrl.text = list[i].name;
                                          StateId = list[i].id;
                                        });
                                        _loadDistricts(StateId!);
                                      })))
                        ])),
                  ));
        });
  }

  void _showProductSelectionDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) {
        List<LeadProduct> filteredProducts =
            List.from(productSectionModel?.data ?? []);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Select Products"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "Search Products",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        setDialogState(() {
                          filteredProducts = productSectionModel!.data!
                              .where((p) => (p.productName ?? "")
                                  .toLowerCase()
                                  .contains(v.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (c, i) {
                          final p = filteredProducts[i];
                          final isSelected =
                              _selectedProducts.any((sp) => sp.id == p.id);
                          return CheckboxListTile(
                            title: Text(p.productName ?? ""),
                            subtitle: Text("₹${p.totalAmount}"),
                            value: isSelected,
                            onChanged: (v) {
                              setState(() {
                                if (v!) {
                                  _selectedProducts.add(p);
                                } else {
                                  _selectedProducts
                                      .removeWhere((sp) => sp.id == p.id);
                                }
                                _updateTotalCost();
                              });
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
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadCategoryDialog(
        onSubmit: (name, cost, sub) async {
          final response = await HttpService.postLeadCategory(name, cost, sub);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(widget.token);
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')),
            );
          }
        },
      ),
    );
  }

  void _showAddSourceDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadSourceDialog(
        onSubmit: (name) async {
          final response = await HttpService.postLeadSource(name);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(widget.token);
            setState(() {});
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')),
            );
          }
        },
      ),
    );
  }

  Future<void> _selectContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String number =
            contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
        if (number.startsWith('+'))
          number = number.substring(number.length - 10);
        else if (number.length > 10)
          number = number.substring(number.length - 10);
        setState(() {
          contactNoCtrl.text = number;
          whatsappNoCtrl.text = number;
          clientNameCtrl.text = contact.displayName;
        });
      }
    } else {
      Common.toastMessaage('Permission denied', Colors.red);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Permission',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 15),
                const Text(
                  'Access contacts to manage them efficiently',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Deny',
                          style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Common.saveSharedPref('getContactPermission', 'true');
                        contactPermission = 'true';
                        _selectContact();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Allow'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitLead() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }

    // if (callResultId != '1' && callResponseId.isEmpty) {
    //   Common.toastMessaage('Select call response', Colors.red);
    //   return;
    // }

    bool nextFollowUpRequired =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (nextFollowUpRequired && nextFollowupCtrl.text.isEmpty) {
      Common.toastMessaage('Select Next Followup Date', Colors.red);
      return;
    }
    Common.showProgressDialog(context, "Updating...");

    _additionalValues.clear();
    for (int i = 0; i < commonDetails!.data.additionalFields.length; i++) {
      _additionalValues.add({
        "id": commonDetails!.data.additionalFields[i].id,
        "name": commonDetails!.data.additionalFields[i].fieldName,
        "value": _additionalCtrls[i].text
      });
    }

    final res = await HttpService.editLeads(
      widget.token,
      widget.callMasterId,
      branch,
      clientNameCtrl.text,
      leadTypeId,
      leadSubTypeId,
      contactNoCtrl.text,
      assignStaffId,
      costCtrl.text,
      priorityId,
      addressCtrl.text,
      pinCodeCtrl.text,
      selectedPostOffice?.name ?? "",
      remarkCtrl.text,
      callResultId,
      callResponseId,
      nextFollowupCtrl.text,
      checked ? "1" : "0",
      timeBeforeCtrl.text,
      _additionalValues,
      code,
      leadSourceId,
      stateId: StateId,
      districtId: DistrictId,
      products: _selectedProducts.map((p) => p.id).join(','),
      whatsappNumber: whatsappNoCtrl.text,
      whatsappnumber_country_code: whatsappCode,
      email: emailCtrl.text,
      classId: selectedClassId,
      division: divisionCtrl.text,
      syllabus: selectedSyllabusId.isNotEmpty ? selectedSyllabusValue : '',
      streamName: selectedStreamName == 'Select Stream' ? '' : selectedStreamName,
      schoolDistrictId: selectedSchoolDistrictId,
      schoolId: selectedSchoolId,
      abroadId: selectedAbroadId,
    );

    Navigator.pop(context);
    if (res?.status == true) {
      Common.toastMessaage(res!.message, Colors.green);
      Navigator.pop(context, true);
    } else {
      Common.toastMessaage(res?.message ?? "Update failed", Colors.red);
    }
  }
}
