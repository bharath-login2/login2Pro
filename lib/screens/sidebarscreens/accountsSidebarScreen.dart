// settings_menu_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/accounts/clients/gstInvoiceList.dart';
import 'package:login2/screens/accounts/clients/invoiceList.dart';
import 'package:login2/screens/accounts/clients/pendingInvoice.dart';
import 'package:login2/screens/accounts/clients/proformaInvoiceList.dart';
import 'package:login2/screens/accounts/clients/receiptList.dart';
import 'package:login2/screens/accounts/expense/expense_categories.dart';
import 'package:login2/screens/accounts/expense/expense_list.dart';
import 'package:login2/screens/accounts/expense/pendingExpenseHistory.dart';
import 'package:login2/screens/accounts/expense/unverifiedReponsePage.dart';
import 'package:login2/screens/accounts/recentTransactionsPage.dart';
import 'package:login2/screens/accounts/archivedInvoicePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/leadManagement/viewLeadsNew.dart';
import 'package:login2/screens/rental/addRentalReturnPage.dart';
import 'package:login2/screens/rental/rentIssueListPage.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/staff_reports/timeline_page.dart';
import 'package:login2/service/service.dart';
import 'package:login2/screens/accounts/dashboard/account_head.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedProformaInvoiceListPage.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedInvoiceListPage.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedReceiptListPage.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedGstInvoiceListPage.dart';

class AccountsMenuWidget extends StatefulWidget {
  final String token;
  final String? name;
  final String? userId;
  final String? staffId;
  final bool isExpired;
  final dynamic configure;
  final dynamic leadDashboard;
  final String fromdate;
  final String todate;
  final bool loadmore;
  final VoidCallback onDataRefresh;
  final VoidCallback onStaffwiseRefresh;

  const AccountsMenuWidget({
    super.key,
    required this.token,
    this.name,
    this.userId,
    this.staffId,
    required this.isExpired,
    this.configure,
    this.leadDashboard,
    required this.fromdate,
    required this.todate,
    required this.loadmore,
    required this.onDataRefresh,
    required this.onStaffwiseRefresh,
  });

  @override
  State<AccountsMenuWidget> createState() => _AccountsMenuWidgetState();
}

