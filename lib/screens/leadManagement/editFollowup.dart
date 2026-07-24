import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/callResultResonModel.dart';
import '../../models/lead_management/editLeadFollowupModel.dart';
import '../../models/lead_management/followupDetailsModel.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../models/lead_management/leadProductsModel.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../service/service.dart';
import '../../models/lead_management/leadExtraSettings.dart';
import 'dart:developer';
import 'package:login2/screens/product_mannagement/add_products.dart';

// ignore: must_be_immutable
class EditFollowup extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String callMasterId;
  String callFollowupId;

  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  int? scrollToIndex;

  EditFollowup(this.token, this.editLead, this.deleteLead, this.cloudCall,
      this.callMasterId, this.callFollowupId,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.scrollToIndex});

  @override
  State<EditFollowup> createState() => _EditFollowupState();
}

class _EditFollowupState extends State<EditFollowup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AddLeadCommonDataModel? commonDetails;
  LeadSubTypeModel? leadSubTypeList;
  CallResultResonModel? callResultReason;

  // Form Fields
  String callResult = 'New';
  String callResultId = '1';
  String callResponse = 'Call Status';
  String callResponseId = '';
  String leadType = 'Lead Category';
  String leadTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String leadSubTypeId = '';
  String callResultReasonName = 'Tag';
  String callResultReasonId = '';

  final TextEditingController cost = TextEditingController();
  final TextEditingController remarks = TextEditingController();
  final TextEditingController calledDate1 = TextEditingController();
  final TextEditingController nextFollowupDate1 = TextEditingController();
  final TextEditingController leadTypeVal = TextEditingController();
  final TextEditingController leadSubTypeVal = TextEditingController();
  final TextEditingController callResultVal = TextEditingController();
  final TextEditingController callResponseVal = TextEditingController();
  final TextEditingController callReasonVal = TextEditingController();
  final TextEditingController whatsappLead = TextEditingController();
  final TextEditingController emailLead = TextEditingController();
  final TextEditingController expectedClosingDate = TextEditingController();
  LeadSettings? leadSettings;
  bool checked = false;
  final TextEditingController timeBefore = TextEditingController(text: '10');
  bool isLoadingSettings = false;

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

  FollowupDetailsModel? followupDetails;
  LeadProductSectionModel? productSectionModel;
  LeadDeatailsModel? leadDetails;
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

  bool? result = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    cost.dispose();
    remarks.dispose();
    calledDate1.dispose();
    nextFollowupDate1.dispose();
    leadTypeVal.dispose();
    leadSubTypeVal.dispose();
    callResultVal.dispose();
    callResponseVal.dispose();
    callReasonVal.dispose();
    whatsappLead.dispose();
    emailLead.dispose();
    timeBefore.dispose();
    for (var ctrl in _additionalCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
  }

  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() => result = true);
      } else {
        setState(() => result = false);
      }
    } else {
      setState(() => result = false);
    }

    if (result == false) {
      setState(() => isLoading = false);
      return;
    }

    try {
      commonDetails = await HttpService.addLeadCommonData(widget.token);
      productSectionModel = await HttpService.leadProductSection();
      leadDetails =
          await HttpService.leadDetails(widget.token, widget.callMasterId);
      followupDetails = await HttpService.followupDetails(
          widget.token, widget.callFollowupId);
print("Expected Closing API: ${followupDetails?.data?.expectedClosingDate}");
      if (followupDetails != null) {
        if (followupDetails!.data!.leadCategoryId.toString().isNotEmpty) {
          leadSubTypeList = await HttpService.leadSubType(
              followupDetails!.data!.leadCategoryId.toString());
        }

        _initializeAdditionalFields();
        _populateFormData();
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _initializeAdditionalFields() {
    if (commonDetails?.data.additionalFields != null) {
      if (_additionalCtrls.length !=
          commonDetails!.data.additionalFields.length) {
        for (var ctrl in _additionalCtrls) {
          ctrl.dispose();
        }
        _additionalCtrls.clear();
        for (int i = 0; i < commonDetails!.data.additionalFields.length; i++) {
          String initialValue = "";
          // If editing, try to find existing value
          if (followupDetails?.data?.additionalFields != null) {
            final fieldId = commonDetails!.data.additionalFields[i].id;
            final existing = followupDetails!.data!.additionalFields!
                .where((f) => f.id == fieldId)
                .toList();
            if (existing.isNotEmpty) {
              initialValue = existing.first.value ?? "";
            }
          }
          _additionalCtrls.add(TextEditingController(text: initialValue));
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
        child: TextFormField(
          controller: _additionalCtrls[i],
          decoration: InputDecoration(
            labelText: commonDetails!.data.additionalFields[i].fieldName,
            prefixIcon: const Icon(Icons.edit_note),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    });
  }

  void _populateFormData() {
    setState(() {
      callResult = followupDetails!.data!.callResult.toString();
      callResultId = followupDetails!.data!.callResultId.toString();
      calledDate1.text = DateFormat('dd-MM-yyyy hh:mm a')
          .format(DateTime.parse(followupDetails!.data!.calledDate.toString()));
      if (followupDetails?.data?.followupDate != null &&
          !followupDetails!.data!.followupDate!.toString().contains("0001")) {
        nextFollowupDate1.text = DateFormat('dd-MM-yyyy hh:mm a').format(
            DateTime.parse(followupDetails!.data!.followupDate.toString()));
      } else {
        nextFollowupDate1.text = "";
      }
       expectedClosingDate.text =
        followupDetails?.data?.expectedClosingDate ?? "";
      leadType = followupDetails!.data!.leadCategory.toString();
      leadTypeId = followupDetails!.data!.leadCategoryId.toString();
      cost.text = followupDetails!.data!.cost.toString();
      remarks.text = followupDetails!.data!.remarks.toString();
      leadSubType = followupDetails!.data!.leadSubCategory.toString();
      leadSubTypeId = followupDetails!.data!.leadSubCategoryId.toString();
      leadTypeVal.text = followupDetails?.data?.leadCategory?.toString() ?? "";
      leadSubTypeVal.text = followupDetails!.data!.leadSubCategory.toString();
      callResultVal.text = followupDetails!.data!.callResult.toString();
      callResponse = followupDetails!.data!.callResponse.toString();
      callResponseId = followupDetails!.data!.callResponseId.toString();
      callResponseVal.text = followupDetails!.data!.callResponse.toString();

      callResultReasonName = followupDetails!.data!.reason.toString();
      callResultReasonId = followupDetails!.data!.reasonId.toString();
      callReasonVal.text = followupDetails!.data!.reason.toString();

      callResultReasonList();
      _fetchLeadExtraSettings(callResultId);

      if (leadDetails != null && leadDetails!.data != null) {
        whatsappLead.text = leadDetails!.data!.whatsaAppNumber ?? '';
        emailLead.text = leadDetails!.data!.emailId ?? '';

        if (productSectionModel != null && productSectionModel!.data != null) {
          String leadProductsRaw = leadDetails!.data!.productsOnAdd ?? '';
          if (leadProductsRaw.isNotEmpty) {
            List<String> assignedProductIds = leadProductsRaw.split(',');
            _selectedProducts = productSectionModel!.data!
                .where(
                    (prod) => assignedProductIds.contains(prod.id.toString()))
                .toList();
          }
        }
      }
      _initializeAdditionalFields();
    });
  }

  editFollowup() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult is List<ConnectivityResult>) {
      if (!connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi)) {
        _showNoNetworkSnackbar();
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    if (callResultId == '') {
      Common.toastMessaage('Choose any Status', Colors.red);
      return;
    }

    if (callResponseId.isEmpty) {
      Common.toastMessaage('Select Call Status', Colors.red);
      return;
    }

    bool nextFollowUpRequired =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (nextFollowUpRequired &&
        (nextFollowupDate1.text.isEmpty ||
            nextFollowupDate1.text.contains("0001"))) {
      Common.toastMessaage('Select Next Followup Date', Colors.red);
      return;
    }

    bool reasonRequired = leadSettings?.isReasonRequiredBool ?? false;
    if (reasonRequired &&
        (callResultReasonId.isEmpty ||
            callResultReasonId == '0' ||
            callResultReasonId == 'null')) {
      Common.toastMessaage('Select Tag', Colors.red);
      return;
    }
// Mandatory fields
if (cost.text.trim().isEmpty ||
    (double.tryParse(cost.text.trim()) ?? 0) <= 0) {
  Common.toastMessaage('Enter Cost', Colors.red);
  return;
}

if (leadTypeId.isEmpty || leadTypeId == "0") {
  Common.toastMessaage('Select Lead Category', Colors.red);
  return;
}

if (remarks.text.trim().isEmpty) {
  Common.toastMessaage('Enter Remarks', Colors.red);
  return;
}
    if (context.mounted) {
      Common.showProgressDialog(context, "Loading..");
    }

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

    EditLeadFollowupModel object1 = await HttpService.editLeadsFollowupUpdated(
        widget.token,
        widget.callFollowupId,
        callResultId,
        nextFollowupDate1.text,
        expectedClosingDate.text,
        cost.text,
        leadTypeId,
        leadSubTypeId,
        remarks.text,
        calledDate1.text,
        widget.callMasterId,
        callResponseId,
        callResultReasonId,
        checked,
        timeBefore.text,
        _additionalValues,
        whatsappLead: whatsappLead.text,
        emailLead: emailLead.text,
        products: _selectedProducts.map((p) => p.id).join(','));

    if (context.mounted) Navigator.pop(context);

    if (object1.status == true) {
      Common.toastMessaage(object1.message, Colors.green);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      Common.toastMessaage(object1.message, Colors.red);
    }
  }

  void _showNoNetworkSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Network Found..Try Again Later..'),
        backgroundColor: Colors.redAccent,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
      ),
    );
  }

  callResultReasonList() async {
    callResultReason =
        await HttpService.callResultReasonLiat(widget.token, callResultId);
    if (commonDetails != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: result == false
          ? _buildNoNetworkView()
          : isLoading
              ? Center(
                  child: Lottie.asset('assets/main/loading.json', width: 150))
              : commonDetails == null
                  ? _buildErrorView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Edit Followup',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      backgroundColor: const Color(0xFF2a86c9),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
          const Text(
            'No Network Found!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: getData,
            child: Container(
              width: 120,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: getData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSectionCard(
              title: 'Call Information',
              icon: Icons.phone_in_talk_outlined,
              children: [
                const SizedBox(height: 12),
                _buildCalledDateField(),
                const SizedBox(height: 12),
                _buildCallResponseField(),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Lead Info',
              icon: Icons.assignment_outlined,
              children: [
                const SizedBox(height: 12),
                _buildCallResultField(),
                const SizedBox(height: 12),
                if (callResultReason?.data?.isNotEmpty ?? false)
                  _buildCallReasonField(),
                const SizedBox(height: 12),
                // if (leadSettings != null
                //     ? leadSettings!.isFollowupRequiredBool
                //     : (callResultId == '2'))
                //   _buildNextFollowupField(),
                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool
                    : (callResultId == '2')) ...[
                  _buildNextFollowupField(),
                  const SizedBox(height: 12),
                  _buildExpectedClosingDateField(),
                ],
                
                const SizedBox(height: 12),
                _buildCostField(),
              ],
            ),
            // const SizedBox(height: 12),
            // _buildSectionCard(
            //   title: 'Product Details',
            //   icon: Icons.inventory_2_outlined,
            //   children: [
            //     // const SizedBox(height: 12),
            //     // _buildProductSelection(),
            //     const SizedBox(height: 12),
            //     _buildLeadCategoryField(),
            //     const SizedBox(height: 12),
            //     if (leadSubTypeList?.data?.isNotEmpty ?? false)
            //       _buildLeadSubCategoryField(),
            //   ],
            // ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Contact Info',
              icon: Icons.contact_phone_outlined,
              children: [
                const SizedBox(height: 12),
                _buildContactRow(),
                const SizedBox(height: 12),
                _buildRemarksField(),
              ],
            ),
            if (commonDetails?.data.additionalFields != null &&
                commonDetails!.data.additionalFields.isNotEmpty)
              const SizedBox(height: 12),
            if (commonDetails?.data.additionalFields != null &&
                commonDetails!.data.additionalFields.isNotEmpty)
              _buildSectionCard(
                title: 'Additional Fields',
                icon: Icons.more_outlined,
                children: [
                  const SizedBox(height: 12),
                  ..._buildAdditionalFieldsUI(),
                ],
              ),
            // const SizedBox(height: 12),
            // _buildSectionCard(
            //   title: 'Category & Sub Category',
            //   icon: Icons.category_outlined,
            //   children: [
            //     const SizedBox(height: 12),
            //     _buildLeadCategoryField(),
            //     const SizedBox(height: 12),
            //     if (leadSubTypeList?.data?.isNotEmpty ?? false)
            //       _buildLeadSubCategoryField(),
            //   ],
            // ),
            // const SizedBox(height: 12),
            // _buildSectionCard(
            //   title: 'Additional Information',
            //   icon: Icons.note_outlined,
            //   children: [
            //     const SizedBox(height: 12),
            //     _buildRemarksField(),
            //   ],
            // ),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2a86c9), size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCalledDateField() {
    return TextFormField(
      controller: calledDate1,
      readOnly: true,
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (selectedDate != null) {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (selectedTime != null) {
            final dateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            calledDate1.text =
                DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
          }
        }
      },
      validator: (v) => v!.isEmpty ? 'Called date is required' : null,
      decoration: _inputDecoration('Called Date *', Icons.calendar_today),
    );
  }

  Widget _buildContactRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: whatsappLead,
            keyboardType: TextInputType.phone,
            decoration:
                _inputDecoration('WhatsApp Number', FontAwesomeIcons.whatsapp)
                    .copyWith(
                        prefixIcon: Icon(FontAwesomeIcons.whatsapp,
                            color: Colors.green, size: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: emailLead,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email ID', Icons.email),
          ),
        ),
      ],
    );
  }
Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (productSectionModel?.data != null) {
                    _showProductSelectionDialog(productSectionModel!.data!);
                  } else {
                    Common.toastMessaage(
                        'Products not loaded yet', Colors.orange);
                  }
                },
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
                  getData();
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
        if (_selectedProducts.isNotEmpty) ...[
          const SizedBox(height: 12),
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
                              _updateCostFromProducts();
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
      ],
    );
  }

  Widget _buildCallResultField() {
    return GestureDetector(
      onTap: () => _showSelectionDialog(
        title: 'Lead Stages',
        items: commonDetails!.data.callResult
            .map((cr) => cr.callResult.toString())
            .toList(),
        onSelected: (index) {
          String newCallResultId =
              commonDetails!.data.callResult[index].callResultId.toString();
          setState(() {
            if (newCallResultId != callResultId) {
              nextFollowupDate1.clear();
            }
            callResultVal.text =
                commonDetails!.data.callResult[index].callResult.toString();
            callResult =
                commonDetails!.data.callResult[index].callResult.toString();
            callResultId = newCallResultId;
            // Clear stage-specific tags when stage changes
            callResultReasonId = '';
            callResultReasonName = 'Tag';
            callReasonVal.clear();

            callResultReasonList();
            _fetchLeadExtraSettings(callResultId);
          });
        },
      ),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResultVal,
          validator: (v) => v!.isEmpty ? 'Lead Stages is required' : null,
          decoration:
              _inputDecoration('Lead Stages *', Icons.assignment_turned_in),
        ),
      ),
    );
  }

  Widget _buildNextFollowupField() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: checked ? 3 : 4,
              child: TextFormField(
                controller: nextFollowupDate1,
                readOnly: true,
                onTap: () async {
                  DateTime now = DateTime.now();
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      final selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      if (selectedDateTime.isAfter(now)) {
                        setState(() {
                          nextFollowupDate1.text =
                              DateFormat('dd-MM-yyyy hh:mm a')
                                  .format(selectedDateTime);

                          // Auto-adjust reminder if needed
                          if (checked && timeBefore.text.isNotEmpty) {
                            int minutes = int.tryParse(timeBefore.text) ?? 10;
                            DateTime reminderTime = selectedDateTime
                                .subtract(Duration(minutes: minutes));
                            if (reminderTime.isBefore(DateTime.now())) {
                              int maxMinutes = selectedDateTime
                                  .difference(DateTime.now())
                                  .inMinutes;
                              if (maxMinutes <= 0) {
                                timeBefore.text = "0";
                              } else {
                                timeBefore.text = maxMinutes.toString();
                              }
                              Common.toastMessaage(
                                  'Reminder time adjusted to ${timeBefore.text} mins before',
                                  Colors.orange);
                            }
                          }
                        });
                      } else {
                        Common.toastMessaage(
                          "You cannot choose a past time for the follow-up date",
                          Colors.red,
                        );
                      }
                    }
                  }
                },
                decoration: _inputDecoration(
                    (leadSettings?.isFollowupRequiredBool ??
                            (callResultId == '2'))
                        ? 'Next Followup Date *'
                        : 'Next Followup Date',
                    Icons.calendar_month),
              ),
            ),
            if (checked)
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: timeBefore,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            int val = int.tryParse(timeBefore.text) ?? 0;
                            timeBefore.text = (val + 1).toString();
                          },
                          child: const Icon(Icons.arrow_drop_up, size: 20),
                        ),
                        InkWell(
                          onTap: () {
                            int val = int.tryParse(timeBefore.text) ?? 0;
                            timeBefore.text =
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
              onTap: () {
                setState(() {
                  checked = !checked;
                  if (checked && nextFollowupDate1.text.isNotEmpty) {
                    try {
                      DateTime dt = DateFormat('dd-MM-yyyy hh:mm a')
                          .parse(nextFollowupDate1.text);
                      int minutes = int.tryParse(timeBefore.text) ?? 10;
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
                        Common.toastMessaage(
                            'Reminder time adjusted to ${timeBefore.text} mins before',
                            Colors.orange);
                      }
                    } catch (e) {
                      // ignore
                    }
                  }
                });
              },
              child: Icon(
                Icons.notifications,
                color: checked ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
Widget _buildExpectedClosingDateField() {
  return TextFormField(
    controller: expectedClosingDate,
    readOnly: true,
    onTap: () async {
      DateTime initialDate = DateTime.now();

      if (expectedClosingDate.text.trim().isNotEmpty) {
        try {
          initialDate = DateFormat('dd-MM-yyyy')
              .parseStrict(expectedClosingDate.text.trim());
        } catch (e) {
          initialDate = DateTime.now();
        }
      }

      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        setState(() {
          expectedClosingDate.text =
              DateFormat('dd-MM-yyyy').format(pickedDate);
        });
      }
    },
    decoration: _inputDecoration(
      'Expected Closing Date *',
      Icons.event_available,
    ),
  );
}
  Widget _buildCallReasonField() {
    return GestureDetector(
      onTap: () => _showSelectionDialog(
        title: 'Tags',
        items: callResultReason!.data!.map((r) => r.reason.toString()).toList(),
        onSelected: (index) {
          setState(() {
            callResultReasonName =
                callResultReason!.data![index].reason.toString();
            callResultReasonId = callResultReason!.data![index].id.toString();
            callReasonVal.text =
                callResultReason!.data![index].reason.toString();
          });
        },
      ),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callReasonVal,
          decoration: _inputDecoration(
              (leadSettings?.isReasonRequiredBool ?? false) ? 'Tags *' : 'Tags',
              Icons.reply_all_sharp),
        ),
      ),
    );
  }

  Widget _buildCallResponseField() {
    return GestureDetector(
      onTap: () => _showSelectionDialog(
        title: 'Call Status',
        items: commonDetails!.data.callResponseStatus
            .map((r) => r.callResponse.toString())
            .toList(),
        onSelected: (index) {
          setState(() {
            callResponseVal.text = commonDetails!
                .data.callResponseStatus[index].callResponse
                .toString();
            callResponse = commonDetails!
                .data.callResponseStatus[index].callResponse
                .toString();
            callResponseId = commonDetails!
                .data.callResponseStatus[index].callResponseId
                .toString();
          });
        },
      ),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResponseVal,
          decoration: _inputDecoration('Call Status *', Icons.add_call),
        ),
      ),
    );
  }

