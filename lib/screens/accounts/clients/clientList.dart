// ignore_for_file: must_be_immutable

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/deleteMainClientModel.dart';
import 'package:login2/screens/accounts/clients/addInvoice.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/common.dart';
import '../../../models/clients/mainClientListModel.dart';
import '../../../service/service.dart';
import 'addClients.dart';
import 'editClient.dart';
import 'log_screen.dart';

class ClientList extends StatefulWidget {
  String token;
  GlobalKey<ScaffoldState>? scaffoldKey;
  String? filterCategory;
  int? filterCount;
  int? followupCount;
  int? calledCount;
  int? missedCount;
  int? transferredCount;
  String? fromDate;
  String? toDate;

  ClientList(
    this.token,
    this.scaffoldKey, {
    super.key,
    this.filterCategory,
    this.filterCount,
    this.followupCount,
    this.calledCount,
    this.missedCount,
    this.transferredCount,
    this.fromDate,
    this.toDate,
  });

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  MainClientListModel? mainClients;
  bool result = true;
  String? activeFilter;
  TextEditingController searchController = TextEditingController();
  String fDate = "From Date";
  String tDate = "To Date";
  int _lastScrollIndex = 0;
  bool _shouldRestoreScroll = false;
  int page = 1;
  int add = 1;
  int pageSize = 10;
  String name = '';
  String role = '';
  String userId = '';
  String phoneCallLogPermission = '';
  List<ClientLists> items = [];
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  void _onLoadMore() {
    if (items.length + 10 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      getData();
      add++;
    }
  }

  @override
  void initState() {
    super.initState();
    activeFilter = widget.filterCategory;
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    getData();
  }

  // getData() async {
  //   final connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     setState(() {
  //       result = true;
  //     });
  //   } else {
  //     setState(() {
  //       result = false;
  //     });
  //   }