class _AccountsMenuWidgetState extends State<AccountsMenuWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  // Permission variables
  String? adminCheckPermission;
  String? viewAllWorkPermission;
  String? viewAttendanceSection;
  String? approvePayroll;
  String? viewPendingWorks;
  String? assignWork;
  String? viewTargetReportPermission;
  String? multipleWorksCheck;
  String? viewWorkReportPermission;
  String? viewLeadPermission;
  String? accessCallHistoryPermission;
  bool accessCallRecordingPermission1 = false;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  String? proformaInvoiceMenu;
  String? gstInvoiceMenu;
  AccountDashboardModel? dashboard;
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  bool toggle = false;

  List<dynamic> get list => [
        "Invoices",
        "Pending Invoices",
        "Receipts",
        "Expense",
        "Customers",
        "Account Head",
        if (proformaInvoiceMenu == "true") "Proforma Invoices",
        if (proformaInvoiceMenu == "true") "Proforma Deleted",
        if (gstInvoiceMenu == "true") "GST Invoices",
        //  "Updated Invoice",
      ];
  @override
  void initState() {
    super.initState();
    _loadPermissions();
    getList();
  }

  Future<void> getList() async {
    String fDate = DateFormat('dd-MM-yyyy')
        .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
    String tDate = DateFormat('dd-MM-yyyy')
        .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

    dashboard = await HttpService.accountsDashboard(fDate, tDate);

    proformaInvoiceMenu =
        await Common.getSharedPref("proformaInvoiceMenu") ?? "";
    gstInvoiceMenu = await Common.getSharedPref("gstInvoiceMenu") ?? "";
    // pendingInvoiceMenu = await Common.getSharedPref("pendingInvoiceMenu") ?? "";
    // receiptMenu = await Common.getSharedPref("receiptMenu") ?? "";

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();

    // Load string permissions
    adminCheckPermission = prefs.getString('adminCheckPermission') ?? '';
    viewAllWorkPermission = prefs.getString('viewAllWorkPermission') ?? '';
    viewAttendanceSection = prefs.getString('viewAttendanceSection') ?? '';
    approvePayroll = prefs.getString('approvePayroll') ?? '';
    viewPendingWorks = prefs.getString('viewPendingWorks') ?? '';
    assignWork = prefs.getString('assignWork') ?? '';
    viewTargetReportPermission =
        prefs.getString('viewTargetReportPermission') ?? '';
    multipleWorksCheck = prefs.getString('multipleWorks') ?? '';
    viewWorkReportPermission =
        prefs.getString('viewWorkReportPermission') ?? '';
    viewLeadPermission = prefs.getString('viewLeadPermission') ?? '';
    accessCallHistoryPermission =
        prefs.getString('accessCallHistoryPermission') ?? '';

    // Load boolean permissions
    final accessCallRecordingPermission =
        prefs.getString('accessCallRecordingPermission') ?? 'false';
    final createLeadCategory = prefs.getString('createLeadCategory') ?? 'false';
    final updateLeadCategory = prefs.getString('updateLeadCategory') ?? 'false';
    final deleteLeadCategory = prefs.getString('deleteLeadCategory') ?? 'false';
    final updateLeadPermission =
        prefs.getString('updateLeadPermission') ?? 'false';
    final deleteLeadPermission =
        prefs.getString('deleteLeadPermission') ?? 'false';
    final cloudCallPermission =
        prefs.getString('cloudCallPermission') ?? 'false';

    // Convert string to boolean
    accessCallRecordingPermission1 = accessCallRecordingPermission == 'true';
    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';
    updateLeadPermission1 = updateLeadPermission == 'true';
    deleteLeadPermission1 = deleteLeadPermission == 'true';
    cloudCallPermission1 = cloudCallPermission == 'true';

    if (mounted) {
      setState(() {});
    }
  }

  void _dialogue(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Access Denied"),
          content: Text("You don't have permission to access $permissionName"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.configure != null &&
        widget.isExpired == false &&
        widget.leadDashboard != null) {
      return _buildMenuButton(context);
    }
    return const SizedBox();
  }

  Widget _buildMenuButton(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(17.5),
          onTap: () {
            _showSettingsDrawer(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/icons/menu.png",
              width: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.only(top: 0, right: 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with gradient like in example
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF406dbe),
                            Colors.white,
                            Color(0xFF406dbe),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.settings,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Center(
                              child: Image.asset('assets/main/funriders.png',
                                  height: 130, fit: BoxFit.contain),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMenuItemsList(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  List<Widget> _buildMenuItemsList(BuildContext context) {
    final menuItems = <Widget>[];
    menuItems.addAll([
      // _buildSectionHeader('Quick  Links'),
      _buildMenuItemTitle(
        // icon: Icons.pending_actions_rounded,
        title: 'Quick  Links',
        onTap: () {
          // Navigator.pop(context);
          //  _handleMenuItemTap(context, 2);
        },
      ),
      _buildMenuItem(
        icon: Icons.account_balance,
        title: 'Account Head',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 12);
        },
      ),
      _buildMenuItem(
        icon: Icons.receipt,
        title: 'Invoice',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 9);
        },
      ),

      _buildMenuItem(
        icon: Icons.pending_actions,
        title: 'Pending Invoices',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 2);
        },
      ),
      _buildMenuItem(
        icon: Icons.payments,
        title: 'Receipts',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 6);
        },
      ),
      _buildMenuItem(
        icon: Icons.attach_money,
        title: 'Expense',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 7);
        },
      ),
      _buildMenuItem(
        icon: Icons.people,
        title: 'Customers',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 8);
        },
      ),
      _buildMenuItem(
        icon: Icons.transform_rounded,
        title: 'Transfer',
        onTap: () {
          // Navigator.pop(context);
          //  _handleMenuItemTap(context, 8);
        },
      )
    ]);

    if (proformaInvoiceMenu == "true") {
      menuItems.add(_buildMenuItem(
        icon: Icons.description,
        title: 'Proforma Invoice',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 10);
        },
      ));
    }

    if (gstInvoiceMenu == "true") {
      menuItems.add(_buildMenuItem(
        icon: Icons.gavel,
        title: 'GST Invoices',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 11);
        },
      ));
    }

    menuItems.addAll([
      // _buildSectionHeader('Expense'),
      _buildMenuItemTitle(
        // icon: Icons.pending_actions_rounded,
        title: 'Expense',
        onTap: () {
          // Navigator.pop(context);
          //  _handleMenuItemTap(context, 2);
        },
      ),
      _buildMenuItem(
        icon: Icons.money_sharp,
        title: 'Expense List',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 7);
        },
      ),
      _buildMenuItem(
        icon: Icons.expand_circle_down_sharp,
        title: 'Expense Category',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 33);
        },
      ),
      _buildMenuItem(
        icon: Icons.pending_actions_rounded,
        title: 'Pending Expense',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 44);
        },
      ),
    ]);

    menuItems.addAll([
      //_buildSectionHeader('Other'),
      _buildMenuItemTitle(
        // icon: Icons.pending_actions_rounded,
        title: 'Other',
        onTap: () {
          // Navigator.pop(context);
          //  _handleMenuItemTap(context, 2);
        },
      ),
      _buildMenuItem(
        icon: Icons.money_sharp,
        title: 'Recent Transactions',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 66);
        },
      ),
      _buildMenuItem(
        icon: Icons.verified_outlined,
        title: 'Unverified Transactions',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 55); // Add new case
        },
      ),
      _buildMenuItem(
        icon: Icons.pending_actions_rounded,
        title: 'Archived Invoices',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 77);
        },
      ),
      _buildExpansionMenuItem(
        icon: Icons.delete_outline,
        title: 'Deleted List',
        children: [
          if (proformaInvoiceMenu == "true")
            _buildSubMenuItem(
              icon: Icons.description_outlined,
              title: 'Deleted Proforma',
              onTap: () {
                Navigator.pop(context);
                _handleMenuItemTap(context, 111);
              },
            ),
          _buildSubMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'Deleted Invoice',
            onTap: () {
              Navigator.pop(context);
              _handleMenuItemTap(context, 112);
            },
          ),
          _buildSubMenuItem(
            icon: Icons.receipt_outlined,
            title: 'Deleted Receipt',
            onTap: () {
              Navigator.pop(context);
              _handleMenuItemTap(context, 113);
            },
          ),
          _buildSubMenuItem(
            icon: Icons.assessment_outlined,
            title: 'Deleted Gst Invoice',
            onTap: () {
              Navigator.pop(context);
              _handleMenuItemTap(context, 114);
            },
          ),
        ],
      ),
    ]);
    menuItems.add(_buildDivider());
    return menuItems;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 117, 117, 117),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(
        height: 1,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildMenuItemTitle({
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      decoration: TextDecoration.underline, // Add underline
                      decorationColor: Colors.blue, // Blue underline color
                      decorationThickness: 2.0, // Thickness of underline
                      decorationStyle: TextDecorationStyle.solid, // Solid line
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    String? iconImage,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8),
                //   color: const Color.fromARGB(255, 2, 6, 15).withOpacity(0.1),
                // ),
                child: Center(
                  child: iconImage != null
                      ? Image.asset(
                          iconImage,
                          width: 22,
                          height: 22,
                          color: const Color.fromARGB(255, 1, 4, 8),
                        )
                      : Icon(
                          icon ?? Icons.settings, // Provide a default icon
                          size: 22,
                          color: const Color.fromARGB(255, 1, 4, 10),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, int value) {
    _onMenuItemSelected(context, value);
  }

  void _onMenuItemSelected(BuildContext context, int value) async {
    switch (value) {
      case 2: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingInvoice(widget.token.toString(),''),
          ),
        );
        break;

      case 6: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptList(widget.token.toString()),
          ),
        );
        break;

      case 111: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DeletedProformaInvoiceListPage(widget.token.toString()),
          ),
        );
        break;

      case 112: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DeletedInvoiceListPage(widget.token.toString()),
          ),
        );
        break;
      case 113:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DeletedReceiptListPage(widget.token.toString()),
          ),
        );
        break;

      case 114: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DeletedGstInvoiceListPage(widget.token.toString()),
          ),
        );
        break;

      case 7: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseList(),
          ),
        );
        break;

      case 8: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientList(widget.token, _scaffoldKey),
          ),
        );
        break;

      case 9:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvoiceList(widget.token.toString(), "", "", ""),
          ),
        );
        break;
      case 33:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseCategories(),
          ),
        );
        break;

      case 44:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingExpenseHistoryPage(),
          ),
        );
        break;
      case 55:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnverifiedTransactionsPage(
              token: widget.token,
            ),
          ),
        );
        break;

      case 66:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecentTransactionsPage(
              token: widget.token,
            ),
          ),
        );
        break;

      case 77:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArchivedInvoicePage(
              token: widget.token,
            ),
          ),
        );
        break;

      case 10: 
        if (proformaInvoiceMenu == "true") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProformaInvoiceList(widget.token.toString(), "", "", "", ""),
            ),
          );
        }
        break;

      case 11:
        if (gstInvoiceMenu == "true") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GSTInvoiceList(widget.token.toString()),
            ),
          );
        }
        break;

      case 12:
        if (dashboard != null && dashboard!.data.isViewAccHead == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountHead()),
          );
        } else {
          Common.toastMessaage("No permission", Colors.red);
        }
        break;
    }
  }

  Future<void> _handleViewWork(BuildContext context) async {
    if (widget.staffId == null) return;

    final workStatusModel = await HttpService.getWorkStatus();

    if (multipleWorksCheck == "true") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Phone Call Log"),
            content: const Text("Choose an action below"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewWorkPage(staffId: widget.staffId!),
                    ),
                  );
                },
                child: const Text("Works"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TimelinePage(),
                      settings:
                          RouteSettings(arguments: {"staffId": widget.userId}),
                    ),
                  );
                },
                child: const Text("Call Log"),
              ),
            ],
          );
        },
      );
    } else if (multipleWorksCheck == "phone") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TimelinePage(),
          settings: RouteSettings(arguments: {"staffId": widget.staffId}),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewWorkPage(staffId: widget.staffId!),
        ),
      );
    }
  }

  Future<void> getSharedData() async {
  }
  Widget _buildExpansionMenuItem({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: const Color.fromARGB(255, 1, 4, 10),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
          size: 20,
        ),
        children: children,
      ),
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 44),
              Icon(
                icon,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
