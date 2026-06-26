// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/customerListModel.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/models/dashboardModel.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/lead_management/leadDashboardModel.dart';
import 'package:login2/models/loginCheckModel.dart';
import 'package:login2/screens/accounts/clients/addInvoice.dart';
import 'package:login2/screens/accounts/clients/addInvoiceUpdated.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/accounts/clients/gstInvoiceList.dart';
import 'package:login2/screens/accounts/clients/invoiceList.dart';
import 'package:login2/screens/accounts/clients/pendingInvoice.dart';
import 'package:login2/screens/accounts/clients/proformaInvoiceList.dart';
import 'package:login2/screens/accounts/clients/receiptList.dart';
import 'package:login2/screens/accounts/clients/updatedInvoiceList.dart';
import 'package:login2/screens/accounts/dashboard/account_head.dart';
import 'package:login2/screens/accounts/dashboard/bank_account.dart';
import 'package:login2/screens/accounts/expense/expense_list.dart';
import 'package:login2/screens/accounts/expense/advance&expense.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/notification_page.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/sidebarscreens/accountsSidebarScreen.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/togglebutton_start.dart';
import 'package:shimmer/shimmer.dart';
import '../../authentication/deep_link_handler.dart';

class AccountsDashboard extends StatefulWidget {
  String token;

  AccountsDashboard({super.key, required this.token});
  @override
  State<AccountsDashboard> createState() => _AccountsDashboardState();
}

class _AccountsDashboardState extends State<AccountsDashboard> {
  bool result = true;
  bool isLoading = true;
  String token = '';
  String name = '';
  String userId = '';
  String staffId = '';
  bool isExpired = false;
  bool loadmore = false;
  String startAndStopWorkPermission = '';
  Offset _floatingButtonPosition = Offset.zero;
  bool _showFloatingOptions = false;
  TextEditingController search = TextEditingController();
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  String customerName = "Choose Customer";
  String customerId = "";
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String role = '';
  String phoneCallLogPermission = '';
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? proformaInvoiceMenu;
  String? gstInvoiceMenu;
  String? pendingInvoiceMenu;
  String? receiptMenu;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  LeadDashboardModel? leadDashboard;
  DashboardModel? userDashboard;
  CommonConfigureModel? configure;
  AccountDashboardModel? dashboard;
  String? firebaseToken;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  bool toggle = false;
  int notificationCount = 0;
  List<dynamic> get list => [
        "Invoices",
        "Pending Invoices",
        "Receipts",
        "Expense",
        "Customers",
        "Account Head",
        if (proformaInvoiceMenu == "true") "Proforma Invoices",
        if (gstInvoiceMenu == "true") "GST Invoices",
        //  "Updated Invoice",
      ];
  List<dynamic> get tabColors => [
        Colors.green,
        Colors.orange,
        Colors.blue,
        Colors.red,
        Colors.teal,
        Colors.purple,
        if (proformaInvoiceMenu == "true")
          const Color.fromARGB(255, 111, 27, 207),
        if (gstInvoiceMenu == "true") const Color.fromARGB(255, 228, 43, 235),
        // const Color.fromARGB(255, 95, 133, 26),
      ];
  List colorList = [
    const Color(0xFFddd8f5),
    const Color(0xFFf0ebef),
    const Color(0xFFd7e9f4),
    const Color(0xFFf5e6d7),
    const Color(0xFFdbe4e8),
    const Color(0xFFf3d6d5),
    const Color(0xFFe0f0c8),
    const Color(0xFFf3e8d3),
    const Color(0xFFf3e8d3),
    const Color.fromARGB(255, 211, 243, 216),
    // const Color.fromARGB(255, 180, 248, 211),
  ];
  getData() async {
    token = await Common.getSharedPref("token") ?? "";
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
    proformaInvoiceMenu =
        await Common.getSharedPref("proformaInvoiceMenu") ?? "";
    gstInvoiceMenu = await Common.getSharedPref("gstInvoiceMenu") ?? "";
    pendingInvoiceMenu = await Common.getSharedPref("pendingInvoiceMenu") ?? "";
    receiptMenu = await Common.getSharedPref("receiptMenu") ?? "";
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission") ?? "";
    getList();
    getCustomerList();
    firebaseToken = await FirebaseMessaging.instance.getToken();
    LoginCheckModel? loginCheck =
        await HttpService.loginCheck(token, firebaseToken!);
    log(firebaseToken.toString());
    if (loginCheck!.data == false) {
      Common.premiumToast(context, 'Token Expired', Icons.lock_clock_rounded,
          color: Colors.red);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }
    }
    configure = await HttpService.configure(token);

