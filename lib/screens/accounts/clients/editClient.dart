// ignore_for_file: file_names, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common.dart';
import '../../../models/clients/branchListModel.dart';
import '../../../models/clients/editClientDetailsModel.dart';
import '../../../models/clients/editClientsModel.dart';
import '../../../models/clients/postalCodeModel.dart';
import '../../../service/service.dart';

class EditClients extends StatefulWidget {
  String token;
  String clientId;
  EditClients(this.token, this.clientId, {super.key});

  @override
  State<EditClients> createState() => _EditClientsState();
}

class _EditClientsState extends State<EditClients> {
  EditClientDetailsModel? mainClientDetail;
  bool result = true;
  TextEditingController clientName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController whatsappNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController address3 = TextEditingController();
  TextEditingController stateId = TextEditingController();
  TextEditingController districtId = TextEditingController();
  TextEditingController taxType = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController gstNumber = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController postOffice = TextEditingController();
  PostalCodeModel? postal;
  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldValue = TextEditingController();
  List<Map<String, dynamic>> additionalFields = [];
  String roleId = '';
  String multiBranch = '';
  String? branch;
  BranchListModel? branchList;
  bool isExists = false;
  IsCustomerExistModel? isExist;
  var code = '91';
  var whatsappCode = '91';

  List<File> idProofFiles = [];
  List<IdProofDocument> existingIdProofs = [];
  List<String> existingIdProofFiles = [];
  Set<int> mandatoryFields = {};
  bool isLoadingMandatoryFields = true;

