import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/rental/rentalIssueDetailsModel.dart';
import 'package:login2/screens/rental/addRentalIssuePage.dart';
import 'package:login2/service/service.dart';

class RentIssueDetailsPage extends StatefulWidget {
  final String rentId;
  const RentIssueDetailsPage({super.key, required this.rentId});

  @override
  State<RentIssueDetailsPage> createState() => _RentIssueDetailsPageState();
}

class _RentIssueDetailsPageState extends State<RentIssueDetailsPage> {
  bool _isLoading = true;
  RentalIssueDetailsResponse? _details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    final response = await HttpService.rentIssueDetails(widget.rentId);
    setState(() {
      _details = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Rental Issue Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_details != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddRentalIssuePage(rentId: widget.rentId),
                  ),
                ).then((value) {
                  if (value == true) {
                    _fetchDetails();
                  }
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null || !_details!.status
              ? _buildErrorView()
              : _buildDetailsContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(_details?.message ?? "Failed to load details"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDetails,
            child: const Text("Retry"),
          ),
        ],
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

  Widget _buildDetailsContent() {
    final issue = _details!.data.rentIssue;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: "Rental Information",
            icon: Icons.receipt_long_outlined,
            children: [
              _buildDetailRow("Rent No", issue.rentNo),
              _buildDetailRow("Invoice No", issue.invoiceNo),
              _buildDetailRow("Invoice Date", _formatDate(issue.invoiceDate)),
              _buildDetailRowSmall(
                  "Duration", "${issue.fromDate} to ${issue.toDate}"),
              _buildDetailRow("Total Days", issue.totalDays),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "Customer & Site Details",
            icon: Icons.person_outline,
            children: [
              _buildDetailRow("Customer", issue.customerName),
              _buildDetailRow("Work Site", issue.locationName),
              _buildDetailRow("Collected By", issue.collectedStaffName),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "Financial Summary",
            icon: Icons.account_balance_wallet_outlined,
            children: [
              _buildDetailRow("Sub Total", "₹ ${issue.subTotal}"),
              _buildDetailRow("GST Total", "₹ ${issue.gstTotal}"),
              _buildDetailRow("Discount", "₹ ${issue.discount}",
                  color: Colors.orange),
              _buildDetailRow("Other Expenses", "₹ ${issue.otherExpenses}"),
              if (issue.transportationCharges.isNotEmpty &&
                  issue.transportationCharges != "0" &&
                  issue.transportationCharges != "0.00")
                _buildDetailRow(
                    "Transportation Charges", "₹ ${issue.transportationCharges}"),
              if (issue.loadingCharges.isNotEmpty &&
                  issue.loadingCharges != "0" &&
                  issue.loadingCharges != "0.00")
                _buildDetailRow("Loading Charges", "₹ ${issue.loadingCharges}"),
              const Divider(height: 24),
              _buildDetailRow("Grand Total", "₹ ${issue.grandTotal}",
                  isBold: true, color: const Color(0xFF2a86c9)),
              _buildDetailRow("Paid Amount", "₹ ${issue.amountPaid}",
                  color: Colors.green),
              _buildDetailRow("Advance", "₹ ${issue.advanceAmount}"),
              _buildDetailRow("Balance",
                  "₹ ${(double.tryParse(issue.grandTotal) ?? 0) - (double.tryParse(issue.amountPaid) ?? 0)}",
                  isBold: true, color: Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          _buildProductsSection(),
          const SizedBox(height: 16),
          _buildAddonProductsSection(),
          _buildAddressCard(
              "Billing Address", Icons.location_on_outlined, _details!.data.billingAddress),
          _buildAddressCard(
              "Shipping Address", Icons.local_shipping_outlined, _details!.data.shippingAddress),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2a86c9), size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142))),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? const Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowSmall(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? const Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    final items = _details!.data.rentItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text("Rented Products",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142))),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" ${item.productName}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Qty: ${item.qty} | Days: ${item.days}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Text("₹ ${item.total}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF2a86c9))),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSmallInfo("Rate: ₹${item.ratePerDay}/d"),
                      _buildSmallInfo("GST: ${item.gstPercent}%"),
                      _buildSmallInfo("Gross: ₹${item.gross}"),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddonProductsSection() {
    final addons = _details!.data.addonProducts;
    if (addons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text("Add-on Products",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142))),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addons.length,
          itemBuilder: (context, index) {
            final item = addons[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.grid_view_rounded,
                        color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            item.productName.isNotEmpty
                                ? item.productName
                                : "Product ID: ${item.productId}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("Qty: ${item.qty}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddressCard(String title, IconData icon, AddressDetail? addr) {
    if (addr == null) return const SizedBox.shrink();

    bool hasContent = addr.name.isNotEmpty ||
        addr.address1.isNotEmpty ||
        addr.contactNo.isNotEmpty ||
        addr.whatsappNumber.isNotEmpty ||
        addr.pincode.isNotEmpty ||
        addr.gstNum.isNotEmpty;

    if (!hasContent) return const SizedBox.shrink();

    List<String> addressLines = [
      if (addr.address1.isNotEmpty) addr.address1,
      if (addr.address2.isNotEmpty) addr.address2,
      if (addr.address3.isNotEmpty) addr.address3,
      if (addr.postOffice.isNotEmpty) "PO: ${addr.postOffice}",
      if (addr.pincode.isNotEmpty) "PIN: ${addr.pincode}",
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2a86c9), size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142))),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (addr.name.isNotEmpty)
                  _buildDetailRow("Name", addr.name, isBold: true),
                if (addressLines.isNotEmpty)
                  _buildDetailRowSmall("Address", addressLines.join(", ")),
                if (addr.contactNo.isNotEmpty)
                  _buildDetailRow("Mobile", "+91 ${addr.contactNo}"),
                if (addr.whatsappNumber.isNotEmpty)
                  _buildDetailRow("Whatsapp", "+91 ${addr.whatsappNumber}"),
                if (addr.gstNum.isNotEmpty)
                  _buildDetailRow("GST Number", addr.gstNum),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500));
  }
}
