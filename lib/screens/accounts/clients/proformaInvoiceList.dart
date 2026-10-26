// // ignore_for_file: must_be_immutable

// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:login2/models/clients/getInvoiceSearchData.dart';
// import 'package:login2/models/clients/invoiceListTempModel.dart';
// import 'package:login2/screens/accounts/clients/addInvoiceTemp.dart';
// import 'package:login2/screens/accounts/clients/editInvoiceTemp.dart';
// import 'package:login2/screens/accounts/clients/print_invoice_view_temp.dart';
// import 'package:login2/screens/accounts/clients/receiptByInvoice.dart';
// import 'package:login2/screens/accounts/renewal_mannagement/edit_custom_renewal.dart';
// import 'package:login2/screens/accounts/renewal_mannagement/edit_quick_renewal.dart';
// import 'package:login2/screens/customer/customerDasboard.dart';
// import 'package:lottie/lottie.dart';
// import '../../../core/common.dart';
// import '../../../models/clients/deleteInvoiceModel.dart';
// import '../../../service/service.dart';
// import 'addInvoice.dart';
// import 'addReceipt.dart';
// import 'clientDetails.dart';
// import 'editInvoice.dart';

// class ProformaInvoiceList extends StatefulWidget {
//   String token;
//   String custId;
//   String custName;
//   String status;
//   String isDash;
//   ProformaInvoiceList(
//       this.token, this.custId, this.custName, this.status, this.isDash,
//       {super.key});

//   @override
//   State<ProformaInvoiceList> createState() => _ProformaInvoiceListState();
// }

// class _ProformaInvoiceListState extends State<ProformaInvoiceList> {
//   String fDate = DateFormat('dd-MM-yyyy')
//       .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
//   String tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
//   InvoiceListModelTemp? invoiceList;
//   GetInvoiceSearchData? searchData;
//   bool result = true;
//   List<Customer> customers = [];
//   List<Customer> filteredCustomers = [];
//   String customerId = "";
//   String customerName = "Choose Customer";
//   List<Staff> staffs = [];
//   List<Staff> filteredStaffs = [];
//   String staffId = "";
//   String staffName = "Choose Staff";
//   List<Type> types = [];
//   List<Type> filteredTypes = [];
//   Map<int, bool> _pdfLoadingStates = {};
//   String typeId = "";
//   String typeName = "Choose Type";
//   TextEditingController search = TextEditingController();
//   bool isSearch = false;
//   List<String> collectedByNames = [];
//   List<String> collectedByIds = [];
//   List<String> createdByNames = [];
//   List<String> createdByIds = [];
//   Timer? _debounce;
//   String? name = '';
//   String? role = '';
//   String? userId = '';
//   String? phoneCallLogPermission = '';
//   List<String> selectedStaffIds = [];
//   List<String> selectedStaffNames = [];
//   List<String> selectedStatuses = [];
//   List<String> selectedCustomerIds = [];
//   List<String> selectedCustomerNames = [];
//   List<String> selectedTypeIds = [];
//   List<String> selectedTypeNames = [];
//   int page = 1;
//   List<GetInvoiceSearchData> items = [];

//   bool _isStatusSelected(String status) {
//     return selectedStatuses.contains(status);
//   }

//   void _addStatus(String status) {
//     if (!selectedStatuses.contains(status)) {
//       selectedStatuses.add(status);
//     }
//   }

//   void _removeStatus(String status) {
//     selectedStatuses.remove(status);
//   }

//   void _clearAllStatuses() {
//     selectedStatuses.clear();
//   }

//   List<String> _getSelectedStatuses() {
//     return List.from(selectedStatuses);
//   }

