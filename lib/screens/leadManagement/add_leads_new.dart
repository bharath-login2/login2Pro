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
import 'package:url_launcher/url_launcher.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/getLeadSourceModel.dart';

import '../../models/lead_management/leadProductsModel.dart';
import '../../models/lead_management/productDescriptionModel.dart';
import '../../service/service.dart';
import '../../models/lead_management/leadExtraSettings.dart';
import 'dart:developer';

class AddLeadsNew extends StatefulWidget {
  final String? token;
  final String? page;
  final String? leadMasterId;
  final String? clientName;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? fromDate;
  final String? toDate;
  final bool? editLead;
  final bool? deleteLead;
  final bool? cloudCall;
  final String? countryCode;
  final String? address;
  final String? email;
  final String? cost;
  final String? leadCategoryId;
  final String? leadSubCategoryId;
  final String? priorityId;
  final String? leadSourceId;
  final String? remarks;
  final String? pinCode;
  final String? stateId;
  final String? districtId;
  final String? assignedUserId;
  final String? leadCategory;
  final String? leadSubCategory;
  final String? leadSource;
  final String? priority;
  final String? stateName;
  final String? districtName;
  final String? products;
  final String? whatsappCode;
  final String? assignStaff;
  final String? postOffice;

  AddLeadsNew(this.token,
      {super.key,
      this.page,
      this.leadMasterId,
      this.clientName,
      this.phoneNumber,
      this.whatsappNumber,
      this.fromDate,
      this.toDate,
      this.editLead,
      this.deleteLead,
      this.cloudCall,
      this.countryCode,
      this.address,
      this.email,
      this.cost,
      this.leadCategoryId,
      this.leadSubCategoryId,
      this.priorityId,
      this.leadSourceId,
      this.remarks,
      this.pinCode,
      this.stateId,
      this.districtId,
      this.assignedUserId,
      this.leadCategory,
      this.leadSubCategory,
      this.leadSource,
      this.priority,
      this.stateName,
      this.districtName,
      this.products,
      this.whatsappCode,
      this.assignStaff,
      this.postOffice});

  @override
  State<AddLeadsNew> createState() => _AddLeadsNewState();
}

