import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/CompanyLocationPage.dart';
import 'package:lottie/lottie.dart';

import 'package:image_picker/image_picker.dart';

import '../core/common.dart';
import '../screens/leadManagement/viewLogoutPage.dart';
import '../service/service.dart';

class StartStopToggle extends StatefulWidget {
  final bool initialStatus;
  final Function(bool) onToggle;
  final Function(bool) setDashboardLoading;
  final bool? startWorkOrder;
  final bool? startWorkOrderCamera;
  const StartStopToggle({
    super.key,
    required this.initialStatus,
    required this.onToggle,
    required this.setDashboardLoading,
    this.startWorkOrder,
    this.startWorkOrderCamera,
  });

  @override
  _StartStopToggleState createState() => _StartStopToggleState();
}

class _StartStopToggleState extends State<StartStopToggle> {
  late bool isWorkStarted;
  bool isLoading = false;
  String? _faceBase64;
  String faceDetection = "true";
  String companyLocation = "true";
  bool isStartWorkOrder = false;
  // static  renewalPermission =  Common.getSharedPref("renewalPermission");
  @override
  void initState() {
    super.initState();
    isWorkStarted = widget.initialStatus;
    isStartWorkOrder =
        widget.startWorkOrderCamera ?? widget.startWorkOrder ?? false;
    _loadSharedPrefs();
  }

  @override
  void didUpdateWidget(covariant StartStopToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentCameraSetting =
        widget.startWorkOrderCamera ?? widget.startWorkOrder;
    if (currentCameraSetting != null &&
        currentCameraSetting != isStartWorkOrder) {
      setState(() {
        isStartWorkOrder = currentCameraSetting;
      });
    }
  }

  Future<void> _loadSharedPrefs() async {
    final facepermission = await Common.getSharedPref("faceDetection");
    final companylocation = await Common.getSharedPref("companyLocation");
    final startWorkOrderCameraPref =
        await Common.getSharedPref("start_work_order_camera");
    final startWorkOrderPref = await Common.getSharedPref("start_work_order");
    setState(() {
      faceDetection = facepermission ?? "false";
      companyLocation = companylocation ?? "false";
      if (widget.startWorkOrderCamera != null) {
        isStartWorkOrder = widget.startWorkOrderCamera!;
      } else if (widget.startWorkOrder != null) {
        isStartWorkOrder = widget.startWorkOrder!;
      } else {
        isStartWorkOrder =
            (startWorkOrderCameraPref ?? startWorkOrderPref) == "true";
      }
    });
  }

  // Future<String?> generateFaceHash(File faceImageFile) async {
  //   final faceDetector = FaceDetector(
  //     options: FaceDetectorOptions(
  //       enableLandmarks: true,
  //       enableContours: true,
  //       enableClassification: false,
  //     ),
  //   );

  //   final inputImage = InputImage.fromFile(faceImageFile);
  //   final faces = await faceDetector.processImage(inputImage);

  //   if (faces.isEmpty) return null;

  //   final face = faces.first;
  //   final landmarks = face.landmarks;

  //   // Serialize key landmarks
  //   final serialized = [
  //     landmarks[FaceLandmarkType.leftEye]?.position,
  //     landmarks[FaceLandmarkType.rightEye]?.position,
  //     landmarks[FaceLandmarkType.noseBase]?.position,
  //     landmarks[FaceLandmarkType.leftCheek]?.position,
  //     landmarks[FaceLandmarkType.rightCheek]?.position,
  //   ].map((p) => p != null ? '${p.x.round()},${p.y.round()}' : '0,0').join(';');

  //   final lipPoints = face.contours[FaceContourType.upperLipTop]?.points ?? [];
  //   final lipData =
  //       lipPoints.take(3).map((p) => '${p.x.round()},${p.y.round()}').join(';');

  //   faceDetector.close();

  //   final combined = '$serialized;$lipData';
  //   return base64Encode(utf8.encode(combined));
  // }

  // Future<void> captureFace() async {
  //   final faceImage = await Navigator.of(context).push<File>(
  //     MaterialPageRoute(
  //       builder: (context) => FaceDetectionCamera(
  //         onFaceCaptured: (File imageFile) {
  //           Navigator.of(context).pop(imageFile);
  //         },
  //       ),
  //     ),
  //   );

  //   if (faceImage != null && mounted) {
  //     final faceHash = await generateFaceHash(faceImage);
  //     if (faceHash == null) {
  //       Common.toastMessaage('Face hash failed', Colors.red);
  //       return;
  //     }
  //     _faceBase64 = faceHash;
  //     setState(() {});
  //   }
  // }

  void toggleSwitch({bool skipConfirmation = false}) async {
    final now = DateTime.now();
    if (!skipConfirmation) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isWorkStarted ? "Logout" : "Login"),
            content: Text(
              "Are you sure you want to ${isWorkStarted ? "Logout" : "Login"}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );
      if (confirmed != true) return;
    }

    if (!isWorkStarted) {
      XFile? capturedImage;
      if (isStartWorkOrder) {
        try {
          final ImagePicker picker = ImagePicker();
          capturedImage = await picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
          );
          if (capturedImage == null) {
            showError("Image capture is required to start work.");
            return;
          }
        } catch (e) {
          showError("Camera error: $e");
          return;
        }
      }

