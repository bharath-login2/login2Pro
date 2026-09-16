import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/service/service.dart';

class CreateReceiptPage extends StatefulWidget {
  final dynamic booking; 
  const CreateReceiptPage({super.key, required this.booking});
  @override
  State<CreateReceiptPage> createState() => _CreateReceiptPageState();
}
class _CreateReceiptPageState extends State<CreateReceiptPage> {
  StaffListModel? staffList;
  bool _isLoading = false;
  String? selectedPaymentMethod;
  String? selectedStaff;
  String? _selectedReceiptDate;

  TextEditingController amountController = TextEditingController();
  TextEditingController receiptDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String receiptNo = "";
  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI',
    'Bank Transfer', 
    'Net Banking',
    'Cheque'
  ];

  @override
  void initState() {
    super.initState();
    generateReceiptNumber();
    setDefaultDate();
    loadStaffs();
  }

  void generateReceiptNumber() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyMMdd').format(now);
    receiptNo = "REC${widget.booking.bookingId.toString().padLeft(4, '0')}";
  }

  void setDefaultDate() {
    final now = DateTime.now();
    receiptDateController.text = DateFormat('dd-MM-yyyy').format(now);
    _selectedReceiptDate = receiptDateController.text;
  }

  Future<void> loadStaffs() async {
    setState(() => _isLoading = true);
    try {
      staffList = await HttpService.getStaffs();
    } catch (e) {
      print('Error loading staffs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xff2f3e96),
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2f3e96),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        receiptDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        _selectedReceiptDate = receiptDateController.text;
      });
    }
  }

  void _submitReceipt() {
    if (amountController.text.isEmpty) {
      _showErrorSnackBar('Please enter amount');
      return;
    }
    
    if (selectedPaymentMethod == null) {
      _showErrorSnackBar('Please select payment method');
      return;
    }
    
    if (selectedStaff == null) {
      _showErrorSnackBar('Please select staff');
      return;
    }
    
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter valid amount');
      return;
    }

    // TODO: Call create receipt API
    print('Submitting receipt with:');
    print('Receipt No: $receiptNo');
    print('Date: ${receiptDateController.text}');
    print('Amount: $amount');
    print('Payment Method: $selectedPaymentMethod');
    print('Staff: $selectedStaff');
    print('Description: ${descriptionController.text}');
    print('Booking ID: ${widget.booking.bookingId}');

    _showSuccessDialog();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Success',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Receipt created successfully!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReceiptInfoRow('Receipt No', receiptNo),
                  const SizedBox(height: 6),
                  _buildReceiptInfoRow('Date', receiptDateController.text),
                  const SizedBox(height: 6),
                  _buildReceiptInfoRow('Amount', '₹${amountController.text}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalInvoice = double.tryParse(widget.booking.amount.toString()) ?? 0;
    double totalPaid = 0;
    double balance = totalInvoice - totalPaid;
    double enteredAmount = double.tryParse(amountController.text) ?? 0;
    double remainingBalance = balance - enteredAmount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Create Receipt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
         backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2f3e96)),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Info Card
                  Container(
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xff2f3e96).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt,
                                color: Color(0xff2f3e96),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Booking Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Booking #${widget.booking.bookingId}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildAmountRow(
                          label: 'Total Invoice',
                          amount: totalInvoice,
                          icon: Icons.receipt_long,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 12),
                        _buildAmountRow(
                          label: 'Total Paid',
                          amount: totalPaid,
                          icon: Icons.payments,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(height: 12),
                        _buildAmountRow(
                          label: 'Balance Due',
                          amount: balance,
                          icon: Icons.account_balance_wallet,
                          color: Colors.orange.shade600,
                        ),
                        if (amountController.text.isNotEmpty)
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildAmountRow(
                                label: 'This Receipt',
                                amount: enteredAmount,
                                icon: Icons.add,
                                color: const Color(0xff2f3e96),
                              ),
                              const SizedBox(height: 12),
                              _buildAmountRow(
                                label: 'Remaining Balance',
                                amount: remainingBalance,
                                icon: Icons.credit_card,
                                color: Colors.red.shade600,
                                isRemaining: true,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Receipt Details Card
                  Container(
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
                        const Text(
                          'Receipt Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill the receipt information below',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Two Column Layout for Form Fields
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isMobile = constraints.maxWidth < 600;
                            
                            if (isMobile) {
                              return Column(
                                children: [
                                  _buildReceiptNumberField(),
                                  const SizedBox(height: 16),
                                  _buildReceiptDateField(context),
                                  const SizedBox(height: 16),
                                  _buildAmountField(),
                                  const SizedBox(height: 16),
                                  _buildPaymentMethodDropdown(),
                                  const SizedBox(height: 16),
                                  _buildStaffDropdown(),
                                  const SizedBox(height: 16),
                                  _buildDescriptionField(),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _buildReceiptNumberField()),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildReceiptDateField(context)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: _buildAmountField()),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildPaymentMethodDropdown()),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: _buildStaffDropdown()),
                                      const SizedBox(width: 16),
                                      const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDescriptionField(),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitReceipt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2f3e96),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor:const Color.fromARGB(255, 22, 145, 216),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Create Receipt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildAmountRow({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    bool isRemaining = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isRemaining ? Colors.red.shade700 : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Number',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.confirmation_number, color: Colors.grey.shade500, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  receiptNo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Date *',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade500, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    receiptDateController.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade500, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount *',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey.shade500, size: 18),
            hintText: '0.00',
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
              borderSide: const BorderSide(color: Color(0xff2f3e96)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method *',
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
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.payment, color: Colors.grey.shade500, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(
                    method,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
              hint: const Text('Select Payment Method'),
              validator: (value) {
                if (value == null) {
                  return 'Please select payment method';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collected By *',
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
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedStaff,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.grey.shade500, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: staffList?.data.map((staff) {
                return DropdownMenuItem<String>(
                  value: staff.id,
                  child: Text(
                    staff.name,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStaff = value;
                });
              },
              hint: const Text('Select Staff'),
              validator: (value) {
                if (value == null) {
                  return 'Please select staff';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter any additional notes or description...',
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
              borderSide: const BorderSide(color: Color(0xff2f3e96)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}