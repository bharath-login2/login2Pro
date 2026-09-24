import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
// import '../models/pushNotificationModel.dart';
import '../models/pushNotificationModel.dart';
import 'leadManagement/viewLeadsNew.dart';
import 'officialWhatsapp/chatScreen.dart';

class FirebaseServices {
  String? token;
  bool? editLead;
  bool? deleteLead;
  bool? cloudCall;
  String? navigation;
  String? detailId;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(BuildContext context) async {
    _initNotification(context);
    await FirebaseMessaging.instance.requestPermission();
  }

  void _initNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onNotificationTap(message, context);
    });

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _showNotification(RemoteMessage message) async {
    final notification = PushNotificationModel.fromJson(message.data);
    try {
      // Android-specific configuration
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        message.notification?.android?.channelId ?? "login2",
        message.notification?.android?.channelId ?? "login2",
        importance: Importance.max,
        priority: Priority.high,
        ticker: notification.message,
        channelShowBadge: true,
        icon: '@mipmap/ic_launcher',
      );

      // iOS-specific configuration
      var iosPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: message.notification?.apple?.sound?.name ?? 'default',
      );

      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await notificationsPlugin.show(
        notification.notificationId ?? 0,
        notification.title,
        notification.message,
        platformChannelSpecifics,
        payload: notification.toString(),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void onNotificationTap(RemoteMessage message, BuildContext context) async {
    token = await Common.getSharedPref("token");
    detailId = message.data['detail_id'];
    navigation = message.data['navigation'];
    if (message.data['edit_lead'] == 'true') {
      editLead = true;
    } else {
      editLead = false;
    }
    if (message.data['delete_lead'] == 'true') {
      deleteLead = true;
    } else {
      deleteLead = false;
    }
    if (message.data['cloud_call'] == 'true') {
      cloudCall = true;
    } else {
      cloudCall = false;
    }
    log("🔍 detailId: $detailId");
    log("🔍 message.data: ${message.data}");
    final notificationMessage = message.notification?.body?.toLowerCase() ??
        message.data['message']?.toLowerCase() ??
        '';
    if (navigation == 'whatsapp') {
      Get.to(() => ChatScreen(
            groupId: detailId.toString(),
            nav: "Notification",
          ));
    } else if (navigation == 'notification') {
      if (notificationMessage.contains("task")) {
        Get.to(() => AssignReport(workId: detailId.toString(), sectionId: ""));
      } else if (notificationMessage.contains("Work")) {
        Get.to(() => AssignReport(workId: detailId.toString(), sectionId: ""));
      } else if (notificationMessage.contains("logout")) {
        Get.to(() => DashboardLeadNewUpdatedTwo(token));
      } else if (notificationMessage.contains("login")) {
        Get.to(() => DashboardLeadNewUpdatedTwo(token));
      } else {
        Get.to(() => ViewLeadsNew(
              token!,
              editLead!,
              deleteLead!,
              cloudCall!,
              notificationLeadId: detailId!,
              pageName: 'notification',
            ));
      }
    } else {
      Get.to(() => DashboardLeadNewUpdatedTwo(token!));
    }
  }
}
