// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/addClientsModel.dart';
import '../../../models/clients/branchListModel.dart';
import '../../../models/clients/postalCodeModel.dart';
import '../../../service/service.dart';

class AddClients extends StatefulWidget {
  String token;
  bool createOrder;
  AddClients(this.token, {this.createOrder = false, super.key});
  @override
  State<AddClients> createState() => _AddClientsState();
}

class _AddClientsState extends State<AddClients> {
  TextEditingController clientName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController address3 = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController gstNumber = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController postOffice = TextEditingController();
  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldValue = TextEditingController();
  TextEditingController productDescription = TextEditingController();
  TextEditingController productRate = TextEditingController();
  TextEditingController productQty = TextEditingController(text: "1");
  TextEditingController productTaxPercent = TextEditingController();
  TextEditingController productTaxAmount = TextEditingController();
  TextEditingController productTotalAmount = TextEditingController();
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

  List<Map<String, dynamic>> additionalFields = [];
  bool createOrder = false;
  String invoiceNumber = '';
  String typeDuration = "";
  PostalCodeModel? postal;
  Color paidColor = Colors.black;
  List<Template> filteredTemplates = [];
  String templateId = "";
  String roleId = '';
  String multiBranch = '';
  String customerAddInvoicePermission = '';
    String createRenewalPermission = '';
  String? branch;
  BranchListModel? branchList;
  bool result = true;
  var code = '91';
  bool isExists = false;
  IsCustomerExistModel? isExist;
  bool createRenewal = false;
  bool isDifrent = false;
  dynamic paymentMethod;
  dynamic paymentStatus;
  List<ColloctedStaff> filteredStaff = [];
  String staffId = "";
  String staffName = "Staff";
  List<Product> items = [];
  List<Product> filteredItems = [];
  String selectedTaxType = "Intrastate";
  String productId = "";
  String renProductId = "";
  String productName = "Choose Product";
  String renProductName = "";
  var invoiceDate = DateTime.now();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> renProducts = [];
  double subTotal = 0.00;
  double allTotal = 0.00;
  double totalTaxAmount = 00;
  AddLeadCommonDataModel? commonDetails;
  RenewalDetailslModel? detailsResponse;
  List<TargetGroup> filteredTargets = [];
  List targetGroups = [];
  List targetGroupNames = [];
  StateModel? stateModel;
  List<StateList> stateList = [];
  String? selectedStateId;

  DistrictModel? districtModel;
  List<DistrictList> districtList = [];
  String? selectedDistrictId;
  bool isLoadingState = true;
  bool isLoadingDistrict = false;
  //String? selectedTaxType;

  TextEditingController whatsappNumber = TextEditingController();
  var whatsappCode = '91';
  List<File> idProofFiles = [];
  Set<int> mandatoryFields = {};
  bool isLoadingMandatoryFields = true;

  bool isMandatory(int id) => mandatoryFields.contains(id);

  Widget _buildFieldLabel(String labelText, bool isRequired) {
    if (!isRequired) {
      return Text(
        labelText,
        style: const TextStyle(color: Colors.grey),
      );
    }
    return Text.rich(
      TextSpan(
        text: labelText,
        style: const TextStyle(color: Colors.grey),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchMandatoryFields() async {
    try {
      final fields = await HttpService.getMandatoryFields(widget.token);
      if (mounted) {
        setState(() {
          mandatoryFields = fields.toSet();
          isLoadingMandatoryFields = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMandatoryFields = false;
        });
      }
    }
  }

  Future<void> _pickIdProof() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var f in result.files) {
            if (f.path != null) {
              if (!idProofFiles.any((existing) => existing.path == f.path)) {
                idProofFiles.add(File(f.path!));
              }
            }
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("File pick error: $e");
      }
    }
  }

