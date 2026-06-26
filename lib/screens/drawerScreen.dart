// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/main.dart';
import 'package:login2/screens/leadManagement/CompanyLocationPage.dart';
import 'package:login2/screens/leadManagement/setDashboard.dart';
import 'package:login2/screens/leadManagement/webview.dart';
import 'package:login2/service/backgroundService.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workmanager/workmanager.dart';
import '../../core/common.dart';
import '../../models/commonsettingsModel.dart';
import '../../screens/authentication/login.dart';
import '../../screens/changePassword.dart';
import '../../screens/homePage.dart';
import '../../service/service.dart';
import 'package:login2/models/lead_management/profile_response_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/updateModel.dart';

class DraweScreen extends StatefulWidget {
  String token;

  DraweScreen(this.token, {super.key});

  @override
  _DraweScreenState createState() => _DraweScreenState();
}

class _DraweScreenState extends State<DraweScreen> {
  bool? result = true;
  bool? result1 = true;
  CommonSettingsModel? commmon;
  ProfileResponseModel? _profileData;
  bool _isLoadingProfile = false;
  String name = '';
  String role = '';
  String roleId = '';
  String userId = '';
  bool isVisible = true;
  final List<Color> _textColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  // List supportNames = ["Pradeesh", "Swetha", "Abina", "Unnimaya", "Login2"];
  // List supportPhone = [
  //   "8086935814",
  //   "9746981138",
  //   "9567616533",
  //   "9567256533",
  //   "9061125533"
  // ];
  List supportNames = ["Swetha", "Abina", "Unnimaya", "Login2"];
  List supportPhone = ["9746981138", "9567616533", "9567256533", "9061125533"];
  int _currentColorIndex = 0;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  UpdateModel? updatedata;
  final MethodChannel _channel =
      const MethodChannel('onreBootInitFunctionChannel');

