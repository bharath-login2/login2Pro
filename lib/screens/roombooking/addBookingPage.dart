import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/models/roomManagement/editListModel.dart';
import 'package:login2/models/roomManagement/roomNumberListModel.dart';
import 'package:login2/models/roomManagement/roomProductsModel.dart';
import 'package:login2/models/roomManagement/roomTypesModel.dart';
import 'package:login2/service/service.dart';
import 'package:image_picker/image_picker.dart';

class AddBookingPage extends StatefulWidget {
  final String? bookingId;
  const AddBookingPage({super.key, this.bookingId});
  @override
  State<AddBookingPage> createState() => _AddBookingPageState();
}

class _AddBookingPageState extends State<AddBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _bookingDateController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
    final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  File? _idProofFile;
  final ImagePicker _picker = ImagePicker();
  final List<String> _customerTypes = ['Premium', 'Normal'];
  String? _selectedCustomerType;
  final List<String> _bookingTypes = ['Online', 'Offline'];
  String? _selectedBookingType;
  final List<String> _paymentStatuses = ['Paid', 'Unpaid', 'Partially Paid'];
  final List<String> _paymentModes = ['Cash', 'Card', 'UPI', 'Bank Transfer'];
  final List<String> _stayTypes = ['Day', 'Hourly'];
  String _selectedStayType = 'Day';
  List<RoomTypeData> _roomTypes = [];
  List<RoomNumberData> _roomNumbers = [];
  List<RoomProductData> _roomProducts = [];
  bool _isLoadingRoomTypes = false;
  bool _isLoadingRoomNumbers = false;
  bool _isLoadingProducts = false;
  bool _showAddOns = false;
  List<StateList> _states = [];
  List<DistrictList> _districts = [];
  String? _selectedStateId;
  String? _selectedDistrictId;
  bool _isLoadingStates = false;
  bool _isLoadingDistricts = false;
  PostalCodeModel? _postalData;
  bool isLoadingState = true;
  bool isLoadingDistrict = false;
  List<StateList> stateList = [];
  List<DistrictList> districtList = [];
  String? selectedStateId;
  String? selectedStateName;
  String? selectedDistrictId;
  String? selectedDistrictName;
  final stateController = TextEditingController();
  final districtController = TextEditingController();
  double _advancePaid = 0.0;
  double _balanceAmount = 0.0;
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();
  String? _selectedPaymentStatus;
  String? _selectedPaymentMode;
  List<RoomRowData> _roomRows = [RoomRowData()];
  List<ProductRowData> _productRows = [ProductRowData()];
  bool _isSubmitting = false;
  bool _isEditMode = false;
  bool _isLoadingBookingDetails = false;
  BookingDetailsResponse? _bookingDetails;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.bookingId != null;
    final now = DateTime.now();
    _bookingDateController.text = DateFormat('dd-MM-yyyy').format(now);
    _checkInController.text = DateFormat('dd-MM-yyyy HH:mm').format(now);
    _checkOutController.text =
        DateFormat('dd-MM-yyyy HH:mm').format(now.add(const Duration(days: 1)));
    _invoiceDateController.text = DateFormat('dd-MM-yyyy').format(now);
    _selectedCustomerType = _customerTypes.first;
    _selectedBookingType = _bookingTypes.first;
    _advanceController.addListener(_calculateBalance);
    _balanceController.text = '0.00';
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _fetchStates();
    await _fetchRoomTypes();
    await _fetchRoomProducts();
    if (_isEditMode && widget.bookingId != null) {
      await _loadBookingDetails();
    }
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoadingBookingDetails = true;
    });

    try {
      final response = await HttpService.getListDataOnEdit(widget.bookingId!);

      if (response != null && response.status) {
        _bookingDetails = response;
        await _populateFormData(response.data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response?.message ?? 'Failed to load booking details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error loading booking details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error loading booking details'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingBookingDetails = false;
      });
    }
  }

  Future<void> _populateFormData(BookingData bookingData) async {
    await Future.wait([
      if (_roomTypes.isEmpty) _fetchRoomTypes(),
      if (_roomProducts.isEmpty) _fetchRoomProducts(),
    ]);

    final booking = bookingData.bookingDetails;
    final rooms = bookingData.bookingRoomsList;
    final products = bookingData.productDetails;

    _guestNameController.text = booking.name;
     _customerIdController.text = booking.customerId;
    _phoneController.text = booking.contactNo;
    _emailController.text = booking.emailId;
    _address1Controller.text = booking.address;
    _pinCodeController.text = booking.pincode;
    _postOfficeController.text = booking.postOffice;
    _selectedCustomerType = booking.customerType.isNotEmpty
        ? booking.customerType
        : _customerTypes.first;
    selectedStateId = booking.stateId.isNotEmpty ? booking.stateId : null;
    selectedDistrictId =
        booking.districtId.isNotEmpty ? booking.districtId : null;
    _selectedStayType = booking.stayType.isNotEmpty
        ? (booking.stayType == 'Hourly' ? 'Hourly' : 'Day')
        : 'Day';
    _selectedBookingType = booking.bookingType.isNotEmpty
        ? booking.bookingType
        : _bookingTypes.first;
    _bookingDateController.text = booking.bookingDate.isNotEmpty
        ? booking.bookingDate
        : DateFormat('dd-MM-yyyy').format(DateTime.now());
    _checkInController.text = booking.checkInDate.isNotEmpty
        ? booking.checkInDate
        : DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    _checkOutController.text = (rooms.isNotEmpty && rooms.first.checkOutDate.isNotEmpty)
        ? rooms.first.checkOutDate
        : DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now().add(const Duration(days: 1)));
    _invoiceNumberController.text = booking.invoiceNumber;
    _invoiceDateController.text = booking.invoiceDate.isNotEmpty
        ? booking.invoiceDate
        : DateFormat('dd-MM-yyyy').format(DateTime.now());
    _selectedPaymentStatus =
        booking.paymentStatus.isNotEmpty ? booking.paymentStatus : null;
    _selectedPaymentMode =
        booking.lastPaymentMethod.isNotEmpty ? booking.lastPaymentMethod : null;
    _advanceController.text =
        booking.totalAmountPaid.isNotEmpty ? booking.totalAmountPaid : '0';

    double totalAmount = double.tryParse(booking.totalAmount) ?? 0;
    double totalPaid = double.tryParse(booking.totalAmountPaid) ?? 0;
    _balanceAmount = totalAmount - totalPaid;
    _balanceController.text = _balanceAmount.toStringAsFixed(2);
    _roomRows.clear();
    if (rooms.isNotEmpty) {
      for (var room in rooms) {
        if (room.roomTypeId.isNotEmpty && room.roomNumberId.isNotEmpty) {
          await _fetchRoomNumbers(room.roomTypeId, _roomRows.length);
          final roomTypeExists =
              _roomTypes.any((rt) => rt.id == room.roomTypeId);
          if (roomTypeExists) {
            _roomRows.add(RoomRowData(
              selectedRoomTypeId: room.roomTypeId,
              selectedRoomId: room.roomNumberId,
              roomPrice: double.tryParse(room.amount) ?? 0,
              taxPercentage: double.tryParse(room.taxPercent) ?? 0,
              isHourly: booking.stayType == 'Hourly',
              days: int.tryParse(room.days) ?? 1,
              hours: int.tryParse(room.hour) ?? 1,
              adults: int.tryParse(room.adult) ?? 1,
              children: int.tryParse(room.children) ?? 0,
              subtotal: double.tryParse(room.totalAmount) ?? 0,
              total: double.tryParse(room.totalAmount) ?? 0,
            ));
          }
        }
      }
    }

    if (_roomRows.isEmpty) {
      _roomRows.add(RoomRowData(isHourly: booking.stayType == 'Hourly'));
    }
    if (products.isNotEmpty) {
      _showAddOns = true;
      _productRows.clear();
      for (var product in products) {
        _productRows.add(ProductRowData(
          id: product.id,
          productId: product.productId,
          productName: product.productName,
          rate: double.tryParse(product.rate) ?? 0,
          quantity: int.tryParse(product.quantity) ?? 1,
          tax: double.tryParse(product.tax) ?? 0,
          amount: double.tryParse(product.amount) ?? 0,
          subtotal: double.tryParse(product.rate) ?? 0,
          taxAmount: (double.tryParse(product.tax) ?? 0) / 100 *
              (double.tryParse(product.rate) ?? 0) *
              (int.tryParse(product.quantity) ?? 1),
          total: double.tryParse(product.amount) ?? 0,
        ));
      }
    } else {
      _showAddOns = false;
      _productRows = [ProductRowData()];
    }

    // Handle state and district
    final targetDistrictId =
        booking.districtId.trim().isNotEmpty ? booking.districtId.trim() : null;
    selectedStateId =
        booking.stateId.trim().isNotEmpty ? booking.stateId.trim() : null;

    if (selectedStateId != null && selectedStateId!.isNotEmpty) {
      if (stateList.isEmpty) {
        await _fetchStates();
      }
      if (stateList.isNotEmpty) {
        final state = stateList.firstWhere(
          (s) => s.id == selectedStateId,
          orElse: () => StateList(id: '', name: ''),
        );
        if (state.id.isNotEmpty) {
          stateController.text = state.name;
          selectedStateName = state.name;
          await _fetchDistricts(selectedStateId!);
          if (targetDistrictId != null && targetDistrictId.isNotEmpty) {
            selectedDistrictId = targetDistrictId;
            if (districtList.isNotEmpty) {
              final district = districtList.firstWhere(
                (d) => d.id == selectedDistrictId,
                orElse: () => DistrictList(id: '', name: ''),
              );
              if (district.id.isNotEmpty) {
                districtController.text = district.name;
                selectedDistrictName = district.name;
              }
            }
          }
        }
      }
    }

    _calculateBalance();
    setState(() {});
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _advanceController.dispose();
    _balanceController.dispose();
    _transactionIdController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchStates() async {
    setState(() => isLoadingState = true);
    try {
      final response = await HttpService.getState();
      if (response != null && response.status) {
        setState(() {
          stateList = response.data;
          isLoadingState = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to load states'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoadingState = false);
      }
    } catch (e) {
      print('Error fetching states: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error loading states'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoadingState = false);
    }
  }

  Future<void> _fetchDistricts(String stateId) async {
    setState(() {
      isLoadingDistrict = true;
      districtList = [];
      selectedDistrictId = null;
      selectedDistrictName = null;
      districtController.clear();
    });

    try {
      final response = await HttpService.getDistrict(stateId);
      if (response != null && response.status) {
        setState(() {
          districtList = response.data;
          isLoadingDistrict = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to load districts'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoadingDistrict = false);
      }
    } catch (e) {
      print('Error fetching districts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error loading districts'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoadingDistrict = false);
    }
  }

  Future<void> _fetchPostOffice(String pinCode) async {
    if (pinCode.length >= 6) {
      try {
        final response = await HttpService.fetchPostOffice(pinCode);
        setState(() {
          _postalData = response;
        });
      } catch (e) {
        print('Error fetching post office: $e');
      }
    } else {
      setState(() {
        _postalData = null;
        _postOfficeController.clear();
      });
    }
  }

  Future<void> _fetchRoomTypes() async {
    setState(() {
      _isLoadingRoomTypes = true;
    });

    try {
      final response = await HttpService.getRoomTypes();
      if (response != null && response.status) {
        setState(() {
          _roomTypes = response.data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to load room types'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching room types: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error loading room types'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingRoomTypes = false;
      });
    }
  }

  Future<void> _fetchRoomNumbers(String roomTypeId, int rowIndex) async {
    if (roomTypeId.isEmpty) return;

    setState(() {
      _isLoadingRoomNumbers = true;
    });

    try {
      final response = await HttpService.getRoomNumbers(roomTypeId);
      if (response != null && response.status) {
        setState(() {
          _roomNumbers = response.data
              .where((room) => room.isAvailable == 'Y' || room.isAvailable == true)
              .toList();

          // Reset the selected room if it's no longer in the list
          if (rowIndex < _roomRows.length) {
            final roomRow = _roomRows[rowIndex];
            if (roomRow.selectedRoomId != null && roomRow.selectedRoomId!.isNotEmpty) {
              final roomExists =
                  _roomNumbers.any((room) => room.id == roomRow.selectedRoomId);
              if (!roomExists) {
                roomRow.selectedRoomId = null;
                roomRow.selectedRoomNumber = null;
                roomRow.roomPrice = null;
                roomRow.taxPercentage = null;
              }
            }
            _calculateTotal(rowIndex);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to load room numbers'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching room numbers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error loading room numbers'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingRoomNumbers = false;
      });
    }
  }

  Future<void> _fetchRoomProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final response = await HttpService.getRoomProducts();
      if (response != null && response.status) {
        setState(() {
          _roomProducts = response.data;
          // Pre-select first product for new rows
          if (_roomProducts.isNotEmpty && _productRows.isNotEmpty) {
            final row = _productRows[0];
            if (row.productId == null || row.productId!.isEmpty) {
              final product = _roomProducts[0];
              row.productId = product.id;
              row.productName = product.productName;
              row.rate = product.sellingPriceAsDouble;
              row.tax = product.taxPercentAsDouble;
              _calculateProductTotal(0);
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to load products'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error loading products'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _idProofFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error selecting image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _idProofFile = File(photo.path);
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error taking photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStateSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _StateSearchDialog(
        stateList: stateList,
        selectedStateId: selectedStateId,
        onStateSelected: (state) {
          setState(() {
            selectedStateId = state.id;
            selectedStateName = state.name;
            stateController.text = state.name;
            selectedDistrictId = null;
            selectedDistrictName = null;
            districtController.clear();
            districtList.clear();
          });
          Navigator.pop(context);
          _fetchDistricts(state.id);
        },
      ),
    );
  }

  void _showDistrictSearchDialog() {
    if (selectedStateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select state first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (districtList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Loading districts...'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _DistrictSearchDialog(
        districtList: districtList,
        selectedDistrictId: selectedDistrictId,
        onDistrictSelected: (district) {
          setState(() {
            selectedDistrictId = district.id;
            selectedDistrictName = district.name;
            districtController.text = district.name;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFilePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload ID Proof'),
        content: const Text('Choose image source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhotoWithCamera();
            },
            child: const Text('Camera'),
          ),
          if (_idProofFile != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _idProofFile = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _onRoomTypeChanged(String? roomTypeId, int rowIndex) {
    if (roomTypeId != null && roomTypeId.isNotEmpty) {
      setState(() {
        _roomRows[rowIndex].selectedRoomTypeId = roomTypeId;
        // Clear room number when room type changes
        _roomRows[rowIndex].selectedRoomId = null;
        _roomRows[rowIndex].selectedRoomNumber = null;
        _roomRows[rowIndex].roomPrice = null;
        _roomRows[rowIndex].taxPercentage = null;
      });
      _fetchRoomNumbers(roomTypeId, rowIndex);
    }
  }

  void _onRoomNumberChanged(String? roomId, int rowIndex) {
    if (roomId != null && roomId.isNotEmpty) {
      final room = _roomNumbers.firstWhere(
        (r) => r.id == roomId,
        orElse: () => RoomNumberData(
          id: '',
          roomNo: '',
          roomName: '',
          price: '0',
          taxPercentage: '0',
          roomFacility: '',
          roomDescription: '',
          isMaintenance: 'N',
        ),
      );

      setState(() {
        _roomRows[rowIndex].selectedRoomId = roomId;
        _roomRows[rowIndex].selectedRoomNumber = room.roomNo;
        _roomRows[rowIndex].roomPrice = double.tryParse(room.price) ?? 0;
        _roomRows[rowIndex].taxPercentage =
            double.tryParse(room.taxPercentage) ?? 0;
        _calculateTotal(rowIndex);
      });
    }
  }

  void _calculateTotal(int rowIndex) {
    final row = _roomRows[rowIndex];

    if (row.roomPrice == null) return;

    double basePrice = row.roomPrice ?? 0;
    int quantity = row.isHourly ? row.hours : row.days;
    double taxPercentage = row.taxPercentage ?? 0;

    row.subtotal = basePrice * quantity;
    row.taxAmount = (row.subtotal! * taxPercentage) / 100;
    row.total = (row.subtotal! + row.taxAmount!);

    setState(() {});
  }

  void _onQuantityChanged(String value, int rowIndex) {
    int quantity = int.tryParse(value) ?? 1;
    if (quantity < 1) quantity = 1;

    setState(() {
      if (_roomRows[rowIndex].isHourly) {
        _roomRows[rowIndex].hours = quantity;
      } else {
        _roomRows[rowIndex].days = quantity;
      }
      _calculateTotal(rowIndex);
      _updateCheckoutDate();
    });
  }

  void _onDaysIncrement(int rowIndex) {
    setState(() {
      _roomRows[rowIndex].days++;
      _calculateTotal(rowIndex);
      _updateCheckoutDate();
    });
  }

  void _onDaysDecrement(int rowIndex) {
    if (_roomRows[rowIndex].days > 1) {
      setState(() {
        _roomRows[rowIndex].days--;
        _calculateTotal(rowIndex);
        _updateCheckoutDate();
      });
    }
  }

  void _updateCheckoutDate() {
    if (_checkInController.text.isNotEmpty) {
      try {
        final checkInDate = _checkInController.text.contains(' ')
            ? DateFormat('dd-MM-yyyy HH:mm').parse(_checkInController.text)
            : DateFormat('dd-MM-yyyy').parse(_checkInController.text);
        int maxDays = 0;
        int maxHours = 0;
        
        bool isHourly = _selectedStayType == 'Hourly';
        
        for (var row in _roomRows) {
          if (isHourly) {
            if (row.hours > maxHours) maxHours = row.hours;
          } else {
            if (row.days > maxDays) maxDays = row.days;
          }
        }
        
        // Ensure at least 1 day or 1 hour
        if (!isHourly && maxDays == 0) maxDays = 1;
        if (isHourly && maxHours == 0) maxHours = 1;

        final checkoutDate = isHourly 
            ? checkInDate.add(Duration(hours: maxHours))
            : checkInDate.add(Duration(days: maxDays));
            
        _checkOutController.text =
            DateFormat('dd-MM-yyyy HH:mm').format(checkoutDate);
      } catch (e) {
        print('Error updating checkout date: $e');
      }
    }
  }

  void _onTaxChanged(String value, int rowIndex) {
    double tax = double.tryParse(value) ?? 0;
    setState(() {
      _roomRows[rowIndex].taxPercentage = tax;
      _calculateTotal(rowIndex);
    });
  }

  void _onProductChanged(String? productId, int rowIndex) {
    if (productId != null && productId.isNotEmpty) {
      final product = _roomProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => RoomProductData(
          id: '',
          productName: '',
          taxPercent: '0',
          totalAmount: '0',
          sellingPrice: '0',
          description: '',
        ),
      );

      setState(() {
        _productRows[rowIndex].productId = productId;
        _productRows[rowIndex].productName = product.productName;
        _productRows[rowIndex].rate = product.sellingPriceAsDouble;
        _productRows[rowIndex].tax = product.taxPercentAsDouble;
        _calculateProductTotal(rowIndex);
      });
    }
  }

  void _onProductQuantityChanged(String value, int rowIndex) {
    int quantity = int.tryParse(value) ?? 1;
    if (quantity < 1) quantity = 1;

    setState(() {
      _productRows[rowIndex].quantity = quantity;
      _calculateProductTotal(rowIndex);
    });
  }

  void _onProductRateChanged(String value, int rowIndex) {
    double rate = double.tryParse(value) ?? 0;
    setState(() {
      _productRows[rowIndex].rate = rate;
      _calculateProductTotal(rowIndex);
    });
  }

  void _onProductTaxChanged(String value, int rowIndex) {
    double tax = double.tryParse(value) ?? 0;
    setState(() {
      _productRows[rowIndex].tax = tax;
      _calculateProductTotal(rowIndex);
    });
  }

  void _calculateProductTotal(int rowIndex) {
    final row = _productRows[rowIndex];

    row.subtotal = row.rate * row.quantity;
    row.taxAmount = (row.subtotal * row.tax) / 100;
    row.amount = row.subtotal + row.taxAmount;

    setState(() {});
  }

  void _calculateBalance() {
    double advance = double.tryParse(_advanceController.text) ?? 0.0;
    double grandTotal = _calculateGrandTotal();
    double balance = grandTotal - advance;

    setState(() {
      _advancePaid = advance;
      _balanceAmount = balance > 0 ? balance : 0;
      _balanceController.text = _balanceAmount.toStringAsFixed(2);
    });
  }

  double _calculateGrandTotal() {
    double total = 0;
    for (var row in _roomRows) {
      total += row.total ?? 0;
    }
    if (_showAddOns) {
      for (var row in _productRows) {
        total += row.amount;
      }
    }
    return total;
  }

  void _showPostOfficeDialog() {
    if (_postalData == null || _postalData!.postOffice == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Post Office'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _postalData!.postOffice!.length,
            itemBuilder: (context, index) {
              final postOffice = _postalData!.postOffice![index];
              return ListTile(
                title: Text(postOffice.name ?? ''),
                onTap: () {
                  setState(() {
                    _postOfficeController.text = postOffice.name ?? '';
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;
    if (_checkInController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select check-in date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      bool allRoomsValid = true;
      for (int i = 0; i < _roomRows.length; i++) {
        final row = _roomRows[i];
        if (row.selectedRoomTypeId == null || row.selectedRoomId == null) {
          allRoomsValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please select room type and room number for Room ${i + 1}'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        }
      }
      
      if (_showAddOns) {
        for (int i = 0; i < _productRows.length; i++) {
          final row = _productRows[i];
          if (row.productId == null || row.productId!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select product for Product ${i + 1}'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }
      
      if (_selectedPaymentStatus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select payment status'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!allRoomsValid) return;
      setState(() => _isSubmitting = true);
      try {
        final formData = {
          'guest': {
            'name': _guestNameController.text.trim(),
            'customerId': _customerIdController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'addressLine1': _address1Controller.text.trim(),
            'addressLine2': _address2Controller.text.trim(),
            'pinCode': _pinCodeController.text.trim(),
            'stateId': selectedStateId,
            'districtId': selectedDistrictId,
            'postOffice': _postOfficeController.text.trim(),
            'customerType': _selectedCustomerType,
          },
          'booking': {
            'stayType': _selectedStayType,
            'bookingType': _selectedBookingType,
            'bookingDate': _bookingDateController.text,
            'checkInDate': _checkInController.text,
            'checkOutDate': _checkOutController.text,
            'invoiceNumber': _invoiceNumberController.text.trim(),
            'invoiceDate': _invoiceDateController.text,
          },
          'rooms': _roomRows.map((row) => row.toMap()).toList(),
          'products': _showAddOns ? _productRows.where((row) => row.productId != null && row.productId!.isNotEmpty).map((row) => row.toMap()).toList() : [],
          'payment': {
            'status': _selectedPaymentStatus,
            'mode': _selectedPaymentMode,
            'totalAmount': _calculateGrandTotal(),
            'advancePaid': _advancePaid,
            'balanceAmount': _balanceAmount,
            'transactionId': _transactionIdController.text.trim(),
          },
        };

        if (_isEditMode && widget.bookingId != null) {
          formData['bookingId'] = widget.bookingId!;
        }

        print('Submitting booking data: $formData');
        final response = await HttpService.submitBooking(
          bookingData: formData,
          idProofFile: _idProofFile,
          isEdit: _isEditMode,
        );

        if (response != null && response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode
                  ? 'Booking updated successfully!'
                  : 'Booking created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode
                  ? 'Failed to update booking'
                  : 'Failed to create booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error submitting booking: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Error updating booking'
                : 'Error submitting booking'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Edit Booking" : "Add New Booking",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoadingBookingDetails
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading booking details...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(255, 22, 145, 216)
                                    .withOpacity(0.1),
                                const Color.fromARGB(255, 22, 145, 216)
                                    .withOpacity(0.05),
                              ]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color.fromARGB(255, 22, 145, 216)
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 22, 145, 216),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isEditMode
                                    ? Icons.edit
                                    : Icons.add_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditMode
                                        ? 'Edit Booking'
                                        : 'New Booking',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    _isEditMode
                                        ? 'Update booking details as needed'
                                        : 'Fill all required fields to create a new booking',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isEditMode && widget.bookingId != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ID: ${widget.bookingId!.length > 8 ? '${widget.bookingId!.substring(0, 8)}...' : widget.bookingId!}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildSection(
                        title: 'Guest Details',
                        icon: Icons.person_outline,
                        iconColor: Colors.purple,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildResponsiveRow([
                              _buildTextField(
                                label: 'Guest Name *',
                                controller: _guestNameController,
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter guest name';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Phone Number *',
                                controller: _phoneController,
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  if (value.length < 10) {
                                    return 'Enter valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Email Address',
                                controller: _emailController,
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildResponsiveRow([
                              _buildTextField(
                                label: 'Address Line 1',
                                controller: _address1Controller,
                                icon: Icons.location_on,
                              ),
                              _buildTextField(
                                label: 'Address Line 2',
                                controller: _address2Controller,
                                icon: Icons.location_on,
                              ),
                              _buildPinCodeField(),
                            ]),
                            const SizedBox(height: 12),
                            _buildResponsiveRow([
                              _buildDropdown(
                                label: 'Customer Type *',
                                items: _customerTypes,
                                icon: Icons.group,
                                value: _selectedCustomerType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCustomerType = value;
                                  });
                                },
                              ),
                              _buildStateDropdown(),
                              _buildDistrictDropdown(),
                            ]),
                            const SizedBox(height: 12),
                            if (_pinCodeController.text.length == 6 &&
                                _postalData != null)
                              _buildResponsiveRow([
                                _buildPostOfficeField(),
                              ]),
                            const SizedBox(height: 12),
                            _buildFileUploadField(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'Booking Details',
                        icon: Icons.calendar_month,
                        iconColor: Colors.blue,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildResponsiveRow([
                              _buildStayTypeDropdown(),
                              _buildDropdown(
                                label: 'Booking Type *',
                                items: _bookingTypes,
                                icon: Icons.type_specimen,
                                value: _selectedBookingType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBookingType = value;
                                  });
                                },
                              ),
                              _buildDateField(
                                label: 'Booking Date *',
                                controller: _bookingDateController,
                                icon: Icons.date_range,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _buildResponsiveRow([
                              _buildDateField(
                                label: 'Check-in Date *',
                                controller: _checkInController,
                                icon: Icons.login,
                                selectTime: true,
                              ),
                              // _buildDateField(
                              //   label: 'Check-out Date *',
                              //   controller: _checkOutController,
                              //   icon: Icons.logout,
                              //   selectTime: true,
                              // ),
                            ]),
                            const SizedBox(height: 12),
                            _buildResponsiveRow([
                              _buildTextField(
                                label: 'Invoice Number',
                                controller: _invoiceNumberController,
                                icon: Icons.receipt,
                              ),
                              _buildDateField(
                                label: 'Invoice Date',
                                controller: _invoiceDateController,
                                icon: Icons.calendar_today,
                              ),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'Room Details',
                        icon: Icons.king_bed,
                        iconColor: Colors.green,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            ...List.generate(_roomRows.length, (index) {
                              final row = _roomRows[index];
                              final isHourly = _selectedStayType == 'Hourly';
                              row.isHourly = isHourly;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    if (_roomRows.length > 1)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Room ${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          if (index > 0)
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red.shade600,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _roomRows.removeAt(index);
                                                  _updateCheckoutDate();
                                                });
                                              },
                                              tooltip: 'Remove Room',
                                            ),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    _buildRoomTypeDropdown(index),
                                    const SizedBox(height: 12),
                                    if (row.selectedRoomTypeId != null &&
                                        row.selectedRoomTypeId!.isNotEmpty)
                                      _buildRoomNumberDropdown(index),
                                    if (row.selectedRoomId != null &&
                                        row.selectedRoomId!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      _buildResponsiveRow([
                                        _buildTextField(
                                          label: 'Adults',
                                          icon: Icons.person,
                                          keyboardType: TextInputType.number,
                                          initialValue: row.adults.toString(),
                                          onChanged: (value) {
                                            setState(() {
                                              row.adults =
                                                  int.tryParse(value) ?? 1;
                                            });
                                          },
                                        ),
                                        _buildTextField(
                                          label: 'Children',
                                          icon: Icons.child_care,
                                          keyboardType: TextInputType.number,
                                          initialValue: row.children.toString(),
                                          onChanged: (value) {
                                            setState(() {
                                              row.children =
                                                  int.tryParse(value) ?? 0;
                                            });
                                          },
                                        ),
                                      ]),
                                      const SizedBox(height: 12),
                                      _buildResponsiveRow([
                                        _buildTextField(
                                          label: isHourly
                                              ? 'Amount per Hour*'
                                              : 'Amount*',
                                          icon: Icons.currency_rupee,
                                          keyboardType: TextInputType.number,
                                          readOnly: true,
                                          initialValue: row.roomPrice
                                                  ?.toStringAsFixed(2) ??
                                              '0.00',
                                        ),
                                        if (!isHourly) _buildDaysCounter(index),
                                        if (isHourly)
                                          _buildTextField(
                                            label: 'Hours*',
                                            icon: Icons.timer,
                                            keyboardType: TextInputType.number,
                                            initialValue: row.hours.toString(),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Required';
                                              }
                                              final val = int.tryParse(value);
                                              if (val == null || val < 1) {
                                                return 'Must be at least 1';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) =>
                                                _onQuantityChanged(
                                                    value, index),
                                          ),
                                        _buildTextField(
                                          label: 'Tax %',
                                          icon: Icons.percent,
                                          keyboardType: TextInputType.number,
                                          initialValue:
                                              row.taxPercentage?.toString() ??
                                                  '0',
                                          onChanged: (value) =>
                                              _onTaxChanged(value, index),
                                        ),
                                      ]),
                                      const SizedBox(height: 12),
                                      if (!isHourly)
                                        _buildResponsiveRow([
                                          _buildDateField(
                                            label: 'Check-out Date',
                                            controller: _checkOutController,
                                            icon: Icons.logout,
                                            readOnly: true,
                                            selectTime: true,
                                          ),
                                        ]),
                                      const SizedBox(height: 12),
                                      _buildResponsiveRow([
                                        _buildTextField(
                                          label: 'Subtotal',
                                          icon: Icons.calculate,
                                          keyboardType: TextInputType.number,
                                          readOnly: true,
                                          initialValue: row.subtotal
                                                  ?.toStringAsFixed(2) ??
                                              '0.00',
                                        ),
                                        _buildTextField(
                                          label: 'Tax Amount',
                                          icon: Icons.calculate,
                                          keyboardType: TextInputType.number,
                                          readOnly: true,
                                          initialValue: row.taxAmount
                                                  ?.toStringAsFixed(2) ??
                                              '0.00',
                                        ),
                                        _buildTextField(
                                          label: 'Total',
                                          icon: Icons.calculate,
                                          keyboardType: TextInputType.number,
                                          readOnly: true,
                                          initialValue:
                                              row.total?.toStringAsFixed(2) ??
                                                  '0.00',
                                        ),
                                      ]),
                                    ],
                                  ],
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _roomRows.add(RoomRowData(
                                        isHourly:
                                            _selectedStayType == 'Hourly'));
                                    _updateCheckoutDate();
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Another Room'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  foregroundColor: Colors.blue.shade700,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side:
                                        BorderSide(color: Colors.blue.shade200),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProductsCheckbox(),
                      const SizedBox(height: 16),
                      if (_showAddOns) _buildProductsSection(),
                      if (_showAddOns) const SizedBox(height: 16),
                      _buildSection(
                        title: 'Payment Details',
                        icon: Icons.payment,
                        iconColor: Colors.red,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildResponsiveRow([
                              _buildDropdown(
                                label: 'Payment Status *',
                                items: _paymentStatuses,
                                icon: Icons.payment,
                                value: _selectedPaymentStatus,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentStatus = value;

                                    if (value == 'Paid') {
                                      _advanceController.text =
                                          _calculateGrandTotal()
                                              .toStringAsFixed(2);
                                    } else if (value == 'Unpaid') {
                                      _advanceController.clear();
                                    }

                                    _calculateBalance();
                                  });
                                },
                              ),
                              _buildTextField(
                                label: 'Total Amount',
                                icon: Icons.currency_rupee,
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                initialValue:
                                    _calculateGrandTotal().toStringAsFixed(2),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            if (_selectedPaymentStatus != "Unpaid") ...[
                              _buildResponsiveRow([
                                _buildTextField(
                                  label: 'Advance Paid',
                                  icon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                  controller: _advanceController,
                                  onChanged: (value) {
                                    _calculateBalance();
                                  },
                                ),
                                _buildTextField(
                                  label: 'Balance Amount',
                                  icon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                  controller: _balanceController,
                                ),
                              ]),
                              const SizedBox(height: 12),
                              _buildResponsiveRow([
                                _buildDropdown(
                                  label: 'Payment Mode',
                                  items: _paymentModes,
                                  icon: Icons.credit_card,
                                  value: _selectedPaymentMode,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMode = value;
                                    });
                                  },
                                ),
                                _buildTextField(
                                  label: 'Transaction ID',
                                  icon: Icons.receipt_long,
                                  controller: _transactionIdController,
                                ),
                              ]),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.green.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calculate,
                                        color: Colors.green.shade700, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Booking Summary',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      Colors.green.shade800)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Stay Type: $_selectedStayType | Rooms: ${_roomRows.length}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600),
                                          ),
                                          if (_showAddOns)
                                            Text(
                                              'Products: ${_productRows.where((row) => row.productId != null && row.productId!.isNotEmpty).length}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600),
                                            ),
                                          Text(
                                            'Grand Total: ₹${_calculateGrandTotal().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.info_outline,
                                        color: Colors.green.shade700, size: 20),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _submitBooking,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 22, 145, 216),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              _isEditMode
                                                  ? Icons.save_as
                                                  : Icons.save,
                                              size: 20,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isEditMode
                                                ? 'Update Booking'
                                                : 'Save Booking',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFileUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Proof',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: _idProofFile == null
              ? ElevatedButton.icon(
                  onPressed: _showFilePickerDialog,
                  icon: Icon(
                    Icons.upload_file,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    'Upload ID Proof',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _idProofFile!.path.split('/').last,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _idProofFile = null;
                          });
                        },
                        tooltip: 'Remove file',
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProductsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Addons',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Checkbox(
            value: _showAddOns,
            onChanged: (value) {
              setState(() {
                _showAddOns = value ?? false;
                if (!_showAddOns) {
                  _productRows = [ProductRowData()];
                } else if (_productRows.isEmpty) {
                  _productRows = [ProductRowData()];
                }
              });
            },
            activeColor: const Color.fromARGB(255, 22, 145, 216),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return _buildSection(
      title: 'Products/Services',
      icon: Icons.shopping_cart,
      iconColor: Colors.orange,
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...List.generate(_productRows.length, (index) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.shade100,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  if (_productRows.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Product ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _productRows.removeAt(index);
                            });
                          },
                          tooltip: 'Remove Product',
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  _buildProductDropdown(index),
                  const SizedBox(height: 12),
                  _buildResponsiveRow([
                    _buildTextField(
                      label: 'Rate *',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      initialValue: _productRows[index].rate.toStringAsFixed(2),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                      onChanged: (value) => _onProductRateChanged(value, index),
                    ),
                    _buildTextField(
                      label: 'Quantity *',
                      icon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                      initialValue: _productRows[index].quantity.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 1) {
                          return 'Must be at least 1';
                        }
                        return null;
                      },
                      onChanged: (value) =>
                          _onProductQuantityChanged(value, index),
                    ),
                    _buildTextField(
                      label: 'Tax %',
                      icon: Icons.percent,
                      keyboardType: TextInputType.number,
                      initialValue: _productRows[index].tax.toString(),
                      onChanged: (value) => _onProductTaxChanged(value, index),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildResponsiveRow([
                    _buildTextField(
                      label: 'Subtotal',
                      icon: Icons.calculate,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      initialValue:
                          _productRows[index].subtotal.toStringAsFixed(2),
                    ),
                    _buildTextField(
                      label: 'Tax Amount',
                      icon: Icons.calculate,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      initialValue:
                          _productRows[index].taxAmount.toStringAsFixed(2),
                    ),
                    _buildTextField(
                      label: 'Total Amount',
                      icon: Icons.calculate,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      initialValue: _productRows[index].amount.toStringAsFixed(2),
                    ),
                  ]),
                ],
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _productRows.add(ProductRowData());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Another Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.orange.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDropdown(int rowIndex) {
    final currentProductId = _productRows[rowIndex].productId;
    final isValidProduct = currentProductId != null && 
                          currentProductId.isNotEmpty &&
                          _roomProducts.any((p) => p.id == currentProductId);

    return DropdownButtonFormField<String>(
      value: isValidProduct ? currentProductId : null,
      decoration: InputDecoration(
        labelText: 'Product/Service *',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: _isLoadingProducts
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.shopping_basket,
                size: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _roomProducts.map((RoomProductData product) {
        return DropdownMenuItem<String>(
          value: product.id,
          child: Text(
            product.productName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) => _onProductChanged(value, rowIndex),
      validator: _showAddOns
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select product';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDaysCounter(int rowIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Days*',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () => _onDaysDecrement(rowIndex),
                color: Colors.grey.shade600,
                splashRadius: 20,
              ),
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: TextEditingController(
                    text: _roomRows[rowIndex].days.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) => _onQuantityChanged(value, rowIndex),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val < 1) {
                      return 'Must be at least 1';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _onDaysIncrement(rowIndex),
                color: Colors.grey.shade600,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State*',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: stateController,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: isLoadingState
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.map, size: 18, color: Colors.grey.shade500),
            suffixIcon: const Icon(Icons.arrow_drop_down, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: 'Select State',
          ),
          onTap: _showStateSearchDialog,
          validator: (value) {
            if (selectedStateId == null) {
              return 'Please select state';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'District*',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: districtController,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: isLoadingDistrict
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.location_city,
                    size: 18, color: Colors.grey.shade500),
            suffixIcon: const Icon(Icons.arrow_drop_down, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: 'Select District',
          ),
          onTap: _showDistrictSearchDialog,
          validator: (value) {
            if (selectedDistrictId == null) {
              return 'Please select district';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPinCodeField() {
    return TextFormField(
      controller: _pinCodeController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: 'PIN Code',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.pin_drop, size: 18, color: Colors.grey.shade500),
        suffixIcon: _pinCodeController.text.length == 6
            ? Icon(Icons.search, color: Colors.blue.shade600)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterText: '',
      ),
      onChanged: (value) {
        if (value.length == 6) {
          _fetchPostOffice(value);
        } else if (value.length < 6) {
          setState(() {
            _postalData = null;
            _postOfficeController.clear();
          });
        }
      },
    );
  }

  Widget _buildPostOfficeField() {
    return TextFormField(
      controller: _postOfficeController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Post Office',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.local_post_office,
            size: 18, color: Colors.grey.shade500),
        suffixIcon:
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onTap: () {
        if (_postalData != null && _postalData!.postOffice != null) {
          _showPostOfficeDialog();
        }
      },
    );
  }

  Widget _buildStayTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStayType,
      decoration: InputDecoration(
        labelText: 'Stay Type *',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.hotel, size: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _stayTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStayType = value;
            // Update all room rows
            for (var row in _roomRows) {
              row.isHourly = value == 'Hourly';
              _calculateTotal(_roomRows.indexOf(row));
            }
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select stay type';
        }
        return null;
      },
    );
  }

  Widget _buildRoomTypeDropdown(int rowIndex) {
    final roomRow = _roomRows[rowIndex];
    final hasValidRoomType = roomRow.selectedRoomTypeId != null && 
                            roomRow.selectedRoomTypeId!.isNotEmpty &&
                            _roomTypes.any((room) => room.id == roomRow.selectedRoomTypeId);

    return DropdownButtonFormField<String>(
      value: hasValidRoomType ? roomRow.selectedRoomTypeId : null,
      decoration: InputDecoration(
        labelText: 'Room Type *',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: _isLoadingRoomTypes
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.category, size: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: _roomTypes.isEmpty ? 'Loading...' : 'Select Room Type',
      ),
      items: _roomTypes.isNotEmpty
          ? _roomTypes.map((RoomTypeData roomType) {
              return DropdownMenuItem<String>(
                value: roomType.id,
                child: Text(roomType.roomType),
              );
            }).toList()
          : [
              DropdownMenuItem<String>(
                value: 'loading',
                enabled: false,
                child:
                    Text(_isLoadingRoomTypes ? 'Loading...' : 'No room types'),
              )
            ],
      onChanged: _roomTypes.isNotEmpty
          ? (value) => _onRoomTypeChanged(value, rowIndex)
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select room type';
        }
        return null;
      },
    );
  }

  Widget _buildRoomNumberDropdown(int rowIndex) {
    final roomRow = _roomRows[rowIndex];
    final availableRooms = _roomNumbers
        .where((room) => room.isAvailable == true || room.isAvailable == 'Y')
        .toList();

    final hasValidRoom = roomRow.selectedRoomId != null && 
                        roomRow.selectedRoomId!.isNotEmpty &&
                        availableRooms.any((room) => room.id == roomRow.selectedRoomId);

    return DropdownButtonFormField<String>(
      value: hasValidRoom ? roomRow.selectedRoomId : null,
      decoration: InputDecoration(
        labelText: 'Room Number *',
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: _isLoadingRoomNumbers
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.meeting_room, size: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: availableRooms.isEmpty
            ? 'No rooms available'
            : 'Select Room Number',
      ),
      items: availableRooms.isNotEmpty
          ? availableRooms.map((RoomNumberData room) {
              return DropdownMenuItem<String>(
                value: room.id,
                child: Row(
                  children: [
                    Text(room.roomNo),
                    const SizedBox(width: 8),
                    Text(
                      room.formattedPrice,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (room.isMaintenance == 'Y')
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Maintenance',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList()
          : [
              DropdownMenuItem<String>(
                value: 'no_rooms',
                enabled: false,
                child: Text(_isLoadingRoomNumbers
                    ? 'Loading...'
                    : 'No rooms available'),
              )
            ],
      onChanged: availableRooms.isNotEmpty
          ? (value) => _onRoomNumberChanged(value, rowIndex)
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select room number';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    bool selectTime = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: Colors.grey.shade500)
                : null,
            suffixIcon: Icon(selectTime ? Icons.access_time : Icons.calendar_today,
                size: 18, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: const Color.fromARGB(255, 22, 145, 216),
                    colorScheme: const ColorScheme.light(
                      primary: Color.fromARGB(255, 22, 145, 216),
                    ),
                    buttonTheme: const ButtonThemeData(
                      textTheme: ButtonTextTheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              if (selectTime) {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: const Color.fromARGB(255, 22, 145, 216),
                        colorScheme: const ColorScheme.light(
                          primary: Color.fromARGB(255, 22, 145, 216),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null) {
                  final dateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  controller.text = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
                }
              } else {
                controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
              }

              if (label.contains('Check-in')) {
                _updateCheckoutDate();
              }
            }
          },
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Required *',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;

        if (isMobile) {
          return Column(
            children: children
                .map((child) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: child,
                    ))
                .toList(),
          );
        } else {
          return Row(
            children: children
                .map((child) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: child,
                      ),
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildTextField({
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? initialValue,
    TextEditingController? controller,
    bool readOnly = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: Colors.grey.shade500)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    IconData? icon,
    String? value,
    void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: Colors.grey.shade500)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 22, 145, 216)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class RoomRowData {
  String? selectedRoomTypeId;
  String? selectedRoomId;
  String? selectedRoomNumber;
  double? roomPrice;
  double? taxPercentage;
  bool isHourly;
  int days;
  int hours;
  int adults;
  int children;
  double? subtotal;
  double? taxAmount;
  double? total;

  RoomRowData({
    this.selectedRoomTypeId,
    this.selectedRoomId,
    this.selectedRoomNumber,
    this.roomPrice,
    this.taxPercentage,
    this.isHourly = false,
    this.days = 1,
    this.hours = 1,
    this.adults = 1,
    this.children = 0,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.total = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomTypeId': selectedRoomTypeId,
      'roomId': selectedRoomId,
      'roomNumber': selectedRoomNumber,
      'roomPrice': roomPrice,
      'taxPercentage': taxPercentage,
      'isHourly': isHourly,
      'days': days,
      'hours': hours,
      'adults': adults,
      'children': children,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'total': total,
    };
  }
}

class ProductRowData {
  String? id;
  String? productId;
  String? productName;
  double rate;
  int quantity;
  double tax;
  double amount;
  double subtotal;
  double taxAmount;
  double total;
  ProductRowData({
    this.id,
    this.productId,
    this.productName,
    this.rate = 0,
    this.quantity = 1,
    this.tax = 0,
    this.amount = 0,
    this.subtotal = 0,
    this.taxAmount = 0,
     this.total = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'rate': rate,
      'quantity': quantity,
      'tax': tax,
      'amount': amount,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
        'total': total,
    };
  }
}

class _StateSearchDialog extends StatefulWidget {
  final List<StateList> stateList;
  final String? selectedStateId;
  final Function(StateList) onStateSelected;

  const _StateSearchDialog({
    required this.stateList,
    required this.selectedStateId,
    required this.onStateSelected,
  });

  @override
  __StateSearchDialogState createState() => __StateSearchDialogState();
}

class __StateSearchDialogState extends State<_StateSearchDialog> {
  late TextEditingController searchCtrl;
  late List<StateList> filteredList;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredList = List.from(widget.stateList);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Select State'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  filteredList = widget.stateList
                      .where((state) => state.name
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search state...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text('No states found'),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final state = filteredList[index];
                        return ListTile(
                          title: Text(state.name),
                          trailing: widget.selectedStateId == state.id
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () => widget.onStateSelected(state),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _DistrictSearchDialog extends StatefulWidget {
  final List<DistrictList> districtList;
  final String? selectedDistrictId;
  final Function(DistrictList) onDistrictSelected;

  const _DistrictSearchDialog({
    required this.districtList,
    required this.selectedDistrictId,
    required this.onDistrictSelected,
  });

  @override
  __DistrictSearchDialogState createState() => __DistrictSearchDialogState();
}

class __DistrictSearchDialogState extends State<_DistrictSearchDialog> {
  late TextEditingController searchCtrl;
  late List<DistrictList> filteredList;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredList = List.from(widget.districtList);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Select District'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  filteredList = widget.districtList
                      .where((district) => district.name
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search district...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text('No districts found'),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final district = filteredList[index];
                        return ListTile(
                          title: Text(district.name),
                          trailing: widget.selectedDistrictId == district.id
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () => widget.onDistrictSelected(district),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}