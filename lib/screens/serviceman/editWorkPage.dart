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
  const EditWorkPage({super.key, required this.workOrderId});
  @override
  State<EditWorkPage> createState() => _EditWorkPageState();
}

class _EditWorkPageState extends State<EditWorkPage> {
  final _formKey = GlobalKey<FormState>();
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
  String? _selectedCustomerId;
  String? _selectedCustomerType;
  String? _selectedPriority;
  String? _selectedProduct;
  String? _selectedCategory;
  String? _selectedServiceMan;
  String? _selectedJobType;
  String? _selectedReceivedThrough;
  String? _selectedAccessory;
  String? _selectedServiceOption;
  String? _selectedStatus;
  DateTime? _preferredDate;
  DateTime? _estimatedDate;
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
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Add this method INSIDE the _EditWorkPageState class but OUTSIDE the build method
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
      // Remove quotes and split by comma
      String cleanedString =
          _selectedAccessory!.replaceAll('"', '').replaceAll("'", '');
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
                                        horizontal: 0,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    if (customController.text
                                        .trim()
                                        .isNotEmpty) {
                                      final newAccessory =
                                          customController.text.trim();
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
                selectedAccessories = result;
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
                text: selectedAccessories.isNotEmpty
                    ? selectedAccessories.join(', ')
                    : '',
              ),
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadAllData() async {
    try {
      final workDetails = await HttpService().getWorkEditDetails(
        widget.workOrderId,
      );
      if (workDetails != null && workDetails.status) {
        setState(() {
          _workData = workDetails.data;
        });
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
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _updateWork() async {
    if (!_formKey.currentState!.validate()) {
      _showError("Please fill all required fields");
      return;
    }
    if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
      _showError("Please select a Customer");
      return;
    }
    if (_selectedCustomerType == null || _selectedCustomerType!.isEmpty) {
      _showError("Please select Customer Type");
      return;
    }
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showError("Please enter a valid 10-digit Phone Number");
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
      // final result = await HttpService().updateWork(body);

      Navigator.of(context).pop();

      final result = await HttpService().updateWorkService(body);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Work order updated successfully",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to update work order",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showError('⚠️ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Work'),
          backgroundColor: const Color(0xFF2a86c9),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Work'),
          backgroundColor: const Color(0xFF2a86c9),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadAllData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Work'),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildCustomerDropdown(),
              _buildDropdown(
                "Customer Type *",
                _selectedCustomerType,
                custTypeModel!.data
                    .map(
                      (e) => {"id": e.customerTypeId, "name": e.customerType},
                    )
                    .toList(),
                (val) => setState(() => _selectedCustomerType = val),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    .map((e) => {"id": e.workCategory, "name": e.workCategory})
                    .toList(),
                (val) => setState(() => _selectedCategory = val),
              ),

              _buildTextField(
                _problemDescController,
                "Problem Description",
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              const Text(
                "Work Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              _buildDateField(
                "Preferred Date",
                _preferredDate,
                () => _pickDateTime(context, true),
              ),

              _buildDateField(
                "Estimated Date",
                _estimatedDate,
                () => _pickDateTime(context, false),
              ),

              _buildServiceManDropdown(),

              _buildDropdown(
                "Status",
                _selectedStatus,
                [
                  "New",
                  "In Progress",
                  "Completed",
                  "On Hold",
                  "Cancelled",
                ].map((status) => {"id": status, "name": status}).toList(),
                (val) => setState(() => _selectedStatus = val),
              ),

              _buildTextField(
                _remarksCustomerController,
                "Remarks About Customer",
              ),

              const SizedBox(height: 8),
              _buildDropdown(
                "Service Option",
                _selectedServiceOption,
                [
                  "Quarterwise Service",
                  "Yearlywise Service",
                ].map((e) => {"id": e, "name": e}).toList(),
                (val) => setState(() => _selectedServiceOption = val),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                _serviceChargeController,
                "Service Charge",
                keyboardType: TextInputType.number,
              ),

              _buildTextField(_remarksController, "Description", maxLines: 2),

              _buildDropdown(
                "Job Type",
                _selectedJobType,
                [
                  "New",
                  "Repeat",
                ].map((type) => {"id": type, "name": type}).toList(),
                (val) => setState(() => _selectedJobType = val),
              ),

              _buildTextField(_dealerCustomerController, "Dealer / Customer"),

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
                      (e) => {"id": e.recievedTruId, "name": e.recievedThrough},
                    )
                    .toList(),
                (val) => setState(() => _selectedReceivedThrough = val),
              ),

              // _buildDropdown(
              //   "Other Accessories",
              //   _selectedAccessory,
              //   ["Remote", "Cable", "Manual", "Others"]
              //       .map((e) => {"id": e, "name": e})
              //       .toList(),
              //   (val) => setState(() => _selectedAccessory = val),
              // ),
              _buildAccessoriesDropdown(),

              const SizedBox(height: 20),
              const Text(
                "Notification Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              _buildCheckbox(
                "WhatsApp Notification",
                _whatsappNotify,
                (val) => setState(() => _whatsappNotify = val!),
              ),

              // _buildCheckbox(
              //   "Push Notification",
              //   _pushNotify,
              //   (val) => setState(() => _pushNotify = val!),
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
                  onPressed: _updateWork,
                  child: const Text(
                    "Update Work",
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

  Widget _buildCustomerDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Name *",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final CustomerDetails? selected = await showDialog<CustomerDetails>(
              context: context,
              builder: (context) {
                String searchText = '';
                List<CustomerDetails> filteredList = customerModel?.data ?? [];
                return StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    title: const Text('Select Customer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search by name',
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value.toLowerCase();
                              filteredList = customerModel!.data
                                  .where(
                                    (c) => c.name.toLowerCase().contains(
                                          searchText,
                                        ),
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
                                subtitle: Text(c.contactNo),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedCustomerId,
              isExpanded: true,
              hint: const Text("Select Customer"),
              items: customerModel?.data.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value!;
                });
              },
            ),
          ),
        ),
      ],
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
    ValueChanged<String?> onChanged,
  ) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: valueExists ? selectedValue : null,
          isExpanded: true,
          hint: Text("Select $label"),
          items: deduplicatedItems.map((item) {
            return DropdownMenuItem<String>(
              value: item["id"].toString(),
              child: Text(
                item["name"] ?? "",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
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
      if (resolvedValue!.isEmpty) {
        final foundItem = uniqueStaffItems.firstWhere(
          (item) => item["name"] == _selectedServiceMan,
          orElse: () => {"id": "", "name": ""},
        );
        resolvedValue = foundItem["id"].toString();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assigned Service Man",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: resolvedValue?.isNotEmpty == true ? resolvedValue : null,
          isExpanded: true,
          hint: const Text("Select Service Man"),
          items: uniqueStaffItems.map((item) {
            return DropdownMenuItem<String>(
              value: item["id"].toString(),
              child: Text(
                item["name"],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedServiceMan = val),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
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
