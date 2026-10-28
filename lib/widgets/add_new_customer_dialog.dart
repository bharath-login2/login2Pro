import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/common.dart';
import '../models/lead_management/districtModel.dart';
import '../models/lead_management/stateModel.dart';
import '../models/serviceman/customerModel.dart';
import '../service/service.dart';

class AddNewCustomerDialog extends StatefulWidget {
  const AddNewCustomerDialog({super.key});

  @override
  State<AddNewCustomerDialog> createState() => _AddNewCustomerDialogState();
}

class _AddNewCustomerDialogState extends State<AddNewCustomerDialog> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _idProofController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // Country Codes
  String _phoneCountryCode = '91';
  String _whatsappCountryCode = '91';

  // State & District
  List<StateList> _stateList = [];
  List<DistrictList> _districtList = [];
  String? _selectedStateId;
  String? _selectedStateName;
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  bool _isLoadingState = false;
  bool _isLoadingDistrict = false;

  // Post Offices
  List<String> _postOfficeOptions = [];
  String? _selectedPostOffice;
  bool _isLoadingPostOffice = false;

  // Saving state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _nationalityController.dispose();
    _pinCodeController.dispose();
    _postOfficeController.dispose();
    _idProofController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchStates() async {
    setState(() => _isLoadingState = true);
    try {
      final response = await HttpService.getState();
      if (response != null && response.status == true) {
        setState(() {
          _stateList = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching states: $e");
    } finally {
      if (mounted) setState(() => _isLoadingState = false);
    }
  }

  Future<void> _fetchDistricts(String stateId) async {
    setState(() {
      _isLoadingDistrict = true;
      _districtList = [];
      _selectedDistrictId = null;
      _selectedDistrictName = null;
    });
    try {
      final response = await HttpService.getDistrict(stateId);
      if (response != null && response.status == true) {
        setState(() {
          _districtList = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching districts: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDistrict = false);
    }
  }

  Future<void> _onPinCodeChanged(String value) async {
    if (value.length >= 6) {
      setState(() => _isLoadingPostOffice = true);
      try {
        final postal = await HttpService.fetchPostOffice(value);
        if (postal.postOffice != null && postal.postOffice!.isNotEmpty) {
          final options = postal.postOffice!
              .map((p) => p.name ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();

          setState(() {
            _postOfficeOptions = options;
            if (options.length == 1) {
              _selectedPostOffice = options.first;
              _postOfficeController.text = options.first;
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching post office: $e");
      } finally {
        if (mounted) setState(() => _isLoadingPostOffice = false);
      }
    } else {
      if (_postOfficeOptions.isNotEmpty) {
        setState(() {
          _postOfficeOptions = [];
          _selectedPostOffice = null;
          _postOfficeController.clear();
        });
      }
    }
  }

  Future<void> _saveCustomer() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address1 = _address1Controller.text.trim();

    if (name.isEmpty) {
      Common.toastMessaage('Name is required', Colors.red);
      return;
    }

    if (phone.isEmpty) {
      Common.toastMessaage('Phone Number is required', Colors.red);
      return;
    }

    if (phone.length < 7) {
      Common.toastMessaage('Please enter a valid Phone Number', Colors.red);
      return;
    }

    if (address1.isEmpty) {
      Common.toastMessaage('Address Line 1 is required', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await Common.getSharedPref("token") ?? '';

      final formData = FormData.fromMap({
        'token': token,
        'name': name,
        'contact_no': phone,
        'phone_number': phone,
        'country_code': _phoneCountryCode,
        'whatsapp_no': _whatsappController.text.trim(),
        'whatsapp_number': _whatsappController.text.trim(),
        'whatsapp_country_code': _whatsappCountryCode,
        'email': _emailController.text.trim(),
        'email_id': _emailController.text.trim(),
        'address': address1,
        'address1': address1,
        'address_line1': address1,
        'address2': _address2Controller.text.trim(),
        'address_line2': _address2Controller.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'state_id': _selectedStateId ?? '',
        'state': _selectedStateName ?? '',
        'district_id': _selectedDistrictId ?? '',
        'district': _selectedDistrictName ?? '',
        'pincode': _pinCodeController.text.trim(),
        'pin_code': _pinCodeController.text.trim(),
        'post_office': _postOfficeController.text.trim(),
        'id_proof': _idProofController.text.trim(),
        'id_proof_number': _idProofController.text.trim(),
        'id_proof_no': _idProofController.text.trim(),
        'remarks': _remarksController.text.trim(),
      });

      final response = await HttpService.postQuickCustomer(formData);

      if (!mounted) return;

      bool isSuccess = false;
      String message = 'Customer added successfully';

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
        String customerId = '';
        if (response!['data'] is Map) {
          customerId = response['data']['id']?.toString() ??
              response['data']['customer_id']?.toString() ??
              response['data']['client_id']?.toString() ??
              '';
        } else if (response['data'] != null &&
            response['data'].toString().isNotEmpty &&
            response['data'].toString() != 'null') {
          customerId = response['data'].toString();
        }
        if (customerId.isEmpty && response['customer_id'] != null) {
          customerId = response['customer_id'].toString();
        }
        if (customerId.isEmpty && response['id'] != null) {
          customerId = response['id'].toString();
        }

        final fullAddress = address1 +
            (_address2Controller.text.trim().isNotEmpty
                ? ', ${_address2Controller.text.trim()}'
                : '');

        final newCustomer = CustomerDetails(
          id: customerId.isNotEmpty
              ? customerId
              : DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          contactNo: phone,
          address: fullAddress,
          emailId: _emailController.text.trim(),
        );

        Common.toastMessaage(message, Colors.green);
        Navigator.pop(context, newCustomer);
      } else {
        Common.toastMessaage(
          response?['message']?.toString() ?? 'Failed to save customer',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        Common.toastMessaage('An error occurred: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showCountryCodePicker(
      {required String currentCode, required Function(String) onSelected}) {
    showCountryPicker(
      context: context,
      searchAutofocus: false,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          onSelected(country.phoneCode);
        });
      },
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF94A3B8),
      ),
      prefixIcon: prefixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF00A884), width: 1.5),
      ),
    );
  }

  Widget _buildPhonePrefix({
    required String code,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFFCBD5E1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.outlined_flag,
              size: 18,
              color: Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              '+$code',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: _inputDecoration(hintText: hintText),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPhoneInputField({
    required String label,
    required TextEditingController controller,
    required String code,
    required Function(String) onCodeChanged,
    required String hintText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: _inputDecoration(
            hintText: hintText,
            prefixIcon: _buildPhonePrefix(
              code: code,
              onTap: () => _showCountryCodePicker(
                currentCode: code,
                onSelected: onCodeChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hintText,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool isLoading = false,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        isLoading
            ? Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Loading...',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              )
            : DropdownButtonFormField<T>(
                value: value,
                isExpanded: true,
                hint: Text(
                  hintText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                decoration: _inputDecoration(hintText: hintText),
                items: items,
                onChanged: onChanged,
              ),
      ],
    );
  }

  Widget _buildPostOfficeField() {
    if (_postOfficeOptions.isNotEmpty) {
      return _buildDropdownField<String>(
        label: "Post Office",
        hintText: "Select Post Office",
        value: _selectedPostOffice,
        isLoading: _isLoadingPostOffice,
        items: _postOfficeOptions.map((po) {
          return DropdownMenuItem<String>(
            value: po,
            child: Text(
              po,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedPostOffice = val;
            _postOfficeController.text = val ?? '';
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Post Office"),
        TextFormField(
          controller: _postOfficeController,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: _inputDecoration(
            hintText: "Select Post Office",
            prefixIcon: _isLoadingPostOffice
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ).copyWith(
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 960,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFDEF0F8),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFCBD5E1), width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Customer',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                        letterSpacing: 0.2,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          color: Color(0xFF64748B),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;

                      if (isWide) {
                        return Column(
                          children: [
                            // Row 1: Name* | Phone Number*
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "Name",
                                    controller: _nameController,
                                    hintText: "Enter Full Name",
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildPhoneInputField(
                                    label: "Phone Number",
                                    controller: _phoneController,
                                    code: _phoneCountryCode,
                                    onCodeChanged: (code) =>
                                        _phoneCountryCode = code,
                                    hintText: "Enter number",
                                    isRequired: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: Whatsapp Number | Email Id
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildPhoneInputField(
                                    label: "Whatsapp Number",
                                    controller: _whatsappController,
                                    code: _whatsappCountryCode,
                                    onCodeChanged: (code) =>
                                        _whatsappCountryCode = code,
                                    hintText: "Enter number",
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildTextField(
                                    label: "Email Id",
                                    controller: _emailController,
                                    hintText: "Enter Email Id",
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 3: Address Line 1* | Address Line 2
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "Address Line 1",
                                    controller: _address1Controller,
                                    hintText: "Enter Address Line 1",
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildTextField(
                                    label: "Address Line 2",
                                    controller: _address2Controller,
                                    hintText: "Enter Address Line 2",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 4: Nationality | State
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "Nationality",
                                    controller: _nationalityController,
                                    hintText: "Enter Nationality",
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDropdownField<String>(
                                    label: "State",
                                    hintText: "Select State",
                                    value: _selectedStateId,
                                    isLoading: _isLoadingState,
                                    items: _stateList.map((state) {
                                      return DropdownMenuItem<String>(
                                        value: state.id,
                                        child: Text(
                                          state.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedStateId = val;
                                        _selectedStateName = _stateList
                                            .firstWhere((s) => s.id == val,
                                                orElse: () => StateList(
                                                    id: '', name: ''))
                                            .name;
                                      });
                                      if (val != null) {
                                        _fetchDistricts(val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 5: District | Pin Code
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDropdownField<String>(
                                    label: "District",
                                    hintText: "Select District",
                                    value: _selectedDistrictId,
                                    isLoading: _isLoadingDistrict,
                                    items: _districtList.map((dist) {
                                      return DropdownMenuItem<String>(
                                        value: dist.id,
                                        child: Text(
                                          dist.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedDistrictId = val;
                                        _selectedDistrictName = _districtList
                                            .firstWhere((d) => d.id == val,
                                                orElse: () => DistrictList(
                                                    id: '', name: ''))
                                            .name;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildTextField(
                                    label: "Pin Code",
                                    controller: _pinCodeController,
                                    hintText: "Enter Pin Code",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: _onPinCodeChanged,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 6: Post Office | ID Proof number
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildPostOfficeField(),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildTextField(
                                    label: "ID Proof number",
                                    controller: _idProofController,
                                    hintText: "Enter ID proof number",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 7: Remarks | Empty
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "Remarks",
                                    controller: _remarksController,
                                    hintText: "Enter remarks",
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        );
                      } else {
                        // Narrow screen (mobile portrait)
                        return Column(
                          children: [
                            _buildTextField(
                              label: "Name",
                              controller: _nameController,
                              hintText: "Enter Full Name",
                              isRequired: true,
                            ),
                            const SizedBox(height: 14),
                            _buildPhoneInputField(
                              label: "Phone Number",
                              controller: _phoneController,
                              code: _phoneCountryCode,
                              onCodeChanged: (code) => _phoneCountryCode = code,
                              hintText: "Enter number",
                              isRequired: true,
                            ),
                            const SizedBox(height: 14),
                            _buildPhoneInputField(
                              label: "Whatsapp Number",
                              controller: _whatsappController,
                              code: _whatsappCountryCode,
                              onCodeChanged: (code) =>
                                  _whatsappCountryCode = code,
                              hintText: "Enter number",
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              label: "Email Id",
                              controller: _emailController,
                              hintText: "Enter Email Id",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              label: "Address Line 1",
                              controller: _address1Controller,
                              hintText: "Enter Address Line 1",
                              isRequired: true,
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              label: "Address Line 2",
                              controller: _address2Controller,
                              hintText: "Enter Address Line 2",
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              label: "Nationality",
                              controller: _nationalityController,
                              hintText: "Enter Nationality",
                            ),
                            const SizedBox(height: 14),
                            _buildDropdownField<String>(
                              label: "State",
                              hintText: "Select State",
                              value: _selectedStateId,
                              isLoading: _isLoadingState,
                              items: _stateList.map((state) {
                                return DropdownMenuItem<String>(
                                  value: state.id,
                                  child: Text(
                                    state.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedStateId = val;
                                  _selectedStateName = _stateList
                                      .firstWhere((s) => s.id == val,
                                          orElse: () =>
                                              StateList(id: '', name: ''))
                                      .name;
                                });
                                if (val != null) {
                                  _fetchDistricts(val);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildDropdownField<String>(
                              label: "District",
                              hintText: "Select District",
                              value: _selectedDistrictId,
                              isLoading: _isLoadingDistrict,
                              items: _districtList.map((dist) {
                                return DropdownMenuItem<String>(
                                  value: dist.id,
                                  child: Text(
                                    dist.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedDistrictId = val;
                                  _selectedDistrictName = _districtList
                                      .firstWhere((d) => d.id == val,
                                          orElse: () =>
                                              DistrictList(id: '', name: ''))
                                      .name;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              label: "Pin Code",
                              controller: _pinCodeController,
                              hintText: "Enter Pin Code",
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: _onPinCodeChanged,
                            ),
                            const SizedBox(height: 14),
                            _buildPostOfficeField(),
                            // const SizedBox(height: 14),
                            // _buildTextField(
                            //   label: "ID Proof number",
                            //   controller: _idProofController,
                            //   hintText: "Enter ID proof number",
                            // ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              label: "Remarks",
                              controller: _remarksController,
                              hintText: "Enter remarks",
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A884),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