  Future<void> _openDocument(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    try {
      final uri = Uri.parse(trimmed);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Could not open URL: $trimmed ($e)");
      }
      Common.toastMessaage("Could not open document", Colors.red);
    }
  }

  StateModel? stateModel;
  List<StateList> stateList = [];
  String? selectedStateId;

  DistrictModel? districtModel;
  List<DistrictList> districtList = [];
  String? selectedDistrictId;
  bool isLoadingState = true;
  bool isLoadingDistrict = false;
  String? selectedTaxType;

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

  List<String> _parseExistingIdProof(dynamic val) {
    if (val == null) return [];
    if (val is List) {
      return val
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty && e != 'null')
          .toList();
    }
    String str = val.toString().trim();
    if (str.isEmpty || str == 'null') return [];
    if (str.startsWith('[') && str.endsWith(']')) {
      try {
        final decoded = jsonDecode(str);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty && e != 'null')
              .toList();
        }
      } catch (_) {}
    }
    if (str.contains(',')) {
      return str
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != 'null')
          .toList();
    }
    return [str];
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
    final totalCount = idProofFiles.length + existingIdProofs.length;

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
        if (existingIdProofs.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...existingIdProofs.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final name = doc.fileName.isNotEmpty
                ? doc.fileName
                : (doc.fileUrl.isNotEmpty
                    ? doc.fileUrl.split('/').last.split('\\').last
                    : 'Document ${index + 1}');
            final lower =
                (name + doc.fileUrl + doc.previewUrl).toLowerCase();
            final isPdf = lower.contains('.pdf');

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                    color:
                        isPdf ? Colors.red.shade700 : const Color(0xFF2a86c9),
                    size: 22,
                  ),
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
                          'Existing document',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (doc.previewUrl.isNotEmpty) ...[
                    InkWell(
                      onTap: () => _openDocument(doc.previewUrl),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_red_eye_outlined,
                                color: Color(0xFF2a86c9), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Preview',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2a86c9),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else if (doc.fileUrl.isNotEmpty) ...[
                    InkWell(
                      onTap: () => _openDocument(doc.fileUrl),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_red_eye_outlined,
                                color: Color(0xFF2a86c9), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Preview',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2a86c9),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (doc.fileUrl.isNotEmpty &&
                      doc.previewUrl.isNotEmpty &&
                      doc.fileUrl != doc.previewUrl)
                    InkWell(
                      onTap: () => _openDocument(doc.fileUrl),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.open_in_new,
                            color: Colors.grey, size: 18),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
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
                          'New file selected',
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
    roleId = await Common.getSharedPref("roleId");
    multiBranch = await Common.getSharedPref("multiBranch");
    branchList = await HttpService.getBranchList(widget.token);
    if (branchList != null) {
      setState(() {});
    }
    mainClientDetail =
        await HttpService.editClientDetails(widget.token, widget.clientId);
    if (mainClientDetail != null) {
      clientName.text = mainClientDetail!.data.name.toString();
      phoneNumber.text = mainClientDetail!.data.contactNo.toString();
      if (mainClientDetail!.data.whatsappNumber != null &&
          mainClientDetail!.data.whatsappNumber!.isNotEmpty) {
        whatsappNumber.text = mainClientDetail!.data.whatsappNumber!;
      }
      if (mainClientDetail!.data.whatsappCountryCode != null &&
          mainClientDetail!.data.whatsappCountryCode!.isNotEmpty) {
        whatsappCode = mainClientDetail!.data.whatsappCountryCode!;
      } else if (mainClientDetail!.data.countryCode.toString().isNotEmpty) {
        whatsappCode = mainClientDetail!.data.countryCode.toString();
      }
      existingIdProofs =
          List<IdProofDocument>.from(mainClientDetail!.data.idProofs);
      if (existingIdProofs.isEmpty &&
          mainClientDetail!.data.idProof != null &&
          mainClientDetail!.data.idProof!.isNotEmpty &&
          mainClientDetail!.data.idProof != 'null') {
        final legacyFiles =
            _parseExistingIdProof(mainClientDetail!.data.idProof);
        for (var f in legacyFiles) {
          existingIdProofs.add(IdProofDocument(
            documentId: '',
            fileId: '',
            fileName: f.split('/').last.split('\\').last,
            fileUrl: f,
            previewUrl: f,
          ));
        }
      }
      existingIdProofFiles = existingIdProofs
          .map((e) => e.fileUrl.isNotEmpty ? e.fileUrl : e.previewUrl)
          .where((e) => e.isNotEmpty)
          .toList();

      email.text = mainClientDetail!.data.emailId.toString();
      address1.text = mainClientDetail!.data.address1.toString();
      address2.text = mainClientDetail!.data.address2.toString();
      address3.text = mainClientDetail!.data.address3.toString();

      final rawStateId = mainClientDetail!.data.stateId.toString().trim();
      final isValidStateId = rawStateId.isNotEmpty &&
          rawStateId != '0' &&
          rawStateId != 'null';
      stateId.text = isValidStateId ? rawStateId : '';
      selectedStateId = isValidStateId ? rawStateId : null;

      final rawDistrictId =
          mainClientDetail!.data.districtId.toString().trim();
      final isValidDistrictId = rawDistrictId.isNotEmpty &&
          rawDistrictId != '0' &&
          rawDistrictId != 'null';
      districtId.text = isValidDistrictId ? rawDistrictId : '';
      selectedDistrictId = isValidDistrictId ? rawDistrictId : null;

      await getStates();

      // Verify that selectedStateId exists in fetched stateList
      if (selectedStateId != null &&
          !stateList.any((s) => s.id.trim() == selectedStateId!.trim())) {
        selectedStateId = null;
        stateId.text = '';
      }

      if (selectedStateId != null) {
        await getDistricts(selectedStateId!);
        // Verify that selectedDistrictId exists in fetched districtList
        if (selectedDistrictId != null &&
            !districtList
                .any((d) => d.id.trim() == selectedDistrictId!.trim())) {
          selectedDistrictId = null;
          districtId.text = '';
        }
      } else {
        selectedDistrictId = null;
        districtId.text = '';
      }

      taxType.text = mainClientDetail!.data.taxType.toString();
      selectedTaxType = mainClientDetail!.data.taxType.toString().isNotEmpty
          ? mainClientDetail!.data.taxType.toString()
          : "Intrastate";
      pinCode.text = mainClientDetail!.data.pincode.toString();
      gstNumber.text = mainClientDetail!.data.gstNum.toString();
      remarks.text = mainClientDetail!.data.remarks.toString();
      postOffice.text = mainClientDetail!.data.postOffice.toString();
      if (mainClientDetail!.data.countryCode.toString() != '') {
        code = mainClientDetail!.data.countryCode.toString();
      }

      if (pinCode.text != '') {
        postal = await HttpService.fetchPostOffice(pinCode.text);
      }

      final rawBranchId = mainClientDetail!.data.branchId.toString().trim();
      final isValidBranchId = rawBranchId.isNotEmpty &&
          rawBranchId != '0' &&
          rawBranchId != 'null';
      if (isValidBranchId) {
        branch = rawBranchId;
      } else {
        branch = null;
      }

      if (mainClientDetail!.data.additionalFields.isNotEmpty) {
        for (int i = 0;
            i < mainClientDetail!.data.additionalFields.length;
            i++) {
          additionalFields.add({
            "field_name": mainClientDetail!.data.additionalFields[i].fieldName,
            "field_value":
                mainClientDetail!.data.additionalFields[i].fieldValue,
          });
        }
      }
      setState(() {});
    }
  }

  Future<void> getStates() async {
    setState(() => isLoadingState = true);
    final response = await HttpService.getState();
    if (response != null && response.status == true) {
      final seenStateIds = <String>{};
      final uniqueStates = (response.data as List<StateList>)
          .where((s) =>
              s.id.trim().isNotEmpty &&
              s.id.trim() != '0' &&
              seenStateIds.add(s.id.trim()))
          .toList();
      setState(() {
        stateList = uniqueStates;
        isLoadingState = false;
        if (selectedStateId != null &&
            !stateList.any((s) => s.id.trim() == selectedStateId!.trim())) {
          selectedStateId = null;
          stateId.text = '';
        }
      });
    } else {
      setState(() => isLoadingState = false);
    }
  }

  Future<void> getDistricts(String sId) async {
    final cleanStateId = sId.trim();
    if (cleanStateId.isEmpty ||
        cleanStateId == '0' ||
        cleanStateId == 'null') {
      setState(() {
        districtList = [];
        selectedDistrictId = null;
        districtId.text = '';
        isLoadingDistrict = false;
      });
      return;
    }

    setState(() {
      isLoadingDistrict = true;
      districtList = [];
      selectedDistrictId = null;
    });

    final response = await HttpService.getDistrict(cleanStateId);
    if (response != null && response.status == true) {
      final seenDistrictIds = <String>{};
      final uniqueDistricts = (response.data as List<DistrictList>)
          .where((d) =>
              d.id.trim().isNotEmpty &&
              d.id.trim() != '0' &&
              seenDistrictIds.add(d.id.trim()))
          .toList();
      setState(() {
        districtList = uniqueDistricts;
        isLoadingDistrict = false;
        if (districtId.text.isNotEmpty &&
            districtId.text != '0' &&
            districtList
                .any((d) => d.id.trim() == districtId.text.trim())) {
          selectedDistrictId = districtId.text.trim();
        } else {
          selectedDistrictId = null;
        }
      });
    } else {
      setState(() => isLoadingDistrict = false);
    }
  }

  isCustomerExists() async {
    isExist =
        await HttpService.isCustomerExists(widget.clientId, phoneNumber.text);
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
                            'Edit Customer',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: mainClientDetail != null && branchList != null
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
                                  child: Builder(
                                    builder: (context) {
                                      final branches = branchList?.data ?? [];
                                      final seenBranchIds = <String>{};
                                      final branchDropdownItems = branches
                                          .where((data) =>
                                              data.branchId != null &&
                                              data.branchId.toString().trim().isNotEmpty &&
                                              data.branchId.toString().trim() != '0' &&
                                              seenBranchIds.add(data.branchId.toString().trim()))
                                          .map((data) {
                                        final bId = data.branchId.toString().trim();
                                        return DropdownMenuItem<String>(
                                          value: bId,
                                          child: Text(
                                            data.branchName?.toString() ?? '',
                                          ),
                                        );
                                      }).toList();

                                      final currentSelectedBranch = (branch != null &&
                                              branch != '0' &&
                                              branchDropdownItems.any((item) => item.value == branch!.trim()))
                                          ? branch!.trim()
                                          : null;

                                      return DropdownButtonFormField<String>(
                                        value: currentSelectedBranch,
                                        onChanged: (value) async {
                                          setState(() {
                                            branch = value;
                                          });
                                        },
                                        items: branchDropdownItems,
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
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
                                      );
                                    },
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
                                      onSelect: (Country country) {
                                        setState(() {
                                          code = country.phoneCode;
                                        });
                                      },
                                    );
                                  },
                                  child: SizedBox(
                                    width: 70,
                                    child: Row(children: [
                                      Text("+$code"),
                                      const Icon(Icons.arrow_drop_down),
                                    ]),
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
                                  child: SizedBox(
                                    width: 70,
                                    child: Row(children: [
                                      Text("+$whatsappCode"),
                                      const Icon(Icons.arrow_drop_down),
                                    ]),
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
                          const SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isLoadingState
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Builder(
                                      builder: (context) {
                                        final seenStateIds = <String>{};
                                        final stateDropdownItems = stateList
                                            .where((s) =>
                                                s.id.trim().isNotEmpty &&
                                                s.id.trim() != '0' &&
                                                seenStateIds.add(s.id.trim()))
                                            .map((state) {
                                          return DropdownMenuItem<String>(
                                            value: state.id.trim(),
                                            child: Text(state.name),
                                          );
                                        }).toList();

                                        final currentSelectedState =
                                            (selectedStateId != null &&
                                                    selectedStateId != '0' &&
                                                    stateDropdownItems.any(
                                                        (item) =>
                                                            item.value ==
                                                            selectedStateId!
                                                                .trim()))
                                                ? selectedStateId!.trim()
                                                : null;

                                        return DropdownButtonFormField<String>(
                                          value: currentSelectedState,
                                          hint: _buildFieldLabel(
                                              "Select State", isMandatory(4)),
                                          decoration: InputDecoration(
                                            label: _buildFieldLabel(
                                                "State", isMandatory(4)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                          ),
                                          items: stateDropdownItems,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedStateId = value;
                                              stateId.text = value ?? '';
                                              selectedDistrictId = null;
                                              districtId.text = '';
                                              districtList.clear();
                                            });
                                            if (value != null &&
                                                value.isNotEmpty &&
                                                value != '0') {
                                              getDistricts(value);
                                            }
                                          },
                                        );
                                      },
                                    ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLoadingDistrict)
                                const Center(child: CircularProgressIndicator())
                              else
                                Builder(
                                  builder: (context) {
                                    final seenDistrictIds = <String>{};
                                    final districtDropdownItems = districtList
                                        .where((d) =>
                                            d.id.trim().isNotEmpty &&
                                            d.id.trim() != '0' &&
                                            seenDistrictIds.add(d.id.trim()))
                                        .map((district) {
                                      return DropdownMenuItem<String>(
                                        value: district.id.trim(),
                                        child: Text(district.name),
                                      );
                                    }).toList();

                                    final currentSelectedDistrict =
                                        (selectedDistrictId != null &&
                                                selectedDistrictId != '0' &&
                                                districtDropdownItems.any(
                                                    (item) =>
                                                        item.value ==
                                                        selectedDistrictId!
                                                            .trim()))
                                            ? selectedDistrictId!.trim()
                                            : null;

                                    return DropdownButtonFormField<String>(
                                      value: currentSelectedDistrict,
                                      hint: _buildFieldLabel(
                                          "Choose District", isMandatory(4)),
                                      decoration: InputDecoration(
                                        label: _buildFieldLabel(
                                            "District", isMandatory(4)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                      ),
                                      items: districtDropdownItems,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDistrictId = value;
                                          districtId.text = value ?? '';
                                        });
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Select Tax Type ",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
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
                                          taxType.text =
                                              value; // sync controller
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
                                          taxType.text =
                                              value; // sync controller
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
                          const SizedBox(height: 15),
                          TextFormField(
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
                            controller: pinCode,
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
                          const SizedBox(
                            height: 15,
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
                                                0.4),
                                        1: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.4),
                                        2: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
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
                                                0.4),
                                        1: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.4),
                                        2: FixedColumnWidth(
                                            MediaQuery.of(context).size.width *
                                                0.10),
                                      },
                                      children: [
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
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              if (clientName.text.isEmpty) {
                                Common.toastMessaage(
                                    'Customer Name cannot be empty',
                                    Colors.red);
                              } else if (phoneNumber.text.isEmpty) {
                                Common.toastMessaage(
                                    'phoneNumber Name cannot be empty',
                                    Colors.red);
                              } else if (isExists == true) {
                                Common.toastMessaage(
                                    'PhoneNumber is already exists',
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
                              } else if (isMandatory(7) &&
                                  address2.text.trim().isEmpty) {
                                Common.toastMessaage(
                                    'Address 2 cannot be empty',
                                    Colors.red);
                              } else if (isMandatory(4) &&
                                  (selectedStateId == null ||
                                      selectedStateId!.isEmpty ||
                                      selectedStateId == '0')) {
                                Common.toastMessaage(
                                    'Please select a State', Colors.red);
                              } else if (isMandatory(4) &&
                                  (selectedDistrictId == null ||
                                      selectedDistrictId!.isEmpty ||
                                      selectedDistrictId == '0')) {
                                Common.toastMessaage(
                                    'Please select a District', Colors.red);
                              } else if (isMandatory(8) &&
                                  pinCode.text.trim().isEmpty) {
                                Common.toastMessaage(
                                    'Pin Code cannot be empty',
                                    Colors.red);
                              } else if (isMandatory(1) &&
                                  idProofFiles.isEmpty &&
                                  existingIdProofs.isEmpty) {
                                Common.toastMessaage(
                                    'Please upload ID Proof',
                                    Colors.red);
                              } else {
                                if (context.mounted) {
                                  Common.showProgressDialog(
                                      context, "Loading..");
                                }
                                var body = FormData.fromMap({
                                  "token": widget.token,
                                  'client_id': widget.clientId,
                                  'name': clientName.text,
                                  'country_code': code,
                                  'contact_no': phoneNumber.text,
                                  'whatsapp_no': whatsappNumber.text.trim(),
                                  'whatsapp_number': whatsappNumber.text.trim(),
                                  'whatsapp_country_code': whatsappCode,
                                  'email_id': email.text,
                                  'address': address1.text,
                                  'address2': address2.text,
                                  'address3': address3.text,
                                  "state_id": (selectedStateId != null &&
                                          selectedStateId != '0')
                                      ? selectedStateId
                                      : "",
                                  "district_id":
                                      (selectedDistrictId != null &&
                                              selectedDistrictId != '0')
                                          ? selectedDistrictId
                                          : "",
                                  "tax_type": selectedTaxType ?? "",
                                  'pincode': pinCode.text,
                                  'post_office': postOffice.text,
                                  'gst_num': gstNumber.text,
                                  'remarks': remarks.text,
                                  "branch_id": (branch != null && branch != '0')
                                      ? branch
                                      : "",
                                  'additional_fields':
                                      jsonEncode(additionalFields),
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
                                if (existingIdProofs.isNotEmpty) {
                                  final urls = existingIdProofs
                                      .map((e) => e.fileUrl.isNotEmpty
                                          ? e.fileUrl
                                          : e.previewUrl)
                                      .where((u) => u.isNotEmpty)
                                      .toList();
                                  final docIds = existingIdProofs
                                      .map((e) => e.documentId)
                                      .where((id) => id.isNotEmpty)
                                      .toList();

                                  body.fields.add(MapEntry('existing_id_proof',
                                      jsonEncode(urls)));
                                  body.fields.add(MapEntry('existing_id_proofs',
                                      urls.join(',')));
                                  if (docIds.isNotEmpty) {
                                    body.fields.add(MapEntry(
                                        'existing_document_ids',
                                        docIds.join(',')));
                                    body.fields.add(MapEntry(
                                        'existing_id_proof_ids',
                                        jsonEncode(docIds)));
                                  }
                                }
                                EditClientsModel object =
                                    await HttpService.editClients(body);
                                if (object.status == true) {
                                  Common.toastMessaage(
                                      object.message, Colors.green);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
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
}
