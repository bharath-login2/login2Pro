import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/rental/rentalDashbaordModel.dart';
import 'package:login2/service/service.dart';

class OverdueReturnsListPage extends StatefulWidget {
  final String token;
  final List<OverdueItem> initialOverdueList;
  final String? selectedDateString;

  const OverdueReturnsListPage({
    super.key,
    required this.token,
    required this.initialOverdueList,
    this.selectedDateString,
  });

  @override
  State<OverdueReturnsListPage> createState() => _OverdueReturnsListPageState();
}

class _OverdueReturnsListPageState extends State<OverdueReturnsListPage> {
  late List<OverdueItem> _overdueList;
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _overdueList = List.from(widget.initialOverdueList);
  }

  Future<void> _refreshList() async {
    final dateStr =
        widget.selectedDateString ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() => _isLoading = true);
    try {
      final data = await HttpService.getRentalDashboard(dateStr);
      if (mounted && data != null && data.status) {
        setState(() {
          _overdueList = data.data.overdueList;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing overdue list: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<OverdueItem> _getFilteredList() {
    if (_searchQuery.trim().isEmpty) {
      return _overdueList;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _overdueList.where((item) {
      final nameMatches = item.name.toLowerCase().contains(query);
      final daysMatches = item.totalDays.toLowerCase().contains(query);
      final dateMatches = item.toDate.toLowerCase().contains(query);
      final amountMatches = item.grandTotal.toLowerCase().contains(query);
      return nameMatches || daysMatches || dateMatches || amountMatches;
    }).toList();
  }

  double _calculateTotalAmount(List<OverdueItem> items) {
    double total = 0;
    for (var item in items) {
      total += double.tryParse(item.grandTotal) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();
    final totalAmount = _calculateTotalAmount(filteredList);

    final formattedTotalAmount = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    ).format(totalAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text(
          'Overdue Returns',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2a86c9),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Header & Search Bar
          Container(
            color: const Color(0xFF2a86c9),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Search Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by customer name, amount...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2a86c9)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metrics Summary Header Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overdue Records',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${filteredList.length} Items',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedTotalAmount,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1C1A79),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Overdue Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _refreshList,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildOverdueCard(filteredList[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.check_circle_outline,
                size: 56,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching overdue returns'
                  : 'No overdue returns',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with a different keyword'
                  : 'All returns are up to date',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueCard(OverdueItem item) {
    final totalDays = int.tryParse(item.totalDays) ?? 0;
    final amount = double.tryParse(item.grandTotal) ?? 0;

    final formattedAmount = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(item.toDate);
    } catch (e) {
      debugPrint('Error parsing date: ${item.toDate}');
    }

    final formattedDate = parsedDate != null
        ? DateFormat('dd MMM yyyy').format(parsedDate)
        : item.toDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isNotEmpty ? item.name : 'Unknown Customer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Text(
                    '$totalDays Days Overdue',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedAmount,
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
