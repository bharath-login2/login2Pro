import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/serviceman/customerModel.dart';
import 'package:login2/models/serviceman/customerTypeModel.dart';
import 'package:login2/models/serviceman/receivedThroughModel.dart';
import 'package:login2/models/serviceman/staffModel.dart';
import 'package:login2/models/serviceman/workCategoryModel.dart';
import 'package:login2/models/serviceman/workOrderIdModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login2/service/service.dart';
import 'package:login2/core/common.dart';
import 'package:login2/core/config.dart';

class WorkImageItem {
  final String? id;
  final String? fileId;
  final String viewUrl;
  final String thumbnailUrl;
  final String name;

  WorkImageItem({
    this.id,
    this.fileId,
    required this.viewUrl,
    required this.thumbnailUrl,
    required this.name,
  });
}

class EditWorkPage extends StatefulWidget {
  final String workOrderId;
  final String? initialServiceType;
  const EditWorkPage({
    super.key,
    required this.workOrderId,
    this.initialServiceType,
  });
  @override
  State<EditWorkPage> createState() => _EditWorkPageState();
}

class _EditWorkPageState extends State<EditWorkPage> {
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
  String? _selectedStatus;
  DateTime? _preferredDate;
  DateTime? _estimatedDate;
  List<WorkImageItem> _existingProductImages = [];
  List<WorkImageItem> _existingWarrantyImages = [];
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
  WorkOrderDetailsModel? _workDetails;
  WorkOrderData? _workData;

  bool _whatsappNotify = true;
  bool _pushNotify = false;
  bool _isLoading = true;
  bool _isMoreDetailsExpanded = false;
  bool _customerError = false;
  bool _isDeletingImage = false;
  String? _errorMessage;
  Set<String> _mandatoryFieldKeys = {};

  bool _isMandatory(String key) => _mandatoryFieldKeys.contains(key);

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

  String? _normalizeServiceType(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final lower = val.trim().toLowerCase();
    if (lower == 'onsite' ||
        lower.contains('onsite') ||
        lower.contains('on-site')) {
      return 'onsite';
    } else if (lower == 'workshop' ||
        lower.contains('workshop') ||
        lower.contains('office') ||
        lower.contains('in-office')) {
      return 'workshop';
    }
    return lower;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialServiceType != null &&
        widget.initialServiceType!.trim().isNotEmpty) {
      _selectedServiceType = _normalizeServiceType(widget.initialServiceType);
    }
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Data loading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final mandatoryFuture = _fetchMandatoryFields();
      final workDetails = await HttpService().getWorkEditDetails(
        widget.workOrderId,
      );
      if (workDetails != null && workDetails.status) {
        _workDetails = workDetails;
        _workData = workDetails.data;
      } else {
        throw Exception('Failed to load work details');
      }
      customerModel = await HttpService().getCustomerListService();
      custTypeModel = await HttpService().getCustomerType();
      staffModel = await HttpService().getStaffName();
      workType = await HttpService().getWorkType();
      workCategory = await HttpService().getWorkCategory();
      receivedOne = await HttpService().getReceivedThrough();
      _fillExistingData();
      await mandatoryFuture;
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fillExistingData() {
    if (_workData == null) return;
    final data = _workData!;
    _selectedCustomerId = data.customerName;
    _selectedCustomerType = data.customerType;
    _selectedPriority = data.priority;
    _selectedProduct = data.workType;
    _selectedCategory = data.workCategory;
    _selectedServiceMan = data.assignedServiceMan;
    _selectedStatus = data.status;
    final rawServiceType = data.serviceType.isNotEmpty
        ? data.serviceType
        : widget.initialServiceType;
    if (rawServiceType != null && rawServiceType.trim().isNotEmpty) {
      _selectedServiceType = _normalizeServiceType(rawServiceType);
    }
    _selectedJobType = data.jobType;
    _selectedReceivedThrough = data.receivedTru;
    _selectedAccessory = data.accessories;
    _phoneController.text = data.mobileNumber;
    _emailController.text = data.emailId;
    _addressController.text = data.address;
    _locationController.text = data.location;
    _serialController.text = data.serialNo;
    _brandController.text = data.brand;
    _problemDescController.text = data.issueDescription;
    _dealerCustomerController.text = data.dealerName;
    _userPasswordController.text = data.userPassword;
    _remarksController.text = data.remarks;
    _remarksCustomerController.text = data.problemReportedByCustomer;
    if (data.serviceOption.isNotEmpty) {
      _selectedServiceOption = data.serviceOption;
    }
    _serviceChargeController.text = data.serviceCharge;
    if (data.preferredDateTime.isNotEmpty) {
      _preferredDate = DateTime.tryParse(data.preferredDateTime);
    }
    if (data.estimatedDatetime.isNotEmpty) {
      _estimatedDate = DateTime.tryParse(data.estimatedDatetime);
    }

    final rawProd = _workDetails?.productImages ??
        _workDetails?.rawJson?["product_images"] ??
        _workDetails?.rawJson?["product_image"] ??
        data.productImages ??
        data.rawJson?["product_images"] ??
        data.rawJson?["product_image"];
    _existingProductImages = _parseWorkImages(rawProd);

    final rawWarr = _workDetails?.warrantyImages ??
        _workDetails?.rawJson?["warranty_images"] ??
        _workDetails?.rawJson?["warranty_image"] ??
        data.warrantyImages ??
        data.rawJson?["warranty_images"] ??
        data.rawJson?["warranty_image"];
    _existingWarrantyImages = _parseWorkImages(rawWarr);

    // Open "Show more" initially only if it already has data inside.
    _isMoreDetailsExpanded = _hasMoreDetailsData();
  }

