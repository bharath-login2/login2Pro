import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/serviceman/serviceCollectionModel.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceCollectionListPage extends StatefulWidget {
  final int type;
  final String title;

  const ServiceCollectionListPage({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<ServiceCollectionListPage> createState() =>
      _ServiceCollectionListPageState();
}

class _ServiceCollectionListPageState extends State<ServiceCollectionListPage> {
  bool isLoading = true;
  ServiceCollectionData? collectionData;
  List<ServiceCollectionRecord> records = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchCollectionData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCollectionData() async {
    setState(() => isLoading = true);
    try {
      final httpService = HttpService();
      final model = await httpService.getServiceCollection(widget.type);
      if (model != null && model.status == true && model.data != null) {
        setState(() {
          collectionData = model.data;
          records = model.data?.records ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching service collection: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<ServiceCollectionRecord> get _filteredRecords {
    if (_searchQuery.trim().isEmpty) return records;
    final query = _searchQuery.toLowerCase().trim();
    return records.where((item) {
      final name = (item.customerName ?? "").toLowerCase();
      final phone = (item.customerPhone ?? "").toLowerCase();
      final invNum = (item.invoiceNumber ?? "").toLowerCase();
      final invId = (item.invoiceId ?? "").toLowerCase();
      final status = (item.paymentStatus ?? "").toLowerCase();
      final createdBy = (item.createdByName ?? "").toLowerCase();
      return name.contains(query) ||
          phone.contains(query) ||
          invNum.contains(query) ||
          invId.contains(query) ||
          status.contains(query) ||
          createdBy.contains(query);
    }).toList();
  }

  void _launchPhone(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;
    final telUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching phone: $e");
    }
  }

  String _formatAmount(num? amount) {
    if (amount == null || amount == 0) return "0.00";
    return NumberFormat("#,##,##0.00", "en_IN").format(amount);
  }

  Color _getStatusColor(String? status) {
    switch ((status ?? "").toLowerCase()) {
      case 'paid':
      case 'completed':
        return const Color(0xFF10B981);
      case 'unpaid':
      case 'due':
        return const Color(0xFFEF4444);
      case 'partial':
      case 'partially paid':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredRecords;
    final num totalCollection = collectionData?.collection ?? 0;
    final int totalRecordsCount = collectionData?.totalRecords ?? records.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Total Summary Card Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL COLLECTION",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoading ? "..." : "₹${_formatAmount(totalCollection)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        isLoading ? "..." : "$totalRecordsCount Records",
                        style: const TextStyle(
                          color: Colors.white,
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

          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search customer, phone, invoice #...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Color(0xFF2a86c9)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // List Count Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A86C9).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${filteredList.length} Items",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A86C9),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Total: ${records.length}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Main List View
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2A86C9)),
                  )
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "No records matching '$_searchQuery'"
                                  : "No collection records found.",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF2A86C9),
                        onRefresh: _fetchCollectionData,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildCollectionCard(filteredList[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(ServiceCollectionRecord record) {
    final statusColor = _getStatusColor(record.paymentStatus);
    final String invDisplay = (record.invoiceNumber?.isNotEmpty == true)
        ? record.invoiceNumber!
        : (record.invoiceId ?? "N/A");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Column(
        children: [
          // Card Header: Invoice # and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A86C9).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: Color(0xFF2A86C9),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Inv #$invDisplay",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    (record.paymentStatus ?? "UNKNOWN").toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Customer Details & Phone Action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person,
                              size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              record.customerName?.isNotEmpty == true
                                  ? record.customerName!
                                  : "Customer",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (record.customerPhone?.isNotEmpty == true)
                      InkWell(
                        onTap: () => _launchPhone(record.customerPhone!),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone,
                                  size: 13, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                record.customerPhone!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Amount Breakdown Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAmountCol(
                        "Total Amount",
                        "₹${_formatAmount(record.totalAmount)}",
                        const Color(0xFF1E293B),
                      ),
                      Container(
                        height: 25,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildAmountCol(
                        "Paid Amount",
                        "₹${_formatAmount(record.paidAmount)}",
                        const Color(0xFF10B981),
                      ),
                      Container(
                        height: 25,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildAmountCol(
                        "Due Amount",
                        "₹${_formatAmount(record.dueAmount)}",
                        (record.dueAmount ?? 0) > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Card Footer: Date & Created By
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          record.invoiceDate?.isNotEmpty == true
                              ? record.invoiceDate!
                              : (record.createdAt ?? "N/A"),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (record.createdByName?.isNotEmpty == true)
                      Row(
                        children: [
                          const Icon(Icons.account_circle_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "By: ${record.createdByName}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCol(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
