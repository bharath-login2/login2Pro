import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/serviceman/customerModel.dart';
import 'package:login2/models/serviceman/customerTypeModel.dart';
import 'package:login2/models/serviceman/receivedThroughModel.dart';
import 'package:login2/models/serviceman/staffModel.dart';
import 'package:login2/models/serviceman/workCategoryModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'package:dio/dio.dart';
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
  DateTime? _preferredDate;
  DateTime? _estimatedDate;

  // Models
  CustomerModelService? customerModel;
  CustomerTypeModel? custTypeModel;
  StaffsModel? staffModel;
  WorkTypeModel? workType;
  WorkCategory? workCategory;
  ReceivedThroughModel? receivedOne;
  bool _whatsappNotify = true;
  bool _pushNotify = false;
  bool _notifyAssignedStaff = true;
  bool _notifyOtherPeople = false;
  bool _notifyWorkStarts = true;
  bool _notifyStatusChange = false;
  bool _notifyWorkCompletes = true;
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    customerModel = await HttpService().getCustomerListService();
    custTypeModel = await HttpService().getCustomerType();
    staffModel = await HttpService().getStaffName();
    workType = await HttpService().getWorkType();
    workCategory = await HttpService().getWorkCategory();
    receivedOne = await HttpService().getReceivedThrough();
    setState(() {});
  }

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

  Widget _buildAccessoriesDropdown() {
    // Common accessories suggestions
    final List<String> accessorySuggestions = [
      "Battery",
      "Charger",
      "Display",
      "Mouse",
      // "Charger",
      // "Display",
      // "Adapter",
      // "Keyboard",
      // "Mouse",
      // "Stand",
      // "Cover",
      // "Case",
      // "Stylus",
      // "Headphones",
      // "Power Cord",
      // "USB Cable",
      // "HDMI Cable",
      // "Earphones",
      // "Dongle",
      // "Mount",
    ];

    // Parse existing accessories from the string format: "battery, charger"
    List<String> selectedAccessories = [];
    if (_selectedAccessory != null && _selectedAccessory!.isNotEmpty) {
      String cleanedString = _selectedAccessory!
          .replaceAll('"', '')
          .replaceAll("'", '');
      selectedAccessories = cleanedString
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Other Accessories",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final List<String>? result = await showDialog<List<String>>(
              context: context,
              builder: (context) {
                List<String> tempSelected = List.from(selectedAccessories);
                TextEditingController customController =
                    TextEditingController();

                return StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    title: const Text('Select Accessories'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: customController,
                                    decoration: const InputDecoration(
                                      hintText: 'Add custom accessory...',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    if (customController.text
                                        .trim()
                                        .isNotEmpty) {
                                      final newAccessory = customController.text
                                          .trim();
                                      if (!tempSelected.contains(
                                        newAccessory,
                                      )) {
                                        tempSelected.add(newAccessory);
                                        customController.clear();
                                        setState(() {});
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          if (tempSelected.isNotEmpty) ...[
                            const Text(
                              'Selected:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: tempSelected.map((accessory) {
                                return Chip(
                                  label: Text(accessory),
                                  onDeleted: () {
                                    tempSelected.remove(accessory);
                                    setState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                          ],
                          const Text(
                            'Suggestions:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: accessorySuggestions.length,
                              itemBuilder: (context, index) {
                                final accessory = accessorySuggestions[index];
                                final isSelected = tempSelected.contains(
                                  accessory,
                                );
                                return CheckboxListTile(
                                  title: Text(accessory),
                                  value: isSelected,
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
                      ElevatedButton(
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
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "Accessories",
                hintText: "Tap to select accessories",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              controller: TextEditingController(
                text: _selectedAccessory ?? '',
              ),
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _openAddNewCustomerPopup() async {
    final CustomerDetails? newCustomer = await showDialog<CustomerDetails>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddNewCustomerDialog(),
    );

    if (newCustomer != null) {
      // Refresh customer list from backend if possible
      try {
        final refreshedModel = await HttpService().getCustomerListService();
        if (refreshedModel != null && refreshedModel.data.isNotEmpty) {
          customerModel = refreshedModel;
        }
      } catch (e) {
        debugPrint("Error refreshing customer list: $e");
      }

      customerModel ??= CustomerModelService(status: "true", data: []);

      // Find matching customer
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
          bool isSuccess = false;
          String message = "Customer type added successfully";

          if (response != null) {
            final status = response['status'];
            if (status == true ||
                status == 'true' ||
                status == 200 ||
                status == '200' ||
                status == 'success') {
              isSuccess = true;
            }
            if (response['message'] != null &&
                response['message'].toString().isNotEmpty) {
              message = response['message'].toString();
            }
          }

          if (isSuccess) {
            String newId = '';
            if (response!['data'] is Map) {
              newId = response['data']['customer_type_id']?.toString() ??
                  response['data']['id']?.toString() ??
                  '';
            } else if (response['data'] != null &&
                response['data'].toString().isNotEmpty &&
                response['data'].toString() != 'null') {
              newId = response['data'].toString();
            }
            if (newId.isEmpty && response['customer_type_id'] != null) {
              newId = response['customer_type_id'].toString();
            }
            if (newId.isEmpty && response['id'] != null) {
              newId = response['id'].toString();
            }

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
          } else {
            Common.toastMessaage(
              response?['message']?.toString() ??
                  'Failed to add customer type',
              Colors.red,
            );
            return false;
          }
        },
      ),
    );
  }

  Future<void> _openAddNewWorkCategoryPopup() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickAddSingleFieldDialog(
        title: "Add New Work Category",
        fieldLabel: "Work Category",
        hintText: "Work Category",
        onSubmit: (value) async {
          final token = await Common.getSharedPref("token") ?? '';
          final formData = FormData.fromMap({
            "token": token,
            "work_category": value,
            // "workCategory": value,
            "name": value,
          });

          final response = await HttpService.postQuickWorkCategory(formData);
          bool isSuccess = false;
          String message = "Work category added successfully";

          if (response != null) {
            final status = response['status'];
            if (status == true ||
                status == 'true' ||
                status == 200 ||
                status == '200' ||
                status == 'success') {
              isSuccess = true;
            }
            if (response['message'] != null &&
                response['message'].toString().isNotEmpty) {
              message = response['message'].toString();
            }
          }

          if (isSuccess) {
            String newId = '';
            if (response!['data'] is Map) {
              newId = response['data']['workCategory_id']?.toString() ??
                  response['data']['id']?.toString() ??
                  '';
            } else if (response['data'] != null &&
                response['data'].toString().isNotEmpty &&
                response['data'].toString() != 'null') {
              newId = response['data'].toString();
            }
            if (newId.isEmpty && response['workCategory_id'] != null) {
              newId = response['workCategory_id'].toString();
            }
            if (newId.isEmpty && response['id'] != null) {
              newId = response['id'].toString();
            }

            try {
              final refreshed = await HttpService().getWorkCategory();
              if (refreshed != null && refreshed.data.isNotEmpty) {
                workCategory = refreshed;
              }
            } catch (e) {
              debugPrint("Error refreshing work category: $e");
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
          } else {
            Common.toastMessaage(
              response?['message']?.toString() ??
                  'Failed to add work category',
              Colors.red,
            );
            return false;
          }
        },
      ),
    );
  }

  Future<void> _openAddNewReceivedThroughPopup() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickAddSingleFieldDialog(
        title: "Add New Recieved through",
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
          bool isSuccess = false;
          String message = "Received through added successfully";

          if (response != null) {
            final status = response['status'];
            if (status == true ||
                status == 'true' ||
                status == 200 ||
                status == '200' ||
                status == 'success') {
              isSuccess = true;
            }
            if (response['message'] != null &&
                response['message'].toString().isNotEmpty) {
              message = response['message'].toString();
            }
          }

          if (isSuccess) {
            String newId = '';
            if (response!['data'] is Map) {
              newId = response['data']['recieved_tru_id']?.toString() ??
                  response['data']['id']?.toString() ??
                  '';
            } else if (response['data'] != null &&
                response['data'].toString().isNotEmpty &&
                response['data'].toString() != 'null') {
              newId = response['data'].toString();
            }
            if (newId.isEmpty && response['recieved_tru_id'] != null) {
              newId = response['recieved_tru_id'].toString();
            }
            if (newId.isEmpty && response['id'] != null) {
              newId = response['id'].toString();
            }

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
          } else {
            Common.toastMessaage(
              response?['message']?.toString() ??
                  'Failed to add received through',
              Colors.red,
            );
            return false;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Work'),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
      ),
      body:
          customerModel == null ||
              custTypeModel == null ||
              staffModel == null ||
              workType == null ||
              workCategory == null ||
              receivedOne == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final CustomerDetails? selected =
                                    await showDialog<CustomerDetails>(
                                  context: context,
                                  builder: (context) {
                                    String searchText = '';
                                    List<CustomerDetails> filteredList =
                                        customerModel?.data ?? [];
                                    return StatefulBuilder(
                                      builder: (context, setState) => AlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Select Customer'),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                color: Color(0xFF2a86c9),
                                              ),
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
                                              decoration: const InputDecoration(
                                                hintText: 'Search by name',
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  searchText =
                                                      value.toLowerCase();
                                                  filteredList = customerModel!
                                                      .data
                                                      .where(
                                                        (c) => c.name
                                                            .toLowerCase()
                                                            .contains(searchText),
                                                      )
                                                      .toList();
                                                });
                                              },
                                            ),
                                            SizedBox(
                                              height: 300,
                                              width: double.maxFinite,
                                              child: ListView.builder(
                                                itemCount: filteredList.length,
                                                itemBuilder: (context, index) {
                                                  final c = filteredList[index];
                                                  return ListTile(
                                                    title: Text(c.name),
                                                    onTap: () => Navigator.of(
                                                      context,
                                                    ).pop(c),
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
                                    _selectedCustomerId = selected.id;
                                    _phoneController.text = selected.contactNo;
                                    _addressController.text = selected.address;
                                    _emailController.text = selected.emailId;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: "Customer Name *",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  value: _selectedCustomerId,
                                  items: customerModel?.data.map((c) {
                                    return DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCustomerId = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _openAddNewCustomerPopup,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a86c9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDropdown(
                      "Customer Type *",
                      _selectedCustomerType,
                      custTypeModel!.data
                          .map(
                            (e) => {
                              "id": e.customerTypeId,
                              "name": e.customerType,
                            },
                          )
                          .toList(),
                      (val) => setState(() => _selectedCustomerType = val),
                      onAddPressed: _openAddNewCustomerTypePopup,
                    ),
                    _buildTextField(_phoneController, "Mobile Number *"),
                    _buildTextField(_emailController, "Email"),
                    _buildTextField(_locationController, "Location"),
                    _buildDropdown(
                      "Priority",
                      _selectedPriority,
                      [
                        "High",
                        "Medium",
                        "Low",
                        "Normal",
                      ].map((e) => {"id": e, "name": e}).toList(),
                      (val) => setState(() => _selectedPriority = val),
                    ),

                    _buildTextField(_addressController, "Address"),

                    const SizedBox(height: 20),
                    const Text(
                      "📌 Issue Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildTextField(_serialController, "Serial No / Model No"),
                    _buildTextField(_brandController, "Brand"),
                    _buildDropdown(
                      "Product (Work Type)",
                      _selectedProduct,
                      workType!.data
                          .map((e) => {"id": e.id, "name": e.productName})
                          .toList(),
                      (val) => setState(() => _selectedProduct = val),
                    ),

                    _buildDropdown(
                      "Work Category",
                      _selectedCategory,
                      workCategory!.data
                          .map(
                            (e) => {
                              "id": e.workCategory,
                              "name": e.workCategory,
                            },
                          )
                          .toList(),
                      (val) => setState(() => _selectedCategory = val),
                      onAddPressed: _openAddNewWorkCategoryPopup,
                    ),

                    _buildTextField(
                      _problemDescController,
                      "Problem Description",
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Work Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildDateField(
                      "Preferred Date",
                      _preferredDate,
                      () => _pickDateTime(context, true),
                    ),
                    _buildDateField(
                      "Estimated Date *",
                      _estimatedDate,
                      () => _pickDateTime(context, false),
                    ),
                    _buildDropdown(
                      "Assigned Service Man",
                      _selectedServiceMan,
                      staffModel!.data
                          .map((e) => {"id": e.staffId, "name": e.staffName})
                          .toList(),
                      (val) => setState(() => _selectedServiceMan = val),
                    ),

                    _buildDropdown(
                      "Status",
                      "New",
                      ["New", "In Progress", "Completed"]
                          .map((status) => {"id": status, "name": status})
                          .toList(),
                      (val) => setState(() => _selectedStatus = val),
                      readOnly: true,
                    ),

                    _buildTextField(
                      _remarksCustomerController,
                      "Remarks About Customer",
                    ),
                    const SizedBox(height: 8),
                    // _buildDropdown(
                    //   "Service Option",
                    //   _selectedServiceOption,
                    //   [
                    //     "Quarterwise Service",
                    //     "Yearlywise Service",
                    //   ].map((e) => {"id": e, "name": e}).toList(),
                    //   (val) => setState(() => _selectedServiceOption = val),
                    // ),
                    // const SizedBox(height: 8),
                    // _buildTextField(
                    //   _serviceChargeController,
                    //   "Service Charge",
                    //   keyboardType: TextInputType.number,
                    // ),
                    _buildTextField(
                      _remarksController,
                      "Description",
                      maxLines: 2,
                    ),

                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isMoreDetailsExpanded = !_isMoreDetailsExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  color: Color(0xFF2a86c9),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "More Details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _isMoreDetailsExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF64748B),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Visibility(
                      visible: _isMoreDetailsExpanded,
                      maintainState: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                                _buildDropdown(
                                  "Service Type",
                                  _selectedServiceType,
                                  [
                                    {"id": "onsite", "name": "On-site Service"},
                                    {"id": "workshop", "name": "In-office / Workshop Service"},
                                  ],
                                  (val) => setState(() => _selectedServiceType = val),
                                ),
                                const SizedBox(height: 8),
                                _buildDropdown(
                                  "Job Type",
                                  _selectedJobType,
                                  [
                                    "New",
                                    "Repeat",
                                  ].map((type) => {"id": type, "name": type}).toList(),
                                  (val) => setState(() => _selectedJobType = val),
                                ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            _dealerCustomerController,
                            "Dealer / Customer",
                          ),
                          _buildTextField(
                            _userPasswordController,
                            "User Password",
                            obscureText: true,
                          ),
                          _buildDropdown(
                            "Received Through",
                            _selectedReceivedThrough,
                            receivedOne!.data
                                .map(
                                  (e) => {
                                    "id": e.recievedTruId,
                                    "name": e.recievedThrough,
                                  },
                                )
                                .toList(),
                            (val) => setState(() => _selectedReceivedThrough = val),
                            onAddPressed: _openAddNewReceivedThroughPopup,
                          ),
                          _buildTextField(
                            _remarksController,
                            "Remarks from Customer",
                          ),
                          _buildAccessoriesDropdown(),
                        ],
                      ),
                    ),

                    // const SizedBox(height: 20),
                    // const Text(
                    //   "Notification Settings",
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // _buildCheckbox(
                    //   "WhatsApp Notification",
                    //   _whatsappNotify,
                    //   (val) => setState(() => _whatsappNotify = val!),
                    // ),
                    // _buildCheckbox(
                    //   "Push Notification",
                    //   _pushNotify,
                    //   (val) => setState(() => _pushNotify = val!),
                    // ),

                    // const SizedBox(height: 10),
                    // const Text(
                    //   "Participants in Chat: All Participants",
                    //   style: TextStyle(fontWeight: FontWeight.w500),
                    // ),

                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (_selectedCustomerId == null ||
                              _selectedCustomerId!.isEmpty) {
                            _showError("Please select a Customer");
                            return;
                          }

                          if (_selectedCustomerType == null ||
                              _selectedCustomerType!.isEmpty) {
                            _showError("Please select Customer Type");
                            return;
                          }

                          if (_phoneController.text.isEmpty ||
                              _phoneController.text.length < 10) {
                            _showError(
                              "Please enter a valid 10-digit Phone Number",
                            );
                            return;
                          }

                          if (_estimatedDate == null) {
                            _showError("Please select an Estimated Date");
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
                                ? DateFormat(
                                    'yyyy-MM-dd HH:mm:ss',
                                  ).format(_preferredDate!)
                                : "",
                            "estimated_date": _estimatedDate != null
                                ? DateFormat(
                                    'yyyy-MM-dd HH:mm:ss',
                                  ).format(_estimatedDate!)
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
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            var result = await HttpService().addWorkService(body);
                            Navigator.of(context).pop();
                            if (result!["status"] == "success") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Job created successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '❌ Failed: ${result["message"] ?? "Unknown error"}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚠️ Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Create Job",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }


  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) =>
            value!.isEmpty && label.contains('*') ? 'Required field' : null,
      ),
    );
  }

  
Widget _buildDropdown(
  String label,
  String? selectedValue,
  List<Map<String, dynamic>> items,
  ValueChanged<String?>? onChanged, {
  VoidCallback? onAddPressed,
  bool readOnly = false,
}) {
  Widget dropdown = DropdownButtonFormField<String>(
    value: selectedValue,
    isExpanded: true,
    hint: Text("Select $label"),
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item["id"].toString(),
        child: Text(
          item["name"] ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }).toList(),
    onChanged: readOnly ? null : onChanged,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 6),
      if (onAddPressed != null)
        Row(
          children: [
            Expanded(child: dropdown),
            const SizedBox(width: 8),
            InkWell(
              onTap: onAddPressed,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2a86c9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        )
      else
        dropdown,
    ],
  );
}

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            date == null
                ? 'Select date and time'
                : DateFormat('dd MMM yyyy, hh:mm a').format(date),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

