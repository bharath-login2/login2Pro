import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/delete_product.dart';
import 'package:login2/models/product_mannagement/products_by_id_model.dart';
import 'package:login2/models/lead_management/productHistoryRental.dart';
import 'package:login2/screens/product_mannagement/update_products.dart';
import 'package:login2/service/service.dart';
import 'package:login2/screens/purchase/purchaseBillPage.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/product_mannagement/rental_history_model.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login2/models/product_mannagement/get_service_list_model.dart';
import 'package:login2/models/product_mannagement/get_product_payment_list_model.dart';

class ProductView extends StatefulWidget {
  final String productId;
  final String title;

  const ProductView({super.key, required this.productId, required this.title});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  bool isLoading = true;
  ProdectsByIdModel? productsResponse;
  DeleteProductModel? deleteResponse;
  ProductHistoryModel? productHistoryResponse;
  Future<ProductHistoryRentalModel?>? _historyFuture;
  final ScreenshotController _screenshotController = ScreenshotController();
  GetServiceListModel? serviceListResponse;
  bool isServiceLoading = false;
  bool hasFetchedService = false;
  GetProductPaymentListModel? paymentListResponse;
  bool isPaymentLoading = false;
  bool hasFetchedPayment = false;
  String paymentFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController != null) {
      final isRental =
          productsResponse?.data.productType.trim().toLowerCase() == "rental";
      final serviceTabIndex = isRental ? 3 : 2;
      final paymentTabIndex = isRental ? 4 : 3;
      if (_tabController!.index == serviceTabIndex &&
          !hasFetchedService &&
          !isServiceLoading) {
        _fetchServiceList();
      } else if (_tabController!.index == paymentTabIndex &&
          !hasFetchedPayment &&
          !isPaymentLoading) {
        _fetchPaymentList();
      }
    }
  }

  Future<void> _fetchServiceList() async {
    if (isServiceLoading) return;
    setState(() {
      isServiceLoading = true;
    });
    try {
      final response = await HttpService.getServiceList(widget.productId);
      if (mounted) {
        setState(() {
          serviceListResponse = response;
          hasFetchedService = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching service list: $e");
      if (mounted) {
        setState(() {
          hasFetchedService = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isServiceLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPaymentList() async {
    if (isPaymentLoading) return;
    setState(() {
      isPaymentLoading = true;
    });
    try {
      final response =
          await HttpService.getProductPaymentList(widget.productId);
      if (mounted) {
        setState(() {
          paymentListResponse = response;
          hasFetchedPayment = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching payment list: $e");
      if (mounted) {
        setState(() {
          hasFetchedPayment = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isPaymentLoading = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      productsResponse = await HttpService.getProductById(widget.productId);

      if (productsResponse != null) {
        final isRental =
            productsResponse!.data.productType.trim().toLowerCase() == "rental";

        // Create controller based on product type
        _tabController?.removeListener(_handleTabSelection);
        _tabController = TabController(
          length: isRental ? 5 : 4,
          vsync: this,
        );
        _tabController!.addListener(_handleTabSelection);

        // Existing stock history - DON'T CHANGE
        _historyFuture = HttpService.getStockHistoryRental(widget.productId);

        // New rental history
        if (isRental) {
          productHistoryResponse =
              await HttpService.getRentalHistory(widget.productId);
        }

        // Prefetch service and payment history
        _fetchServiceList();
        _fetchPaymentList();
      }
    } catch (e) {
      debugPrint("Error loading product details: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    if (productsResponse == null) return;
    Common.showProgressDialog(context, "Deleting product...");
    try {
      deleteResponse =
          await HttpService.deleteProduct(productsResponse!.data.id);
      Navigator.pop(context); // Pop loading dialog
      if (deleteResponse != null && deleteResponse!.status == true) {
        Common.toastMessaage(deleteResponse!.message, Colors.green);
        Navigator.pop(context, true);
      } else {
        Common.toastMessaage(
            deleteResponse?.message ?? "Failed to delete product", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  String removeHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  void _showAddStockDialog() {
    if (productsResponse == null) return;
    final qtyController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final product = productsResponse!.data;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Stock",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      "Product",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        product.productName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Current Stock",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.currentStock} ${product.unitName.isNotEmpty ? product.unitName : 'PCS'}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selling Price",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹ ${product.sellingPrice}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Purchase Price",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹ ${product.purchasePrice}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Quantity to Add *",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Enter quantity",
                        suffixText: product.unitName.isNotEmpty
                            ? product.unitName
                            : 'PCS',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Quantity is required";
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return "Enter a valid positive number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: isSubmitting
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 50, 155, 216)))
                          : ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() {
                                    isSubmitting = true;
                                  });
                                  try {
                                    final payload = [
                                      {
                                        "product_id": product.id,
                                        "product_name": product.productName,
                                        "quantity": qtyController.text.trim(),
                                        "unit_price":
                                            product.sellingPrice.isNotEmpty
                                                ? product.sellingPrice
                                                : "0.00",
                                        "unit": product.unitId.isNotEmpty
                                            ? product.unitId
                                            : "PCS",
                                      }
                                    ];
                                    final response =
                                        await HttpService.postStocks(payload);
                                    if (response != null &&
                                        response.status == true) {
                                      Common.toastMessaage(
                                          "Stock added successfully",
                                          Colors.green);
                                      Navigator.pop(
                                          context); // Close bottom sheet
                                      _loadData(); // Reload product and history
                                    } else {
                                      setModalState(() {
                                        isSubmitting = false;
                                      });
                                      Common.toastMessaage(
                                          response?.message ??
                                              "Failed to add stock",
                                          Colors.red);
                                    }
                                  } catch (e) {
                                    setModalState(() {
                                      isSubmitting = false;
                                    });
                                    Common.toastMessaage(
                                        "Error: $e", Colors.red);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 50, 155, 216),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text("Confirm & Submit",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF2a86c9);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productsResponse == null
              ? const Center(child: Text("Product details not available"))
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    final product = productsResponse!.data;
                    print(product);
                    return [
                      SliverAppBar(
                        expandedHeight: 280.0,
                        floating: false,
                        pinned: true,
                        elevation: 0,
                        backgroundColor: themeColor,
                        iconTheme: const IconThemeData(color: Colors.white),
                        actions: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateProducts(
                                            productId: product.id),
                                      ),
                                    );

                                    if (result == true) {
                                      _loadData();
                                    }
                                  },
                                ),
                                Container(
                                  width: 1,
                                  height: 22,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Delete Product"),
                                        content: const Text(
                                          "Are you sure you want to permanently delete this product?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteProduct();
                                            },
                                            child: const Text(
                                              "Delete",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              product.productImage.isNotEmpty
                                  ? Image.network(
                                      product.productImage,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.blue[50]!,
                                        child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 64,
                                            color: Colors.blue[200]),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.blue[50]!,
                                      child: Icon(Icons.image_outlined,
                                          size: 64, color: Colors.blue[200]),
                                    ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black38,
                                      Colors.transparent,
                                      Colors.black54,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                              color: Colors.black38,
                                              blurRadius: 4,
                                              offset: Offset(0, 2))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (product.brand.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          product.brand.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.1),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController!,
                            isScrollable: true,
                            indicatorColor: themeColor,
                            labelColor: themeColor,
                            unselectedLabelColor: Colors.grey[600],
                            indicatorWeight: 3.0,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 15),
                            tabs: [
                              const Tab(text: "Specifications"),
                              const Tab(text: "Stock & History"),
                              if (product.productType.trim().toLowerCase() ==
                                  "rental") ...[
                                const Tab(text: "Rental History"),
                              ],
                              const Tab(text: "Service History"),
                              const Tab(text: "Payment History"),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(productsResponse!.data),
                      _buildStockHistoryTab(productsResponse!.data),
                      if (productsResponse!.data.productType
                              .trim()
                              .toLowerCase() ==
                          "rental") ...[
                        _buildRentalHistoryTab(),
                      ],
                      _buildServiceHistoryTab(),
                      _buildPaymentHistoryTab(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRentalHistoryTab() {
    final history = productHistoryResponse?.data ?? [];

    if (history.isEmpty) {
      return const Center(
        child: Text("No rental history found"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isLast = index == history.length - 1;
        final isReturned = item.returnDate.isNotEmpty;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReturned ? Colors.green : Colors.orange,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.rentNo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isReturned
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isReturned ? "Returned" : "Active",
                              style: TextStyle(
                                color:
                                    isReturned ? Colors.green : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRentalHistoryRow(
                        Icons.person_outline,
                        "Customer",
                        item.customerName,
                      ),
                      _buildRentalHistoryRow(
                        Icons.location_on_outlined,
                        "Location",
                        item.locationName,
                      ),
                      _buildRentalHistoryRow(
                        Icons.calendar_today_outlined,
                        "Rental Period",
                        "${item.fromDate} → ${item.toDate}",
                      ),
                      _buildRentalHistoryRow(
                        Icons.timelapse_outlined,
                        "Total Days",
                        item.totalDays,
                      ),
                      _buildRentalHistoryRow(
                        Icons.inventory_2_outlined,
                        "Issued Quantity",
                        item.issuedQuantity,
                      ),
                      _buildRentalHistoryRow(
                        Icons.assignment_return_outlined,
                        "Returned Quantity",
                        item.returnedQuantity,
                      ),
                      if (item.returnDate.isNotEmpty)
                        _buildRentalHistoryRow(
                          Icons.assignment_return_outlined,
                          "Return Date",
                          item.returnDate,
                        ),
                      _buildRentalHistoryRow(
                        Icons.receipt_long_outlined,
                        "Invoice",
                        item.invoiceNo,
                      ),
                      // const Divider(height: 20),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     const Text(
                      //       "Amount Paid",
                      //       style: TextStyle(
                      //         color: Colors.grey,
                      //         fontSize: 13,
                      //       ),
                      //     ),
                      //     Text(
                      //       "₹${item.amountPaid}",
                      //       style: const TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRentalHistoryRow(
    IconData icon,
    String title,
    String value,
  ) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 95,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Data product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pricing Summary Card
          _buildPricingCard(product),
          const SizedBox(height: 16),

          // Primary info
          _buildInfoSection("Categorization", [
            _buildInfoRow(
                Icons.category_outlined, "Category", product.categoryName),
            _buildInfoRow(Icons.subdirectory_arrow_right_outlined,
                "Sub Category", product.subCategory),
            _buildInfoRow(Icons.branding_watermark_outlined, "Brand",
                product.brand.isNotEmpty ? product.brand : "No Brand"),
            _buildInfoRow(
                Icons.label_outline, "Product Type", product.productType),
            _buildInfoRow(Icons.barcode_reader, "BarCode Value",
                product.barCode.isNotEmpty ? product.barCode : "Not Set"),
            if (product.barCode.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: product.barCode,
                            height: 80,
                            width: 200,
                            errorBuilder: (context, error) => Center(
                              child: Text(error,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            Common.showProgressDialog(
                                context, "Preparing image...");
                            final image = await _screenshotController.capture();
                            Navigator.pop(context);
                            if (image != null) {
                              final directory = await getTemporaryDirectory();
                              final imagePath = await File(
                                      '${directory.path}/barcode_${product.barCode}.png')
                                  .create();
                              await imagePath.writeAsBytes(image);
                              await Share.shareXFiles([XFile(imagePath.path)],
                                  text: 'Barcode for ${product.productName}');
                            }
                          } catch (e) {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            Common.toastMessaage(
                                "Could not share barcode: $e", Colors.red);
                          }
                        },
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text("Share / Save Barcode"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2a86c9),
                          side: const BorderSide(color: Color(0xFF2a86c9)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 16),

          _buildInfoSection("Product Inventory Info", [
            _buildInfoRow(
                Icons.qr_code_outlined,
                "HSN / SAC Code",
                product.productCode.isNotEmpty
                    ? product.productCode
                    : "Not Set"),
            _buildInfoRow(
                Icons.code_outlined,
                "Product Code",
                product.productUCode.isNotEmpty
                    ? product.productUCode
                    : "Not Set"),
            _buildInfoRow(Icons.fingerprint_outlined, "Content ID",
                product.contentId.isNotEmpty ? product.contentId : "Not Set"),
            _buildInfoRow(Icons.scale_outlined, "Unit",
                product.unitName.isNotEmpty ? product.unitName : "Not Set"),
            _buildInfoRow(Icons.inventory_2_outlined, "Check Stock Status",
                product.checkStock == "1" ? "Active" : "Inactive"),
            _buildInfoRow(
              Icons.published_with_changes_outlined,
              "Publish Status",
              product.publishStatus.isNotEmpty
                  ? product.publishStatus
                  : "Draft",
            ),
            _buildInfoRow(
              Icons.visibility_outlined,
              "Visibility",
              product.visibility.isNotEmpty ? product.visibility : "Private",
            ),
          ]),
          const SizedBox(height: 16),

          if (product.warranty == "true" || product.expiryDate.isNotEmpty)
            _buildInfoSection("Warranty & Expiry", [
              _buildInfoRow(Icons.verified_user_outlined, "Warranty Active",
                  product.warranty == "true" ? "Yes" : "No"),
              _buildInfoRow(Icons.confirmation_number_outlined, "Warranty No",
                  product.warrantyNo.isNotEmpty ? product.warrantyNo : "N/A"),
              _buildInfoRow(Icons.event_available_outlined, "Expiry Date",
                  product.expiryDate.isNotEmpty ? product.expiryDate : "N/A"),
              _buildInfoRow(
                  Icons.timer_outlined,
                  "Duration Days",
                  product.noOfDays.isNotEmpty
                      ? "${product.noOfDays} Days"
                      : "N/A"),
            ]),

          if (product.serviceCycle.isNotEmpty)
            _buildInfoSection("Service Details", [
              _buildInfoRow(
                  Icons.sync_outlined, "Service Cycle", product.serviceCycle),
              _buildInfoRow(Icons.star_outline_rounded, "Free Services",
                  product.freeCount),
              _buildInfoRow(Icons.monetization_on_outlined, "Paid Services",
                  product.paidCount),
              if (product.serviceNoDays.isNotEmpty)
                _buildInfoRow(Icons.calendar_today_outlined,
                    "Service Interval Days", product.serviceNoDays),
            ]),

          if (product.pipelineName.isNotEmpty)
            _buildInfoSection(
                "Pipelines",
                product.pipelineName
                    .map((pipe) =>
                        _buildInfoRow(Icons.linear_scale, "Pipeline", pipe))
                    .toList()),

          if (product.complaintType.isNotEmpty)
            _buildInfoSection(
              "Complaint Reminders",
              product.complaintType
                  .map(
                    (comp) => _buildInfoRow(
                      Icons.notification_important_outlined,
                      comp,
                      "",
                    ),
                  )
                  .toList(),
            ),

          if (product.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text("Description",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                removeHtmlTags(product.description),
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: Color(0xFF475569)),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPricingCard(Data product) {
    final double mrp = double.tryParse(product.productMrp) ?? 0;
    final double selling = double.tryParse(product.sellingPrice) ?? 0;
    double savingsPercent = 0;
    if (mrp > selling && mrp > 0) {
      savingsPercent = ((mrp - selling) / mrp) * 100;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PRICING DETAILS",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1)),
              if (product.isFeatureProduct == "Y")
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text("FEATURED",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "₹${product.totalAmount}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (mrp > selling) ...[
                Text(
                  "₹${product.productMrp}",
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough),
                ),
                // const SizedBox(width: 8),
                // Text(
                //   "${savingsPercent.toStringAsFixed(0)}% OFF",
                //   style: const TextStyle(
                //       color: Colors.greenAccent,
                //       fontSize: 14,
                //       fontWeight: FontWeight.bold),
                // ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPricingDetail("Tax/GST", "${product.taxPercent}%"),
              _buildPricingDetail(
                  "Discount Amount",
                  product.discountAmount.isNotEmpty
                      ? "₹${product.discountAmount}"
                      : "0"),
              if (double.tryParse(product.rentalPrice) != null &&
                  double.parse(product.rentalPrice) > 0)
                _buildPricingDetail("Rental Price", "₹${product.rentalPrice}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) => children[index],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildStockHistoryTab(Data product) {
    return Column(
      children: [
        // Stock Overview Header Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStockMetricCard(
                  "Opening Stock",
                  product.openingStock,
                  const Color(0xFF64748B),
                  Icons.archive_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStockMetricCard(
                  "Current Stock",
                  product.currentStock,
                  const Color(0xFF10B981),
                  Icons.inventory_2_outlined,
                ),
              ),
              // const SizedBox(width: 12),
              // Expanded(
              //   child: _buildStockMetricCard(
              //     "Available Stock",
              //     product.availableStock,
              //     const Color(0xFF10B981),
              //     Icons.inventory_2_outlined,
              //   ),
              // ),
            ],
          ),
        ),

        // Action Buttons Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddStockDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text("Add Stock",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 61, 168, 201),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (productsResponse != null) {
                      final pData = productsResponse!.data;
                      MaterialData material = MaterialData(
                        materialId: pData.id,
                        materialName: pData.productName,
                        unitName: pData.unitName,
                        unitPrice: pData.purchaseAmount.isNotEmpty
                            ? pData.purchaseAmount
                            : pData.sellingPrice,
                        gstPercentage: pData.taxPercent,
                      );

                      String? token = await Common.getSharedPref("token");
                      String? name = await Common.getSharedPref("name");
                      String? userId = await Common.getSharedPref("userId");

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseBillPage(
                            token: token ?? "",
                            name: name ?? "",
                            userId: userId ?? "",
                            showAddDialogOnArrive: true,
                            initialProductToCart: material,
                          ),
                        ),
                      );
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text("Add Purchase",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Timeline header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                "Stock Timeline Log",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<ProductHistoryRentalModel?>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data!.status == false) {
                return _buildTimelineError();
              }
              final history = snapshot.data!.data;
              if (history.isEmpty) {
                return _buildTimelineEmpty();
              }
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return _buildTimelineItem(
                      history[index], index == history.length - 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockMetricCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : "0",
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ProductHistoryData hist, bool isLast) {
    Color actionColor = Colors.blue;
    IconData actionIcon = Icons.info_outline;

    switch (hist.actionType.toLowerCase()) {
      case 'issue':
      case 'issued':
        actionColor = Colors.orange;
        actionIcon = Icons.outbox_outlined;
        break;
      case 'return':
      case 'returned':
        actionColor = Colors.green;
        actionIcon = Icons.move_to_inbox_outlined;
        break;
      case 'purchase':
      case 'added':
        actionColor = Colors.blue;
        actionIcon = Icons.add_shopping_cart;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: actionColor.withOpacity(0.2), width: 2),
                ),
                child: Icon(actionIcon, color: actionColor, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hist.actionType.toUpperCase(),
                        style: TextStyle(
                            color: actionColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.1),
                      ),
                      Text(
                        _formatDate(hist.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (hist.customerName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        hist.customerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1E293B)),
                      ),
                    ),
                  if (hist.locationName.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          hist.locationName,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (int.tryParse(hist.issuedQuantity) != null &&
                          int.parse(hist.issuedQuantity) > 0)
                        _buildHistoryBadge(
                            "Issued: ${hist.issuedQuantity}", Colors.orange),
                      if (int.tryParse(hist.returnedQuantity) != null &&
                          int.parse(hist.returnedQuantity) > 0)
                        _buildHistoryBadge(
                            "Returned: ${hist.returnedQuantity}", Colors.green),
                      if (hist.addedQuantity.isNotEmpty &&
                          int.tryParse(hist.addedQuantity) != null &&
                          int.parse(hist.addedQuantity) > 0)
                        _buildHistoryBadge(
                            "Added: ${hist.addedQuantity}", Colors.blue),
                      _buildHistoryBadge("Current: ${hist.currentStock}",
                          const Color.fromARGB(255, 33, 243, 121)),
                      _buildHistoryBadge("By: ${hist.companyName}",
                          const Color.fromARGB(255, 26, 117, 145)),
                    ],
                  ),
                  if (hist.rentNo.isNotEmpty || hist.invoiceNo.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Ref: ${hist.rentNo.isNotEmpty ? hist.rentNo : hist.invoiceNo}",
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildHistoryBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTimelineEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text("No stock log history found",
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTimelineError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[100]),
          const SizedBox(height: 12),
          Text("Failed to load history log",
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildServiceHistoryTab() {
    if (!hasFetchedService && !isServiceLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchServiceList();
      });
    }

    if (isServiceLoading && serviceListResponse == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Loading service history...",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final services = serviceListResponse?.data ?? [];

    if (services.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchServiceList,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_repair_service_outlined,
                    size: 48,
                    color: Color(0xFF2a86c9),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No Service History Found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "No service or repair records have been added for this product yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _fetchServiceList,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Refresh List"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2a86c9),
                    side: const BorderSide(color: Color(0xFF2a86c9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    double totalServiceAmount = 0.0;
    double totalPaidAmount = 0.0;
    for (var s in services) {
      totalServiceAmount += double.tryParse(s.serviceAmount) ?? 0.0;
      totalPaidAmount += double.tryParse(s.totalPaidAmount) ?? 0.0;
    }
    double totalDueAmount = totalServiceAmount - totalPaidAmount;
    if (totalDueAmount < 0) totalDueAmount = 0.0;

    return RefreshIndicator(
      onRefresh: _fetchServiceList,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildServiceSummaryHeader(
              totalCount: services.length,
              totalAmount: totalServiceAmount,
              totalPaid: totalPaidAmount,
              totalDue: totalDueAmount,
            );
          }
          final service = services[index - 1];
          return _buildServiceItemCard(service);
        },
      ),
    );
  }

  Widget _buildServiceSummaryHeader({
    required int totalCount,
    required double totalAmount,
    required double totalPaid,
    required double totalDue,
  }) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '₹ ', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a86c9).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Service Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$totalCount ${totalCount == 1 ? 'Record' : 'Records'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatItem(
                  "Total Cost",
                  currencyFormatter.format(totalAmount),
                  Colors.white,
                  Icons.receipt_rounded,
                ),
              ),
              Expanded(
                child: _buildSummaryStatItem(
                  "Total Paid",
                  currencyFormatter.format(totalPaid),
                  const Color(0xFF34D399),
                  Icons.check_circle_outline_rounded,
                ),
              ),
              if (totalDue > 0)
                Expanded(
                  child: _buildSummaryStatItem(
                    "Balance Due",
                    currencyFormatter.format(totalDue),
                    const Color(0xFFF87171),
                    Icons.pending_actions_rounded,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatItem(
      String label, String value, Color valueColor, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Colors.white60),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItemCard(ServiceListItem item) {
    Color statusBgColor = Colors.grey.shade100;
    Color statusTextColor = Colors.grey.shade800;
    IconData statusIcon = Icons.info_outline;

    final statusLower = item.paymentStatus.toLowerCase().trim();
    if (statusLower == 'paid') {
      statusBgColor = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF15803D);
      statusIcon = Icons.check_circle_rounded;
    } else if (statusLower.contains('partial')) {
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFB45309);
      statusIcon = Icons.pie_chart_rounded;
    } else if (statusLower.contains('unpaid') ||
        statusLower.contains('pending')) {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFB91C1C);
      statusIcon = Icons.error_rounded;
    }

    Color serviceTypeBg = const Color(0xFFEFF6FF);
    Color serviceTypeColor = const Color(0xFF1D4ED8);
    final typeLower = item.serviceType.toLowerCase().trim();
    if (typeLower.contains('repair')) {
      serviceTypeBg = const Color(0xFFFFF7ED);
      serviceTypeColor = const Color(0xFFC2410C);
    } else if (typeLower.contains('monthly')) {
      serviceTypeBg = const Color(0xFFF0FDF4);
      serviceTypeColor = const Color(0xFF15803D);
    } else if (typeLower.contains('maintenance')) {
      serviceTypeBg = const Color(0xFFF5F3FF);
      serviceTypeColor = const Color(0xFF6D28D9);
    }

    final double totalAmt = double.tryParse(item.serviceAmount) ?? 0.0;
    final double paidAmt = double.tryParse(item.totalPaidAmount) ?? 0.0;
    final double dueAmt = totalAmt - paidAmt > 0 ? totalAmt - paidAmt : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: serviceTypeBg,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: serviceTypeColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.build_circle_outlined,
                          size: 14, color: serviceTypeColor),
                      const SizedBox(width: 5),
                      Text(
                        item.serviceType.isNotEmpty
                            ? item.serviceType
                            : "Service",
                        style: TextStyle(
                          color: serviceTypeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusTextColor),
                      const SizedBox(width: 4),
                      Text(
                        item.paymentStatus.isNotEmpty
                            ? item.paymentStatus
                            : "Unspecified",
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceInfoBlock(
                        icon: Icons.calendar_today_rounded,
                        label: "Service Date",
                        value: _formatDateStr(item.serviceDate),
                      ),
                    ),
                    if (item.returnDate.isNotEmpty)
                      Expanded(
                        child: _buildServiceInfoBlock(
                          icon: Icons.event_available_rounded,
                          label: "Return Date",
                          value: _formatDateStr(item.returnDate),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                if (item.vendorName.isNotEmpty || item.vendorMobile.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceInfoBlock(
                          icon: Icons.storefront_rounded,
                          label: "Vendor",
                          value: item.vendorName.isNotEmpty
                              ? item.vendorName
                              : "N/A",
                          subtitle: item.vendorMobile,
                          onSubtitleTap: item.vendorMobile.isNotEmpty
                              ? () => _makePhoneCall(item.vendorMobile)
                              : null,
                        ),
                      ),
                      if (item.servicePlace.isNotEmpty ||
                          item.servicePlaceContact.isNotEmpty)
                        Expanded(
                          child: _buildServiceInfoBlock(
                            icon: Icons.location_on_outlined,
                            label: "Service Location",
                            value: item.servicePlace.isNotEmpty
                                ? item.servicePlace
                                : "N/A",
                            subtitle: item.servicePlaceContact,
                            onSubtitleTap: item.servicePlaceContact.isNotEmpty
                                ? () =>
                                    _makePhoneCall(item.servicePlaceContact)
                                : null,
                          ),
                        ),
                    ],
                  ),

                if ((item.vendorName.isEmpty && item.vendorMobile.isEmpty) &&
                    (item.servicePlace.isNotEmpty ||
                        item.servicePlaceContact.isNotEmpty))
                  _buildServiceInfoBlock(
                    icon: Icons.location_on_outlined,
                    label: "Service Location",
                    value: item.servicePlace,
                    subtitle: item.servicePlaceContact,
                    onSubtitleTap: item.servicePlaceContact.isNotEmpty
                        ? () => _makePhoneCall(item.servicePlaceContact)
                        : null,
                  ),

                if (item.issues.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.report_problem_outlined,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              "Issues / Notes",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.issues,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Service Amount",
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${item.serviceAmount}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Total Paid",
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${item.totalPaidAmount}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                          if (dueAmt > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Balance",
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${dueAmt.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (item.paymentDetails.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.payment_rounded,
                                    size: 13, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  "Payment Mode:",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              item.paymentDetails,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoBlock({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    VoidCallback? onSubtitleTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2a86c9).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2a86c9)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                InkWell(
                  onTap: onSubtitleTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 11, color: Colors.blue[700]),
                      const SizedBox(width: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateStr(String dateStr) {
    if (dateStr.isEmpty) return "N/A";
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        Common.toastMessaage("Could not call $phoneNumber", Colors.orange);
      }
    } catch (e) {
      Common.toastMessaage("Could not launch phone dialer", Colors.red);
    }
  }

  Widget _buildPaymentHistoryTab() {
    if (!hasFetchedPayment && !isPaymentLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchPaymentList();
      });
    }

    if (isPaymentLoading && paymentListResponse == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Loading payment history...",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final data = paymentListResponse?.data;
    final summary = data?.amountSummary;
    final transactions = data?.amountTransactions ?? [];

    if (summary == null && transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchPaymentList,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: Color(0xFF2a86c9),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No Payment History Found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "No financial transactions have been recorded for this product.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _fetchPaymentList,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Refresh List"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2a86c9),
                    side: const BorderSide(color: Color(0xFF2a86c9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPaymentList,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary != null) ...[
              // 1. Top 4 Metric Cards (Horizontal Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTopMetricCard(
                      icon: Icons.shopping_cart_outlined,
                      iconColor: const Color(0xFF0284C7),
                      label: "TOTAL PURCHASE COST",
                      value: summary.purchaseCost,
                    ),
                    const SizedBox(width: 12),
                    _buildTopMetricCard(
                      icon: Icons.local_mall_outlined,
                      iconColor: const Color(0xFF0D9488),
                      label: "TOTAL SALES INCOME",
                      value: summary.salesIncome,
                    ),
                    const SizedBox(width: 12),
                    _buildTopMetricCard(
                      icon: Icons.alt_route_rounded,
                      iconColor: const Color(0xFF4F46E5),
                      label: "TOTAL RENTAL INCOME",
                      value: summary.rentalIncome,
                    ),
                    const SizedBox(width: 12),
                    _buildTopMetricCard(
                      icon: Icons.construction_rounded,
                      iconColor: const Color(0xFFD97706),
                      label: "TOTAL SERVICE COST",
                      value: summary.serviceCost,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Middle 3 Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMiddleSummaryCard(
                      icon: Icons.arrow_circle_up_rounded,
                      color: const Color(0xFFEF4444),
                      label: "TOTAL EXPENSE",
                      value: summary.totalExpense,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiddleSummaryCard(
                      icon: Icons.arrow_circle_down_rounded,
                      color: const Color(0xFF0D9488),
                      label: "TOTAL INCOME",
                      value: summary.totalIncome,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiddleSummaryCard(
                      icon: Icons.balance_rounded,
                      color: summary.netAmount >= 0
                          ? const Color(0xFF0D9488)
                          : const Color(0xFFEF4444),
                      label: "NET AMOUNT",
                      value: summary.netAmount,
                      isNet: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // 3. Section Title
            Row(
              children: [
                const Icon(Icons.history_rounded,
                    size: 20, color: Color(0xFF1E293B)),
                const SizedBox(width: 8),
                const Text(
                  "TRANSACTION HISTORY",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Transaction History Table View
            if (transactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    "No transactions recorded",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ),
              )
            else
              _buildTransactionTable(transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double value,
  }) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "₹${value.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleSummaryCard({
    required IconData icon,
    required Color color,
    required String label,
    required double value,
    bool isNet = false,
  }) {
    String valueStr = "₹${value.toStringAsFixed(2)}";
    if (isNet && value < 0) {
      valueStr = "₹-${value.abs().toStringAsFixed(2)}";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    valueStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTable(List<AmountTransaction> transactions) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor:
                MaterialStateProperty.all(const Color(0xFFF8FAFC)),
            headingRowHeight: 46,
            dataRowHeight: 52,
            horizontalMargin: 16,
            columnSpacing: 28,
            columns: const [
              DataColumn(
                label: Text(
                  "Date",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Type",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Amount",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Income / Expense",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
            rows: transactions.map((t) {
              final isIncome = t.classification.toLowerCase() == "income";
              final color =
                  isIncome ? const Color(0xFF0D9488) : const Color(0xFFEF4444);

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      t.date.isNotEmpty ? t.date : t.rawDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      t.type,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      t.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      "₹${t.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      t.classification,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
