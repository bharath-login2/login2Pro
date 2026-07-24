import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/models/customers/customerDashboardModel.dart';
import 'package:login2/screens/accounts/clients/addInvoice.dart';
import 'package:login2/screens/accounts/clients/addInvoiceTemp.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/accounts/clients/editClient.dart';
import 'package:login2/screens/accounts/clients/invoiceList.dart';
import 'package:login2/screens/accounts/clients/proformaInvoiceList.dart';
import 'package:login2/screens/accounts/clients/receiptList.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewalListCustomers.dart'
    as renewal_widget;
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/customer/customerwiseLeadReport.dart';
import 'package:login2/screens/customer/customerwiseProject.dart';
import 'package:login2/screens/customer/customerwiseQuotationReport.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/addQuotationPage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart'
//     as renewal_widget;

class CustomerDashboard extends StatefulWidget {
  final String token;
  final String name;
  final String userId;
  final String? phoneCallLogPermission;
  final String? custId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  CustomerDashboard({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.phoneCallLogPermission,
    this.custId,
    this.scaffoldKey,
  });

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  CommonConfigureModel? configure;
  CustomerDashboardModel? dashboardData;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  bool isLoading = true;
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  bool _isFabExpanded = false;
  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey ?? GlobalKey<ScaffoldState>();
    _loadConfiguration();
    _permissionsCheck();
    _loadDashboardData();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String countryCode, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$countryCode$cleanPhone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot make call to $countryCode$cleanPhone'),
        ),
      );
    }
  }

  void _openWhatsApp(String countryCode, String phoneNumber) async {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }
    final countryCodeDigits = countryCode.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappNumber = '$countryCodeDigits$cleanPhone';

    final whatsappUrl = Uri.parse('whatsapp://send?phone=$whatsappNumber');
    final webUrl = Uri.parse('https://wa.me/$whatsappNumber');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        // Many modern OSs block canLaunchUrl, so try launching directly as a last resort
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open WhatsApp'),
        ),
      );
    }
  }

  void _handleAddReceipt() {
    print('Add Receipt tapped');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptList(
            widget.token!,
            custId: widget.custId,
            custName: dashboardData?.data.customerDetails.name,
            fromDash: "1",
            // fdate: DateFormat('dd-MM-yyyy').format(DateTime(
            //     DateTime.now().year, DateTime.now().month, 1)),
            // tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
            fdate: "",
            tdate: "",
          ),
        ));
  }

  void _handleAddInvoice() {
    print('Add Invoice tapped');

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddInvoice(widget.token, widget.custId!, "")),
    );
  }

  void _handleAddProformaInvoice() {
    print('Add Proforma Invoice tapped');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddInvoiceTemp(
                widget.token,
                widget.custId!,
                dashboardData!.data.customerDetails.name,
              )),
    );
  }

  void _handleAddRenewal() {
    print('Add Renewal tapped');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => renewal_widget.RenewalList(
    //       custId: widget.custId!,
    //       title: "Renewal List",
    //       searchKey: "current_month",
    //       searchMonth: "",
    //       renewed: 0,
    //     ),
    //   ),
    // );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomRenewal(
            custId: widget.custId,
            custName: dashboardData?.data.customerDetails.name,
          ),
        ));
  }

  void _handleAddQuotation() {
    print('Add Quotation tapped');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => renewal_widget.RenewalList(
    //       custId: widget.custId!,
    //       title: "Renewal List",
    //       searchKey: "current_month",
    //       searchMonth: "",
    //       renewed: 0,
    //     ),
    //   ),
    // );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddQuotationPage(custId: widget.custId),
        ));
  }

  Future<void> _permissionsCheck() async {
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
  }

  Future<void> _loadConfiguration() async {
    try {
      configure = await HttpService.configure(widget.token);
    } catch (e) {
      print("Error loading configuration: $e");
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      if (widget.custId != null && widget.custId!.isNotEmpty) {
        dashboardData = await HttpService.getCustomerDashboard(widget.custId!);
      }
    } catch (e) {
      print("Error loading dashboard data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatCurrency(String amount) {
    try {
      final value = double.tryParse(amount) ?? 0.0;
      if (value >= 10000000) {
        return '₹${(value / 10000000).toStringAsFixed(2)}Cr';
      } else if (value >= 100000) {
        return '₹${(value / 100000).toStringAsFixed(2)}L';
      } else if (value >= 1000) {
        return '₹${(value / 1000).toStringAsFixed(2)}K';
      } else {
        return '₹${value.toStringAsFixed(2)}';
      }
    } catch (e) {
      return '₹${amount}';
    }
  }

  String _getPaymentProgressPercentage() {
    if (dashboardData == null) return '0%';
    try {
      final total = dashboardData!.data.paymentDetails.totalInvoiceAmountDouble;
      final received =
          dashboardData!.data.paymentDetails.totalReceivedAmountDouble;
      if (total == 0) return '0%';
      final percentage = (received / total * 100).toInt();
      return '$percentage% Paid';
    } catch (e) {
      return '0%';
    }
  }

  double _getPaymentProgressValue() {
    if (dashboardData == null) return 0.0;
    try {
      final total = dashboardData!.data.paymentDetails.totalInvoiceAmountDouble;
      final received =
          dashboardData!.data.paymentDetails.totalReceivedAmountDouble;
      if (total == 0) return 0.0;
      return received / total;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _buildAppBar(context),
      // body: SafeArea(
      //   child: isLoading
      //       ? const Center(child: CircularProgressIndicator())
      //       : SingleChildScrollView(
      //           padding: const EdgeInsets.all(20),
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               const SizedBox(height: 10),
      //               _buildProfileCard(),
      //               const SizedBox(height: 20),
      //               _buildTopStats(context),
      //               const SizedBox(height: 20),
      //               if (dashboardData?.data.paymentDetails != null)
      //                 _buildPaymentSummary(),
      //               const SizedBox(height: 20),
      //               if (dashboardData?.data.proformaInvoices != null)
      //                 _buildProformaInvoices(),
      //               const SizedBox(height: 20),
      //               if (dashboardData?.data.renewalList != null)
      //                 _buildUpcomingRenewals(),

      //             ],
      //           ),
      //         ),

      // ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadDashboardData();
                },
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildProfileCard(),
                          const SizedBox(height: 20),
                          _buildTopStats(context),
                          const SizedBox(height: 20),
                          if (dashboardData?.data.paymentDetails != null)
                            _buildPaymentSummary(),
                          const SizedBox(height: 20),
                          if (dashboardData?.data.proformaInvoices != null)
                            _buildProformaInvoices(),
                          const SizedBox(height: 20),
                          // if (dashboardData?.data.renewalList != null)
                          //   _buildUpcomingRenewals(),
                          // const SizedBox(height: 20),
                          // if (dashboardData?.data.rentalList != null)
                            // _buildRentalSection(),
                          // const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      right: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_isFabExpanded)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // _buildFabOption(
                                //   icon: Icons.receipt,
                                //   label: 'Receipt',
                                //   onTap: () {
                                //     _handleAddReceipt();
                                //     _toggleFab();
                                //   },
                                // ),
                                const SizedBox(height: 12),
                                _buildFabOption(
                                  icon: Icons.inventory,
                                  label: 'Add Invoice',
                                  onTap: () {
                                    _handleAddInvoice();
                                    _toggleFab();
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildFabOption(
                                  icon: Icons.description,
                                  label: 'Add Proforma',
                                  onTap: () {
                                    _handleAddProformaInvoice();
                                    _toggleFab();
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildFabOption(
                                  icon: Icons.autorenew,
                                  label: 'Add Renewal',
                                  onTap: () {
                                    _handleAddRenewal();
                                    _toggleFab();
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildFabOption(
                                  icon: Icons.settings_ethernet_outlined,
                                  label: 'Add Quotation',
                                  onTap: () {
                                    _handleAddQuotation();
                                    _toggleFab();
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          FloatingActionButton(
                            backgroundColor: Colors.blue,
                            onPressed: _toggleFab,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isFabExpanded
                                  ? const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      key: ValueKey('close'),
                                    )
                                  : const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      key: ValueKey('add'),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      endDrawer: DraweScreen(widget.token!),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
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
                              AccountsDashboard(token: widget.token!)),
                    )
                  : MenuDashboard == "true"
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(widget.token)),
                        )
                      : RenewalDashboardPermission == "true"
                          ? Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RenewalDashboard()),
                            )
                          : NewleadDashboardPermission == "true"
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MinimalDashboard(widget.token)),
                                )
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardLeadNewUpdatedTwo(
                                              widget.token)),
                                );
        },
        child: Image.asset("assets/icons/menu.png", width: 25),
      ),
      bottomNavigationBar: configure != null
          ? BottomNavigation(
              widget.token,
              phoneCallLogPermission: widget.phoneCallLogPermission ?? 'false',
              name: widget.name,
              userId: widget.userId,
              scaffoldKey: _scaffoldKey,
            )
          : const SizedBox(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      titleSpacing: -2,
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  color: Colors.grey.shade800,
                  offset: const Offset(0, 2.0),
                )
              ],
              shape: BoxShape.circle,
              color: const Color(0xFF2191ce),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.blue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dashboardData?.data.customerDetails.name ?? widget.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Customer Dashboard',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final customer = dashboardData?.data.customerDetails;
    return GestureDetector(
      onTap: _showCustomerDetailsPopup,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2a86c9),
              Color(0xFF1C1A79),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2a86c9).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/profile.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white.withOpacity(0.2),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer?.name ?? 'No Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer?.gstNum.isNotEmpty == true
                        ? 'GST: ${customer!.gstNum}'
                        : 'Customer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.white.withOpacity(0.95),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${customer?.countryCode ?? ''} ${customer?.contactNo ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  void _showCustomerDetailsPopup() {
    final customer = dashboardData?.data.customerDetails;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2196F3),
                          Color(0xFF1976D2),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Customer Profile Info',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.asset(
                                  'assets/profile.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              customer?.name ?? 'No Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              customer?.gstNum.isNotEmpty == true
                                  ? 'GST: ${customer!.gstNum}'
                                  : 'Customer',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            // Created info
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Created: ${customer?.createdDate} by ${customer?.createdBy}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Contact Information'),
                        const SizedBox(height: 16),

                        _buildContactItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: customer?.emailId.isNotEmpty == true
                              ? customer!.emailId
                              : 'Not Available',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),

                        _buildContactItem(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: customer?.contactNo.isNotEmpty == true
                              ? '${customer!.countryCode} ${customer.contactNo}'
                              : 'Not Available',
                          color: Colors.green,
                          onTap: customer?.contactNo.isNotEmpty == true
                              ? () => _makePhoneCall(
                                  customer!.countryCode, customer.contactNo)
                              : null,
                          onWhatsAppTap: customer?.contactNo.isNotEmpty == true
                              ? () => _openWhatsApp(
                                  customer!.countryCode, customer.contactNo)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        customer!.whatsappNumber != ""
                            ? _buildContactItem(
                                icon: FontAwesomeIcons.whatsapp,
                                label: 'WhatsApp',
                                value: customer!.whatsappNumber!,
                                color: Colors.green,
                                onTap: () => _openWhatsApp(
                                    customer!.countryCode,
                                    customer!.whatsappNumber!),
                              )
                            : SizedBox(),

                        // Address Section
                        const SizedBox(height: 32),
                        _buildSectionTitle('Address Details'),
                        const SizedBox(height: 16),

                        // Address 1
                        if (customer?.address?.isNotEmpty == true) ...[
                          _buildAddressItem('Address 1', customer!.address),
                          const SizedBox(height: 12),
                        ],

                        // Address 2
                        if (customer?.address2?.isNotEmpty == true) ...[
                          _buildAddressItem('Address 2', customer!.address2),
                          const SizedBox(height: 12),
                        ],

                        // Address 3
                        if (customer?.address3?.isNotEmpty == true) ...[
                          _buildAddressItem('Address 3', customer!.address3),
                          const SizedBox(height: 12),
                        ],

                        // Combined Location Info
                        if ((customer?.stateName ?? '').isNotEmpty ||
                            (customer?.districtName ?? '').isNotEmpty ||
                            (customer?.postOffice ?? '').isNotEmpty ||
                            (customer?.pincode ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // State
                                if ((customer?.stateName ?? '').isNotEmpty)
                                  _buildInfoRow('State', customer!.stateName),

                                // District
                                if ((customer?.districtName ?? '').isNotEmpty)
                                  _buildInfoRow(
                                      'District', customer!.districtName),

                                // Post Office
                                if ((customer?.postOffice ?? '').isNotEmpty)
                                  _buildInfoRow(
                                      'Post Office', customer!.postOffice),

                                // Pincode
                                if ((customer?.pincode ?? '').isNotEmpty)
                                  _buildInfoRow('Pincode', customer!.pincode),
                              ],
                            ),
                          ),

                        // Tax Information
                        if ((customer?.taxType ?? '').isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _buildSectionTitle('Tax Information'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.orange.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                        'Tax Type', customer!.taxType),
                                    if (customer.gstNum.isNotEmpty)
                                      _buildInfoRow(
                                          'GST Number', customer.gstNum),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        // Additional Information
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildSectionTitle('Additional Information'),
                            const SizedBox(height: 12),

                            // Remarks
                            if ((customer?.remarks ?? '').isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.sticky_note_2_outlined,
                                            size: 18, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Remarks',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      customer!.remarks,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Company & Branch Info
                            // Container(
                            //   padding: const EdgeInsets.all(16),
                            //   decoration: BoxDecoration(
                            //     color: Colors.grey[50],
                            //     borderRadius: BorderRadius.circular(12),
                            //     border: Border.all(color: Colors.grey[200]!),
                            //   ),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       if ((customer?.companyId ?? '').isNotEmpty)
                            //         _buildInfoRow(
                            //             'Company ID', customer!.companyId),
                            //       if ((customer?.branchId ?? '').isNotEmpty)
                            //         _buildInfoRow(
                            //             'Branch ID', customer!.branchId),
                            //       if ((customer?.leadId ?? '').isNotEmpty)
                            //         _buildInfoRow('Lead ID', customer!.leadId),
                            //     ],
                            //   ),
                            // ),

                            // Status Indicators
                            if (customer != null)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    // Deleted Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: customer.isDeleted == "Y"
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: customer.isDeleted == "Y"
                                              ? Colors.red.shade200
                                              : Colors.green.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            customer.isDeleted == "Y"
                                                ? Icons.delete_outline
                                                : Icons.check_circle_outline,
                                            size: 14,
                                            color: customer.isDeleted == "Y"
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            customer.isDeleted == "Y"
                                                ? 'Deleted'
                                                : 'Active',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: customer.isDeleted == "Y"
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    // Additional Fields Indicator
                                    if ((customer?.additionalFields ?? '')
                                        .isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.blue.shade200),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.code,
                                                size: 14, color: Colors.blue),
                                            SizedBox(width: 6),
                                            Text(
                                              'Has Custom Fields',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
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

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditClients(
                                    widget.token,
                                    widget.custId!,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Edit Customer Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
    VoidCallback? onWhatsAppTap, // Add this parameter
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // WhatsApp icon on the right
            if (onWhatsAppTap != null)
              InkWell(
                onTap: onWhatsAppTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
              ),
            // Original arrow icon (only show if no WhatsApp icon)
            if (onTap != null && onWhatsAppTap == null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(String title, String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_outlined,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats(BuildContext context) {
    final leads = dashboardData?.data.leads;
    final quotations = dashboardData?.data.quotations;
    final projects = dashboardData?.data.projects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.grey[900],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         ClientDetails(widget.token, widget.custId ?? ''),
                  //   ),
                  // );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerLeadsPage(
                        custId: widget.custId ?? '',
                        customerName:
                            dashboardData?.data.customerDetails.name ?? '',
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: _statCard(
                    title: 'Leads',
                    total: leads?.totalLeads ?? '0',
                    totalLabel: 'Total Leads',
                    sub: 'Confirmed',
                    subValue: leads?.confirmedCount ?? '0',
                    icon: Icons.leaderboard_outlined,
                    color: const Color(0xFF667eea),
                  ),
                ),
              ),
              // const SizedBox(width: 12),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => CustomerQuotationPage(
              //           customerId: widget.custId ?? '',
              //           customerName:
              //               dashboardData?.data.customerDetails.name ?? '',
              //         ),
              //       ),
              //     );
              //   },
              //   child: SizedBox(
              //     width: MediaQuery.of(context).size.width * 0.50,
              //     child: _statCard(
              //       title: 'Quotations',
              //       total: quotations?.total ?? '0',
              //       totalLabel: 'Total',
              //       sub: 'Approved',
              //       subValue: quotations?.approved ?? '0',
              //       icon: Icons.description_outlined,
              //       color: const Color(0xFF43e97b),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerProjectPage(
                        customerId: widget.custId ?? '',
                        customerName:
                            dashboardData?.data.customerDetails.name ?? '',
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: _statCard(
                    title: 'Projects',
                    total: projects?.total ?? '0',
                    totalLabel: 'Total',
                    sub: 'Completed',
                    subValue: projects?.completed ?? '0',
                    icon: Icons.rocket_launch_outlined,
                    color: const Color(0xFFf093fb),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String total,
    required String totalLabel,
    required String sub,
    required String subValue,
    required IconData icon,
    required Color color,
  }) {
    final totalInt = int.tryParse(total) ?? 0;
    final subInt = int.tryParse(subValue) ?? 0;
    final percentage = totalInt > 0 ? (subInt / totalInt * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: percentage > 50
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        total,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subValue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final payment = dashboardData?.data.paymentDetails;
    final totalInvoice = payment?.totalInvoiceAmountDouble ?? 0.0;
    final totalReceived = payment?.totalReceivedAmountDouble ?? 0.0;
    final balance = payment?.balanceAmountDouble ?? 0.0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptList(
                widget.token!,
                custId: widget.custId,
                custName: dashboardData?.data.customerDetails.name,
                fromDash: "1",
                // fdate: DateFormat('dd-MM-yyyy').format(DateTime(
                //     DateTime.now().year, DateTime.now().month, 1)),
                // tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                fdate: "",
                tdate: "",
              ),
            ));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getPaymentProgressValue() >= 0.8
                            ? Colors.green.shade400
                            : Colors.orange.shade400,
                        _getPaymentProgressValue() >= 0.8
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPaymentProgressPercentage(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Total Invoice Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceList(
                        widget.token!,
                        widget.custId!,
                        "1",
                        dashboardData?.data.customerDetails.name ?? ''),
                  ),
                );
              },
              child: Text(
                '₹ ${NumberFormat('#,##,###').format(totalInvoice)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InvoiceList(widget.token!, widget.custId!, "1", ""),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _getPaymentProgressValue(),
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPaymentProgressValue() >= 0.8
                        ? Colors.green.shade500
                        : Colors.orange.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => InvoiceList(
                        //       widget.token!,
                        //     ),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptList(
                              widget.token!,
                              custId: widget.custId,
                              custName:
                                  dashboardData?.data.customerDetails.name,
                              fromDash: "1",
                              // fdate: DateFormat('dd-MM-yyyy').format(DateTime(
                              //     DateTime.now().year, DateTime.now().month, 1)),
                              // tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              fdate: "",
                              tdate: "",
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Received',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => InvoiceList(
                        //       widget.token!,
                        //     ),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptList(
                              widget.token!,
                              custId: widget.custId,
                              custName:
                                  dashboardData?.data.customerDetails.name,
                              fromDash: "1",
                              // fdate: DateFormat('dd-MM-yyyy').format(DateTime(
                              //     DateTime.now().year, DateTime.now().month, 1)),
                              // tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              fdate: "",
                              tdate: "",
                            ),
                          ),
                        );
                      },
                      child: Text(
                        NumberFormat('#,##,###').format(totalReceived),
                        // _formatCurrency(totalReceived.toString()),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => InvoiceList(
                        //       widget.token!,
                        //     ),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptList(
                              widget.token!,
                              custId: widget.custId,
                              custName:
                                  dashboardData?.data.customerDetails.name,
                              fromDash: "1",
                              // fdate: DateFormat('dd-MM-yyyy').format(DateTime(
                              //     DateTime.now().year, DateTime.now().month, 1)),
                              // tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              fdate: "",
                              tdate: "",
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => InvoiceList(
                        //       widget.token!,
                        //     ),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptList(
                              widget.token!,
                              custId: widget.custId,
                              custName:
                                  dashboardData?.data.customerDetails.name,
                              fromDash: "1",
                              // fdate: DateFormat('dd-MM-yyyy').format(DateTime(
                              //     DateTime.now().year, DateTime.now().month, 1)),
                              // tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              fdate: "",
                              tdate: "",
                            ),
                          ),
                        );
                      },
                      child: Text(
                        NumberFormat('#,##,###').format(balance),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (payment?.paymentHistory.isNotEmpty == true)
              _buildRecentPayments(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptList(
                      widget.token!,
                      custId: widget.custId,
                      custName: dashboardData?.data.customerDetails.name,
                      fromDash: "1",
                      // fdate: DateFormat('dd-MM-yyyy').format(DateTime(
                      //     DateTime.now().year, DateTime.now().month, 1)),
                      // tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      fdate: "",
                      tdate: "",
                    ),
                  ),
                );
              },
              child: Container(
                height: 40, // Fixed height for consistency
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade400,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All Payments',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments() {
    final paymentHistory =
        dashboardData?.data.paymentDetails.paymentHistory ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...paymentHistory
            .take(3)
            .map(
              (payment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payment,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receipt #${payment.receiptNumber}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Date: ${payment.receiptDate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${NumberFormat('#,##,###').format(double.tryParse(payment.recieptAmount) ?? 0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildProformaInvoices() {
    final proforma = dashboardData?.data.proformaInvoices;

    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => ProformaInvoiceList(widget.token,widget.custId!)),
      //   );
      // },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Proforma Invoices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Latest',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2a86c9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _invoiceStatCard(
                      title: 'Total Proforma',
                      value: proforma?.totalProforma ?? '0',
                      subtitle: 'Invoices',
                      color: const Color(0xFF667eea),
                      icon: Icons.receipt_long_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProformaInvoiceList(
                                widget.token!,
                                widget.custId!,
                                dashboardData!.data.customerDetails.name,
                                'all',
                                "1"),
                          ),
                        );
                      },
                    ),
                    _invoiceStatCard(
                      title: 'Total Amount',
                      value: _formatCurrency(proforma?.totalAmount ?? '0'),
                      subtitle: 'Gross Value',
                      color: const Color(0xFF43e97b),
                      icon: Icons.currency_rupee_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProformaInvoiceList(
                                widget.token!,
                                widget.custId!,
                                dashboardData!.data.customerDetails.name,
                                'all',
                                "1"),
                          ),
                        );
                      },
                    ),
                    _invoiceStatCard(
                      title: 'Pending Proforma',
                      value: proforma?.pendingProforma ?? '0',
                      subtitle: 'Awaiting',
                      color: const Color(0xFFf093fb),
                      icon: Icons.pending_actions_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProformaInvoiceList(
                                widget.token!,
                                widget.custId!,
                                dashboardData!.data.customerDetails.name,
                                'pending',
                                "1"),
                          ),
                        );
                      },
                    ),
                    _invoiceStatCard(
                      title: 'Pending Amount',
                      value: _formatCurrency(proforma?.pendingAmount ?? '0'),
                      subtitle: 'Balance Due',
                      color: const Color(0xFFfa709a),
                      icon: Icons.money_off_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProformaInvoiceList(
                                widget.token!,
                                widget.custId!,
                                dashboardData!.data.customerDetails.name,
                                'pending',
                                "1"),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: color,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // const SizedBox(height: 4),
                // Text(
                //   subtitle,
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey[600],
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRenewals() {
    final renewal = dashboardData?.data.renewalList;
    final upcomingList = renewal?.upcomingList ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => renewal_widget.RenewalListCustomer(
              custId: widget.custId!,
              custName: dashboardData!.data.customerDetails.name,
              title: "Renewal List",
              searchKey: "",
              searchMonth: "",
              renewed: 0,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade50.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Upcoming Renewals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade50.withOpacity(0.9),
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                border: Border.all(
                  color: Colors.blue.shade100.withOpacity(0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Upcoming
                        _buildPremiumStat(
                          label: 'Upcoming',
                          value: renewal?.totalUpcoming?.toString() ?? '0',
                          color: Colors.blue.shade700,
                          icon: Icons.trending_up_rounded,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100.withOpacity(0.9),
                              Colors.blue.shade50,
                            ],
                          ),
                        ),

                        // Elegant Divider
                        Container(
                          width: 1,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.grey.shade300,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Expired
                        _buildPremiumStat(
                          label: 'Expired',
                          value: renewal?.totalExpired?.toString() ?? '0',
                          color: const Color.fromARGB(255, 238, 106, 106),
                          icon: Icons.warning_amber_rounded,
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade100.withOpacity(0.9),
                              Colors.red.shade50,
                            ],
                          ),
                        ),

                        // Elegant Divider
                        Container(
                          width: 1,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.grey.shade300,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Renewed
                        _buildPremiumStat(
                          label: 'Renewed',
                          value: renewal?.totalRenewed?.toString() ?? '0',
                          color: Colors.green.shade700,
                          icon: Icons.check_circle_rounded,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade100.withOpacity(0.9),
                              Colors.green.shade50,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (upcomingList.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade100,
                              Colors.green.shade50,
                            ],
                          ),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All Caught Up!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No pending renewals at the moment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: upcomingList
                    .map(
                      (renewal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _renewalRow(
                          name: renewal.productNames,
                          days: renewal.daysLeftInt >= 0
                              ? '${renewal.daysLeftInt} Days Left'
                              : 'Overdue ${renewal.daysLeftInt.abs()} Days',
                          date: renewal.endDate,
                          amount: _formatCurrency(renewal.amount),
                          status:
                              renewal.daysLeftInt >= 0 ? 'upcoming' : 'pending',
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => renewal_widget.RenewalListCustomer(
                      custId: widget.custId!,
                      custName: dashboardData!.data.customerDetails.name,
                      title: "Renewal List",
                      searchKey: "",
                      searchMonth: "",
                      renewed: 0,
                    ),
                  ),
                );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade400,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All Renewals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalSection() {
    final rental = dashboardData?.data.rentalList;
    final pendingList = rental?.pendingList ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade50.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rental Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade50.withOpacity(0.9),
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              border: Border.all(
                color: Colors.purple.shade100.withOpacity(0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade100.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 0,
                  offset: const Offset(0, 0),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRentalStat(
                        label: 'Issued',
                        value: rental?.issued.toString() ?? '0',
                        color: Colors.orange.shade700,
                        icon: Icons.outbox_rounded,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100.withOpacity(0.9),
                            Colors.orange.shade50,
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey.shade300,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Returned
                      _buildRentalStat(
                        label: 'Returned',
                        value: rental?.returned.toString() ?? '0',
                        color: Colors.green.shade700,
                        icon: Icons.check_circle_rounded,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade100.withOpacity(0.9),
                            Colors.green.shade50,
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey.shade300,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Pending
                      _buildRentalStat(
                        label: 'Pending',
                        value: rental?.pending.toString() ?? '0',
                        color: Colors.red.shade700,
                        icon: Icons.pending_actions_rounded,
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade100.withOpacity(0.9),
                            Colors.red.shade50,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (pendingList.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade50,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade100,
                            Colors.green.shade50,
                          ],
                        ),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All Items Returned!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No pending rental items',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: pendingList
                  .map(
                    (rental) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _rentalRow(
                        name: rental.name,
                        days: '${rental.totalDays} days',
                        date: rental.toDate,
                        amount: _formatCurrency(rental.grandTotal.toString()),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => renewal_widget.RenewalListCustomer(
                    custId: widget.custId!,
                    custName: dashboardData!.data.customerDetails.name,
                    title: "Renewal List",
                    searchKey: "",
                    searchMonth: "",
                    renewed: 0,
                  ),
                ),
              );
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade400,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Rentals',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rentalRow({
    required String name,
    required String days,
    required String date,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_rounded,
              color: Colors.purple.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: $date • $days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Helper widget for rental stat item
  Widget _buildRentalStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              height: 0.9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.9),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              height: 0.9,
              fontFamily: 'Inter', // Use a premium font if available
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.9),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renewalRow({
    required String name,
    required String days,
    required String date,
    required String amount,
    required String status,
  }) {
    Color statusColor = status == 'pending' ? Colors.orange : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                status == 'pending'
                    ? Icons.warning_amber
                    : Icons.calendar_today,
                color: statusColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    days,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C1A79),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
