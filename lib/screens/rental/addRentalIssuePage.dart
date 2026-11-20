import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/rental/rentalCustomerLocations.dart';
import 'package:login2/models/rental/rentalCollectedByStaffList.dart' as rcs;
import 'package:login2/models/rental/staffRateListModel.dart';
import 'package:login2/screens/accounts/clients/addClients.dart';
import 'package:login2/service/service.dart';

class AddRentalIssuePage extends StatefulWidget {
  final String? rentId;
  const AddRentalIssuePage({super.key, this.rentId});

  @override
  State<AddRentalIssuePage> createState() => _AddRentalIssuePageState();
}

class _AddRentalIssuePageState extends State<AddRentalIssuePage> {
  final HttpService _httpService = HttpService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();
  final TextEditingController _advanceAmountController =
      TextEditingController();
  final TextEditingController _totalPaidAmountController =
      TextEditingController(text: "0.00");
  final TextEditingController _discountController =
      TextEditingController(text: "0");
  final TextEditingController _otherExpensesController =
      TextEditingController(text: "0");
  final TextEditingController _transportationChargesController =
      TextEditingController(text: "0");
  final TextEditingController _otherTransportationChargesController =
      TextEditingController(text: "0");
  final TextEditingController _rentIssueIdController =
      TextEditingController(text: "#RIN");
  final TextEditingController _invoiceNoController =
      TextEditingController(text: "#");
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();

  bool _isBillingAddressExpanded = false;
  bool _isShippingAddressExpanded = false;

  // 'daily' or 'hourly' (sent to the API as rent_type)
  String _rentType = 'daily';
  bool get _isHourly => _rentType == 'hourly';

  final TextEditingController _billingNameController = TextEditingController();
  final TextEditingController _billingAddressLine1Controller =
      TextEditingController();
  final TextEditingController _billingAddressLine2Controller =
      TextEditingController();
  final TextEditingController _billingAddressLine3Controller =
      TextEditingController();
  final TextEditingController _billingPincodeController =
      TextEditingController();
  final TextEditingController _billingPostOfficeController =
      TextEditingController();
  final TextEditingController _billingMobileController =
      TextEditingController();
  final TextEditingController _billingWhatsappController =
      TextEditingController();
  final TextEditingController _billingGstController = TextEditingController();