      setState(() => isLoading = true);
      widget.setDashboardLoading(true);

      late BuildContext loaderContext;
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (ctx) {
          loaderContext = ctx;
          Future.delayed(const Duration(seconds: 12), () {
            if (Navigator.of(loaderContext).canPop()) {
              Navigator.of(loaderContext).pop();
              showError("Location fetch timed out.");
              setState(() => isLoading = false);
              widget.setDashboardLoading(false);
            }
          });

          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.0),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie/location_loader.json',
                    width: 180,
                    height: 180,
                    repeat: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Logging In...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          final bool allowed = await Common.showLocationDisclosure(context);
          if (!allowed) {
            if (Navigator.of(loaderContext).canPop())
              Navigator.of(loaderContext).pop();
            showError("Location permission denied by user.");
            setState(() => isLoading = false);
            widget.setDashboardLoading(false);
            return;
          }
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (Navigator.of(loaderContext).canPop())
              Navigator.of(loaderContext).pop();
            showError("Location permission denied.");
            setState(() => isLoading = false);
            widget.setDashboardLoading(false);
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          if (Navigator.of(loaderContext).canPop())
            Navigator.of(loaderContext).pop();
          showError("Location permission permanently denied.");
          setState(() => isLoading = false);
          widget.setDashboardLoading(false);
          return;
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (Navigator.of(loaderContext).canPop())
          Navigator.of(loaderContext).pop();

        if (companyLocation == "true") {
          final companyResponse = await HttpService.getCompanyLocations();
          if (companyResponse == null || companyResponse.status != true) {
            showError("Failed to fetch company locations.");
            setState(() => isLoading = false);
            widget.setDashboardLoading(false);
            return;
          }

          final String rawLocations = companyResponse.data.location;
          final List<String> locationStrings = rawLocations
              .replaceAll('{', '')
              .split('},')
              .map((e) => e.replaceAll('}', '').trim())
              .where((e) => e.isNotEmpty)
              .toList();

          bool isWithinRange = false;
          const double maxDistanceMeters = 100;
          for (final locStr in locationStrings) {
            final parts = locStr.split(',');
            if (parts.length == 2) {
              final double? companyLat = double.tryParse(parts[0].trim());
              final double? companyLng = double.tryParse(parts[1].trim());
              if (companyLat != null && companyLng != null) {
                final double distance = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  companyLat,
                  companyLng,
                );
                if (distance <= maxDistanceMeters) {
                  isWithinRange = true;
                  break;
                }
              }
            }
          }

          if (locationStrings.isEmpty ||
              locationStrings.any((loc) => loc.trim().isEmpty)) {
            setState(() => isLoading = false);
            widget.setDashboardLoading(false);
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("No Location Found"),
                  content: const Text(
                      "Please add company location before you start to login"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CompanyLocationPage()),
                        );
                      },
                      child: const Text("Add Location"),
                    ),
                  ],
                );
              },
            );
            return;
          }

          if (!isWithinRange) {
            setState(() => isLoading = false);
            widget.setDashboardLoading(false);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Location Error"),
                  content: Text(
                    "You are not within $maxDistanceMeters meters of any company location.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        toggleSwitch(skipConfirmation: true);
                      },
                      child: const Text("Retry"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
            return;
          }
        }

        // if (faceDetection == "true") {
        //   await captureFace();
        //   if (_faceBase64 == null || _faceBase64!.isEmpty) {
        //     Common.toastMessaage('Face capture required for login', Colors.red);
        //     setState(() => isLoading = false);
        //     widget.setDashboardLoading(false);
        //     return;
        //   }
        // }

        final response = await HttpService.startWork(
          now,
          latitude: position.latitude,
          longitude: position.longitude,
          faceData: _faceBase64,
          image: capturedImage != null ? File(capturedImage.path) : null,
        );
        if (response != null && response.status == true) {
          await Common.saveSharedPref("is_work_started", "true");
          widget.onToggle(true);
          setState(() => isWorkStarted = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Log in at ${DateFormat('hh:mm a').format(now)}"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          showError(response?.message ?? "Failed to start work");
        }
      } catch (e) {
        if (Navigator.of(loaderContext).canPop())
          Navigator.of(loaderContext).pop();
        showError("Error: $e");
      } finally {
        setState(() => isLoading = false);
        widget.setDashboardLoading(false);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InfoCardExample(),
          settings: RouteSettings(
            arguments: {
              "logoutTime": DateTime.now().toIso8601String(),
            },
          ),
        ),
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final result = await HttpService.getWorkStatus();
          if (result != null && result.data.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout Blocked'),
                content: const Text(
                    'Work is in progress. Please close all work before logging out.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
               toggleSwitch(skipConfirmation: true);
          }
        } catch (e) {
          print('Error checking work status: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to check work status')),
          );
        }
      },
      //   onTap: isLoading ? null : toggleSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40,
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isWorkStarted
              ? Colors.green
              : const Color.fromARGB(255, 255, 253, 253),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment:
              isWorkStarted ? Alignment.centerRight : Alignment.centerLeft,
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isWorkStarted
                        ? Colors.white
                        : const Color.fromARGB(255, 81, 146, 238),
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