  //   mainClients = await HttpService.mainClients(
  //       widget.token, searchController.text, fDate, tDate, page, pageSize);
  //   if (mainClients != null) {
  //     items.addAll(mainClients!.data);
  //     page++;
  //     setState(() {});
  //   }
  // }
  getData() async {
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    final connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.mobile ||
    //     connectivityResult == ConnectivityResult.wifi) {
    //   setState(() {
    //     result = true;
    //   });
    // } else {
    //   setState(() {
    //     result = false;
    //   });
    // }
    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          result = true;
        });
      }
    } else {
      setState(() {
        result = false;
      });
    }

    mainClients = await HttpService.mainClients(
        widget.token, searchController.text, fDate, tDate, page, pageSize);
    if (mainClients != null) {
      items.addAll(mainClients!.data);
      page++;
      if (_shouldRestoreScroll && items.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_lastScrollIndex < items.length) {
            itemScrollController.scrollTo(
              index: _lastScrollIndex,
              duration: const Duration(milliseconds: 300),
            );
          }
          _shouldRestoreScroll = false;
        });
      }

      setState(() {});
    }
  }

  refreshData() {
    items.clear();
    page = 1;
    add = 1;
    _shouldRestoreScroll = false;
    setState(() {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.grey.shade300,
            appBar: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 10.0),
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
                          Text(
                            activeFilter != null &&
                                    activeFilter!.isNotEmpty &&
                                    activeFilter != 'Total Customers'
                                ? 'Customers - $activeFilter'
                                : 'Customer List',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddClients(widget.token,
                                    createOrder: true)),
                          ).then((_) {
                            items.clear();
                            page = 1;
                            add = 1;
                            _shouldRestoreScroll = false;
                            getData();
                          });
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: mainClients != null
                ? Container(
                    color: Colors.grey[300],
                    child: Column(
                      children: [
                        if (activeFilter != null &&
                            activeFilter!.isNotEmpty &&
                            activeFilter != 'Total Customers')
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 1,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.blue.shade200, width: 0.8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.filter_alt,
                                          size: 18,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Filter: $activeFilter',
                                        style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        activeFilter = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close,
                                          size: 16,
                                          color: Colors.blue.shade800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final selctedDatetimetemp =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(DateTime.now().year,
                                          DateTime.now().month, 1),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    fDate = DateFormat('dd-MM-yyyy')
                                        .format(selctedDatetimetemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            fDate,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final toDateSelectTemp =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    tDate = DateFormat('dd-MM-yyyy')
                                        .format(toDateSelectTemp!);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            tDate,
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 4.0, left: 8.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: TextFormField(
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(8),
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    hintText: 'Search',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide
                                          .none, // Set the border color to none
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  items.clear();
                                  page = 1;
                                  add = 1;
                                  _shouldRestoreScroll = false;
                                  setState(() {
                                    getData();
                                  });
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.31,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: const Color(0xff2590cf)),
                                  child: const Center(
                                    child: Text("Search",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: mainClients!.data.isNotEmpty
                                ? ScrollablePositionedList.builder(
                                    shrinkWrap: true,
                                    itemScrollController: itemScrollController,
                                    itemPositionsListener:
                                        itemPositionsListener,
                                    itemCount: items.length +
                                        (items.length + 10 == page * pageSize
                                            ? 1
                                            : 0),
                                    initialScrollIndex: _shouldRestoreScroll
                                        ? _lastScrollIndex
                                        : 0,
                                    itemBuilder: (context, index) {
                                      if (index == items.length) {
                                        return buildLoaderListItem();
                                      } else {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: InkWell(
                                            // onTap: () {
                                            //   _lastScrollIndex = index;
                                            //   _shouldRestoreScroll = true;

                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //       builder: (context) =>
                                            //           ClientDetails(
                                            //               widget.token,
                                            //               items[index]
                                            //                   .id
                                            //                   .toString()),
                                            //     ),
                                            //   ).then((_) {
                                            //     items.clear();
                                            //     page = 1;
                                            //     add = 1;
                                            //     _shouldRestoreScroll = false;
                                            //     getData();
                                            //   });
                                            // },
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CustomerDashboard(
                                                          name: name,
                                                          token: widget.token!,
                                                          userId: userId,
                                                          phoneCallLogPermission:
                                                              phoneCallLogPermission,
                                                          custId: items[index]
                                                              .id
                                                              .toString(),
                                                          key: widget
                                                              .scaffoldKey),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 1,
                                                      offset:
                                                          const Offset(1, 1),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(14.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                    items[index]
                                                                        .clientName
                                                                        .toString(),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    )),
                                                              ),
                                                              if (items[index]
                                                                      .totalDue !=
                                                                  '') ...[
                                                                const SizedBox(
                                                                    width: 6),
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            2),
                                                                    color: items[index].totalDue ==
                                                                            'Paid'
                                                                        ? const Color(
                                                                            0xffe6fbec)
                                                                        : const Color(
                                                                            0xfffcbcbc),
                                                                  ),
                                                                  child: Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4),
                                                                      child: Text(
                                                                          items[index]
                                                                              .totalDue
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                            color: items[index].totalDue == 'Paid'
                                                                                ? Colors.green
                                                                                : Colors.red,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => AddInvoice(
                                                                          widget
                                                                              .token,
                                                                          items[index]
                                                                              .id
                                                                              .toString(),
                                                                          "")),
                                                                ).then((_) {
                                                                  items.clear();
                                                                  page = 1;
                                                                  add = 1;
                                                                  _shouldRestoreScroll =
                                                                      false;
                                                                  refreshData();
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: const Color(
                                                                        0xffceffe1)),
                                                                child:
                                                                    const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Icon(
                                                                      Icons
                                                                          .currency_rupee,
                                                                      color: Colors
                                                                          .green,
                                                                      size: 18),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => EditClients(
                                                                          widget
                                                                              .token,
                                                                          items[index]
                                                                              .id
                                                                              .toString())),
                                                                ).then((_) {
                                                                  items.clear();
                                                                  page = 1;
                                                                  add = 1;
                                                                  _shouldRestoreScroll =
                                                                      false;
                                                                  refreshData();
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: const Color(
                                                                        0xffaedcf4)),
                                                                child:
                                                                    const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Icon(
                                                                      Icons
                                                                          .mode_edit_outlined,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: 18),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        scrollable:
                                                                            true,
                                                                        title: const Text(
                                                                            'Please Confirm'),
                                                                        content:
                                                                            const Text('Are you sure to Delete?'),
                                                                        actions: [
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text('No')),
                                                                          TextButton(
                                                                              onPressed: () async {
                                                                                Common.showProgressDialog(context, "Loading..");
                                                                                DeleteMainClientModel deleteClients = await HttpService.deleteMainClients(widget.token, items[index].id.toString());
                                                                                if (deleteClients.data == true) {
                                                                                  Common.toastMessaage(deleteClients.message, Colors.green);
                                                                                  refreshData();
                                                                                  if (context.mounted) {
                                                                                    Navigator.pop(context);
                                                                                    Navigator.pop(context);
                                                                                  }
                                                                                } else {
                                                                                  if (context.mounted) {
                                                                                    Navigator.of(context).pop();
                                                                                    Navigator.of(context).pop();
                                                                                    deleteFailedPopup(context, index, deleteClients.message.toString());
                                                                                  }
                                                                                }
                                                                              },
                                                                              child: const Text('Yes')),
                                                                        ],
                                                                      );
                                                                    });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: const Color(
                                                                        0xfffcbcbc)),
                                                                child:
                                                                    const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 18),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .call,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Text(
                                                                        items[index]
                                                                            .phoneNumber
                                                                            .toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ],
                                                            )),
                                                        // items[index].totalInvoiceCount !=
                                                        //         ''
                                                        //     ? Container(
                                                        //         decoration: BoxDecoration(
                                                        //             borderRadius:
                                                        //                 BorderRadius.circular(
                                                        //                     30),
                                                        //             color: const Color(
                                                        //                 0xff80D1FF)),
                                                        //         child: Center(
                                                        //           child:
                                                        //               Padding(
                                                        //             padding: const EdgeInsets
                                                        //                 .only(
                                                        //                 left:
                                                        //                     12,
                                                        //                 right:
                                                        //                     12,
                                                        //                 top: 6,
                                                        //                 bottom:
                                                        //                     6),
                                                        //             child: Text(
                                                        //                 items[index]
                                                        //                     .totalInvoiceCount
                                                        //                     .toString(),
                                                        //                 style:
                                                        //                     const TextStyle(
                                                        //                   color:
                                                        //                       Colors.black,
                                                        //                   fontSize:
                                                        //                       14,
                                                        //                   fontWeight:
                                                        //                       FontWeight.w600,
                                                        //                 )),
                                                        //           ),
                                                        //         ),
                                                        //       )
                                                        //     : const SizedBox()
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .location_on,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Text(
                                                                        items[index]
                                                                            .location
                                                                            .toString(),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ],
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .person,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.38,
                                                                      child: Text(
                                                                          'Created by:${items[index].createdBy}',
                                                                          maxLines:
                                                                              1,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          )),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Text(
                                                                        items[index]
                                                                            .createdAt
                                                                            .toString(),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => CustomerLogHistory(
                                                                          custId: items[index]
                                                                              .id
                                                                              .toString())),
                                                                ).then((_) {
                                                                  items.clear();
                                                                  page = 1;
                                                                  add = 1;
                                                                  _shouldRestoreScroll =
                                                                      false;
                                                                  refreshData();
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: const Color(
                                                                        0xffe2e8f0)),
                                                                child:
                                                                    Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Icon(
                                                                      Icons
                                                                          .history,
                                                                      color: Colors
                                                                          .blueGrey
                                                                          .shade700,
                                                                      size: 18),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                if (items[index]
                                                                        .isNegative ==
                                                                    "1") {
                                                                  _showCustomerNormalDialog(
                                                                      context,
                                                                      items[index]
                                                                          .id
                                                                          .toString());
                                                                } else {
                                                                  _showCustomerFollowupDialog(
                                                                      context,
                                                                      items[index]
                                                                          .id
                                                                          .toString());
                                                                }
                                                              },
                                                              child: Tooltip(
                                                                message: items[index]
                                                                            .isNegative ==
                                                                        "1"
                                                                    ? "Negative Customer"
                                                                    : "Customer Follow-up",
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6),
                                                                    color: items[index].isNegative ==
                                                                            "1"
                                                                        ? const Color(
                                                                            0xfffcbcbc)
                                                                        : const Color(
                                                                            0xffffe8e0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                    child: Icon(
                                                                        items[index].isNegative ==
                                                                                "1"
                                                                            ? Icons.person_off_outlined
                                                                            : Icons.notifications_active_outlined,
                                                                        color: items[index].isNegative == "1"
                                                                            ? Colors.red
                                                                            : const Color(
                                                                                0xFFF28B74),
                                                                        size: 18),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 180,
                                          height: 180,
                                          child: Image.asset(
                                            "assets/icons/nodatafound.png",
                                          ),
                                        ),
                                        const Text(
                                          'No Data Found',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
                  ))
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Text(
                    'No Network Found !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  Future<dynamic> deleteFailedPopup(
      BuildContext context, int index, String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 6.0, left: 6.0),
              child: Column(
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 60,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 15, color: Colors.red),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  void _showCustomerFollowupDialog(BuildContext context, String clientId) {
    final TextEditingController reasonController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF0ED),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_active_outlined,
                                size: 40,
                                color: Color(0xFFF28B74),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'You are about to Mark This Customer as\nNegative?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This will mark the customer as negative and will be visible across all customer lists.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF718096),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: const TextSpan(
                                text: 'Reason for marking negative ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: reasonController,
                            maxLines: 4,
                            minLines: 3,
                            onChanged: (val) {
                              if (errorMessage != null) {
                                setDialogState(() {
                                  errorMessage = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter reason for marking customer as negative...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              errorText: errorMessage,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF406DBE), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Color(0xFF00A884),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Close',
                                        style: TextStyle(
                                          color: Color(0xFF00A884),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF28B74),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final reason = reasonController.text.trim();
                                  if (reason.isEmpty) {
                                    setDialogState(() {
                                      errorMessage = 'Please enter reason for marking customer as negative';
                                    });
                                    return;
                                  }

                                  Common.showProgressDialog(context, "Loading..");
                                  DeleteMainClientModel deleteClients =
                                      await HttpService.markCustomerNegative(
                                          widget.token, clientId, reason);

                                  if (context.mounted) {
                                    Navigator.of(context).pop(); // dismiss loading
                                  }

                                  if (deleteClients.data == true || deleteClients.status == true) {
                                    Common.toastMessaage(
                                      deleteClients.message ?? "Customer marked as negative successfully",
                                      Colors.green,
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop(); // dismiss dialog
                                    }
                                    refreshData();
                                  } else {
                                    Common.toastMessaage(
                                      deleteClients.message ?? "Failed to mark customer as negative",
                                      Colors.red,
                                    );
                                  }
                                },
                                child: const Text(
                                  'Yes, Mark Negative!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          color: Colors.transparent,
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 22,
                          ),
                        ),
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

  void _showCustomerNormalDialog(BuildContext context, String clientId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CustomPaint(
                          painter: _NormalCustomerIconPainter(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'You are about to Mark This Customer as\nNormal?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This will remove the negative status from the customer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Color(0xFF00A884),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Color(0xFF00A884),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A884),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              Common.showProgressDialog(context, "Loading..");
                              DeleteMainClientModel deleteClients =
                                  await HttpService.markCustomerNormal(
                                      widget.token, clientId);

                              if (context.mounted) {
                                Navigator.of(context).pop(); // dismiss loading
                              }

                              if (deleteClients.data == true || deleteClients.status == true) {
                                Common.toastMessaage(
                                  deleteClients.message != null && deleteClients.message!.isNotEmpty
                                      ? deleteClients.message!
                                      : "Customer marked as normal successfully",
                                  Colors.green,
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // dismiss dialog
                                }
                                refreshData();
                              } else {
                                Common.toastMessaage(
                                  deleteClients.message != null && deleteClients.message!.isNotEmpty
                                      ? deleteClients.message!
                                      : "Failed to mark customer as normal",
                                  Colors.red,
                                );
                              }
                            },
                            child: const Text(
                              'Yes, Mark Normal!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.transparent,
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NormalCustomerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final headPaint = Paint()
      ..color = const Color(0xFFF28B74)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    final bodyPaint = Paint()
      ..color = const Color(0xFF00A884)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    double headRadius = size.width * 0.20;
    Offset headCenter = Offset(size.width / 2, size.height * 0.28);
    canvas.drawCircle(headCenter, headRadius, headPaint);

    Rect bodyRect = Rect.fromLTWH(
      size.width * 0.16,
      size.height * 0.48,
      size.width * 0.68,
      size.height * 0.44,
    );
    Path bodyPath = Path();
    bodyPath.addArc(bodyRect, 3.14159, 3.14159);
    canvas.drawPath(bodyPath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

