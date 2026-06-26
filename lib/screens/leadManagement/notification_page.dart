import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/ChatScreenWork.dart';
import 'package:lottie/lottie.dart';
import '../../models/lead_management/delete_notification.dart';
import '../../models/lead_management/leadNotificationListModel.dart';
import '../../service/service.dart';
import '../officialWhatsapp/chatScreen.dart';
import 'viewLeadsNew.dart';

// ignore: must_be_immutable
class NotificationPage extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  NotificationPage(this.token, this.editLead, this.deleteLead, this.cloudCall,
      {super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  LeadNotificationListModel? leadNotification;
  DeleteNotification? deleteNotificationModel;
  bool result = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  deleteNotification(String notificationId) async {
    deleteNotificationModel =
        await HttpService.deleteNotification(widget.token, notificationId);
    if (deleteNotificationModel != null &&
        deleteNotificationModel!.data == true) {
      Common.toastMessaage('Deleted', Colors.green);
      getData();
    } else {
      Common.toastMessaage('Something went wrong', Colors.red);
    }
    setState(() {});
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
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

    leadNotification = await HttpService.leadNotificationList(widget.token);
    if (leadNotification != null) {
      setState(() {});
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (result == true) {
      return RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        child: Scaffold(
            backgroundColor: Colors.grey.shade200,
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
                            'Notification',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: isLoading == false
                ? leadNotification!.data.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: ListView.builder(
                          itemCount: leadNotification!.data.length,
                          itemBuilder: (context, i) {
                            return Dismissible(
                              key: const Key('0'),
                              background: Container(
                                color: Colors.red,
                                child: const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                deleteDialog(context,
                                    leadNotification!.data[i].notificationId);
                                return null;
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    i == 0
                                        ? const SizedBox(
                                            height: 10,
                                          )
                                        : const SizedBox(),
                                    GestureDetector(
                                      onTap: () async {
                                        if (leadNotification!.data[i].type ==
                                            "2") {
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewLeadsNew(
                                                  widget.token!,
                                                  widget.editLead,
                                                  widget.deleteLead,
                                                  widget.cloudCall,
                                                  notificationLeadId:
                                                      leadNotification!
                                                          .data[i].id
                                                          .toString(),
                                                  pageName: 'LeadNotification',
                                                ),
                                              ),
                                            ).then((r) {
                                              getData();
                                            });
                                          }
                                        } else if (leadNotification!
                                                .data[i].type ==
                                            "12") {
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AssignReport(
                                                        preselectedWorkId:
                                                            leadNotification!
                                                                .data[i].id
                                                                .toString(),
                                                        workId:
                                                            leadNotification!
                                                                .data[i].id
                                                                .toString(),
                                                        sectionId: ""),
                                              ),
                                            );
                                          }
                                        } else if (leadNotification!
                                                .data[i].type ==
                                            "13") {
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AssignReport(
                                                        preselectedWorkId:
                                                            leadNotification!
                                                                .data[i]
                                                                .assignedId
                                                                .toString(),
                                                        workId:
                                                            leadNotification!
                                                                .data[i]
                                                                .assignedId
                                                                .toString(),
                                                        sectionId: ""),
                                              ),
                                            );
                                          }
                                        } else if (leadNotification!
                                                .data[i].type ==
                                            "14") {
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AssignReport(
                                                        preselectedWorkId:
                                                            leadNotification!
                                                                .data[i]
                                                                .assignedId
                                                                .toString(),
                                                        workId:
                                                            leadNotification!
                                                                .data[i]
                                                                .assignedId
                                                                .toString(),
                                                        sectionId: ""),
                                              ),
                                            );
                                          }
                                        } else if (leadNotification!
                                                .data[i].type ==
                                            "15") {
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AssignReport(
                                                        preselectedWorkId:
                                                            leadNotification!
                                                                .data[i]
                                                                .assignedId
                                                                .toString(),
                                                        workId:
                                                            leadNotification!
                                                                .data[i]
                                                                .assignedId
                                                                .toString(),
                                                        sectionId: ""),
                                              ),
                                            );
                                          }
                                        } else if (leadNotification!
                                                .data[i].type ==
                                            "7") {
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreenWork(
                                                  groupId: leadNotification!
                                                      .data[i].id,
                                                  nav: "",
                                                  assignedTo: "",
                                                  project: "",
                                                  assignedToId: "",
                                                ),
                                              ),
                                            );
                                          }
                                        } else if (leadNotification!
                                                .data[i].type ==
                                            "16") {
                                          debugPrint(
                                              "Notification type 16 clicked – no navigation.");
                                        } else {
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                  groupId: leadNotification!
                                                      .data[i].id
                                                      .toString(),
                                                  nav: "",
                                                ),
                                              ),
                                            ).then((r) {
                                              getData();
                                            });
                                          }
                                        }

                                        if (leadNotification!.data[i].isRead ==
                                            false) {
                                          await HttpService
                                              .readLeadNotification(
                                                  widget.token,
                                                  leadNotification!
                                                      .data[i].notificationId);
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: leadNotification!
                                                        .data[i].type ==
                                                    "3"
                                                ? Colors.green
                                                : Colors.white,
                                            child: Image.asset(
                                                leadNotification!
                                                            .data[i].type ==
                                                        "3"
                                                    ? "assets/icons/whatsapp_white.png"
                                                    : "assets/main/funriders.png",
                                                width: 25),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .78,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        leadNotification!
                                                            .data[i].title
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        )),
                                                    Text(
                                                        leadNotification!
                                                            .data[i].dateTime
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.grey
                                                                .shade400)),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      child: Text(
                                                          leadNotification!
                                                              .data[i].content
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          )),
                                                    ),
                                                    leadNotification!.data[i]
                                                                .isRead ==
                                                            false
                                                        ? Container(
                                                            height: 15,
                                                            width: 15,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: Colors.red,
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Divider()
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox(
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
                                  image:
                                      AssetImage('assets/icons/no_alarm.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Text(
                              'No Notification Found !',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                      )
                : Center(
                    child: Lottie.asset('assets/main/loading.json',
                        fit: BoxFit.fill),
                  )),
      );
    } else {
      return Scaffold(
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
  }

  Future<dynamic> deleteDialog(BuildContext context, String notificationId) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    deleteNotification(notificationId);
                    Navigator.pop(context);
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }
}