  bool _hasText(String? v) => v != null && v.trim().isNotEmpty;

  /// True when any field inside "Show more" already has a value.
  /// (Product now sits above Show more. Status is skipped because it is always filled.)
  bool _hasMoreDetailsData() {
    return _hasText(_selectedCustomerType) ||
        _hasText(_emailController.text) ||
        _hasText(_addressController.text) ||
        _hasText(_selectedPriority) ||
        _preferredDate != null ||
        _estimatedDate != null ||
        _hasText(_selectedServiceMan) ||
        _hasText(_selectedServiceType) ||
        _hasText(_selectedJobType) ||
        _hasText(_remarksCustomerController.text) ||
        _hasText(_remarksController.text) ||
        _hasText(_dealerCustomerController.text) ||
        _hasText(_userPasswordController.text) ||
        _hasText(_selectedReceivedThrough) ||
        _hasText(_selectedAccessory);
  }

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
    final v = _selectedCustomerId;
    if (v == null || v.isEmpty || customerModel == null) return null;
    for (final c in customerModel!.data) {
      if (c.id.toString() == v) return c.name;
    }
    for (final c in customerModel!.data) {
      if (c.name.trim().toLowerCase() == v.trim().toLowerCase()) return c.name;
    }
    return int.tryParse(v) == null ? v : null;
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
            title: const Text('Select Customer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Update â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _updateWork() async {
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
    final bool hasProductImages =
        _existingProductImages.isNotEmpty || _productImages.isNotEmpty;
    if (_isMandatory("22") && !hasProductImages) {
      showMoreHasError = true;
      firstErrorMessage ??= 'Please upload Product Images';
    }
    final bool hasWarrantyImages =
        _existingWarrantyImages.isNotEmpty || _warrantyImages.isNotEmpty;
    if (_isMandatory("23") && !hasWarrantyImages) {
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
    if (_isMandatory("22") && !hasProductImages) nonFormOk = false;
    if (_isMandatory("23") && !hasWarrantyImages) nonFormOk = false;

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final Map<String, dynamic> body = {
        "WorkOrderID": widget.workOrderId,
        "editcustomername": _selectedCustomerId,
        "editcustomer_type": _selectedCustomerType,
        "editpriority": _selectedPriority ?? "Normal",
        "editphone": _phoneController.text,
        "editemail_id": _emailController.text,
        "editlocation": _locationController.text,
        "editaddress": _addressController.text,
        "editserial_no": _serialController.text,
        "editbrand": _brandController.text,
        "editwork_type": _selectedProduct,
        "Editwork_category": _selectedCategory,
        "editproblem_reported": _problemDescController.text,
        "preferred_datetime": _preferredDate != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_preferredDate!)
            : "",
        "editestimated_datetime": _estimatedDate != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_estimatedDate!)
            : "",
        "editservice_man": _selectedServiceMan,
        "editStatus": _selectedStatus ?? "New",
        "remarks_customer": _remarksCustomerController.text,
        "editservice_option": _selectedServiceOption,
        "service_option": _selectedServiceOption,
        "editservice_type": _selectedServiceType,
        "service_type": _selectedServiceType,
        "editservice_charge": _serviceChargeController.text,
        "service_charge": _serviceChargeController.text,
        "editDescription": _remarksController.text,
        "editjob_type": _selectedJobType ?? "New",
        "editdealer_name": _dealerCustomerController.text,
        "edituser_password": _userPasswordController.text,
        "editreceived_through": _selectedReceivedThrough,
        "editaccessories": _selectedAccessory,
        "notify_whatsapp": _whatsappNotify ? "1" : "0",
        "notify_push": _pushNotify ? "1" : "0",
      };

