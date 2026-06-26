// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/models/dashboardModel.dart';
import 'package:login2/models/lead_management/leadDashboardModel.dart';
import 'package:login2/models/renewal/renewal_dashboard_model.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_followup_list.dart';
import 'package:login2/screens/accounts/renewal_mannagement/custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/hidden_clients.dart';
import 'package:login2/screens/accounts/renewal_mannagement/payment_reports.dart';
import 'package:login2/screens/accounts/renewal_mannagement/quck_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list_new.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/notification_page.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/widgets/customerListDropdown.dart';
import 'package:login2/widgets/renewal_grid_widget.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/grid_shimmer.dart';
import 'package:login2/widgets/togglebutton_start.dart';
import 'package:shimmer/shimmer.dart';

class RenewalDashboard extends StatefulWidget {
  const RenewalDashboard({super.key});

  @override
  State<RenewalDashboard> createState() => _RenewalDashboardState();
}

class _RenewalDashboardState extends State<RenewalDashboard> {
  RenewalDashboardModel? renewalDashboard;
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  bool isLoading = true;
  String token = "";

  String phoneCallLogPermission = '';
  LeadDashboardModel? leadDashboard;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String name = '';
  String userId = '';
  String role = '';
  String startAndStopWorkPermission = '';
  CommonConfigureModel? configure;
  DashboardModel? userDashboard;
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  int notificationCount = 0;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  getDashboard() async {
    setState(() {
      isLoading = true;
    });

    token = await Common.getSharedPref("token");
    renewalDashboard = await HttpService.renewalDashboard();
    configure = await HttpService.configure(token);
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
    startAndStopWorkPermission =
        await Common.getSharedPref("startAndStopWorkPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    updateLeadCategory = await Common.getSharedPref("updateLeadCategory");
    deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory");

    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';

    userDashboard = await HttpService.mainDashboard(token);
    leadDashboard = await HttpService.leadDashboard(
        token, fromdate, todate, fromdate1, todate1);
    setState(() {
      notificationCount = leadDashboard!.data.unreadNotification;
    });
    Common.saveSharedPref("profile_pic", userDashboard!.data.profilePic);
    if (renewalDashboard != null && renewalDashboard!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getDashboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      appBar: appBarWidget(context, "lead"),
      // appBar: PreferredSize(
      //   preferredSize:
      //       Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
      //   child: Container(
      //     padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      //     decoration: const BoxDecoration(
      //       // color: Color(0xFF2a86c9),
      //       // image: DecorationImage(
      //       //   fit: BoxFit.cover,
      //       //   image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxm1-0D3a3KOSC29gIUrre2R8sMnYVr-_6rA&usqp=CAU")),
      //       gradient: LinearGradient(
      //           colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
      //     ),
      //     child: Padding(
      //       padding: const EdgeInsets.only(
      //           left: 10.0, top: 10.0, bottom: 10.0, right: 10),
      //       child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 RenewalDashboardPermission == "false"
      //                     ? InkWell(
      //                         onTap: () {
      //                           Navigator.pop(context);
      //                         },
      //                         child: Container(
      //                           height: 25,
      //                           width: 25,
      //                           decoration: BoxDecoration(
      //                               border: Border.all(color: Colors.white),
      //                               shape: BoxShape.circle),
      //                           child: const Icon(
      //                             Icons.arrow_back_ios_outlined,
      //                             color: Colors.white,
      //                             size: 16,
      //                           ),
      //                         ),
      //                       )
      //                     : SizedBox(),
      //                 const SizedBox(
      //                   width: 25,
      //                 ),
      //                 const Text(
      //                   "Renewal Management",
      //                   style: TextStyle(color: Colors.white, fontSize: 18),
      //                 ),
      //               ],
      //             ),
      //             PopupMenuButton<String>(
      //               iconColor: Colors.white,
      //               color: Colors.white,
      //               onSelected: (value) async {
      //                 if (value == "1") {
      //                   Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                         builder: (context) =>
      //                             const HiddenCilientsScreen(),
      //                       )).then((_) {
      //                     getDashboard();
      //                   });
      //                 } else if (value == "2") {
      //                   Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                         builder: (context) => const PaymentReport(),
      //                       )).then((_) {
      //                     getDashboard();
      //                   });
      //                 } else {
      //                   try {
      //                     final result = await HttpService.getWorkStatus();
      //                     if (result != null && result.data.isNotEmpty) {
      //                       showDialog(
      //                         context: context,
      //                         builder: (context) => AlertDialog(
      //                           title: const Text('Logout Blocked'),
      //                           content: const Text(
      //                               'Work is in progress. Please close all work before logging out.'),
      //                           actions: [
      //                             TextButton(
      //                               onPressed: () =>
      //                                   Navigator.of(context).pop(),
      //                               child: const Text('OK'),
      //                             ),
      //                           ],
      //                         ),
      //                       );
      //                     } else {
      //                       logout(context);
      //                     }
      //                   } catch (e) {
      //                     print('Error checking work status: $e');
      //                     ScaffoldMessenger.of(context).showSnackBar(
      //                       const SnackBar(
      //                           content: Text('Failed to check work status')),
      //                     );
      //                   }
      //                 }
      //               },
      //               itemBuilder: (BuildContext context) {
      //                 return [
      //                   const PopupMenuItem<String>(
      //                     value: '1',
      //                     child: Text('Hidden Clients'),
      //                   ),
      //                   const PopupMenuItem<String>(
      //                     value: '2',
      //                     child: Text('Payment Report'),
      //                   ),
      //                   const PopupMenuItem<String>(
      //                     value: '3',
      //                     child: Text('Logout'),
      //                   ),
      //                 ];
      //               },
      //             ),
      //           ]),
      //     ),
      //   ),
      // ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: isLoading == true
              ? ShimmerGridView(
                  type: "s",
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: TextField(
                    //     onChanged: (value) {
                    //       print("Searching for: $value");
                    //     },
                    //     decoration: InputDecoration(
                    //       hintText: "Search...",
                    //       prefixIcon:
                    //           const Icon(Icons.search, color: Colors.grey),
                    //       filled: true,
                    //       fillColor: Colors.grey.shade100,
                    //       contentPadding:
                    //           const EdgeInsets.symmetric(vertical: 12),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //         borderSide: BorderSide.none,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    CustomerSearchBox(token: token),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RenewalFollowupList(
                              clientId: "",
                              clientName: "",
                            ),
                          ),
                        ).then((_) {
                          getDashboard();
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * .95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.blue.shade50,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 5,
                              offset: const Offset(0, -2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade600,
                                            Colors.blue.shade800,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.shade300,
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.timer_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "UPCOMING RENEWALS",
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            renewalDashboard!
                                                .data.upcomingRenewals,
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 2,
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            "Renewals pending action",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade500,
                                      Colors.green.shade700,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.shade300,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CustomRenewal(),
                                        ),
                                      ).then((_) {
                                        getDashboard();
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_circle_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "ADD RENEWAL",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => RenewalFollowupList(
                    //           clientId: "",
                    //           clientName: "",
                    //         ),
                    //       ),
                    //     ).then((_) {
                    //       getDashboard();
                    //     });
                    //   },
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width * .95,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(12),
                    //       color: Colors.white,
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.blueGrey.shade100,
                    //           blurRadius: 8,
                    //           offset: const Offset(0, 3),
                    //         ),
                    //       ],
                    //       border: Border.all(
                    //         color: Colors.blue.shade100,
                    //         width: 1,
                    //       ),
                    //     ),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(18.0),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               Container(
                    //                 padding: EdgeInsets.all(10),
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.blue.shade50,
                    //                   borderRadius: BorderRadius.circular(10),
                    //                   border: Border.all(
                    //                     color: Colors.blue.shade200,
                    //                     width: 1,
                    //                   ),
                    //                 ),
                    //                 child: Icon(
                    //                   Icons.schedule_rounded,
                    //                   color: Colors.blue.shade700,
                    //                   size: 24,
                    //                 ),
                    //               ),
                    //               SizedBox(width: 16),
                    //               Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     "Upcoming Renewals",
                    //                     style: TextStyle(
                    //                       color: Colors.blue.shade800,
                    //                       fontSize: 15,
                    //                       fontWeight: FontWeight.bold,
                    //                     ),
                    //                   ),
                    //                   SizedBox(height: 6),
                    //                   Text(
                    //                     renewalDashboard!.data.upcomingRenewals,
                    //                     style: TextStyle(
                    //                       color: Colors.blue.shade900,
                    //                       fontSize: 28,
                    //                       fontWeight: FontWeight.bold,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //           ElevatedButton.icon(
                    //             onPressed: () {
                    //               Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                   builder: (context) => CustomRenewal(),
                    //                 ),
                    //               ).then((_) {
                    //                 getDashboard();
                    //               });
                    //             },
                    //             icon: Icon(
                    //               Icons.add_circle_outline_rounded,
                    //               size: 20,
                    //             ),
                    //             label: Text(
                    //               "Add Renewal",
                    //               style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w600,
                    //               ),
                    //             ),
                    //             style: ElevatedButton.styleFrom(
                    //               elevation: 2,
                    //               backgroundColor: Colors.blue.shade600,
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: 16, vertical: 12),
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => RenewalFollowupList(
                    //             clientId: "",
                    //             clientName: "",
                    //           ),
                    //         )).then((_) {
                    //       getDashboard();
                    //     });
                    //   },
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width * .95,
                    //     decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(5),
                    //         color: Colors.white,
                    //         boxShadow: [
                    //           BoxShadow(
                    //             blurRadius: 2,
                    //             color: Colors.grey.shade600,
                    //             offset: const Offset(0, 2.0),
                    //           )
                    //         ]),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(16.0),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //         children: [
                    //           Column(
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               Text("Upcoming Renewals :",
                    //                   style: TextStyle(
                    //                       color: Colors.blue.shade900,
                    //                       fontSize: 15,
                    //                       fontWeight: FontWeight.bold)),
                    //               Text(
                    //                 renewalDashboard!.data.upcomingRenewals,
                    //                 style: TextStyle(
                    //                     color: Colors.blue.shade900,
                    //                     fontSize: 25,
                    //                     fontWeight: FontWeight.bold),
                    //               ),
                    //             ],
                    //           ),
                    //           ElevatedButton.icon(
                    //             onPressed: () {
                    //               Navigator.push(
                    //                   context,
                    //                   MaterialPageRoute(
                    //                     builder: (context) => CustomRenewal(),
                    //                   )).then((_) {
                    //                 getDashboard();
                    //               });
                    //             },
                    //             label: const Text(
                    //               "Add Renewal",
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 15,
                    //                   fontWeight: FontWeight.bold),
                    //             ),
                    //             style: ElevatedButton.styleFrom(
                    //                 elevation: 1, backgroundColor: Colors.blue),
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 15,
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * .25,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Renewal Overview",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                Text(
                                  "Swipe to view",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return _buildRenewalCard(index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

// Add this method to your class:

                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * .2,
                    //   width: MediaQuery.of(context).size.width,
                    //   child: ListView(
                    //     scrollDirection: Axis.horizontal,
                    //     // gridDelegate:
                    //     //     const SliverGridDelegateWithFixedCrossAxisCount(
                    //     //   crossAxisCount: 2,
                    //     //   crossAxisSpacing: 10.0,
                    //     //   mainAxisSpacing: 10.0,
                    //     //   childAspectRatio: 1.2,
                    //     // ),
                    //     shrinkWrap: true,
                    //     children: [
                    //       GestureDetector(
                    //         onTap: () {
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => RenewalList(
                    //                    custId: "",
                    //                   title: "Current Month",
                    //                   searchKey: "current_month",
                    //                   searchMonth: "",
                    //                   renewed: int.parse(renewalDashboard!
                    //                       .data.currentMonthData.paidCount),
                    //                 ),
                    //               )).then((_) {
                    //             getDashboard();
                    //           });
                    //         },
                    //         child: RenewalGridItem(
                    //           title: "Current Month",
                    //           paidAmount: renewalDashboard!
                    //               .data.currentMonthData.paidAmount
                    //               .toString(),
                    //           paidCount: renewalDashboard!
                    //               .data.currentMonthData.paidCount
                    //               .toString(),
                    //           totalAmount: renewalDashboard!
                    //               .data.currentMonthData.totalAmount
                    //               .toString(),
                    //           totalCount: renewalDashboard!
                    //               .data.currentMonthData.totalCount
                    //               .toString(),
                    //           color: const Color(0xFF2a86c9),
                    //         ),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => RenewalList(
                    //                    custId: "",
                    //                   title: "Next Month",
                    //                   searchKey: "next_month",
                    //                   searchMonth: "",
                    //                   renewed: int.parse(renewalDashboard!
                    //                       .data.nextMonthData.paidCount),
                    //                 ),
                    //               )).then((_) {
                    //             getDashboard();
                    //           });
                    //         },
                    //         child: RenewalGridItem(
                    //           title: "Next Month",
                    //           paidAmount: renewalDashboard!
                    //               .data.nextMonthData.paidAmount
                    //               .toString(),
                    //           paidCount: renewalDashboard!
                    //               .data.nextMonthData.paidCount
                    //               .toString(),
                    //           totalAmount: renewalDashboard!
                    //               .data.nextMonthData.totalAmount
                    //               .toString(),
                    //           totalCount: renewalDashboard!
                    //               .data.nextMonthData.totalCount
                    //               .toString(),
                    //           color: const Color(0xFF2a86c9),
                    //         ),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => RenewalList(
                    //                    custId: "",
                    //                   title: "Current Year",
                    //                   searchKey: "current_year",
                    //                   searchMonth: "",
                    //                   renewed: int.parse(renewalDashboard!
                    //                       .data.allData.paidCount),
                    //                 ),
                    //               )).then((_) {
                    //             getDashboard();
                    //           });
                    //         },
                    //         child: RenewalGridItem(
                    //           title: "Current Year",
                    //           paidAmount: renewalDashboard!
                    //               .data.allData.paidAmount
                    //               .toString(),
                    //           paidCount: renewalDashboard!
                    //               .data.allData.paidCount
                    //               .toString(),
                    //           totalAmount: renewalDashboard!
                    //               .data.allData.totalAmount
                    //               .toString(),
                    //           totalCount: renewalDashboard!
                    //               .data.allData.totalCount
                    //               .toString(),
                    //           color: const Color(0xFF2a86c9),
                    //         ),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => RenewalList(
                    //                    custId: "",
                    //                   title: "Expired",
                    //                   searchMonth: "",
                    //                   searchKey: "expired",
                    //                   renewed: int.parse(renewalDashboard!
                    //                       .data.expiredData.paidCount),
                    //                 ),
                    //               )).then((_) {
                    //             getDashboard();
                    //           });
                    //         },
                    //         child: RenewalGridItem(
                    //             title: "Expired",
                    //             paidAmount: renewalDashboard!
                    //                 .data.expiredData.paidAmount
                    //                 .toString(),
                    //             paidCount: renewalDashboard!
                    //                 .data.expiredData.paidCount
                    //                 .toString(),
                    //             totalAmount: renewalDashboard!
                    //                 .data.expiredData.totalAmount
                    //                 .toString(),
                    //             totalCount: renewalDashboard!
                    //                 .data.expiredData.totalCount
                    //                 .toString(),
                    //             color: Colors.red.shade200),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 15,
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: TextField(
                    //     onChanged: (value) {
                    //       print("Searching for: $value");
                    //     },
                    //     decoration: InputDecoration(
                    //       hintText: "Search...",
                    //       prefixIcon:
                    //           const Icon(Icons.search, color: Colors.grey),
                    //       filled: true,
                    //       fillColor: Colors.grey.shade100,
                    //       contentPadding:
                    //           const EdgeInsets.symmetric(vertical: 12),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //         borderSide: BorderSide.none,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                color: Colors.grey.shade600,
                                offset: const Offset(0, 2.0),
                              )
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.blue.shade600,
                                    Colors.blue.shade500,
                                  ]),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  )),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Renewal Reports",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16.0, top: 16.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .9,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      renewalDashboard!.data.monthReport.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RenewalListNew(
                                                custId: "",
                                                custName: "",
                                                title: renewalDashboard!.data
                                                    .monthReport[index].label,
                                                searchKey: "",
                                                searchMonth: renewalDashboard!
                                                    .data
                                                    .monthReport[index]
                                                    .searchMonth
                                                    .toString(),
                                                renewed: 0,
                                              ),
                                            )).then((_) {
                                          getDashboard();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 10.0,
                                            left: 20.0,
                                            right: 20.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(renewalDashboard!.data
                                                    .monthReport[index].label),
                                                Text(
                                                  "₹ ${renewalDashboard!.data.monthReport[index].amount.toString()} /-",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            LinearProgressIndicator(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              backgroundColor: Colors.grey,
                                              value: renewalDashboard!
                                                      .data
                                                      .monthReport[index]
                                                      .percentage /
                                                  100,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue.shade400),
                                              minHeight: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
        ),
      )),
      endDrawer: DraweScreen(token),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => RenewalDashboard()),
          // );
          ProjectDashboardPermission == "true"
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectDashboard()),
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
                                  builder: (context) => RenewalDashboard()),
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
                        getDashboard();
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
                  InkWell(
                    onTap: () {
                      if (_scaffoldKey.currentState != null) {
                        _scaffoldKey.currentState!.openEndDrawer();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset("assets/icons/menu.png", width: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRenewalCard(int index) {
    late Map<String, dynamic> cardData;
    if (renewalDashboard != null) {
      switch (index) {
        case 0:
          cardData = {
            'title': 'Current Month',
            'paidAmount':
                renewalDashboard!.data.currentMonthData.paidAmount.toString(),
            'paidCount':
                renewalDashboard!.data.currentMonthData.paidCount.toString(),
            'totalAmount':
                renewalDashboard!.data.currentMonthData.totalAmount.toString(),
            'totalCount':
                renewalDashboard!.data.currentMonthData.totalCount.toString(),
            'color': Color(0xFF2a86c9),
            'searchKey': 'current_month',
            'renewed':
                int.parse(renewalDashboard!.data.currentMonthData.paidCount),
          };
          break;
        case 1:
          cardData = {
            'title': 'Next Month',
            'paidAmount':
                renewalDashboard!.data.nextMonthData.paidAmount.toString(),
            'paidCount':
                renewalDashboard!.data.nextMonthData.paidCount.toString(),
            'totalAmount':
                renewalDashboard!.data.nextMonthData.totalAmount.toString(),
            'totalCount':
                renewalDashboard!.data.nextMonthData.totalCount.toString(),
            'color': Color(0xFF2a86c9),
            'searchKey': 'next_month',
            'renewed':
                int.parse(renewalDashboard!.data.nextMonthData.paidCount),
          };
          break;
        case 2:
          cardData = {
            'title': 'Current Year',
            'paidAmount': renewalDashboard!.data.allData.paidAmount.toString(),
            'paidCount': renewalDashboard!.data.allData.paidCount.toString(),
            'totalAmount':
                renewalDashboard!.data.allData.totalAmount.toString(),
            'totalCount': renewalDashboard!.data.allData.totalCount.toString(),
            'color': Color(0xFF2a86c9),
            'searchKey': 'current_year',
            'renewed': int.parse(renewalDashboard!.data.allData.paidCount),
          };
          break;
        case 3:
          cardData = {
            'title': 'Expired',
            'paidAmount':
                renewalDashboard!.data.expiredData.paidAmount.toString(),
            'paidCount':
                renewalDashboard!.data.expiredData.paidCount.toString(),
            'totalAmount':
                renewalDashboard!.data.expiredData.totalAmount.toString(),
            'totalCount':
                renewalDashboard!.data.expiredData.totalCount.toString(),
            'color': Colors.red.shade400,
            'searchKey': 'expired',
            'renewed': int.parse(renewalDashboard!.data.expiredData.paidCount),
          };
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RenewalListNew(
              custId: "",
              custName: "",
              title: cardData['title'],
              searchKey: cardData['searchKey'],
              searchMonth: "",
              renewed: cardData['renewed'],
            ),
          ),
        ).then((_) {
          getDashboard();
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                cardData['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cardData['color'],
                ),
              ),
              SizedBox(height: 12),

              // Paid section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Paid",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "₹${cardData['paidAmount']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${cardData['paidCount']} items",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "₹${cardData['totalAmount']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${cardData['totalCount']} items",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Progress bar
              SizedBox(height: 5),
              LinearProgressIndicator(
                value: cardData['totalCount'] != "0"
                    ? int.parse(cardData['paidCount']) /
                        int.parse(cardData['totalCount'])
                    : 0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(cardData['color']),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    cardData['totalCount'] != "0"
                        ? "${((int.parse(cardData['paidCount']) / int.parse(cardData['totalCount'])) * 100).toStringAsFixed(0)}% completed"
                        : "0% completed",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> renewalAddDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            content: Column(
              children: [
                SizedBox(
                    height: 100,
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Image.asset("assets/main/bill_funriders.png"),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuickRenewal(),
                              )).then((_) {
                            getDashboard();
                          });
                        },
                        child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(child: Text('Quick\nInsert')))),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomRenewal(),
                              )).then((_) {
                            getDashboard();
                          });
                        },
                        child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child:
                                const Center(child: Text('Custom\nRenewal'))))
                  ],
                )
              ],
            ),
          );
        });
  }
}
