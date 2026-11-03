import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/serviceman/customerModel.dart';
import 'package:login2/models/serviceman/customerTypeModel.dart';
import 'package:login2/models/serviceman/receivedThroughModel.dart';
import 'package:login2/models/serviceman/staffModel.dart';
import 'package:login2/models/serviceman/workCategoryModel.dart';
import 'package:login2/models/serviceman/workOrderIdModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'package:login2/service/service.dart';

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
  // ───────────────────────── Theme constants ─────────────────────────
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

  // Models
  CustomerModelService? customerModel;
  CustomerTypeModel? custTypeModel;
  StaffsModel? staffModel;
  WorkTypeModel? workType;
  WorkCategory? workCategory;
  ReceivedThroughModel? receivedOne;
  WorkOrderData? _workData;

  bool _whatsappNotify = true;
  bool _pushNotify = false;
  bool _isLoading = true;
  bool _isMoreDetailsExpanded = false;
  bool _customerError = false;
  String? _errorMessage;

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

  // ───────────────────────── Data loading ─────────────────────────
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final workDetails = await HttpService().getWorkEditDetails(
        widget.workOrderId,
      );
      if (workDetails != null && workDetails.status) {
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

  // ───────────────────────── Helpers ─────────────────────────
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

  // ───────────────────────── Customer picker ─────────────────────────
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

  // ───────────────────────── Accessories picker ─────────────────────────
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

  // ───────────────────────── Update ─────────────────────────
  Future<void> _updateWork() async {
    final bool formOk = _formKey.currentState!.validate();
    final bool customerMissing =
        _selectedCustomerId == null || _selectedCustomerId!.isEmpty;
    setState(() => _customerError = customerMissing);
    if (!formOk || customerMissing) return;

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

      final result = await HttpService().updateWorkService(body);

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
      _showError('⚠️ Error: $e');
    }
  }

  // ───────────────────────── Build ─────────────────────────
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

  // ───────────────────────── Sections ─────────────────────────
  Widget _buildMainSection() {
    return _sectionCard(
      title: 'Job Details',
      icon: Icons.assignment_outlined,
      children: [
        _buildSelectField(
          label: 'Customer Name *',
          icon: Icons.person_outline_rounded,
          valueText: _selectedCustomerName,
          placeholder: 'Tap to select customer',
          errorText: _customerError ? 'Please select a customer' : null,
          onTap: _showCustomerPicker,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          _phoneController,
          "Mobile Number *",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            final v = (value ?? '').trim();
            if (v.isEmpty) return 'Required field';
            if (v.length < 10) return 'Enter a valid 10-digit number';
            return null;
          },
        ),
        _buildTextField(_locationController, "Location",
            icon: Icons.location_on_outlined),
        _buildTextField(_serialController, "Serial No / Model No",
            icon: Icons.qr_code_2_rounded),
        _buildTextField(_brandController, "Brand", icon: Icons.sell_outlined),
        _buildDropdown(
          "Product (Work Type) *",
          _selectedProduct,
          workType!.data
              .map((e) => {"id": e.id, "name": e.productName})
              .toList(),
          (val) => setState(() => _selectedProduct = val),
          icon: Icons.devices_other_outlined,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please select a product' : null,
        ),
        _buildDropdown(
          "Work Category",
          _selectedCategory,
          workCategory!.data
              .map((e) => {"id": e.workCategory, "name": e.workCategory})
              .toList(),
          (val) => setState(() => _selectedCategory = val),
          icon: Icons.category_outlined,
        ),
        _buildTextField(
          _problemDescController,
          "Problem Description",
          icon: Icons.report_problem_outlined,
          maxLines: 3,
          isLast: true,
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
            ),
            _buildTextField(_emailController, "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            _buildTextField(_addressController, "Address",
                icon: Icons.home_outlined, maxLines: 2),
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
            _buildDateField("Preferred Date", _preferredDate,
                () => _pickDateTime(context, true),
                onClear: () => setState(() => _preferredDate = null)),
            _buildDateField("Estimated Date", _estimatedDate,
                () => _pickDateTime(context, false),
                onClear: () => setState(() => _estimatedDate = null)),
            _buildServiceManDropdown(),
            _buildDropdown(
              "Status",
              _selectedStatus,
              ["New", "In Progress", "Completed", "On Hold", "Cancelled"]
                  .map((s) => {"id": s, "name": s})
                  .toList(),
              (val) => setState(() => _selectedStatus = val),
              icon: Icons.timelapse_rounded,
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
            ),
            _buildDropdown(
              "Job Type",
              _selectedJobType,
              ["New", "Repeat"].map((t) => {"id": t, "name": t}).toList(),
              (val) => setState(() => _selectedJobType = val),
              icon: Icons.repeat_rounded,
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Additional Information',
          icon: Icons.notes_rounded,
          children: [
            _buildTextField(
                _remarksCustomerController, "Remarks About Customer",
                icon: Icons.comment_outlined),
            _buildTextField(_remarksController, "Description",
                icon: Icons.description_outlined, maxLines: 2),
            _buildTextField(_dealerCustomerController, "Dealer / Customer",
                icon: Icons.storefront_outlined),
            _buildTextField(_userPasswordController, "User Password",
                icon: Icons.lock_outline_rounded, obscureText: true),
            _buildDropdown(
              "Received Through",
              _selectedReceivedThrough,
              receivedOne!.data
                  .map(
                      (e) => {"id": e.recievedTruId, "name": e.recievedThrough})
                  .toList(),
              (val) => setState(() => _selectedReceivedThrough = val),
              icon: Icons.input_rounded,
            ),
            _buildAccessoriesField(),
          ],
        ),
      ],
    );
  }

  // ───────────────────────── Reusable widgets ─────────────────────────
  InputDecoration _decoration(
    String label, {
    IconData? icon,
    String? hint,
    String? errorText,
    bool alwaysFloat = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: _decoration(label, icon: icon),
        validator: validator,
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
        decoration: _decoration(label, icon: icon),
      ),
    );
  }

  Widget _buildServiceManDropdown() {
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
      "Assigned Service Man",
      resolvedValue?.isNotEmpty == true ? resolvedValue : null,
      uniqueStaffItems,
      (val) => setState(() => _selectedServiceMan = val),
      icon: Icons.engineering_outlined,
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

  Widget _buildAccessoriesField() {
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
}
