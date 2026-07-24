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
import 'package:barcode_widget/barcode_widget.dart';
import 'package:html/parser.dart';

class ProductView extends StatefulWidget {
  final String productId;
  final String title;

  const ProductView({super.key, required this.productId, required this.title});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  ProdectsByIdModel? productsResponse;
  DeleteProductModel? deleteResponse;
  Future<ProductHistoryRentalModel?>? _historyFuture;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      productsResponse = await HttpService.getProductById(widget.productId);
      if (productsResponse != null) {
        _historyFuture = HttpService.getStockHistoryRental(widget.productId);
      }
    } catch (e) {
      debugPrint("Error loading product details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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
                        suffixText:
                            product.unitName.isNotEmpty ? product.unitName : 'PCS',
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
                            controller: _tabController,
                            indicatorColor: themeColor,
                            labelColor: themeColor,
                            unselectedLabelColor: Colors.grey[600],
                            indicatorWeight: 3.0,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 15),
                            tabs: const [
                              Tab(text: "Specifications"),
                              Tab(text: "Stock & History"),
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
                    ],
                  ),
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
            _buildInfoRow(
                Icons.barcode_reader, "BarCode Value", product.barCode.isNotEmpty ? product.barCode : "Not Set"),
            if (product.barCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                              child: Text(error, style: const TextStyle(color: Colors.red)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            Common.showProgressDialog(context, "Preparing image...");
                            final image = await _screenshotController.capture();
                            Navigator.pop(context);
                            if (image != null) {
                              final directory = await getTemporaryDirectory();
                              final imagePath = await File('${directory.path}/barcode_${product.barCode}.png').create();
                              await imagePath.writeAsBytes(image);
                              await Share.shareXFiles([XFile(imagePath.path)], text: 'Barcode for ${product.productName}');
                            }
                          } catch (e) {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            Common.toastMessaage("Could not share barcode: $e", Colors.red);
                          }
                        },
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text("Share / Save Barcode"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2a86c9),
                          side: const BorderSide(color: Color(0xFF2a86c9)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              product.visibility.isNotEmpty
                  ? product.visibility
                  : "Private",
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
              _buildPricingDetail("Tax/GST",
                  "${product.taxPercent}%" ),
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
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: const Color(0xFFE5E7EB),
    ),
  ),
  child: Row(
    children: [
      Expanded(
        child: _buildStockMetricCard(
          "Opening Stock",
          product.openingStock,
          const Color(0xFF64748B), // Slate
          Icons.archive_outlined,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildStockMetricCard(
          "Current Stock",
          product.currentStock,
          const Color(0xFF10B981), // Green
          Icons.inventory_2_outlined,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildStockMetricCard(
          "Low Stock",
          product.lowStockLimit,
          const Color(0xFFF59E0B), // Orange
          Icons.warning_amber_rounded,
        ),
      ),
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
                        unitPrice: pData.purchaseAmount.isNotEmpty ? pData.purchaseAmount : pData.sellingPrice,
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
  String title,
  String value,
  Color color,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.2),
      ),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
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