      body.removeWhere((key, value) => value == null || value == '');

      final FormData formData = FormData.fromMap(body);

      // Preserve existing product images
      final existingProdUrls =
          _existingProductImages.map((e) => e.viewUrl).toList();
      formData.fields.add(
          MapEntry('existing_product_images', jsonEncode(existingProdUrls)));
      formData.fields.add(
          MapEntry('existing_product_images_list', existingProdUrls.join(',')));
      final existingProdIds = _existingProductImages
          .map((e) => e.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();
      if (existingProdIds.isNotEmpty) {
        formData.fields.add(
            MapEntry('existing_product_image_ids', jsonEncode(existingProdIds)));
      }
      for (var id in existingProdIds) {
        formData.fields.add(MapEntry('existing_product_image_ids[]', id));
      }
      for (var url in existingProdUrls) {
        formData.fields.add(MapEntry('existing_product_images[]', url));
      }

      // Preserve existing warranty images
      final existingWarrUrls =
          _existingWarrantyImages.map((e) => e.viewUrl).toList();
      formData.fields.add(
          MapEntry('existing_warranty_images', jsonEncode(existingWarrUrls)));
      formData.fields.add(MapEntry(
          'existing_warranty_images_list', existingWarrUrls.join(',')));
      final existingWarrIds = _existingWarrantyImages
          .map((e) => e.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();
      if (existingWarrIds.isNotEmpty) {
        formData.fields.add(
            MapEntry('existing_warranty_image_ids', jsonEncode(existingWarrIds)));
      }
      for (var id in existingWarrIds) {
        formData.fields.add(MapEntry('existing_warranty_image_ids[]', id));
      }
      for (var url in existingWarrUrls) {
        formData.fields.add(MapEntry('existing_warranty_images[]', url));
      }

      // New product images
      for (var file in _productImages) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'product_images[]',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      // New warranty images
      for (var file in _warrantyImages) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'warranty_images[]',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      final result = await HttpService().updateWorkService(formData);

      if (!mounted) return;
      Navigator.of(context).pop(); // close progress dialog

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Work order updated successfully",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showError("Failed to update work order");
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
        title: const Text('Edit Work',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
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
          (_isLoading || _errorMessage != null) ? null : _buildBottomBar(),
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
            Text(
              _errorMessage ?? 'Could not load data',
              style: const TextStyle(color: Colors.red, fontSize: 15),
              textAlign: TextAlign.center,
            ),
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
              onPressed: _updateWork,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Update Work',
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
        _buildSelectField(
          label: 'Customer Name',
          isRequired: true,
          icon: Icons.person_outline_rounded,
          valueText: _selectedCustomerName,
          placeholder: 'Tap to select customer',
          errorText: _customerError ? 'Please select a customer' : null,
          onTap: _showCustomerPicker,
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
            _buildServiceManDropdown(isRequired: _isMandatory("13")),
            _buildDropdown(
              "Status",
              _selectedStatus,
              ["New", "In Progress", "Completed", "On Hold", "Cancelled"]
                  .map((s) => {"id": s, "name": s})
                  .toList(),
              (val) => setState(() => _selectedStatus = val),
              icon: Icons.timelapse_rounded,
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
            _buildEditImageUploadSection(
              title: "Product Images",
              icon: Icons.photo_library_outlined,
              existingImages: _existingProductImages,
              newFiles: _productImages,
              onPick: () => _pickImages(isProduct: true),
              onRemoveExisting: (index) => _handleDeleteExistingImage(
                isProduct: true,
                index: index,
              ),
              onRemoveNew: (index) => _handleDeleteNewImage(
                isProduct: true,
                index: index,
              ),
              isRequired: _isMandatory("22"),
            ),
            const SizedBox(height: 14),
            _buildEditImageUploadSection(
              title: "Warranty Images",
              icon: Icons.verified_outlined,
              existingImages: _existingWarrantyImages,
              newFiles: _warrantyImages,
              onPick: () => _pickImages(isProduct: false),
              onRemoveExisting: (index) => _handleDeleteExistingImage(
                isProduct: false,
                index: index,
              ),
              onRemoveNew: (index) => _handleDeleteNewImage(
                isProduct: false,
                index: index,
              ),
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
    ValueChanged<String?> onChanged, {
    IconData? icon,
    bool isLast = false,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    // De-duplicate by id and make sure the current value exists in the list.
    final uniqueItems = <String, Map<String, dynamic>>{};
    for (final item in items) {
      final id = item["id"].toString();
      if (!uniqueItems.containsKey(id)) {
        uniqueItems[id] = item;
      }
    }
    final deduplicatedItems = uniqueItems.values.toList();
    final bool valueExists = deduplicatedItems.any(
      (item) => item["id"].toString() == selectedValue,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: DropdownButtonFormField<String>(
        value: valueExists ? selectedValue : null,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textMuted),
        borderRadius: BorderRadius.circular(12),
        items: deduplicatedItems.map((item) {
          return DropdownMenuItem<String>(
            value: item["id"].toString(),
            child: Text(
              item["name"]?.toString() ?? "",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        autovalidateMode: validator != null
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        decoration: _decoration(label, icon: icon, isRequired: isRequired),
      ),
    );
  }

  Widget _buildServiceManDropdown({bool isRequired = false}) {
    final staffMap = <String, String>{};
    final List<Map<String, dynamic>> uniqueStaffItems = [];
    for (final staff in staffModel!.data) {
      final staffName = staff.staffName;
      final staffId = staff.staffId;
      if (!staffMap.containsKey(staffName)) {
        staffMap[staffName] = staffId;
        uniqueStaffItems.add({"id": staffId, "name": staffName});
      }
    }

    String? resolvedValue;
    if (_selectedServiceMan != null) {
      resolvedValue = uniqueStaffItems
          .firstWhere(
            (item) => item["id"] == _selectedServiceMan,
            orElse: () => {"id": "", "name": ""},
          )["id"]
          .toString();
      if (resolvedValue.isEmpty) {
        final foundItem = uniqueStaffItems.firstWhere(
          (item) => item["name"] == _selectedServiceMan,
          orElse: () => {"id": "", "name": ""},
        );
        resolvedValue = foundItem["id"].toString();
      }
    }

    return _buildDropdown(
      "Assigned Staff",
      resolvedValue?.isNotEmpty == true ? resolvedValue : null,
      uniqueStaffItems,
      (val) => setState(() => _selectedServiceMan = val),
      icon: Icons.engineering_outlined,
      isRequired: isRequired,
      validator: isRequired
          ? (v) => (v == null || v.trim().isEmpty)
              ? 'Please select Assigned Staff'
              : null
          : null,
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Image Upload & Preview Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<WorkImageItem> _parseWorkImages(dynamic raw) {
    if (raw == null) return [];
    List<WorkImageItem> items = [];
    if (raw is List) {
      for (var item in raw) {
        if (item is Map) {
          final id = (item['id'] ?? item['image_id'] ?? item['document_id'])
              ?.toString();
          final fileId = (item['file_id'] ?? item['fileId'])?.toString();
          final viewUrl = (item['view_url'] ??
                  item['file_url'] ??
                  item['preview_url'] ??
                  item['image_url'] ??
                  item['image'] ??
                  item['url'] ??
                  item['path'])
              ?.toString() ??
              '';
          final thumbnailUrl = (item['thumbnail_url'] ??
                  item['thumb_url'] ??
                  item['thumbnail'] ??
                  item['preview_url'] ??
                  viewUrl)
              ?.toString() ??
              '';
          final name = (item['file_name'] ??
                  item['image_name'] ??
                  item['name'])
              ?.toString() ??
              (thumbnailUrl.isNotEmpty
                  ? thumbnailUrl.split('/').last.split('\\').last
                  : 'Image');
          if (viewUrl.isNotEmpty || thumbnailUrl.isNotEmpty) {
            items.add(WorkImageItem(
              id: id,
              fileId: fileId,
              viewUrl: viewUrl.isNotEmpty ? viewUrl : thumbnailUrl,
              thumbnailUrl: thumbnailUrl.isNotEmpty ? thumbnailUrl : viewUrl,
              name: name.isNotEmpty ? name : 'Image',
            ));
          }
        } else if (item is String && item.trim().isNotEmpty) {
          final str = item.trim();
          items.add(WorkImageItem(
            viewUrl: str,
            thumbnailUrl: str,
            name: str.split('/').last.split('\\').last,
          ));
        }
      }
    } else if (raw is String && raw.trim().isNotEmpty) {
      final str = raw.trim();
      if (str.startsWith('[') && str.endsWith(']')) {
        try {
          final decoded = jsonDecode(str);
          if (decoded is List) return _parseWorkImages(decoded);
        } catch (_) {}
      }
      if (str.contains(',')) {
        for (var part in str.split(',')) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) {
            items.add(WorkImageItem(
              viewUrl: trimmed,
              thumbnailUrl: trimmed,
              name: trimmed.split('/').last.split('\\').last,
            ));
          }
        }
      } else {
        items.add(WorkImageItem(
          viewUrl: str,
          thumbnailUrl: str,
          name: str.split('/').last.split('\\').last,
        ));
      }
    }
    return items;
  }

  Future<void> _openImageView(String viewUrl, {String? thumbnailUrl}) async {
    if (viewUrl.trim().isEmpty) return;
    final uri = Uri.tryParse(viewUrl.trim());
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      try {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      } catch (e) {
        debugPrint('Failed to launch view_url: $e');
      }
    }
    if (mounted) {
      _previewImage(
        url: (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            ? thumbnailUrl
            : viewUrl,
      );
    }
  }

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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading:
                    const Icon(Icons.photo_library_outlined, color: _primary),
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

  // ───────────────────────── Image Deletion & Confirmation ─────────────────────────
  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Delete Image",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        content: const Text(
          "Do you want to delete this image?",
          style: TextStyle(fontSize: 15, color: _textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<Map<String, dynamic>> _callDeleteWorkOrderImageApi(
      String imageId) async {
    try {
      final token = await Common.getSharedPref("token");
      final dio = Dio();
      final formData = FormData.fromMap({
        "token": token ?? "",
        "image_id": imageId,
      });

      final response = await dio.post(
        "${await Config.getUrl()}delete_workorder_image",
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic raw = response.data;
        final Map<String, dynamic> data = raw is Map<String, dynamic>
            ? raw
            : (raw is String
                ? jsonDecode(raw)
                : Map<String, dynamic>.from(raw));
        final bool status = data["status"] == true ||
            data["status"] == 1 ||
            data["status"]?.toString().toLowerCase() == "true" ||
            data["status"]?.toString().toLowerCase() == "success";
        return {
          "status": status,
          "message": data["message"]?.toString() ??
              (status
                  ? "Image deleted successfully"
                  : "Failed to delete image"),
        };
      }
      return {
        "status": false,
        "message": "Server returned status code: ${response.statusCode}",
      };
    } catch (e) {
      debugPrint("delete_workorder_image error: $e");
      return {
        "status": false,
        "message": "Error deleting image: $e",
      };
    }
  }

  Future<void> _handleDeleteExistingImage({
    required bool isProduct,
    required int index,
  }) async {
    if (_isDeletingImage) return;

    final targetList =
        isProduct ? _existingProductImages : _existingWarrantyImages;
    if (index < 0 || index >= targetList.length) return;

    final WorkImageItem imageItem = targetList[index];

    final bool confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;
    if (!mounted) return;

    final String? imageId = imageItem.id;
    if (imageId == null || imageId.trim().isEmpty) {
      setState(() {
        targetList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Image removed successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isDeletingImage = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await _callDeleteWorkOrderImageApi(imageId.trim());

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss progress dialog

      if (result["status"] == true) {
        setState(() {
          targetList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ?? "Image deleted successfully",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ?? "Failed to delete image",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error deleting image: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingImage = false;
        });
      } else {
        _isDeletingImage = false;
      }
    }
  }

  Future<void> _handleDeleteNewImage({
    required bool isProduct,
    required int index,
  }) async {
    final targetList = isProduct ? _productImages : _warrantyImages;
    if (index < 0 || index >= targetList.length) return;

    final bool confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;
    if (!mounted) return;

    setState(() {
      targetList.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Image removed successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildEditImageUploadSection({
    required String title,
    required IconData icon,
    required List<WorkImageItem> existingImages,
    required List<File> newFiles,
    required VoidCallback onPick,
    required ValueChanged<int> onRemoveExisting,
    required ValueChanged<int> onRemoveNew,
    bool isRequired = false,
  }) {
    final int totalCount = existingImages.length + newFiles.length;
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
            if (totalCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalCount',
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
                  totalCount > 0 ? "Add More $title" : "Upload $title",
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
        if (totalCount > 0) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Existing Images
              ...existingImages.asMap().entries.map((entry) {
                final index = entry.key;
                final img = entry.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => _openImageView(img.viewUrl,
                          thumbnailUrl: img.thumbnailUrl),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _primary.withOpacity(0.4)),
                          color: Colors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              img.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: Colors.grey, size: 24),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.55),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: const Text(
                                  'Saved',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => onRemoveExisting(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 3),
                            ],
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              // New Files
              ...newFiles.asMap().entries.map((entry) {
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
                          border: Border.all(color: Colors.green.shade400),
                          color: Colors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: Colors.grey, size: 24),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.green.shade700.withOpacity(0.75),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: const Text(
                                  'New',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => onRemoveNew(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 3),
                            ],
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ],
    );
  }
}
