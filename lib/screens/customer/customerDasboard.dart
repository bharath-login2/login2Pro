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
import 'package:login2/models/customers/customerFollowupDetailsModel.dart';
import 'package:login2/models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/leadProductsModel.dart';
import 'package:login2/models/lead_management/callResultResonModel.dart' as cr;
import 'package:login2/models/lead_management/leadExtraSettings.dart';
import 'package:login2/screens/leadManagement/add_followup.dart';
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
  final bool openFollowupTab;
  CustomerDashboard({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.phoneCallLogPermission,
    this.custId,
    this.scaffoldKey,
    this.openFollowupTab = false,
  });

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard>
    with SingleTickerProviderStateMixin {
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
  late TabController _tabController;
  bool _isFollowupLoaded = false;
  bool _isFollowupLoading = false;
  String? _followupError;
  CustomerFollowupDetailsModel? _followupDetails;
  AddLeadCommonDataModel? _addLeadCommonData;
  LeadProductSectionModel? _leadProductSection;
  bool _isLoadingCommonData = false;
  bool _isDeletingFollowup = false;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey ?? GlobalKey<ScaffoldState>();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.openFollowupTab ? 1 : 0,
    );
    _tabController.addListener(_handleTabChange);
    _loadConfiguration();
    _permissionsCheck();
    _loadDashboardData();
    _fetchPopupCommonData();
    if (widget.openFollowupTab) {
      _fetchFollowupDetails();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      if (!_isFollowupLoaded && !_isFollowupLoading) {
        _fetchFollowupDetails();
      }
      _fetchPopupCommonData();
    }
  }

  Future<void> _fetchPopupCommonData() async {
    if (_isLoadingCommonData) return;
    if (_addLeadCommonData != null && _leadProductSection != null) return;
    _isLoadingCommonData = true;
    try {
      if (_addLeadCommonData == null) {
        final commonRes = await HttpService.addLeadCommonData(widget.token);
        if (commonRes != null && mounted) {
          setState(() {
            _addLeadCommonData = commonRes;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching lead common data: $e");
    }
    try {
      if (_leadProductSection == null) {
        final productRes = await HttpService.leadProductSection();
        if (productRes != null && mounted) {
          setState(() {
            _leadProductSection = productRes;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching product section: $e");
    } finally {
      _isLoadingCommonData = false;
    }
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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if ((widget.openFollowupTab || _tabController.index == 1) &&
          !_isFollowupLoaded &&
          !_isFollowupLoading) {
        _fetchFollowupDetails();
      }
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
            : Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildProfileCard(),
                      ),
                      const SizedBox(height: 10),
                      _buildTabBar(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCustomerDetailsTab(),
                            _buildFollowupTab(),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          if (index == 1 && !_isFollowupLoaded && !_isFollowupLoading) {
            _fetchFollowupDetails();
          }
        },
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2a86c9),
              Color(0xFF1C1A79),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2a86c9).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_outlined, size: 18),
                SizedBox(width: 8),
                Text(" Details"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_outlined, size: 18),
                SizedBox(width: 8),
                Text("Follow-up"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadDashboardData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildTopStats(context),
            const SizedBox(height: 20),
            if (dashboardData?.data.paymentDetails != null)
              _buildPaymentSummary(),
            const SizedBox(height: 20),
            if (dashboardData?.data.proformaInvoices != null)
              _buildProformaInvoices(),
            const SizedBox(height: 20),
            if (dashboardData?.data.renewalList != null)
              _buildUpcomingRenewals(),
            const SizedBox(height: 20),
            if (dashboardData?.data.rentalList != null)
              _buildRentalSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchFollowupDetails({bool forceRefresh = false}) async {
    if (_isFollowupLoading) return;
    if (_isFollowupLoaded && !forceRefresh) return;

    final customerId = (widget.custId != null && widget.custId!.trim().isNotEmpty)
        ? widget.custId!.trim()
        : (dashboardData?.data.customerDetails.id ?? '');
    if (customerId.isEmpty) {
      if (mounted) {
        setState(() {
          _followupError = "Customer ID is not available";
          _isFollowupLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isFollowupLoading = true;
        _followupError = null;
      });
    }

    try {
      final leadId = dashboardData?.data.customerDetails.leadId;
      final result = await HttpService.customerFollowupDetails(
        customerId,
        token: widget.token,
        callMasterId: leadId,
      );

      if (mounted) {
        if (result != null && result.status == true) {
          setState(() {
            _followupDetails = result;
            _isFollowupLoaded = true;
            _isFollowupLoading = false;
            _followupError = null;
          });
        } else {
          setState(() {
            _followupDetails = result;
            _isFollowupLoaded = true;
            _isFollowupLoading = false;
            _followupError = (result?.message.isNotEmpty == true)
                ? result!.message
                : "Failed to load follow-up details";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFollowupLoading = false;
          _followupError = "Error loading follow-up: $e";
        });
      }
    }
  }

  void _openAddFollowup() {
    _showAddFollowupPopup(context);
  }

  void _showAddFollowupPopup(BuildContext context,
      {CustomerFollowupItem? editItem}) {
    if (_addLeadCommonData == null || _leadProductSection == null) {
      _fetchPopupCommonData();
    }

    final bool isEdit = editItem != null;
    final String followupId = editItem?.id ?? '';

    final customerId = (widget.custId != null && widget.custId!.isNotEmpty)
        ? widget.custId!
        : ((editItem?.customerId.isNotEmpty == true)
            ? editItem!.customerId
            : (dashboardData?.data.customerDetails.id ?? ''));

    final callMasterId = (editItem?.callMasterId.isNotEmpty == true)
        ? editItem!.callMasterId
        : ((_followupDetails?.data?.callMasterId.isNotEmpty == true)
            ? _followupDetails!.data!.callMasterId
            : ((_followupDetails?.data?.callData?.callMasterId.isNotEmpty ==
                    true)
                ? _followupDetails!.data!.callData!.callMasterId
                : (dashboardData?.data.customerDetails.leadId ?? '')));

    final callData = _followupDetails?.data?.callData;
    final leadCategoryId = callData?.leadCategoryId ?? '';
    final leadSubCategoryId = callData?.leadSubCategoryId ?? '';

    String initialCalledDate =
        DateFormat('dd-MM-yyyy h:mm a').format(DateTime.now());
    if (isEdit) {
      if (_isValidDate(editItem.calledDateFormatted)) {
        initialCalledDate = editItem.calledDateFormatted!.trim();
      } else if (_isValidDate(editItem.calledDate)) {
        initialCalledDate = _formatDateSafely(editItem.calledDate);
      } else if (_isValidDate(editItem.createdAt)) {
        initialCalledDate = _formatDateSafely(editItem.createdAt);
      }
    }
    final calledDateCtrl = TextEditingController(text: initialCalledDate);

    final costCtrl = TextEditingController(
      text: (callData?.cost.isNotEmpty == true) ? callData!.cost : '0',
    );
    final remarksCtrl = TextEditingController(
      text: isEdit ? (editItem.remarks ?? '') : '',
    );

    String initialNextFollowup = '';
    if (isEdit) {
      if (_isValidDate(editItem.followupDateFormatted)) {
        initialNextFollowup = editItem.followupDateFormatted!.trim();
      } else if (_isValidDate(editItem.followupDate)) {
        initialNextFollowup = _formatDateSafely(editItem.followupDate);
      } else if (_isValidDate(editItem.scheduledDate)) {
        initialNextFollowup = _formatDateSafely(editItem.scheduledDate);
      }
    }
    final nextFollowupDateCtrl = TextEditingController(text: initialNextFollowup);
    final timeBeforeCtrl = TextEditingController(text: '10');

    String? selectedCallResponseId = isEdit
        ? (editItem.callResponseId.isNotEmpty
            ? editItem.callResponseId
            : (editItem.callStatusId.isNotEmpty ? editItem.callStatusId : null))
        : null;

    String? selectedCallResultId = isEdit
        ? (editItem.callResultId.isNotEmpty ? editItem.callResultId : null)
        : null;

    String? selectedProductId;
    String? selectedPriorityId =
        (callData?.priorityId.isNotEmpty == true) ? callData!.priorityId : null;

    String? selectedReasonId = isEdit
        ? (editItem.reasonId.isNotEmpty &&
                editItem.reasonId != '0' &&
                editItem.reasonId != 'null'
            ? editItem.reasonId
            : null)
        : null;

    bool isRemindMeChecked = isEdit ? initialNextFollowup.isNotEmpty : false;
    bool isSubmitting = false;
    cr.CallResultResonModel? callResultReason;
    LeadSettings? leadSettings;
    bool isLoadingReasons = false;
    bool hasInitializedStageSettings = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Populate Call Status items
            final statusItems = <Map<String, String>>[];
            if (_addLeadCommonData?.data.callResponseStatus != null &&
                _addLeadCommonData!.data.callResponseStatus.isNotEmpty) {
              for (var s in _addLeadCommonData!.data.callResponseStatus) {
                if (s.callResponseId.isNotEmpty &&
                    !statusItems.any((e) => e['id'] == s.callResponseId)) {
                  statusItems.add({
                    'id': s.callResponseId,
                    'name': s.callResponse,
                  });
                }
              }
            } else {
              statusItems.addAll([
                {'id': '1', 'name': 'Connected'},
                {'id': '2', 'name': 'Busy'},
                {'id': '3', 'name': 'Switch Off'},
                {'id': '4', 'name': 'Not Reachable'},
                {'id': '5', 'name': 'Ringing No Response'},
                {'id': '6', 'name': 'Wrong Number'},
              ]);
            }

            // Populate Lead Stage items
            final stageItems = <Map<String, String>>[];
            if (_addLeadCommonData?.data.callResult != null &&
                _addLeadCommonData!.data.callResult.isNotEmpty) {
              for (var r in _addLeadCommonData!.data.callResult) {
                if (r.callResultId.isNotEmpty &&
                    !stageItems.any((e) => e['id'] == r.callResultId)) {
                  stageItems.add({
                    'id': r.callResultId,
                    'name': r.callResult,
                  });
                }
              }
            } else if (_addLeadCommonData?.data.callResultNew != null &&
                _addLeadCommonData!.data.callResultNew.isNotEmpty) {
              for (var r in _addLeadCommonData!.data.callResultNew) {
                if (r.callResultIdNew.isNotEmpty &&
                    !stageItems.any((e) => e['id'] == r.callResultIdNew)) {
                  stageItems.add({
                    'id': r.callResultIdNew,
                    'name': r.callResultNew,
                  });
                }
              }
            } else {
              stageItems.addAll([
                {'id': '2', 'name': 'Followup'},
                {'id': '1', 'name': 'New'},
                {'id': '3', 'name': 'Confirmed'},
                {'id': '4', 'name': 'Lost'},
                {'id': '5', 'name': 'Rejected'},
              ]);
            }

            // Populate Product items
            final productItems = <Map<String, String>>[];
            if (_leadProductSection?.data != null &&
                _leadProductSection!.data!.isNotEmpty) {
              for (var p in _leadProductSection!.data!) {
                final pid = p.id ?? '';
                final pname = p.productName ?? '';
                if (pid.isNotEmpty && !productItems.any((e) => e['id'] == pid)) {
                  productItems.add({
                    'id': pid,
                    'name': pname,
                  });
                }
              }
            }

            // Populate Priority items
            final priorityItems = <Map<String, String>>[];
            if (_addLeadCommonData?.data.priority != null &&
                _addLeadCommonData!.data.priority.isNotEmpty) {
              for (var p in _addLeadCommonData!.data.priority) {
                if (p.priorityId.isNotEmpty &&
                    !priorityItems.any((e) => e['id'] == p.priorityId)) {
                  priorityItems.add({
                    'id': p.priorityId,
                    'name': p.priority,
                  });
                }
              }
            } else {
              priorityItems.addAll([
                {'id': '1', 'name': 'Low'},
                {'id': '2', 'name': 'Normal'},
                {'id': '3', 'name': 'High'},
                {'id': '4', 'name': 'Urgent'},
              ]);
            }

            // Populate Tags items
            final reasonItems = <Map<String, String>>[];
            if (callResultReason?.data != null &&
                callResultReason!.data!.isNotEmpty) {
              for (var r in callResultReason!.data!) {
                final rid = r.id?.toString() ?? '';
                final rname = r.reason ?? '';
                if (rid.isNotEmpty && !reasonItems.any((e) => e['id'] == rid)) {
                  reasonItems.add({
                    'id': rid,
                    'name': rname,
                  });
                }
              }
            }

            // Auto-match dropdown IDs by text if needed in edit mode
            if (isEdit && selectedCallResponseId == null) {
              final targetName = (editItem.callResponse ?? editItem.callStatus ?? '')
                  .trim()
                  .toLowerCase();
              if (targetName.isNotEmpty) {
                final match = statusItems.firstWhere(
                  (e) => (e['name'] ?? '').trim().toLowerCase() == targetName,
                  orElse: () => {},
                );
                if (match['id'] != null) {
                  selectedCallResponseId = match['id'];
                }
              }
            }
            if (isEdit && selectedCallResultId == null) {
              final targetName =
                  (editItem.callResult ?? '').trim().toLowerCase();
              if (targetName.isNotEmpty) {
                final match = stageItems.firstWhere(
                  (e) => (e['name'] ?? '').trim().toLowerCase() == targetName,
                  orElse: () => {},
                );
                if (match['id'] != null) {
                  selectedCallResultId = match['id'];
                }
              }
            }
            if (isEdit && (selectedReasonId == null || selectedReasonId!.isEmpty)) {
              final targetReason = (editItem.reason ?? '').trim().toLowerCase();
              if (targetReason.isNotEmpty && reasonItems.isNotEmpty) {
                final match = reasonItems.firstWhere(
                  (e) => (e['name'] ?? '').trim().toLowerCase() == targetReason,
                  orElse: () => {},
                );
                if (match['id'] != null) {
                  selectedReasonId = match['id'];
                }
              }
            }

            // Determine if Follow Up or Rejected is active
            final currentStatusName = (statusItems.firstWhere(
              (e) => e['id'] == selectedCallResponseId,
              orElse: () => {},
            )['name'] ?? '').toLowerCase();

            final currentStageName = (stageItems.firstWhere(
              (e) => e['id'] == selectedCallResultId,
              orElse: () => {},
            )['name'] ?? '').toLowerCase();

            final bool isFollowUp = selectedCallResultId == '2' ||
                currentStageName.contains('follow') ||
                currentStatusName.contains('follow') ||
                (leadSettings?.isFollowupRequiredBool == true);

            final bool isRejected = selectedCallResultId == '5' ||
                currentStageName.contains('reject') ||
                currentStatusName.contains('reject') ||
                (leadSettings?.isReasonRequiredBool == true);

            // Fetch reasons & extra settings when stage/status changes
            void fetchReasonsAndSettings(String stageId) {
              isLoadingReasons = true;
              HttpService.callResultReasonLiat(widget.token, stageId).then((res) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    isLoadingReasons = false;
                    callResultReason = res;
                    if (isEdit &&
                        selectedReasonId != null &&
                        callResultReason?.data != null) {
                      final hasReason = callResultReason!.data!
                          .any((e) => e.id?.toString() == selectedReasonId);
                      if (!hasReason && editItem.reason != null) {
                        final match = callResultReason!.data!.firstWhere(
                          (e) =>
                              (e.reason ?? '').trim().toLowerCase() ==
                              editItem.reason!.trim().toLowerCase(),
                          orElse: () => cr.Data(id: '', reason: ''),
                        );
                        if (match.id != null && match.id!.isNotEmpty) {
                          selectedReasonId = match.id;
                        }
                      }
                    }
                  });
                }
              }).catchError((_) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    isLoadingReasons = false;
                  });
                }
              });

              HttpService.leadExtraSettings(stageId).then((res) {
                if (res != null && res.status == true && dialogContext.mounted) {
                  setDialogState(() {
                    leadSettings = res.data.settings;
                    if (!leadSettings!.isFollowupRequiredBool && !isEdit) {
                      nextFollowupDateCtrl.clear();
                      isRemindMeChecked = false;
                    }
                  });
                }
              }).catchError((_) {});
            }

            // Auto-fetch reasons and settings on first build in edit mode
            if (!hasInitializedStageSettings) {
              hasInitializedStageSettings = true;
              final stageToFetch =
                  selectedCallResultId ?? selectedCallResponseId;
              if (stageToFetch != null && stageToFetch.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  fetchReasonsAndSettings(stageToFetch);
                });
              }
            }

            // Pick date & time for Called Date
            Future<void> pickCalledDateTime() async {
              DateTime initialDate = DateTime.now();
              try {
                if (calledDateCtrl.text.isNotEmpty) {
                  initialDate = DateFormat('dd-MM-yyyy hh:mm a')
                      .parse(calledDateCtrl.text);
                }
              } catch (_) {}

              final pickedDate = await showDatePicker(
                context: dialogContext,
                initialDate: initialDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF00A389),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF1E293B),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate == null || !dialogContext.mounted) return;

              final pickedTime = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay.fromDateTime(initialDate),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF00A389),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF1E293B),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedTime == null) return;

              final combined = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              final formatted =
                  DateFormat('dd-MM-yyyy h:mm a').format(combined);
              setDialogState(() {
                calledDateCtrl.text = formatted;
              });
            }

            // Pick date & time for Next Followup Date
            Future<void> pickNextFollowupDateTime() async {
              DateTime now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: dialogContext,
                initialDate: now,
                firstDate: now,
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF00A389),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF1E293B),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate == null || !dialogContext.mounted) return;

              final pickedTime = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF00A389),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF1E293B),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedTime == null) return;

              final dt = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              if (!dt.isAfter(now)) {
                if (dialogContext.mounted) {
                  Common.toastMessaage(
                    'You cannot choose a past time for the follow-up date',
                    Colors.red,
                  );
                }
                return;
              }

              setDialogState(() {
                nextFollowupDateCtrl.text =
                    DateFormat('dd-MM-yyyy hh:mm a').format(dt);
                if (isRemindMeChecked && timeBeforeCtrl.text.isNotEmpty) {
                  int minutes = int.tryParse(timeBeforeCtrl.text) ?? 10;
                  DateTime reminderTime =
                      dt.subtract(Duration(minutes: minutes));
                  if (reminderTime.isBefore(DateTime.now())) {
                    int maxMinutes =
                        dt.difference(DateTime.now()).inMinutes;
                    if (maxMinutes <= 0) {
                      timeBeforeCtrl.text = "0";
                    } else {
                      timeBeforeCtrl.text = maxMinutes.toString();
                    }
                    if (dialogContext.mounted) {
                      Common.toastMessaage(
                        'Reminder time adjusted to ${timeBeforeCtrl.text} mins before',
                        Colors.orange,
                      );
                    }
                  }
                }
              });
            }

            // Form Submit handler
            Future<void> submitFollowup() async {
              // Prevent duplicate submissions
              if (isSubmitting) return;

              if (calledDateCtrl.text.trim().isEmpty) {
                Common.toastMessaage('Please enter Called Date', Colors.red);
                return;
              }
              if (selectedCallResponseId == null ||
                  selectedCallResponseId!.isEmpty) {
                Common.toastMessaage('Please select Call Status', Colors.red);
                return;
              }
              if (selectedCallResultId == null ||
                  selectedCallResultId!.isEmpty) {
                Common.toastMessaage('Please select Lead Stage', Colors.red);
                return;
              }

              // Required validation for Follow Up
              if (isFollowUp && nextFollowupDateCtrl.text.trim().isEmpty) {
                Common.toastMessaage('Select Next Followup Date', Colors.red);
                return;
              }

              // Required validation for Rejected
              if (isRejected &&
                  (selectedReasonId == null ||
                      selectedReasonId!.isEmpty ||
                      selectedReasonId == '0' ||
                      selectedReasonId == 'null')) {
                Common.toastMessaage('Select Tags', Colors.red);
                return;
              }

              setDialogState(() {
                isSubmitting = true;
              });

              try {
                final Map<String, dynamic>? response;
                if (isEdit) {
                  response = await HttpService.editCustomerFollowup(
                    token: widget.token,
                    customerId: customerId,
                    callMasterId: callMasterId,
                    followupId: followupId,
                    calledDate: calledDateCtrl.text.trim(),
                    callResponseId: selectedCallResponseId!,
                    callResultId: selectedCallResultId!,
                    productId: selectedProductId,
                    cost: costCtrl.text.trim().isNotEmpty
                        ? costCtrl.text.trim()
                        : '0',
                    priorityId: selectedPriorityId,
                    remarks: remarksCtrl.text.trim(),
                    leadCategoryId: leadCategoryId,
                    leadSubCategoryId: leadSubCategoryId,
                    nextFollowupDate: isFollowUp
                        ? nextFollowupDateCtrl.text.trim()
                        : '',
                    reminder: isFollowUp ? isRemindMeChecked : false,
                    timeBefore: (isFollowUp && isRemindMeChecked)
                        ? timeBeforeCtrl.text.trim()
                        : '',
                    reasonId: isRejected ? (selectedReasonId ?? '') : '',
                  );
                } else {
                  response = await HttpService.insertCustomerFollowup(
                    token: widget.token,
                    customerId: customerId,
                    callMasterId: callMasterId,
                    calledDate: calledDateCtrl.text.trim(),
                    callResponseId: selectedCallResponseId!,
                    callResultId: selectedCallResultId!,
                    productId: selectedProductId,
                    cost: costCtrl.text.trim().isNotEmpty
                        ? costCtrl.text.trim()
                        : '0',
                    priorityId: selectedPriorityId,
                    remarks: remarksCtrl.text.trim(),
                    leadCategoryId: leadCategoryId,
                    leadSubCategoryId: leadSubCategoryId,
                    nextFollowupDate: isFollowUp
                        ? nextFollowupDateCtrl.text.trim()
                        : '',
                    reminder: isFollowUp ? isRemindMeChecked : false,
                    timeBefore: (isFollowUp && isRemindMeChecked)
                        ? timeBeforeCtrl.text.trim()
                        : '',
                    reasonId: isRejected ? (selectedReasonId ?? '') : '',
                  );
                }

                final isSuccess = response != null &&
                    (response['status'] == true ||
                        response['status'] == 1 ||
                        response['status'] == '1' ||
                        response['status'] == 'true' ||
                        response['data'] == true ||
                        response['success'] == true);

                if (isSuccess) {
                  Common.toastMessaage(
                    (response['message']?.toString().isNotEmpty == true)
                        ? response['message'].toString()
                        : (isEdit
                            ? 'Follow-up updated successfully'
                            : 'Follow-up added successfully'),
                    Colors.green,
                  );
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  _fetchFollowupDetails(forceRefresh: true);
                  if (_tabController.index != 1) {
                    _tabController.animateTo(1);
                  }
                } else {
                  setDialogState(() {
                    isSubmitting = false;
                  });
                  Common.toastMessaage(
                    (response?['message']?.toString().isNotEmpty == true)
                        ? response!['message'].toString()
                        : (isEdit
                            ? 'Failed to update follow-up'
                            : 'Failed to add follow-up'),
                    Colors.red,
                  );
                }
              } catch (e) {
                setDialogState(() {
                  isSubmitting = false;
                });
                Common.toastMessaage('Error: $e', Colors.red);
              }
            }

            // Individual field widgets
            final calledDateField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Called Date ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                InkWell(
                  onTap: pickCalledDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      calledDateCtrl.text.isNotEmpty
                          ? calledDateCtrl.text
                          : 'Select Date & Time',
                      style: TextStyle(
                        fontSize: 14,
                        color: calledDateCtrl.text.isNotEmpty
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ],
            );

            final callStatusField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Call Status ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (selectedCallResponseId != null &&
                              statusItems.any(
                                  (e) => e['id'] == selectedCallResponseId))
                          ? selectedCallResponseId
                          : null,
                      hint: const Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                      items: statusItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedCallResponseId = val;
                          final statusName = (statusItems.firstWhere(
                            (e) => e['id'] == val,
                            orElse: () => {},
                          )['name'] ?? '').toLowerCase();
                          if (statusName.contains('reject') && val != null) {
                            fetchReasonsAndSettings(val);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            );

            final leadStageField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Lead Stage',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                        children: [
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Lead stage status',
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00A389),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.question_mark_rounded,
                          size: 10,
                          color: Color(0xFF00A389),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (selectedCallResultId != null &&
                              stageItems
                                  .any((e) => e['id'] == selectedCallResultId))
                          ? selectedCallResultId
                          : null,
                      hint: const Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                      items: stageItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedCallResultId = val;
                          if (val != null) {
                            fetchReasonsAndSettings(val);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            );

            // Tags Field (shown when Call Status is Rejected)
            final tagsField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Tags ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (selectedReasonId != null &&
                              reasonItems.any((e) => e['id'] == selectedReasonId))
                          ? selectedReasonId
                          : null,
                      hint: Text(
                        isLoadingReasons ? 'Loading tags...' : 'Select Tags',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                      items: reasonItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedReasonId = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );

            // Next Followup Date Field (shown when Call Status is Follow Up)
            final nextFollowupDateField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Next Followup Date ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                InkWell(
                  onTap: pickNextFollowupDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          nextFollowupDateCtrl.text.isNotEmpty
                              ? nextFollowupDateCtrl.text
                              : 'Select Date & Time',
                          style: TextStyle(
                            fontSize: 14,
                            color: nextFollowupDateCtrl.text.isNotEmpty
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );

            // Remind Me Checkbox
            final remindMeCheckbox = CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Remind Me',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              value: isRemindMeChecked,
              activeColor: const Color(0xFF00A389),
              onChanged: (value) {
                setDialogState(() {
                  isRemindMeChecked = value ?? false;
                  if (isRemindMeChecked &&
                      nextFollowupDateCtrl.text.isNotEmpty) {
                    try {
                      DateTime dt = DateFormat('dd-MM-yyyy hh:mm a')
                          .parse(nextFollowupDateCtrl.text);
                      int minutes = int.tryParse(timeBeforeCtrl.text) ?? 10;
                      DateTime reminderTime =
                          dt.subtract(Duration(minutes: minutes));
                      if (reminderTime.isBefore(DateTime.now())) {
                        int maxMinutes =
                            dt.difference(DateTime.now()).inMinutes;
                        if (maxMinutes <= 0) {
                          timeBeforeCtrl.text = "0";
                        } else {
                          timeBeforeCtrl.text = maxMinutes.toString();
                        }
                        if (dialogContext.mounted) {
                          Common.toastMessaage(
                            'Reminder time adjusted to ${timeBeforeCtrl.text} mins before',
                            Colors.orange,
                          );
                        }
                      }
                    } catch (_) {}
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );

            // Time in Minutes Field
            final timeInMinutesField = Row(
              children: [
                const Text(
                  'Time in Minutes: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 110,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeBeforeCtrl,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              int val = int.tryParse(timeBeforeCtrl.text) ?? 0;
                              int newVal = val + 1;
                              if (nextFollowupDateCtrl.text.isNotEmpty) {
                                try {
                                  DateTime dt = DateFormat('dd-MM-yyyy hh:mm a')
                                      .parse(nextFollowupDateCtrl.text);
                                  DateTime reminderTime =
                                      dt.subtract(Duration(minutes: newVal));
                                  if (reminderTime.isBefore(DateTime.now())) {
                                    Common.toastMessaage(
                                      'Cannot set reminder time in the past',
                                      Colors.red,
                                    );
                                    return;
                                  }
                                } catch (_) {}
                              }
                              setDialogState(() {
                                timeBeforeCtrl.text = newVal.toString();
                              });
                            },
                            child: const Icon(
                              Icons.arrow_drop_up,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              int val = int.tryParse(timeBeforeCtrl.text) ?? 0;
                              if (val > 0) {
                                setDialogState(() {
                                  timeBeforeCtrl.text = "${val - 1}";
                                });
                              }
                            },
                            child: const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            final productField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Color(0xFF00A389),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Product',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (selectedProductId != null &&
                              productItems
                                  .any((e) => e['id'] == selectedProductId))
                          ? selectedProductId
                          : null,
                      hint: const Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                      items: productItems.isNotEmpty
                          ? productItems.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['id'],
                                child: Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList()
                          : [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text(
                                  'Select',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              )
                            ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedProductId = (val == '') ? null : val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );

            final costField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cost',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: 48,
                  child: TextFormField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF00A389),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            final priorityField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (selectedPriorityId != null &&
                              priorityItems
                                  .any((e) => e['id'] == selectedPriorityId))
                          ? selectedPriorityId
                          : null,
                      hint: const Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                      items: priorityItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedPriorityId = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );

            final remarksField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Remarks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: 48,
                  child: TextFormField(
                    controller: remarksCtrl,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Remarks',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF00A389),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              elevation: 12,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? 'Edit Followup' : 'Add Followup',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF64748B),
                              size: 22,
                            ),
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      // Form Body
                      Flexible(
                        child: SingleChildScrollView(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 500;
                              if (isWide) {
                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: calledDateField),
                                        const SizedBox(width: 20),
                                        Expanded(child: callStatusField),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    if (isRejected) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: leadStageField),
                                          const SizedBox(width: 20),
                                          Expanded(child: tagsField),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: productField),
                                          const SizedBox(width: 20),
                                          Expanded(child: costField),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: priorityField),
                                          const SizedBox(width: 20),
                                          Expanded(child: remarksField),
                                        ],
                                      ),
                                    ] else if (isFollowUp) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: leadStageField),
                                          const SizedBox(width: 20),
                                          Expanded(
                                              child: nextFollowupDateField),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(child: remindMeCheckbox),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: isRemindMeChecked
                                                ? timeInMinutesField
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: productField),
                                          const SizedBox(width: 20),
                                          Expanded(child: costField),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: priorityField),
                                          const SizedBox(width: 20),
                                          Expanded(child: remarksField),
                                        ],
                                      ),
                                    ] else ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: leadStageField),
                                          const SizedBox(width: 20),
                                          Expanded(child: productField),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: costField),
                                          const SizedBox(width: 20),
                                          Expanded(child: priorityField),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: remarksField),
                                          const SizedBox(width: 20),
                                          const Expanded(
                                              child: SizedBox()),
                                        ],
                                      ),
                                    ],
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    calledDateField,
                                    const SizedBox(height: 14),
                                    callStatusField,
                                    const SizedBox(height: 14),
                                    leadStageField,
                                    if (isRejected) ...[
                                      const SizedBox(height: 14),
                                      tagsField,
                                    ],
                                    if (isFollowUp) ...[
                                      const SizedBox(height: 14),
                                      nextFollowupDateField,
                                      const SizedBox(height: 10),
                                      remindMeCheckbox,
                                      if (isRemindMeChecked) ...[
                                        const SizedBox(height: 10),
                                        timeInMinutesField,
                                      ],
                                    ],
                                    const SizedBox(height: 14),
                                    productField,
                                    const SizedBox(height: 14),
                                    costField,
                                    const SizedBox(height: 14),
                                    priorityField,
                                    const SizedBox(height: 14),
                                    remarksField,
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF1E293B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A389),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isSubmitting ? null : submitFollowup,
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEdit ? 'Update' : 'Submit',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEditFollowup(CustomerFollowupItem item) {
    _showAddFollowupPopup(context, editItem: item);
  }

  void _confirmDeleteFollowup(CustomerFollowupItem item) {
    if (_isDeletingFollowup) return;

    final String followupId = item.id;
    if (followupId.isEmpty) {
      Common.toastMessaage('Invalid follow-up ID', Colors.red);
      return;
    }

    final customerId = (widget.custId != null && widget.custId!.isNotEmpty)
        ? widget.custId!
        : ((item.customerId.isNotEmpty)
            ? item.customerId
            : (dashboardData?.data.customerDetails.id ?? ''));

    final callMasterId = (item.callMasterId.isNotEmpty)
        ? item.callMasterId
        : ((_followupDetails?.data?.callMasterId.isNotEmpty == true)
            ? _followupDetails!.data!.callMasterId
            : (dashboardData?.data.customerDetails.leadId ?? ''));

    showDialog(
      context: context,
      barrierDismissible: !_isDeletingFollowup,
      builder: (BuildContext dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Delete Follow-up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Are you sure you want to delete this follow-up record? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          if (isDeleting || _isDeletingFollowup) return;
                          setDialogState(() {
                            isDeleting = true;
                          });
                          setState(() {
                            _isDeletingFollowup = true;
                          });

                          try {
                            final response =
                                await HttpService.deleteCustomerFollowup(
                              token: widget.token,
                              followupId: followupId,
                              customerId: customerId,
                              callMasterId: callMasterId,
                            );

                            final isSuccess = response != null &&
                                (response['status'] == true ||
                                    response['status'] == 1 ||
                                    response['status'] == '1' ||
                                    response['status'] == 'true' ||
                                    response['data'] == true ||
                                    response['success'] == true);

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (isSuccess) {
                              Common.toastMessaage(
                                (response['message']?.toString().isNotEmpty ==
                                        true)
                                    ? response['message'].toString()
                                    : 'Follow-up deleted successfully',
                                Colors.green,
                              );
                              _fetchFollowupDetails(forceRefresh: true);
                            } else {
                              Common.toastMessaage(
                                (response?['message']?.toString().isNotEmpty ==
                                        true)
                                    ? response!['message'].toString()
                                    : 'Failed to delete follow-up',
                                Colors.red,
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            Common.toastMessaage('Error: $e', Colors.red);
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isDeletingFollowup = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isValidDate(String? dateStr) {
    if (dateStr == null) return false;
    final trimmed = dateStr.trim();
    if (trimmed.isEmpty ||
        trimmed == 'null' ||
        trimmed == '00-00-0000' ||
        trimmed == '0000-00-00' ||
        trimmed.startsWith('00-00-0000') ||
        trimmed.startsWith('0000-00-00')) {
      return false;
    }
    return true;
  }

  String _formatDateSafely(String? dateStr, {String? formattedDate}) {
    if (_isValidDate(formattedDate)) {
      return formattedDate!.trim();
    }
    if (!_isValidDate(dateStr)) {
      return '-';
    }
    final clean = dateStr!.trim();
    try {
      DateTime? parsed = DateTime.tryParse(clean);
      if (parsed != null) {
        return DateFormat('dd-MM-yyyy hh:mm a').format(parsed);
      }
      try {
        parsed = DateFormat('yyyy-MM-dd HH:mm:ss').parse(clean);
        return DateFormat('dd-MM-yyyy hh:mm a').format(parsed);
      } catch (_) {}
      try {
        parsed = DateFormat('dd-MM-yyyy HH:mm:ss').parse(clean);
        return DateFormat('dd-MM-yyyy hh:mm a').format(parsed);
      } catch (_) {}
    } catch (_) {}
    return clean;
  }

  Widget _buildFollowupTab() {
    if (_isFollowupLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF2a86c9),
            ),
            SizedBox(height: 16),
            Text(
              'Loading follow-up details...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_followupError != null &&
        (_followupDetails == null || _followupDetails?.data == null)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _followupError ?? 'Failed to load follow-up details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2a86c9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  _fetchFollowupDetails(forceRefresh: true);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final followups = _followupDetails?.data?.followup ?? [];
    final callData = _followupDetails?.data?.callData;

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchFollowupDetails(forceRefresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            if (callData != null) ...[
              _buildFollowupLeadSummary(callData),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Follow-up History',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a86c9).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${followups.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2a86c9),
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openAddFollowup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add_call, size: 16),
                  label: const Text(
                    'Add Follow-up',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (followups.isEmpty)
              _buildEmptyFollowupState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: followups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = followups[index];
                  return _buildFollowupHistoryCard(item, index);
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowupLeadSummary(CustomerCallData callData) {
    final hasNextFollowup = _isValidDate(callData.nextFollowupDate);
    final hasCalledDate = _isValidDate(callData.calledDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      callData.clientName.isNotEmpty
                          ? callData.clientName
                          : (dashboardData?.data.customerDetails.name ??
                              'Lead Details'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (callData.leadCategory.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              callData.leadCategory,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        if (callData.leadCategory.isNotEmpty &&
                            callData.priority.isNotEmpty)
                          const SizedBox(width: 8),
                        if (callData.priority.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriorityBgColor(callData.priorityId),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              callData.priority,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    _getPriorityTextColor(callData.priorityId),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (callData.callResult.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2a86c9).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    callData.callResult,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2a86c9),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMiniInfo(
                  icon: Icons.person_outline,
                  label: 'Staff',
                  value: callData.staffName.isNotEmpty
                      ? callData.staffName
                      : (callData.createdStaff.isNotEmpty
                          ? callData.createdStaff
                          : '-'),
                ),
              ),
              Expanded(
                child: _buildSummaryMiniInfo(
                  icon: Icons.calendar_today_outlined,
                  label: 'Called Date',
                  value: hasCalledDate
                      ? _formatDateSafely(callData.calledDate)
                      : '-',
                ),
              ),
              if (hasNextFollowup)
                Expanded(
                  child: _buildSummaryMiniInfo(
                    icon: Icons.alarm,
                    label: 'Next Follow-up',
                    value: _formatDateSafely(callData.nextFollowupDate),
                    valueColor: Colors.orange.shade800,
                  ),
                ),
            ],
          ),
          if (callData.remarks.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded,
                      size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      callData.remarks,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowupHistoryCard(CustomerFollowupItem item, int index) {
    final hasScheduled = _isValidDate(item.scheduledDate);
    final hasCalled = _isValidDate(item.calledDateFormatted) ||
        _isValidDate(item.calledDate);
    final hasNextFollowup = _isValidDate(item.followupDateFormatted) ||
        _isValidDate(item.followupDate);
    final hasRemarks = item.remarks != null && item.remarks!.trim().isNotEmpty;
    final staffName = item.staffName?.isNotEmpty == true
        ? item.staffName!
        : (item.createdBy?.isNotEmpty == true ? 'User ${item.createdBy}' : '-');

    final isCalledStatus =
        (item.callStatus ?? '').toLowerCase().contains('called') &&
            !(item.callStatus ?? '').toLowerCase().contains('not');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2a86c9), Color(0xFF1C1A79)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    staffName.isNotEmpty ? staffName[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staffName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_isValidDate(item.createdAt))
                      Text(
                        _formatDateSafely(item.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (item.callStatus != null && item.callStatus!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCalledStatus
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCalledStatus
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCalledStatus
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.callStatus!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCalledStatus
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              if (item.isEditDelete == true) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Edit Follow-up',
                  child: InkWell(
                    onTap: () => _openEditFollowup(item),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Delete Follow-up',
                  child: InkWell(
                    onTap: () => _confirmDeleteFollowup(item),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 14,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (item.callResult != null && item.callResult!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_forwarded,
                          size: 13, color: Color(0xFF2a86c9)),
                      const SizedBox(width: 5),
                      Text(
                        'Result: ${item.callResult}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2a86c9),
                        ),
                      ),
                    ],
                  ),
                ),
              if (item.callResponse != null && item.callResponse!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.headset_mic_outlined,
                          size: 13, color: Colors.purple.shade700),
                      const SizedBox(width: 5),
                      Text(
                        'Response: ${item.callResponse}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              if (item.reason != null && item.reason!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Reason: ${item.reason}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                if (hasCalled)
                  _buildFollowupDateRow(
                    icon: Icons.phone_callback_rounded,
                    label: 'Called Date',
                    value: _formatDateSafely(
                      item.calledDate,
                      formattedDate: item.calledDateFormatted,
                    ),
                    color: Colors.blue.shade700,
                  ),
                if (hasScheduled) ...[
                  if (hasCalled) const SizedBox(height: 8),
                  _buildFollowupDateRow(
                    icon: Icons.event_available_rounded,
                    label: 'Scheduled Date',
                    value: _formatDateSafely(
                      item.scheduledDate,
                    ),
                    color: Colors.teal.shade700,
                  ),
                ],
                if (hasNextFollowup) ...[
                  if (hasCalled || hasScheduled) const SizedBox(height: 8),
                  _buildFollowupDateRow(
                    icon: Icons.update_rounded,
                    label: 'Next Follow-up Date',
                    value: _formatDateSafely(
                      item.followupDate,
                      formattedDate: item.followupDateFormatted,
                    ),
                    color: Colors.deepOrange.shade700,
                  ),
                ],
                if (!hasCalled && !hasScheduled && !hasNextFollowup)
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text(
                        'Date not recorded',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (hasRemarks) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.amber.shade200.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 14, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.remarks!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryMiniInfo({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFollowupDateRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getPriorityBgColor(String? priorityId) {
    switch (priorityId) {
      case '1':
      case '4':
        return Colors.red.shade50;
      case '2':
      case '3':
        return Colors.orange.shade50;
      default:
        return Colors.blue.shade50;
    }
  }

  Color _getPriorityTextColor(String? priorityId) {
    switch (priorityId) {
      case '1':
      case '4':
        return Colors.red.shade700;
      case '2':
      case '3':
        return Colors.orange.shade800;
      default:
        return Colors.blue.shade700;
    }
  }

  Widget _buildEmptyFollowupState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_missed_outlined,
              size: 40,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Follow-up Records',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are no follow-up interactions recorded for this customer yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openAddFollowup,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a86c9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add_call, size: 16),
            label: const Text('Add First Follow-up'),
          ),
        ],
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
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerQuotationPage(
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
                    title: 'Quotations',
                    total: quotations?.total ?? '0',
                    totalLabel: 'Total',
                    sub: 'Approved',
                    subValue: quotations?.approved ?? '0',
                    icon: Icons.description_outlined,
                    color: const Color(0xFF43e97b),
                  ),
                ),
              ),
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
