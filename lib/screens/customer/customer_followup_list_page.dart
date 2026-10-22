import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/customers/customerFollowupListModel.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';

typedef CustomerListPage = CustomerFollowupListPage;

class CustomerFollowupListPage extends StatefulWidget {
  final String token;
  final String filterType; // 'Follow-up', 'Total Called', 'Missed', 'Transferred'
  final int? filterCount;
  final int? followupCount;
  final int? calledCount;
  final int? missedCount;
  final int? transferredCount;
  final String? fromDate;
  final String? toDate;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomerFollowupListPage({
    super.key,
    required this.token,
    required this.filterType,
    this.filterCount,
    this.followupCount,
    this.calledCount,
    this.missedCount,
    this.transferredCount,
    this.fromDate,
    this.toDate,
    this.scaffoldKey,
  });

  @override
  State<CustomerFollowupListPage> createState() =>
      _CustomerFollowupListPageState();
}

class _CustomerFollowupListPageState extends State<CustomerFollowupListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<CustomerFollowupListItem> _allItems = [];
  List<CustomerFollowupListItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  String _currentUserId = '';
  String _phoneCallLogPermission = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    fetchFollowupList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final userId = await Common.getSharedPref("userId");
    final permission =
        await Common.getSharedPref("phoneCallLogPermission");
    if (mounted) {
      setState(() {
        _currentUserId = userId ?? '';
        _phoneCallLogPermission = permission ?? '';
      });
    }
  }

  Future<void> fetchFollowupList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await HttpService.getCustomerFollowupList(
        token: widget.token,
        filterType: widget.filterType,
        filterCount: widget.filterCount,
        followupCount: widget.followupCount,
        calledCount: widget.calledCount,
        missedCount: widget.missedCount,
        transferredCount: widget.transferredCount,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
      );

      if (mounted) {
        if (response != null && response.status) {
          setState(() {
            _allItems = response.data;
            _applySearchFilter();
            _isLoading = false;
          });
        } else {
          setState(() {
            _allItems = [];
            _filteredItems = [];
            _errorMessage = response?.message.isNotEmpty == true
                ? response!.message
                : "No records found.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allItems = [];
          _filteredItems = [];
          _errorMessage = "Failed to load customer list: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _applySearchFilter();
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(_allItems);
      });
      return;
    }

    setState(() {
      _filteredItems = _allItems.where((item) {
        final name = item.name.toLowerCase();
        final contact = item.contactNo.toLowerCase();
        final email = item.emailId.toLowerCase();
        final address = item.fullAddress.toLowerCase();
        final id = item.customerId.toLowerCase();
        final leadId = item.leadId.toLowerCase();
        final remarks = item.remarks.toLowerCase();

        return name.contains(query) ||
            contact.contains(query) ||
            email.contains(query) ||
            address.contains(query) ||
            id.contains(query) ||
            leadId.contains(query) ||
            remarks.contains(query);
      }).toList();
    });
  }

  void _makePhoneCall(String countryCode, String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is not available')),
      );
      return;
    }
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot make call to $cleanPhone')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not place call: $e')),
      );
    }
  }

  void _openWhatsApp(String countryCode, String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp number is not available')),
      );
      return;
    }
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }
    final cleanCode = countryCode.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappNumber = cleanPhone.length > 10
        ? cleanPhone
        : '${cleanCode.isNotEmpty ? cleanCode : "91"}$cleanPhone';

    final whatsappUrl = Uri.parse('whatsapp://send?phone=$whatsappNumber');
    final webUrl = Uri.parse('https://wa.me/$whatsappNumber');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open WhatsApp')),
      );
    }
  }

  void _navigateToCustomerDashboard(
      CustomerFollowupListItem item, {bool openFollowupTab = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDashboard(
          token: widget.token,
          name: item.name,
          userId: _currentUserId,
          custId: item.customerId.isNotEmpty ? item.customerId : item.id,
          phoneCallLogPermission: _phoneCallLogPermission,
          openFollowupTab: openFollowupTab,
        ),
      ),
    );
  }

  _TileTheme _getTileTheme() {
    final lower = widget.filterType.toLowerCase();
    if (lower.contains('called')) {
      return const _TileTheme(
        accentColor: Color(0xFF10B981),
        lightBgColor: Color(0xFFD1FAE5),
        textColor: Color(0xFF047857),
        borderColor: Color(0xFFA7F3D0),
        icon: Icons.call_outlined,
      );
    } else if (lower.contains('missed')) {
      return const _TileTheme(
        accentColor: Color(0xFFEF4444),
        lightBgColor: Color(0xFFFEE2E2),
        textColor: Color(0xFFB91C1C),
        borderColor: Color(0xFFFECACA),
        icon: Icons.phone_missed_outlined,
      );
    } else if (lower.contains('transferred')) {
      return const _TileTheme(
        accentColor: Color(0xFF6366F1),
        lightBgColor: Color(0xFFEDE9FE),
        textColor: Color(0xFF4338CA),
        borderColor: Color(0xFFDDD6FE),
        icon: Icons.swap_horiz_rounded,
      );
    } else {
      // Follow-up default
      return const _TileTheme(
        accentColor: Color(0xFFF59E0B),
        lightBgColor: Color(0xFFFEF3C7),
        textColor: Color(0xFFB45309),
        borderColor: Color(0xFFFDE68A),
        icon: Icons.calendar_today_outlined,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTileTheme();
    final int countDisplay = widget.filterCount ??
        widget.followupCount ??
        widget.calledCount ??
        widget.missedCount ??
        widget.transferredCount ??
        _allItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.filterType} Customers',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          'Total Filter Count: $countDisplay',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: fetchFollowupList,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Details Bar
          _buildFilterInfoCard(theme, countDisplay),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  hintText: 'Search by name, contact, address, or ID...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // List Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchFollowupList,
              color: const Color(0xFF2A86C9),
              child: _buildListContent(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInfoCard(_TileTheme theme, int countDisplay) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.lightBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              theme.icon,
              size: 18,
              color: theme.textColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.lightBgColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.borderColor),
                      ),
                      child: Text(
                        widget.filterType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter Count: $countDisplay',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                if (widget.fromDate != null &&
                    widget.fromDate!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 12,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Period: ${widget.fromDate} to ${widget.toDate ?? ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filteredItems.length} loaded',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(_TileTheme theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2A86C9)),
            SizedBox(height: 14),
            Text(
              'Loading customer followup records...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: fetchFollowupList,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A86C9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_search_outlined,
                    color: Color(0xFF94A3B8),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'No Customers Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'No customer records match "${_searchController.text}".'
                      : 'No records available for the ${widget.filterType} filter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildCustomerCard(item, theme);
      },
    );
  }

  Widget _buildCustomerCard(
      CustomerFollowupListItem item, _TileTheme theme) {
    final relevantDateStr = item.relevantDate(widget.filterType);
    final String initial =
        item.name.trim().isNotEmpty ? item.name.trim()[0].toUpperCase() : 'C';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToCustomerDashboard(item),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Name, ID, Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A86C9), Color(0xFF406DBE)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.customerId.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '#${item.customerId}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Badges row
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (item.isNegative == '1')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: const Color(0xFFFCA5A5)),
                                  ),
                                  child: const Text(
                                    'Negative',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              if (item.priority.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.flag_rounded,
                                        size: 10,
                                        color: Color(0xFF2563EB),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Priority ${item.priority}',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1D4ED8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (item.taxType.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    item.taxType,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Details section: Phone, Email, Address
                if (item.contactNo.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.phoneWithCountryCode,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      // Quick action buttons: Call & WhatsApp
                      InkWell(
                        onTap: () => _makePhoneCall(
                            item.countryCode, item.contactNo),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Icon(
                            Icons.call,
                            size: 13,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _openWhatsApp(
                            item.whatsappCountryCode.isNotEmpty
                                ? item.whatsappCountryCode
                                : item.countryCode,
                            item.whatsappNumber.isNotEmpty
                                ? item.whatsappNumber
                                : item.contactNo),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF86EFAC)),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            size: 13,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (item.emailId.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.emailId,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (item.fullAddress.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.fullAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Relevant Date Pill
                if (relevantDateStr != null &&
                    relevantDateStr.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.lightBgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          theme.icon,
                          size: 13,
                          color: theme.textColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getDateLabel(widget.filterType, relevantDateStr),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: theme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Remarks if present
                if (item.remarks.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.remarks,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Bottom Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _navigateToCustomerDashboard(
                        item,
                        openFollowupTab: true,
                      ),
                      icon: const Icon(
                        Icons.history_outlined,
                        size: 14,
                        color: Color(0xFF2A86C9),
                      ),
                      label: const Text(
                        'Follow-up Details',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A86C9),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _navigateToCustomerDashboard(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A86C9), Color(0xFF406DBE)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Dashboard',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDateLabel(String filterType, String dateStr) {
    final lower = filterType.toLowerCase();
    if (lower.contains('called')) {
      return 'Called: $dateStr';
    } else if (lower.contains('transferred')) {
      return 'Transferred: $dateStr';
    } else if (lower.contains('missed')) {
      return 'Overdue / Scheduled: $dateStr';
    } else {
      return 'Scheduled: $dateStr';
    }
  }
}

class _TileTheme {
  final Color accentColor;
  final Color lightBgColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  const _TileTheme({
    required this.accentColor,
    required this.lightBgColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });
}
