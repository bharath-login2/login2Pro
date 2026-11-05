import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/serviceman/customerModel.dart';
import 'package:login2/models/serviceman/customerTypeModel.dart';
import 'package:login2/models/serviceman/receivedThroughModel.dart';
import 'package:login2/models/serviceman/staffModel.dart';
import 'package:login2/models/serviceman/workCategoryModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/core/common.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/add_new_customer_dialog.dart';
import 'package:login2/widgets/quick_add_single_field_dialog.dart';

class CreateNewJobPage extends StatefulWidget {
  const CreateNewJobPage({Key? key}) : super(key: key);

  @override
  State<CreateNewJobPage> createState() => _CreateNewJobPageState();
}

class _CreateNewJobPageState extends State<CreateNewJobPage> {
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Theme constants â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Color _primary = Color(0xFF2a86c9);
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _card = Colors.white;
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _fill = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _problemDescController = TextEditingController();
  final TextEditingController _remarksCustomerController =
      TextEditingController();
  final TextEditingController _serviceChargeController =
      TextEditingController();
  final TextEditingController _dealerCustomerController =
      TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // Selected values
  String? _selectedCustomerId;
  String? _selectedCustomerType;
  String? _selectedPriority;
  String? _selectedProduct;
  String? _selectedCategory;
  String? _selectedServiceMan;
  String? _selectedServiceType;
  String? _selectedJobType;
  String? _selectedReceivedThrough;
  String? _selectedAccessory;
  String? _selectedServiceOption;
  String? _selectedStatus = "New";
  bool _isMoreDetailsExpanded = false;
  bool _loadFailed = false;
  bool _customerError = false;
  DateTime? _preferredDate;
  DateTime? _estimatedDate;
  final List<File> _productImages = [];
  final List<File> _warrantyImages = [];
  final ImagePicker _picker = ImagePicker();

  // Models
  CustomerModelService? customerModel;
  CustomerTypeModel? custTypeModel;
  StaffsModel? staffModel;
  WorkTypeModel? workType;
  WorkCategory? workCategory;
  ReceivedThroughModel? receivedOne;

  bool _whatsappNotify = true;
  bool _pushNotify = false;
  Set<String> _mandatoryFieldKeys = {};

