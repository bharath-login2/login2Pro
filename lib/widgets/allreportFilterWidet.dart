import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/service/service.dart';

class AllReportFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final int pageId;
  final Map<String, dynamic>? initialFilters;

  const AllReportFilterWidget({
    super.key,
    required this.onApplyFilters,
    required this.pageId,
    this.initialFilters,
  });

  @override
  State<AllReportFilterWidget> createState() => _AllReportFilterWidgetState();
}
class _AllReportFilterWidgetState extends State<AllReportFilterWidget> {
  String selectedCategory = 'Category';
  DateTime? createdFrom;
  DateTime? createdTo;
  List<AccountHead> allAccountHeads = [];
  List<StaffList> staffs = [];
  List<ExpenseType> filteredCategories = [];
  Set<String> selectedFromAccountHeadIds = {};
  Set<String> selectedToAccountHeadIds = {};
  Set<String> selectedCategoryIds = {};
  Set<String> selectedCreatedByIds = {};
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _searchController = TextEditingController();

  @override
void initState() {
  super.initState();
  final now = DateTime.now();
  createdFrom = widget.initialFilters?['created_from'] != null 
      ? DateTime.parse(widget.initialFilters!['created_from'])
      : DateTime(now.year, now.month, 1);
  createdTo = widget.initialFilters?['created_to'] != null
      ? DateTime.parse(widget.initialFilters!['created_to'])
      : DateTime(now.year, now.month + 1, 0);
  selectedCategoryIds = widget.initialFilters?['category_ids'] != null
      ? Set.from(widget.initialFilters!['category_ids'])
      : <String>{};
  selectedFromAccountHeadIds = widget.initialFilters?['from_account_head_ids'] != null
      ? Set.from(widget.initialFilters!['from_account_head_ids'])
      : <String>{};
  selectedToAccountHeadIds = widget.initialFilters?['to_account_head_ids'] != null
      ? Set.from(widget.initialFilters!['to_account_head_ids'])
      : <String>{};
  selectedCreatedByIds = widget.initialFilters?['created_by_ids'] != null
      ? Set.from(widget.initialFilters!['created_by_ids'])
      : <String>{};
  _loadData();
}

