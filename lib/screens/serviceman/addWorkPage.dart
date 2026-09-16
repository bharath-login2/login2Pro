import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/serviceman/customerModel.dart';
import 'package:login2/models/serviceman/customerTypeModel.dart';
import 'package:login2/models/serviceman/receivedThroughModel.dart';
import 'package:login2/models/serviceman/staffModel.dart';
import 'package:login2/models/serviceman/workCategoryModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'package:login2/service/service.dart';


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
  // String? _selectedStatus;
  String? _selectedJobType;
  String? _selectedReceivedThrough;
  String? _selectedAccessory;
  String? _selectedServiceOption;
  String? _selectedStatus = "New";
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
                    GestureDetector(
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
                      "Estimated Date",
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
                      _selectedStatus,
                      ["New", "In Progress", "Completed"]
                          .map((status) => {"id": status, "name": status})
                          .toList(),
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
                    _buildTextField(
                      _remarksController,
                      "Description",
                      maxLines: 2,
                    ),
                    _buildDropdown(
                      "Job Type",
                      _selectedJobType,
                      [
                        "New",
                        "Repeat",
                      ].map((type) => {"id": type, "name": type}).toList(),
                      (val) => setState(() => _selectedJobType = val),
                    ),

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
                    ),

                    _buildTextField(
                      _remarksController,
                      "Remarks from Customer",
                    ),
                    _buildAccessoriesDropdown(),

                    const SizedBox(height: 20),
                    const Text(
                      "Notification Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
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
          onChanged: onChanged,
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