class _AddLeadsNewState extends State<AddLeadsNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  StateModel? stateDetails;
  CommonConfigureModel? configure;
  LeadSubTypeModel? leadSubTypeList;
  final ScrollController _scrollController = ScrollController();

  // Form Fields
  String leadType = 'Lead Type', leadTypeId = '';
  String leadSubType = 'Lead Sub Category', leadSubTypeId = '';
  String assignStaff = 'Assign Staff', assignStaffId = '';
  String callResult = 'New', callResultId = '1';
  String leadSource = 'Direct Entry', leadSourceId = "1";
  String priority = 'Normal', priorityId = '2';

  final TextEditingController leadTypeCtrl =
      TextEditingController(text: 'Lead Type');
  final TextEditingController leadSubTypeCtrl =
      TextEditingController(text: 'Lead Sub Category');
  final TextEditingController assignStaffCtrl =
      TextEditingController(text: 'Assign Staff');
  final TextEditingController leadSourceCtrl =
      TextEditingController(text: 'Direct Entry');
  final TextEditingController priorityCtrl =
      TextEditingController(text: 'Normal');
  final TextEditingController callResultCtrl =
      TextEditingController(text: 'New');
  String callResponse = 'Call Response', callResponseId = '';

  final TextEditingController clientNameCtrl = TextEditingController();
  final TextEditingController contactNoCtrl = TextEditingController();
  final TextEditingController costCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();
  final TextEditingController nextFollowupCtrl = TextEditingController();
  final TextEditingController timeBeforeCtrl =
      TextEditingController(text: '10');
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController callResponseCtrl = TextEditingController();
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

  // Additional Fields
  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];

  // Data Models
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  LeadProductSectionModel? productSectionModel;
  GetLeadSourceModel? leadSourceModel;

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
    clientNameCtrl.text = widget.clientName ?? "";
    contactNoCtrl.text = _trimPlus91(widget.phoneNumber ?? "");
    whatsappNoCtrl.text = _trimPlus91(widget.whatsappNumber ?? "");
    addressCtrl.text = widget.address ?? "";
    emailCtrl.text = widget.email ?? "";

    // Pre-fill fields from widget parameters
    costCtrl.text = widget.cost ?? "";
    remarkCtrl.text = widget.remarks ?? "";
    pinCodeCtrl.text = widget.pinCode ?? "";
    stateCtrl.text = widget.stateName ?? "";
    districtCtrl.text = widget.districtName ?? "";

    if (widget.leadCategory != null) {
      leadType = widget.leadCategory!;
      leadTypeCtrl.text = widget.leadCategory!;
    }
    if (widget.leadCategoryId != null) {
      leadTypeId = widget.leadCategoryId!;
    }

    if (widget.leadSubCategory != null) {
      leadSubType = widget.leadSubCategory!;
      leadSubTypeCtrl.text = widget.leadSubCategory!;
    }
    if (widget.leadSubCategoryId != null) {
      leadSubTypeId = widget.leadSubCategoryId!;
    }

    if (widget.leadSource != null) {
      leadSource = widget.leadSource!;
      leadSourceCtrl.text = widget.leadSource!;
    }
    if (widget.leadSourceId != null) {
      leadSourceId = widget.leadSourceId!;
    }

    if (widget.priority != null) {
      priority = widget.priority!;
      priorityCtrl.text = widget.priority!;
    }
    if (widget.priorityId != null) {
      priorityId = widget.priorityId!;
    }

    if (widget.assignStaff != null) {
      assignStaff = widget.assignStaff!;
      assignStaffCtrl.text = widget.assignStaff!;
    }
    if (widget.assignedUserId != null) {
      assignStaffId = widget.assignedUserId!;
    }

    if (widget.countryCode != null) {
      code = widget.countryCode!;
    }
    if (widget.whatsappCode != null) {
      whatsappCode = widget.whatsappCode!;
    } else if (widget.countryCode != null) {
      whatsappCode = widget.countryCode!;
    }

    if (widget.stateId != null) {
      StateId = widget.stateId;
    }
    if (widget.districtId != null) {
      DistrictId = widget.districtId;
    }

    _initializeData();
  }

  String _trimPlus91(String mobile) {
    if (mobile.startsWith('+91')) return mobile.substring(3);
    if (mobile.startsWith('91')) return mobile.substring(2);
    return mobile;
  }

  @override
  void dispose() {
    clientNameCtrl.dispose();
    contactNoCtrl.dispose();
    costCtrl.dispose();
    addressCtrl.dispose();
    remarkCtrl.dispose();
    pinCodeCtrl.dispose();
    nextFollowupCtrl.dispose();
    timeBeforeCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    callResponseCtrl.dispose();
    whatsappNoCtrl.dispose();
    emailCtrl.dispose();
    divisionCtrl.dispose();
    classCtrl.dispose();
    syllabusCtrl.dispose();
    streamCtrl.dispose();
    schoolDistrictCtrl.dispose();
    schoolCtrl.dispose();
    abroadCtrl.dispose();
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

    if (assignStaff == 'Assign Staff' || assignStaff.isEmpty) {
      assignStaff = await Common.getSharedPref("name") ?? 'Assign Staff';
    }
    if (assignStaffId.isEmpty) {
      assignStaffId = await Common.getSharedPref("userId") ?? '';
    }

    roleId = await Common.getSharedPref("roleId") ?? '';
    multiBranch = await Common.getSharedPref("multiBranch") ?? '';

    final String userToken = (widget.token != null && widget.token!.isNotEmpty)
        ? widget.token!
        : (await Common.getSharedPref("token") ?? '');

    commonDetails = await HttpService.addLeadCommonData(userToken);
    if (commonDetails != null) {
      if (widget.countryCode == null) {
        code = commonDetails!.data.countryCode.toString();
      }
      configure = await HttpService.configure(userToken);
    }
    stateDetails = await HttpService.getState();
    productSectionModel = await HttpService.leadProductSection();
    leadSourceModel = await HttpService.getLeadSourceAddleads();

    if (widget.products != null &&
        widget.products!.isNotEmpty &&
        productSectionModel?.data != null) {
      final productIds = widget.products!.split(',');
      _selectedProducts = productSectionModel!.data!
          .where((p) => productIds.any((id) => id.trim() == p.id))
          .toList();
    }

    if (leadTypeId.isNotEmpty) {
      leadSubTypeList = await HttpService.leadSubType(leadTypeId);
    }

    if (pinCodeCtrl.text.length == 6) {
      final model = await HttpService.fetchPostOffice(pinCodeCtrl.text);
      postOffices = model?.postOffice ?? [];
      if (postOffices.isNotEmpty && widget.postOffice != null) {
        try {
          selectedPostOffice = postOffices.firstWhere(
            (po) => po.name?.toLowerCase() == widget.postOffice!.toLowerCase(),
          );
        } catch (e) {
          // If not found, keep it null
        }
      }
    }

    if (StateId != null && StateId!.isNotEmpty) {
      final result = await HttpService.getDistrict(StateId!);
      districtList = result?.data ?? [];
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

    setState(() => isLoading = false);
  }

  String _formatDate(String dmy) {
    if (dmy.isEmpty) return dmy;
    final parts = dmy.split("-");
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: Lottie.asset('assets/main/loading.json', width: 150))
          : commonDetails == null || configure == null
              ? _buildNoNetworkView()
              : configure!.data!.isExpired == true
                  ? _buildExpiredView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.editLead == true ? 'Create Lead' : 'Create Lead',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      backgroundColor: const Color(0xFF2a86c9),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildNoNetworkView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/noNetwork.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Text('No Network Found!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          InkWell(
            onTap: _initializeData,
            child: Container(
              width: 120,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text('Try Again',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/main/packageimage.png',
              height: 160, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 15),
          const Text('Package Expired!',
              style: TextStyle(fontSize: 20, color: Colors.red)),
          const SizedBox(height: 10),
          const Text('Please contact support to upgrade your plan'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showUpgradeDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('UPGRADE'),
          ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (multiBranch == 'true' && roleId == '2') _buildBranchField(),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Customer Details',
              icon: Icons.person_outline,
              children: [
                const SizedBox(height: 12),
                _buildPhoneField(),
                const SizedBox(height: 12),
                _buildCustomerRow(),
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
                if (_isClass11Or12(selectedClassName)) ...[
                  _buildStreamField(),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                _buildDivisionField(),
                const SizedBox(height: 12),
                _buildSyllabusField(),
                const SizedBox(height: 12),
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
                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool
                    : (callResultId == '2'))
                const SizedBox(height: 12),
                // if (leadSettings != null
                //     ? leadSettings!.isFollowupRequiredBool ||
                //         callResultId == '2' ||
                //         callResultId == '3' ||
                //         callResultId == '4'
                //     : (callResultId == '2' ||
                //         callResultId == '3' ||
                //         callResultId == '4'))
                //   _buildCallResponseField(),
                if (callResultId != '1') _buildCallResponseField(),
              ],
            ),
            // const SizedBox(height: 12),
            // _buildSectionCard(
            //   title: 'Lead Information',
            //   icon: Icons.info_outline,
            //   children: [
            //     const SizedBox(height: 12),
                
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
            if (commonDetails?.data.additionalFields != null &&
                commonDetails!.data.additionalFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Additional Fields',
                icon: Icons.more_horiz,
                children: [
                  const SizedBox(height: 12),
                  ..._buildAdditionalFields(),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSubmitButton()),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchField() {
    return DropdownButtonFormField<String>(
      value: branch,
      decoration: _inputDecoration('Select Branch', Icons.business),
      items: commonDetails!.data.branch.map((b) {
        return DropdownMenuItem(
          value: b.branchId.toString(),
          child: Text(b.branchName!),
        );
      }).toList(),
      onChanged: (value) async {
        setState(() => branch = value);
        commonDetails =
            await HttpService.addLeadCommonData(widget.token, branchId: branch);
        setState(() {});
      },
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: clientNameCtrl,
            decoration: _inputDecoration('Student Name ', Icons.person),
            // validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        // const SizedBox(width: 10),
        // GestureDetector(
        //   onTap: () => contactPermission == 'true'
        //       ? _selectContact()
        //       : _showPermissionDialog(),
        //   child: Container(
        //     height: 50,
        //     width: 60,
        //     decoration: BoxDecoration(
        //       gradient: const LinearGradient(
        //           colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: const Icon(Icons.contacts, color: Colors.white),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: contactNoCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        label: RichText(
          text: const TextSpan(
            text: 'Contact Number ',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(text: '*', style: TextStyle(color: Colors.red))
            ],
          ),
        ),
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (c) => setState(() => code = c.phoneCode),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text("+$code"), const Icon(Icons.arrow_drop_down)],
            ),
          ),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (v!.isEmpty) return 'Required';
        if (code == '91' && v.length != 10) return '10 digits required';
        return null;
      },
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
            return 'Enter valid email';
          }
        }
        return null;
      },
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: costCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('Cost', Icons.currency_rupee),
    );
  }

  Widget _buildStaffField() {
    return GestureDetector(
      onTap: () => _showStaffDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: assignStaff),
          decoration: _inputDecoration('Assign Agent', Icons.person),
        ),
      ),
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

  Future<void> _fetchSchoolsForDistrict(String districtId) async {
    setState(() => isSchoolLoading = true);
    final String userToken = (widget.token != null && widget.token!.isNotEmpty)
        ? widget.token!
        : (await Common.getSharedPref("token") ?? '');
    final schoolRes = await HttpService.getSchoolList(userToken, districtId);
    setState(() {
      isSchoolLoading = false;
      schoolList = schoolRes?.data ?? [];
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

  Widget _buildLeadCategoryField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: () => _showCategoryDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: leadTypeCtrl,
              decoration: _inputDecoration(
                      'Lead Type', Icons.arrow_drop_down_circle_outlined)
                  .copyWith(
                suffixIcon: leadTypeId.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            leadType = 'Lead Type';
                            leadTypeId = '';
                            leadSubType = 'Lead Sub Category';
                            leadSubTypeId = '';
                            leadSubTypeList = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (createLeadCategory == 'true')
          Positioned(
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddCategoryDialog(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubCategoryField() {
    return GestureDetector(
      onTap: () => _showSubCategoryDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: leadSubTypeCtrl,
          decoration: _inputDecoration(
              'Lead Sub Category', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildLeadSourceField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: () => _showSourceDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: leadSourceCtrl,
              decoration: _inputDecoration(
                  'Lead Source', Icons.arrow_drop_down_circle_outlined),
            ),
          ),
        ),
        if (addLeadSource == 'true')
          Positioned(
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddSourceDialog(),
            ),
          ),
      ],
    );
  }

  Widget _buildPriorityField() {
    return GestureDetector(
      onTap: () => _showPriorityDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: priorityCtrl,
          decoration: _inputDecoration(
              'Priority', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: addressCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Address', Icons.location_on_outlined),
    );
  }

  Widget _buildPinCodeField() {
    return TextFormField(
      controller: pinCodeCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('PIN Code', Icons.pin_drop).copyWith(
        suffixIcon: isPinLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : null,
      ),
      onChanged: (v) async {
        if (v.length == 6) {
          setState(() => isPinLoading = true);
          final model = await HttpService.fetchPostOffice(v);
          setState(() {
            isPinLoading = false;
            postalCodeModel = model;
            postOffices = model?.postOffice ?? [];
          });
        } else {
          setState(() {
            postOffices = [];
            selectedPostOffice = null;
          });
        }
      },
    );
  }

  Widget _buildPostOfficeDropdown() {
    return DropdownButtonFormField<PostOffice>(
      value: selectedPostOffice,
      decoration:
          _inputDecoration('Select Post Office', Icons.local_post_office),
      items: postOffices.map((po) {
        return DropdownMenuItem(value: po, child: Text(po.name ?? ''));
      }).toList(),
      onChanged: (v) => setState(() => selectedPostOffice = v),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showStateDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: stateCtrl,
              decoration: _inputDecoration(
                  'State', Icons.arrow_drop_down_circle_outlined),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isDistrictLoading)
          const Center(child: CircularProgressIndicator())
        else if (districtList.isNotEmpty)
          DropdownButtonFormField<DistrictList>(
            value: districtList.any((d) => d.id == DistrictId)
                ? districtList.firstWhere((d) => d.id == DistrictId)
                : null,
            decoration: _inputDecoration(
                'Select District', Icons.arrow_drop_down_circle_outlined),
            hint: const Text("Select District"),
            items: districtList.map((d) {
              return DropdownMenuItem(value: d, child: Text(d.name));
            }).toList(),
            onChanged: (v) => setState(() {
              DistrictId = v?.id;
              districtCtrl.text = v?.name ?? '';
            }),
          ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: remarkCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Remarks', Icons.list),
    );
  }

  Widget _buildStatusField() {
    return GestureDetector(
      onTap: () => _showCallResultDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: callResult),
          decoration:
              _inputDecoration('Feedback', Icons.arrow_drop_down_circle_outlined),
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

  List<Widget> _buildAdditionalFields() {
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      _additionalCtrls.add(TextEditingController());
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _additionalCtrls[i],
          onSaved: (v) {
            _additionalValues.add({
              "id": commonDetails!.data.additionalFields[i].id,
              "name": commonDetails!.data.additionalFields[i].fieldName,
              "value": v,
            });
          },
          decoration: _inputDecoration(
            commonDetails!.data.additionalFields[i].fieldName,
            Icons.arrow_drop_down_circle,
          ),
        ),
      );
    });
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isTransparent = false,
  }) {
    return Card(
      elevation: isTransparent ? 0 : 1,
      color: isTransparent ? Colors.transparent : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTransparent ? 0 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTransparent)
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF2a86c9), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2a86c9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Create Lead',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showProductPopup(),
                child: AbsorbPointer(
                  child: TextFormField(
                    key: ValueKey(_selectedProducts.length),
                    initialValue: _selectedProducts.isEmpty
                        ? ''
                        : "${_selectedProducts.length} Products Selected",
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
                            onTap: () => _removeProduct(p),
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
                              _removeProduct(p);
                            } else {
                              _addProduct(p);
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

  void _addProduct(LeadProduct p) {
    setState(() {
      if (!_selectedProducts.any((item) => item.id == p.id)) {
        _selectedProducts.add(p);
      }
      _calculateTotalAmount();
    });
  }

  void _removeProduct(LeadProduct p) {
    setState(() {
      _selectedProducts.removeWhere((item) => item.id == p.id);
      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    double total = 0;
    for (var p in _selectedProducts) {
      String amountStr = (p.totalAmount ?? '0').replaceAll(',', '');
      total += double.tryParse(amountStr) ?? 0;
    }
    costCtrl.text = total.toStringAsFixed(2);
  }

  InputDecoration _inputDecoration(String? label, IconData icon,
      {bool isDense = false}) {
    return InputDecoration(
      isDense: isDense,
      label: RichText(
        text: TextSpan(
          text: (label ?? "").replaceAll(' *', ''),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            if (label?.contains('*') == true)
              const TextSpan(
                text: ' *',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 12, vertical: isDense ? 8 : 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2a86c9), width: 1),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  // Dialog Methods
  void _showStaffDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.staff);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Assign Staff'),
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
                      filtered = commonDetails!.data.staff
                          .where((s) => s.staffName
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
                        final staff = filtered[i];
                        return ListTile(
                          title: Text(staff.staffName),
                          onTap: () {
                            assignStaff = staff.staffName;
                            assignStaffId = staff.userId;
                            Navigator.pop(context);
                            setState(() {});
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

  void _showCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.leadCategory);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Lead Type'),
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
                      filtered = commonDetails!.data.leadCategory
                          .where((c) => c.leadCategory
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
                        final cat = filtered[i];
                        return ListTile(
                          title: Text(cat.leadCategory),
                          onTap: () async {
                            leadSubTypeList = await HttpService.leadSubType(
                                cat.leadCategoryId.toString());
                            setState(() {
                              leadType = cat.leadCategory;
                              leadTypeCtrl.text = leadType;
                              leadTypeId = cat.leadCategoryId.toString();
                              leadSubType = 'Lead Sub Category';
                              leadSubTypeCtrl.text = leadSubType;
                              leadSubTypeId = '';
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

  void _showSubCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (leadSubTypeList == null ||
        leadSubTypeList!.data == null ||
        leadSubTypeList!.data!.isEmpty) {
      Common.toastMessaage('No Sub Category found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Lead Sub Category'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: ListView.builder(
              itemCount: leadSubTypeList!.data!.length,
              itemBuilder: (_, i) {
                final sub = leadSubTypeList!.data![i];
                return ListTile(
                  title: Text(sub.leadSubCategory ?? ''),
                  onTap: () {
                    setState(() {
                      leadSubType = sub.leadSubCategory!;
                      leadSubTypeCtrl.text = leadSubType;
                      leadSubTypeId = sub.leadSubCategoryId.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(leadSourceModel?.data ?? []);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Lead Source'),
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
                      filtered = (leadSourceModel?.data ?? [])
                          .where((s) => (s.leadSource ?? "")
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
                        final src = filtered[i];
                        return ListTile(
                          title: Text(src.leadSource ?? ""),
                          onTap: () {
                            setState(() {
                              leadSource = src.leadSource ?? "";
                              leadSourceCtrl.text = leadSource;
                              leadSourceId = src.leadSourceId ?? "";
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

  void _showPriorityDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Priority'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 200,
            child: ListView.builder(
              itemCount: commonDetails!.data.priority.length,
              itemBuilder: (_, i) {
                final p = commonDetails!.data.priority[i];
                return ListTile(
                  title: Text(p.priority),
                  onTap: () {
                    setState(() {
                      priority = p.priority;
                      priorityCtrl.text = priority;
                      priorityId = p.priorityId.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCallResultDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Stages'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: ListView.builder(
              itemCount: commonDetails!.data.callResult.length,
              itemBuilder: (_, i) {
                final cr = commonDetails!.data.callResult[i];
                return ListTile(
                  title: Text(cr.callResult),
                  onTap: () {
                    setState(() {
                      callResult = cr.callResult;
                      callResultCtrl.text = callResult;
                      callResultId = cr.callResultId.toString();
                      if (callResultId != '2') nextFollowupCtrl.clear();
                      _fetchLeadExtraSettings(callResultId);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCallResponseDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.callResponseStatus);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Call Response'),
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
                      filtered = commonDetails!.data.callResponseStatus
                          .where((r) => r.callResponse
                              .toString()
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
                        final r = filtered[i];
                        return ListTile(
                          title: Text(r.callResponse.toString()),
                          onTap: () {
                            setState(() {
                              callResponse = r.callResponse.toString();
                              callResponseId = r.callResponseId.toString();
                              callResponseCtrl.text = callResponse;
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

  void _showStateDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(stateDetails!.data);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select State'),
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
                      filtered = stateDetails!.data
                          .where((s) =>
                              s.name.toLowerCase().contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        return ListTile(
                          title: Text(s.name),
                          onTap: () async {
                            Navigator.pop(context);
                            setState(() {
                              stateCtrl.text = s.name;
                              StateId = s.id;
                              DistrictId = null;
                              districtCtrl.clear();
                              districtList = [];
                              isDistrictLoading = true;
                            });
                            final result = await HttpService.getDistrict(s.id);
                            setState(() {
                              districtList = result?.data ?? [];
                              isDistrictLoading = false;
                              DistrictId = null;
                              districtCtrl.clear();
                            });
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

  void _showAddCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadCategoryDialog(
        onSubmit: (name, cost, sub) async {
          final token = await Common.getSharedPref('token');
          final response = await HttpService.postLeadCategory(name, cost, sub);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(token);
            if (commonDetails != null) {
              try {
                final newCat = commonDetails!.data.leadCategory.firstWhere(
                  (c) => c.leadCategory.toLowerCase() == name.toLowerCase(),
                );
                setState(() {
                  leadType = newCat.leadCategory;
                  leadTypeCtrl.text = leadType;
                  leadTypeId = newCat.leadCategoryId.toString();
                  if (cost.isNotEmpty) {
                    costCtrl.text = cost;
                  }
                  leadSubType = 'Lead Sub Category';
                  leadSubTypeCtrl.text = leadSubType;
                  leadSubTypeId = '';
                });

                // Load sub-categories for the new category
                leadSubTypeList = await HttpService.leadSubType(leadTypeId);

                if (sub != null &&
                    sub.isNotEmpty &&
                    leadSubTypeList?.data != null) {
                  try {
                    final newSub = leadSubTypeList!.data!.firstWhere(
                      (s) =>
                          s.leadSubCategory?.toLowerCase() == sub.toLowerCase(),
                    );
                    setState(() {
                      leadSubType = newSub.leadSubCategory!;
                      leadSubTypeCtrl.text = leadSubType;
                      leadSubTypeId = newSub.leadSubCategoryId.toString();
                    });
                  } catch (e) {
                    // Sub-category not found in refreshed list
                  }
                }
              } catch (e) {
                // Category not found in refreshed list
              }
            }
            setState(() {});
            // Navigator.pop(context); // REMOVED: AddLeadCategoryDialog already pops itself
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Category added'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _showAddSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadSourceDialog(
        onSubmit: (name) async {
          final token = await Common.getSharedPref('token');
          final response = await HttpService.postLeadSource(name);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(token);
            leadSourceModel = await HttpService.getLeadSourceAddleads();
            if (commonDetails != null) {
              try {
                final newSrc = leadSourceModel!.data!.firstWhere(
                  (s) => s.leadSource?.toLowerCase() == name.toLowerCase(),
                );
                setState(() {
                  leadSource = newSrc.leadSource ?? "";
                  leadSourceCtrl.text = leadSource;
                  leadSourceId = newSrc.leadSourceId ?? "";
                });
              } catch (e) {
                // Source not found in refreshed list
              }
            }
            setState(() {});
            // Navigator.pop(context); // REMOVED: AddLeadSourceDialog already pops itself
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')),
            );
          }
        },
      ),
    );
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

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upgrade Package'),
        content: const Text('Contact support to upgrade your plan'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse('tel:${configure!.data!.supportTeamNumber}'),
            ),
            child: const Text('Call'),
          ),
        ],
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
          clientNameCtrl.text = contact.displayName;
        });
      }
    } else {
      Common.toastMessaage('Permission denied', Colors.red);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }
    _formKey.currentState!.save();

    if (multiBranch == 'true' && roleId == '2' && branch == null) {
      Common.toastMessaage('Select Branch', Colors.red);
      return;
    }

    bool nextFollowUpRequired =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (nextFollowUpRequired && nextFollowupCtrl.text.isEmpty) {
      Common.toastMessaage('Select followup date', Colors.red);
      return;
    }

    if (callResultId != '1' && callResponseId.isEmpty) {
      Common.toastMessaage('Select call response', Colors.red);
      return;
    }

    Common.showProgressDialog(context, 'Loading...');
    final check = await HttpService.checkLeadPhoneNumber(
        widget.token, contactNoCtrl.text, code);

    if (check.data == true) {
      Navigator.pop(context);
      _showDuplicateDialog(check.message ?? 'Number already exists. Continue?');
    } else {
      await _submitLead();
    }
  }

  void _showDuplicateDialog(String message) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alert!'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Common.showProgressDialog(context, 'Loading...');
              await _submitLead();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLead() async {
    String productIds =
        _selectedProducts.map((p) => p.id).where((id) => id != null).join(',');

    final result = await HttpService.addLeadsNew(
      widget.token,
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
      selectedPostOffice?.name ?? '',
      remarkCtrl.text,
      callResultId,
      callResponseId,
      nextFollowupCtrl.text,
      _additionalValues,
      code,
      checked,
      timeBeforeCtrl.text,
      leadSourceId,
      stateId: StateId,
      districtId: DistrictId,
      products: productIds,
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
    if (result.status == true) {
      Common.toastMessaage(result.message, Colors.green);
      Navigator.pop(context);
    } else {
      Common.toastMessaage(result.message, Colors.red);
    }
  }
}