  bool _isMandatory(String key) => _mandatoryFieldKeys.contains(key);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _serialController.dispose();
    _brandController.dispose();
    _problemDescController.dispose();
    _remarksCustomerController.dispose();
    _serviceChargeController.dispose();
    _dealerCustomerController.dispose();
    _userPasswordController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchMandatoryFields() async {
    try {
      final keys = await HttpService.getServiceMandatoryFields();
      if (mounted) {
        setState(() {
          _mandatoryFieldKeys = keys;
        });
      } else {
        _mandatoryFieldKeys = keys;
      }
    } catch (e) {
      debugPrint("Error fetching service mandatory fields: $e");
    }
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _loadFailed = false);
    try {
      final mandatoryFuture = _fetchMandatoryFields();
      customerModel = await HttpService().getCustomerListService();
      custTypeModel = await HttpService().getCustomerType();
      staffModel = await HttpService().getStaffName();
      workType = await HttpService().getWorkType();
      workCategory = await HttpService().getWorkCategory();
      receivedOne = await HttpService().getReceivedThrough();
      await mandatoryFuture;
    } catch (e) {
      debugPrint("Error loading data: $e");
      _loadFailed = true;
    }
    if (mounted) setState(() {});
  }

  bool get _isLoading =>
      customerModel == null ||
      custTypeModel == null ||
      staffModel == null ||
      workType == null ||
      workCategory == null ||
      receivedOne == null;

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _pickDateTime(BuildContext context, bool isPreferred) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isPreferred
          ? (_preferredDate ?? DateTime.now())
          : (_estimatedDate ?? DateTime.now()),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isPreferred
            ? (_preferredDate ?? DateTime.now())
            : (_estimatedDate ?? DateTime.now())),
      );
      if (pickedTime != null) {
        setState(() {
          final fullDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isPreferred) {
            _preferredDate = fullDateTime;
          } else {
            _estimatedDate = fullDateTime;
          }
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String? get _selectedCustomerName {
    if (_selectedCustomerId == null || customerModel == null) return null;
    for (final c in customerModel!.data) {
      if (c.id.toString() == _selectedCustomerId) return c.name;
    }
    return null;
  }

  bool _isQuickAddSuccess(dynamic response) {
    if (response == null) return false;
    final status = response['status'];
    return status == true ||
        status == 'true' ||
        status == 200 ||
        status == '200' ||
        status == 'success';
  }

  String _quickAddMessage(dynamic response, String fallback) {
    if (response != null &&
        response['message'] != null &&
        response['message'].toString().isNotEmpty) {
      return response['message'].toString();
    }
    return fallback;
  }

  String _extractNewId(dynamic response, String key) {
    String newId = '';
    if (response['data'] is Map) {
      newId = response['data'][key]?.toString() ??
          response['data']['id']?.toString() ??
          '';
    } else if (response['data'] != null &&
        response['data'].toString().isNotEmpty &&
        response['data'].toString() != 'null') {
      newId = response['data'].toString();
    }
    if (newId.isEmpty && response[key] != null) {
      newId = response[key].toString();
    }
    if (newId.isEmpty && response['id'] != null) {
      newId = response['id'].toString();
    }
    return newId;
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Customer picker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _showCustomerPicker() async {
    final CustomerDetails? selected = await showDialog<CustomerDetails>(
      context: context,
      builder: (context) {
        List<CustomerDetails> filteredList = customerModel?.data ?? [];
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Customer',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded,
                      color: _primary),
                  tooltip: 'Add New Customer',
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _openAddNewCustomerPopup();
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration:
                      _decoration('Search by name', icon: Icons.search_rounded),
                  onChanged: (value) {
                    final searchText = value.toLowerCase();
                    setState(() {
                      filteredList = customerModel!.data
                          .where(
                              (c) => c.name.toLowerCase().contains(searchText))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: filteredList.isEmpty
                      ? const Center(
                          child: Text('No customers found',
                              style: TextStyle(color: _textMuted)),
                        )
                      : ListView.separated(
                          itemCount: filteredList.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: _border),
                          itemBuilder: (context, index) {
                            final c = filteredList[index];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: _primary.withOpacity(0.12),
                                child: Text(
                                  c.name.isNotEmpty
                                      ? c.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              title: Text(c.name),
                              subtitle: c.contactNo.toString().isNotEmpty
                                  ? Text(c.contactNo.toString())
                                  : null,
                              onTap: () => Navigator.of(context).pop(c),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _customerError = false;
        _selectedCustomerId = selected.id;
        _phoneController.text = selected.contactNo;
        _addressController.text = selected.address;
        _emailController.text = selected.emailId;
      });
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Accessories picker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<String> _parseAccessories() {
    if (_selectedAccessory == null || _selectedAccessory!.isEmpty) return [];
    final cleaned = _selectedAccessory!.replaceAll('"', '').replaceAll("'", '');
    return cleaned
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _openAccessoriesDialog() async {
    final List<String> accessorySuggestions = [
      "Battery",
      "Charger",
      "Display",
      "Mouse",
    ];
    final List<String> selectedAccessories = _parseAccessories();

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(selectedAccessories);
        final TextEditingController customController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Select Accessories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customController,
                            decoration: _decoration('Add custom accessory'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: _primary,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              final newAccessory = customController.text.trim();
                              if (newAccessory.isNotEmpty &&
                                  !tempSelected.contains(newAccessory)) {
                                tempSelected.add(newAccessory);
                                customController.clear();
                                setState(() {});
                              }
                            },
                            child: const SizedBox(
                              height: 48,
                              width: 48,
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (tempSelected.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Selected',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: _textDark)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: tempSelected.map((accessory) {
                          return Chip(
                            label: Text(accessory),
                            backgroundColor: _primary.withOpacity(0.1),
                            side: BorderSide.none,
                            deleteIconColor: _primary,
                            onDeleted: () {
                              tempSelected.remove(accessory);
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const Divider(height: 24),
                    const Text('Suggestions',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: _textDark)),
                    ...accessorySuggestions.map((accessory) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: _primary,
                        title: Text(accessory),
                        value: tempSelected.contains(accessory),
                        onChanged: (value) {
                          if (value == true) {
                            if (!tempSelected.contains(accessory)) {
                              tempSelected.add(accessory);
                            }
                          } else {
                            tempSelected.remove(accessory);
                          }
                          setState(() {});
                        },
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context, tempSelected),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedAccessory = result.join(', ');
      });
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Quick-add popups â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _openAddNewCustomerPopup() async {
    final CustomerDetails? newCustomer = await showDialog<CustomerDetails>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddNewCustomerDialog(),
    );

    if (newCustomer != null) {
      try {
        final refreshedModel = await HttpService().getCustomerListService();
        if (refreshedModel != null && refreshedModel.data.isNotEmpty) {
          customerModel = refreshedModel;
        }
      } catch (e) {
        debugPrint("Error refreshing customer list: $e");
      }

      customerModel ??= CustomerModelService(status: "true", data: []);

      CustomerDetails? matchedCustomer;
      if (newCustomer.id.isNotEmpty) {
        try {
          matchedCustomer = customerModel!.data.firstWhere(
            (c) => c.id.toString() == newCustomer.id.toString(),
          );
        } catch (_) {}
      }

      if (matchedCustomer == null && newCustomer.name.isNotEmpty) {
        try {
          matchedCustomer = customerModel!.data.lastWhere(
            (c) =>
                c.name.trim().toLowerCase() ==
                newCustomer.name.trim().toLowerCase(),
          );
        } catch (_) {}
      }

      if (matchedCustomer == null) {
        customerModel!.data.add(newCustomer);
        matchedCustomer = newCustomer;
      }

      setState(() {
        _customerError = false;
        _selectedCustomerId = matchedCustomer!.id;
        _phoneController.text = matchedCustomer.contactNo;
        _addressController.text = matchedCustomer.address;
        _emailController.text = matchedCustomer.emailId;
      });
    }
  }

  Future<void> _openAddNewCustomerTypePopup() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickAddSingleFieldDialog(
        title: "Add New Customer Type",
        fieldLabel: "Customer Type",
        hintText: "",
        onSubmit: (value) async {
          final token = await Common.getSharedPref("token") ?? '';
          final formData = FormData.fromMap({
            "token": token,
            "customer_type": value,
            "name": value,
          });

          final response = await HttpService.postQuickCustomerType(formData);

          if (!_isQuickAddSuccess(response)) {
            Common.toastMessaage(
              response?['message']?.toString() ?? 'Failed to add customer type',
              Colors.red,
            );
            return false;
          }

          final message =
              _quickAddMessage(response, "Customer type added successfully");
          final newId = _extractNewId(response, 'customer_type_id');

          try {
            final refreshed = await HttpService().getCustomerType();
            if (refreshed != null && refreshed.data.isNotEmpty) {
              custTypeModel = refreshed;
            }
          } catch (e) {
            debugPrint("Error refreshing customer type: $e");
          }

          custTypeModel ??= CustomerTypeModel(status: "true", data: []);

          CustType? matched;
          if (newId.isNotEmpty) {
            try {
              matched = custTypeModel!.data.firstWhere(
                (c) => c.customerTypeId.toString() == newId.toString(),
              );
            } catch (_) {}
          }

          if (matched == null) {
            try {
              matched = custTypeModel!.data.lastWhere(
                (c) =>
                    c.customerType.trim().toLowerCase() ==
                    value.trim().toLowerCase(),
              );
            } catch (_) {}
          }

          if (matched == null) {
            matched = CustType(
              customerTypeId: newId.isNotEmpty
                  ? newId
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              customerType: value,
            );
            custTypeModel!.data.add(matched);
          }

          setState(() {
            _selectedCustomerType = matched!.customerTypeId;
          });

          Common.toastMessaage(message, Colors.green);
          return true;
        },
      ),
    );
  }

  Future<void> _openAddNewWorkCategoryPopup() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickAddSingleFieldDialog(
        title: "Add New Issue Type",
        fieldLabel: "Issue Type",
        hintText: "Issue Type",
        onSubmit: (value) async {
          final token = await Common.getSharedPref("token") ?? '';
          final formData = FormData.fromMap({
            "token": token,
            "work_category": value,
            "name": value,
          });

          final response = await HttpService.postQuickWorkCategory(formData);

          if (!_isQuickAddSuccess(response)) {
            Common.toastMessaage(
              response?['message']?.toString() ?? 'Failed to add Issue Type',
              Colors.red,
            );
            return false;
          }

          final message =
              _quickAddMessage(response, "Issue Type added successfully");
          final newId = _extractNewId(response, 'workCategory_id');

          try {
            final refreshed = await HttpService().getWorkCategory();
            if (refreshed != null && refreshed.data.isNotEmpty) {
              workCategory = refreshed;
            }
          } catch (e) {
            debugPrint("Error refreshing Issue Type: $e");
          }

          workCategory ??= WorkCategory(status: "true", data: []);

          Datum? matched;
          if (newId.isNotEmpty) {
            try {
              matched = workCategory!.data.firstWhere(
                (c) => c.workCategoryId.toString() == newId.toString(),
              );
            } catch (_) {}
          }

          if (matched == null) {
            try {
              matched = workCategory!.data.lastWhere(
                (c) =>
                    c.workCategory.trim().toLowerCase() ==
                    value.trim().toLowerCase(),
              );
            } catch (_) {}
          }

          if (matched == null) {
            matched = Datum(
              workCategoryId: newId.isNotEmpty
                  ? newId
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              workCategory: value,
            );
            workCategory!.data.add(matched);
          }

          setState(() {
            _selectedCategory = matched!.workCategory;
          });

          Common.toastMessaage(message, Colors.green);
          return true;
        },
      ),
    );
  }

  Future<void> _openAddNewReceivedThroughPopup() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickAddSingleFieldDialog(
        title: "Add New Received Through",
        fieldLabel: "Received Through",
        hintText: "Received Through",
        onSubmit: (value) async {
          final token = await Common.getSharedPref("token") ?? '';
          final formData = FormData.fromMap({
            "token": token,
            "received_through": value,
            "name": value,
          });

          final response = await HttpService.postQuickReceivedThrough(formData);

          if (!_isQuickAddSuccess(response)) {
            Common.toastMessaage(
              response?['message']?.toString() ??
                  'Failed to add received through',
              Colors.red,
            );
            return false;
          }

          final message =
              _quickAddMessage(response, "Received through added successfully");
          final newId = _extractNewId(response, 'recieved_tru_id');

          try {
            final refreshed = await HttpService().getReceivedThrough();
            if (refreshed != null && refreshed.data.isNotEmpty) {
              receivedOne = refreshed;
            }
          } catch (e) {
            debugPrint("Error refreshing received through: $e");
          }

          receivedOne ??= ReceivedThroughModel(status: "true", data: []);

          ReceivedThrough? matched;
          if (newId.isNotEmpty) {
            try {
              matched = receivedOne!.data.firstWhere(
                (c) => c.recievedTruId.toString() == newId.toString(),
              );
            } catch (_) {}
          }

          if (matched == null) {
            try {
              matched = receivedOne!.data.lastWhere(
                (c) =>
                    c.recievedThrough.trim().toLowerCase() ==
                    value.trim().toLowerCase(),
              );
            } catch (_) {}
          }

          if (matched == null) {
            matched = ReceivedThrough(
              recievedTruId: newId.isNotEmpty
                  ? newId
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              recievedThrough: value,
            );
            receivedOne!.data.add(matched);
          }

          setState(() {
            _selectedReceivedThrough = matched!.recievedTruId;
          });

          Common.toastMessaage(message, Colors.green);
          return true;
        },
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Submit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _submit() async {
    // 1. Check if any mandatory field is missing/invalid
    bool showMoreHasError = false;
    String? firstErrorMessage;

    if (_isMandatory("1") &&
        (_selectedProduct == null || _selectedProduct!.trim().isEmpty)) {
      firstErrorMessage ??= 'Please select Product';
    }
    if (_isMandatory("2") && _locationController.text.trim().isEmpty) {
      firstErrorMessage ??= 'Please enter Location';
    }
    if (_isMandatory("3") && _serialController.text.trim().isEmpty) {
      firstErrorMessage ??= 'Please enter Serial No / Model No';
    }
    if (_isMandatory("4") && _brandController.text.trim().isEmpty) {
      firstErrorMessage ??= 'Please enter Brand';
    }
    if (_isMandatory("5") &&
        (_selectedCategory == null || _selectedCategory!.trim().isEmpty)) {
      firstErrorMessage ??= 'Please select Issue Type';
    }
    if (_isMandatory("6") && _problemDescController.text.trim().isEmpty) {
      firstErrorMessage ??= 'Please enter Problem Description';
    }

    // Check collapsible (Show more) mandatory fields
    if (_isMandatory("7") &&
        (_selectedCustomerType == null ||
            _selectedCustomerType!.trim().isEmpty)) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Customer Type';
    }
    if (_isMandatory("8") && _emailController.text.trim().isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please enter Email';
    }
    if (_isMandatory("9") && _addressController.text.trim().isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please enter Address';
    }
    if (_isMandatory("10") &&
        _remarksCustomerController.text.trim().isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please enter Remarks About Customer';
    }
    if (_isMandatory("11") && _preferredDate == null) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Preferred Date';
    }
    if (_isMandatory("12") && _estimatedDate == null) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Estimated Date';
    }
    if (_isMandatory("13") &&
        (_selectedServiceMan == null || _selectedServiceMan!.trim().isEmpty)) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Assigned Staff';
    }
    if (_isMandatory("14") &&
        (_selectedStatus == null || _selectedStatus!.trim().isEmpty)) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Status';
    }
    if (_isMandatory("15") &&
        (_selectedServiceType == null ||
            _selectedServiceType!.trim().isEmpty)) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Service Type';
    }
    if (_isMandatory("16") &&
        (_selectedJobType == null || _selectedJobType!.trim().isEmpty)) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Job Type';
    }
    if (_isMandatory("17") && _dealerCustomerController.text.trim().isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please enter Dealer / Customer';
    }
    if (_isMandatory("18") && _userPasswordController.text.trim().isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please enter User Password';
    }
    if (_isMandatory("19") &&
        (_selectedReceivedThrough == null ||
            _selectedReceivedThrough!.trim().isEmpty)) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Received Through';
    }
    if (_isMandatory("20") && _remarksController.text.trim().isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please enter Remarks From Customer';
    }
    if (_isMandatory("21") &&
        (_selectedAccessory == null ||
            _selectedAccessory!.trim().isEmpty ||
            _parseAccessories().isEmpty)) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please select Other Accessories';
    }
    if (_isMandatory("22") && _productImages.isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please upload Product Images';
    }
    if (_isMandatory("23") && _warrantyImages.isEmpty) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please upload Warranty Images';
    }

    if (showMoreHasError && !_isMoreDetailsExpanded) {
      setState(() {
        _isMoreDetailsExpanded = true;
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final bool formOk = _formKey.currentState?.validate() ?? false;
    final bool customerMissing =
        _selectedCustomerId == null || _selectedCustomerId!.isEmpty;
    setState(() => _customerError = customerMissing);

    bool nonFormOk = true;
    if (_isMandatory("11") && _preferredDate == null) nonFormOk = false;
    if (_isMandatory("12") && _estimatedDate == null) nonFormOk = false;
    if (_isMandatory("21") &&
        (_selectedAccessory == null ||
            _selectedAccessory!.trim().isEmpty ||
            _parseAccessories().isEmpty)) {
      nonFormOk = false;
    }
    if (_isMandatory("22") && _productImages.isEmpty) nonFormOk = false;
    if (_isMandatory("23") && _warrantyImages.isEmpty) nonFormOk = false;

    if (!formOk || customerMissing || !nonFormOk) {
      if (customerMissing) {
        _showError('Please select a customer');
      } else if (firstErrorMessage != null) {
        _showError(firstErrorMessage);
      } else {
        _showError('Please fill all mandatory fields');
      }
      return;
    }

    final Map<String, dynamic> body = {
      "customer_id": _selectedCustomerId,
      "customer_type": _selectedCustomerType,
      "priority": _selectedPriority,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "location": _locationController.text,
      "address": _addressController.text,
      "serial_no": _serialController.text,
      "brand": _brandController.text,
      "product": _selectedProduct,
      "work_category": _selectedCategory,
      "problem_description": _problemDescController.text,
      "preferred_date": _preferredDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_preferredDate!)
          : "",
      "estimated_date": _estimatedDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_estimatedDate!)
          : "",
      "assigned_service_man": _selectedServiceMan,
      "status": _selectedStatus,
      "remarks_customer": _remarksCustomerController.text,
      "service_option": _selectedServiceOption,
      "service_charge": _serviceChargeController.text,
      "remarks": _remarksController.text,
      "service_type": _selectedServiceType ?? "",
      "job_type": _selectedJobType,
      "dealer_customer": _dealerCustomerController.text,
      "user_password": _userPasswordController.text,
      "received_through": _selectedReceivedThrough,
      "accessory": _selectedAccessory,
      "notify_whatsapp": _whatsappNotify ? "1" : "0",
      "notify_push": _pushNotify ? "1" : "0",
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final FormData formData = FormData.fromMap(body);

      for (var file in _productImages) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'product_images[]',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      for (var file in _warrantyImages) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'warranty_images[]',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      var result = await HttpService().addWorkService(formData);
      if (!mounted) return;
      Navigator.of(context).pop();

      if (result != null && result["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('âœ… Job created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showError('âŒ Failed: ${result?["message"] ?? "Unknown error"}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showError('âš ï¸ Error: $e');
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Create New Job',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _loadFailed
          ? _buildErrorState()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainSection(),
                          const SizedBox(height: 16),
                          _buildMoreDetailsToggle(),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            sizeCurve: Curves.easeInOut,
                            crossFadeState: _isMoreDetailsExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: _buildMoreDetailsContent(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar:
          (_loadFailed || _isLoading) ? null : _buildBottomBar(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: _textMuted),
            const SizedBox(height: 12),
            const Text('Could not load form data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submit,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Create Job',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Sections â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildMainSection() {
    return _sectionCard(
      title: 'Job Details',
      icon: Icons.assignment_outlined,
      children: [
        // Customer name picker + add button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSelectField(
                label: 'Customer Name',
                isRequired: true,
                icon: Icons.person_outline_rounded,
                valueText: _selectedCustomerName,
                placeholder: 'Tap to select customer',
                errorText: _customerError ? 'Please select a customer' : null,
                onTap: _showCustomerPicker,
              ),
            ),
            const SizedBox(width: 8),
            _addButton(_openAddNewCustomerPopup),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(
          _phoneController,
          "Mobile Number",
          isRequired: true,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            final v = (value ?? '').trim();
            if (v.isEmpty) return 'Required field';
            if (v.length < 10) return 'Enter a valid 10-digit number';
            return null;
          },
        ),
        _buildTextField(
          _locationController,
          "Location",
          icon: Icons.location_on_outlined,
          isRequired: _isMandatory("2"),
          validator: _isMandatory("2")
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter Location'
                  : null
              : null,
        ),
        _buildTextField(
          _serialController,
          "Serial No / Model No",
          icon: Icons.qr_code_2_rounded,
          isRequired: _isMandatory("3"),
          validator: _isMandatory("3")
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter Serial No / Model No'
                  : null
              : null,
        ),
        _buildTextField(
          _brandController,
          "Brand",
          icon: Icons.sell_outlined,
          isRequired: _isMandatory("4"),
          validator: _isMandatory("4")
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter Brand'
                  : null
              : null,
        ),
        _buildDropdown(
          "Product",
          _selectedProduct,
          workType!.data
              .map((e) => {"id": e.id, "name": e.productName})
              .toList(),
          (val) => setState(() => _selectedProduct = val),
          icon: Icons.devices_other_outlined,
          isRequired: _isMandatory("1"),
          validator: _isMandatory("1")
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'Please select Product'
                  : null
              : null,
        ),
        _buildDropdown(
          "Issue Type",
          _selectedCategory,
          workCategory!.data
              .map((e) => {"id": e.workCategory, "name": e.workCategory})
              .toList(),
          (val) => setState(() => _selectedCategory = val),
          icon: Icons.category_outlined,
          onAddPressed: _openAddNewWorkCategoryPopup,
          isRequired: _isMandatory("5"),
          validator: _isMandatory("5")
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'Please select Issue Type'
                  : null
              : null,
        ),
        _buildTextField(
          _problemDescController,
          "Problem Description",
          icon: Icons.report_problem_outlined,
          maxLines: 3,
          isLast: true,
          isRequired: _isMandatory("6"),
          validator: _isMandatory("6")
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter Problem Description'
                  : null
              : null,
        ),
      ],
    );
  }

  Widget _buildMoreDetailsToggle() {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () =>
            setState(() => _isMoreDetailsExpanded = !_isMoreDetailsExpanded),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isMoreDetailsExpanded
                    ? Icons.remove_rounded
                    : Icons.add_rounded,
                color: _primary,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                _isMoreDetailsExpanded ? 'Show less' : 'Show more',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Customer Info',
          icon: Icons.badge_outlined,
          children: [
            _buildDropdown(
              "Customer Type",
              _selectedCustomerType,
              custTypeModel!.data
                  .map((e) => {"id": e.customerTypeId, "name": e.customerType})
                  .toList(),
              (val) => setState(() => _selectedCustomerType = val),
              icon: Icons.groups_outlined,
              onAddPressed: _openAddNewCustomerTypePopup,
              isRequired: _isMandatory("7"),
              validator: _isMandatory("7")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please select Customer Type'
                      : null
                  : null,
            ),
            _buildTextField(
              _emailController,
              "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              isRequired: _isMandatory("8"),
              validator: _isMandatory("8")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter Email'
                      : null
                  : null,
            ),
            _buildTextField(
              _addressController,
              "Address",
              icon: Icons.home_outlined,
              maxLines: 2,
              isRequired: _isMandatory("9"),
              validator: _isMandatory("9")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter Address'
                      : null
                  : null,
            ),
            _buildDropdown(
              "Priority",
              _selectedPriority,
              ["High", "Medium", "Low", "Normal"]
                  .map((e) => {"id": e, "name": e})
                  .toList(),
              (val) => setState(() => _selectedPriority = val),
              icon: Icons.flag_outlined,
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Work Details',
          icon: Icons.build_circle_outlined,
          children: [
            _buildDateField(
              "Preferred Date",
              _preferredDate,
              () => _pickDateTime(context, true),
              onClear: () => setState(() => _preferredDate = null),
              isRequired: _isMandatory("11"),
            ),
            _buildDateField(
              "Estimated Date",
              _estimatedDate,
              () => _pickDateTime(context, false),
              onClear: () => setState(() => _estimatedDate = null),
              isRequired: _isMandatory("12"),
            ),
            _buildDropdown(
              "Assigned Staff",
              _selectedServiceMan,
              staffModel!.data
                  .map((e) => {"id": e.staffId, "name": e.staffName})
                  .toList(),
              (val) => setState(() => _selectedServiceMan = val),
              icon: Icons.engineering_outlined,
              isRequired: _isMandatory("13"),
              validator: _isMandatory("13")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please select Assigned Staff'
                      : null
                  : null,
            ),
            _buildDropdown(
              "Status",
              _selectedStatus ?? "New",
              ["New", "In Progress", "Completed"]
                  .map((s) => {"id": s, "name": s})
                  .toList(),
              (val) => setState(() => _selectedStatus = val),
              icon: Icons.timelapse_rounded,
              readOnly: true,
              isRequired: _isMandatory("14"),
              validator: _isMandatory("14")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please select Status'
                      : null
                  : null,
            ),
            _buildDropdown(
              "Service Type",
              _selectedServiceType,
              [
                {"id": "onsite", "name": "On-site Service"},
                {"id": "workshop", "name": "In-office / Workshop Service"},
              ],
              (val) => setState(() => _selectedServiceType = val),
              icon: Icons.home_repair_service_outlined,
              isRequired: _isMandatory("15"),
              validator: _isMandatory("15")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please select Service Type'
                      : null
                  : null,
            ),
            _buildDropdown(
              "Job Type",
              _selectedJobType,
              ["New", "Repeat"].map((t) => {"id": t, "name": t}).toList(),
              (val) => setState(() => _selectedJobType = val),
              icon: Icons.repeat_rounded,
              isLast: true,
              isRequired: _isMandatory("16"),
              validator: _isMandatory("16")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please select Job Type'
                      : null
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Additional Information',
          icon: Icons.notes_rounded,
          children: [
            _buildTextField(
              _remarksCustomerController,
              "Remarks About Customer",
              icon: Icons.comment_outlined,
              isRequired: _isMandatory("10"),
              validator: _isMandatory("10")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter Remarks About Customer'
                      : null
                  : null,
            ),
            _buildTextField(
              _remarksController,
              "Remarks From Customer",
              icon: Icons.description_outlined,
              maxLines: 2,
              isRequired: _isMandatory("20"),
              validator: _isMandatory("20")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter Remarks From Customer'
                      : null
                  : null,
            ),
            _buildTextField(
              _dealerCustomerController,
              "Dealer / Customer",
              icon: Icons.storefront_outlined,
              isRequired: _isMandatory("17"),
              validator: _isMandatory("17")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter Dealer / Customer'
                      : null
                  : null,
            ),
            _buildTextField(
              _userPasswordController,
              "User Password",
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              isRequired: _isMandatory("18"),
              validator: _isMandatory("18")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter User Password'
                      : null
                  : null,
            ),
            _buildDropdown(
              "Received Through",
              _selectedReceivedThrough,
              receivedOne!.data
                  .map(
                      (e) => {"id": e.recievedTruId, "name": e.recievedThrough})
                  .toList(),
              (val) => setState(() => _selectedReceivedThrough = val),
              icon: Icons.input_rounded,
              onAddPressed: _openAddNewReceivedThroughPopup,
              isRequired: _isMandatory("19"),
              validator: _isMandatory("19")
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Please select Received Through'
                      : null
                  : null,
            ),
            _buildAccessoriesField(
              isRequired: _isMandatory("21"),
            ),
            const SizedBox(height: 14),
            _buildImageUploadSection(
              title: "Product Images",
              icon: Icons.photo_library_outlined,
              files: _productImages,
              onPick: () => _pickImages(isProduct: true),
              onRemove: (index) => setState(() => _productImages.removeAt(index)),
              isRequired: _isMandatory("22"),
            ),
            const SizedBox(height: 14),
            _buildImageUploadSection(
              title: "Warranty Images",
              icon: Icons.verified_outlined,
              files: _warrantyImages,
              onPick: () => _pickImages(isProduct: false),
              onRemove: (index) => setState(() => _warrantyImages.removeAt(index)),
              isRequired: _isMandatory("23"),
            ),
          ],
        ),
      ],
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Reusable widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildFieldLabel(String labelText, bool isRequired) {
    final cleanLabel = labelText.endsWith(' *')
        ? labelText.substring(0, labelText.length - 2)
        : labelText;
    if (!isRequired) {
      return Text(cleanLabel);
    }
    return Text.rich(
      TextSpan(
        text: cleanLabel,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(
    String label, {
    IconData? icon,
    String? hint,
    String? errorText,
    bool alwaysFloat = false,
    bool isRequired = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      label: _buildFieldLabel(label, isRequired),
      hintText: hint,
      errorText: errorText,
      floatingLabelBehavior: alwaysFloat
          ? FloatingLabelBehavior.always
          : FloatingLabelBehavior.auto,
      hintStyle: const TextStyle(color: _textMuted, fontSize: 16),
      labelStyle: const TextStyle(color: _textMuted, fontSize: 14),
      floatingLabelStyle:
          const TextStyle(color: _primary, fontWeight: FontWeight.w600),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: _textMuted) : null,
      filled: true,
      fillColor: _fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: border(_border),
      enabledBorder: border(_border),
      focusedBorder: border(_primary, 1.6),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 1.6),
      disabledBorder: border(_border),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _addButton(VoidCallback onTap) {
    return Material(
      color: _primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          height: 56,
          width: 56,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isLast = false,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: _decoration(label, icon: icon, isRequired: isRequired),
        validator: validator,
        autovalidateMode: validator != null
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? selectedValue,
    List<Map<String, dynamic>> items,
    ValueChanged<String?>? onChanged, {
    IconData? icon,
    VoidCallback? onAddPressed,
    bool readOnly = false,
    bool isLast = false,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    final Widget dropdown = DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textMuted),
      borderRadius: BorderRadius.circular(12),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item["id"].toString(),
          child: Text(
            item["name"]?.toString() ?? "",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: readOnly ? null : onChanged,
      validator: validator,
      autovalidateMode: validator != null
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      decoration: _decoration(label, icon: icon, isRequired: isRequired),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: onAddPressed != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: dropdown),
                const SizedBox(width: 8),
                _addButton(onAddPressed),
              ],
            )
          : dropdown,
    );
  }

  /// Read-only, tap-to-open field (label always floats so it never
  /// overlaps the value / placeholder).
  Widget _buildSelectField({
    required String label,
    required IconData icon,
    required String? valueText,
    required String placeholder,
    required VoidCallback onTap,
    String? errorText,
    bool isRequired = false,
  }) {
    final bool hasValue = valueText != null && valueText.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _decoration(
          label,
          icon: icon,
          hint: placeholder,
          errorText: errorText,
          alwaysFloat: true,
          isRequired: isRequired,
        ).copyWith(
          suffixIcon:
              const Icon(Icons.keyboard_arrow_down_rounded, color: _textMuted),
        ),
        isEmpty: !hasValue,
        child: Text(
          hasValue ? valueText : '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, color: _textDark),
        ),
      ),
    );
  }

  Widget _buildAccessoriesField({bool isRequired = false}) {
    final accessories = _parseAccessories();
    return InkWell(
      onTap: _openAccessoriesDialog,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _decoration(
          "Other Accessories",
          icon: Icons.extension_outlined,
          hint: 'Tap to select accessories',
          alwaysFloat: true,
          isRequired: isRequired,
        ).copyWith(
          suffixIcon:
              const Icon(Icons.keyboard_arrow_down_rounded, color: _textMuted),
        ),
        isEmpty: accessories.isEmpty,
        child: accessories.isEmpty
            ? const Text('', style: TextStyle(fontSize: 16))
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                children: accessories
                    .map((a) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(a,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: _primary,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    VoidCallback onTap, {
    VoidCallback? onClear,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: _decoration(
            label,
            icon: Icons.event_outlined,
            hint: 'Select date and time',
            alwaysFloat: true,
            isRequired: isRequired,
          ).copyWith(
            suffixIcon: date != null && onClear != null
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: _textMuted),
                    onPressed: onClear,
                  )
                : const Icon(Icons.calendar_month_outlined,
                    size: 20, color: _textMuted),
          ),
          isEmpty: date == null,
          child: Text(
            date == null ? '' : DateFormat('dd MMM yyyy, hh:mm a').format(date),
            style: const TextStyle(fontSize: 16, color: _textDark),
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Image Upload Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _pickImages({required bool isProduct}) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload ${isProduct ? "Product" : "Warranty"} Images',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: _primary),
                title: const Text('Choose Multiple from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final List<XFile> picked = await _picker.pickMultiImage();
                    if (picked.isNotEmpty) {
                      setState(() {
                        final targetList =
                            isProduct ? _productImages : _warrantyImages;
                        for (var xFile in picked) {
                          if (!targetList.any((f) => f.path == xFile.path)) {
                            targetList.add(File(xFile.path));
                          }
                        }
                      });
                    }
                  } catch (e) {
                    debugPrint('Error picking images: $e');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: _primary),
                title: const Text('Take Photo from Camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? photo =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (photo != null) {
                      setState(() {
                        final targetList =
                            isProduct ? _productImages : _warrantyImages;
                        if (!targetList.any((f) => f.path == photo.path)) {
                          targetList.add(File(photo.path));
                        }
                      });
                    }
                  } catch (e) {
                    debugPrint('Error taking photo: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewImage({File? file, String? url, String? title}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topRight,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  child: file != null
                      ? Image.file(file, fit: BoxFit.contain)
                      : (url != null
                          ? Image.network(url, fit: BoxFit.contain)
                          : const SizedBox.shrink()),
                ),
              ),
            ),
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child:
                      const Icon(Icons.close, size: 20, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection({
    required String title,
    required IconData icon,
    required List<File> files,
    required VoidCallback onPick,
    required ValueChanged<int> onRemove,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: _primary),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                text: title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
                children: isRequired
                    ? const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                    : [],
              ),
            ),
            if (files.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${files.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _fill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined,
                    color: _primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  files.isNotEmpty ? "Add More $title" : "Upload $title",
                  style: const TextStyle(
                    fontSize: 14,
                    color: _primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: files.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => _previewImage(file: file, title: title),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: Colors.grey, size: 24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 3),
                          ],
                        ),
                        child:
                            const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