Widget _buildLeadCategoryField() {
  return GestureDetector(
    onTap: () => _showLeadCategoryDialog(),
    child: AbsorbPointer(
      child: TextFormField(
        controller: leadTypeVal,
        decoration: _inputDecoration(
          'Lead Category',
          Icons.category,
        ).copyWith(
          label: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
        ),
      ),
    ),
  );
}

  Widget _buildLeadSubCategoryField() {
    return GestureDetector(
      onTap: () => _showLeadSubCategoryDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: leadSubTypeVal,
          decoration: _inputDecoration('Lead Sub Category', Icons.subtitles),
        ),
      ),
    );
  }

Widget _buildCostField() {
  return TextFormField(
    controller: cost,
    keyboardType: TextInputType.number,
    decoration: _inputDecoration(
      'Cost *',
      Icons.currency_rupee,
    ).copyWith(
      label: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
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
    ),
  );
}

Widget _buildRemarksField() {
  return TextFormField(
    controller: remarks,
    maxLines: 3,
    decoration: _inputDecoration(
      'Remarks *',
      Icons.note,
    ).copyWith(
      alignLabelWithHint: true,
      label: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
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
    ),
  );
}

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: editFollowup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2a86c9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Update Followup',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {bool isDense = false}) {
    return InputDecoration(
      isDense: isDense,
      label: RichText(
        text: TextSpan(
          text: label.replaceAll(' *', ''),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            if (label.contains('*'))
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  void _showSelectionDialog({
    required String title,
    required List<String> items,
    required Function(int) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController searchCtrl = TextEditingController();
        List<String> filteredItems = List.from(items);

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onChanged: (v) {
                        setState(() {
                          filteredItems = items
                              .where((item) =>
                                  item.toLowerCase().contains(v.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (_, i) {
                          return ListTile(
                            title: Text(filteredItems[i]),
                            onTap: () {
                              final originalIndex =
                                  items.indexOf(filteredItems[i]);
                              onSelected(originalIndex);
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
          },
        );
      },
    );
  }

  void _showLeadCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.leadCategory);

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Lead Category'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          filtered = commonDetails!.data.leadCategory
                              .where((c) => c.leadCategory
                                  .toString()
                                  .toLowerCase()
                                  .contains(v.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          return ListTile(
                            title: Text(filtered[i].leadCategory.toString()),
                            onTap: () async {
                              leadSubTypeList = await HttpService.leadSubType(
                                  filtered[i].leadCategoryId.toString());
                              setState(() {
                                leadTypeVal.text =
                                    filtered[i].leadCategory.toString();
                                leadType = filtered[i].leadCategory.toString();
                                leadTypeId =
                                    filtered[i].leadCategoryId.toString();
                                leadSubType = 'Lead Sub Category';
                                leadSubTypeId = '';
                                leadSubTypeVal.text = 'Lead Sub Category';
                              });
                              if (context.mounted) Navigator.pop(context);
                            },
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
      },
    );
  }

  void _showLeadSubCategoryDialog() {
    if (leadSubTypeList == null) return;

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
                return ListTile(
                  title: Text(
                      leadSubTypeList!.data![i].leadSubCategory.toString()),
                  onTap: () {
                    setState(() {
                      leadSubType =
                          leadSubTypeList!.data![i].leadSubCategory.toString();
                      leadSubTypeId = leadSubTypeList!
                          .data![i].leadSubCategoryId
                          .toString();
                      leadSubTypeVal.text = leadSubType;
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

  void _showProductSelectionDialog(List<LeadProduct> products) {
    List<LeadProduct> filteredProducts = List.from(products);
    List<LeadProduct> localSelected = List.from(_selectedProducts);
    TextEditingController searchCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Products'),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          filteredProducts = products
                              .where((p) => (p.productName ?? '')
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final isSelected =
                              localSelected.any((p) => p.id == product.id);

                          return CheckboxListTile(
                            title: Text(product.productName ?? 'Unknown'),
                            subtitle: Text('₹ ${product.totalAmount ?? '0'}'),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  localSelected.add(product);
                                } else {
                                  localSelected
                                      .removeWhere((p) => p.id == product.id);
                                }
                              });
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedProducts = List.from(localSelected);
                      _updateCostFromProducts();
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateCostFromProducts() {
    double total = 0;
    for (var prod in _selectedProducts) {
      if (prod.totalAmount != null && prod.totalAmount!.isNotEmpty) {
        total += double.tryParse(prod.totalAmount!) ?? 0.0;
      }
    }
    setState(() {
      cost.text = total > 0 ? total.toStringAsFixed(2) : "";
    });
  }
}
