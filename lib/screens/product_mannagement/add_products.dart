import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/product_mannagement/post_product.dart';
import 'package:login2/models/product_mannagement/product_categories.dart';
import 'package:login2/models/product_mannagement/sub_categories.dart';
import 'package:login2/models/lead_management/unitModel.dart';
import 'package:login2/screens/product_mannagement/categories.dart';
import 'package:login2/screens/product_mannagement/subcategories.dart';
import 'package:intl/intl.dart';
import 'package:login2/service/service.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final formKey = GlobalKey<FormState>();
  TextEditingController productName = TextEditingController();
  TextEditingController productCode = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController totalAmount = TextEditingController();
  TextEditingController mrp = TextEditingController();
  TextEditingController contentId = TextEditingController();
  TextEditingController brand = TextEditingController();
  TextEditingController expiryDays = TextEditingController();
  //TextEditingController openingStock = TextEditingController();
  final TextEditingController openingStock = TextEditingController(text: "0");
  TextEditingController currentStock = TextEditingController();
  TextEditingController noOfDays = TextEditingController();
  TextEditingController remindBefore = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController subCategory = TextEditingController();
  TextEditingController expiryDate = TextEditingController();
  TextEditingController warrantyNumber = TextEditingController();
  TextEditingController lowStock = TextEditingController();
  TextEditingController freeService = TextEditingController();
  TextEditingController paidService = TextEditingController();
  List<TextEditingController> complaintControllers = [TextEditingController()];
  final TextEditingController productUCode = TextEditingController();
  List<String?> selectedComplaintTypes = ["Complaint Type"];
  List<String> complaintTypeOptions = [
    "Complaint Type",
    "Product Issue",
    "Payment Issue",
    "Warranty Issue",
    "Technical Issue"
  ];

  List<UnitData> unitList = [];
  List<UnitData> filteredUnits = [];
  bool isUnitsLoading = false;

  List filteredCategories = [];
  List filteredSubCategories = [];
  List<String> productTypeList = [];
  String? selectedProductType;
  String? selectedServiceCycle;
  String? selectedWeekDay;
  String? selectedYearMonth;
  TextEditingController serviceNoOfDays = TextEditingController();
  TextEditingController serviceMonthDays = TextEditingController();
  TextEditingController serviceYearDays = TextEditingController();
  int? productId;
  String? barcodeError;
  bool isBarcodeDuplicate = false;
  List<String> serviceCycles = [
    "Daily",
    "N Days",
    "Weekly",
    "Monthly",
    "Yearly"
  ];
  bool _mrpEdited = false;
  List<String> weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  String? productImage;
  String categoryId = "";
  String subCategoryId = "";
  String selectedStockStatus = "In Stock";
  bool isLoading = true;
  bool addStock = false;
  bool checkStock = false;

  TextEditingController unitController = TextEditingController();
  String selectedUnitId = "";
  bool hasWarranty = false;
  List<TextEditingController> pipelineControllers = [TextEditingController()];
  bool addPublish = false;
  String selectedStatus = "Published";
  String selectedVisibility = "Public";
  ProductCategoriesModel? categories;
  SubCategoriesModel? subCategories;
  PostProductModel? postResponse;
  getProductSubCategory() async {
    subCategories = await HttpService.getProductSubCategory(categoryId);
    if (subCategories != null) {
      filteredSubCategories = subCategories!.data;
      setState(() {
        isLoading = false;
      });
    }
  }

  getProductCategory() async {
    categories = await HttpService.getProductCategory();
    if (categories != null) {
      filteredCategories = categories!.data;
      setState(() {
        isLoading = false;
      });
    }
  }

  getProductTypes() async {
    final response = await HttpService.getProductTypes();
    if (response != null && response.status) {
      setState(() {
        productTypeList = response.data;
      });
    }
  }

  void filterCategories(
    String query,
  ) {
    filteredCategories = categories!.data
        .where((map) =>
            map.categoryName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  Future<bool> validateBarcode() async {
  if (barcodeController.text.trim().isEmpty) {
    return true;
  }

  final result = await HttpService.checkBarcodeDuplicate(
    barcodeController.text.trim(),
    "0",
  );

  print("result = $result");
  print("duplicate = ${result?.duplicate}");
  print("message = ${result?.message}");

  if (result != null && result.duplicate == true) {
    Common.toastMessaage(
      result.message ?? "Barcode already exists",
      Colors.red,
    );

    return false;
  }

  return true;
}
  Future<void> checkBarcodeValidation() async {
  if (barcodeController.text.trim().isEmpty) {
    setState(() {
      barcodeError = null;
      isBarcodeDuplicate = false;
    });
    return;
  }

  final result = await HttpService.checkBarcodeDuplicate(
    barcodeController.text.trim(),
    "0",
  );

  setState(() {
    if (result != null && result.duplicate == true) {
      barcodeError = result.message ?? "Barcode already exists";
      isBarcodeDuplicate = true;
    } else {
      barcodeError = null;
      isBarcodeDuplicate = false;
    }
  });
}
  
  void filterSubCategories(
    String query,
  ) {
    filteredSubCategories = subCategories!.data
        .where((map) =>
            map.subCategory.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  postProducts() async {
    postResponse = await HttpService.postProducts(
      contentId.text,
      categoryId,
      subCategoryId,
      productName.text,
      productCode.text,
      productUCode.text,
      mrp.text,
      noOfDays.text,
      remindBefore.text,
      sellingPrice.text,
      purchasePrice.text,
      barcodeController.text,
      tax.text,
      totalAmount.text,
      description.text,
      productImage,
      selectedProductType ?? "",
      "",
      brand.text,
      discount.text,
      expiryDays.text,
      addStock: addStock ? "1" : "0",
      checkStock: checkStock ? "1" : "0",
      openingStock: openingStock.text,
      currentStock: currentStock.text,
      stockStatus: selectedStockStatus,
      unit: selectedUnitId,
      unitId: selectedUnitId,
      hasWarranty: hasWarranty,
      pipelines: pipelineControllers
          .map((e) => e.text)
          .where((text) => text.isNotEmpty)
          .toList(),
      addPublish: addPublish,
      publishStatus: selectedStatus,
      visibility: selectedVisibility,
      expiryDate: expiryDate.text,
      warrantyNumber: warrantyNumber.text,
      lowStock: lowStock.text,
      serviceCycle: selectedServiceCycle,
      freeService: freeService.text,
      paidService: paidService.text,
      serviceNoOfDays: serviceNoOfDays.text,
      serviceWeeks: selectedWeekDay,
      serviceMonthDays: serviceMonthDays.text,
      serviceYearDays: serviceYearDays.text,
      serviceYearMonth: selectedYearMonth,
      complaints: List.generate(complaintControllers.length, (index) {
        return {
          "type": selectedComplaintTypes[index],
          "remark": complaintControllers[index].text
        };
      }).where((element) => element["remark"]!.isNotEmpty).toList(),
    );
    if (postResponse != null && postResponse!.status == true) {
      Navigator.pop(context);
      Navigator.pop(context, true);
      Common.toastMessaage(postResponse!.message, Colors.green);
    } else {
      Navigator.pop(context);
      Common.toastMessaage(postResponse!.message, Colors.red);
    }
  }

  getUnitsList() async {
    setState(() {
      isUnitsLoading = true;
    });
    try {
      final response = await HttpService.getUnits();
      if (response != null && response.status == true) {
        setState(() {
          unitList = response.data ?? [];
          filteredUnits = unitList;
        });
      }
    } catch (e) {
      debugPrint("Error fetching units: $e");
    } finally {
      setState(() {
        isUnitsLoading = false;
      });
    }
  }

  void filterUnits(String query) {
    setState(() {
      filteredUnits = unitList
          .where((m) =>
              (m.unitName ?? "").toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showQuickAddUnitDialog() {
    final TextEditingController newUnitController = TextEditingController();
    final newUnitFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Quick Add Unit",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Form(
            key: newUnitFormKey,
            child: TextFormField(
              controller: newUnitController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Unit Name *",
                hintText: "e.g. PCS, KG, BOX",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? "Enter unit name" : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newUnitFormKey.currentState!.validate()) {
                  Common.showProgressDialog(context, "Adding Unit...");
                  try {
                    final response = await HttpService.addUnit(
                        newUnitController.text.trim());
                    Navigator.pop(context); // Pop loading dialog
                    if (response != null &&
                        (response['status'] == true ||
                            response['status'] == 'true')) {
                      Common.toastMessaage(
                          response['message'] ?? "Unit added successfully",
                          Colors.green);
                      Navigator.pop(context); // Pop Quick Add Dialog
                      await getUnitsList();
                      setState(() {
                        unitController.text = newUnitController.text.trim();
                      });
                      final addedUnit = unitList.firstWhere(
                        (element) =>
                            (element.unitName ?? "").toLowerCase() ==
                            newUnitController.text.trim().toLowerCase(),
                        orElse: () => UnitData(
                            id: "", unitName: newUnitController.text.trim()),
                      );
                      setState(() {
                        unitController.text = addedUnit.unitName ?? "";
                        selectedUnitId = addedUnit.id ?? "";
                      });
                    } else {
                      Common.toastMessaage(
                          response?['message'] ?? "Failed to add unit",
                          Colors.red);
                    }
                  } catch (e) {
                    Navigator.pop(context); // Pop loading dialog
                    Common.toastMessaage("Error: $e", Colors.red);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a86c9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

@override
void initState() {
  super.initState();

  getProductCategory();
  getProductTypes();
  getUnitsList();

  checkStock = true;
  addPublish = true;
  selectedStatus = "Published";
  selectedVisibility = "Public";
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      const Text(
                        "Add Product",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionCard(
                    title: "Basic Information",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: "Product Type *",
                              value: selectedProductType,
                              items: productTypeList,
                              onChanged: (val) async {
                                setState(() {
                                  selectedProductType = val;
                                });
                                if (val != null) {
                                  final response =
                                      await HttpService.getContentId(
                                          productType: val);
                                  if (response != null && response.status) {
                                    setState(() {
                                      contentId.text = response.data;
                                    });
                                  }
                                }
                              },
                              validator: (val) =>
                                  val == null ? "Select Product Type" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: productName,
                              label: "Product Name *",
                              icon: Icons.layers_outlined,
                              validator: (val) =>
                                  val!.isEmpty ? "Enter Product Name" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: productUCode,
                                label: "Product Code ",
                                icon: Icons.qr_code_outlined,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //     child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       _buildTextField(
                      //         controller: barcodeController,
                      //         label: "Barcode value",
                      //         icon: Icons.qr_code,
                      //         onChanged: (value) async {
                      //           if (value.trim().isEmpty) {
                      //             setState(() {
                      //               barcodeError = null;
                      //             });
                      //             return;
                      //           }

                      //           final result = await HttpService.checkBarcodeDuplicate(
                      //             value.trim(),
                      //             productId?.toString() ?? "0",
                      //           );

                      //           setState(() {
                      //             if (result?.duplicate == true) {
                      //               barcodeError = result?.message;
                      //             } else {
                      //               barcodeError = null;
                      //             }
                      //           });
                      //         },
                      //       ),

                      //       if (barcodeError != null)
                      //         Padding(
                      //           padding: const EdgeInsets.only(top: 5),
                      //           child: Text(
                      //             barcodeError!,
                      //             style: const TextStyle(
                      //               color: Colors.red,
                      //               fontSize: 12,
                      //             ),
                      //           ),
                      //         ),
                      //     ],
                      //   )
                      //   ),
                      //     const SizedBox(width: 12),
                      //     Transform.translate(
                      //       offset: const Offset(0, 24),
                      //       child: Container(
                      //         height: 50,
                      //         width: 50,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //           color: const Color(0xFF2a86c9),
                      //         ),
                      //         child: IconButton(
                      //           onPressed: () async {
                      //             var res = await Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => const SimpleBarcodeScannerPage(),
                      //               ),
                      //             );

                      //             if (res is String && res != '-1') {
                      //             barcodeController.text = res;

                      //             // print("Scanned Barcode = $res");

                      //             final result = await HttpService.checkBarcodeDuplicate(
                      //               res,
                      //               "0",
                      //             );

                      //             // print("API Result = $result");
                      //             // print("Duplicate = ${result?.duplicate}");
                      //             // print("Message = ${result?.message}");

                      //             setState(() {
                      //               if (result?.duplicate == true) {
                      //                 barcodeError = result?.message;
                      //               } else {
                      //                 barcodeError = null;
                      //               }
                      //             });

                      //             print("barcodeError = $barcodeError");
                      //           }
                      //           },
                      //           icon: const Icon(Icons.qr_code_scanner,
                      //               color: Colors.white, size: 24),
                      //           padding: EdgeInsets.zero,
                      //           constraints: const BoxConstraints(),
                      //           style: IconButton.styleFrom(
                      //             backgroundColor: const Color(0xFF2a86c9),
                      //             shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(8)),
                      //             minimumSize: const Size(50, 50),
                      //           ),
                      //           tooltip: "Scan Barcode",
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),
                      Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: _buildTextField(
        controller: productCode,
        label: selectedProductType == "Service"
            ? "SAC Code"
            : "HSN Code",
        icon: Icons.qr_code_outlined,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildTextField(
        controller: brand,
        label: "Brand *",
        icon: Icons.branding_watermark_outlined,
        validator: (val) =>
          val!.isEmpty ? "Enter Brand Name" : null,
      ),
    ),
  ],
),

const SizedBox(height: 16),

Row(
  children: [
    Expanded(
      child: _buildSelectField(
        controller: unitController,
        label: "Unit *",
        validator: (val) =>
          val!.isEmpty ? "Select Unit" : null,
        onTap: () {
          dropDialog(context, "unit");
        },
        actionWidget: _buildAddButton(() {
          _showQuickAddUnitDialog();
        }),
      ),
    ),
  ],
),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: "Pricing & Tax",
                    children: [
                      Row(
                        children: [
//                           Expanded(
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _buildTextField(
//         controller: sellingPrice,
//         label: selectedProductType == "Rental"
//             ? "Rental Price *"
//             : "Selling Price *",
//         icon: Icons.currency_rupee_outlined,
//         keyboardType: TextInputType.number,
//         onChanged: (val) {
//           _updateTotalAmount();
//           formKey.currentState?.validate();
//         },
//         validator: (val) => val!.isEmpty
//             ? (selectedProductType == "Rental"
//                 ? "Enter Rental Price"
//                 : "Enter Selling Price")
//             : null,
//       ),

//       if (selectedProductType != "Rental")
//         const Padding(
//           padding: EdgeInsets.only(
//             left: 4,
//             top: 4,
//           ),
//         ),
//     ],
//   ),
// ),
                          // const SizedBox(width: 12),
                          Expanded(
                            child: 
                           _buildTextField(
                                  controller: purchasePrice,
                                  label: "Purchase Amount",
                                  icon: Icons.currency_rupee_outlined,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) {
                                    _updateTotalAmount();
                                  },
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               _buildTextField(
                              controller: tax,
                              label: "Tax (%)",
                              icon: Icons.percent_outlined,
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _updateTotalAmount(),
                            ),


                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: discount,
                              label: "Discount (%)",
                              icon: Icons.discount_outlined,
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _updateTotalAmount(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    _buildTextField(
                      controller: mrp,
                      label: "MRP",
                      icon: Icons.price_check_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        formKey.currentState?.validate();
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Please enter MRP";
                        }

                        double mrpValue = double.tryParse(val) ?? 0;
                        double purchaseValue = double.tryParse(purchasePrice.text) ?? 0;

                        if (mrpValue < purchaseValue) {
                          return "MRP must be greater than Purchase Amount";
                        }

                        return null;
                      },
                    ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: totalAmount,
                        label: "Total Amount",
                        icon: Icons.account_balance_wallet_outlined,
                        readOnly: true,
                        fillColor: Colors.grey[100],
                      ),
                    ],
                  ),
                  
                  //  const SizedBox(height: 16),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildTextField(
                  //         controller: barcodeController,
                  //         label: "Barcode value",
                  //         icon: Icons.qr_code,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     ElevatedButton.icon(
                  //       onPressed: () async {
                  //         var res = await Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => const SimpleBarcodeScannerPage(),
                  //           ),
                  //         );
                  //         if (res is String && res != '-1') {
                  //           setState(() {
                  //             barcodeController.text = res;
                  //           });
                  //         }
                  //       },
                  //       icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  //       label: const Text("Scan Barcode", style: TextStyle(color: Colors.white)),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: const Color(0xFF2a86c9),
                  //         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 16),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Expanded(
                  //       child: _buildTextField(
                  //         controller: barcodeController,
                  //         label: "Barcode value",
                  //         icon: Icons.qr_code,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Transform.translate(
                  //       offset: const Offset(0, 24),
                  //       child: Container(
                  //         height: 50,
                  //         width: 50,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8),
                  //           color: const Color(0xFF2a86c9),
                  //         ),
                  //         child: IconButton(
                  //           onPressed: () async {
                  //             var res = await Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                 builder: (context) =>
                  //                     const SimpleBarcodeScannerPage(),
                  //               ),
                  //             );
                  //             if (res is String && res != '-1') {
                  //               setState(() {
                  //                 barcodeController.text = res;
                  //               });
                  //             }
                  //           },
                  //           icon: const Icon(Icons.qr_code_scanner,
                  //               color: Colors.white, size: 24),
                  //           padding: EdgeInsets.zero,
                  //           constraints: const BoxConstraints(),
                  //           style: IconButton.styleFrom(
                  //             backgroundColor: const Color(0xFF2a86c9),
                  //             shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(8)),
                  //             minimumSize: const Size(50, 50),
                  //           ),
                  //           tooltip: "Scan Barcode",
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: "Other Details",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: contentId,
                              label: "Content ID",
                              icon: Icons.badge_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDynamicExpiryField(),
                          ),
                        ],
                      ),
                      // if (selectedProductType == "Service" && hasWarranty) ...[
                        // const SizedBox(height: 16),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: _buildSelectField(
                        //         controller: expiryDate,
                        //         label: "Expiry Date",
                        //         icon: Icons.calendar_month,
                        //         onTap: () async {
                        //           DateTime? pickedDate = await showDatePicker(
                        //               context: context,
                        //               initialDate: DateTime.now(),
                        //               firstDate: DateTime(2000),
                        //               lastDate: DateTime(2101));
                        //           if (pickedDate != null) {
                        //             setState(() {
                        //               expiryDate.text = DateFormat('yyyy-MM-dd')
                        //                   .format(pickedDate);
                        //             });
                        //           }
                        //         },
                        //       ),
                        //     ),
                        //     const SizedBox(width: 12),
                        //     Expanded(
                        //       child: _buildTextField(
                        //         controller: warrantyNumber,
                        //         label: "Warranty Number",
                        //         icon: Icons.numbers,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 16),
                        // _buildDropdownField(
                        //   label: "Service Cycle",
                        //   value: selectedServiceCycle,
                        //   items: serviceCycles,
                        //   onChanged: (val) {
                        //     setState(() {
                        //       selectedServiceCycle = val;
                        //     });
                        //   },
                        // ),
                        // if (selectedServiceCycle == "N Days") ...[
                        //   const SizedBox(height: 16),
                        //   _buildTextField(
                        //     controller: serviceNoOfDays,
                        //     label: "No of Days",
                        //     icon: Icons.calendar_today,
                        //     keyboardType: TextInputType.number,
                        //   ),
                        // ],
                        // if (selectedServiceCycle == "Weekly") ...[
                        //   const SizedBox(height: 16),
                        //   _buildDropdownField(
                        //     label: "Select Week Day",
                        //     value: selectedWeekDay,
                        //     items: weekDays,
                        //     onChanged: (val) {
                        //       setState(() {
                        //         selectedWeekDay = val;
                        //       });
                        //     },
                        //   ),
                        // ],
                        // if (selectedServiceCycle == "Monthly") ...[
                        //   const SizedBox(height: 16),
                        //   _buildTextField(
                        //     controller: serviceMonthDays,
                        //     label: "No of Days",
                        //     icon: Icons.calendar_today,
                        //     keyboardType: TextInputType.number,
                        //   ),
                        // ],
                        // if (selectedServiceCycle == "Yearly") ...[
                        //   const SizedBox(height: 16),
                        //   Row(
                        //     children: [
                        //       Expanded(
                        //         child: _buildTextField(
                        //           controller: serviceYearDays,
                        //           label: "No of Days",
                        //           icon: Icons.calendar_today,
                        //           keyboardType: TextInputType.number,
                        //         ),
                        //       ),
                        //       const SizedBox(width: 12),
                        //       Expanded(
                        //         child: _buildDropdownField(
                        //           label: "Select Month",
                        //           value: selectedYearMonth,
                        //           items: months,
                        //           onChanged: (val) {
                        //             setState(() {
                        //               selectedYearMonth = val;
                        //             });
                        //           },
                        //         ),
                        //       ),
                            // ],
                          // ),
                        // ],
                      // ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: description,
                        label: "Description",
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: "Classification",
                    children: [
                      _buildSelectField(
                        controller: category,
                        label: "Category",
                        icon: Icons.category_outlined,
                        onTap: () => dropDialog(context, "category"),
                        // validator: (val) =>
                        //     val!.isEmpty ? "Select Category" : null,
                        actionWidget: _buildAddButton(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ProductCategories()),
                          ).then((value) => getProductCategory());
                        }),
                      ),
                      if (categoryId != "") ...[
                        const SizedBox(height: 16),
                        _buildSelectField(
                          controller: subCategory,
                          label: "Sub Category",
                          icon: Icons.account_tree_outlined,
                          onTap: () => dropDialog(context, "sub category"),
                          // validator: (val) =>
                          //     val!.isEmpty ? "Select Sub Category" : null,
                          actionWidget: _buildAddButton(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubCategories(
                                  catId: categoryId,
                                  title: category.text,
                                ),
                              ),
                            ).then((value) => getProductSubCategory());
                          }),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (selectedProductType == "Service") ...[
                    _buildPipelineSection(),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionCard(
                    title: "Stock Management",
                    trailing: IconButton(
                      icon: Icon(
                        addStock
                            ? Icons.remove_circle_outline
                            : Icons.add_circle_outline,
                        color: addStock ? Colors.red : const Color(0xFF2a86c9),
                      ),
                      onPressed: () {
                        setState(() {
                          addStock = !addStock;
                          if (!addStock) {
                            openingStock.clear();
                            currentStock.clear();
                            selectedStockStatus = "In Stock";
                            checkStock = false;
                          }
                        });
                      },
                    ),
                    children: !addStock
                        ? []
                        : [
                            // Row(
                            //   children: [
                            //     Checkbox(
                            //       value: checkStock,
                            //       onChanged: (val) {
                            //         setState(() {
                            //           checkStock = val!;
                            //         });
                            //       },
                            //       activeColor: const Color(0xFF2a86c9),
                            //     ),
                            //     const Text("Check Stock"),
                            //   ],
                            // ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: openingStock,
                                        label: "Opening Stock *",
                                        icon: Icons.inventory_2_outlined,
                                        keyboardType: TextInputType.number,
                                        validator: (val) =>
                                            addStock && val!.isEmpty
                                                ? "Enter Opening Stock"
                                                : null,
                                      ),
                                    ),
                                  ],
                                ),
                                 Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: lowStock,
                                        label: "Low Stock Limit",
                                        icon: Icons.numbers,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: checkStock,
                                      onChanged: (val) {
                                        setState(() {
                                          checkStock = val!;
                                        });
                                      },
                                      activeColor: const Color(0xFF2a86c9),
                                    ),
                                    const Text(
                                      "Check Stock",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, top: 2),
                                  child: Text(
                                    "Enable this checkbox to check inventory stock. If disabled, unlimited sales are allowed.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                  ),
                  if (selectedProductType == "Service" && hasWarranty) ...[
                    const SizedBox(height: 16),
                    _buildServiceCountSection(),
                    const SizedBox(height: 16),
                    _buildComplaintsSection(),
                  ],
                  if (selectedProductType == "Ecommerce" ||
                      selectedProductType == "Rental") ...[
                    const SizedBox(height: 16),
                    _buildPublishSection(),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: "Product Image",
                    children: [
                      GestureDetector(
                        onTap: () {
                          selectFile();
                        },
                        child: productImage == null
                            ? Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined,
                                        size: 40, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text("Add Product Photo",
                                        style:
                                            TextStyle(color: Colors.grey[500])),
                                  ],
                                ),
                              )
                            : Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(
                                      File(productImage!),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2a86c9).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RawMaterialButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Common.showProgressDialog(
                              context, "Saving Product...");
                          postProducts();
                        } else {
                          Common.toastMessaage(
                              "Please complete all required fields",
                              Colors.red);
                        }
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        "SAVE PRODUCT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _updateTotalAmount() {
  //   double selling = double.tryParse(sellingPrice.text) ?? 0;
  //   double taxVal = double.tryParse(tax.text) ?? 0;
  //   double discVal = double.tryParse(discount.text) ?? 0;

  //   double total =
  //       (selling + (selling * taxVal / 100)) - (selling * discVal / 100);
  //   setState(() {
  //     totalAmount.text = total.roundToDouble().toString();
  //     mrp.text = totalAmount.text;
  //   });
  // }
void _updateTotalAmount() {
  double purchase =
      double.tryParse(purchasePrice.text) ?? 0;

  double taxValue =
      double.tryParse(tax.text) ?? 0;

  double discountValue =
      double.tryParse(discount.text) ?? 0;

  // Tax amount
  double taxAmount =
      purchase * taxValue / 100;

  // MRP = Purchase + Tax
  double mrpAmount =
      purchase + taxAmount;

  // Discount on MRP
  double discountAmount =
      mrpAmount * discountValue / 100;

  // Total Amount
  double total =
      mrpAmount - discountAmount;

  setState(() {
    if (selectedProductType != "Rental") {
      mrp.text = mrpAmount.toStringAsFixed(2);
    }

    totalAmount.text = total.toStringAsFixed(2);
  });

  formKey.currentState?.validate();
}
  Widget _buildLabel(String label) {
    bool hasAsterisk = label.contains('*');
    String cleanLabel = label.replaceAll('*', '').trim();

    return RichText(
      text: TextSpan(
        text: cleanLabel,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
        children: [
          if (hasAsterisk)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

Widget _buildDynamicExpiryField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _buildLabel("Warranty *"),
      ),
      Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: hasWarranty,
            onChanged: (val) {
              setState(() {
                hasWarranty = val!;
              });
            },
            activeColor: const Color(0xFF2a86c9),
          ),
          const Text("Yes"),

          const SizedBox(width: 16),

          Radio<bool>(
            value: false,
            groupValue: hasWarranty,
            onChanged: (val) {
              setState(() {
                hasWarranty = val!;
              });
            },
            activeColor: const Color(0xFF2a86c9),
          ),
          const Text("No"),
        ],
      ),

      if (hasWarranty) ...[
        const SizedBox(height: 16),

        _buildTextField(
          controller: warrantyNumber,
          label: "Warranty Number",
          icon: Icons.confirmation_number_outlined,
        ),

        const SizedBox(height: 16),

        _buildTextField(
  controller: expiryDate,
  label: "Warranty Expiry Date",
  icon: Icons.calendar_today_outlined,
  readOnly: true,
  onTap: () async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      expiryDate.text =
          DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  },
),
      ],
    ],
  );
}
  Widget _buildPipelineSection() {
    return _buildSectionCard(
      title: "Add Pipeline",
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pipelineControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildTextField(
                controller: pipelineControllers[index],
                label: "Pipeline Name *",
                icon: Icons.linear_scale,
                validator: (val) => val!.isEmpty ? "Enter Pipeline Name" : null,
                actionWidget: index == 0
                    ? _buildActionButton(Icons.add, const Color(0xFF26A69A),
                        () {
                        setState(() {
                          pipelineControllers.add(TextEditingController());
                        });
                      })
                    : _buildActionButton(
                        Icons.delete_outline, const Color(0xFFEF5350), () {
                        setState(() {
                          pipelineControllers.removeAt(index);
                        });
                      }),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  // Widget _buildPublishSection() {
  //   return _buildSectionCard(
  //     title: "Publish",
  //     trailing: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         IconButton(
  //           icon: Icon(
  //             addPublish
  //                 ? Icons.remove_circle_outline
  //                 : Icons.add_circle_outline,
  //             color: addPublish ? Colors.red : const Color(0xFF2a86c9),
  //             size: 28,
  //           ),
  //           onPressed: () {
  //             setState(() {
  //               addPublish = !addPublish;
  //               if (!addPublish) {
  //                 // Reset values when closing
  //                 selectedStatus = "Published";
  //                 selectedVisibility = "Public";
  //               }
  //             });
  //           },
  //         ),
  //         // const SizedBox(width: 4),
  //         // Text(
  //         //   addPublish ? "Hide Publish" : "Add Publish",
  //         //   style: TextStyle(
  //         //     fontWeight: FontWeight.w600,
  //         //     color: addPublish ? Colors.red : const Color(0xFF2a86c9),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //     children: addPublish
  //         ? [
  //             _buildDropdownField(
  //               label: "Status",
  //               value: selectedStatus,
  //               items: ["Published", "Draft"],
  //               onChanged: (val) {
  //                 setState(() {
  //                   selectedStatus = val!;
  //                 });
  //               },
  //             ),
  //             const SizedBox(height: 16),
  //             _buildDropdownField(
  //               label: "Visibility",
  //               value: selectedVisibility,
  //               items: ["Public", "Private"],
  //               onChanged: (val) {
  //                 setState(() {
  //                   selectedVisibility = val!;
  //                 });
  //               },
  //             ),
  //           ]
  //         : [],
  //   );
  // }
  Widget _buildPublishSection() {
    return _buildSectionCard(
      title: "Publish",
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: addPublish,
            onChanged: (val) {
              setState(() {
                addPublish = val!;
              });
            },
            activeColor: const Color(0xFF2a86c9),
          ),
          const Text("Add Publish",
              style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      children: [
        if (addPublish) ...[
          _buildDropdownField(
            label: "Status",
            value: selectedStatus,
            items: ["Published", "Draft"],
            onChanged: (val) {
              setState(() {
                selectedStatus = val!;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: "Visibility",
            value: selectedVisibility,
            items: ["Public", "Private"],
            onChanged: (val) {
              setState(() {
                selectedVisibility = val!;
              });
            },
          ),
        ]
      ],
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required List<Widget> children,
      Widget? trailing}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    Color? fillColor,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    Widget? actionWidget,
    List<TextInputFormatter>? inputFormatters, 
    VoidCallback? onTap,// Add this parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                readOnly: readOnly,
                onChanged: onChanged,
                onTap: onTap, 
                validator: validator,
                inputFormatters: inputFormatters, // Add this line
                decoration: InputDecoration(
                  hintText: label.replaceAll('*', '').trim(),
                  prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
                  filled: fillColor != null,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2a86c9), width: 2),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  errorMaxLines: 2,
                  errorStyle: const TextStyle(
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            if (actionWidget != null) ...[
              const SizedBox(width: 8),
              actionWidget,
            ],
          ],
        ),
      ],
    );
  }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   required IconData icon,
  //   TextInputType keyboardType = TextInputType.text,
  //   int maxLines = 1,
  //   bool readOnly = false,
  //   Color? fillColor,
  //   ValueChanged<String>? onChanged,
  //   FormFieldValidator<String>? validator,
  //   Widget? actionWidget,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildLabel(label),
  //       const SizedBox(height: 8),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Expanded(
  //             child: TextFormField(
  //               controller: controller,
  //               keyboardType: keyboardType,
  //               maxLines: maxLines,
  //               readOnly: readOnly,
  //               onChanged: onChanged,
  //               validator: validator,
  //               decoration: InputDecoration(
  //                 hintText: label.replaceAll('*', '').trim(),
  //                 prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
  //                 filled: fillColor != null,
  //                 fillColor: fillColor,
  //                 border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12)),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: BorderSide(color: Colors.grey[300]!),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide:
  //                       const BorderSide(color: Color(0xFF2a86c9), width: 2),
  //                 ),
  //                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
  //                 contentPadding:
  //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //                 errorMaxLines:
  //                     2, // Add this line to allow multi-line error messages
  //                 errorStyle: const TextStyle(
  //                   fontSize: 11,
  //                   height:
  //                       1.2, // Optional: Adjust line height for better readability
  //                 ),
  //               ),
  //             ),
  //           ),
  //           if (actionWidget != null) ...[
  //             const SizedBox(width: 8),
  //             actionWidget,
  //           ],
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   required IconData icon,
  //   TextInputType keyboardType = TextInputType.text,
  //   int maxLines = 1,
  //   bool readOnly = false,
  //   Color? fillColor,
  //   ValueChanged<String>? onChanged,
  //   FormFieldValidator<String>? validator,
  //   Widget? actionWidget,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildLabel(label),
  //       const SizedBox(height: 8),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Expanded(
  //             child: TextFormField(
  //               controller: controller,
  //               keyboardType: keyboardType,
  //               maxLines: maxLines,
  //               readOnly: readOnly,
  //               onChanged: onChanged,
  //               validator: validator,
  //               decoration: InputDecoration(
  //                 hintText: label.replaceAll('*', '').trim(),
  //                 prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
  //                 filled: fillColor != null,
  //                 fillColor: fillColor,
  //                 border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12)),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: BorderSide(color: Colors.grey[300]!),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide:
  //                       const BorderSide(color: Color(0xFF2a86c9), width: 2),
  //                 ),
  //                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
  //                 contentPadding:
  //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //               ),
  //             ),
  //           ),
  //           if (actionWidget != null) ...[
  //             const SizedBox(width: 8),
  //             actionWidget,
  //           ],
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: label.replaceAll('*', '').trim(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2a86c9), width: 2),
            ),
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    required VoidCallback onTap,
    FormFieldValidator<String>? validator,
    Widget? actionWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: true,
                onTap: onTap,
                validator: validator,
                decoration: InputDecoration(
                  hintText: label.replaceAll('*', '').trim(),
                  prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2a86c9), width: 2),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            if (actionWidget != null) ...[
              const SizedBox(width: 8),
              actionWidget,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<dynamic> dropDialog(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
                scrollable: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      height: 40,
                      child: TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onChanged: ((value) {
                          setDialogState(() {
                            if (title == "category") {
                              filterCategories(value);
                            } else if (title == "sub category") {
                              filterSubCategories(value);
                            } else if (title == "unit") {
                              filterUnits(value);
                            }
                          });
                        }),
                      ),
                    )
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .7,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: title == "category"
                        ? filteredCategories.length
                        : title == "sub category"
                            ? filteredSubCategories.length
                            : filteredUnits.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: (() {
                          if (title == "category") {
                            category.text =
                                filteredCategories[index].categoryName;
                            categoryId = filteredCategories[index].id;
                            Navigator.pop(context);
                            setState(() {});
                            filterCategories("");
                            getProductSubCategory();
                          } else if (title == "sub category") {
                            subCategory.text =
                                filteredSubCategories[index].subCategory;
                            subCategoryId = filteredSubCategories[index].id;
                            Navigator.pop(context);
                            setState(() {});
                            filterSubCategories("");
                          } else if (title == "unit") {
                            unitController.text =
                                filteredUnits[index].unitName ?? "";
                            selectedUnitId = filteredUnits[index].id ?? "";
                            Navigator.pop(context);
                            setState(() {});
                            filterUnits("");
                          }
                        }),
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            title == "category"
                                ? filteredCategories[index]
                                    .categoryName
                                    .toString()
                                : title == "sub category"
                                    ? filteredSubCategories[index]
                                        .subCategory
                                        .toString()
                                    : filteredUnits[index].unitName.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  pickImage(context, source) async {
    try {
      Navigator.pop(context);
      final pickedFile = await ImagePicker().pickImage(source: source);
      //await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
      setState(() {
        productImage = pickedFile!.path;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  selectFile() {
    showModalBottomSheet(
      context: context,
      builder: ((builder) {
        return Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width * 1,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: <Widget>[
              const Text(
                "Choose  photo",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        await pickImage(context, ImageSource.camera);
                      },
                      child: const Column(
                        children: [Icon(Icons.camera), Text('Camera')],
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    InkWell(
                      onTap: () async {
                        await pickImage(context, ImageSource.gallery);
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.image),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ])
            ],
          ),
        );
      }),
    );
  }

  Widget _buildServiceCountSection() {
    return _buildSectionCard(
      title: "Service Count",
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: freeService,
                label: "Free Service",
                icon: Icons.sync,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: paidService,
                label: "Paid Service",
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplaintsSection() {
    return _buildSectionCard(
      title: "Add Complaints",
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: complaintControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showComplaintTypeDialog(index),
                    child: Container(
                      height: 50,
                      width: 100, // Fixed width for the type box
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedComplaintTypes[index] ?? "Type",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: complaintControllers[index],
                      decoration: InputDecoration(
                        hintText: "Enter Remarks",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF2a86c9), width: 2),
                        ),
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  index == 0
                      ? _buildActionButton(Icons.add, const Color(0xFF26A69A),
                          () {
                          setState(() {
                            complaintControllers.add(TextEditingController());
                            selectedComplaintTypes.add("Complaint Type");
                          });
                        })
                      : _buildActionButton(
                          Icons.delete_outline, const Color(0xFFEF5350), () {
                          setState(() {
                            complaintControllers.removeAt(index);
                            selectedComplaintTypes.removeAt(index);
                          });
                        }),
                ],
              ),
            );
          },
        )
      ],
    );
  }

  void _showComplaintTypeDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Complaint Type"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: complaintTypeOptions.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(complaintTypeOptions[i]),
                  onTap: () {
                    setState(() {
                      selectedComplaintTypes[index] = complaintTypeOptions[i];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