  final TextEditingController _shippingNameController = TextEditingController();
  final TextEditingController _shippingAddressLine1Controller =
      TextEditingController();
  final TextEditingController _shippingAddressLine2Controller =
      TextEditingController();
  final TextEditingController _shippingAddressLine3Controller =
      TextEditingController();
  final TextEditingController _shippingPincodeController =
      TextEditingController();
  final TextEditingController _shippingPostOfficeController =
      TextEditingController();
  final TextEditingController _shippingMobileController =
      TextEditingController();
  final TextEditingController _shippingWhatsappController =
      TextEditingController();
  final TextEditingController _shippingGstController = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedLocationId;
  String? _selectedPaymentStatus = 'Unpaid';
  String? _selectedCollectedByStaffId;
  String? _selectedStaffName = "Select Staff";
  String? _paymentCollectedByStaffId;
  String? _paymentStaffName = "Select Staff";
  List<CustomerExp> _customers = [];
  List<MaterialData> _materials = [];
  List<MaterialData> _searchResults = [];
  List<LocationData> _customerLocations = [];
  List<Staff> _staffs = [];
  // Labour list (with hourly & daily rates)
  List<StaffRate> _staffRates = [];
  List<rcs.Staff> _collectedStaffs = [];
  List<String> _paymentStatuses = ['Unpaid', 'Paid', 'Partial'];
  final List<String> _paymentMethods = ['Cash', 'Bank'];
  String? _selectedPaymentMethod = 'Cash';
  List<ProductRow> _productRows = [ProductRow()];
  List<AddonProductRow> _addonProductRows = [AddonProductRow()];
  List<LabourRow> _labourRows = [LabourRow()];
  double _totalGrossAmount = 0.0;
  double _gstAmount = 0.0;
  double _labourTotal = 0.0;
  double _grandTotal = 0.0;
  int _totalDays = 1; // holds hours when rent type is hourly
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rentType = 'daily';
    _invoiceDateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
    _fromDateController.text =
        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    _toDateController.text = DateFormat('dd-MM-yyyy HH:mm')
        .format(DateTime.now().add(const Duration(days: 1)));
    if (widget.rentId != null) {
      _loadEditData(); // calls _loadData() internally
    } else {
      _loadData();
    }
    _updateTotalDays();
  }

  // ---------------------------------------------------------------------------
  // Rent type helpers
  // ---------------------------------------------------------------------------

  /// Raw rate for the selected rent type, or "" if the product has none.
  String _rawRateFor(MaterialData mat) {
    final r = _isHourly ? mat.hourlyRate : mat.unitPrice;
    final v = (r ?? '').trim();
    final n = double.tryParse(v);
    return (n == null || n <= 0) ? '' : v;
  }

  bool _hasRate(MaterialData mat) => _rawRateFor(mat).isNotEmpty;

  void _toastNoRate(String productName) {
    Common.toastMessaage(
      'No ${_isHourly ? 'hourly' : 'daily'} rate set for $productName. Please enter it manually.',
      Colors.orange,
    );
  }

  /// Returns the rate for a product based on the selected rent type.
  String _rateFor(MaterialData mat) {
    final r = _isHourly ? mat.hourlyRate : mat.unitPrice;
    return (r == null || r.trim().isEmpty) ? "0" : r;
  }

  /// Raw labour rate for the selected rent type, or "" if not set.
  String _labourRawRate(StaffRate labour) {
    final v = (_isHourly ? labour.hourlyRate : labour.dailyRate).trim();
    final n = double.tryParse(v);
    return (n == null || n <= 0) ? '' : v;
  }

  /// Converts a minute difference to hours or days depending on rent type.
  int _unitsFromMinutes(int diffInMinutes) {
    if (diffInMinutes <= 0) return 1;
    return _isHourly
        ? (diffInMinutes / 60).ceil()
        : (diffInMinutes / (24 * 60)).ceil();
  }

  void _onRentTypeChanged(String type) {
    if (_rentType == type) return;
    _rentType = type;

    final missing = <String>[];
    for (final row in _productRows) {
      if (row.selectedProductId == null) continue;
      final mat = _materials.firstWhere(
        (m) => m.materialId == row.selectedProductId,
        orElse: () => MaterialData(),
      );
      final rate = _rawRateFor(mat);
      row.unitPriceController.text = rate;
      row.ratePerDayController.text = rate;
      if (rate.isEmpty) missing.add(mat.materialName ?? 'Product');
    }

    // Update labour rates for the new rent type
    final missingLabours = <String>[];
    for (final row in _labourRows) {
      if (row.selectedLabourId == null) continue;
      final labour = _staffRates.firstWhere(
        (l) => l.id == row.selectedLabourId,
        orElse: () =>
            StaffRate(id: '', name: '', hourlyRate: '', dailyRate: ''),
      );
      final rate = _labourRawRate(labour);
      row.rateController.text = rate;
      if (rate.isEmpty) missingLabours.add(row.labourName ?? 'Labour');
    }

    _updateTotalDays();
    setState(() {});

    if (missing.isNotEmpty) {
      Common.toastMessaage(
        'No ${_isHourly ? 'hourly' : 'daily'} rate for: ${missing.join(', ')}. Please enter manually.',
        Colors.orange,
      );
    }
    if (missingLabours.isNotEmpty) {
      Common.toastMessaage(
        'No ${_isHourly ? 'hourly' : 'daily'} rate for labour: ${missingLabours.join(', ')}. Please enter manually.',
        Colors.orange,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadEditData() async {
    setState(() => _isLoading = true);
    try {
      await _loadData();
      final response = await HttpService.rentIssueDetails(widget.rentId!);
      if (response != null && response.status) {
        final issue = response.data.rentIssue;
        _rentType = issue.rentType;
        _selectedCustomerId = issue.customerId;
        await _loadCustomerLocations(_selectedCustomerId!);
        await _loadCollectedStaffs(_selectedCustomerId!);

        _selectedLocationId = issue.locationId;
        _selectedCollectedByStaffId = issue.collectedRent;
        _selectedStaffName = issue.collectedStaffName;

        _invoiceDateController.text = _formatDate(issue.invoiceDate);
        _fromDateController.text =
            _formatDate(issue.fromDate, includeTime: true);
        _toDateController.text = _formatDate(issue.toDate, includeTime: true);
        _totalDaysController.text = issue.totalDays;
        _advanceAmountController.text = issue.advanceAmount;
        _discountController.text = issue.discount;
        _otherExpensesController.text = issue.otherExpenses;
        _transportationChargesController.text = issue.transportationCharges;
        _otherTransportationChargesController.text = issue.loadingCharges;

        final bAddr = response.data.billingAddress;
        if (bAddr != null) {
          _billingNameController.text = bAddr.name;
          _billingAddressLine1Controller.text = bAddr.address1;
          _billingAddressLine2Controller.text = bAddr.address2;
          _billingAddressLine3Controller.text = bAddr.address3;
          _billingPincodeController.text = bAddr.pincode;
          _billingPostOfficeController.text = bAddr.postOffice;
          _billingMobileController.text = bAddr.contactNo;
          _billingWhatsappController.text = bAddr.whatsappNumber;
          _billingGstController.text = bAddr.gstNum;
        }

        final sAddr = response.data.shippingAddress;
        if (sAddr != null) {
          _shippingNameController.text = sAddr.name;
          _shippingAddressLine1Controller.text = sAddr.address1;
          _shippingAddressLine2Controller.text = sAddr.address2;
          _shippingAddressLine3Controller.text = sAddr.address3;
          _shippingPincodeController.text = sAddr.pincode;
          _shippingPostOfficeController.text = sAddr.postOffice;
          _shippingMobileController.text = sAddr.contactNo;
          _shippingWhatsappController.text = sAddr.whatsappNumber;
          _shippingGstController.text = sAddr.gstNum;
        }

        _rentIssueIdController.text = issue.rentNo;
        _invoiceNoController.text = issue.invoiceNo;
        _totalPaidAmountController.text = issue.amountPaid;
        _productRows.clear();
        for (var item in response.data.rentItems) {
          final row = ProductRow();
          row.selectedProductId = item.productId;
          row.quantityController.text = item.qty;
          row.unitPriceController.text = item.unitPrice;
          row.ratePerDayController.text = item.ratePerDay;
          row.noOfDaysController.text = item.days;
          row.fromDateController.text =
              _formatDate(issue.fromDate, includeTime: true);
          row.toDateController.text =
              _formatDate(issue.toDate, includeTime: true);
          row.grossAmountController.text = item.gross;
          row.gstPercentController.text = item.gstPercent;
          row.gstAmountController.text = item.gstAmount;
          row.totalController.text = item.total;
          row.hasGst = double.tryParse(item.gstPercent) != null &&
              double.parse(item.gstPercent) > 0;
          _productRows.add(row);
        }
        if (_productRows.isEmpty) _productRows.add(ProductRow());
        _recalculateAllRows();

        _addonProductRows.clear();
        for (var item in response.data.addonProducts) {
          final aRow = AddonProductRow();
          aRow.selectedProductId = item.productId;
          aRow.quantityController.text = item.qty;
          if (aRow.selectedProductId != null) {
            final mat = _materials.firstWhere(
              (m) => m.materialId == aRow.selectedProductId,
              orElse: () => MaterialData(),
            );
            aRow.currentStock = mat.currentStock;
          }
          _addonProductRows.add(aRow);
        }
        if (_addonProductRows.isEmpty) _addonProductRows.add(AddonProductRow());
      }
    } catch (e) {
      log('Error loading edit data: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadCustomers(),
        _loadMaterials(),
        _loadStaffs(),
        _loadStaffRates(),
      ]);
    } catch (e) {
      log('Error loading data: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadCustomers() async {
    final data = await HttpService.getCustomers();
    if (data != null && data.status) {
      setState(() => _customers = data.data);
    }
  }

  Future<void> _loadMaterials() async {
    final data = await HttpService.getMaterials();
    if (data != null && data.status == true && data.data != null) {
      setState(() => _materials = data.data!);
    }
  }

  Future<void> _loadStaffs() async {
    final data = await HttpService.getStaffs();
    if (data != null && data.status) {
      setState(() => _staffs = data.data);
    }
  }

  Future<void> _loadStaffRates() async {
    final data = await HttpService.getStaffRates();
    if (data != null && data.status) {
      setState(() => _staffRates = data.data);
    }
  }

  void _onProductSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = _materials
            .where((m) => (m.materialName ?? "")
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addProductFromSearch(MaterialData mat) {
    double stock = double.tryParse(mat.currentStock ?? "0") ?? 0;
    if (stock <= 0) {
      Common.toastMessaage('Product is out of stock', Colors.red);
      return;
    }

    setState(() {
      bool exists =
          _productRows.any((row) => row.selectedProductId == mat.materialId);
      if (!exists) {
        final rate = _rawRateFor(mat);
        final newRow = ProductRow();
        newRow.selectedProductId = mat.materialId;
        newRow.unitPriceController.text = rate;
        newRow.ratePerDayController.text = rate;
        newRow.currentStock = mat.currentStock;
        newRow.gstPercentController.text = mat.gstPercentage ?? "0";
        newRow.hasGst =
            mat.gstPercentage != null && mat.gstPercentage!.isNotEmpty;
        newRow.noOfDaysController.text = _totalDays.toString();
        newRow.fromDateController.text = _fromDateController.text;
        newRow.toDateController.text = _toDateController.text;
        newRow.quantityController.text = "1";
        if (_productRows.length == 1 &&
            _productRows[0].selectedProductId == null) {
          _productRows[0] = newRow;
        } else {
          _productRows.add(newRow);
        }
        _recalculateAllRows();
        if (rate.isEmpty) _toastNoRate(mat.materialName ?? 'this product');
      }
      _productSearchController.clear();
      _searchResults.clear();
    });
  }

  Future<void> _loadCustomerLocations(String customerId) async {
    final data = await HttpService.getRentalCustomerLocations(customerId);
    if (data != null && data.status) {
      setState(() {
        _customerLocations = data.data;
        _selectedLocationId = null;
      });
    }
  }

  Future<void> _loadCollectedStaffs(String customerId) async {
    final data = await HttpService.getCollectedStaffRentalList(customerId);
    if (data != null && data.status) {
      setState(() {
        _collectedStaffs = data.data;
      });
    } else {
      setState(() {
        _collectedStaffs = [];
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Calculations
  // ---------------------------------------------------------------------------

  void _updateTotalDays() {
    if (_fromDateController.text.isNotEmpty &&
        _toDateController.text.isNotEmpty) {
      try {
        final fromDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(_fromDateController.text);
        final toDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(_toDateController.text);

        final diffInMinutes = toDate.difference(fromDate).inMinutes;
        _totalDays = _unitsFromMinutes(diffInMinutes);
        _totalDaysController.text = _totalDays.toString();
        for (final row in _productRows) {
          row.noOfDaysController.text = _totalDays.toString();
          row.fromDateController.text = _fromDateController.text;
          row.toDateController.text = _toDateController.text;
        }
        for (final row in _labourRows) {
          row.daysController.text = _totalDays.toString();
        }
        _recalculateAllRows();
      } catch (e) {
        log("Error updating total days: $e");
        _totalDaysController.text = "0";
      }
    }
  }

  void _removeProductRow(int index) {
    setState(() {
      _productRows.removeAt(index);
      _recalculateAllRows();
    });
  }

  void _recalculateRow(int index) {
    final row = _productRows[index];
    final quantity = double.tryParse(row.quantityController.text) ?? 0;
    final ratePerDay = double.tryParse(row.ratePerDayController.text) ?? 0;
    final noOfDays =
        double.tryParse(row.noOfDaysController.text) ?? _totalDays.toDouble();
    final grossAmount = quantity * ratePerDay * noOfDays;
    row.grossAmountController.text = grossAmount.toStringAsFixed(2);
    double gstAmount = 0;
    if (row.hasGst && row.gstPercentController.text.isNotEmpty) {
      final gstPercent = double.tryParse(row.gstPercentController.text) ?? 0;
      gstAmount = grossAmount * (gstPercent / 100);
    }
    row.gstAmountController.text = gstAmount.toStringAsFixed(2);
    final total = grossAmount + gstAmount;
    row.totalController.text = total.toStringAsFixed(2);
    _calculateSummary();
  }

  void _updateRowDaysFromDates(int index) {
    final row = _productRows[index];
    if (row.fromDateController.text.isNotEmpty &&
        row.toDateController.text.isNotEmpty) {
      try {
        final fromDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(row.fromDateController.text);
        final toDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(row.toDateController.text);

        final diffInMinutes = toDate.difference(fromDate).inMinutes;
        final rowDays = _unitsFromMinutes(diffInMinutes);
        row.noOfDaysController.text = rowDays.toString();
        _recalculateRow(index);
      } catch (e) {
        log("Error updating row days: $e");
      }
    }
  }

  /// Amount = rate x days (hours when hourly). Does not touch the summary.
  void _recalculateLabourAmount(LabourRow row) {
    final rate = double.tryParse(row.rateController.text) ?? 0;
    final days = double.tryParse(row.daysController.text) ?? 0;
    row.amountController.text = (rate * days).toStringAsFixed(2);
  }

  void _onLabourChanged(LabourRow row) {
    _recalculateLabourAmount(row);
    _calculateSummary();
  }

  void _recalculateAllRows() {
    for (int i = 0; i < _productRows.length; i++) {
      _recalculateRow(i);
    }
    for (final row in _labourRows) {
      _recalculateLabourAmount(row);
    }
    _calculateSummary(); // also covers the case with no product rows
  }

  void _calculateSummary() {
    double totalGross = 0;
    double totalGST = 0;
    for (final row in _productRows) {
      totalGross += double.tryParse(row.grossAmountController.text) ?? 0;
      totalGST += double.tryParse(row.gstAmountController.text) ?? 0;
    }
    double labourTotal = 0;
    for (final row in _labourRows) {
      if (row.selectedLabourId == null) continue;
      labourTotal += double.tryParse(row.amountController.text) ?? 0;
    }
    final discount = double.tryParse(_discountController.text) ?? 0;
    final otherExpenses = double.tryParse(_otherExpensesController.text) ?? 0;
    final transportation =
        double.tryParse(_transportationChargesController.text) ?? 0;
    final otherTransportation =
        double.tryParse(_otherTransportationChargesController.text) ?? 0;
    setState(() {
      _totalGrossAmount = totalGross;
      _gstAmount = totalGST;
      _labourTotal = labourTotal;
      _grandTotal = totalGross +
          totalGST +
          labourTotal -
          discount +
          otherExpenses +
          transportation +
          otherTransportation;
      if (_selectedPaymentStatus == 'Paid') {
        _totalPaidAmountController.text = _grandTotal.toStringAsFixed(2);
      } else if (_selectedPaymentStatus == 'Unpaid') {
        _totalPaidAmountController.text = "0.00";
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Date pickers
  // ---------------------------------------------------------------------------

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller) async {
    DateTime issueDateTime;
    try {
      issueDateTime =
          DateFormat('dd-MM-yyyy HH:mm').parse(_fromDateController.text);
    } catch (e) {
      issueDateTime = DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller == _fromDateController
          ? (controller.text.isNotEmpty
              ? DateFormat('dd-MM-yyyy HH:mm').parse(controller.text)
              : DateTime.now())
          : (controller.text.isNotEmpty
              ? DateFormat('dd-MM-yyyy HH:mm').parse(controller.text)
              : (issueDateTime.isAfter(DateTime.now())
                  ? issueDateTime
                  : DateTime.now())),
      firstDate: controller == _fromDateController
          ? DateTime(2000)
          : DateTime(
              issueDateTime.year, issueDateTime.month, issueDateTime.day),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: controller.text.isNotEmpty
            ? TimeOfDay.fromDateTime(
                DateFormat('dd-MM-yyyy HH:mm').parse(controller.text))
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (controller == _toDateController) {
          if (fullDateTime.isBefore(issueDateTime)) {
            Common.toastMessaage(
                'Due Date & Time cannot be before Issue Date & Time',
                Colors.red);
            return;
          }
        }

        setState(() {
          controller.text = DateFormat('dd-MM-yyyy HH:mm').format(fullDateTime);
          if (controller == _fromDateController ||
              controller == _toDateController) {
            _updateTotalDays();
          }
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submitForm() async {
    if (_selectedCustomerId == null) {
      Common.toastMessaage('Please select a customer', Colors.red);
      return;
    }
    if (_productRows.isEmpty ||
        _productRows.every((row) => row.selectedProductId == null)) {
      Common.toastMessaage('Please add at least one product', Colors.red);
      return;
    }
    final hasEmptyRate = _productRows.any((row) =>
        row.selectedProductId != null &&
        (double.tryParse(row.ratePerDayController.text) ?? 0) <= 0);
    if (hasEmptyRate) {
      Common.toastMessaage(
          'Please enter the ${_isHourly ? 'hourly' : 'daily'} rate for all products',
          Colors.red);
      return;
    }
    final hasEmptyLabourRate = _labourRows.any((row) =>
        row.selectedLabourId != null &&
        (double.tryParse(row.rateController.text) ?? 0) <= 0);
    if (hasEmptyLabourRate) {
      Common.toastMessaage(
          'Please enter the ${_isHourly ? 'hourly' : 'daily'} rate for all labours',
          Colors.red);
      return;
    }
    if (_selectedLocationId == null) {
      Common.toastMessaage('Please select a work site', Colors.red);
      return;
    }

    // Payment validation
    if (_selectedPaymentStatus == 'Paid' ||
        _selectedPaymentStatus == 'Partial') {
      if (_selectedPaymentMethod == null) {
        Common.toastMessaage('Please select a payment method', Colors.red);
        return;
      }
      if (_paymentCollectedByStaffId == null) {
        Common.toastMessaage('Please select a payment collector', Colors.red);
        return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      Map<String, dynamic> formData = {
        'token': await Common.getSharedPref('token'),
        if (widget.rentId != null) 'id': widget.rentId,
        'customer_id': _selectedCustomerId,
        'from_date': "${_fromDateController.text}:00",
        'to_date': "${_toDateController.text}:00",
        'invoice_date': _invoiceDateController.text,
        'location': _selectedLocationId,
        'rent_type': _rentType, // 'daily' or 'hourly'
        'total_days': _totalDays.toString(), // hours when rent_type is hourly
        'advance_amount': _advanceAmountController.text,
        'payment_status': _selectedPaymentStatus,
        'total_paid_amount': _totalPaidAmountController.text,
        'discount': _discountController.text,
        'other_expenses': _otherExpensesController.text,
        'transportation_charges': _transportationChargesController.text,
        'loading_charges': _otherTransportationChargesController.text,
        'billing_name': _billingNameController.text,
        'billing_address1': _billingAddressLine1Controller.text,
        'billing_address2': _billingAddressLine2Controller.text,
        'billing_address3': _billingAddressLine3Controller.text,
        'billing_pincode': _billingPincodeController.text,
        'billing_post_office': _billingPostOfficeController.text,
        'billing_contact_no': _billingMobileController.text,
        'billing_whatsapp_number': _billingWhatsappController.text,
        'billing_gst': _billingGstController.text,
        'shipping_name': _shippingNameController.text,
        'shipping_address1': _shippingAddressLine1Controller.text,
        'shipping_address2': _shippingAddressLine2Controller.text,
        'shipping_address3': _shippingAddressLine3Controller.text,
        'shipping_pincode': _shippingPincodeController.text,
        'shipping_post_office': _shippingPostOfficeController.text,
        'shipping_contact_no': _shippingMobileController.text,
        'shipping_whatsapp_number': _shippingWhatsappController.text,
        'shipping_gst': _shippingGstController.text,
        'labour_total': _labourTotal.toStringAsFixed(2),
        'grand_total': _grandTotal.toStringAsFixed(2),
        'collected_by': _selectedCollectedByStaffId,
        'payment_collected_by': _paymentCollectedByStaffId,
        'invoice_no': _invoiceNoController.text,
        'rental_issue_id': _rentIssueIdController.text,
        'products': _productRows
            .where((row) => row.selectedProductId != null)
            .map((row) => {
                  'material_id': row.selectedProductId,
                  'quantity': row.quantityController.text,
                  'rate_per_day': row.ratePerDayController.text,
                  'no_of_days': row.noOfDaysController.text,
                  'from_date': row.fromDateController.text,
                  'to_date': row.toDateController.text,
                  'gross_amount': row.grossAmountController.text,
                  'gst_percent': row.gstPercentController.text.isNotEmpty
                      ? row.gstPercentController.text
                      : "0",
                  'gst_amount': row.gstAmountController.text,
                  'total': row.totalController.text,
                })
            .toList(),
        'addon_products': _addonProductRows
            .where((row) => row.selectedProductId != null)
            .map((row) => {
                  'material_id': row.selectedProductId,
                  'quantity': row.quantityController.text,
                })
            .toList(),
        'labours': _labourRows
            .where((row) => row.selectedLabourId != null)
            .map((row) => {
                  'labour_id': row.selectedLabourId,
                  'labour_rate': row.rateController.text,
                  'labour_duration':
                      row.daysController.text, // hours when hourly
                  'amount': row.amountController.text,
                })
            .toList(),
      };

      final response = widget.rentId != null
          ? await HttpService.editRentalIssue(formData)
          : await HttpService.createRentalIssue(formData);

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.rentId != null
                ? 'Rental Issue updated successfully'
                : 'Rental Issue created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ??
                (widget.rentId != null
                    ? 'Failed to update rental issue'
                    : 'Failed to create rental issue')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Product row UI
  // ---------------------------------------------------------------------------

  Widget _buildMinimalProductRow(int index) {
    final row = _productRows[index];
    final mat = _materials.firstWhere(
        (m) => m.materialId == row.selectedProductId,
        orElse: () => MaterialData());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Colors.blue, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mat.materialName ?? "Unknown Product",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Builder(builder: (context) {
                      final stockValue =
                          double.tryParse(mat.currentStock ?? '0') ?? 0;
                      final isAvailable = stockValue > 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAvailable
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          isAvailable
                              ? "Stock: ${mat.currentStock ?? '0'}"
                              : "No stock available",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isAvailable
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  row.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.blue,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    row.isExpanded = !row.isExpanded;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Colors.red.shade300, size: 20),
                onPressed: () => _removeProductRow(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 0.5),
          ),
          if (!row.isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Qty: ${row.quantityController.text} | ${_isHourly ? 'Rate/Hr' : 'Price'}: ₹ ${row.ratePerDayController.text} | ${_isHourly ? 'Hours' : 'Days'}: ${row.noOfDaysController.text}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (row.isExpanded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFormRow(
                    "Quantity",
                    _counterField(
                        row.quantityController, () => _recalculateRow(index)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormRow(
                    _isHourly ? "Rate/Hour" : "Rental Price",
                    TextFormField(
                      controller: row.ratePerDayController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: _inputDecoration(isDense: true),
                      onChanged: (_) => _recalculateRow(index),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildFormRow(
                    _isHourly ? "No of Hours" : "No of Days",
                    _counterField(
                        row.noOfDaysController, () => _recalculateRow(index)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormRow(
                    "Total",
                    TextFormField(
                      controller: row.totalController,
                      readOnly: true,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                      decoration: _inputDecoration(isDense: true)
                          .copyWith(fillColor: Colors.blue.shade50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rent type toggle
  // ---------------------------------------------------------------------------

  Widget _buildRentTypeToggle() {
    const options = {'daily': 'Daily', 'hourly': 'Hourly'};
    final bool isEditMode = widget.rentId != null; // locked when editing

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildFormRow(
          "Rent Type *:",
          Opacity(
            opacity: isEditMode ? 0.6 : 1,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: _boxDecoration(),
              child: Row(
                children: options.entries.map((entry) {
                  final isSelected = _rentType == entry.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: isEditMode
                          ? null
                          : () => _onRentTypeChanged(entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isEditMode
                                  ? Colors.grey.shade600
                                  : const Color(0xFF2a86c9))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          entry.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.rentId != null ? 'Edit Rent Issue' : 'Add Rent Issue',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Client & Staff Info',
                      icon: Icons.info_outline,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                "Customer *:",
                                GestureDetector(
                                  onTap: () => _showCustomerDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: _boxDecoration(),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedCustomerId != null
                                                ? _customers
                                                    .firstWhere((c) =>
                                                        c.id ==
                                                        _selectedCustomerId)
                                                    .name
                                                : "Select",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _selectedCustomerId != null
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormRow(
                                "Site * :",
                                _dropdown(
                                  _customerLocations
                                      .map((l) => l.locationName)
                                      .toList(),
                                  _selectedLocationId != null &&
                                          _customerLocations.any((l) =>
                                              l.id == _selectedLocationId)
                                      ? _customerLocations
                                          .firstWhere((l) =>
                                              l.id == _selectedLocationId)
                                          .locationName
                                      : null,
                                  "Select Location",
                                  (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedLocationId = _customerLocations
                                            .firstWhere(
                                                (l) => l.locationName == val)
                                            .id;
                                      });
                                    }
                                  },
                                  suffixAction: IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _addWorkSiteDialog(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                "Contact Person :",
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: _boxDecoration(),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => _showStaffDialog(context,
                                              isPayment: false),
                                          child: Text(
                                            _selectedStaffName ?? "Select",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  _selectedCollectedByStaffId !=
                                                          null
                                                      ? Colors.black
                                                      : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _showStaffDialog(context,
                                            isPayment: false),
                                        child: const Icon(Icons.arrow_drop_down,
                                            size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _addCollectedStaffDialog(context),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormRow(
                                "Invoice Date :",
                                GestureDetector(
                                  onTap: () => _selectDate(
                                      context, _invoiceDateController),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: _boxDecoration(),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _invoiceDateController.text
                                                .split(' ')[0],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today,
                                            size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRentTypeToggle(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _minimalDateItem("Issue Date", _fromDateController),
                          _minimalDateItem("Due Date", _toDateController),
                          _minimalDaysItemDays(
                              _isHourly ? "Total Hours" : "Total Days",
                              _totalDaysController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSectionCard(
                      title: 'Items & Summary',
                      icon: Icons.inventory_2,
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          controller: _productSearchController,
                          onChanged: _onProductSearch,
                          decoration: _inputDecoration().copyWith(
                            hintText: 'Search Product...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _productSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _productSearchController.clear();
                                        _searchResults.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                        if (_searchResults.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              border: Border.all(color: Colors.blue.shade50),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _searchResults.length,
                              separatorBuilder: (context, index) => Divider(
                                  height: 1, color: Colors.grey.shade100),
                              itemBuilder: (context, idx) {
                                final mat = _searchResults[idx];
                                final stock =
                                    double.tryParse(mat.currentStock ?? "0") ??
                                        0;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  title: Text(mat.materialName ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                          "${_isHourly ? 'Rate/Hr' : 'Price'}: ₹${_rateFor(mat)}",
                                          style: const TextStyle(fontSize: 11)),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: stock > 0
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "Stock: $stock",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: stock > 0
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.add_circle_outline,
                                      color: Colors.blue, size: 20),
                                  onTap: () => _addProductFromSearch(mat),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                        ...List.generate(_productRows.length, (index) {
                          if (_productRows[index].selectedProductId == null) {
                            return const SizedBox();
                          }
                          return _buildMinimalProductRow(index);
                        }),
                        const Divider(height: 32),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _buildMinimalSummaryRow("Total Gross Amount",
                                  "₹${_totalGrossAmount.toStringAsFixed(2)}"),
                              _buildMinimalSummaryRow("GST Amount",
                                  "₹${_gstAmount.toStringAsFixed(2)}"),
                              _buildMinimalSummaryRow("Labour Charges",
                                  "₹${_labourTotal.toStringAsFixed(2)}"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormRow(
                                      "Discount",
                                      TextFormField(
                                        controller: _discountController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration().copyWith(
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (_) => _calculateSummary(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFormRow(
                                      "Other Expense",
                                      TextFormField(
                                        controller: _otherExpensesController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration().copyWith(
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (_) => _calculateSummary(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormRow(
                                      "Transportation Charges",
                                      TextFormField(
                                        controller:
                                            _transportationChargesController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration().copyWith(
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (_) => _calculateSummary(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFormRow(
                                      "Loading Charges",
                                      TextFormField(
                                        controller:
                                            _otherTransportationChargesController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration().copyWith(
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (_) => _calculateSummary(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Grand Total",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text("₹${_grandTotal.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLabourSection(),
                    const SizedBox(height: 12),
                    _buildAddonProductsSection(),
                    const SizedBox(height: 12),
                    _buildCollapsibleAddressSection(
                      title: "Billing Address",
                      icon: Icons.location_on_outlined,
                      isExpanded: _isBillingAddressExpanded,
                      onToggle: () {
                        setState(() {
                          _isBillingAddressExpanded =
                              !_isBillingAddressExpanded;
                        });
                      },
                      nameController: _billingNameController,
                      addr1Controller: _billingAddressLine1Controller,
                      addr2Controller: _billingAddressLine2Controller,
                      addr3Controller: _billingAddressLine3Controller,
                      pinController: _billingPincodeController,
                      postController: _billingPostOfficeController,
                      mobileController: _billingMobileController,
                      whatsappController: _billingWhatsappController,
                      gstController: _billingGstController,
                    ),
                    const SizedBox(height: 12),
                    _buildCollapsibleAddressSection(
                      title: "Shipping Address",
                      icon: Icons.local_shipping_outlined,
                      isExpanded: _isShippingAddressExpanded,
                      onToggle: () {
                        setState(() {
                          _isShippingAddressExpanded =
                              !_isShippingAddressExpanded;
                        });
                      },
                      nameController: _shippingNameController,
                      addr1Controller: _shippingAddressLine1Controller,
                      addr2Controller: _shippingAddressLine2Controller,
                      addr3Controller: _shippingAddressLine3Controller,
                      pinController: _shippingPincodeController,
                      postController: _shippingPostOfficeController,
                      mobileController: _shippingMobileController,
                      whatsappController: _shippingWhatsappController,
                      gstController: _shippingGstController,
                    ),
                    const SizedBox(height: 8),
                    widget.rentId != null
                        ? const SizedBox()
                        : _buildPaymentSection(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Save Rental Issue',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Labour section
  // ---------------------------------------------------------------------------

  Widget _buildLabourSection() {
    return _buildSectionCard(
      title: 'Labours',
      icon: Icons.engineering_outlined,
      children: [
        const SizedBox(height: 12),
        if (_labourRows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "No labours added.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          )
        else
          ...List.generate(
              _labourRows.length, (index) => _buildLabourRow(index)),
        ElevatedButton(
          onPressed: () {
            setState(() {
              final row = LabourRow();
              row.daysController.text = _totalDays.toString();
              _labourRows.add(row);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF334155),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text(
            "Add Labour",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildLabourRow(int index) {
    final row = _labourRows[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sl + Labour selector + delete
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLabourSelectionDialog(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            row.selectedLabourId != null
                                ? (row.labourName ?? "Select Labour")
                                : "Select Labour",
                            style: TextStyle(
                              fontSize: 13,
                              color: row.selectedLabourId != null
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (row.selectedLabourId != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                row.selectedLabourId = null;
                                row.labourName = null;
                                row.rateController.clear();
                                row.amountController.text = "0.00";
                              });
                              _calculateSummary();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.grey),
                            ),
                          ),
                        const Icon(Icons.arrow_drop_down,
                            size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEE5253),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 18),
                  onPressed: () {
                    setState(() => _labourRows.removeAt(index));
                    _calculateSummary();
                    // dispose after the frame so the removed fields are gone
                    SchedulerBinding.instance
                        .addPostFrameCallback((_) => row.dispose());
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Rate / Days (Hours) / Amount
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildFormRow(
                  _isHourly ? "Rate/Hour" : "Rate/Day",
                  TextFormField(
                    controller: row.rateController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: _inputDecoration(isDense: true),
                    onChanged: (_) => _onLabourChanged(row),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildFormRow(
                  _isHourly ? "Hours" : "Days",
                  TextFormField(
                    controller: row.daysController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: _inputDecoration(isDense: true),
                    onChanged: (_) => _onLabourChanged(row),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildFormRow(
                  "Amount",
                  TextFormField(
                    controller: row.amountController,
                    readOnly: true,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                    decoration: _inputDecoration(isDense: true)
                        .copyWith(fillColor: Colors.blue.shade50),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLabourSelectionDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // IDs already selected in OTHER rows
            final usedIds = <String>{};
            for (int i = 0; i < _labourRows.length; i++) {
              final id = _labourRows[i].selectedLabourId;
              if (i != index && id != null) usedIds.add(id);
            }
            final List<StaffRate> filtered = _staffRates
                .where((l) =>
                    !usedIds.contains(l.id) &&
                    l.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
            return AlertDialog(
              title: const Text("Select Labour",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (val) =>
                          setDialogState(() => searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: "Search Labour...",
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text("No labours found"))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, idx) {
                                final labour = filtered[idx];
                                final rate = _labourRawRate(labour);
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  title: Text(
                                    labour.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    rate.isEmpty
                                        ? "No ${_isHourly ? 'hourly' : 'daily'} rate"
                                        : "${_isHourly ? 'Rate/Hr' : 'Rate/Day'}: ₹$rate",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: rate.isEmpty
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                  onTap: () {
                                    final row = _labourRows[index];
                                    setState(() {
                                      row.selectedLabourId = labour.id;
                                      row.labourName = labour.name;
                                      row.rateController.text = rate;
                                      row.daysController.text =
                                          _totalDays.toString();
                                    });
                                    _onLabourChanged(row);
                                    Navigator.pop(context);
                                    if (rate.isEmpty) {
                                      Common.toastMessaage(
                                        'No ${_isHourly ? 'hourly' : 'daily'} rate set for ${labour.name}. Please enter it manually.',
                                        Colors.orange,
                                      );
                                    }
                                  },
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
      },
    );
  }

  Widget _buildPaymentSection() {
    return _buildSectionCard(
      title: "Payment Details",
      icon: Icons.payment,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFormRow(
                "Payment Status * :",
                _dropdown(
                    _paymentStatuses, _selectedPaymentStatus, "Select Status",
                    (newVal) {
                  setState(() {
                    _selectedPaymentStatus = newVal;
                    if (_selectedPaymentStatus == 'Unpaid') {
                      _totalPaidAmountController.text = "0.00";
                    } else if (_selectedPaymentStatus == 'Paid') {
                      _totalPaidAmountController.text =
                          _grandTotal.toStringAsFixed(2);
                    }
                  });
                }),
              ),
            ),
            const SizedBox(width: 12),
            if (_selectedPaymentStatus != "Unpaid")
              Expanded(
                child: _buildFormRow(
                  "Total Paid Amount * :",
                  TextFormField(
                    controller: _totalPaidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(),
                    onChanged: (val) {
                      _calculateSummary();
                    },
                  ),
                ),
              ),
          ],
        ),
        if (_selectedPaymentStatus == 'Paid' ||
            _selectedPaymentStatus == 'Partial') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormRow(
                  "Payment Detail * :",
                  _dropdown(
                      _paymentMethods, _selectedPaymentMethod, "Select Method",
                      (val) {
                    setState(() => _selectedPaymentMethod = val);
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormRow(
                  "Collected By * :",
                  GestureDetector(
                    onTap: () => _showStaffDialog(context, isPayment: true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _boxDecoration(),
                      child: Text(
                        _paymentStaffName ?? "Select",
                        style: TextStyle(
                          color: _paymentCollectedByStaffId != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildFormRow(
          "Remarks",
          TextFormField(
            controller: _remarksController,
            maxLines: 2,
            decoration:
                _inputDecoration().copyWith(hintText: "Enter remarks here..."),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(List<String> items, String? value, String hint,
      Function(String?) onChanged,
      {Widget? suffixAction}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: items.contains(value) ? value : null,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(hint, style: const TextStyle(fontSize: 14)),
                ),
                items: items
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(e,
                                  style: const TextStyle(fontSize: 14))),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (suffixAction != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: suffixAction,
            ),
        ],
      ),
    );
  }

  Widget _buildFormRow(String title, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 13),
              children: _parseTitle(title),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      );

  List<TextSpan> _parseTitle(String title) {
    List<TextSpan> spans = [];
    List<String> parts = title.split('*');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(const TextSpan(
            text: '*',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
      }
    }
    return spans;
  }

  InputDecoration _inputDecoration({bool isDense = false}) {
    return InputDecoration(
      isDense: isDense,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 10, vertical: isDense ? 8 : 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 1),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      );

  Widget _counterField(
      TextEditingController controller, VoidCallback onChanged) {
    return Container(
      decoration: _boxDecoration(),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: () {
              int val = int.tryParse(controller.text) ?? 0;
              if (val > 0) {
                controller.text = (val - 1).toString();
                onChanged();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              int val = int.tryParse(controller.text) ?? 0;
              controller.text = (val + 1).toString();
              onChanged();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _addWorkSiteDialog(BuildContext context) {
    if (_selectedCustomerId == null) {
      Common.toastMessaage('Please select a customer first', Colors.red);
      return;
    }
    TextEditingController locationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool adding = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Work Site'),
              content: TextFormField(
                controller: locationController,
                decoration:
                    _inputDecoration().copyWith(hintText: 'Work Site Name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (locationController.text.trim().isEmpty) {
                      Common.toastMessaage('Name required', Colors.red);
                      return;
                    }
                    setStateDialog(() => adding = true);
                    final response =
                        await HttpService.addRentalCustomerLocation(
                            _selectedCustomerId!,
                            locationController.text.trim());
                    setStateDialog(() => adding = false);
                    if (!mounted) return;
                    if (response != null && response['status'] == true) {
                      Common.toastMessaage(
                          'Work Site added successfully', Colors.green);
                      Navigator.pop(context);
                      await _loadCustomerLocations(_selectedCustomerId!);

                      // Find and select the newly added location
                      final newLoc = _customerLocations.firstWhere(
                        (l) => l.locationName == locationController.text.trim(),
                        orElse: () => LocationData(
                            id: '', locationName: '', customerId: ''),
                      );
                      if (newLoc.id.isNotEmpty) {
                        setState(() {
                          _selectedLocationId = newLoc.id;
                        });
                      }
                    } else {
                      Common.toastMessaage(
                          response?['message'] ?? 'Failed', Colors.red);
                    }
                  },
                  child: adding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addCollectedStaffDialog(BuildContext context) {
    if (_selectedCustomerId == null) {
      Common.toastMessaage('Please select a customer first', Colors.red);
      return;
    }
    TextEditingController staffController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool adding = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Customer Staff'),
              content: TextFormField(
                controller: staffController,
                decoration: _inputDecoration().copyWith(hintText: 'Staff Name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (staffController.text.trim().isEmpty) {
                      Common.toastMessaage('Name required', Colors.red);
                      return;
                    }
                    setStateDialog(() => adding = true);
                    final response = await HttpService.addRentalCollectedStaff(
                        _selectedCustomerId!, staffController.text.trim());
                    setStateDialog(() => adding = false);
                    if (!mounted) return;
                    if (response != null && response['status'] == true) {
                      Common.toastMessaage(
                          'Staff added successfully', Colors.green);
                      Navigator.pop(context);
                      await _loadCollectedStaffs(_selectedCustomerId!);

                      // Find and select the newly added staff
                      final newStaff = _collectedStaffs.firstWhere(
                        (s) => s.customerStaff == staffController.text.trim(),
                        orElse: () => rcs.Staff(id: '', customerStaff: ''),
                      );
                      if (newStaff.id.isNotEmpty) {
                        setState(() {
                          _selectedCollectedByStaffId = newStaff.id;
                          _selectedStaffName = newStaff.customerStaff;
                        });
                      }
                    } else {
                      Common.toastMessaage(
                          response?['message'] ?? 'Failed', Colors.red);
                    }
                  },
                  child: adding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<CustomerExp> filtered = _customers
                .where((c) =>
                    c.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Customer",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton.icon(
                    onPressed: () async {
                      final token = await Common.getSharedPref('token');
                      Navigator.pop(context);
                      final oldCustomerIds =
                          _customers.map((c) => c.id).toSet();
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddClients(token ?? ""),
                        ),
                      );

                      if (!mounted) return;

                      if (result == true || result == false || result == null) {
                        await _loadCustomers();
                      }
                      final newCustomers = _customers
                          .where((c) => !oldCustomerIds.contains(c.id))
                          .toList();

                      if (newCustomers.isNotEmpty) {
                        final latestCustomer = newCustomers.first;
                        setState(() {
                          _selectedCustomerId = latestCustomer.id;
                          _loadCustomerLocations(_selectedCustomerId!);
                          _loadCollectedStaffs(_selectedCustomerId!);
                          _selectedCollectedByStaffId = null;
                          _selectedStaffName = "Select Staff";
                        });

                        // Fetch rental invoice number for the new customer
                        final invoiceRes =
                            await HttpService.generateInvoiceNumberRental(
                                latestCustomer.id);
                        if (invoiceRes != null &&
                            invoiceRes.status &&
                            invoiceRes.data != null) {
                          String rawInvoiceNo = invoiceRes.data!.invoiceNo;
                          String numericInvoiceNo =
                              rawInvoiceNo.replaceFirst(RegExp(r'^#+'), '');
                          setState(() {
                            _invoiceNoController.text = "#$numericInvoiceNo";
                            _rentIssueIdController.text =
                                "#RIN$numericInvoiceNo";
                          });
                        }
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Customer "${latestCustomer.name}" added and selected'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.blue, size: 20),
                    label: const Text("Add",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (val) =>
                          setDialogState(() => searchQuery = val),
                      decoration: const InputDecoration(
                          hintText: "Search Customer",
                          prefixIcon: Icon(Icons.search)),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filtered[index].name),
                            onTap: () async {
                              setState(() {
                                _selectedCustomerId = filtered[index].id;
                                _loadCustomerLocations(_selectedCustomerId!);
                                _loadCollectedStaffs(_selectedCustomerId!);
                                _selectedCollectedByStaffId = null;
                                _selectedStaffName = "Select Staff";
                              });
                              Navigator.pop(context);

                              // Fetch rental invoice number
                              final invoiceRes =
                                  await HttpService.generateInvoiceNumberRental(
                                      filtered[index].id);
                              if (invoiceRes != null &&
                                  invoiceRes.status &&
                                  invoiceRes.data != null) {
                                String rawInvoiceNo =
                                    invoiceRes.data!.invoiceNo;
                                // Ensure only one # at the beginning
                                String numericInvoiceNo = rawInvoiceNo
                                    .replaceFirst(RegExp(r'^#+'), '');
                                String formattedInvoiceNo =
                                    "#$numericInvoiceNo";

                                String formattedRentIssueId =
                                    "#RIN$numericInvoiceNo";

                                setState(() {
                                  _invoiceNoController.text =
                                      formattedInvoiceNo;
                                  _rentIssueIdController.text =
                                      formattedRentIssueId;
                                });
                              }
                            },
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
      },
    );
  }

  void _showStaffDialog(BuildContext context, {bool isPayment = false}) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Use either general staff or customer-specific staff
            final List<dynamic> sourceList =
                isPayment ? _staffs : _collectedStaffs;

            // Map to a common format for display
            final List<Map<String, String>> displayList = sourceList.map((s) {
              if (s is Staff) {
                return {"id": s.id, "name": s.name};
              } else if (s is rcs.Staff) {
                return {"id": s.id, "name": s.customerStaff};
              }
              return {"id": "", "name": ""};
            }).toList();

            final List<Map<String, String>> filtered = displayList
                .where((s) => s["name"]!
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();
            return AlertDialog(
              title: const Text("Select Staff"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (val) =>
                          setDialogState(() => searchQuery = val),
                      decoration: const InputDecoration(
                          hintText: "Search Staff",
                          prefixIcon: Icon(Icons.search)),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filtered[index]["name"]!),
                            onTap: () {
                              setState(() {
                                if (isPayment) {
                                  _paymentCollectedByStaffId =
                                      filtered[index]["id"];
                                  _paymentStaffName = filtered[index]["name"];
                                } else {
                                  _selectedCollectedByStaffId =
                                      filtered[index]["id"];
                                  _selectedStaffName = filtered[index]["name"];
                                }
                              });
                              Navigator.pop(context);
                            },
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
      },
    );
  }

  Widget _minimalDateItem(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDateTime(context, controller),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            controller.text.isNotEmpty ? controller.text : "Select",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _minimalDaysItemDays(String label, TextEditingController controller) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
        Text(
          controller.text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isTransparent = false,
  }) {
    return Card(
      elevation: isTransparent ? 0 : 1,
      color: isTransparent ? Colors.transparent : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTransparent ? 0 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTransparent)
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF2a86c9), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ...children,
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr, {bool includeTime = false}) {
    if (dateStr.isEmpty) return "";
    try {
      DateTime dateTime;
      if (dateStr.contains(" ")) {
        dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr);
      } else {
        dateTime = DateFormat("yyyy-MM-dd").parse(dateStr);
      }
      return DateFormat(includeTime ? "dd-MM-yyyy HH:mm" : "dd-MM-yyyy")
          .format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _invoiceDateController.dispose();
    _totalDaysController.dispose();
    _advanceAmountController.dispose();
    _totalPaidAmountController.dispose();
    _discountController.dispose();
    _otherExpensesController.dispose();
    _rentIssueIdController.dispose();
    _invoiceNoController.dispose();
    _remarksController.dispose();
    _productSearchController.dispose();
    _transportationChargesController.dispose();
    _otherTransportationChargesController.dispose();

    _billingNameController.dispose();
    _billingAddressLine1Controller.dispose();
    _billingAddressLine2Controller.dispose();
    _billingAddressLine3Controller.dispose();
    _billingPincodeController.dispose();
    _billingPostOfficeController.dispose();
    _billingMobileController.dispose();
    _billingWhatsappController.dispose();
    _billingGstController.dispose();

    _shippingNameController.dispose();
    _shippingAddressLine1Controller.dispose();
    _shippingAddressLine2Controller.dispose();
    _shippingAddressLine3Controller.dispose();
    _shippingPincodeController.dispose();
    _shippingPostOfficeController.dispose();
    _shippingMobileController.dispose();
    _shippingWhatsappController.dispose();
    _shippingGstController.dispose();

    for (var row in _addonProductRows) {
      row.quantityController.dispose();
    }
    for (var row in _labourRows) {
      row.dispose();
    }
    super.dispose();
  }

  Widget _phoneInputField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.outlined_flag, size: 16, color: Colors.black54),
                SizedBox(width: 4),
                Text(
                  "+91",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: "Enter number",
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleAddressSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required TextEditingController nameController,
    required TextEditingController addr1Controller,
    required TextEditingController addr2Controller,
    required TextEditingController addr3Controller,
    required TextEditingController pinController,
    required TextEditingController postController,
    required TextEditingController mobileController,
    required TextEditingController whatsappController,
    required TextEditingController gstController,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: const Color(0xFF2a86c9), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF2a86c9),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildFormRow(
                      "Name",
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration()
                            .copyWith(hintText: "Company Name"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormRow(
                      "Address Line 1",
                      TextFormField(
                        controller: addr1Controller,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration()
                            .copyWith(hintText: "Address Line 1"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFormRow(
                      "Address Line 2",
                      TextFormField(
                        controller: addr2Controller,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration()
                            .copyWith(hintText: "Address Line 2"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormRow(
                      "Address Line 3",
                      TextFormField(
                        controller: addr3Controller,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration()
                            .copyWith(hintText: "Address Line 3"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFormRow(
                      "Pin Code",
                      TextFormField(
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration:
                            _inputDecoration().copyWith(hintText: "Pin Code"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormRow(
                      "Post Office",
                      TextFormField(
                        controller: postController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration()
                            .copyWith(hintText: "Post Office"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFormRow(
                      "Mobile Number",
                      _phoneInputField(mobileController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormRow(
                      "Whatsapp Number",
                      _phoneInputField(whatsappController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFormRow(
                      "GST Number",
                      TextFormField(
                        controller: gstController,
                        style: const TextStyle(fontSize: 13),
                        decoration:
                            _inputDecoration().copyWith(hintText: "Tax Number"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddonProductsSection() {
    return _buildSectionCard(
      title: 'Add-on Products',
      icon: Icons.grid_view_rounded,
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 35,
                      child: Text(
                        "Sl",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                        width: 1, height: 18, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                    const Expanded(
                      flex: 5,
                      child: Text(
                        "Product",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                        width: 1, height: 18, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                    const Expanded(
                      flex: 4,
                      child: Text(
                        "Quantity",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                        width: 1, height: 18, color: Colors.grey.shade300),
                    const SizedBox(
                      width: 55,
                      child: Text(""),
                    ),
                  ],
                ),
              ),
              // Body Rows
              if (_addonProductRows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No add-on products added.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                )
              else
                ...List.generate(_addonProductRows.length, (index) {
                  return Column(
                    children: [
                      _buildAddonRow(index),
                      if (index < _addonProductRows.length - 1)
                        Divider(height: 1, color: Colors.grey.shade300),
                    ],
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _addonProductRows.add(AddonProductRow());
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF334155),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text(
            "Add Row",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildAddonRow(int index) {
    final row = _addonProductRows[index];
    final mat = _materials.firstWhere(
      (m) => m.materialId == row.selectedProductId,
      orElse: () => MaterialData(),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sl No Column
          SizedBox(
            width: 35,
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          // Product Column
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => _showAddonProductSelectionDialog(index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.selectedProductId != null
                              ? (mat.materialName ?? "Select Product")
                              : "Select Product",
                          style: TextStyle(
                            fontSize: 13,
                            color: row.selectedProductId != null
                                ? Colors.black87
                                : Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (row.selectedProductId != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              row.selectedProductId = null;
                              row.currentStock = null;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child:
                                Icon(Icons.close, size: 14, color: Colors.grey),
                          ),
                        ),
                      const Icon(Icons.arrow_drop_down,
                          size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          // Quantity Column
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: row.quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                  ),
                  if (row.selectedProductId != null) ...[
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final stockVal =
                            double.tryParse(mat.currentStock ?? "0") ?? 0;
                        final isAvailable = stockVal > 0;
                        return Text(
                          "Available stock : ${mat.currentStock ?? '0'}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? const Color(0xFF16A34A)
                                : Colors.red.shade700,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          // Delete Column
          SizedBox(
            width: 55,
            child: Center(
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEE5253),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 18),
                  onPressed: () {
                    setState(() {
                      row.quantityController.dispose();
                      _addonProductRows.removeAt(index);
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddonProductSelectionDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<MaterialData> filtered = _materials
                .where((m) => (m.materialName ?? "")
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();
            return AlertDialog(
              title: const Text("Select Add-on Product",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (val) =>
                          setDialogState(() => searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: "Search Product...",
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final mat = filtered[idx];
                          final stock =
                              double.tryParse(mat.currentStock ?? "0") ?? 0;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            title: Text(
                              mat.materialName ?? "Unknown Product",
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "Stock: ${mat.currentStock ?? '0'} | Price: ₹${mat.unitPrice ?? '0'}",
                              style: TextStyle(
                                fontSize: 11,
                                color: stock > 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _addonProductRows[index].selectedProductId =
                                    mat.materialId;
                                _addonProductRows[index].currentStock =
                                    mat.currentStock;
                              });
                              Navigator.pop(context);
                            },
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
      },
    );
  }
}

class ProductRow {
  final TextEditingController quantityController =
      TextEditingController(text: "1");
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController ratePerDayController = TextEditingController();
  final TextEditingController noOfDaysController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController grossAmountController = TextEditingController();
  final TextEditingController gstPercentController = TextEditingController();
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  String? selectedProductId;
  String? currentStock;
  bool hasGst = false;
  bool isExpanded = false;

  ProductRow();
}

class AddonProductRow {
  String? selectedProductId;
  final TextEditingController quantityController =
      TextEditingController(text: "1");
  String? currentStock;

  AddonProductRow(
      {this.selectedProductId, String qty = "1", this.currentStock}) {
    quantityController.text = qty;
  }
}

class LabourRow {
  String? selectedLabourId;
  String? labourName;
  final TextEditingController rateController = TextEditingController();
  final TextEditingController daysController =
      TextEditingController(text: "1"); // hours when rent type is hourly
  final TextEditingController amountController =
      TextEditingController(text: "0.00");

  LabourRow();

  void dispose() {
    rateController.dispose();
    daysController.dispose();
    amountController.dispose();
  }
}