//   @override
//   void initState() {
//     super.initState();
//     print(
//         'Token: ${widget.token}, CustId: ${widget.custId}, Status: ${widget.status}');
//     getData();
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     search.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         setState(() {
//           page = 1;
//           items.clear();
//           getData();
//         });
//       }
//     });
//   }

//   // getData() async {
//   //   name = await Common.getSharedPref("name");
//   //   role = await Common.getSharedPref("role");
//   //   userId = await Common.getSharedPref("userId");
//   //   phoneCallLogPermission =
//   //       await Common.getSharedPref("phoneCallLogPermission");
//   //   customers.clear();
//   //   filteredCustomers.clear();
//   //   final connectivityResult = await (Connectivity().checkConnectivity());
//   //   // if (connectivityResult == ConnectivityResult.mobile ||
//   //   //     connectivityResult == ConnectivityResult.wifi) {
//   //   //   setState(() {
//   //   //     result = true;
//   //   //   });
//   //   // } else {
//   //   //   setState(() {
//   //   //     result = false;
//   //   //   });
//   //   // }
//   //   if (connectivityResult is List<ConnectivityResult>) {
//   //     if (connectivityResult.contains(ConnectivityResult.mobile) ||
//   //         connectivityResult.contains(ConnectivityResult.wifi)) {
//   //       setState(() {
//   //         result = true;
//   //       });
//   //     }
//   //   } else {
//   //     setState(() {
//   //       result = false;
//   //     });
//   //   }

//   //   String collectedByStaffIds = collectedByIds.join(',');
//   //   String createdByStaffIds = createdByIds.join(',');
//   //   String statusFilter = selectedStatuses.join(',');
//   //   String customerFilter = selectedCustomerIds.join(',');
//   //   String typeFilter = selectedTypeIds.join(',');
//   //   String searchQuery = search.text.trim();

//   //   // invoiceList = await HttpService.invoiceListTemp(
//   //   //     widget.token,
//   //   //     widget.isDash,
//   //   //     widget.status,
//   //   //     widget.custId,
//   //   //     fDate == "From Date" ? "" : fDate.toString(),
//   //   //     tDate == "To Date" ? "" : tDate.toString(),
//   //   //     customerFilter,
//   //   //     collectedByStaffIds,
//   //   //     createdByStaffIds,
//   //   //     staffId,
//   //   //     typeFilter,
//   //   //     statusFilter);
//   //   print("--- 1. Calling invoiceListTemp ---");
//   //   invoiceList = await HttpService.invoiceListTemp(
//   //       widget.token,
//   //       widget.isDash,
//   //       widget.status,
//   //       widget.custId,
//   //       fDate == "From Date" ? "" : fDate.toString(),
//   //       tDate == "To Date" ? "" : tDate.toString(),
//   //       customerFilter,
//   //       collectedByStaffIds,
//   //       createdByStaffIds,
//   //       staffId,
//   //       typeFilter,
//   //       statusFilter);
//   //   print("--- 2. Finished invoiceListTemp, result: $invoiceList ---");

//   //   print("--- 3. Calling getInvoiceSearchTemp ---");
//   //   searchData = await HttpService.getInvoiceSearchTemp(widget.token);
//   //   print("--- 4. Finished getInvoiceSearchTemp ---");

//   //   if (invoiceList != null) {
//   //     // Apply local search filtering
//   //     if (searchQuery.isNotEmpty) {
//   //       invoiceList!.data.lists = invoiceList!.data.lists.where((invoice) {
//   //         return invoice.customerName
//   //                 .toLowerCase()
//   //                 .contains(searchQuery.toLowerCase()) ||
//   //             invoice.invoiceNumber
//   //                 .toLowerCase()
//   //                 .contains(searchQuery.toLowerCase()) ||
//   //             (invoice.products.isNotEmpty &&
//   //                 invoice.products[0].productName
//   //                     .toLowerCase()
//   //                     .contains(searchQuery.toLowerCase())) ||
//   //             invoice.createdBy
//   //                 .toLowerCase()
//   //                 .contains(searchQuery.toLowerCase());
//   //       }).toList();
//   //     }

//   //     searchData = await HttpService.getInvoiceSearchTemp(widget.token);
//   //     customers = searchData!.data.customers;
//   //     filteredCustomers = List.from(customers);
//   //     staffs = searchData!.data.staff;
//   //     filteredStaffs = List.from(staffs);
//   //     types = searchData!.data.types;
//   //     filteredTypes = List.from(types);
//   //     if (isSearch == true) {
//   //       isSearch = false;
//   //       if (mounted) {
//   //         Navigator.pop(context);
//   //       }
//   //     }
//   //     setState(() {});
//   //   }
//   // }

//   getData() async {
//     // 1. Show loading state at the start if you have a loading flag
//     // setState(() => isLoading = true);

//     try {
//       name = await Common.getSharedPref("name");
//       role = await Common.getSharedPref("role");
//       userId = await Common.getSharedPref("userId");
//       phoneCallLogPermission =
//           await Common.getSharedPref("phoneCallLogPermission");

//       customers.clear();
//       filteredCustomers.clear();

//       final connectivityResult = await (Connectivity().checkConnectivity());
//       if (connectivityResult is List<ConnectivityResult>) {
//         if (connectivityResult.contains(ConnectivityResult.mobile) ||
//             connectivityResult.contains(ConnectivityResult.wifi)) {
//           result = true;
//         } else {
//           result = false;
//         }
//       } else {
//         result = true; // Fallback for single result types if applicable
//       }

//       String collectedByStaffIds = collectedByIds.join(',');
//       String createdByStaffIds = createdByIds.join(',');
//       String statusFilter = selectedStatuses.join(',');
//       String customerFilter = selectedCustomerIds.join(',');
//       String typeFilter = selectedTypeIds.join(',');
//       String searchQuery = search.text.trim();

//       // 2. Fetch primary invoice list
//       print("--- 1. Calling invoiceListTemp ---");
//       invoiceList = await HttpService.invoiceListTemp(
//           widget.token,
//           widget.isDash,
//           widget.status,
//           widget.custId,
//           fDate == "From Date" ? "" : fDate.toString(),
//           tDate == "To Date" ? "" : tDate.toString(),
//           customerFilter,
//           collectedByStaffIds,
//           createdByStaffIds,
//           staffId,
//           typeFilter,
//           statusFilter);
//       print("--- 2. Finished invoiceListTemp, result: $invoiceList ---");

//       print("--- 3. Calling getInvoiceSearchTemp ---");
//       searchData = await HttpService.getInvoiceSearchTemp(widget.token);
//       print("--- 4. Finished getInvoiceSearchTemp ---");

//       if (invoiceList != null && invoiceList!.data != null) {
//         // Apply local search filtering
//         if (searchQuery.isNotEmpty) {
//           invoiceList!.data.lists = invoiceList!.data.lists.where((invoice) {
//             return invoice.customerName
//                     .toLowerCase()
//                     .contains(searchQuery.toLowerCase()) ||
//                 invoice.invoiceNumber
//                     .toLowerCase()
//                     .contains(searchQuery.toLowerCase()) ||
//                 (invoice.products.isNotEmpty &&
//                     invoice.products[0].productName
//                         .toLowerCase()
//                         .contains(searchQuery.toLowerCase())) ||
//                 invoice.createdBy
//                     .toLowerCase()
//                     .contains(searchQuery.toLowerCase());
//           }).toList();
//         }
//       }

//       // 3. Fetch search metadata safely
//       searchData = await HttpService.getInvoiceSearchTemp(widget.token);
//       if (searchData != null && searchData!.data != null) {
//         customers = searchData!.data.customers;
//         filteredCustomers = List.from(customers);
//         staffs = searchData!.data.staff;
//         filteredStaffs = List.from(staffs);
//         types = searchData!.data.types;
//         filteredTypes = List.from(types);
//       }

//       if (isSearch == true) {
//         isSearch = false;
//         if (mounted) {
//           Navigator.pop(context);
//         }
//       }
//     } catch (e) {
//       print("Error in getData: $e");
//     } finally {
//       // 4. CRITICAL: Always trigger setState so the spinner stops and UI updates
//       if (mounted) {
//         setState(() {
//           // isLoading = false; // Turn off your loading flag here if you use one
//         });
//       }
//     }
//   }

//   void clearAllFilters() {
//     fDate = DateFormat('dd-MM-yyyy')
//         .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
//     tDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     staffId = "";
//     staffName = "Choose Staff";
//     createdByIds.clear();
//     createdByNames.clear();
//     collectedByIds.clear();
//     collectedByNames.clear();
//     selectedStatuses.clear();
//     selectedCustomerIds.clear();
//     selectedCustomerNames.clear();
//     selectedTypeIds.clear();
//     selectedTypeNames.clear();
//     customerId = "";
//     customerName = "Choose Customer";
//     typeId = "";
//     typeName = "Choose Type";
//     filteredCustomers = List.from(customers);
//     filteredStaffs = List.from(staffs);
//     filteredTypes = List.from(types);
//     search.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return result == true
//         ? Scaffold(
//             backgroundColor: Colors.grey.shade300,
//             appBar: widget.custName != ""
//                 ? PreferredSize(
//                     preferredSize: Size.fromHeight(
//                         MediaQuery.of(context).size.height * 0.08),
//                     child: Container(
//                       padding: EdgeInsets.only(
//                           top: MediaQuery.of(context).padding.top),
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                             colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 10.0, top: 10.0, bottom: 10.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 InkWell(
//                                   onTap: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Container(
//                                     height: 25,
//                                     width: 25,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.white),
//                                         shape: BoxShape.circle),
//                                     child: const Icon(
//                                       Icons.arrow_back_ios_outlined,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 25,
//                                 ),
//                                 // const Text(
//                                 //   'Proforma Invoice List',
//                                 //   style: TextStyle(color: Colors.white, fontSize: 18),
//                                 // ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     if (widget.custName != null &&
//                                         widget.custName!.isNotEmpty)
//                                       Text(
//                                         widget.custName!,
//                                         //  "Customer Leads",
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 0.5,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     SizedBox(height: 5),
//                                     Text(
//                                       // widget.customerName!,
//                                       "Proforma Invoice List",
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.normal,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 8.0),
//                                   child: InkWell(
//                                     onTap: () {
//                                       filtrationSheet(context);
//                                     },
//                                     child: Container(
//                                       width: 30,
//                                       height: 30,
//                                       decoration: BoxDecoration(
//                                           border:
//                                               Border.all(color: Colors.grey),
//                                           color: const Color(0xFFd5f5f4),
//                                           borderRadius:
//                                               BorderRadius.circular(5)),
//                                       child: Center(
//                                           child: Image.asset(
//                                               "assets/icons/filter.png",
//                                               width: 20)),
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () async {
//                                     addInvoiceDialogTemp(context);
//                                   },
//                                   icon: const Icon(
//                                     Icons.add_circle,
//                                     color: Colors.white,
//                                     size: 30,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 : PreferredSize(
//                     preferredSize: Size.fromHeight(
//                         MediaQuery.of(context).size.height * 0.08),
//                     child: Container(
//                       padding: EdgeInsets.only(
//                           top: MediaQuery.of(context).padding.top),
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                             colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 10.0, top: 10.0, bottom: 10.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 InkWell(
//                                   onTap: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Container(
//                                     height: 25,
//                                     width: 25,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.white),
//                                         shape: BoxShape.circle),
//                                     child: const Icon(
//                                       Icons.arrow_back_ios_outlined,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 25,
//                                 ),
//                                 const Text(
//                                   'Proforma Invoice List',
//                                   style: TextStyle(
//                                       color: Colors.white, fontSize: 18),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 8.0),
//                                   child: InkWell(
//                                     onTap: () {
//                                       filtrationSheet(context);
//                                     },
//                                     child: Container(
//                                       width: 30,
//                                       height: 30,
//                                       decoration: BoxDecoration(
//                                           border:
//                                               Border.all(color: Colors.grey),
//                                           color: const Color(0xFFd5f5f4),
//                                           borderRadius:
//                                               BorderRadius.circular(5)),
//                                       child: Center(
//                                           child: Image.asset(
//                                               "assets/icons/filter.png",
//                                               width: 20)),
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () async {
//                                     addInvoiceDialogTemp(context);
//                                   },
//                                   icon: const Icon(
//                                     Icons.add_circle,
//                                     color: Colors.white,
//                                     size: 30,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//             body: invoiceList != null && searchData != null
//                 ? Column(
//                     children: [
//                       // Search Bar
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: search,
//                                 onChanged: (val) {
//                                   _onSearchChanged(val);
//                                 },
//                                 onFieldSubmitted: (value) {
//                                   page = 1;
//                                   items.clear();
//                                   getData();
//                                 },
//                                 style: const TextStyle(color: Colors.black),
//                                 decoration: InputDecoration(
//                                   hintText: 'Search by Customer Name',
//                                   hintStyle:
//                                       const TextStyle(color: Colors.grey),
//                                   prefixIcon: const Icon(Icons.search,
//                                       color: Colors.grey),
//                                   suffixIcon: search.text.isNotEmpty
//                                       ? IconButton(
//                                           icon: const Icon(Icons.clear,
//                                               color: Colors.grey),
//                                           onPressed: () {
//                                             search.clear();
//                                             page = 1;
//                                             items.clear();
//                                             getData();
//                                           },
//                                         )
//                                       : null,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 10, horizontal: 12),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                     borderSide:
//                                         BorderSide(color: Colors.grey.shade300),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                     borderSide:
//                                         BorderSide(color: Colors.grey.shade300),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             // Clear all filters button
//                             if (search.text.isNotEmpty ||
//                                 selectedStatuses.isNotEmpty ||
//                                 selectedCustomerIds.isNotEmpty ||
//                                 selectedTypeIds.isNotEmpty ||
//                                 createdByIds.isNotEmpty ||
//                                 fDate !=
//                                     DateFormat('dd-MM-yyyy').format(DateTime(
//                                         DateTime.now().year,
//                                         DateTime.now().month,
//                                         1)) ||
//                                 tDate !=
//                                     DateFormat('dd-MM-yyyy')
//                                         .format(DateTime.now()))
//                               IconButton(
//                                 onPressed: () {
//                                   clearAllFilters();
//                                   getData();
//                                 },
//                                 icon: const Icon(Icons.refresh,
//                                     color: Colors.blue),
//                                 tooltip: 'Clear all filters',
//                               ),
//                           ],
//                         ),
//                       ),
//                       // Invoice List
//                       Expanded(
//                         child: Stack(
//                           alignment: Alignment.topCenter,
//                           children: [
//                             SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 12,
//                                         right: 12,
//                                         top: 12,
//                                         bottom: 80),
//                                     child: invoiceList!.data.lists.isNotEmpty
//                                         ? ListView.builder(
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             shrinkWrap: true,
//                                             itemCount:
//                                                 invoiceList!.data.lists.length,
//                                             itemBuilder: (context, index) {
//                                               return Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     bottom: 10),
//                                                 child: InkWell(
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                         boxShadow: [
//                                                           BoxShadow(
//                                                             color: Colors.grey
//                                                                 .withOpacity(
//                                                                     0.2),
//                                                             spreadRadius: 1,
//                                                             blurRadius: 1,
//                                                             offset:
//                                                                 const Offset(
//                                                                     1, 1),
//                                                           )
//                                                         ],
//                                                         borderRadius:
//                                                             BorderRadius.circular(
//                                                                 5),
//                                                         color: invoiceList!
//                                                                     .data
//                                                                     .lists[
//                                                                         index]
//                                                                     .invoiceCreated
//                                                                     .toString() ==
//                                                                 "1"
//                                                             ? const Color.fromARGB(
//                                                                 255, 228, 248, 216)
//                                                             : invoiceList!.data.lists[index].isApproved
//                                                                         .toString() ==
//                                                                     "Y"
//                                                                 ? const Color.fromARGB(
//                                                                     255, 243, 248, 216)
//                                                                 : invoiceList!
//                                                                             .data
//                                                                             .lists[index]
//                                                                             .isRejected
//                                                                             .toString() ==
//                                                                         "Y"
//                                                                     ? const Color.fromARGB(255, 248, 216, 216)
//                                                                     : Colors.white),
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               14.0),
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               SizedBox(
//                                                                 width: MediaQuery.of(
//                                                                             context)
//                                                                         .size
//                                                                         .width *
//                                                                     0.6,
//                                                                 child: InkWell(
//                                                                   onTap: () {
//                                                                     // Navigator.push(
//                                                                     //   context,
//                                                                     //   MaterialPageRoute(
//                                                                     //       builder: (context) => ClientDetails(
//                                                                     //           widget
//                                                                     //               .token,
//                                                                     //           invoiceList!
//                                                                     //               .data
//                                                                     //               .lists[index]
//                                                                     //               .clientId
//                                                                     //               .toString())),
//                                                                     // );
//                                                                     Navigator
//                                                                         .push(
//                                                                       context,
//                                                                       MaterialPageRoute(
//                                                                         builder: (context) => CustomerDashboard(
//                                                                             name:
//                                                                                 name!,
//                                                                             token: widget
//                                                                                 .token!,
//                                                                             userId:
//                                                                                 userId!,
//                                                                             phoneCallLogPermission:
//                                                                                 phoneCallLogPermission,
//                                                                             custId:
//                                                                                 invoiceList!.data.lists[index].clientId.toString()),
//                                                                       ),
//                                                                     );
//                                                                   },
//                                                                   child: Text(
//                                                                       invoiceList!
//                                                                           .data
//                                                                           .lists[
//                                                                               index]
//                                                                           .customerName
//                                                                           .toString(),
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                       style:
//                                                                           const TextStyle(
//                                                                         fontSize:
//                                                                             16,
//                                                                         fontWeight:
//                                                                             FontWeight.w600,
//                                                                       )),
//                                                                 ),
//                                                               ),
//                                                               Container(
//                                                                 decoration: BoxDecoration(
//                                                                     borderRadius:
//                                                                         BorderRadius
//                                                                             .circular(
//                                                                                 2),
//                                                                     color: invoiceList!.data.lists[index].invoiceCreated.toString() ==
//                                                                             '1'
//                                                                         ? const Color
//                                                                             .fromARGB(
//                                                                             255,
//                                                                             52,
//                                                                             185,
//                                                                             90)
//                                                                         : const Color(
//                                                                             0xfffcbcbc)),
//                                                                 child: Center(
//                                                                   child:
//                                                                       Padding(
//                                                                     padding: const EdgeInsets
//                                                                         .only(
//                                                                         left:
//                                                                             12,
//                                                                         right:
//                                                                             12,
//                                                                         top: 6,
//                                                                         bottom:
//                                                                             6),
//                                                                     child: Text(
//                                                                         invoiceList!.data.lists[index].invoiceCreated.toString() ==
//                                                                                 '1'
//                                                                             ? "Created"
//                                                                             : invoiceList!.data.lists[index].isApproved.toString() == "Y"
//                                                                                 ? "Approved"
//                                                                                 : invoiceList!.data.lists[index].isRejected.toString() == "Y"
//                                                                                     ? "Rejected"
//                                                                                     : "Not Created",
//                                                                         style: TextStyle(
//                                                                           color: invoiceList!.data.lists[index].invoiceCreated.toString() == '1'
//                                                                               ? Colors.white
//                                                                               : invoiceList!.data.lists[index].isApproved.toString() == "Y"
//                                                                                   ? const Color.fromARGB(255, 240, 255, 154)
//                                                                                   : invoiceList!.data.lists[index].isRejected.toString() == "Y"
//                                                                                       ? const Color.fromARGB(255, 255, 126, 180)
//                                                                                       : Colors.red,
//                                                                           fontSize:
//                                                                               14,
//                                                                           fontWeight:
//                                                                               FontWeight.w600,
//                                                                         )),
//                                                                   ),
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 5,
//                                                           ),
//                                                           SizedBox(
//                                                             width: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .width *
//                                                                 0.6,
//                                                             child: Text(
//                                                               "Proforma No : ${invoiceList!.data.lists[index].invoiceNumber}",
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                               style:
//                                                                   const TextStyle(
//                                                                 fontSize: 14,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w400,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 5,
//                                                           ),
//                                                           SizedBox(
//                                                             width: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .width *
//                                                                 0.8,
//                                                             child: Text(
//                                                               invoiceList!
//                                                                           .data
//                                                                           .lists[
//                                                                               index]
//                                                                           .products
//                                                                           .length !=
//                                                                       1
//                                                                   ? "Products : ${invoiceList!.data.lists[index].products[0].productName} + ${invoiceList!.data.lists[index].products.length - 1} more..."
//                                                                   : "Products : ${invoiceList!.data.lists[index].products[0].productName}",
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                               style:
//                                                                   const TextStyle(
//                                                                 fontSize: 14,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w400,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 5,
//                                                           ),
//                                                           SizedBox(
//                                                             width: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .width *
//                                                                 0.6,
//                                                             child: Text(
//                                                               "Total Amount : ₹ ${invoiceList!.data.lists[index].totalAmount}",
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                               style:
//                                                                   const TextStyle(
//                                                                 fontSize: 14,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w400,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 5,
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               SizedBox(
//                                                                 width: MediaQuery.of(
//                                                                             context)
//                                                                         .size
//                                                                         .width *
//                                                                     0.6,
//                                                                 child: Text(
//                                                                   "Created By : ${invoiceList!.data.lists[index].createdBy}",
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                   style:
//                                                                       const TextStyle(
//                                                                     fontSize:
//                                                                         14,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w400,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 5,
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               Row(
//                                                                 children: [
//                                                                   Column(
//                                                                     crossAxisAlignment:
//                                                                         CrossAxisAlignment
//                                                                             .start,
//                                                                     children: [
//                                                                       const SizedBox(
//                                                                         height:
//                                                                             5,
//                                                                       ),
//                                                                       Row(
//                                                                         children: [
//                                                                           const Icon(
//                                                                             Icons.calendar_month,
//                                                                             color:
//                                                                                 Colors.grey,
//                                                                             size:
//                                                                                 20,
//                                                                           ),
//                                                                           const SizedBox(
//                                                                             width:
//                                                                                 8,
//                                                                           ),
//                                                                           Text(
//                                                                               "${invoiceList!.data.lists[index].invoiceDate} ${invoiceList!.data.lists[index].invoiceAt}",
//                                                                               maxLines: 2,
//                                                                               overflow: TextOverflow.ellipsis,
//                                                                               style: const TextStyle(
//                                                                                 fontSize: 12,
//                                                                                 fontWeight: FontWeight.w400,
//                                                                               )),
//                                                                         ],
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               Row(
//                                                                 children: [
//                                                                   InkWell(
//                                                                     onTap: _pdfLoadingStates[index] ==
//                                                                             true
//                                                                         ? null
//                                                                         : () async {
//                                                                             setState(() {
//                                                                               _pdfLoadingStates[index] = true;
//                                                                             });

//                                                                             final pdfPath =
//                                                                                 await HttpService.printInvoiceTemp(
//                                                                               widget.token,
//                                                                               invoiceList!.data.lists[index].id.toString(),
//                                                                             );

//                                                                             setState(() {
//                                                                               _pdfLoadingStates[index] = false;
//                                                                             });

//                                                                             if (pdfPath !=
//                                                                                 null) {
//                                                                               Navigator.push(
//                                                                                 context,
//                                                                                 MaterialPageRoute(
//                                                                                   builder: (_) => PrintInvoiceViewTemp(pdfPath: pdfPath),
//                                                                                 ),
//                                                                               );
//                                                                             } else {
//                                                                               ScaffoldMessenger.of(context).showSnackBar(
//                                                                                 const SnackBar(content: Text("Failed to load invoice")),
//                                                                               );
//                                                                             }
//                                                                           },
//                                                                     child:
//                                                                         Container(
//                                                                       decoration:
//                                                                           BoxDecoration(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(2),
//                                                                         color: _pdfLoadingStates[index] ==
//                                                                                 true
//                                                                             ? Colors.green.shade300
//                                                                             : Colors.green.shade100,
//                                                                       ),
//                                                                       child:
//                                                                           Padding(
//                                                                         padding: const EdgeInsets
//                                                                             .all(
//                                                                             8.0),
//                                                                         child: _pdfLoadingStates[index] ==
//                                                                                 true
//                                                                             ? SizedBox(
//                                                                                 height: 20,
//                                                                                 width: 20,
//                                                                                 child: CircularProgressIndicator(
//                                                                                   strokeWidth: 2,
//                                                                                   valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade800),
//                                                                                 ),
//                                                                               )
//                                                                             : Container(
//                                                                                 height: 20,
//                                                                                 width: 20,
//                                                                                 decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/icons/pdf.png'))),
//                                                                               ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   Visibility(
//                                                                     visible: invoiceList!.data.lists[index].invType ==
//                                                                             "1" ||
//                                                                         invoiceList!.data.lists[index].invType ==
//                                                                             "2",
//                                                                     child: Row(
//                                                                       children: [
//                                                                         const SizedBox(
//                                                                           width:
//                                                                               10,
//                                                                         ),
//                                                                         invoiceList!.data.lists[index].invoiceCreated ==
//                                                                                 "0"
//                                                                             ? PopupMenuButton<String>(
//                                                                                 shape: RoundedRectangleBorder(
//                                                                                   borderRadius: BorderRadius.circular(12),
//                                                                                 ),
//                                                                                 color: Colors.white,
//                                                                                 elevation: 4,
//                                                                                 onSelected: (value) async {
//                                                                                   if (value == 'delete') {
//                                                                                     showDialog(
//                                                                                       context: context,
//                                                                                       builder: (BuildContext context) {
//                                                                                         return AlertDialog(
//                                                                                           scrollable: true,
//                                                                                           title: const Text('Please Confirm'),
//                                                                                           content: const Text('Are you sure you want to delete this invoice?'),
//                                                                                           actions: [
//                                                                                             TextButton(
//                                                                                               onPressed: () => Navigator.of(context).pop(),
//                                                                                               child: const Text('No'),
//                                                                                             ),
//                                                                                             TextButton(
//                                                                                               onPressed: () async {
//                                                                                                 Common.showProgressDialog(context, "Loading...");
//                                                                                                 DeleteInvoiceModel deleteInvoice = await HttpService.deleteInvoiceTemp(
//                                                                                                   widget.token,
//                                                                                                   invoiceList!.data.lists[index].id,
//                                                                                                 );

//                                                                                                 if (deleteInvoice.data == true) {
//                                                                                                   Common.toastMessaage(deleteInvoice.message, Colors.green);
//                                                                                                   if (context.mounted) {
//                                                                                                     Navigator.pop(context);
//                                                                                                     Navigator.pop(context);
//                                                                                                   }
//                                                                                                   getData();
//                                                                                                 } else {
//                                                                                                   Common.toastMessaage(deleteInvoice.message, Colors.red);
//                                                                                                   if (context.mounted) {
//                                                                                                     Navigator.of(context).pop();
//                                                                                                   }
//                                                                                                 }
//                                                                                               },
//                                                                                               child: const Text('Yes'),
//                                                                                             ),
//                                                                                           ],
//                                                                                         );
//                                                                                       },
//                                                                                     );
//                                                                                   } else if (value == 'create') {
//                                                                                     Navigator.push(
//                                                                                       context,
//                                                                                       MaterialPageRoute(
//                                                                                         builder: (context) => AddInvoice(
//                                                                                           widget.token,
//                                                                                           invoiceList!.data.lists[index].clientId.toString(),
//                                                                                           invoiceList!.data.lists[index].id,
//                                                                                           products: invoiceList!.data.lists[index].products,
//                                                                                         ),
//                                                                                       ),
//                                                                                     );
//                                                                                   } else if (value == 'approve') {
//                                                                                     Common.showProgressDialog(context, "Approving...");
//                                                                                     bool result = await HttpService.approveProforma(
//                                                                                       invoiceList!.data.lists[index].id.toString(),
//                                                                                     );
//                                                                                     Navigator.pop(context);
//                                                                                     if (result) {
//                                                                                       Common.toastMessaage("Proforma Approved Successfully", Colors.green);
//                                                                                       getData();
//                                                                                     } else {
//                                                                                       Common.toastMessaage("Failed to approve proforma", Colors.red);
//                                                                                     }
//                                                                                   } else if (value == 'reject') {
//                                                                                     showDialog(
//                                                                                       context: context,
//                                                                                       builder: (BuildContext context) {
//                                                                                         return AlertDialog(
//                                                                                           title: const Text('Please Confirm'),
//                                                                                           content: const Text('Are you sure you want to reject this proforma?'),
//                                                                                           actions: [
//                                                                                             TextButton(
//                                                                                               onPressed: () => Navigator.of(context).pop(),
//                                                                                               child: const Text('No'),
//                                                                                             ),
//                                                                                             TextButton(
//                                                                                               onPressed: () async {
//                                                                                                 Navigator.of(context).pop();
//                                                                                                 bool result = await HttpService.rejectProforma(
//                                                                                                   invoiceList!.data.lists[index].id.toString(),
//                                                                                                 );

//                                                                                                 if (context.mounted) Navigator.pop(context);
//                                                                                                 if (result) {
//                                                                                                   Common.toastMessaage("Proforma rejected successfully", Colors.green);
//                                                                                                   getData();
//                                                                                                 } else {
//                                                                                                   Common.toastMessaage("Failed to reject proforma", Colors.red);
//                                                                                                 }
//                                                                                               },
//                                                                                               child: const Text('Yes'),
//                                                                                             ),
//                                                                                           ],
//                                                                                         );
//                                                                                       },
//                                                                                     );
//                                                                                   } else if (value == 'edit') {
//                                                                                     Navigator.push(
//                                                                                       context,
//                                                                                       MaterialPageRoute(builder: (context) => EditInvoiceTemp(widget.token, invoiceList!.data.lists[index].id.toString(), invoiceList!.data.lists[index].clientId.toString())),
//                                                                                     ).then((_) {
//                                                                                       getData();
//                                                                                     });
//                                                                                   }
//                                                                                 },
//                                                                                 itemBuilder: (context) => [
//                                                                                   const PopupMenuItem(
//                                                                                     value: 'create',
//                                                                                     child: Row(
//                                                                                       children: [
//                                                                                         Icon(Icons.add_circle_outline, color: Colors.green),
//                                                                                         SizedBox(width: 10),
//                                                                                         Text('Create Invoice'),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                   const PopupMenuItem(
//                                                                                     value: 'approve',
//                                                                                     child: Row(
//                                                                                       children: [
//                                                                                         Icon(Icons.check, color: Colors.green),
//                                                                                         SizedBox(width: 10),
//                                                                                         Text('Approve'),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                   const PopupMenuItem(
//                                                                                     value: 'reject',
//                                                                                     child: Row(
//                                                                                       children: [
//                                                                                         Icon(Icons.close, color: Color.fromARGB(255, 155, 74, 26)),
//                                                                                         SizedBox(width: 10),
//                                                                                         Text('Reject'),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                   const PopupMenuItem(
//                                                                                     value: 'edit',
//                                                                                     child: Row(
//                                                                                       children: [
//                                                                                         Icon(Icons.edit, color: Color.fromARGB(255, 78, 169, 206)),
//                                                                                         SizedBox(width: 10),
//                                                                                         Text('Edit Proforma'),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                   const PopupMenuItem(
//                                                                                     value: 'delete',
//                                                                                     child: Row(
//                                                                                       children: [
//                                                                                         Icon(Icons.delete_outline, color: Colors.red),
//                                                                                         SizedBox(width: 10),
//                                                                                         Text('Delete Proforma'),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                 ],
//                                                                                 child: Container(
//                                                                                   decoration: BoxDecoration(
//                                                                                     color: Colors.grey.shade200,
//                                                                                     borderRadius: BorderRadius.circular(4),
//                                                                                   ),
//                                                                                   padding: const EdgeInsets.all(8),
//                                                                                   child: const Icon(Icons.more_vert, color: Colors.black54),
//                                                                                 ),
//                                                                               )
//                                                                             : SizedBox(),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               )
//                                                             ],
//                                                           )
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           )
//                                         : Center(
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 SizedBox(
//                                                   width: 180,
//                                                   height: 180,
//                                                   child: Image.asset(
//                                                     "assets/icons/nodatafound.png",
//                                                   ),
//                                                 ),
//                                                 const Text(
//                                                   'No Data Found',
//                                                   style: TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w500),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   )
//                 : Center(
//                     child: Lottie.asset('assets/main/loading.json',
//                         fit: BoxFit.fill),
//                   ))
//         : Scaffold(
//             backgroundColor: Colors.white,
//             body: SizedBox(
//               width: MediaQuery.of(context).size.width * 1,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 300,
//                     height: 300,
//                     decoration: const BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage('assets/icons/noNetwork.jpg'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const Text(
//                     'No Network Found !',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(
//                     height: 15,
//                   ),
//                   InkWell(
//                     onTap: () {
//                       getData();
//                     },
//                     child: SizedBox(
//                       width: 120,
//                       height: 35,
//                       child: Padding(
//                         padding: const EdgeInsets.all(1.5),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade400,
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: const Center(
//                             child: Text(
//                               'Try Again',
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ));
//   }

//   Future<Object?> addInvoiceDialogTemp(BuildContext context) {
//     return showGeneralDialog(
//       barrierLabel: "showGeneralDialog",
//       barrierDismissible: true,
//       barrierColor: Colors.black.withOpacity(0.6),
//       transitionDuration: const Duration(milliseconds: 400),
//       context: context,
//       pageBuilder: (context, _, __) {
//         return StatefulBuilder(builder: (context, setState) {
//           return Align(
//             alignment: Alignment.center,
//             child: SingleChildScrollView(
//               child: AlertDialog(
//                 content: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Customer Details',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             return StatefulBuilder(
//                                 builder: (context, setState) {
//                               TextEditingController searchDialogController =
//                                   TextEditingController();
//                               return AlertDialog(
//                                 content: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: TextField(
//                                         controller: searchDialogController,
//                                         autocorrect: false,
//                                         keyboardType:
//                                             TextInputType.visiblePassword,
//                                         autofocus: true,
//                                         onChanged: (value) {
//                                           setState(() {
//                                             filteredCustomers = customers
//                                                 .where((item) => item.name
//                                                     .toLowerCase()
//                                                     .contains(
//                                                         value.toLowerCase()))
//                                                 .toList();
//                                           });
//                                         },
//                                         decoration: const InputDecoration(
//                                           contentPadding: EdgeInsets.all(8),
//                                           hintText: 'Search',
//                                           prefixIcon: Icon(Icons.search),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               .3,
//                                       width: MediaQuery.of(context).size.width *
//                                           .8,
//                                       child: ListView.builder(
//                                         itemCount: filteredCustomers.length,
//                                         physics: const ScrollPhysics(),
//                                         shrinkWrap: true,
//                                         itemBuilder: (context, index) {
//                                           return ListTile(
//                                               onTap: () {
//                                                 customerName =
//                                                     filteredCustomers[index]
//                                                         .name;
//                                                 customerId =
//                                                     filteredCustomers[index].id;
//                                                 searchDialogController.clear();
//                                                 filteredCustomers =
//                                                     List.from(customers);
//                                                 setState(() {});
//                                                 if (context.mounted) {
//                                                   Navigator.pop(context);
//                                                 }
//                                               },
//                                               title: Text(
//                                                   filteredCustomers[index]
//                                                       .name));
//                                         },
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 actions: [
//                                   TextButton(
//                                       onPressed: () {
//                                         searchDialogController.clear();
//                                         filteredCustomers =
//                                             List.from(customers);
//                                         if (context.mounted) {
//                                           Navigator.pop(context);
//                                         }
//                                       },
//                                       child: const Text("Close")),
//                                 ],
//                               );
//                             });
//                           },
//                         );
//                       },
//                       child: Container(
//                         width: MediaQuery.of(context).size.width * 1,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.black),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Center(
//                             child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16.0, vertical: 12.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               SizedBox(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.5,
//                                   child: Text(
//                                     customerName,
//                                     overflow: TextOverflow.ellipsis,
//                                   )),
//                             ],
//                           ),
//                         )),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         if (customerId == '') {
//                           Common.toastMessaage('Choose Client', Colors.red);
//                         } else {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => AddInvoiceTemp(
//                                     widget.token, customerId, widget.custName)),
//                           ).then((_) {
//                             getData();
//                           });
//                         }
//                       },
//                       child: Container(
//                           decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(5)),
//                           child: const Padding(
//                             padding: EdgeInsets.only(
//                                 top: 10, bottom: 10, left: 25, right: 25),
//                             child: Text(
//                               'Submit',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           )),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//       },
//       transitionBuilder: (_, animation1, __, child) {
//         return SlideTransition(
//           position: Tween(
//             begin: const Offset(0, 1),
//             end: const Offset(0, 0),
//           ).animate(animation1),
//           child: child,
//         );
//       },
//     );
//   }

//   Future<dynamic> filtrationSheet(BuildContext context) {
//     return showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         String selectedTab = "Created By";
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               height: MediaQuery.of(context).size.height * 0.75,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "Filters",
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close, color: Colors.black54),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 130,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             children: [
//                               _buildFilterTab(
//                                 icon: Icons.person_outline,
//                                 title: "Created By",
//                                 selected: selectedTab == "Created By",
//                                 onTap: () {
//                                   setState(() {
//                                     selectedTab = "Created By";
//                                   });
//                                 },
//                               ),
//                               _buildFilterTab(
//                                 icon: Icons.date_range,
//                                 title: "Date Range",
//                                 selected: selectedTab == "Date Range",
//                                 onTap: () {
//                                   setState(() {
//                                     selectedTab = "Date Range";
//                                   });
//                                 },
//                               ),
//                               _buildFilterTab(
//                                 icon: Icons.people_alt_outlined,
//                                 title: "Customer",
//                                 selected: selectedTab == "Customer",
//                                 onTap: () {
//                                   setState(() {
//                                     selectedTab = "Customer";
//                                   });
//                                 },
//                               ),
//                               _buildFilterTab(
//                                 icon: Icons.list_alt,
//                                 title: "Type",
//                                 selected: selectedTab == "Type",
//                                 onTap: () {
//                                   setState(() {
//                                     selectedTab = "Type";
//                                   });
//                                 },
//                               ),
//                               _buildFilterTab(
//                                 icon: Icons.verified_outlined,
//                                 title: "Status",
//                                 selected: selectedTab == "Status",
//                                 onTap: () {
//                                   setState(() {
//                                     selectedTab = "Status";
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: _buildRightFilterSection(
//                               selectedTab, setState, context),
//                         ),
//                       ],
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                       isSearch = true;
//                       Common.showProgressDialog(context, "Applying filters...");
//                       getData();
//                     },
//                     child: Container(
//                       height: 50,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 49, 133, 243),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           "Apply Filters",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildRightFilterSection(
//       String selectedTab, StateSetter setState, BuildContext context) {
//     switch (selectedTab) {
//       case "Created By":
//         return _buildCreatedBySection(setState, context);
//       case "Date Range":
//         return _buildDateRangeSection(setState, context);
//       case "Customer":
//         return _buildCustomerSection(setState, context);
//       case "Type":
//         return _buildTypeSection(setState, context);
//       case "Status":
//         return _buildStatusSection(setState, context);
//       default:
//         return _buildCreatedBySection(setState, context);
//     }
//   }

//   Widget _buildCreatedBySection(StateSetter setState, BuildContext context) {
//     return ListView(
//       children: [
//         const Text(
//           "Created By",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           decoration: const InputDecoration(
//             hintText: 'Search staff...',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           ),
//           onChanged: (value) {
//             setState(() {
//               filteredStaffs = staffs
//                   .where((item) => item.accountName
//                       .toLowerCase()
//                       .contains(value.toLowerCase()))
//                   .toList();
//             });
//           },
//         ),
//         const SizedBox(height: 16),
//         Container(
//           height: MediaQuery.of(context).size.height * 0.3,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: filteredStaffs.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No staff members found',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: filteredStaffs.length,
//                   itemBuilder: (context, index) {
//                     final staff = filteredStaffs[index];
//                     final isSelected = createdByIds.contains(staff.accountId);

//                     return CheckboxListTile(
//                       title: Text(
//                         staff.accountName,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       value: isSelected,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           if (value == true) {
//                             if (!createdByIds.contains(staff.accountId)) {
//                               createdByIds.add(staff.accountId);
//                               createdByNames.add(staff.accountName);
//                             }
//                           } else {
//                             createdByIds.remove(staff.accountId);
//                             createdByNames.remove(staff.accountName);
//                           }
//                         });
//                       },
//                       controlAffinity: ListTileControlAffinity.leading,
//                       dense: true,
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 8),
//                     );
//                   },
//                 ),
//         ),
//         if (createdByNames.isNotEmpty) ...[
//           const SizedBox(height: 16),
//           const Text(
//             "Selected Staff:",
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: createdByNames.map((name) {
//               return Chip(
//                 label: Text(
//                   name,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 onDeleted: () {
//                   final index = createdByNames.indexOf(name);
//                   if (index != -1) {
//                     createdByNames.removeAt(index);
//                     createdByIds.removeAt(index);
//                     setState(() {});
//                   }
//                 },
//                 deleteIcon: const Icon(Icons.close, size: 16),
//                 backgroundColor: Colors.blue.shade50,
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 16),
//           InkWell(
//             onTap: () {
//               createdByIds.clear();
//               createdByNames.clear();
//               setState(() {});
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.clear_all, size: 14, color: Colors.grey),
//                   SizedBox(width: 4),
//                   Text(
//                     "Clear All",
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildDateRangeSection(StateSetter setState, BuildContext context) {
//     return ListView(
//       children: [
//         const Text(
//           "Date Range",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 20),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "From Date",
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87),
//             ),
//             const SizedBox(height: 8),
//             _buildDatePickerTile(
//               context: context,
//               title: "Select from date",
//               date: fDate,
//               onSelect: (date) {
//                 fDate = date;
//                 setState(() {});
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "To Date",
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87),
//             ),
//             const SizedBox(height: 8),
//             _buildDatePickerTile(
//               context: context,
//               title: "Select to date",
//               date: tDate,
//               onSelect: (date) {
//                 tDate = date;
//                 setState(() {});
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         if (fDate != "From Date" || tDate != "To Date")
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.shade100),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_today,
//                     color: Colors.blue.shade600, size: 16),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "Selected: ${fDate != "From Date" ? fDate : "Any"} - ${tDate != "To Date" ? tDate : "Any"}",
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.blue.shade800,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         if (fDate != "From Date" || tDate != "To Date") ...[
//           const SizedBox(height: 16),
//           InkWell(
//             onTap: () {
//               fDate = "From Date";
//               tDate = "To Date";
//               setState(() {});
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.clear, size: 14, color: Colors.grey),
//                   SizedBox(width: 4),
//                   Text(
//                     "Clear Dates",
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildDatePickerTile({
//     required BuildContext context,
//     required String title,
//     required String date,
//     required Function(String) onSelect,
//   }) {
//     final bool hasDate =
//         date.isNotEmpty && date != "From Date" && date != "To Date";

//     return GestureDetector(
//       onTap: () async {
//         final pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//         );
//         if (pickedDate != null) {
//           onSelect(DateFormat('dd-MM-yyyy').format(pickedDate));
//         }
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: hasDate ? const Color(0xff2590cf) : Colors.grey.shade400,
//           ),
//           borderRadius: BorderRadius.circular(8),
//           color: hasDate ? const Color(0xffe7f3ff) : Colors.white,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 hasDate ? date : title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color:
//                       hasDate ? const Color(0xff2590cf) : Colors.grey.shade600,
//                   fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.calendar_month,
//               color: hasDate ? const Color(0xff2590cf) : Colors.grey.shade500,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomerSection(StateSetter setState, BuildContext context) {
//     if (filteredCustomers.isEmpty ||
//         filteredCustomers.length != customers.length) {
//       filteredCustomers = List.from(customers);
//     }

//     return ListView(
//       children: [
//         const Text(
//           "Customer",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           decoration: const InputDecoration(
//             hintText: 'Search customers...',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           ),
//           onChanged: (value) {
//             setState(() {
//               if (value.isEmpty) {
//                 filteredCustomers = List.from(customers);
//               } else {
//                 filteredCustomers = customers
//                     .where((item) =>
//                         item.name.toLowerCase().contains(value.toLowerCase()))
//                     .toList();
//               }
//             });
//           },
//         ),
//         const SizedBox(height: 16),
//         Container(
//           height: MediaQuery.of(context).size.height * 0.3,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: filteredCustomers.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No customers found',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: filteredCustomers.length,
//                   itemBuilder: (context, index) {
//                     final customer = filteredCustomers[index];
//                     final isSelected =
//                         selectedCustomerIds.contains(customer.id);

//                     return CheckboxListTile(
//                       title: Text(
//                         customer.name,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       value: isSelected,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           if (value == true) {
//                             if (!selectedCustomerIds.contains(customer.id)) {
//                               selectedCustomerIds.add(customer.id);
//                               selectedCustomerNames.add(customer.name);
//                             }
//                           } else {
//                             selectedCustomerIds.remove(customer.id);
//                             selectedCustomerNames.remove(customer.name);
//                           }
//                         });
//                       },
//                       controlAffinity: ListTileControlAffinity.leading,
//                       dense: true,
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 8),
//                     );
//                   },
//                 ),
//         ),
//         if (selectedCustomerNames.isNotEmpty) ...[
//           const SizedBox(height: 16),
//           const Text(
//             "Selected Customers:",
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: selectedCustomerNames.map((name) {
//               return Chip(
//                 label: Text(
//                   name,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 onDeleted: () {
//                   final index = selectedCustomerNames.indexOf(name);
//                   if (index != -1) {
//                     selectedCustomerNames.removeAt(index);
//                     selectedCustomerIds.removeAt(index);
//                     setState(() {});
//                   }
//                 },
//                 deleteIcon: const Icon(Icons.close, size: 16),
//                 backgroundColor: Colors.blue.shade50,
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 16),
//           InkWell(
//             onTap: () {
//               selectedCustomerIds.clear();
//               selectedCustomerNames.clear();
//               setState(() {});
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.clear_all, size: 14, color: Colors.grey),
//                   SizedBox(width: 4),
//                   Text(
//                     "Clear All",
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildTypeSection(StateSetter setState, BuildContext context) {
//     if (filteredTypes.isEmpty || filteredTypes.length != types.length) {
//       filteredTypes = List.from(types);
//     }

//     return ListView(
//       children: [
//         const Text(
//           "Type",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           decoration: const InputDecoration(
//             hintText: 'Search types...',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           ),
//           onChanged: (value) {
//             setState(() {
//               if (value.isEmpty) {
//                 filteredTypes = List.from(types);
//               } else {
//                 filteredTypes = types
//                     .where((item) => item.typeName
//                         .toLowerCase()
//                         .contains(value.toLowerCase()))
//                     .toList();
//               }
//             });
//           },
//         ),
//         const SizedBox(height: 16),
//         Container(
//           height: MediaQuery.of(context).size.height * 0.3,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: filteredTypes.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No types found',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: filteredTypes.length,
//                   itemBuilder: (context, index) {
//                     final type = filteredTypes[index];
//                     final isSelected =
//                         selectedTypeIds.contains(type.id.toString());

//                     return CheckboxListTile(
//                       title: Text(
//                         type.typeName,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       value: isSelected,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           if (value == true) {
//                             if (!selectedTypeIds.contains(type.id.toString())) {
//                               selectedTypeIds.add(type.id.toString());
//                               selectedTypeNames.add(type.typeName);
//                             }
//                           } else {
//                             selectedTypeIds.remove(type.id.toString());
//                             selectedTypeNames.remove(type.typeName);
//                           }
//                         });
//                       },
//                       controlAffinity: ListTileControlAffinity.leading,
//                       dense: true,
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 8),
//                     );
//                   },
//                 ),
//         ),
//         if (selectedTypeNames.isNotEmpty) ...[
//           const SizedBox(height: 16),
//           const Text(
//             "Selected Types:",
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: selectedTypeNames.map((name) {
//               return Chip(
//                 label: Text(
//                   name,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 onDeleted: () {
//                   final index = selectedTypeNames.indexOf(name);
//                   if (index != -1) {
//                     selectedTypeNames.removeAt(index);
//                     selectedTypeIds.removeAt(index);
//                     setState(() {});
//                   }
//                 },
//                 deleteIcon: const Icon(Icons.close, size: 16),
//                 backgroundColor: Colors.blue.shade50,
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 16),
//           InkWell(
//             onTap: () {
//               selectedTypeIds.clear();
//               selectedTypeNames.clear();
//               setState(() {});
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.clear_all, size: 14, color: Colors.grey),
//                   SizedBox(width: 4),
//                   Text(
//                     "Clear All",
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildStatusSection(StateSetter setState, BuildContext context) {
//     return ListView(
//       children: [
//         const Text(
//           "Status",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           decoration: const InputDecoration(
//             hintText: 'Search status...',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           ),
//           onChanged: (value) {},
//         ),
//         const SizedBox(height: 16),
//         Container(
//           height: MediaQuery.of(context).size.height * 0.3,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ListView(
//             children: [
//               _buildStatusCheckbox(
//                 "Pending",
//                 "Proforma not approved or rejected",
//                 setState,
//               ),
//               _buildStatusCheckbox(
//                 "Approved",
//                 "Proforma approved but not converted to invoice",
//                 setState,
//               ),
//               _buildStatusCheckbox(
//                 "Rejected",
//                 "Proforma rejected",
//                 setState,
//               ),
//               _buildStatusCheckbox(
//                 "Created",
//                 "Converted to invoice",
//                 setState,
//               ),
//             ],
//           ),
//         ),
//         if (_getSelectedStatuses().isNotEmpty) ...[
//           const SizedBox(height: 16),
//           const Text(
//             "Selected Status:",
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _getSelectedStatuses().map((status) {
//               return Chip(
//                 label: Text(
//                   status,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 onDeleted: () {
//                   _removeStatus(status);
//                   setState(() {});
//                 },
//                 deleteIcon: const Icon(Icons.close, size: 16),
//                 backgroundColor: Colors.blue.shade50,
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 16),
//           InkWell(
//             onTap: () {
//               _clearAllStatuses();
//               setState(() {});
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.clear_all, size: 14, color: Colors.grey),
//                   SizedBox(width: 4),
//                   Text(
//                     "Clear All",
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildStatusCheckbox(
//       String status, String description, StateSetter setState) {
//     final isSelected = _isStatusSelected(status);

//     return CheckboxListTile(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             status,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             description,
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//       value: isSelected,
//       onChanged: (bool? value) {
//         if (value == true) {
//           _addStatus(status);
//         } else {
//           _removeStatus(status);
//         }
//         setState(() {});
//       },
//       controlAffinity: ListTileControlAffinity.leading,
//       dense: true,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     );
//   }

//   Widget _buildFilterTab({
//     required IconData icon,
//     required String title,
//     required bool selected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//         decoration: BoxDecoration(
//           color: selected ? const Color(0xffe7f3ff) : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//           border: selected
//               ? Border.all(color: const Color(0xff2590cf), width: 1)
//               : null,
//         ),
//         child: Row(
//           children: [
//             Icon(icon,
//                 color: selected ? const Color(0xff2590cf) : Colors.grey,
//                 size: 18),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
//                   color: selected ? const Color(0xff2590cf) : Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<dynamic> staffDialog(BuildContext context, String type) {
//     List<String> tempSelectedIds = [];
//     List<String> tempSelectedNames = [];
//     TextEditingController staffSearchController = TextEditingController();
//     if (type == 'collected') {
//       tempSelectedIds = List.from(collectedByIds);
//       tempSelectedNames = List.from(collectedByNames);
//     } else if (type == 'created') {
//       tempSelectedIds = List.from(createdByIds);
//       tempSelectedNames = List.from(createdByNames);
//     }
//     List<Staff> tempFilteredStaffs = List.from(staffs);

//     return showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text("Select Staff"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextField(
//                       controller: staffSearchController,
//                       onChanged: (value) {
//                         setState(() {
//                           tempFilteredStaffs = staffs
//                               .where((item) => item.accountName
//                                   .toLowerCase()
//                                   .contains(value.toLowerCase()))
//                               .toList();
//                         });
//                       },
//                       decoration: const InputDecoration(
//                         hintText: 'Search staff',
//                         prefixIcon: Icon(Icons.search),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * .4,
//                     width: MediaQuery.of(context).size.width * .8,
//                     child: ListView.builder(
//                       itemCount: tempFilteredStaffs.length,
//                       itemBuilder: (context, index) {
//                         final staff = tempFilteredStaffs[index];
//                         final selected =
//                             tempSelectedIds.contains(staff.accountId);

//                         return CheckboxListTile(
//                           title: Text(staff.accountName),
//                           value: selected,
//                           onChanged: (bool? value) {
//                             setState(() {
//                               if (value == true) {
//                                 if (!tempSelectedIds
//                                     .contains(staff.accountId)) {
//                                   tempSelectedIds.add(staff.accountId);
//                                   tempSelectedNames.add(staff.accountName);
//                                 }
//                               } else {
//                                 tempSelectedIds.remove(staff.accountId);
//                                 tempSelectedNames.remove(staff.accountName);
//                               }
//                             });
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (type == 'collected') {
//                       collectedByIds = List.from(tempSelectedIds);
//                       collectedByNames = List.from(tempSelectedNames);
//                     } else {
//                       createdByIds = List.from(tempSelectedIds);
//                       createdByNames = List.from(tempSelectedNames);
//                     }
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Done"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<dynamic> typesDialog(BuildContext context) {
//     TextEditingController typeSearchController = TextEditingController();
//     List<Type> tempFilteredTypes = List.from(types);

//     return showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: typeSearchController,
//                     autocorrect: false,
//                     keyboardType: TextInputType.visiblePassword,
//                     autofocus: true,
//                     onChanged: (value) {
//                       setState(() {
//                         tempFilteredTypes = types
//                             .where((item) => item.typeName
//                                 .toLowerCase()
//                                 .contains(value.toLowerCase()))
//                             .toList();
//                       });
//                     },
//                     decoration: const InputDecoration(
//                       contentPadding: EdgeInsets.all(8),
//                       hintText: 'Search',
//                       prefixIcon: Icon(Icons.search),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * .3,
//                   width: MediaQuery.of(context).size.width * .8,
//                   child: ListView.builder(
//                     itemCount: tempFilteredTypes.length,
//                     physics: const ScrollPhysics(),
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                           onTap: () {
//                             typeName = tempFilteredTypes[index].typeName;
//                             typeId = tempFilteredTypes[index].id.toString();
//                             typeSearchController.clear();
//                             Navigator.pop(context);
//                           },
//                           title: Text(tempFilteredTypes[index].typeName));
//                     },
//                   ),
//                 )
//               ],
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     typeSearchController.clear();
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Close")),
//             ],
//           );
//         });
//       },
//     );
//   }

//   Future<dynamic> customerDialog(BuildContext context) {
//     TextEditingController customerSearchController = TextEditingController();
//     List<Customer> tempFilteredCustomers = List.from(customers);

//     return showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: customerSearchController,
//                     autocorrect: false,
//                     keyboardType: TextInputType.visiblePassword,
//                     autofocus: true,
//                     onChanged: (value) {
//                       setState(() {
//                         tempFilteredCustomers = customers
//                             .where((item) => item.name
//                                 .toLowerCase()
//                                 .contains(value.toLowerCase()))
//                             .toList();
//                       });
//                     },
//                     decoration: const InputDecoration(
//                       contentPadding: EdgeInsets.all(8),
//                       hintText: 'Search',
//                       prefixIcon: Icon(Icons.search),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * .3,
//                   width: MediaQuery.of(context).size.width * .8,
//                   child: ListView.builder(
//                     itemCount: tempFilteredCustomers.length,
//                     physics: const ScrollPhysics(),
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                           onTap: () {
//                             customerName = tempFilteredCustomers[index].name;
//                             customerId = tempFilteredCustomers[index].id;
//                             customerSearchController.clear();
//                             Navigator.pop(context);
//                           },
//                           title: Text(tempFilteredCustomers[index].name));
//                     },
//                   ),
//                 )
//               ],
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     customerSearchController.clear();
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Close")),
//             ],
//           );
//         });
//       },
//     );
//   }
// }

// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/getInvoiceSearchData.dart';
import 'package:login2/models/clients/invoiceListTempModel.dart';
import 'package:login2/screens/accounts/clients/addInvoiceTemp.dart';
import 'package:login2/screens/accounts/clients/editInvoiceTemp.dart';
import 'package:login2/screens/accounts/clients/print_invoice_view_temp.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:lottie/lottie.dart';
import '../../../core/common.dart';
import '../../../models/clients/deleteInvoiceModel.dart';
import '../../../service/service.dart';
import 'addInvoice.dart';

/// Simple id/name pair used by the generic multi-select filter section.
class _Opt {
  final String id;
  final String name;
  _Opt(this.id, this.name);
}

class ProformaInvoiceList extends StatefulWidget {
  String token;
  String custId;
  String custName;
  String status;
  String isDash;
  ProformaInvoiceList(
      this.token, this.custId, this.custName, this.status, this.isDash,
      {super.key});

  @override
  State<ProformaInvoiceList> createState() => _ProformaInvoiceListState();
}

class _ProformaInvoiceListState extends State<ProformaInvoiceList> {
  static const _dateFmt = 'dd-MM-yyyy';

  static String get _defaultFrom => DateFormat(_dateFmt)
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  static String get _defaultTo => DateFormat(_dateFmt).format(DateTime.now());

  String fDate = _defaultFrom;
  String tDate = _defaultTo;

  InvoiceListModelTemp? invoiceList;
  GetInvoiceSearchData? searchData;

  bool result = true; // network available
  bool isLoading = true; // list loader

  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  String customerId = "";
  String customerName = "Choose Customer";

  List<Staff> staffs = [];
  List<Staff> filteredStaffs = [];
  String staffId = "";

  List<Type> types = [];
  List<Type> filteredTypes = [];

  /// keyed by invoice id (NOT list index)
  final Map<String, bool> _pdfLoading = {};

  final TextEditingController search = TextEditingController();
  Timer? _debounce;

  String? name = '';
  String? role = '';
  String? userId = '';
  String? phoneCallLogPermission = '';

  List<String> collectedByIds = [];
  List<String> createdByNames = [];
  List<String> createdByIds = [];
  List<String> selectedStatuses = [];
  List<String> selectedCustomerIds = [];
  List<String> selectedCustomerNames = [];
  List<String> selectedTypeIds = [];
  List<String> selectedTypeNames = [];

  // ---------------------------------------------------------------- lifecycle

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {}); // refresh clear (x) icon
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) getData();
    });
  }

  // --------------------------------------------------------------------- data

  Future<void> getData() async {
    if (mounted) setState(() => isLoading = true);

    try {
      name = await Common.getSharedPref("name");
      role = await Common.getSharedPref("role");
      userId = await Common.getSharedPref("userId");
      phoneCallLogPermission =
          await Common.getSharedPref("phoneCallLogPermission");

      final conn = await Connectivity().checkConnectivity();
      result = !conn.contains(ConnectivityResult.none);
      if (!result) return;

      final searchQuery = search.text.trim().toLowerCase();

      final list = await HttpService.invoiceListTemp(
        widget.token,
        widget.isDash,
        widget.status,
        widget.custId,
        fDate == "From Date" ? "" : fDate,
        tDate == "To Date" ? "" : tDate,
        selectedCustomerIds.join(','),
        collectedByIds.join(','),
        createdByIds.join(','),
        staffId,
        selectedTypeIds.join(','),
        selectedStatuses.join(','),
      );

      // dropdown data only needs to be fetched once
      searchData ??= await HttpService.getInvoiceSearchTemp(widget.token);

      if (list != null && searchQuery.isNotEmpty) {
        list.data.lists = list.data.lists.where((inv) {
          return inv.customerName.toLowerCase().contains(searchQuery) ||
              inv.invoiceNumber.toLowerCase().contains(searchQuery) ||
              (inv.products.isNotEmpty &&
                  inv.products[0].productName
                      .toLowerCase()
                      .contains(searchQuery)) ||
              inv.createdBy.toLowerCase().contains(searchQuery);
        }).toList();
      }
      invoiceList = list;

      if (searchData != null) {
        customers = searchData!.data.customers;
        filteredCustomers = List.from(customers);
        staffs = searchData!.data.staff;
        filteredStaffs = List.from(staffs);
        types = searchData!.data.types;
        filteredTypes = List.from(types);
      }
    } catch (e, st) {
      debugPrint("Error in getData: $e\n$st");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool get _hasActiveFilters =>
      search.text.isNotEmpty ||
      selectedStatuses.isNotEmpty ||
      selectedCustomerIds.isNotEmpty ||
      selectedTypeIds.isNotEmpty ||
      createdByIds.isNotEmpty ||
      fDate != _defaultFrom ||
      tDate != _defaultTo;

  void clearAllFilters() {
    fDate = _defaultFrom;
    tDate = _defaultTo;
    staffId = "";
    createdByIds.clear();
    createdByNames.clear();
    collectedByIds.clear();
    selectedStatuses.clear();
    selectedCustomerIds.clear();
    selectedCustomerNames.clear();
    selectedTypeIds.clear();
    selectedTypeNames.clear();
    customerId = "";
    customerName = "Choose Customer";
    filteredCustomers = List.from(customers);
    filteredStaffs = List.from(staffs);
    filteredTypes = List.from(types);
    search.clear();
  }

  // -------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    if (!result) return _buildNoNetwork(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill))
                : _buildList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final hasCust = widget.custName.isNotEmpty;
    final topPad = MediaQuery.of(context).padding.top;

    return PreferredSize(
      preferredSize: Size.fromHeight(topPad + (hasCust ? 72 : kToolbarHeight)),
      child: Container(
        padding: EdgeInsets.only(top: topPad),
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 4),
          child: Row(
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
                  child: const Icon(Icons.arrow_back_ios_outlined,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasCust)
                      Text(
                        widget.custName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    if (hasCust) const SizedBox(height: 3),
                    Text(
                      'Proforma Invoice List',
                      style: TextStyle(
                          color: Colors.white, fontSize: hasCust ? 13 : 18),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => filtrationSheet(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: const Color(0xFFd5f5f4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Image.asset("assets/icons/filter.png", width: 20),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => addInvoiceDialogTemp(context),
                icon:
                    const Icon(Icons.add_circle, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: search,
              onChanged: _onSearchChanged,
              onFieldSubmitted: (_) => getData(),
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search by Customer Name',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          search.clear();
                          getData();
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                filled: true,
                fillColor: Colors.white,
                border: border,
                enabledBorder: border,
              ),
            ),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                clearAllFilters();
                getData();
              },
              icon: const Icon(Icons.refresh, color: Colors.blue),
              tooltip: 'Clear all filters',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    final lists = invoiceList?.data.lists ?? [];

    if (lists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset("assets/icons/nodatafound.png"),
            ),
            const Text(
              'No Data Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: getData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: lists.length,
        itemBuilder: (context, index) => _buildInvoiceCard(lists[index]),
      ),
    );
  }

  Widget _buildInvoiceCard(dynamic inv) {
    final created = inv.invoiceCreated.toString() == "1";
    final approved = inv.isApproved.toString() == "Y";
    final rejected = inv.isRejected.toString() == "Y";

    final cardColor = created
        ? const Color.fromARGB(255, 228, 248, 216)
        : approved
            ? const Color.fromARGB(255, 243, 248, 216)
            : rejected
                ? const Color.fromARGB(255, 248, 216, 216)
                : Colors.white;

    final badgeColor = created
        ? const Color.fromARGB(255, 52, 185, 90)
        : const Color(0xfffcbcbc);
    final badgeText = created
        ? "Created"
        : approved
            ? "Approved"
            : rejected
                ? "Rejected"
                : "Not Created";
    final badgeTextColor = created
        ? Colors.white
        : approved
            ? const Color.fromARGB(255, 240, 255, 154)
            : rejected
                ? const Color.fromARGB(255, 255, 126, 180)
                : Colors.red;

    final products = inv.products as List;
    final productText = products.isEmpty
        ? "Products : -"
        : products.length != 1
            ? "Products : ${products[0].productName} + ${products.length - 1} more..."
            : "Products : ${products[0].productName}";

    const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    final idKey = inv.id.toString();
    final pdfBusy = _pdfLoading[idKey] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(1, 1),
            )
          ],
          borderRadius: BorderRadius.circular(5),
          color: cardColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDashboard(
                            name: name!,
                            token: widget.token,
                            userId: userId!,
                            phoneCallLogPermission: phoneCallLogPermission,
                            custId: inv.clientId.toString(),
                          ),
                        ),
                      ),
                      child: Text(
                        inv.customerName.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: badgeColor,
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text("Proforma No : ${inv.invoiceNumber}",
                  overflow: TextOverflow.ellipsis, style: body),
              const SizedBox(height: 5),
              Text(productText, overflow: TextOverflow.ellipsis, style: body),
              const SizedBox(height: 5),
              Text("Total Amount : ₹ ${inv.totalAmount}",
                  overflow: TextOverflow.ellipsis, style: body),
              const SizedBox(height: 5),
              Text("Created By : ${inv.createdBy}",
                  overflow: TextOverflow.ellipsis, style: body),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${inv.invoiceDate} ${inv.invoiceAt}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: pdfBusy ? null : () => _openPdf(idKey),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: pdfBusy
                            ? Colors.green.shade300
                            : Colors.green.shade100,
                      ),
                      child: pdfBusy
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green.shade800),
                              ),
                            )
                          : Container(
                              height: 20,
                              width: 20,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/icons/pdf.png')),
                              ),
                            ),
                    ),
                  ),
                  if ((inv.invType.toString() == "1" ||
                          inv.invType.toString() == "2") &&
                      inv.invoiceCreated.toString() == "0") ...[
                    const SizedBox(width: 10),
                    _buildMenu(inv),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ actions

  Future<void> _openPdf(String invoiceId) async {
    setState(() => _pdfLoading[invoiceId] = true);
    String? pdfPath;
    try {
      pdfPath = await HttpService.printInvoiceTemp(widget.token, invoiceId);
    } catch (e) {
      debugPrint("PDF error: $e");
    }
    if (!mounted) return;
    setState(() => _pdfLoading[invoiceId] = false);

    if (pdfPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PrintInvoiceViewTemp(pdfPath: pdfPath!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load invoice")),
      );
    }
  }

  Widget _buildMenu(dynamic inv) {
    PopupMenuItem<String> item(
            String value, IconData icon, Color color, String label) =>
        PopupMenuItem(
          value: value,
          child: Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(label),
          ]),
        );

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      onSelected: (value) => _onMenuSelected(value, inv),
      itemBuilder: (context) => [
        item(
            'create', Icons.add_circle_outline, Colors.green, 'Create Invoice'),
        item('approve', Icons.check, Colors.green, 'Approve'),
        item('reject', Icons.close, const Color.fromARGB(255, 155, 74, 26),
            'Reject'),
        item('edit', Icons.edit, const Color.fromARGB(255, 78, 169, 206),
            'Edit Proforma'),
        item('delete', Icons.delete_outline, Colors.red, 'Delete Proforma'),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.more_vert, color: Colors.black54),
      ),
    );
  }

  Future<void> _onMenuSelected(String value, dynamic inv) async {
    switch (value) {
      case 'create':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddInvoice(
              widget.token,
              inv.clientId.toString(),
              inv.id,
              products: inv.products,
            ),
          ),
        ).then((_) => getData());
        break;

      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditInvoiceTemp(
                widget.token, inv.id.toString(), inv.clientId.toString()),
          ),
        ).then((_) => getData());
        break;

      case 'approve':
        Common.showProgressDialog(context, "Approving...");
        bool ok = false;
        try {
          ok = await HttpService.approveProforma(inv.id.toString());
        } catch (e) {
          debugPrint("approve error: $e");
        }
        if (!mounted) return;
        Navigator.pop(context); // close progress
        if (ok) {
          Common.toastMessaage("Proforma Approved Successfully", Colors.green);
          getData();
        } else {
          Common.toastMessaage("Failed to approve proforma", Colors.red);
        }
        break;

      case 'reject':
        final confirmReject =
            await _confirm('Are you sure you want to reject this proforma?');
        if (confirmReject != true || !mounted) return;
        Common.showProgressDialog(context, "Rejecting...");
        bool ok2 = false;
        try {
          ok2 = await HttpService.rejectProforma(inv.id.toString());
        } catch (e) {
          debugPrint("reject error: $e");
        }
        if (!mounted) return;
        Navigator.pop(context); // close progress
        if (ok2) {
          Common.toastMessaage("Proforma rejected successfully", Colors.green);
          getData();
        } else {
          Common.toastMessaage("Failed to reject proforma", Colors.red);
        }
        break;

      case 'delete':
        final confirmDelete =
            await _confirm('Are you sure you want to delete this invoice?');
        if (confirmDelete != true || !mounted) return;
        Common.showProgressDialog(context, "Loading...");
        DeleteInvoiceModel? res;
        try {
          res = await HttpService.deleteInvoiceTemp(widget.token, inv.id);
        } catch (e) {
          debugPrint("delete error: $e");
        }
        if (!mounted) return;
        Navigator.pop(context); // close progress
        if (res != null && res.data == true) {
          Common.toastMessaage(res.message, Colors.green);
          getData();
        } else {
          Common.toastMessaage(res?.message ?? "Failed to delete", Colors.red);
        }
        break;
    }
  }

  Future<bool?> _confirm(String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Please Confirm'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes')),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- no network

  Widget _buildNoNetwork(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------- add invoice dialog

  Future<Object?> addInvoiceDialogTemp(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (dialogContext, _, __) {
        return StatefulBuilder(builder: (dialogContext, setDialogState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Customer Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _pickCustomer(dialogContext, setDialogState),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child:
                            Text(customerName, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (customerId == '') {
                          Common.toastMessaage('Choose Client', Colors.red);
                        } else {
                          Navigator.pop(dialogContext);
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (context) => AddInvoiceTemp(
                                  widget.token, customerId, widget.custName),
                            ),
                          ).then((_) => getData());
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 25),
                          child: Text('Submit',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
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
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  void _pickCustomer(BuildContext ctx, StateSetter setDialogState) {
    final controller = TextEditingController();
    filteredCustomers = List.from(customers);

    showDialog(
      context: ctx,
      builder: (pickerContext) {
        return StatefulBuilder(builder: (pickerContext, setPickerState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    autocorrect: false,
                    autofocus: true,
                    onChanged: (value) {
                      setPickerState(() {
                        filteredCustomers = customers
                            .where((c) => c.name
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
                  height: MediaQuery.of(pickerContext).size.height * .3,
                  width: MediaQuery.of(pickerContext).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final c = filteredCustomers[index];
                      return ListTile(
                        title: Text(c.name),
                        onTap: () {
                          customerName = c.name;
                          customerId = c.id;
                          filteredCustomers = List.from(customers);
                          setDialogState(() {}); // refresh the outer dialog
                          Navigator.pop(pickerContext);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  filteredCustomers = List.from(customers);
                  Navigator.pop(pickerContext);
                },
                child: const Text("Close"),
              ),
            ],
          );
        });
      },
    ).then((_) => controller.dispose());
  }

  // ------------------------------------------------------------ filter sheet

  Future<dynamic> filtrationSheet() {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        String selectedTab = "Created By";
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Widget tab(IconData icon, String title) => _buildFilterTab(
                  icon: icon,
                  title: title,
                  selected: selectedTab == title,
                  onTap: () => setSheetState(() => selectedTab = title),
                );

            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(sheetContext).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filters",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              tab(Icons.person_outline, "Created By"),
                              tab(Icons.date_range, "Date Range"),
                              tab(Icons.people_alt_outlined, "Customer"),
                              tab(Icons.list_alt, "Type"),
                              tab(Icons.verified_outlined, "Status"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRightFilterSection(
                              selectedTab, setSheetState, sheetContext),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      getData(); // list loader shows while fetching
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 49, 133, 243),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Apply Filters",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
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

  Widget _buildRightFilterSection(
      String tab, StateSetter setState, BuildContext ctx) {
    switch (tab) {
      case "Date Range":
        return _buildDateRangeSection(setState, ctx);
      case "Customer":
        return _buildMultiSelect(
          ctx: ctx,
          setState: setState,
          title: "Customer",
          selectedLabel: "Selected Customers:",
          searchHint: 'Search customers...',
          emptyText: 'No customers found',
          options: filteredCustomers.map((c) => _Opt(c.id, c.name)).toList(),
          ids: selectedCustomerIds,
          names: selectedCustomerNames,
          onSearch: (v) => filteredCustomers = customers
              .where((c) => c.name.toLowerCase().contains(v.toLowerCase()))
              .toList(),
        );
      case "Type":
        return _buildMultiSelect(
          ctx: ctx,
          setState: setState,
          title: "Type",
          selectedLabel: "Selected Types:",
          searchHint: 'Search types...',
          emptyText: 'No types found',
          options: filteredTypes
              .map((t) => _Opt(t.id.toString(), t.typeName))
              .toList(),
          ids: selectedTypeIds,
          names: selectedTypeNames,
          onSearch: (v) => filteredTypes = types
              .where((t) => t.typeName.toLowerCase().contains(v.toLowerCase()))
              .toList(),
        );
      case "Status":
        return _buildStatusSection(setState, ctx);
      case "Created By":
      default:
        return _buildMultiSelect(
          ctx: ctx,
          setState: setState,
          title: "Created By",
          selectedLabel: "Selected Staff:",
          searchHint: 'Search staff...',
          emptyText: 'No staff members found',
          options: filteredStaffs
              .map((s) => _Opt(s.accountId, s.accountName))
              .toList(),
          ids: createdByIds,
          names: createdByNames,
          onSearch: (v) => filteredStaffs = staffs
              .where(
                  (s) => s.accountName.toLowerCase().contains(v.toLowerCase()))
              .toList(),
        );
    }
  }

  /// Generic searchable multi-select list with chips + "Clear All".
  Widget _buildMultiSelect({
    required BuildContext ctx,
    required StateSetter setState,
    required String title,
    required String selectedLabel,
    required String searchHint,
    required String emptyText,
    required List<_Opt> options,
    required List<String> ids,
    required List<String> names,
    required void Function(String) onSearch,
  }) {
    return ListView(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (v) => setState(() => onSearch(v)),
        ),
        const SizedBox(height: 16),
        Container(
          height: MediaQuery.of(ctx).size.height * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: options.isEmpty
              ? Center(
                  child: Text(emptyText,
                      style: const TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final o = options[index];
                    return CheckboxListTile(
                      title: Text(o.name, style: const TextStyle(fontSize: 14)),
                      value: ids.contains(o.id),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            if (!ids.contains(o.id)) {
                              ids.add(o.id);
                              names.add(o.name);
                            }
                          } else {
                            final i = ids.indexOf(o.id);
                            if (i != -1) {
                              ids.removeAt(i);
                              names.removeAt(i);
                            }
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
        ),
        if (names.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(selectedLabel,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(names.length, (i) {
              return Chip(
                label: Text(names[i], style: const TextStyle(fontSize: 12)),
                onDeleted: () {
                  names.removeAt(i);
                  ids.removeAt(i);
                  setState(() {});
                },
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Colors.blue.shade50,
              );
            }),
          ),
          const SizedBox(height: 16),
          _clearButton(Icons.clear_all, "Clear All", () {
            ids.clear();
            names.clear();
            setState(() {});
          }),
        ],
      ],
    );
  }

  Widget _clearButton(IconData icon, String label, VoidCallback onTap) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSection(StateSetter setState, BuildContext ctx) {
    final anySet = fDate != "From Date" || tDate != "To Date";

    Widget label(String t) => Text(t,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87));

    return ListView(
      children: [
        const Text("Date Range",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        label("From Date"),
        const SizedBox(height: 8),
        _buildDatePickerTile(
          context: ctx,
          title: "Select from date",
          date: fDate,
          onSelect: (d) => setState(() => fDate = d),
        ),
        const SizedBox(height: 20),
        label("To Date"),
        const SizedBox(height: 8),
        _buildDatePickerTile(
          context: ctx,
          title: "Select to date",
          date: tDate,
          onSelect: (d) => setState(() => tDate = d),
        ),
        const SizedBox(height: 20),
        if (anySet) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Selected: ${fDate != "From Date" ? fDate : "Any"} - ${tDate != "To Date" ? tDate : "Any"}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _clearButton(Icons.clear, "Clear Dates", () {
            fDate = "From Date";
            tDate = "To Date";
            setState(() {});
          }),
        ],
      ],
    );
  }

  Widget _buildDatePickerTile({
    required BuildContext context,
    required String title,
    required String date,
    required void Function(String) onSelect,
  }) {
    final hasDate = date.isNotEmpty && date != "From Date" && date != "To Date";
    const blue = Color(0xff2590cf);

    return GestureDetector(
      onTap: () async {
        DateTime initial = DateTime.now();
        if (hasDate) {
          try {
            initial = DateFormat(_dateFmt).parse(date);
          } catch (_) {}
        }
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(DateFormat(_dateFmt).format(picked));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: hasDate ? blue : Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: hasDate ? const Color(0xffe7f3ff) : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasDate ? date : title,
                style: TextStyle(
                  fontSize: 14,
                  color: hasDate ? blue : Colors.grey.shade600,
                  fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.calendar_month,
                color: hasDate ? blue : Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(StateSetter setState, BuildContext ctx) {
    const options = {
      "Pending": "Proforma not approved or rejected",
      "Approved": "Proforma approved but not converted to invoice",
      "Rejected": "Proforma rejected",
      "Created": "Converted to invoice",
    };

    return ListView(
      children: [
        const Text("Status",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: options.entries.map((e) {
              return CheckboxListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(e.value,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600)),
                  ],
                ),
                value: selectedStatuses.contains(e.key),
                onChanged: (checked) {
                  if (checked == true) {
                    if (!selectedStatuses.contains(e.key)) {
                      selectedStatuses.add(e.key);
                    }
                  } else {
                    selectedStatuses.remove(e.key);
                  }
                  setState(() {});
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            }).toList(),
          ),
        ),
        if (selectedStatuses.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text("Selected Status:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<String>.from(selectedStatuses).map((s) {
              return Chip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                onDeleted: () {
                  selectedStatuses.remove(s);
                  setState(() {});
                },
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _clearButton(Icons.clear_all, "Clear All", () {
            selectedStatuses.clear();
            setState(() {});
          }),
        ],
      ],
    );
  }

  Widget _buildFilterTab({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    const blue = Color(0xff2590cf);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffe7f3ff) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: blue, width: 1) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? blue : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? blue : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
