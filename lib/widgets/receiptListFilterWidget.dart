// Your imports here...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/service/service.dart';
import 'package:login2/core/common.dart';

class ReceiptListFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final int pageId;
  final Map<String, dynamic>? initialFilters;

  const ReceiptListFilterWidget({
    super.key,
    required this.onApplyFilters,
    required this.pageId,
    this.initialFilters,
  });

  @override
  State<ReceiptListFilterWidget> createState() =>
      _ReceiptListFilterWidgetState();
}

class _ReceiptListFilterWidgetState extends State<ReceiptListFilterWidget> {
  String selectedCategory = 'Account Head';
  Set<String> selectedAccountHeadIds = {};
  DateTime? createdFrom;
  DateTime? createdTo;
  List<AccountHead> allAccountHeads = [];
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _searchController = TextEditingController();
// @override
// void initState() {
//   super.initState();
//   final now = DateTime.now();
//   createdFrom = widget.initialFilters?['created_from'] != null
//       ? DateTime.parse(widget.initialFilters!['created_from'])
//       : DateTime(now.year, now.month, 1);
//   createdTo = widget.initialFilters?['created_to'] != null
//       ? DateTime.parse(widget.initialFilters!['created_to'])
//       : DateTime(now.year, now.month + 1, 0);
//   selectedAccountHeadIds = widget.initialFilters?['account_head_ids'] != null
//       ? Set.from(widget.initialFilters!['account_head_ids'])
//       : <String>{};
//   _loadData();
// }
  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      if (widget.initialFilters!['created_from'] != null) {
        try {
          String dateString = widget.initialFilters!['created_from'];
          if (dateString.contains('-') && dateString.split('-').length == 3) {
            createdFrom = _formatter.parse(dateString);
          } else {
            createdFrom = DateTime.parse(dateString);
          }
        } catch (e) {
          print("Error parsing created_from: $e");
        }
      }
      if (widget.initialFilters!['created_to'] != null) {
        try {
          String dateString = widget.initialFilters!['created_to'];
          if (dateString.contains('-') && dateString.split('-').length == 3) {
            createdTo = _formatter.parse(dateString);
          } else {
            createdTo = DateTime.parse(dateString);
          }
        } catch (e) {
          print("Error parsing created_to: $e");
        }
      }
      if (widget.initialFilters!['account_head_ids'] != null) {
        selectedAccountHeadIds =
            Set.from(widget.initialFilters!['account_head_ids']);
      }
    }
    if (createdFrom == null) {
      final now = DateTime.now();
      createdFrom = DateTime(now.year, now.month, 1);
    }
    if (createdTo == null) {
      final now = DateTime.now();
      createdTo = DateTime(now.year, now.month + 1, 0);
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final masterData = await HttpService.expenseMasterData();
    if (mounted && masterData != null && masterData.status) {
      setState(() {
        allAccountHeads = _sortSelectedToTop(masterData.data.accountHead,
            selectedAccountHeadIds, (a) => a.accountId);
      });
    }
  }

  List<T> _sortSelectedToTop<T>(
      List<T> items, Set<String> selectedIds, String Function(T) getId) {
    final selectedItems =
        items.where((item) => selectedIds.contains(getId(item))).toList();
    final unselectedItems =
        items.where((item) => !selectedIds.contains(getId(item))).toList();
    return [...selectedItems, ...unselectedItems];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, -3))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFilterBody(),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE4E9F2), height: 1),
          const SizedBox(height: 16),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A59)),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2E3A59)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFilterBody() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterCategories(),
          const SizedBox(width: 16),
          Expanded(child: _buildFilterOptionsPanel()),
        ],
      ),
    );
  }

  Widget _buildFilterCategories() {
    final categories = ['Account Head', 'Receipt Date', 'Target Group'];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories
            .map((title) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _buildFilterCategory(
                    title,
                    title == 'Receipt Date'
                        ? Icons.date_range
                        : Icons.account_circle,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFilterCategory(String title, IconData icon) {
    final isSelected = selectedCategory == title;
    final hasFilters = _hasFiltersForCategory(title);

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF3366FF)),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  if (hasFilters)
                    Positioned(
                      right: 0,
                      top: 6,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
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

  bool _hasFiltersForCategory(String category) {
    switch (category) {
      case 'Account Head':
        return selectedAccountHeadIds.isNotEmpty;
      case 'Receipt Date':
        return createdFrom != null || createdTo != null;
      case 'Target Group':
        return false;
      default:
        return false;
    }
  }

  Widget _buildFilterOptionsPanel() {
    switch (selectedCategory) {
      case 'Account Head':
        return _buildAccountHeadSelectionList();

      case 'Receipt Date':
        return Column(
          children: [
            _buildDateField(
                "From", createdFrom, true, createdTo, (d) async {
                  final dateFilterMonths = await Common.getDateFilter();
                  setState(() {
                    createdFrom = d;
                    if (dateFilterMonths != null && dateFilterMonths > 0) {
                      final maxTo = Common.addMonths(d, dateFilterMonths);
                      if (createdTo != null && (createdTo!.isBefore(d) || createdTo!.isAfter(maxTo))) {
                        createdTo = null;
                      }
                    } else if (createdTo != null && createdTo!.isBefore(d)) {
                      createdTo = null;
                    }
                  });
                }),
            const SizedBox(height: 20),
            _buildDateField(
                "To", createdTo, false, createdFrom, (d) async {
                  final dateFilterMonths = await Common.getDateFilter();
                  setState(() {
                    createdTo = d;
                    if (d != null && dateFilterMonths != null && dateFilterMonths > 0) {
                      final minFrom = Common.subtractMonths(d, dateFilterMonths);
                      if (createdFrom != null && (createdFrom!.isBefore(minFrom) || createdFrom!.isAfter(d))) {
                        createdFrom = null;
                      }
                    }
                  });
                }),
          ],
        );
      default:
        return const Text("Coming soon...");
    }
  }

  Widget _buildDateField(
      String label, DateTime? value, bool isFrom, DateTime? otherDate, Function(DateTime) onSelect) {
    final display = value != null ? _formatter.format(value) : 'Select';
    return GestureDetector(
      onTap: () async {
        final dateFilterMonths = await Common.getDateFilter();
        final DateTime now = DateTime.now();

        DateTime firstDate;
        DateTime lastDate;
        DateTime initialDate;

        if (isFrom) {
          if (otherDate != null) {
            lastDate = otherDate;
            if (dateFilterMonths != null && dateFilterMonths > 0) {
              firstDate = Common.subtractMonths(otherDate, dateFilterMonths);
            } else {
              firstDate = DateTime(2020);
            }
          } else {
            firstDate = DateTime(2020);
            lastDate = DateTime(2100);
          }
          initialDate = value ?? lastDate;
          if (initialDate.isBefore(firstDate)) initialDate = firstDate;
          if (initialDate.isAfter(lastDate)) initialDate = lastDate;
        } else {
          if (otherDate != null) {
            firstDate = otherDate;
            if (dateFilterMonths != null && dateFilterMonths > 0) {
              lastDate = Common.addMonths(otherDate, dateFilterMonths);
            } else {
              lastDate = DateTime(2100);
            }
          } else {
            firstDate = DateTime(2020);
            lastDate = DateTime(2100);
          }
          initialDate = value ?? firstDate;
          if (initialDate.isBefore(firstDate)) initialDate = firstDate;
          if (initialDate.isAfter(lastDate)) initialDate = lastDate;
        }

        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) onSelect(picked);
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Color(0xFF3366FF)),
          const SizedBox(width: 8),
          Text('$label: $display',
              style: const TextStyle(fontSize: 14, color: Color(0xFF2E3A59))),
        ],
      ),
    );
  }

  // Widget _buildAccountHeadSelectionList() {
  //   final filteredHeads = allAccountHeads.where((head) {
  //     final searchTerm = _searchController.text.toLowerCase();
  //     return head.accountName.toLowerCase().contains(searchTerm);
  //   }).toList();

  //   return Column(
  //     children: [
  //       TextField(
  //         controller: _searchController,
  //         decoration: InputDecoration(
  //           hintText: 'Search Account Head',
  //           prefixIcon: const Icon(Icons.search),
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //           isDense: true,
  //         ),
  //         onChanged: (value) => setState(() {}),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         height: 250,
  //         decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC5CEE0)), borderRadius: BorderRadius.circular(8)),
  //         child: ListView.builder(
  //           itemCount: filteredHeads.length,
  //           itemBuilder: (context, index) {
  //             final head = filteredHeads[index];
  //             final selected = selectedAccountHeadIds.contains(head.accountId);

  //             return CheckboxListTile(
  //               controlAffinity: ListTileControlAffinity.leading,
  //               contentPadding: const EdgeInsets.symmetric(horizontal: 4),
  //               dense: true,
  //               visualDensity: VisualDensity.compact,
  //               value: selected,
  //               onChanged: (val) {
  //                 setState(() {
  //                   if (val == true) {
  //                     selectedAccountHeadIds.add(head.accountId);
  //                   } else {
  //                     selectedAccountHeadIds.remove(head.accountId);
  //                   }
  //                 });
  //               },
  //               title: Text(
  //                 head.accountName,
  //                 style: const TextStyle(fontSize: 13),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildAccountHeadSelectionList() {
    final searchTerm = _searchController.text.toLowerCase();
    final filteredHeads = allAccountHeads.where((head) {
      return head.accountName.toLowerCase().contains(searchTerm);
    }).toList();

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Account Head',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFC5CEE0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: filteredHeads.length,
            itemBuilder: (context, index) {
              final head = filteredHeads[index];
              final selected = selectedAccountHeadIds.contains(head.accountId);

              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
                visualDensity: VisualDensity.compact,
                value: selected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedAccountHeadIds.add(head.accountId);
                    } else {
                      selectedAccountHeadIds.remove(head.accountId);
                    }
                  });
                },
                title: Text(
                  head.accountName,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366FF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'account_head_ids': selectedAccountHeadIds.toList(),
      'created_from': createdFrom?.toIso8601String(),
      'created_to': createdTo?.toIso8601String(),
    });
    Navigator.pop(context);
  }
}