  Future<void> _loadData() async {
    final masterData = await HttpService.expenseMasterData();
    final dateFilterMonths = await Common.getDateFilter();
    if (mounted) {
      setState(() {
        if (masterData != null && masterData.status) {
          allAccountHeads = masterData.data.accountHead;
          staffs = masterData.data.staffList;
          filteredCategories = masterData.data.expenseType;
        }
        if (dateFilterMonths != null && dateFilterMonths > 0 && createdTo != null) {
          final minFrom = Common.subtractMonths(createdTo!, dateFilterMonths);
          if (createdFrom != null && (createdFrom!.isBefore(minFrom) || createdFrom!.isAfter(createdTo!))) {
            createdFrom = minFrom;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 7, offset: const Offset(0, -3))],
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E3A59)),
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
      decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
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
    final categories = [ 'Category', 'From Account', 'To Account','Transaction Date', 'Created By'];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories
            .map((title) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _buildFilterCategory(
                    title,
                    title == 'Transaction Date' ? Icons.date_range : Icons.account_circle,
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
      onTap: () {
        _searchController.clear();
        setState(() => selectedCategory = title);
      },
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
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
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
      case 'Category':
        return selectedCategoryIds.isNotEmpty;
      case 'From Account':
        return selectedFromAccountHeadIds.isNotEmpty;
      case 'To Account':
        return selectedToAccountHeadIds.isNotEmpty;
      case 'Transaction Date':
        return createdFrom != null || createdTo != null;
      case 'Created By':
        return selectedCreatedByIds.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildFilterOptionsPanel() {
    switch (selectedCategory) {
      case 'Transaction Date':
        return Column(
          children: [
            _buildDateField("From", createdFrom, true, (d) => setState(() => createdFrom = d)),
            const SizedBox(height: 18),
            _buildDateField("To", createdTo, false, (d) => setState(() => createdTo = d)),
          ],
        );

      case 'Created By':
        return _buildSearchableCheckboxList<StaffList>(
          items: staffs,
          getId: (item) => item.userId,
          getLabel: (item) => item.staffName,
          selectedIds: selectedCreatedByIds,
          hintText: "Search Staff",
        );

      case 'Category':
        return _buildSearchableCheckboxList<ExpenseType>(
          items: filteredCategories,
          getId: (item) => item.expCatId,
          getLabel: (item) => item.expCatName,
          selectedIds: selectedCategoryIds,
          hintText: "Search Category",
        );

      case 'From Account':
        return _buildSearchableCheckboxList<AccountHead>(
          items: allAccountHeads,
          getId: (item) => item.accountId,
          getLabel: (item) => item.accountName,
          selectedIds: selectedFromAccountHeadIds,
          hintText: "Search Account Head",
        );

      case 'To Account':
        return _buildSearchableCheckboxList<AccountHead>(
          items: allAccountHeads,
          getId: (item) => item.accountId,
          getLabel: (item) => item.accountName,
          selectedIds: selectedToAccountHeadIds,
          hintText: "Search Account Head",
        );

      default:
        return const Text("Coming soon...");
    }
  }

  Widget _buildSearchableCheckboxList<T>({
    required List<T> items,
    required String Function(T) getId,
    required String Function(T) getLabel,
    required Set<String> selectedIds,
    required String hintText,
  }) {
    final filteredItems = items.where((item) {
      final term = _searchController.text.toLowerCase();
      return getLabel(item).toLowerCase().contains(term);
    }).toList();

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC5CEE0)), borderRadius: BorderRadius.circular(8)),
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final id = getId(item);
              final label = getLabel(item);
              final isSelected = selectedIds.contains(id);

              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
                visualDensity: VisualDensity.compact,
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedIds.add(id);
                    } else {
                      selectedIds.remove(id);
                    }
                  });
                },
                title: Text(label, style: const TextStyle(fontSize: 13)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? value, bool isFrom, Function(DateTime) onSelect) {
    final display = value != null ? _formatter.format(value) : 'Select';
    return GestureDetector(
      onTap: () async {
        final dateFilterMonths = await Common.getDateFilter();
        final DateTime now = DateTime.now();

        DateTime firstDate;
        DateTime lastDate;
        DateTime initialDate;

        if (isFrom) {
          if (createdTo != null) {
            lastDate = createdTo!;
            if (dateFilterMonths != null && dateFilterMonths > 0) {
              firstDate = Common.subtractMonths(createdTo!, dateFilterMonths);
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
          if (createdFrom != null) {
            firstDate = createdFrom!;
            if (dateFilterMonths != null && dateFilterMonths > 0) {
              lastDate = Common.addMonths(createdFrom!, dateFilterMonths);
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

        if (picked != null) {
          if (isFrom) {
            setState(() {
              createdFrom = picked;
              if (dateFilterMonths != null && dateFilterMonths > 0) {
                final maxTo = Common.addMonths(picked, dateFilterMonths);
                if (createdTo != null &&
                    (createdTo!.isBefore(picked) || createdTo!.isAfter(maxTo))) {
                  createdTo = null; // Clear/reset To date if invalid
                }
              } else if (createdTo != null && createdTo!.isBefore(picked)) {
                createdTo = null;
              }
            });
            onSelect(picked);
          } else {
            setState(() {
              createdTo = picked;
              if (dateFilterMonths != null && dateFilterMonths > 0) {
                final minFrom = Common.subtractMonths(picked, dateFilterMonths);
                if (createdFrom != null &&
                    (createdFrom!.isBefore(minFrom) || createdFrom!.isAfter(picked))) {
                  createdFrom = null; // Clear/reset From date if invalid
                }
              } else if (createdFrom != null && createdFrom!.isAfter(picked)) {
                createdFrom = null;
              }
            });
            onSelect(picked);
          }
        }
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Color(0xFF3366FF)),
          const SizedBox(width: 8),
          Text('$label: $display', style: const TextStyle(fontSize: 14, color: Color(0xFF2E3A59))),
        ],
      ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'created_from': createdFrom?.toIso8601String(),
      'created_to': createdTo?.toIso8601String(),
      'from_account_head_ids': selectedFromAccountHeadIds.toList(),
      'to_account_head_ids': selectedToAccountHeadIds.toList(),
      'category_ids': selectedCategoryIds.toList(),
      'created_by_ids': selectedCreatedByIds.toList(),
    });
    Navigator.pop(context);
  }
}