  Widget _buildIdProofUpload() {
    final totalCount = idProofFiles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel('ID Proof', isMandatory(1)),
            if (totalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a86c9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalCount file${totalCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2a86c9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickIdProof,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: totalCount > 0
                    ? const Color(0xFF2a86c9)
                    : Colors.grey.shade400,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: totalCount > 0 ? const Color(0xFF2a86c9) : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  totalCount > 0
                      ? 'Add More ID Proof Documents'
                      : 'Upload ID Proof (PDF, JPG, PNG, DOC)',
                  style: TextStyle(
                    fontSize: 14,
                    color: totalCount > 0
                        ? const Color(0xFF2a86c9)
                        : Colors.grey.shade700,
                    fontWeight:
                        totalCount > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (idProofFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...idProofFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            final name = file.path.split(Platform.pathSeparator).last;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'File selected',
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        idProofFiles.removeAt(index);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, color: Colors.red, size: 18),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    getStates();
    fetchMandatoryFields();
  }

  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          result = true;
        });
      }
    } else {
      setState(() {
        result = false;
      });
    }
    // if (connectivityResult == ConnectivityResult.mobile ||
    //     connectivityResult == ConnectivityResult.wifi) {
    //   setState(() {
    //     result = true;
    //   });
    // } else {
    //   setState(() {
    //     result = false;
    //   });
    // }
    roleId = await Common.getSharedPref("roleId");
    multiBranch = await Common.getSharedPref("multiBranch");
     customerAddInvoicePermission = await Common.getSharedPref("customerAddInvoicePermission");
       createRenewalPermission = await Common.getSharedPref("createRenewalPermission");
    branchList = await HttpService.getBranchList(widget.token);
    if (branchList != null) {
      setState(() {});
    }
    detailsResponse = await HttpService.getRenewalDetails();
    if (detailsResponse != null) {
      invoiceNumber = detailsResponse!.data.invoiceNumber.toString();
      items = detailsResponse!.data.products;
      filteredTemplates = detailsResponse!.data.template;
      filteredItems.addAll(items);
    }
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    if (commonDetails != null) {
      filteredStaff.addAll(commonDetails!.data.colloctedStaff);
      filteredTargets.addAll(commonDetails!.data.targetGroups);
    }
  }

  Future<void> getStates() async {
    setState(() => isLoadingState = true);
    final response = await HttpService.getState();
    if (response != null && response.status == true) {
      setState(() {
        stateList = response.data;
        isLoadingState = false;
      });
    } else {
      setState(() => isLoadingState = false);
    }
  }

  Future<void> getDistricts(String stateId) async {
    setState(() {
      isLoadingDistrict = true;
      districtList = [];
      selectedDistrictId = null;
    });

    final response = await HttpService.getDistrict(stateId);
    if (response != null && response.status == true) {
      setState(() {
        districtList = response.data;
        isLoadingDistrict = false;
      });
    } else {
      setState(() => isLoadingDistrict = false);
    }
  }

  isCustomerExists() async {
    isExist = await HttpService.isCustomerExists("", phoneNumber.text);
    if (isExist != null) {
      isExists = isExist!.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            appBar: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
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
                          const SizedBox(
                            width: 25,
                          ),
                          const Text(
                            'Add Customer',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: branchList != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          multiBranch == 'true' && roleId == '2'
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: DropdownButtonFormField(
                                    value: branch,
                                    onChanged: (value) async {
                                      setState(() {
                                        branch = value.toString();
                                      });
                                    },
                                    items: branchList!.data!.map((data) {
                                      return DropdownMenuItem<String>(
                                        value: data.branchId.toString(),
                                        child: Text(
                                          data.branchName.toString(),
                                        ),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        // Custom border
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      labelText: 'Select Branch',
                                      prefixIcon: const Icon(
                                          Icons.arrow_drop_down_circle_outlined,
                                          color: Colors.grey),
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      contentPadding: const EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          TextFormField(
                            controller: clientName,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('Customer Name', true),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    const Icon(Icons.person, color: Colors.grey),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            onChanged: (value) {
                              if (value.length == 10) {
                                isCustomerExists();
                              }
                            },
                            controller: phoneNumber,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('Phone Number', true),
                                fillColor: Colors.white,
                                filled: true,
                                prefix: GestureDetector(
                                  onTap: () {
                                    showCountryPicker(
                                      context: context,
                                      searchAutofocus: false,
                                      showPhoneCode: true,
                                      // optional. Shows phone code before the country name.
                                      onSelect: (Country country) {
                                        setState(() {
                                          code = country.phoneCode;
                                        });
                                        // flag = country.flagEmoji;
                                        // print(countryPickerController.code.value);
                                        // print(flag);
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: SizedBox(
                                      // color: Colors.blue,
                                      width: 70,
                                      // width: MediaQuery.of(context).size.width/3.5,
                                      child: Row(children: [
                                        Text("+$code"),
                                        const Icon(Icons.arrow_drop_down),
                                      ]),
                                    ),
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: whatsappNumber,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('WhatsApp Number', isMandatory(2)),
                                fillColor: Colors.white,
                                filled: true,
                                prefix: GestureDetector(
                                  onTap: () {
                                    showCountryPicker(
                                      context: context,
                                      searchAutofocus: false,
                                      showPhoneCode: true,
                                      onSelect: (Country country) {
                                        setState(() {
                                          whatsappCode = country.phoneCode;
                                        });
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: SizedBox(
                                      width: 70,
                                      child: Row(children: [
                                        Text("+$whatsappCode"),
                                        const Icon(Icons.arrow_drop_down),
                                      ]),
                                    ),
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: email,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('Email', isMandatory(3)),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    const Icon(Icons.email, color: Colors.grey),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: address1,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('Address 1', true),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    const Icon(Icons.location_on, color: Colors.grey),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: address2,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('Address 2', isMandatory(7)),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    const Icon(Icons.location_on, color: Colors.grey),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: address3,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('Address 3', false),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    const Icon(Icons.location_on, color: Colors.grey),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: pinCode,
                            onChanged: (value) async {
                              if (value.length >= 6) {
                                postal =
                                    await HttpService.fetchPostOffice(value);
                                setState(() {});
                              } else {
                                postal = null;
                                postOffice.clear();
                                setState(() {});
                              }
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                label: _buildFieldLabel('Pin Code', isMandatory(8)),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    const Icon(Icons.pin_drop, color: Colors.grey),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey)),
                          ),
                           SizedBox(
                            height: 10,
                          ),
                          postal != null
                              ? TextFormField(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              scrollable: true,
                                              title: const Text('Post Office'),
                                              content: postal!.postOffice !=
                                                      null
                                                  ? SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .32,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .8,
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: postal!
                                                            .postOffice!.length,
                                                        itemBuilder:
                                                            (context, ind) {
                                                          return InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                postOffice
                                                                        .text =
                                                                    postal!
                                                                        .postOffice![
                                                                            ind]
                                                                        .name
                                                                        .toString();
                                                                Navigator.pop(
                                                                    context,
                                                                    true);
                                                              });
                                                            },
                                                            child: SizedBox(
                                                              height: 50,
                                                              child: Text(
                                                                postal!
                                                                    .postOffice![
                                                                        ind]
                                                                    .name
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : const Text(
                                                      'No Post Office Found'));
                                        });
                                  },
                                  maxLines: 1,
                                  readOnly: true,
                                  controller: postOffice,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      labelText: 'Post Office',
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: Icon(
                                          Icons.arrow_drop_down_circle_outlined,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.grey)),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isLoadingState
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : DropdownButtonFormField<String>(
                                      value: selectedStateId,
                                      hint: _buildFieldLabel("Select State", isMandatory(4)),
                                      decoration: InputDecoration(
                                        label: _buildFieldLabel("State", isMandatory(4)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                      ),
                                      items: stateList.map((state) {
                                        return DropdownMenuItem<String>(
                                          value: state.id,
                                          child: Text(state.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStateId = value;
                                        });
                                        if (value != null) getDistricts(value);
                                      },
                                    ),
                              if (isLoadingDistrict)
                                const Center(child: CircularProgressIndicator())
                              else if (districtList.isEmpty)
                                const SizedBox(
                                  height: 10,
                                )
                              else
                                const SizedBox(
                                  height: 10,
                                ),
                              DropdownButtonFormField<String>(
                                value: selectedDistrictId,
                                hint: _buildFieldLabel("Choose District", isMandatory(4)),
                                decoration: InputDecoration(
                                  label: _buildFieldLabel("District", isMandatory(4)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                items: districtList.map((district) {
                                  return DropdownMenuItem<String>(
                                    value: district.id,
                                    child: Text(district.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDistrictId = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          // const SizedBox(height: 10),
                          // DropdownButtonFormField<String>(
                          //   value: selectedTaxType,
                          //   hint: const Text("Select Tax Type"),
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     contentPadding: const EdgeInsets.symmetric(
                          //       horizontal: 12,
                          //       vertical: 8,
                          //     ),
                          //   ),
                          //   items: const [
                          //     DropdownMenuItem(
                          //       value: "Interstate",
                          //       child: Text("Other State"),
                          //     ),
                          //     DropdownMenuItem(
                          //       value: "Intrastate",
                          //       child: Text("State"),
                          //     ),
                          //   ],
                          //   onChanged: (value) {
                          //     setState(() {
                          //       selectedTaxType = value!;
                          //     });
                          //   },
                          // ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Select Tax Type",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 5, 5, 5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    RadioListTile<String>(
                                      title: const Text("Intrastate"),
                                      value: "Intrastate",
                                      groupValue: selectedTaxType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedTaxType = value!;
                                        });
                                      },
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    RadioListTile<String>(
                                      title: const Text("Other State"),
                                      value: "Interstate",
                                      groupValue: selectedTaxType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedTaxType = value!;
                                        });
                                      },
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                         
                          const SizedBox(
                            height: 15,
                          ),
                          _buildIdProofUpload(),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: gstNumber,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'GST Number',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: remarks,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Remark',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.arrow_right, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          Visibility(
                            visible: additionalFields.isNotEmpty ? true : false,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Table(
                                      columnWidths: {
                                        0: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.4), // Using 10%
                                        1: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.4),
                                        2: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.10), // Using 30%
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(1),
                                            color: const Color(0xFFece9fd),
                                          ),
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Field',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Value',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center),
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
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: additionalFields.length,
                                itemBuilder: (context, index) {
                                  Color color = index % 2 == 0
                                      ? const Color(0xFFF3F3F3)
                                      : const Color(0xFFece9fd);
                                  return Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Table(
                                      columnWidths: {
                                        0: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.4), // Using 10%
                                        1: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.4),
                                        2: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.10), // Using 30%
                                      },
                                      children: [
                                        // Each TableRow represents a row in the Table
                                        TableRow(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(1),
                                            color: color,
                                          ),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                additionalFields[index]
                                                    ['field_name'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                additionalFields[index]
                                                    ['field_value'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                additionalFields.removeWhere(
                                                  (item) => mapEquals(
                                                      item,
                                                      ({
                                                        "field_name":
                                                            additionalFields[
                                                                    index]
                                                                ['field_name'],
                                                        "field_value":
                                                            additionalFields[
                                                                    index]
                                                                ['field_value'],
                                                      })),
                                                );
                                                setState(() {});
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Additional Fields',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'If you require extra fields on the customer creation form, kindly generate the fields here.',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      barrierColor:
                                          Colors.white.withOpacity(.4),
                                      context: context,
                                      builder: (context) {
                                        return Material(
                                          type: MaterialType.transparency,
                                          color: Colors.grey.shade200,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                      offset: Offset(1, 1),
                                                    )
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                height: 280,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    const Text(
                                                      'Additional Fields',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SizedBox(
                                                        child: TextFormField(
                                                          controller: fieldName,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          decoration: const InputDecoration(
                                                              hintText:
                                                                  'Field Name',
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          10),
                                                              border:
                                                                  OutlineInputBorder()),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SizedBox(
                                                        child: TextFormField(
                                                          controller:
                                                              fieldValue,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          decoration: const InputDecoration(
                                                              hintText: 'Value',
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          10),
                                                              border:
                                                                  OutlineInputBorder()),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (fieldName
                                                            .text.isEmpty) {
                                                          Common.toastMessaage(
                                                              'Enter Field Name',
                                                              Colors.red);
                                                        } else if (fieldValue
                                                            .text.isEmpty) {
                                                          Common.toastMessaage(
                                                              'Enter Field Value',
                                                              Colors.red);
                                                        } else {
                                                          additionalFields.add({
                                                            // "product_name":productName.text,
                                                            "field_name":
                                                                fieldName.text,
                                                            "field_value":
                                                                fieldValue.text,
                                                          });
                                                          fieldName.clear();
                                                          fieldValue.clear();
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 10,
                                                                    left: 25,
                                                                    right: 25),
                                                            child: Text(
                                                              'Add',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          )),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border:
                                              Border.all(color: Colors.green)),
                                      child: const Padding(
                                        padding: EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 5,
                                            bottom: 5),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                      )),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: widget.createOrder,
                            child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Create Order'),
                                value: createOrder,
                                onChanged: (bool? value) {
                                  setState(() {
                                    createOrder = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading),
                          ),
                          Visibility(
                            visible: createOrder &&
                                customerAddInvoicePermission == "true",
                                  
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Invoice Number :',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      Text(invoiceNumber,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Invoice Date : ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      SizedBox(
                                        width: 100,
                                        height: 50,
                                        child: Center(
                                          child: DateTimePicker(
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            initialValue:
                                                invoiceDate.toString(),
                                            type: DateTimePickerType.date,
                                            firstDate: DateTime(1995),
                                            lastDate: DateTime.now()
                                                .add(const Duration(days: 365)),
                                            // This will add one year from current date
                                            validator: (value) {
                                              return null;
                                            },
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                setState(() {
                                                  invoiceDate =
                                                      DateTime.parse(value);
                                                  startDate.text =
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(invoiceDate);
                                                  final endValue =
                                                      invoiceDate.add(Duration(
                                                          days: int.parse(
                                                              typeDuration)));
                                                  endDate.text =
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(endValue);
                                                });
                                              }
                                            },
                                            // We can also use onSaved
                                            onSaved: (value) {
                                              if (value!.isNotEmpty) {
                                                invoiceDate = value as DateTime;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () async {
                                        addProductsDialog(context).then((_) {
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: const Padding(
                                            padding: EdgeInsets.only(
                                                top: 5,
                                                bottom: 5,
                                                left: 10,
                                                right: 10),
                                            child: Text(
                                              '+ Add Product',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Table(
                                        columnWidths: {
                                          0: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2), // Using 10%
                                          1: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.16), // Using 30%
                                          2: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.10),
                                          3: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.16), // Using 20%
                                          4: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.20),
                                          5: FixedColumnWidth(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.10),
                                        },
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              color: const Color(0xFFece9fd),
                                            ),
                                            children: const [
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Product',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Rate',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Qty',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text('Tax',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Amount',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text(' ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                products.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "No Products !",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: products.length,
                                          itemBuilder: (context, index) {
                                            Color color = index % 2 == 0
                                                ? const Color(0xFFF3F3F3)
                                                : const Color(0xFFece9fd);
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Table(
                                                columnWidths: {
                                                  0: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.2), // Using 10%
                                                  1: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.16), // Using 30%
                                                  2: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.10),
                                                  3: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.16), // Using 20%
                                                  4: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.20),
                                                  5: FixedColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.10),
                                                },
                                                children: [
                                                  // Each TableRow represents a row in the Table
                                                  TableRow(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1),
                                                      color: color,
                                                    ),
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['product_name'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['product_rate'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['quantity'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index][
                                                              'total_tax_amount'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          products[index]
                                                              ['total_amount'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          subTotal = subTotal -
                                                              double.parse(
                                                                products[index][
                                                                    'total_amount'],
                                                              );
                                                          totalTaxAmount = totalTaxAmount -
                                                              double.parse(products[
                                                                          index]
                                                                      [
                                                                      'total_tax_amount']) *
                                                                  double.parse(products[
                                                                          index]
                                                                      [
                                                                      'quantity']);

                                                          allTotal = subTotal +
                                                              double.parse(shippingCharge
                                                                          .text ==
                                                                      ''
                                                                  ? '0'
                                                                  : shippingCharge
                                                                      .text) -
                                                              double.parse(
                                                                  discount.text ==
                                                                          ''
                                                                      ? '0'
                                                                      : discount
                                                                          .text);
                                                          paidAmount.text =
                                                              allTotal
                                                                  .toString();
                                                          // products.removeWhere(
                                                          //   (item) => mapEquals(
                                                          //       item,
                                                          //       ({
                                                          //         "product_name":
                                                          //             products[
                                                          //                     index]
                                                          //                 [
                                                          //                 'product_name'],
                                                          //         "product_id":
                                                          //             products[
                                                          //                     index]
                                                          //                 [
                                                          //                 'product_id'],
                                                          //         "description":
                                                          //             products[
                                                          //                     index]
                                                          //                 [
                                                          //                 'description'],
                                                          //         "product_rate":
                                                          //             products[
                                                          //                     index]
                                                          //                 [
                                                          //                 'product_rate'],
                                                          //         "quantity": products[
                                                          //                 index]
                                                          //             [
                                                          //             'quantity'],
                                                          //         "tax_percent":
                                                          //             products[
                                                          //                     index]
                                                          //                 [
                                                          //                 'tax_percent'],
                                                          //         "total_tax_amount":
                                                          //             products[
                                                          //                     index]
                                                          //                 [
                                                          //                 'total_tax_amount'],
                                                          //         "total_amount":
                                                          //             products[
                                                          //                     index]
                                                          //                 [
                                                          //                 'total_amount'],
                                                          //       })),
                                                          // );
                                                          products
                                                              .removeAt(index);
                                                          if (renProducts
                                                              .isNotEmpty) {
                                                            renProducts
                                                                .removeAt(
                                                                    index);
                                                          }
                                                          if (products
                                                              .isEmpty) {
                                                            discount.clear();
                                                            shippingCharge
                                                                .clear();
                                                            allTotal = 0.00;
                                                            paidAmount.text =
                                                                allTotal
                                                                    .toString();
                                                          }
                                                          setState(() {});
                                                        },
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Sub Total :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Text(subTotal
                                                    .toStringAsFixed(2)),
                                              ))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Tax Amount:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Text(totalTaxAmount
                                                    .toStringAsFixed(2)),
                                              ))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Discount:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 35,
                                            child: TextFormField(
                                              onChanged: (value) {
                                                if (products.isNotEmpty) {
                                                  if (value == '') {
                                                    value = '0';
                                                  }
                                                  allTotal = subTotal +
                                                      double.parse(
                                                          shippingCharge.text ==
                                                                  ''
                                                              ? '0'
                                                              : shippingCharge
                                                                  .text) -
                                                      double.parse(value);
                                                  paidAmount.text =
                                                      allTotal.toString();
                                                  setState(() {});
                                                } else {
                                                  discount.clear();
                                                  Common.toastMessaage(
                                                      'choose at least one product',
                                                      Colors.red);
                                                }
                                              },
                                              controller: discount,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  border:
                                                      const OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  //labelText: 'Invoice Number',
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  // border: const OutlineInputBorder(),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Shipping Charge:'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 35,
                                            child: TextFormField(
                                              onChanged: (value) {
                                                if (products.isNotEmpty) {
                                                  if (value == '') {
                                                    value = '0';
                                                  }
                                                  allTotal = subTotal +
                                                      double.parse(value) -
                                                      double.parse(
                                                          discount.text == ''
                                                              ? '0'
                                                              : discount.text);
                                                  paidAmount.text =
                                                      allTotal.toString();

                                                  setState(() {});
                                                } else {
                                                  shippingCharge.clear();
                                                  Common.toastMessaage(
                                                      'choose at least one product',
                                                      Colors.red);
                                                }
                                              },
                                              controller: shippingCharge,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  //labelText: 'Invoice Number',
                                                  fillColor: Colors.grey[300],
                                                  filled: true,
                                                  border:
                                                      const OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Total :',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              allTotal.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Pay Status * :'),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 35,
                                            child: FormField<String>(
                                              builder: (FormFieldState<String>
                                                  state) {
                                                return Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5))),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      isExpanded: true,
                                                      hint: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20),
                                                        child: Text('Status'),
                                                      ),
                                                      value: paymentStatus,
                                                      items: detailsResponse!
                                                          .data.paymentStatus
                                                          .map((data) {
                                                        return DropdownMenuItem(
                                                          value: data
                                                              .paymentStatus
                                                              .toString(),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                              child: Text(
                                                                data.displaySts
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          paymentStatus =
                                                              newValue;
                                                          if (paymentStatus ==
                                                              "paid") {
                                                            paidAmount.text =
                                                                allTotal
                                                                    .toString();
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (paymentStatus != "unpaid")
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text('Paid Amount * :'),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              height: 35,
                                              child: TextFormField(
                                                readOnly:
                                                    paymentStatus == "paid",
                                                style:
                                                    TextStyle(color: paidColor),
                                                onChanged: (val) {
                                                  if (double.parse(val) >
                                                      subTotal) {
                                                    Common.toastMessaage(
                                                        'Enter valid amount',
                                                        Colors.red);
                                                    paidColor = Colors.red;
                                                  } else {
                                                    paidColor = Colors.black;
                                                  }
                                                  setState(() {});
                                                },
                                                controller: paidAmount,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            top: 2,
                                                            bottom: 2),
                                                    //labelText: 'Invoice Number',
                                                    fillColor: Colors.grey[300],
                                                    filled: true,
                                                    border:
                                                        const OutlineInputBorder(
                                                      // width: 0.0 produces a thin "hairline" border
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    labelStyle: const TextStyle(
                                                        color: Colors.black)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: paymentStatus == "paid" ||
                                          paymentStatus == "partial",
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text('Pay Method * :'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: 35,
                                                  child: FormField<String>(
                                                    builder:
                                                        (FormFieldState<String>
                                                            state) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                            isExpanded: true,
                                                            hint: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20),
                                                              child: Text(
                                                                  'Method'),
                                                            ),
                                                            value:
                                                                paymentMethod,
                                                            items: detailsResponse!
                                                                .data
                                                                .paymentMethods
                                                                .map((data) {
                                                              return DropdownMenuItem(
                                                                value: data.id
                                                                    .toString(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child: Text(
                                                                      data.name
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            onChanged:
                                                                (newValue) {
                                                              setState(() {
                                                                paymentMethod =
                                                                    newValue;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text('Account Head * :'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: 35,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      collectedStaffDialog(
                                                          context);
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Center(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 16.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.38,
                                                                child: Text(
                                                                  staffName,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )),
                                                            Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Target Group :',
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.55,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      targetGroupDialog(
                                                          context);
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      child: targetGroups
                                                              .isEmpty
                                                          ? const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      top: 15,
                                                                      bottom:
                                                                          10),
                                                              child: Text(
                                                                  'Target Group'))
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          40),
                                                              child: SizedBox(
                                                                height: 35,
                                                                child: ListView
                                                                    .builder(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemCount:
                                                                      targetGroupNames
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          i) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Container(
                                                                              height: 35,
                                                                              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0), color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6))),
                                                                              child: Center(
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(10),
                                                                                      child: Text(
                                                                                        targetGroupNames[i],
                                                                                        style: const TextStyle(
                                                                                          color: Colors.black,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text('Please Confirm'),
                                                                                        content: const Text('Are you sure to Remove this Number?'),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                              onPressed: () {
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                              child: const Text('No')),
                                                                                          TextButton(
                                                                                              onPressed: () async {
                                                                                                setState(() {
                                                                                                  targetGroupNames.remove(targetGroupNames[i]);
                                                                                                  targetGroups.remove(targetGroups[i]);
                                                                                                });
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                              child: const Text('Yes')),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                              },
                                                                              child: Container(
                                                                                height: 35,
                                                                                width: 30,
                                                                                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0), color: Colors.grey.shade100, borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6))),
                                                                                child: const Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.red,
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
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          if (createOrder && createRenewalPermission =="true")
                            CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Create Renewal'),
                                value: createRenewal,
                                onChanged: (bool? value) {
                                  setState(() {
                                    createRenewal = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading),
                          Visibility(
                              visible: createRenewal &&
                                  createOrder &&
                                  createRenewalPermission =="true",
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: startDate,
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? selectedValue =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            setState(() {
                                              startDate.text =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(selectedValue!);
                                              final endValue =
                                                  selectedValue.add(Duration(
                                                      days: int.parse(
                                                          typeDuration)));
                                              endDate.text =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(endValue);
                                            });
                                          },
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Select Start Date";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.all(8),
                                              labelText: 'Start Date *',
                                              prefixIcon: Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          onTap: () async {
                                            DateTime? selectedEndDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            endDate.text =
                                                DateFormat('dd-MM-yyyy')
                                                    .format(selectedEndDate!);
                                          },
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Select End Date";
                                            }
                                            return null;
                                          },
                                          readOnly: true,
                                          controller: endDate,
                                          decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.all(8),
                                              labelText: 'End Date *',
                                              prefixIcon: Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
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
                                        prefixIcon: Icon(Icons.notifications,
                                            color: Colors.grey),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text(
                                          'Is renewal amount is diffrent?'),
                                      value:
                                          isDifrent, // initial value of the checkbox
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isDifrent = value!;
                                        });
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading),
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
                                            columnWidths: {
                                              0: FixedColumnWidth(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2), // Using 10%
                                              1: FixedColumnWidth(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.16), // Using 30%
                                              2: FixedColumnWidth(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.10),
                                              3: FixedColumnWidth(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.16), // Using 20%
                                              4: FixedColumnWidth(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.20),
                                              5: FixedColumnWidth(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.10),
                                            },
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(1),
                                                  color:
                                                      const Color(0xFFece9fd),
                                                ),
                                                children: const [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text('Product',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text('Rate',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text('Qty',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Text('Tax',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Amount',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Text(' ',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center),
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
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              )
                                            : SingleChildScrollView(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  itemCount: renProducts.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    Color color = index % 2 == 0
                                                        ? const Color(
                                                            0xFFF3F3F3)
                                                        : const Color(
                                                            0xFFece9fd);
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      child: Table(
                                                        columnWidths: {
                                                          0: FixedColumnWidth(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.2), // Using 10%
                                                          1: FixedColumnWidth(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.16), // Using 30%
                                                          2: FixedColumnWidth(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.10),
                                                          3: FixedColumnWidth(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.16), // Using 20%
                                                          4: FixedColumnWidth(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.20),
                                                          5: FixedColumnWidth(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.10),
                                                        },
                                                        children: [
                                                          // Each TableRow represents a row in the Table
                                                          TableRow(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1),
                                                              color: color,
                                                            ),
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  renProducts[
                                                                          index]
                                                                      [
                                                                      'product_name'],
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  renProducts[
                                                                          index]
                                                                      [
                                                                      'product_rate'],
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  renProducts[
                                                                          index]
                                                                      [
                                                                      'quantity'],
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  renProducts[
                                                                          index]
                                                                      [
                                                                      'total_tax_amount'],
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  renProducts[
                                                                          index]
                                                                      [
                                                                      'total_amount'],
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  changeAmount(
                                                                          context,
                                                                          renProducts[index]
                                                                              [
                                                                              'product_name'],
                                                                          renProducts[index]
                                                                              [
                                                                              'product_rate'],
                                                                          renProducts[index]
                                                                              [
                                                                              'quantity'],
                                                                          renProducts[index]
                                                                              [
                                                                              'total_tax_amount'],
                                                                          renProducts[index]
                                                                              [
                                                                              'tax_percent'],
                                                                          renProducts[index]
                                                                              [
                                                                              'total_amount'],
                                                                          renProducts[index]
                                                                              [
                                                                              'product_id'],
                                                                          renProducts[index]
                                                                              [
                                                                              'description'],
                                                                          index)
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {});
                                                                  });
                                                                },
                                                                child:
                                                                    const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child: Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              if (clientName.text.isEmpty) {
                                Common.toastMessaage(
                                    'Customer Name cannot be empty',
                                    Colors.red);
                              } else if (isExists == true) {
                                Common.toastMessaage(
                                    'PhoneNumber is already exists',
                                    Colors.red);
                              } else if (phoneNumber.text.isEmpty) {
                                Common.toastMessaage(
                                    'PhoneNumber Name cannot be empty',
                                    Colors.red);
                              } else if (isMandatory(2) &&
                                  whatsappNumber.text.trim().isEmpty) {
                                Common.toastMessaage(
                                    'WhatsApp Number cannot be empty',
                                    Colors.red);
                              } else if (isMandatory(3) &&
                                  email.text.trim().isEmpty) {
                                Common.toastMessaage(
                                    'Email cannot be empty',
                                    Colors.red);
                              } else if (email.text.trim().isNotEmpty &&
                                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(email.text.trim())) {
                                Common.toastMessaage(
                                    'Please enter a valid Email ID',
                                    Colors.red);
                              } else if (address1.text.isEmpty) {
                                Common.toastMessaage(
                                    'Address1 cannot be empty', Colors.red);
                              } else if (isMandatory(7) &&
                                  address2.text.trim().isEmpty) {
                                Common.toastMessaage(
                                    'Address 2 cannot be empty',
                                    Colors.red);
                              } else if (isMandatory(8) &&
                                  pinCode.text.trim().isEmpty) {
                                Common.toastMessaage(
                                    'Pin Code cannot be empty',
                                    Colors.red);
                              } else if (isMandatory(4) &&
                                  (selectedStateId == null ||
                                      selectedStateId!.isEmpty)) {
                                Common.toastMessaage(
                                    'Please select a State', Colors.red);
                              } else if (isMandatory(4) &&
                                  (selectedDistrictId == null ||
                                      selectedDistrictId!.isEmpty)) {
                                Common.toastMessaage(
                                    'Please select a District', Colors.red);
                              } else if (isMandatory(1) &&
                                  idProofFiles.isEmpty) {
                                Common.toastMessaage(
                                    'Please upload ID Proof',
                                    Colors.red);
                              } else if (selectedTaxType == null ||
                                  selectedTaxType!.isEmpty) {
                                Common.toastMessaage(
                                    'Please select Tax Type', Colors.red);
                              } else if (createOrder == true &&
                                  products.isEmpty &&
                                  customerAddInvoicePermission == "true") {
                                Common.toastMessaage(
                                    'Please add a product to continue',
                                    Colors.red);
                              } else if (createOrder == true &&
                                  customerAddInvoicePermission == "true" &&
                                  paymentStatus == null) {
                                Common.toastMessaage(
                                    'Payment Status is required to add invoice',
                                    Colors.red);
                              } else if (createOrder == true &&
                                  paidAmount.text.isEmpty &&
                                  customerAddInvoicePermission == "true" &&
                                  paymentStatus != "unpaid") {
                                Common.toastMessaage(
                                    'Paid Amount is required to add invoice',
                                    Colors.red);
                              } else if (createOrder == true &&
                                  paymentStatus != "unpaid" &&
                                 customerAddInvoicePermission == "true" &&
                                  paymentMethod == null) {
                                Common.toastMessaage(
                                    'Payment Method is required to add invoice',
                                    Colors.red);
                              } else if (createOrder == true &&
                                  customerAddInvoicePermission == "true"  &&
                                  paymentStatus != "unpaid" &&
                                  staffId == "") {
                                Common.toastMessaage(
                                    'Collected Staff is required to add invoice',
                                    Colors.red);
                              } else if (createRenewal == true &&
                                  createRenewalPermission == "true" &&
                                  startDate.text == "") {
                                Common.toastMessaage(
                                    'Start date is required to add renewal',
                                    Colors.red);
                              } else if (createRenewal == true &&
                                  createRenewalPermission == "true" &&
                                  endDate.text == "") {
                                Common.toastMessaage(
                                    'End date is required to add renewal',
                                    Colors.red);
                              } else if (double.parse(discount.text == ""
                                      ? "0.0"
                                      : discount.text) >
                                  subTotal) {
                                Common.toastMessaage(
                                    'The discount should not exceed the total amount',
                                    Colors.red);
                              } else if (double.parse(discount.text == ""
                                      ? "0.0"
                                      : discount.text) <
                                  0) {
                                Common.toastMessaage(
                                    'Please enter valid discount amount',
                                    Colors.red);
                              } else if (double.parse(shippingCharge.text == ""
                                      ? "0.0"
                                      : shippingCharge.text) <
                                  0) {
                                Common.toastMessaage(
                                    'Please enter valid shipping charge',
                                    Colors.red);
                              } else {
                                if (context.mounted) {
                                  Common.showProgressDialog(
                                      context, "Loading..");
                                }
                                var body = FormData.fromMap({
                                  "token": widget.token,
                                  'name': clientName.text,
                                  "country_code": code,
                                  'contact_no': phoneNumber.text,
                                  'whatsapp_no': whatsappNumber.text.trim(),
                                  'whatsapp_number': whatsappNumber.text.trim(),
                                  'whatsapp_country_code': whatsappCode,
                                  'email_id': email.text,
                                  'address': address1.text,
                                  'address2': address2.text,
                                  'address3': address3.text,
                                  "state_id": selectedStateId,
                                  "district_id": selectedDistrictId,
                                  "tax_type": selectedTaxType ?? "",
                                  'pincode': pinCode.text,
                                  'post_office': postOffice.text,
                                  'gst_num': gstNumber.text,
                                  'remarks': remarks.text,
                                  "branch_id": branch,
                                  'additional_fields':
                                      jsonEncode(additionalFields),
                                  "create_sales": createOrder,
                                  "create_type":
                                      createRenewal ? "renewal" : "invoice",
                                  "check_id_val": detailsResponse!.data.checkId,
                                  "invoice_date": invoiceDate,
                                  "product_list": jsonEncode(products),
                                  "reminder_template": reminderTemplate.text,
                                  "total_amount_paid": allTotal,
                                  "start_date": startDate.text,
                                  "end_date": endDate.text,
                                  "payment_status": paymentStatus,
                                  "sub_total": subTotal,
                                  "estimated_tax": totalTaxAmount,
                                  "discount_amount": discount.text,
                                  "shipping_amount": shippingCharge.text,
                                  "payment_method": paymentMethod,
                                  "amount_paid_customer": paidAmount.text,
                                  "collected_staff": staffId,
                                  "next_cost_diff": isDifrent,
                                  "next_renewal_product":
                                      jsonEncode(renProducts),
                                  'target_group': jsonEncode(targetGroups),
                                });
                                for (var file in idProofFiles) {
                                  final fileName = file
                                      .path
                                      .split(Platform.pathSeparator)
                                      .last;
                                  body.files.add(MapEntry(
                                    'id_proof[]',
                                    await MultipartFile.fromFile(
                                      file.path,
                                      filename: fileName,
                                    ),
                                  ));
                                }
                                AddClientsModel object =
                                    await HttpService.addClients(body);
                                if (object.status == true) {
                                  Common.toastMessaage(
                                      object.message, Colors.green);
                                  if (mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(context, true);
                                  }
                                } else {
                                  Common.toastMessaage(
                                      object.message, Colors.red);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('Submit',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
                  ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Text(
                    'No Network Found !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddProducts(),
                                )).then((_) {
                              getData();
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF2a86c9),
                                Color(0xFF406dbe)
                              ]),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        )
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

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: SizedBox(
                    //     child: TextFormField(
                    //       controller: productName,
                    //       keyboardType: TextInputType.text,
                    //       decoration: const InputDecoration(
                    //           hintText: 'Product Name',
                    //           contentPadding:
                    //           EdgeInsets.symmetric(
                    //               vertical: 10,
                    //               horizontal: 10),
                    //           border: OutlineInputBorder()),
                    //     ),
                    //   ),
                    // ),
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
                            if (productRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (productQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (productTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (productTaxAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Amount', Colors.red);
                            } else if (productTotalAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Total Amount', Colors.red);
                            } else if (double.parse(productTaxPercent.text) >
                                100) {
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
                              subTotal = subTotal +
                                  double.parse(productTotalAmount.text);
                              totalTaxAmount = totalTaxAmount +
                                  double.parse(productTaxAmount.text) *
                                      double.parse(productQty.text);
                              allTotal = subTotal +
                                  double.parse(shippingCharge.text == ''
                                      ? '0'
                                      : shippingCharge.text) -
                                  double.parse(discount.text == ''
                                      ? '0'
                                      : discount.text);
                              productName = "Choose Product";
                              productId = "";
                              productDescription.clear();
                              productRate.clear();
                              productQty.clear();
                              productTaxPercent.clear();
                              productTaxAmount.clear();
                              productTotalAmount.clear();
                              startDate.text =
                                  DateFormat('dd-MM-yyyy').format(invoiceDate);
                              final endValue = invoiceDate
                                  .add(Duration(days: int.parse(typeDuration)));
                              endDate.text =
                                  DateFormat('dd-MM-yyyy').format(endValue);
                              Navigator.of(context).pop();
                              setState(() {});
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
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredItems = items
                            .where((item) => item.productName
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)))),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            if (type == "add") {
                              if (productQty.text == "") {
                                productQty.text = "1";
                              }
                              productName = filteredItems[index].productName;
                              productId = filteredItems[index].id;
                              productRate.text =
                                  filteredItems[index].sellingPrice;
                              productTaxPercent.text =
                                  filteredItems[index].taxPercent;
                              productTaxAmount.text =
                                  filteredItems[index].taxAmount;
                              productTotalAmount
                                  .text = ((double.parse(productRate.text) +
                                          double.parse(productTaxAmount.text)) *
                                      double.parse(productQty.text))
                                  .toString();
                              productTotalAmount.text =
                                  double.parse(productTotalAmount.text)
                                      .toStringAsFixed(2);
                              if (paymentStatus == "paid") {
                                paidAmount.text = productTotalAmount.text;
                              }
                              typeDuration = filteredItems[index].noOfDays;
                            } else {
                              if (renProductQty.text == "") {
                                renProductQty.text = "1";
                              }
                              renProductName = filteredItems[index].productName;
                              renProductId = filteredItems[index].id;
                              renProductRate.text =
                                  filteredItems[index].sellingPrice;
                              renProductTaxPercent.text =
                                  filteredItems[index].taxPercent;
                              renProductTaxAmount.text =
                                  filteredItems[index].taxAmount;
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
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredItems[index].productName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
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
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          filteredTargets = commonDetails!.data.targetGroups
                              .where((item) => item.groupName
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
                    height: MediaQuery.of(context).size.height * .32,
                    width: MediaQuery.of(context).size.width * .8,
                    child: ListView.builder(
                      // Remove NeverScrollableScrollPhysics to enable scrolling
                      shrinkWrap: true,
                      itemCount: filteredTargets.length,
                      itemBuilder: (context, ind) {
                        return CheckboxListTile(
                          title: SizedBox(
                            width: 200,
                            child: Text(
                              filteredTargets[ind].groupName.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                          ),
                          value: targetGroups
                                  .contains(filteredTargets[ind].id.toString())
                              ? true
                              : false,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                targetGroups
                                    .add(filteredTargets[ind].id.toString());
                                targetGroupNames.add(
                                    filteredTargets[ind].groupName.toString());
                              } else {
                                targetGroups
                                    .remove(filteredTargets[ind].id.toString());
                                targetGroupNames.remove(
                                    filteredTargets[ind].groupName.toString());
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
                  filteredTargets.clear();
                  filteredTargets.addAll(commonDetails!.data.targetGroups);
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
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              renProducts.removeAt(index);
                              setState(() {});
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
                              renProductCalculation();
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
                              renProductCalculation();
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
                              renProductCalculation();
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
                              Navigator.of(context).pop();
                              setState(() {});
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
                        autofocus: true,
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
                          filterTemplates("");
                          Navigator.pop(context);
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

  void filterTemplates(
    String query,
  ) {
    filteredTemplates = detailsResponse!.data.template
        .where((map) =>
            map.templateName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<dynamic> collectedStaffDialog(BuildContext context) {
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
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredStaff = commonDetails!.data.colloctedStaff
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
                    itemCount: filteredStaff.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            staffName = filteredStaff[index].accountName;
                            staffId = filteredStaff[index].accountId;
                            filteredStaff
                                .addAll(commonDetails!.data.colloctedStaff);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredStaff[index].accountName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    filteredStaff.addAll(commonDetails!.data.colloctedStaff);
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

  renProductCalculation() {
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
    setState(() {});
  }
}