  @override
  void initState() {
    super.initState();
    getData();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _currentColorIndex = (_currentColorIndex + 1) % _textColors.length;
    });
  }

  getData() async {
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    roleId = await Common.getSharedPref("roleId");
    userId = await Common.getSharedPref("userId");
    setState(() {
      result = result1;
    });
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    commmon = await HttpService.commonSettings();
    if (commmon != null) {
      updatedata = await HttpService.forceUpdate();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
        ),
        child: SizedBox(
          width: 250,
          child: Drawer(
              child: commmon != null
                  ? Column(
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                // Colors.purple,
                                Color(0xFF406dbe),
                                Colors.white,
                                Color(0xFF406dbe),
                              ])),
                          child: DrawerHeader(
                              child: Center(
                            child: Image.asset('assets/main/funriders.png',
                                height: 130, fit: BoxFit.contain),
                          )),
                        ),
                        // Expanded(
                        //   child: Column(
                        //     children: [
                        //       const SizedBox(
                        //         height: 10,
                        //       ),
                        //       ListTile(
                        //         leading: SizedBox(
                        //             width: 25,
                        //             child: Center(
                        //               child: Image.asset(
                        //                   'assets/icons/home.png',
                        //                   height: 100,
                        //                   fit: BoxFit.contain),
                        //             )),
                        //         title: const Text('Home'),
                        //         onTap: () => {
                        //           Navigator.of(context).push(
                        //             MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     HomePage(widget.token)),
                        //           ),
                        //         },
                        //       ),
                        //       // ListTile(
                        //       //   leading: SizedBox(
                        //       //       width: 25,
                        //       //       child: Center(
                        //       //         child: Image.asset('assets/main/user.png',
                        //       //             height: 120, fit: BoxFit.contain),
                        //       //       )),
                        //       //   title: const Text('Profile'),
                        //       //   onTap: () => {
                        //       //
                        //       //   },
                        //       // ),
                        //       if (roleId == "2")
                        //         ListTile(
                        //           leading: SizedBox(
                        //               width: 25,
                        //               child: Center(
                        //                 child: Image.asset(
                        //                     'assets/main/padlock.png',
                        //                     height: 100,
                        //                     fit: BoxFit.contain),
                        //               )),
                        //           title: const Text('Change Password'),
                        //           onTap: () => {
                        //             Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                   builder: (context) =>
                        //                       UserChangePassword(widget.token)),
                        //             ),
                        //           },
                        //         ),
                        //       ListTile(
                        //         leading: SizedBox(
                        //             width: 25,
                        //             child: Center(
                        //               child: Image.asset(
                        //                   'assets/main/insurance.png',
                        //                   height: 100,
                        //                   fit: BoxFit.contain),
                        //             )),
                        //         title: const Text('Privacy T&C'),
                        //         onTap: () async => {
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //                 builder: (context) => const WebViewPage(
                        //                     'Privacy T&C',
                        //                     'https://login2.co.in/privacypolicy.html')),
                        //           ),
                        //         },
                        //       ),
                        //       ListTile(
                        //         leading: SizedBox(
                        //             width: 25,
                        //             child: Center(
                        //               child: Image.asset(
                        //                   'assets/icons/notification.png',
                        //                   height: 100,
                        //                   fit: BoxFit.contain),
                        //             )),
                        //         title: const Text('Notification Settings'),
                        //         onTap: () {
                        //           AppSettings.openAppSettings(
                        //               type: AppSettingsType.notification);
                        //         },
                        //       ),

                        //       ListTile(
                        //         leading:
                        //             Icon(Icons.location_on, color: Colors.red),
                        //         title: const Text('Company Locations'),
                        //         onTap: () {
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     const CompanyLocationPage()),
                        //           );
                        //         },
                        //       ),

                        //       ListTile(
                        //         leading:
                        //             Icon(Icons.dashboard_customize, color: const Color.fromARGB(255, 40, 160, 216)),
                        //         title: const Text('Set Dasboard'),
                        //         onTap: () {
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     const CompanyLocationPage()),
                        //           );
                        //         },
                        //       ),

                        //       // ListTile(
                        //       //   leading: SizedBox(
                        //       //       width: 25,
                        //       //       child: Center(
                        //       //         child: Image.asset(
                        //       //             'assets/icons/facebook.png',
                        //       //             height: 100,
                        //       //             fit: BoxFit.contain),
                        //       //       )),
                        //       //   title: const Text('Facebook Settings'),
                        //       //   onTap: () {
                        //       //     Navigator.push(
                        //       //       context,
                        //       //       MaterialPageRoute(
                        //       //           builder: (context) =>
                        //       //               FacebookSettings(widget.token)),
                        //       //     );
                        //       //   },
                        //       // ),
                        //       ListTile(
                        //         leading: SizedBox(
                        //             width: 25,
                        //             child: Center(
                        //               child: Image.asset(
                        //                   'assets/icons/logout.png',
                        //                   height: 100,
                        //                   fit: BoxFit.contain),
                        //             )),
                        //         title: const Text('Logout'),
                        //         //  onTap: () => logout(context),
                        //         onTap: () async {
                        //           try {
                        //             final result =
                        //                 await HttpService.getWorkStatus();
                        //             if (result != null &&
                        //                 result.data.isNotEmpty) {
                        //               showDialog(
                        //                 context: context,
                        //                 builder: (context) => AlertDialog(
                        //                   title: const Text('Logout Blocked'),
                        //                   content: const Text(
                        //                       'Work is in progress. Please close all work before logging out.'),
                        //                   actions: [
                        //                     TextButton(
                        //                       onPressed: () =>
                        //                           Navigator.of(context).pop(),
                        //                       child: const Text('OK'),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               );
                        //             } else {
                        //               logout(context);
                        //             }
                        //           } catch (e) {
                        //             print('Error checking work status: $e');
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               const SnackBar(
                        //                   content: Text(
                        //                       'Failed to check work status')),
                        //             );
                        //           }
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            children: [
                              ListTile(
                                leading: SizedBox(
                                  width: 25,
                                  child: Center(
                                    child: Image.asset('assets/icons/home.png',
                                        height: 24, fit: BoxFit.contain),
                                  ),
                                ),
                                title: const Text('Home'),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HomePage(widget.token)),
                                  );
                                },
                              ),
                              ListTile(
                                leading: SizedBox(
                                  width: 25,
                                  child: Center(
                                    child: Image.asset('assets/main/user.png',
                                        height: 24, fit: BoxFit.contain),
                                  ),
                                ),
                                title: const Text('Profile'),
                                onTap: () {
                                  _showProfileView();
                                },
                              ),
                              if (roleId == "2")
                                ListTile(
                                  leading: SizedBox(
                                    width: 25,
                                    child: Center(
                                      child: Image.asset(
                                          'assets/main/padlock.png',
                                          height: 24,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                  title: const Text('Change Password'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserChangePassword(widget.token)),
                                    );
                                  },
                                ),
                              ListTile(
                                leading: SizedBox(
                                  width: 25,
                                  child: Center(
                                    child: Image.asset(
                                        'assets/main/insurance.png',
                                        height: 24,
                                        fit: BoxFit.contain),
                                  ),
                                ),
                                title: const Text('Privacy T&C'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WebViewPage(
                                        'Privacy T&C',
                                        'https://login2.co.in/privacypolicy.html',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: SizedBox(
                                  width: 25,
                                  child: Center(
                                    child: Image.asset(
                                        'assets/icons/notification.png',
                                        height: 24,
                                        fit: BoxFit.contain),
                                  ),
                                ),
                                title: const Text('Notification Settings'),
                                onTap: () {
                                  AppSettings.openAppSettings(
                                      type: AppSettingsType.notification);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.red),
                                title: const Text('Company Locations'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CompanyLocationPage()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.dashboard_customize,
                                    color: Color.fromARGB(255, 40, 160, 216)),
                                title: const Text('Set Dashboard'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SetDashboardPage(id: userId)),
                                  );
                                },
                              ),
                              ListTile(
                                leading: SizedBox(
                                  width: 25,
                                  child: Center(
                                    child: Image.asset(
                                        'assets/icons/logout.png',
                                        height: 24,
                                        fit: BoxFit.contain),
                                  ),
                                ),
                                title: const Text('Logout'),
                                onTap: () async {
                                  try {
                                    final result =
                                        await HttpService.getWorkStatus();
                                    if (result != null &&
                                        result.data.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Logout Blocked'),
                                          content: const Text(
                                              'Work is in progress. Please close all work before logging out.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
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
                                          content: Text(
                                              'Failed to check work status')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Version : ${_packageInfo.version}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue
                                                .shade900, // Text color when visible
                                          ),
                                        ),
                                      ],
                                    )),
                                const SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 25, bottom: 30, top: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () async {
                                          final whatsappLink =
                                              "https://wa.me/${commmon!.data!.customerCareWhatsapp}";
                                          await launch(whatsappLink);
                                        },
                                        child: Image.asset(
                                          'assets/icons/whatsapp.png',
                                          fit: BoxFit.contain,
                                          width: 25,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Login2 Support",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.blue.shade900),
                                                ),
                                                content: SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .45,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .7,
                                                  child: ListView.builder(
                                                      itemCount:
                                                          supportNames.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          onTap: () {
                                                            Common.dialPad(
                                                                supportPhone[
                                                                    index]);
                                                            // FlutterPhoneDirectCaller
                                                            //     .callNumber(
                                                            //         supportPhone[
                                                            //             index]);
                                                          },
                                                          title: Text(
                                                            supportNames[index],
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          subtitle: Text(
                                                            supportPhone[index],
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "close",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ))
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Image.asset(
                                            'assets/icons/telephone.png',
                                            fit: BoxFit.contain,
                                            width: 25),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final whatsappLink = commmon!
                                              .data!.supportUrl
                                              .toString();
                                          await launch(whatsappLink);
                                        },
                                        child: Image.asset(
                                            'assets/icons/web.png',
                                            fit: BoxFit.contain,
                                            width: 25),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          fit: BoxFit.fill),
                    )),
        ),
      ),
    );
  }

  void _showProfileView() async {
    setState(() {
      _isLoadingProfile = true;
    });

    final profile = await HttpService.getProfileView();

    setState(() {
      _profileData = profile;
      _isLoadingProfile = false;
    });

    if (!mounted) return;

    if (profile == null || profile.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile data')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Header with Gradient
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profile.data?.staffName?.isNotEmpty == true
                            ? profile.data!.staffName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.data?.staffName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildProfileItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: profile.data?.email ?? 'N/A',
                    color: Colors.orange,
                  ),
                  _buildProfileItem(
                    icon: Icons.phone_android_outlined,
                    title: 'Phone',
                    value: profile.data?.phoneNo ?? 'N/A',
                    color: Colors.green,
                  ),
                  _buildProfileItem(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    value: profile.data?.address1 ?? 'N/A',
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _launchURL(String url) async {
    launchUrl(Uri.parse(url));
  }
}

const MethodChannel _channel = MethodChannel('onreBootInitFunctionChannel');

void logout(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissing by tapping outside
    builder: (BuildContext ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon at the top
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Confirm Logout',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                'Are you sure you want to logout?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.blue,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final isWorkStarted =
                            await Common.getSharedPref("is_work_started");
                        if (isWorkStarted == "true") {
                          final now = DateTime.now();
                          try {
                            final position =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );

                            final response = await HttpService.stopWork(
                              now,
                              latitude: position.latitude,
                              longitude: position.longitude,
                            );

                            if (response != null && response.status == true) {
                              await Common.saveSharedPref(
                                  "is_work_started", "false");
                              debugPrint("Work stopped on logout at $now");
                            } else {
                              debugPrint("Failed to stop work during logout");
                            }
                          } catch (e) {
                            debugPrint(
                                "Error getting location or stopping work: $e");
                          }
                        }

                        await Common.clearSharedPref(excludeKeys: [
                          'url',
                          'callTypes',
                          'callLogsStartingTime',
                          'callLogPermission'
                        ]);
                        HiveUtil.clearAllCallLogs();
                        final permission =
                            await Common.getSharedPref("callLogPermission");
                        debugPrint(
                            "callLogPermission after logout: $permission");

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                          (Route<dynamic> route) => false,
                        );

                        if (Platform.isAndroid) {
                          _channel.setMethodCallHandler((call) async {
                            if (call.method == 'setAsBackgroundService') {
                              initService();
                              FlutterBackgroundService()
                                  .invoke('setAsBackground');
                            }
                          });
                          Workmanager().initialize(callbackDispatcher,
                              isInDebugMode: true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Logout'),
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
}
// void logout(BuildContext context) {
//   showDialog(
//       context: context,
//       builder: (BuildContext ctx) {
//         return AlertDialog(
//           title: const Text('Please Confirm'),
//           content: const Text('Are you sure to Logout?'),
//           actions: [
//             TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('No')),
//             TextButton(
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   final isWorkStarted =
//                       await Common.getSharedPref("is_work_started");
//                   if (isWorkStarted == "true") {
//                     final now = DateTime.now();
//                     // final response = await HttpService.stopWork(now);
//                     // if (response != null && response.status == true) {
//                     //   await Common.saveSharedPref("is_work_started", "false");
//                     //   debugPrint("Work stopped on logout at $now");
//                     // } else {
//                     //   debugPrint("Failed to stop work during logout");
//                     try {
//                       final position = await Geolocator.getCurrentPosition(
//                         desiredAccuracy: LocationAccuracy.high,
//                       );

//                       final response = await HttpService.stopWork(
//                         now,
//                         latitude: position.latitude,
//                         longitude: position.longitude,
//                       );

//                       if (response != null && response.status == true) {
//                         await Common.saveSharedPref("is_work_started", "false");
//                         debugPrint("Work stopped on logout at $now");
//                       } else {
//                         debugPrint("Failed to stop work during logout");
//                       }
//                     } catch (e) {
//                       debugPrint("Error getting location or stopping work: $e");
//                     }
//                     // }
//                   }

//                   // Common.clearSharedPref();
//                   await Common.clearSharedPref(excludeKeys: [
//                     'url',
//                     'callTypes',
//                     'callLogsStartingTime',
//                     'callLogPermission'
//                   ]);
//                   HiveUtil.clearAllCallLogs();
//                   final permission =
//                       await Common.getSharedPref("callLogPermission");
//                   debugPrint("callLogPermission after logout: $permission");
//                   Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (context) => const Login()),
//                       (Route<dynamic> route) => false);
//                   if (Platform.isAndroid) {
//                     _channel.setMethodCallHandler((call) async {
//                       if (call.method == 'setAsBackgroundService') {
//                         initService();
//                         FlutterBackgroundService().invoke('setAsBackground');
//                       }
//                     });
//                     Workmanager()
//                         .initialize(callbackDispatcher, isInDebugMode: true);
//                   }
//                 },
//                 child: const Text('Yes')),
//           ],
//         );
//       });
// }
