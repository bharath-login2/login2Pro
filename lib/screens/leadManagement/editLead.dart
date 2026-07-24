import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/editLeadModel.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/leadDetailsModelAdd.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

import '../../widgets/inputTextFeildWidget.dart';

// ignore: must_be_immutable
class EditLead extends StatefulWidget {
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

  EditLead(this.token, this.callMasterId, this.editLeads, this.deleteLeads,
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
  State<EditLead> createState() => _EditLeadState();
}

class _EditLeadState extends State<EditLead> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  LeadSubTypeModel? leadSubTypeList;
  bool? result = true;
  bool? result1 = true;
  String leadType = 'Lead Category';
  String leadTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String leadSubTypeId = '';
  String assignStaff = 'Assign Staff';
  String assignStaffId = '';
  // String callResult = '';
  // String callResultId = '';
  String leadSource = '';
  String leadSourceId = '';
  String priority = 'Normal';
  String priorityId = '2';
  TextEditingController clientName = TextEditingController();
  TextEditingController contactNo = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController remark = TextEditingController();
  String? nextFollowupDate = '';
  LeadDeatailsModel? leadDetails;
  TextEditingController leadTypeVal = TextEditingController();
  TextEditingController leadSubTypeVal = TextEditingController();
  TextEditingController assignUserval = TextEditingController();
  TextEditingController priorityVal = TextEditingController();
  // TextEditingController callResultVal = TextEditingController();
  TextEditingController leadSourceVal = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController districtVal = TextEditingController();
  TextEditingController stateVal = TextEditingController();
  final TextEditingController companyNameCtrl = TextEditingController();
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  bool isDistrictLoading = false;
  bool isLoading = false;
  StateModel? stateDetails;
  String? StateId;
  String? DistrictId;
  var code = '91';

  final List<TextEditingController> _controllers = [];
  List descriptions = [];
  LeadDeatailsModelAdd? leadDetailsAdditional;
  String roleId = '';
  String multiBranch = '';
  String? branch;

  Future<void> loadPostOffices(String pin) async {
    if (pin.length != 6) return;

    setState(() {
      isLoading = true;
      postOffices = [];
      selectedPostOffice = null;
    });

    var model = await HttpService.fetchPostOffice(pin);

    setState(() {
      isLoading = false;
      postalCodeModel = model;
      postOffices = model?.postOffice ?? [];
      if (leadDetails?.data?.postOffice != null && postOffices.isNotEmpty) {
        selectedPostOffice = postOffices.firstWhere(
          (po) =>
              po.name?.toLowerCase() ==
              leadDetails!.data!.postOffice!.toLowerCase(),
          orElse: () => postOffices.first,
        );
      }
    });
  }

  Future<void> loadDistricts(String stateId) async {
    setState(() {
      isDistrictLoading = true;
      districtList = [];
      districtVal.clear();
      DistrictId = null;
    });

    var result = await HttpService.getDistrict(stateId);

    setState(() {
      districtList = result?.data ?? [];
      isDistrictLoading = false;
      if (leadDetails?.data?.districtId != null && districtList.isNotEmpty) {
        var currentDistrict = districtList.firstWhere(
          (district) => district.id == leadDetails!.data!.districtId,
          orElse: () => districtList.first,
        );
        DistrictId = currentDistrict.id;
        districtVal.text = currentDistrict.name;
      }
    });
  }

