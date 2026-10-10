import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/delete_product.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:login2/screens/product_mannagement/product_view.dart';
import 'package:login2/screens/product_mannagement/update_products.dart';
import 'package:login2/screens/stock/stockRegisterPage.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/grid_shimmer.dart';
import 'package:login2/screens/product_mannagement/product_service_list_page.dart';
import 'categories.dart';

class ProductList extends StatefulWidget {
  String catId;
  String subCatId;
  String subCat;
  String title;
  ProductList({
    super.key,
    required this.catId,
    required this.subCatId,
    required this.title,
    required this.subCat,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  bool isLoading = true;
  ProductListModel? productList;
  DeleteProductModel? deleteResponse;

  getProductLists() async {
    productList = await HttpService.getProductLists(widget.subCatId);
    setState(() {
      isLoading = false;
    });
    if (productList != null) {
      filteredProducts = productList!.data ?? [];
    }
  }

  deleteProduct(String rowId) async {
    deleteResponse = await HttpService.deleteProduct(rowId);
    if (deleteResponse != null) {
      Common.toastMessaage(deleteResponse!.message, Colors.red);
      getProductLists();
    }
  }

  @override
  void initState() {
    getProductLists();
    super.initState();
  }

  List filteredProducts = [];

  void filterProducts(String query) {
    if (productList != null && productList!.data != null) {
      setState(() {
        filteredProducts = productList!.data!
            .where((map) =>
                map.productName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.3),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                    const Text(
                      "Products",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  offset: const Offset(0, 45),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  onSelected: (value) async {
                    if (value == "0") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProducts(),
                        ),
                      ).then((_) {
                        getProductLists();
                      });
                    } else if (value == "1") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductCategories(),
                        ),
                      ).then((_) {
                        getProductLists();
                      });
                    } else if (value == "2") {
                      final token = await Common.getSharedPref("token") ?? '';
                      final name = await Common.getSharedPref("name") ?? '';
                      final userId = await Common.getSharedPref("userId") ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockRegisterPage(
                            token: token,
                            name: name,
                            userId: userId,
                            showAddDialogOnArrive: true,
                          ),
                        ),
                      ).then((_) {
                        getProductLists();
                      });
                    } else if (value == "3") {
                      final token = await Common.getSharedPref("token") ?? '';
                      final name = await Common.getSharedPref("name") ?? '';
                      final userId = await Common.getSharedPref("userId") ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockRegisterPage(
                            token: token,
                            name: name,
                            userId: userId,
                          ),
                        ),
                      ).then((_) {
                        getProductLists();
                      });
                    } else if (value == "4") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductServiceListPage(),
                        ),
                      ).then((_) {
                        getProductLists();
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: '0',
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_box_outlined,
                              size: 18,
                              color: Color(0xFF2a86c9),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Add Products',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "MontserratMedium"),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: '1',
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 18,
                              color: Color(0xFF2a86c9),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Categories',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "MontserratMedium"),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: '4',
                        child: Row(
                          children: [
                            Icon(
                              Icons.playlist_add_rounded,
                              size: 18,
                              color: Color(0xFF2a86c9),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Product Service',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "MontserratMedium"),
                            ),
                          ],
                        ),
                      ),
                      // const PopupMenuItem<String>(
                      //   value: '2',
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.playlist_add_rounded,
                      //         size: 18,
                      //         color: Color(0xFF2a86c9),
                      //       ),
                      //       SizedBox(width: 12),
                      //       Text(
                      //         'Add Stock',
                      //         style: TextStyle(
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //             fontFamily: "MontserratMedium"),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const PopupMenuItem<String>(
                      //   value: '3',
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.history_rounded,
                      //         size: 18,
                      //         color: Color(0xFF2a86c9),
                      //       ),
                      //       SizedBox(width: 12),
                      //       Text(
                      //         'View Stock',
                      //         style: TextStyle(
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //             fontFamily: "MontserratMedium"),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    filterProducts(value);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                await getProductLists();
              },
              child: isLoading == true
                  ? ShimmerListView(type: "b")
                  : (productList == null ||
                          productList!.data == null ||
                          productList!.data!.isEmpty)
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No Products Found",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      fontFamily: "MontserratMedium",
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Add products to get started",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontFamily: "MontserratMedium",
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AddProducts(),
                                        ),
                                      ).then((_) {
                                        getProductLists();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2a86c9),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      "Add First Product",
                                      style: TextStyle(
                                        fontFamily: "MontserratMedium",
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : filteredProducts.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "No Products Match Your Search",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                          fontFamily: "MontserratMedium",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(12),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductView(
                                          productId: filteredProducts[index].id,
                                          title:
                                              filteredProducts[index].productName,
                                        ),
                                      ),
                                    ).then((_) {
                                      getProductLists();
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Product Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(20),
                                          ),
                                          child: Container(
                                            width: 120,
                                            height: 140,
                                            color: Color(0xFFF5F6FA),
                                            child: Image.network(
                                              filteredProducts[index]
                                                  .productImage,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey[400],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
  
                                        // Product Details
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  filteredProducts[index]
                                                      .productName,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: "MontserratBold",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1a1a1a),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                if (filteredProducts[index]
                                                        .categoryName !=
                                                    "")
                                                  Text(
                                                    filteredProducts[index]
                                                        .categoryName,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "MontserratMedium",
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                if (filteredProducts[index]
                                                        .subCategory !=
                                                    "")
                                                  Text(
                                                    filteredProducts[index]
                                                        .subCategory,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "MontserratMedium",
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                SizedBox(height: 8),
                                                // Price
                                                Row(
                                                  children: [
                                                    if (filteredProducts[index]
                                                            .productMrp !=
                                                        filteredProducts[index]
                                                            .totalAmount)
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            right: 8),
                                                        child: Text(
                                                          "₹ ${filteredProducts[index].productMrp}",
                                                          style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            color:
                                                                Colors.grey[400],
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "MontserratMedium",
                                                          ),
                                                        ),
                                                      ),
                                                    Text(
                                                      "₹ ${filteredProducts[index].totalAmount}",
                                                      style: const TextStyle(
                                                        color: Color(0xFF2a86c9),
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            "MontserratBold",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12),
                                                // Action Buttons
                                                Row(
                                                  children: [
                                                    _buildActionButton(
                                                      icon: Icons.edit,
                                                      label: 'Edit',
                                                      color: Color(0xFF2a86c9),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                UpdateProducts(
                                                              productId:
                                                                  filteredProducts[
                                                                          index]
                                                                      .id,
                                                            ),
                                                          ),
                                                        ).then((_) {
                                                          getProductLists();
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(width: 10),
                                                    _buildActionButton(
                                                      icon: Icons.delete,
                                                      label: 'Delete',
                                                      color: Colors.red,
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              title: const Text(
                                                                  'Delete'),
                                                              content: const Text(
                                                                  'Are you sure?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'No',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    deleteProduct(
                                                                        filteredProducts[
                                                                                index]
                                                                            .id);
                                                                    getProductLists();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Yes',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: "MontserratMedium",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