    startAndStopWorkPermission =
        await Common.getSharedPref("startAndStopWorkPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    updateLeadCategory = await Common.getSharedPref("updateLeadCategory");
    deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");

    role = await Common.getSharedPref("role");
    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';
    leadDashboard = await HttpService.leadDashboard(
        token, fromdate, todate, fromdate1, todate1);
    userDashboard = await HttpService.mainDashboard(token);
    Common.saveSharedPref("profile_pic", userDashboard!.data.profilePic);
    setState(() {
      notificationCount = leadDashboard!.data.unreadNotification;
    });
    configure = await HttpService.configure(token);
    if (configure != null) {
      isExpired = configure!.data!.isExpired!;
      setState(() {});
    }
  }

  getList() async {
    String tog = await Common.getSharedPref("acc_toggle") ?? "";

    toggle = tog == "true" ? true : false;
    dashboard = await HttpService.accountsDashboard(fDate, tDate);
    if (dashboard != null && dashboard!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  double _calculateGridViewHeight(int itemCount) {
    // Constants for calculation
    const double padding = 16.0; // Top and bottom padding
    const double itemHeight =
        50.0; // Approximate height of each item (adjust as needed)
    const double spacing = 15.0; // Main axis spacing between rows

    // Calculate number of rows (2 items per row)
    int rows = (itemCount / 2).ceil();

    // Calculate total height
    double totalHeight = (padding * 2) + // Top and bottom padding
        (itemHeight * rows) + // Height of all rows
        (spacing * (rows - 1)); // Spacing between rows

    // Add some extra buffer
    totalHeight += 20;

    // Ensure minimum height
    if (totalHeight < 100) totalHeight = 100;

    // Ensure maximum height (you can adjust this)
    if (totalHeight > MediaQuery.of(context).size.height * 0.6) {
      totalHeight = MediaQuery.of(context).size.height * 0.6;
    }

    return totalHeight;
  }

  getCustomerList() async {
    try {
      CustomerListModel? customerData =
          await HttpService.customerList(widget.token);
      if (customerData != null && customerData.status == true) {
        setState(() {
          customers = customerData.data ?? [];
          filteredCustomers = List.from(customers);
        });
      }
    } catch (e) {
      print("Error loading customers: $e");
    }
  }

  @override
  void initState() {
    getData();
    _initializeFloatingButtonPosition();
    super.initState();

    // Consume pending deep links if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deepLinkHandler.getPendingDeepLink().then((data) {
        if (data != null && mounted) {
          log('[DEEPLINK] AccountsDashboard: Consuming pending deep link: $data');
          deepLinkHandler.validateAndNavigate(context, data);
        }
      });
    });
  }

  void _initializeFloatingButtonPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        _floatingButtonPosition = Offset(screenWidth - 130, 400);
      });
    });
  }

  Future<Object?> addInvoiceDialog(BuildContext context) {
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
                    const Text(
                      'Customer  Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
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
                                        controller: search,
                                        autocorrect: false,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        autofocus: true,
                                        onChanged: (value) {
                                          setState(() {
                                            filteredCustomers = customers
                                                .where((item) => item.name!
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()))
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .3,
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      child: ListView.builder(
                                        itemCount: filteredCustomers.length,
                                        physics: const ScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                              onTap: () {
                                                customerName =
                                                    filteredCustomers[index]
                                                        .name!;
                                                customerId =
                                                    filteredCustomers[index]
                                                        .id!;
                                                search.clear();
                                                filteredCustomers =
                                                    List.from(customers);
                                                setState(() {});
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              title: Text(
                                                  filteredCustomers[index]
                                                      .name!));
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      // onPressed: () {
                                      //   search.clear();
                                      //   filteredCustomers.addAll(customers);
                                      //   if (context.mounted) {
                                      //     Navigator.pop(context);
                                      //   }
                                      // },
                                      onPressed: () {
                                        search.clear();
                                        filteredCustomers =
                                            List.from(customers);
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
                                    customerName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (customerId == '') {
                          Common.toastMessaage('Choose Client', Colors.red);
                        } else {
                          search.clear();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddInvoice(widget.token, customerId, "")),
                          ).then((_) {
                            getData();
                          });
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
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
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
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  void _updateFloatingButtonPosition(Offset newPosition) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double x = newPosition.dx.clamp(0.0, screenWidth - 80);
    double y = newPosition.dy.clamp(0.0, screenHeight - 80);

    setState(() {
      _floatingButtonPosition = Offset(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            key: _scaffoldKey,
            appBar: appBarWidget(context, "lead"),
            // appBar: PreferredSize(
            //   preferredSize:
            //       Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
            //   child: Container(
            //     padding:
            //         EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            //     decoration: const BoxDecoration(
            //       gradient: LinearGradient(
            //           colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.only(
            //           left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             children: [
            //               AccountsDashboardPermission == "false"
            //                   ? InkWell(
            //                       onTap: () => Navigator.pop(context),
            //                       child: Container(
            //                         height: 25,
            //                         width: 25,
            //                         decoration: BoxDecoration(
            //                           border: Border.all(color: Colors.white),
            //                           shape: BoxShape.circle,
            //                         ),
            //                         child: const Icon(
            //                           Icons.arrow_back_ios_outlined,
            //                           color: Colors.white,
            //                           size: 16,
            //                         ),
            //                       ),
            //                     )
            //                   : const SizedBox(),
            //               const SizedBox(width: 25),
            //               const Text(
            //                 "Account Management",
            //                 style:
            //                     TextStyle(color: Colors.white, fontSize: 16),
            //               ),
            //             ],
            //           ),
            //           AccountsDashboardPermission =="true"?
            //           PopupMenuButton<String>(
            //             icon:
            //                 const Icon(Icons.more_vert, color: Colors.white),
            //             itemBuilder: (context) => [
            //               const PopupMenuItem<String>(
            //                 value: 'logout',
            //                 child: Text('Logout'),
            //               ),
            //             ],
            //             onSelected: (value) async {
            //               if (value == 'logout') {
            //                 try {
            //                   final result =
            //                       await HttpService.getWorkStatus();
            //                   if (result != null && result.data.isNotEmpty) {
            //                     showDialog(
            //                       context: context,
            //                       builder: (context) => AlertDialog(
            //                         title: const Text('Logout Blocked'),
            //                         content: const Text(
            //                             'Work is in progress. Please close all work before logging out.'),
            //                         actions: [
            //                           TextButton(
            //                             onPressed: () =>
            //                                 Navigator.of(context).pop(),
            //                             child: const Text('OK'),
            //                           ),
            //                         ],
            //                       ),
            //                     );
            //                   } else {
            //                     logout(context);
            //                   }
            //                 } catch (e) {
            //                   print('Error checking work status: $e');
            //                   ScaffoldMessenger.of(context).showSnackBar(
            //                     const SnackBar(
            //                         content:
            //                             Text('Failed to check work status')),
            //                   );
            //                 }
            //               }
            //             },
            //           ):SizedBox(),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            body: isLoading == true
                ? buildLoaderListItem()
                : RefreshIndicator(
                    onRefresh: () async {
                      getData();
                    },
                    child: Stack(
                      children: [
                        SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       vertical: 20.0, horizontal: 8),
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       setState(() {
                                //         toggle = !toggle;
                                //       });
                                //       Common.saveSharedPref(
                                //           "acc_toggle", toggle.toString());
                                //     },
                                //     child: Container(
                                //       decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(12),
                                //         gradient: const LinearGradient(colors: [
                                //           Color(0xFF2a86c9),
                                //           Color(0xFF406dbe)
                                //         ]),
                                //       ),
                                //       child: Column(
                                //         children: [
                                //           // Container(
                                //           //   height: MediaQuery.of(context).size.height * .2,
                                //           //   decoration: BoxDecoration(
                                //           //       borderRadius: BorderRadius.circular(12),
                                //           //       image: DecorationImage(
                                //           //           image: AssetImage("assets/main/funriders.png"))),
                                //           // ),
                                //           const SizedBox(
                                //             height: 20,
                                //           ),
                                //           const Row(
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.spaceEvenly,
                                //             children: [
                                //               SizedBox(
                                //                 width: 20,
                                //               ),
                                //               Text(
                                //                 "Account Management",
                                //                 style: TextStyle(
                                //                     color: Colors.white,
                                //                     fontWeight: FontWeight.bold,
                                //                     fontSize: 25,
                                //                     shadows: [
                                //                       Shadow(
                                //                         offset:
                                //                             Offset(2.0, 2.0),
                                //                         blurRadius: 5.0,
                                //                         color: Colors.grey,
                                //                       ),
                                //                     ]),
                                //               ),
                                //               Icon(
                                //                 Icons
                                //                     .arrow_drop_down_circle_outlined,
                                //                 color: Colors.white,
                                //                 size: 25,
                                //               )
                                //             ],
                                //           ),
                                //           toggle
                                //               ? SizedBox(
                                //                   width: MediaQuery.of(context)
                                //                           .size
                                //                           .width *
                                //                       .95,
                                //                   height:
                                //                       _calculateGridViewHeight(
                                //                           list.length),
                                //                   child: Padding(
                                //                     padding:
                                //                         const EdgeInsets.all(
                                //                             16.0),
                                //                     child: GridView.builder(
                                //                       physics:
                                //                           const NeverScrollableScrollPhysics(),
                                //                       itemCount: list.length,
                                //                       gridDelegate:
                                //                           const SliverGridDelegateWithFixedCrossAxisCount(
                                //                               crossAxisCount: 2,
                                //                               mainAxisSpacing:
                                //                                   15,
                                //                               crossAxisSpacing:
                                //                                   15,
                                //                               childAspectRatio:
                                //                                   3),
                                //                       itemBuilder:
                                //                           (context, i) {
                                //                         return InkWell(
                                //                           onTap: () {
                                //                             if (list[i] ==
                                //                                 "Expense") {
                                //                               Navigator.push(
                                //                                   context,
                                //                                   MaterialPageRoute(
                                //                                     builder:
                                //                                         (context) =>
                                //                                             ExpenseList(),
                                //                                   ));
                                //                             } else if (list[
                                //                                     i] ==
                                //                                 "Invoices") {
                                //                               Navigator.push(
                                //                                 context,
                                //                                 MaterialPageRoute(
                                //                                     builder: (context) => InvoiceList(
                                //                                         widget
                                //                                             .token
                                //                                             .toString(),
                                //                                         "",
                                //                                         "",
                                //                                         "")),
                                //                               );
                                //                             } else if (list[
                                //                                         i] ==
                                //                                     "Proforma Invoices" &&
                                //                                 proformaInvoiceMenu ==
                                //                                     "true") {
                                //                               Navigator.push(
                                //                                 context,
                                //                                 MaterialPageRoute(
                                //                                     builder: (context) => ProformaInvoiceList(
                                //                                         widget
                                //                                             .token
                                //                                             .toString(),
                                //                                         "",
                                //                                         "",
                                //                                         "",
                                //                                         "")),
                                //                               );
                                //                             } else if (list[
                                //                                         i] ==
                                //                                     "GST Invoices" &&
                                //                                 gstInvoiceMenu ==
                                //                                     "true") {
                                //                               Navigator.push(
                                //                                 context,
                                //                                 MaterialPageRoute(
                                //                                     builder: (context) =>
                                //                                         GSTInvoiceList(widget
                                //                                             .token
                                //                                             .toString())),
                                //                               );
                                //                             }
                                //                             //  else if (list[i] ==
                                //                             //     "Updated Invoice") {
                                //                             //   Navigator.push(
                                //                             //     context,
                                //                             //     MaterialPageRoute(
                                //                             //         builder: (context) =>
                                //                             //             UpdatedInvoiceList(widget
                                //                             //                 .token
                                //                             //                 .toString())),
                                //                             //   );
                                //                             // }
                                //                             else if (list[i] ==
                                //                                 "Pending Invoices") {
                                //                               Navigator.push(
                                //                                 context,
                                //                                 MaterialPageRoute(
                                //                                     builder: (context) =>
                                //                                         PendingInvoice(widget
                                //                                             .token
                                //                                             .toString())),
                                //                               );
                                //                             } else if (list[
                                //                                     i] ==
                                //                                 "Receipts") {
                                //                               Navigator.push(
                                //                                 context,
                                //                                 MaterialPageRoute(
                                //                                     builder: (context) =>
                                //                                         ReceiptList(widget
                                //                                             .token
                                //                                             .toString())),
                                //                               );
                                //                             } else if (list[
                                //                                     i] ==
                                //                                 "Account Head") {
                                //                               if (dashboard!
                                //                                       .data
                                //                                       .isViewAccHead ==
                                //                                   true) {
                                //                                 Navigator.push(
                                //                                   context,
                                //                                   MaterialPageRoute(
                                //                                       builder:
                                //                                           (context) =>
                                //                                               const AccountHead()),
                                //                                 );
                                //                               } else {
                                //                                 Common.toastMessaage(
                                //                                     "No permission",
                                //                                     Colors.red);
                                //                               }
                                //                             } else {
                                //                               Navigator.push(
                                //                                 context,
                                //                                 MaterialPageRoute(
                                //                                     builder:
                                //                                         (context) =>
                                //                                             ClientList(
                                //                                               widget.token,
                                //                                               _scaffoldKey,
                                //                                             )),
                                //                               );
                                //                             }
                                //                           },
                                //                           child: Container(
                                //                             decoration:
                                //                                 BoxDecoration(
                                //                               color: const Color(
                                //                                   0xFFf0ebef),
                                //                               borderRadius:
                                //                                   BorderRadius
                                //                                       .circular(
                                //                                           12),
                                //                             ),
                                //                             child: Center(
                                //                               child: Text(
                                //                                 list[i],
                                //                                 style: TextStyle(
                                //                                     color:
                                //                                         tabColors[
                                //                                             i],
                                //                                     fontWeight:
                                //                                         FontWeight
                                //                                             .bold,
                                //                                     fontSize:
                                //                                         15),
                                //                               ),
                                //                             ),
                                //                           ),
                                //                         );
                                //                       },
                                //                     ),
                                //                   ),
                                //                 )
                                //               : const SizedBox(
                                //                   height: 20,
                                //                 ),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  height:
                                      MediaQuery.of(context).size.height * .63,
                                  child: GridView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 15,
                                            crossAxisSpacing: 15,
                                            childAspectRatio: 1.5),
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (dashboard!.data.bankAccCount ==
                                              "1") {
                                            if (dashboard!.data.isViewBankAcc) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BankAccount(
                                                      accId: dashboard!
                                                          .data.bankAccountId,
                                                      accName: dashboard!
                                                          .data.bankAccountName,
                                                    ),
                                                  ));
                                            } else {
                                              Common.toastMessaage(
                                                  "No permission", Colors.red);
                                            }
                                          } else if (dashboard!
                                                  .data.bankAccCount ==
                                              "0") {
                                            Common.toastMessaage(
                                                "Please add a 'BANK ACCOUNT'",
                                                Colors.red);
                                          } else {
                                            if (dashboard!
                                                .data.isViewPendingExpense) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PendingExpense(
                                                      status: "1",
                                                    ),
                                                  ));
                                            }
                                          }
                                        },
                                        child: gridItem(
                                            "BANK ACCOUNT",
                                            dashboard!.data.bankAccount,
                                            Colors.green,
                                            colorList[0]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (dashboard!
                                              .data.isViewPendingExpense) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PendingExpense(
                                                    status: "2",
                                                  ),
                                                ));
                                          } else {
                                            Common.toastMessaage(
                                                "No permission", Colors.red);
                                          }
                                        },
                                        child: gridItem(
                                            "PENDING EXPENSE",
                                            dashboard!.data.pendingExpense,
                                            Colors.red,
                                            colorList[1]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ReceiptList(
                                                  widget.token,
                                                  fdate: DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(DateTime.now()),
                                                  tdate: DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(DateTime.now()),
                                                ),
                                              ));
                                        },
                                        child: gridItem(
                                            "TODAYS INCOME",
                                            dashboard!.data.todaysIncome,
                                            Colors.black,
                                            colorList[2]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ExpenseList(
                                                  // fdate: DateFormat('dd-MM-yyyy')
                                                  //     .format(DateTime.now()),
                                                  // tdate: DateFormat('dd-MM-yyyy')
                                                  //     .format(DateTime.now()),
                                                  fdate: DateFormat(
                                                          'yyyy-MM-dd')
                                                      .format(DateTime.now()),
                                                  // tdate: DateFormat('dd-MM-yyyy')
                                                  tdate: DateFormat(
                                                          'yyyy-MM-dd')
                                                      .format(DateTime.now()),
                                                ),
                                              ));
                                        },
                                        child: gridItem(
                                            "TODAYS EXPENSE",
                                            dashboard!.data.todayExpense,
                                            Colors.black,
                                            colorList[3]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ReceiptList(
                                                  widget.token,
                                                  fdate: DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          1)),
                                                  tdate: DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(DateTime.now()),
                                                ),
                                              ));
                                        },
                                        child: gridItem(
                                            "THIS MONTH INCOME",
                                            dashboard!.data.monthlyIncome,
                                            Colors.black,
                                            colorList[4]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ExpenseList(
                                                  // fdate: DateFormat('dd-MM-yyyy')
                                                  //     .format(DateTime(
                                                  //         DateTime.now().year,
                                                  //         DateTime.now().month,
                                                  //         1)),
                                                  // tdate: DateFormat('dd-MM-yyyy')
                                                  //     .format(DateTime.now()),
                                                  fdate: DateFormat(
                                                          'yyyy-MM-dd')
                                                      .format(DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          1)),
                                                  // tdate: DateFormat('dd-MM-yyyy')
                                                  tdate: DateFormat(
                                                          'yyyy-MM-dd')
                                                      .format(DateTime.now()),
                                                ),
                                              ));
                                        },
                                        child: gridItem(
                                            "THIS MONTH EXPENSE",
                                            dashboard!.data.monthlyExpense,
                                            Colors.black,
                                            colorList[5]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PendingInvoice(
                                                        widget.token,''),
                                              ));
                                        },
                                        child: gridItem(
                                            "PENDING INVOICE",
                                            dashboard!.data.pendingIncome,
                                            Colors.black,
                                            colorList[6]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PendingExpense(
                                                  status: "3",
                                                ),
                                              ));
                                        },
                                        child: gridItem(
                                            "ADVANCE AMOUNT",
                                            dashboard!.data.advanceAmount,
                                            Colors.green,
                                            colorList[7]),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12.0,
                                    right: 12.0,
                                    bottom: 25.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFf0ebef),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 26.0,
                                              bottom: 16,
                                              left: 16.0,
                                              right: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  final selctedDatetimetemp =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        1),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime.now(),
                                                  );
                                                  fDate = DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(
                                                          selctedDatetimetemp!);
                                                  getList();
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.37,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 0.5,
                                                            color: Colors
                                                                .grey.shade300,
                                                            offset:
                                                                const Offset(
                                                                    2.5, 2.5))
                                                      ],
                                                      color: Colors.white),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          fDate,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                          color: Colors.white,
                                                        ),
                                                        child: const Icon(
                                                          Icons.calendar_month,
                                                          color: Colors.grey,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward,
                                                size: 16,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  final toDateSelectTemp =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  tDate = DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(
                                                          toDateSelectTemp!);
                                                  getList();
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.37,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 0.5,
                                                            color: Colors
                                                                .grey.shade300,
                                                            offset:
                                                                const Offset(
                                                                    2.5, 2.5))
                                                      ]),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          tDate,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors.white,
                                                        ),
                                                        child: const Icon(
                                                          Icons.calendar_month,
                                                          color: Colors.grey,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 16.0,
                                                  left: 16.0,
                                                  right: 16.0),
                                              child: Text(
                                                "Income",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25),
                                              ),
                                            ),
                                            if (dashboard!
                                                .data.incomeGraph.isNotEmpty)
                                              ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: dashboard!
                                                      .data.incomeGraph.length,
                                                  itemBuilder: (context, i) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ReceiptList(
                                                                        widget
                                                                            .token
                                                                            .toString(),
                                                                        type: dashboard!
                                                                            .data
                                                                            .incomeGraph[i]
                                                                            .type,
                                                                        fdate:
                                                                            fDate,
                                                                        tdate:
                                                                            tDate,
                                                                      )),
                                                        );
                                                      },
                                                      child: progressItem(
                                                          dashboard!
                                                              .data
                                                              .incomeGraph[i]
                                                              .category,
                                                          dashboard!
                                                              .data
                                                              .incomeGraph[i]
                                                              .totalExpense,
                                                          double.parse(
                                                              dashboard!
                                                                  .data
                                                                  .incomeGraph[
                                                                      i]
                                                                  .perc)),
                                                    );
                                                  })
                                            else
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 26.0),
                                                child: Text(
                                                  "Empty",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (dashboard!
                                            .data.expenseGraph.isNotEmpty)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16.0,
                                                    horizontal: 16.0),
                                                child: Text(
                                                  "Expense",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 25),
                                                ),
                                              ),
                                              ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: dashboard!
                                                      .data.expenseGraph.length,
                                                  itemBuilder: (context, i) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ExpenseList(
                                                                catId: dashboard!
                                                                    .data
                                                                    .expenseGraph[
                                                                        i]
                                                                    .expCatid,
                                                                catName: dashboard!
                                                                    .data
                                                                    .expenseGraph[
                                                                        i]
                                                                    .expCatName,
                                                                // fdate: fDate,
                                                                // tdate: tDate,
                                                                fdate:
                                                                    convertDate(
                                                                        fDate),
                                                                tdate:
                                                                    convertDate(
                                                                        tDate),
                                                              ),
                                                            ));
                                                      },
                                                      child: progressItem(
                                                          dashboard!
                                                              .data
                                                              .expenseGraph[i]
                                                              .expCatName,
                                                          dashboard!
                                                              .data
                                                              .expenseGraph[i]
                                                              .totalExpense,
                                                          double.parse(
                                                              dashboard!
                                                                  .data
                                                                  .expenseGraph[
                                                                      i]
                                                                  .perc)),
                                                    );
                                                  }),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: _floatingButtonPosition.dx == 0 ? 30 : null,
                          bottom: _floatingButtonPosition.dy == 0 ? 100 : null,
                          left: _floatingButtonPosition.dx != 0
                              ? _floatingButtonPosition.dx
                              : null,
                          top: _floatingButtonPosition.dy != 0
                              ? _floatingButtonPosition.dy
                              : null,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              final newPosition = Offset(
                                _floatingButtonPosition.dx + details.delta.dx,
                                _floatingButtonPosition.dy + details.delta.dy,
                              );
                              _updateFloatingButtonPosition(newPosition);
                            },
                            child: Column(
                              children: [
                                if (_showFloatingOptions) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            child: SizedBox(
                                              width: 130,
                                              child:
                                                  FloatingActionButton.extended(
                                                heroTag: "simple_invoice",
                                                onPressed: () {
                                                  setState(() {
                                                    _showFloatingOptions =
                                                        false;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddInvoiceUpdated(
                                                        widget.token,
                                                        "",
                                                        "",
                                                      ),
                                                    ),
                                                  );
                                                },
                                                label: const Text(
                                                  'Sale',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.receipt,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            child: SizedBox(
                                              width: 130,
                                              child:
                                                  FloatingActionButton.extended(
                                                heroTag: "complex_invoice",
                                                onPressed: () {
                                                  setState(() {
                                                    _showFloatingOptions =
                                                        false;
                                                  });
                                                  addInvoiceDialog(context);
                                                },
                                                label: const Text(
                                                  'Invoice',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.description,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                backgroundColor: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                                FloatingActionButton(
                                  heroTag: "main_floating_button",
                                  onPressed: () {
                                    setState(() {
                                      _showFloatingOptions =
                                          !_showFloatingOptions;
                                    });
                                  },
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child: _showFloatingOptions
                                        ? Icon(Icons.close, color: Colors.white)
                                        : Icon(Icons.add, color: Colors.white),
                                  ),
                                  backgroundColor: _showFloatingOptions
                                      ? Colors.red
                                      : Color(0xFF2a86c9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

            endDrawer: DraweScreen(token),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => AccountsDashboard(token: token)),
                // );
                ProjectDashboardPermission == "true"
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectDashboard()),
                      )
                    : AccountsDashboardPermission == "true"
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AccountsDashboard(token: token)),
                          )
                        : MenuDashboard == "true"
                            ? Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(token)),
                              )
                            : RenewalDashboardPermission == "true"
                                ? Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RenewalDashboard()),
                                  )
                                : Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DashboardLeadNewUpdatedTwo(token)),
                                  );
              },
              child: Image.asset("assets/icons/menu.png", width: 25),
            ),
            bottomNavigationBar: configure != null
                ? BottomNavigation(
                    token,
                    phoneCallLogPermission: phoneCallLogPermission,
                    name: name,
                    userId: userId,
                  )
                : const SizedBox(),
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

  String convertDate(String date) {
    final inputFormat = DateFormat('dd-MM-yyyy');
    final outputFormat = DateFormat('yyyy-MM-dd');

    final parsedDate = inputFormat.parse(date);
    return outputFormat.format(parsedDate);
  }

  Container progressItem(String name, String amount, double value) {
    return Container(
      color: const Color(0xFFf0ebef),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 26.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  amount,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey,
              value: value / 100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Container gridItem(
      String name, String value, Color amountColor, Color backGround) {
    return Container(
      decoration: BoxDecoration(
          color: backGround,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                blurRadius: 0.5,
                color: Colors.grey.shade300,
                offset: const Offset(2.5, 2.5))
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 13),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            value,
            style: TextStyle(
                color: amountColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget appBarWidget(BuildContext context, String type) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Padding(
          padding: EdgeInsets.only(
              left: 20, top: type == "lead" ? 55 : 15, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      try {
                        final result = await HttpService.getWorkStatus();
                        if (result != null && result.data.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout Blocked'),
                              content: const Text(
                                  'Work is in progress. Please close all work before logging out.'),
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
                        print('Error checking work status: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to check work status')),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Colors.grey.shade800,
                              offset: const Offset(0, 2.0),
                            )
                          ],
                          shape: BoxShape.circle,
                          color: const Color(0xFF2191ce)),
                      child: userDashboard != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                userDashboard!.data.profilePic,
                              ),
                            )
                          : Shimmer.fromColors(
                              enabled: true,
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: const CircleAvatar()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  userDashboard != null && startAndStopWorkPermission == "true"
                      ?
                      // StartStopToggle(
                      //     initialStatus: userDashboard!.data.loginCheck,
                      //     onToggle: (bool started) {
                      //       setState(() {
                      //         userDashboard!.data.loginCheck = started;
                      //       });
                      //     },
                      //   )
                      StartStopToggle(
                          initialStatus: userDashboard!.data.loginCheck,
                          onToggle: (bool started) {
                            setState(() {
                              userDashboard!.data.loginCheck = started;
                            });
                          },
                          setDashboardLoading: (bool loading) {
                            setState(() {
                              isLoading =
                                  loading; // This changes the dashboard loader state
                            });
                          },
                        )
                      : const SizedBox(),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage(
                                token,
                                createLeadCategory1,
                                updateLeadCategory1,
                                deleteLeadCategory1)),
                      ).then((r) {
                        getData();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Stack(
                        children: [
                          Image.asset("assets/icons/notification.png",
                              width: 20, color: Colors.white),
                          notificationCount > 0
                              ? Positioned(
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     if (_scaffoldKey.currentState != null) {
                  //       _scaffoldKey.currentState!.openEndDrawer();
                  //     }
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(right: 20),
                  //     child: Image.asset("assets/icons/menu.png", width: 20),
                  //   ),
                  // ),
                  AccountsMenuWidget(
                    token: widget.token!,
                    name: name,
                    userId: userId,
                    staffId: staffId,
                    isExpired: isExpired,
                    configure: configure,
                    leadDashboard: leadDashboard,
                    fromdate: fromdate.toString(),
                    todate: todate.toString(),
                    loadmore: loadmore,
                    onDataRefresh: () {
                      getData();
                    },
                    onStaffwiseRefresh: getList,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoaderListItem() {
    return Shimmer.fromColors(
        enabled: true,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * .95,
                  height: MediaQuery.of(context).size.height * .25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                height: MediaQuery.of(context).size.height * .67,
                child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.5),
                  children: [
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