  void loadStateFromLead() {
    if (leadDetails?.data?.stateId != null && stateDetails?.data != null) {
      try {
        var currentState = stateDetails!.data.firstWhere(
          (state) => state.id == leadDetails!.data!.stateId,
          orElse: () => StateList(id: '', name: 'Select State'),
        );

        if (currentState.id.isNotEmpty) {
          stateVal.text = currentState.name;
          StateId = currentState.id;
          loadDistricts(StateId!);
        }
      } catch (e) {
        print("Error loading state: $e");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  // getData() async {
  //   final connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     setState(() {
  //       result = true;
  //     });
  //   } else {
  //     setState(() {
  //       result = false;
  //     });
  //   }
  //   roleId = await Common.getSharedPref("roleId");
  //   multiBranch = await Common.getSharedPref("multiBranch");
  //   stateDetails = await HttpService.getState();
  //   commonDetails = await HttpService.addLeadCommonData(widget.token);
  //   leadDetails =
  //       await HttpService.leadDetails(widget.token, widget.callMasterId);
  //   if (leadDetails?.data != null) {
  //     pinCode.text = leadDetails!.data!.pinCode ?? "";
  //     if (pinCode.text.length == 6) {
  //       await loadPostOffices(pinCode.text);
  //     }
  //     loadStateFromLead();
  //   }

  //   leadDetailsAdditional =
  //       await HttpService.listAddonDet(widget.token, widget.callMasterId);

  //   if (commonDetails != null) {
  //     if (leadDetails!.data!.leadCategoryId.toString() != '') {
  //       leadSubTypeList = await HttpService.leadSubType(
  //           leadDetails!.data!.leadCategoryId.toString());
  //       setState(() {});
  //     }
  //     setState(() {
  //       if (leadDetails!.data!.branchId.toString() != '') {
  //         branch = leadDetails!.data!.branchId.toString();
  //       }
  //       leadType = leadDetails!.data!.leadCategory.toString();
  //       leadTypeId = leadDetails!.data!.leadCategoryId.toString();
  //       assignStaff = leadDetails!.data!.staffName.toString();
  //       assignStaffId = leadDetails!.data!.assignedUserId.toString();
  //       priorityId = leadDetails!.data!.priorityId.toString();
  //       priority = leadDetails!.data!.priority.toString();
  //       clientName.text = leadDetails!.data!.clientName.toString();
  //       contactNo.text = leadDetails!.data!.contactNumber1.toString();
  //       cost.text = leadDetails!.data!.cost.toString();
  //       contactNo.text =
  //           Common.trimPlus91(leadDetails!.data!.contactNumber1.toString());
  //       address.text = leadDetails!.data!.address.toString();
  //       pinCode.text = leadDetails!.data!.pinCode.toString();
  //       remark.text = leadDetails!.data!.remarks.toString();
  //       leadSubType = leadDetails!.data!.leadSubCategory.toString();
  //       leadSubTypeId = leadDetails!.data!.leadSubCategory.toString();
  //       leadSourceVal.text = leadDetails!.data!.leadSource.toString();
  //       leadSource = leadDetails!.data!.leadSource.toString();
  //       leadSourceId = leadDetails!.data!.leadSourceId.toString();
  //       leadTypeVal.text = leadType;
  //       leadSubTypeVal.text = leadSubType;
  //       assignUserval.text = leadDetails!.data!.staffName.toString();
  //       priorityVal.text = leadDetails!.data!.priority.toString();
  //       code = leadDetails!.data!.countryCode.toString();
  //       for (int i = 0;
  //           i < leadDetailsAdditional!.data.additionalFields.length;
  //           i++) {
  //         _controllers.add(TextEditingController());
  //         _controllers[i].text =
  //             leadDetailsAdditional!.data.additionalFields[i].value.toString();
  //       }
  //     });
  //   }
  // }
  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
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

    try {
      roleId = await Common.getSharedPref("roleId") ?? "";
      multiBranch = await Common.getSharedPref("multiBranch") ?? "";
      stateDetails = await HttpService.getState();
      commonDetails = await HttpService.addLeadCommonData(widget.token);
      leadDetails =
          await HttpService.leadDetails(widget.token, widget.callMasterId);

      if (leadDetails?.data != null) {
        pinCode.text = leadDetails!.data!.pinCode?.toString() ?? "";
        if (pinCode.text.length == 6) {
          await loadPostOffices(pinCode.text);
        }
        loadStateFromLead();
      }

      leadDetailsAdditional =
          await HttpService.listAddonDet(widget.token, widget.callMasterId);

      if (commonDetails != null && leadDetails?.data != null) {
        if (leadDetails!.data!.leadCategoryId?.toString() != null &&
            leadDetails!.data!.leadCategoryId.toString().isNotEmpty) {
          leadSubTypeList = await HttpService.leadSubType(
              leadDetails!.data!.leadCategoryId.toString());
        }

        setState(() {
          // Add null-safe access for all fields
          branch = leadDetails!.data!.branchId?.toString();
          leadType =
              leadDetails!.data!.leadCategory?.toString() ?? 'Lead Category';
          leadTypeId = leadDetails!.data!.leadCategoryId?.toString() ?? '';
          assignStaff =
              leadDetails!.data!.staffName?.toString() ?? 'Assign Staff';
          assignStaffId = leadDetails!.data!.assignedUserId?.toString() ?? '';
          priorityId = leadDetails!.data!.priorityId?.toString() ?? '2';
          priority = leadDetails!.data!.priority?.toString() ?? 'Normal';
          clientName.text = leadDetails!.data!.clientName?.toString() ?? '';

          // Fix duplicate assignment
          // String contactNumber =
          //     leadDetails!.data!.contactNumber1?.toString() ?? '';
          // contactNo.text = Common.trimPlus91(contactNumber);
          String contactNumber =
              leadDetails!.data!.contactNumber1?.toString() ?? '';

          code = leadDetails!.data!.countryCode?.toString() ?? '91';

          contactNo.text = Common.trimCountryCode(
            mobileNumber: contactNumber,
            countryCode: code,
          );

          cost.text = leadDetails!.data!.cost?.toString() ?? '';
          address.text = leadDetails!.data!.address?.toString() ?? '';
          pinCode.text = leadDetails!.data!.pinCode?.toString() ?? '';
          remark.text = leadDetails!.data!.remarks?.toString() ?? '';
          leadSubType = leadDetails!.data!.leadSubCategory?.toString() ??
              'Lead Sub Category';
          leadSubTypeId =
              leadDetails!.data!.leadSubCategoryId?.toString() ?? '';
          leadSourceVal.text = leadDetails!.data!.leadSource?.toString() ?? '';
          leadSource = leadDetails!.data!.leadSource?.toString() ?? '';
          leadSourceId = leadDetails!.data!.leadSourceId?.toString() ?? '';
          leadTypeVal.text = leadType;
          leadSubTypeVal.text = leadSubType;
          assignUserval.text = leadDetails!.data!.staffName?.toString() ?? '';
          priorityVal.text = leadDetails!.data!.priority?.toString() ?? '';
          code = leadDetails!.data!.countryCode?.toString() ?? '91';
          if (leadDetailsAdditional?.data?.additionalFields != null) {
            for (int i = 0;
                i < leadDetailsAdditional!.data.additionalFields.length;
                i++) {
              if (_controllers.length <= i) {
                _controllers.add(TextEditingController());
              }
              _controllers[i].text = leadDetailsAdditional!
                      .data.additionalFields[i].value
                      ?.toString() ??
                  '';
            }
          }
        });
      }
    } catch (e) {
      print("Error in getData: $e");
      Common.toastMessaage('Error loading lead data', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
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
                      'Edit Lead',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: commonDetails != null
          ? SingleChildScrollView(
              child: Form(
                key: globalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    multiBranch == 'true' && roleId == '2'
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: DropdownButtonFormField(
                              value: branch,
                              onChanged: (value) {
                                setState(() {
                                  branch = value.toString();
                                });
                              },
                              items: commonDetails!.data.branch.map((data) {
                                return DropdownMenuItem<String>(
                                  value: data.branchId.toString(),
                                  child: Text(
                                    data.branchName.toString(),
                                  ),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  // Custom border
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                labelText: 'Select Branch',
                                prefixIcon: const Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.grey),
                                labelStyle: const TextStyle(color: Colors.grey),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: InputTextField(
                        hintText: 'Customer Name',
                        hintTextColor: Colors.white,
                        backgroundColor: Colors.white,
                        controller: clientName,
                        width: 1,
                        iconData: Icons.person,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: leadTypeVal,
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController searchController =
                                    TextEditingController();
                                List<LeadCategory> filteredList =
                                    List.from(commonDetails!.data.leadCategory);

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text('Lead Category'),
                                      content: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: searchController,
                                              onChanged: (value) {
                                                setState(() {
                                                  filteredList = commonDetails!
                                                      .data.leadCategory
                                                      .where((cat) => cat
                                                          .leadCategory
                                                          .toLowerCase()
                                                          .contains(value
                                                              .toLowerCase()))
                                                      .toList();
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Search",
                                                prefixIcon: const Icon(
                                                    Icons.search,
                                                    color: Colors.grey),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: filteredList.length,
                                                itemBuilder: (context, ind) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      // Clear the existing subcategory first
                                                      setState(() {
                                                        leadSubType =
                                                            'Lead Sub Category';
                                                        leadSubTypeId = '';
                                                        leadSubTypeVal.text =
                                                            'Lead Sub Category';
                                                        leadSubTypeList =
                                                            null; // Clear the list
                                                      });

                                                      // Fetch new subcategories
                                                      var newLeadSubTypeList =
                                                          await HttpService
                                                              .leadSubType(
                                                        filteredList[ind]
                                                            .leadCategoryId
                                                            .toString(),
                                                      );

                                                      // Update the state with the new values
                                                      setState(() {
                                                        leadSubTypeList =
                                                            newLeadSubTypeList;
                                                        leadTypeVal.text =
                                                            filteredList[ind]
                                                                .leadCategory
                                                                .toString();
                                                        leadType =
                                                            filteredList[ind]
                                                                .leadCategory
                                                                .toString();
                                                        leadTypeId =
                                                            filteredList[ind]
                                                                .leadCategoryId
                                                                .toString();
                                                      });

                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    child: SizedBox(
                                                      height: 45,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          filteredList[ind]
                                                              .leadCategory,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
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
                              },
                            );
                          },
                          maxLines: 1,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Lead Category',
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.arrow_drop_down_circle_outlined,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    //leadSubTypeList != null && leadSubTypeList!.data!.isNotEmpty
                    // Replace the existing subcategory section with this:
                    leadTypeId.isNotEmpty && leadSubTypeList != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: SizedBox(
                                    height: 50,
                                    child: TextFormField(
                                      controller: leadSubTypeVal,
                                      onTap: () {
                                        if (leadSubTypeList!.data!.isNotEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                scrollable: true,
                                                title: const Text(
                                                    'Lead Sub Category'),
                                                content: SingleChildScrollView(
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.5,
                                                    ),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          leadSubTypeList!
                                                              .data!.length,
                                                      itemBuilder:
                                                          (context, subIndex) {
                                                        return InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              leadSubType =
                                                                  leadSubTypeList!
                                                                      .data![
                                                                          subIndex]
                                                                      .leadSubCategory
                                                                      .toString();
                                                              leadSubTypeId =
                                                                  leadSubTypeList!
                                                                      .data![
                                                                          subIndex]
                                                                      .leadSubCategoryId
                                                                      .toString();
                                                              leadSubTypeVal
                                                                      .text =
                                                                  leadSubTypeList!
                                                                      .data![
                                                                          subIndex]
                                                                      .leadSubCategory
                                                                      .toString();
                                                              Navigator.pop(
                                                                  context,
                                                                  true);
                                                            });
                                                          },
                                                          child: SizedBox(
                                                            height: 50,
                                                            child: Text(
                                                              leadSubTypeList!
                                                                  .data![
                                                                      subIndex]
                                                                  .leadSubCategory
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
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          Common.toastMessaage(
                                              'No subcategories available for this category',
                                              Colors.blue);
                                        }
                                      },
                                      maxLines: 1,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText: 'Lead Sub Category',
                                        fillColor: Colors.white,
                                        filled: true,
                                        prefixIcon: const Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Colors.grey),
                                        border: const OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        labelStyle:
                                            const TextStyle(color: Colors.grey),
                                        hintText: leadSubTypeList!.data!.isEmpty
                                            ? 'No subcategories available'
                                            : 'Select Sub Category',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextFormField(
                        controller: leadSourceVal,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController searchController =
                                  TextEditingController();
                              List<LeadSource> filteredList =
                                  List.from(commonDetails!.data.leadSource);

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text('Lead Source'),
                                    content: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: searchController,
                                            onChanged: (value) {
                                              setState(() {
                                                filteredList = commonDetails!
                                                    .data.leadSource
                                                    .where((src) => src
                                                        .leadSource
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()))
                                                    .toList();
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: "Search",
                                              prefixIcon: const Icon(
                                                  Icons.search,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Expanded(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: filteredList.length,
                                              itemBuilder: (context, ind) {
                                                return InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      leadSource =
                                                          filteredList[ind]
                                                              .leadSource;
                                                      leadSourceId =
                                                          filteredList[ind]
                                                              .leadSourceId
                                                              .toString();
                                                      leadSourceVal.text =
                                                          filteredList[ind]
                                                              .leadSource
                                                              .toString();
                                                      Navigator.pop(
                                                          context, true);
                                                    });
                                                  },
                                                  child: SizedBox(
                                                    height: 45,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        filteredList[ind]
                                                            .leadSource,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
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
                            },
                          );
                        },
                        maxLines: 1,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.only(left: 10, top: 2, bottom: 2),
                          labelText: 'Lead Source',
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: contactNo,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Contact Number',
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
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: const TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    // SizedBox(height: 10,),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20, right: 20),
                    //   child: InputTextField(
                    //     hintText: 'Contact Number',
                    //     hintTextColor: Colors.white,
                    //     backgroundColor: Colors.white,
                    //     controller: contactNo,
                    //     keyboardType: TextInputType.number,
                    //     width: 1,
                    //     iconData: Icons.phone_android,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: assignUserval,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // Temporary list for filtering
                                List filteredStaff =
                                    List.from(commonDetails!.data.staff);
                                TextEditingController searchController =
                                    TextEditingController();

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text('Assign Staff'),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: Column(
                                          children: [
                                            // Search box
                                            TextField(
                                              controller: searchController,
                                              decoration: InputDecoration(
                                                hintText: "Search staff...",
                                                prefixIcon:
                                                    const Icon(Icons.search),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  filteredStaff = commonDetails!
                                                      .data.staff
                                                      .where((element) => element
                                                          .staffName
                                                          .toString()
                                                          .toLowerCase()
                                                          .contains(value
                                                              .toLowerCase()))
                                                      .toList();
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            // Staff list
                                            Expanded(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: filteredStaff.length,
                                                itemBuilder: (context, ind) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        assignUserval.text =
                                                            filteredStaff[ind]
                                                                .staffName
                                                                .toString();
                                                        assignStaff =
                                                            filteredStaff[ind]
                                                                .staffName
                                                                .toString();
                                                        assignStaffId =
                                                            filteredStaff[ind]
                                                                .userId
                                                                .toString();
                                                        Navigator.pop(
                                                            context, true);
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      height: 50,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8,
                                                                horizontal: 5),
                                                        child: Text(
                                                          filteredStaff[ind]
                                                              .staffName
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
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
                              },
                            );
                          },
                          maxLines: 1,
                          readOnly: true,
                          decoration: const InputDecoration(
                              labelText: 'Assign Staff',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextFormField(
                        controller: cost,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Cost',
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon:
                                Icon(Icons.currency_rupee, color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),

                      // InputTextField(
                      //   hintText: 'Cost',
                      //   hintTextColor: Colors.white,
                      //   backgroundColor: Colors.white,
                      //   controller: cost,
                      //   keyboardType: TextInputType.number,
                      //   width: 1,
                      //   iconData: Icons.currency_rupee,
                      // ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: priorityVal,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text('Priority'),
                                    content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .24,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              .8,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            commonDetails!.data.priority.length,
                                        itemBuilder: (context, ind) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                priorityVal.text =
                                                    commonDetails!.data
                                                        .priority[ind].priority
                                                        .toString();
                                                priority = commonDetails!
                                                    .data.priority[ind].priority
                                                    .toString();
                                                priorityId = commonDetails!.data
                                                    .priority[ind].priorityId
                                                    .toString();
                                                Navigator.pop(context, true);
                                              });
                                            },
                                            child: SizedBox(
                                              height: 50,
                                              child: Text(
                                                commonDetails!
                                                    .data.priority[ind].priority
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                });
                          },
                          maxLines: 1,
                          readOnly: true,
                          decoration: const InputDecoration(
                              labelText: 'Priority',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: InputTextField(
                        hintText: 'Address',
                        hintTextColor: Colors.white,
                        backgroundColor: Colors.white,
                        controller: address,
                        width: 1,
                        height: 80,
                        maxLine: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 19, right: 10),
                      child: SizedBox(
                        width: 326, // set your desired width
                        child: TextFormField(
                          controller: pinCode,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 10, top: 2, bottom: 2),
                            labelText: 'PIN Code',
                            fillColor: Colors.white,
                            filled: true,
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: const TextStyle(color: Colors.grey),
                          ),
                          onChanged: (value) async {
                            await loadPostOffices(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const SizedBox(height: 15),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),

                    if (postOffices.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 19),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 326,
                            child: DropdownButtonFormField<PostOffice>(
                              value: selectedPostOffice,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: "Select Post Office",
                                border: OutlineInputBorder(),
                              ),
                              items: postOffices.map((postOffice) {
                                return DropdownMenuItem<PostOffice>(
                                  value: postOffice,
                                  child: Text(postOffice.name ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPostOffice = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                    if (postOffices.isNotEmpty) const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 19),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              SizedBox(
                                width: 326,
                                child: TextFormField(
                                  controller: stateVal,
                                  readOnly: true,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        TextEditingController searchController =
                                            TextEditingController();
                                        List<StateList> filteredList =
                                            List.from(stateDetails!.data);

                                        return StatefulBuilder(
                                          builder: (context, setStateSB) {
                                            return AlertDialog(
                                              title: const Text('Select State'),
                                              content: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.55,
                                                child: Column(
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          searchController,
                                                      onChanged: (value) {
                                                        setStateSB(() {
                                                          filteredList = stateDetails!
                                                              .data
                                                              .where((item) => item
                                                                  .name
                                                                  .toLowerCase()
                                                                  .contains(value
                                                                      .toLowerCase()))
                                                              .toList();
                                                        });
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Search State",
                                                        prefixIcon: const Icon(
                                                            Icons.search,
                                                            color: Colors.grey),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount:
                                                            filteredList.length,
                                                        itemBuilder:
                                                            (context, ind) {
                                                          return InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                stateVal.text =
                                                                    filteredList[
                                                                            ind]
                                                                        .name;
                                                                StateId =
                                                                    filteredList[
                                                                            ind]
                                                                        .id;
                                                                districtVal
                                                                    .clear();
                                                                districtList =
                                                                    [];
                                                                isDistrictLoading =
                                                                    true;
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                              await loadDistricts(
                                                                  StateId!);
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          5),
                                                              child: Text(
                                                                filteredList[
                                                                        ind]
                                                                    .name,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18),
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
                                      },
                                    );
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'State',
                                    prefixIcon: Icon(
                                        Icons.arrow_drop_down_circle_outlined,
                                        color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          if (isDistrictLoading)
                            const Center(child: CircularProgressIndicator()),
                          if (!isDistrictLoading && districtList.isNotEmpty)
                            SizedBox(
                              width: 326,
                              child: DropdownButtonFormField<DistrictList>(
                                value: districtList.firstWhere(
                                  (d) => d.id == DistrictId,
                                  orElse: () => districtList.first,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Select District',
                                  border: OutlineInputBorder(),
                                ),
                                items: districtList.map((d) {
                                  return DropdownMenuItem<DistrictList>(
                                    value: d,
                                    child: Text(d.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      DistrictId = value.id;
                                      districtVal.text = value.name;
                                    });
                                  }
                                },
                              ),
                            )
                          else if (!isDistrictLoading)
                            TextFormField(
                              controller: districtVal,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'District',
                                hintText: 'No districts available',
                                border: OutlineInputBorder(),
                              ),
                            )
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: InputTextField(
                        hintText: 'Remarks',
                        hintTextColor: Colors.white,
                        backgroundColor: Colors.white,
                        controller: remark,
                        width: 1,
                        height: 80,
                        maxLine: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    ListView.builder(
                      itemCount:
                          leadDetailsAdditional!.data.additionalFields.length,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            decriptionUi(index),
                          ],
                        );
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        if (globalKey.currentState!.validate()) {
                          globalKey.currentState!.save();
                          descriptions.removeWhere(
                              (item) => ["", null, false, 0].contains(item));
                          final connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult is List<ConnectivityResult>) {
                            if (connectivityResult
                                    .contains(ConnectivityResult.mobile) ||
                                connectivityResult
                                    .contains(ConnectivityResult.wifi)) {
                              // if (connectivityResult == ConnectivityResult.mobile ||
                              //     connectivityResult == ConnectivityResult.wifi) {
                              if (multiBranch == 'true' &&
                                  roleId == '2' &&
                                  branch == null) {
                                Common.toastMessaage(
                                    'Choose Branch', Colors.red);
                              } else if (clientName.text.isEmpty) {
                                Common.toastMessaage(
                                    'Customer Name cannot be empty',
                                    Colors.red);
                              } else if (contactNo.text.isEmpty) {
                                Common.toastMessaage(
                                    'Contact Number cannot be empty',
                                    Colors.red);
                              } else if (code == '') {
                                Common.toastMessaage(
                                    'Select country code', Colors.red);
                              } else if (code == '91' &&
                                  contactNo.text.length != 10) {
                                Common.toastMessaage(
                                    'Phone Number must be 10 digit',
                                    Colors.red);
                              } else if (assignStaffId == '') {
                                Common.toastMessaage(
                                    'Staff cannot be empty', Colors.red);
                              } else if (cost.text.isEmpty) {
                                Common.toastMessaage(
                                    'Cost cannot be empty', Colors.red);
                              } else if (priorityId == '') {
                                Common.toastMessaage(
                                    'Priority cannot be empty', Colors.red);
                              } else {
                                if (context.mounted) {
                                  Common.showProgressDialog(
                                      context, "Loading..");
                                }
                                EditLeadModel object =
                                    await HttpService.editLeads(
                                        widget.token,
                                        widget.callMasterId,
                                        branch,
                                        clientName.text,
                                        companyNameCtrl.text,
                                        leadTypeId,
                                        leadSubTypeId,
                                        contactNo.text,
                                        assignStaffId,
                                        cost.text,
                                        priorityId,
                                        address.text,
                                        pinCode.text,
                                        selectedPostOffice?.name ?? "",
                                        remark.text,
                                        "1",
                                        "",
                                        "",
                                        "0",
                                        "",
                                        descriptions,
                                        code,
                                        leadSourceId,
                                        stateId: StateId,
                                        districtId: DistrictId);
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
                            }
                          } else {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'No Network Found..Try Again Later..'),
                                  backgroundColor: Colors.redAccent,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                ),
                              );
                            });
                          }
                        }
                      },
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * .45,
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
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
            ),
    );
  }

  Widget decriptionUi(index) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: TextFormField(
              controller: _controllers[index],
              onSaved: (val) {
                descriptions.add("");
                descriptions[index] = {
                  "id": leadDetailsAdditional!.data.additionalFields[index].id,
                  "name":
                      leadDetailsAdditional!.data.additionalFields[index].name,
                  "value": val
                };
              },
              onFieldSubmitted: (v) {
                setState(() {
                  _controllers[index].text = v;
                });
              },
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                  labelText:
                      leadDetailsAdditional!.data.additionalFields[index].name,
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.arrow_drop_down_circle,
                      color: Colors.grey),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: const TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
