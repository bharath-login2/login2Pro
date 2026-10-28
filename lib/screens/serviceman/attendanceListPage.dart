import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/serviceman/attendanceListModel.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'attendanceMapPage.dart';

/// Helper to handle Google Drive image URLs and extract direct viewable URLs
class DriveImageHelper {
  static String? extractFileId(String? url, {String? imageId}) {
    if (imageId != null &&
        imageId.trim().isNotEmpty &&
        imageId.trim() != "null") {
      return imageId.trim();
    }
    if (url == null || url.trim().isEmpty || url.trim() == "null") {
      return null;
    }
    final cleanUrl = url.trim();

    // Check if url itself is a raw ID (no / or :, length >= 15)
    if (!cleanUrl.contains('/') &&
        !cleanUrl.contains(':') &&
        cleanUrl.length >= 15) {
      return cleanUrl;
    }

    // Match /file/d/<id>
    final fileDMatch =
        RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(cleanUrl);
    if (fileDMatch != null && fileDMatch.groupCount >= 1) {
      return fileDMatch.group(1);
    }

    // Match [?&]id=<id>
    final idParamMatch =
        RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(cleanUrl);
    if (idParamMatch != null && idParamMatch.groupCount >= 1) {
      return idParamMatch.group(1);
    }

    // Match /d/<id>
    final dMatch = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(cleanUrl);
    if (dMatch != null && dMatch.groupCount >= 1) {
      return dMatch.group(1);
    }

    return null;
  }

  /// Primary direct CDN image link from Google Drive
  static String getDisplayableImageUrl(String? url, {String? imageId}) {
    final fileId = extractFileId(url, imageId: imageId);
    if (fileId != null && fileId.isNotEmpty) {
      return "https://lh3.googleusercontent.com/d/$fileId";
    }
    return url?.trim() ?? "";
  }

  /// Secondary thumbnail link fallback
  static String getFallbackThumbnailUrl(String? url, {String? imageId}) {
    final fileId = extractFileId(url, imageId: imageId);
    if (fileId != null && fileId.isNotEmpty) {
      return "https://drive.google.com/thumbnail?id=$fileId&sz=w1000";
    }
    return url?.trim() ?? "";
  }
}

/// Helper for coordinate validation, reverse geocoding, and map URLs
class LocationHelper {
  static final Map<String, String> _cache = {};

  /// Parses latitude and longitude strings and returns (lat, lng) or (null, null)
  static (double?, double?) parseCoordinates(String? latStr, String? lngStr) {
    if (latStr == null || lngStr == null) return (null, null);
    final cleanLat = latStr.trim();
    final cleanLng = lngStr.trim();
    if (cleanLat.isEmpty ||
        cleanLng.isEmpty ||
        cleanLat == "null" ||
        cleanLng == "null") {
      return (null, null);
    }
    final lat = double.tryParse(cleanLat);
    final lng = double.tryParse(cleanLng);
    if (lat == null || lng == null) return (null, null);
    if (lat == 0.0 && lng == 0.0) return (null, null);
    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) {
      return (null, null);
    }
    return (lat, lng);
  }

  /// Constructs Google Maps / Street Map query URL from coordinates
  static String getMapUrl(double lat, double lng) {
    return "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
  }

  /// Reverse geocodes coordinates to a human-readable street address
  static Future<String> getAddress(double lat, double lng) async {
    final key = "${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}";
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 5),
        onTimeout: () => <geo.Placemark>[],
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];

        final streetParts = [
          if (p.subThoroughfare != null && p.subThoroughfare!.trim().isNotEmpty)
            p.subThoroughfare!.trim(),
          if (p.thoroughfare != null && p.thoroughfare!.trim().isNotEmpty)
            p.thoroughfare!.trim(),
          if (p.street != null && p.street!.trim().isNotEmpty)
            p.street!.trim(),
        ];
        final streetUnique = streetParts.toSet().join(" ").trim();
        if (streetUnique.isNotEmpty) {
          parts.add(streetUnique);
        } else if (p.name != null && p.name!.trim().isNotEmpty) {
          parts.add(p.name!.trim());
        }

        if (p.subLocality != null &&
            p.subLocality!.trim().isNotEmpty &&
            !parts.contains(p.subLocality!.trim())) {
          parts.add(p.subLocality!.trim());
        }
        if (p.locality != null &&
            p.locality!.trim().isNotEmpty &&
            !parts.contains(p.locality!.trim())) {
          parts.add(p.locality!.trim());
        }
        if (p.administrativeArea != null &&
            p.administrativeArea!.trim().isNotEmpty &&
            !parts.contains(p.administrativeArea!.trim())) {
          parts.add(p.administrativeArea!.trim());
        }
        if (p.postalCode != null &&
            p.postalCode!.trim().isNotEmpty &&
            !parts.contains(p.postalCode!.trim())) {
          parts.add(p.postalCode!.trim());
        }

        if (parts.isNotEmpty) {
          final address = parts.join(", ");
          _cache[key] = address;
          return address;
        }
      }
    } catch (e) {
      debugPrint("Reverse geocoding exception for $lat, $lng: $e");
    }

    final fallback =
        "Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}";
    _cache[key] = fallback;
    return fallback;
  }
}

class AttendanceListPage extends StatefulWidget {
  final String? staffId;
  final String? staffName;

  const AttendanceListPage({
    super.key,
    this.staffId,
    this.staffName,
  });

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  final HttpService _httpService = HttpService();

  late String _fromDate;
  late String _toDate;
  String _staffId = "";
  String _staffName = "";

  bool _isLoading = true;
  String? _errorMessage;
  List<AttendanceRecord> _records = [];
  final Map<String, String> _addressCache = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to start of current month up to today
    final startOfMonth = DateTime(now.year, now.month, 1);
    _fromDate = DateFormat('yyyy-MM-dd').format(startOfMonth);
    _toDate = DateFormat('yyyy-MM-dd').format(now);

    _initAndLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initAndLoad() async {
    final prefStaffId = await Common.getSharedPref("staff_id");
    final prefUserId = await Common.getSharedPref("userId");
    final prefName = await Common.getSharedPref("name");
    final prefStaffName = await Common.getSharedPref("staff_name");

    _staffId = widget.staffId ??
        (prefStaffId != null && prefStaffId.isNotEmpty
            ? prefStaffId
            : (prefUserId ?? "1"));

    _staffName = widget.staffName ??
        (prefName != null && prefName.isNotEmpty
            ? prefName
            : (prefStaffName ?? "Serviceman"));

    _fetchAttendanceList();
  }

  Future<void> _fetchAttendanceList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _httpService.getAttendanceList(
        fromDate: _fromDate,
        toDate: _toDate,
        staffId: _staffId,
      );

      if (response != null && response.status == true) {
        final records = response.data ?? [];
        setState(() {
          _records = records;
          _isLoading = false;
        });
        _loadAddressesForRecords(records);
      } else {
        setState(() {
          _errorMessage =
              response?.message ?? "Unable to fetch attendance records.";
          _records = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _records = [];
        _isLoading = false;
      });
    }
  }

  void _loadAddressesForRecords(List<AttendanceRecord> records) {
    for (var record in records) {
      final coords = LocationHelper.parseCoordinates(
        record.loginLatitude,
        record.loginLongitude,
      );
      if (coords.$1 != null && coords.$2 != null) {
        final key = record.id ?? "${coords.$1},${coords.$2}";
        LocationHelper.getAddress(coords.$1!, coords.$2!).then((address) {
          if (mounted) {
            setState(() {
              _addressCache[key] = address;
            });
          }
        });
      }
    }
  }

  String _getAddressText(AttendanceRecord record) {
    final coords = LocationHelper.parseCoordinates(
      record.loginLatitude,
      record.loginLongitude,
    );
    if (coords.$1 == null || coords.$2 == null) {
      return "Location not available";
    }
    final key = record.id ?? "${coords.$1},${coords.$2}";
    return _addressCache[key] ?? "Fetching address...";
  }

  List<AttendanceRecord> get _filteredRecords {
    if (_searchQuery.trim().isEmpty) return _records;
    final query = _searchQuery.toLowerCase().trim();
    return _records.where((item) {
      final name = (item.staffName ?? "").toLowerCase();
      final login = (item.loginTime ?? "").toLowerCase();
      final logout = (item.logoutTime ?? "").toLowerCase();
      final id = (item.id ?? "").toLowerCase();
      final addr = _getAddressText(item).toLowerCase();
      return name.contains(query) ||
          login.contains(query) ||
          logout.contains(query) ||
          id.contains(query) ||
          addr.contains(query);
    }).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    try {
      DateTime start = DateFormat('yyyy-MM-dd').parse(_fromDate);
      DateTime end = DateFormat('yyyy-MM-dd').parse(_toDate);
      if (start.isAfter(end)) start = end;

      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: start, end: end),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF2A86C9),
                onPrimary: Colors.white,
                onSurface: Color(0xFF1E293B),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _fromDate = DateFormat('yyyy-MM-dd').format(picked.start);
          _toDate = DateFormat('yyyy-MM-dd').format(picked.end);
        });
        _fetchAttendanceList();
      }
    } catch (e) {
      debugPrint("Error picking date range: $e");
    }
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw.trim() == "null") {
      return "Not available";
    }
    final trimmed = raw.trim();
    try {
      if (trimmed.contains("T")) {
        final dt = DateTime.tryParse(trimmed);
        if (dt != null) {
          return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
        }
      } else if (trimmed.contains("-") && trimmed.contains(":")) {
        final parts = trimmed.split(" ");
        if (parts.length >= 2) {
          final dt = DateTime.tryParse("${parts[0]}T${parts[1]}");
          if (dt != null) {
            return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
          }
        }
      }
    } catch (_) {}
    return trimmed;
  }

  void _openCoordinatesInMap(double lat, double lng, {String? url}) async {
    final mapUrl = url ?? LocationHelper.getMapUrl(lat, lng);
    try {
      final uri = Uri.parse(mapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open Google Maps: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToMapPage({
    required double latitude,
    required double longitude,
    required String staffName,
    String? loginTime,
    required String address,
    String? locationUrl,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceMapPage(
          latitude: latitude,
          longitude: longitude,
          staffName: staffName,
          loginTime: loginTime,
          address: address,
          locationUrl: locationUrl,
        ),
      ),
    );
  }

  void _showAttendanceDetails(AttendanceRecord record) {
    final coords = LocationHelper.parseCoordinates(
      record.loginLatitude,
      record.loginLongitude,
    );
    final hasValidCoords = coords.$1 != null && coords.$2 != null;
    final staffName = record.staffName?.isNotEmpty == true
        ? record.staffName!
        : _staffName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final address = _getAddressText(record);

            // If coordinates are valid and address hasn't finished loading yet, resolve and update dialog
            if (hasValidCoords &&
                (address == "Fetching address..." ||
                    address == "Location not available")) {
              LocationHelper.getAddress(coords.$1!, coords.$2!).then((addr) {
                if (modalCtx.mounted) {
                  setModalState(() {
                    _addressCache[record.id ?? "${coords.$1},${coords.$2}"] =
                        addr;
                  });
                }
              });
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).padding.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF2A86C9).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.assignment_ind_rounded,
                                  color: Color(0xFF2A86C9),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Attendance Details",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    staffName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Login Image Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Login Photo",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: _buildDetailsImageWidget(
                              record.loginImage,
                              record.loginImageId,
                              staffName,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF2A86C9),
                            title: "Staff Name",
                            value: staffName,
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.badge_outlined,
                            iconColor: const Color(0xFF64748B),
                            title: "Record / User ID",
                            value:
                                "ID: ${record.id ?? 'N/A'} (User: ${record.userId ?? 'N/A'})",
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.login_rounded,
                            iconColor: const Color(0xFF10B981),
                            title: "Login Time",
                            value: _formatDateTime(record.loginTime),
                            badgeColor: const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.logout_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: "Logout Time",
                            value: record.logoutTime != null &&
                                    record.logoutTime!.trim().isNotEmpty &&
                                    record.logoutTime != "null"
                                ? _formatDateTime(record.logoutTime)
                                : "Not logged out yet",
                            badgeColor: record.logoutTime != null &&
                                    record.logoutTime!.trim().isNotEmpty &&
                                    record.logoutTime != "null"
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 10),

                          // Location Row (Clickable to open map with marker when valid coordinates exist)
                          _buildClickableLocationDetailRow(
                            title: "Location",
                            address: address,
                            hasValidCoords: hasValidCoords,
                            lat: coords.$1,
                            lng: coords.$2,
                            onTap: hasValidCoords
                                ? () {
                                    Navigator.pop(ctx);
                                    _navigateToMapPage(
                                      latitude: coords.$1!,
                                      longitude: coords.$2!,
                                      staffName: staffName,
                                      loginTime:
                                          _formatDateTime(record.loginTime),
                                      address: address,
                                      locationUrl: record.locationUrl,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Map action buttons or disabled message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: hasValidCoords
                          ? Column(
                              children: [
                                // View Location on Map (with pin marker)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2A86C9),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    icon: const Icon(Icons.pin_drop_rounded,
                                        size: 20),
                                    label: const Text(
                                      "View Location on Map",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _navigateToMapPage(
                                        latitude: coords.$1!,
                                        longitude: coords.$2!,
                                        staffName: staffName,
                                        loginTime: _formatDateTime(
                                            record.loginTime),
                                        address: address,
                                        locationUrl: record.locationUrl,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Open in Google Maps for Navigation
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xFF2A86C9),
                                      side: const BorderSide(
                                        color: Color(0xFF2A86C9),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                        Icons.navigation_rounded,
                                        size: 18),
                                    label: const Text(
                                      "Open in Google Maps for Navigation",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      final mapUrl = (record.locationUrl !=
                                                  null &&
                                              record.locationUrl!
                                                  .trim()
                                                  .startsWith("http"))
                                          ? record.locationUrl!.trim()
                                          : LocationHelper.getMapUrl(
                                              coords.$1!, coords.$2!);
                                      _openCoordinatesInMap(
                                        coords.$1!,
                                        coords.$2!,
                                        url: mapUrl,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.location_off_rounded,
                                      color: Colors.grey, size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Latitude or longitude is missing for this record. Map marker option is disabled to avoid showing an incorrect location.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableLocationDetailRow({
    required String title,
    required String address,
    required bool hasValidCoords,
    double? lat,
    double? lng,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValidCoords
              ? const Color(0xFF2A86C9).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasValidCoords
                        ? const Color(0xFF2A86C9).withOpacity(0.12)
                        : Colors.grey.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasValidCoords
                        ? Icons.location_on_rounded
                        : Icons.location_off_rounded,
                    color: hasValidCoords
                        ? const Color(0xFF2A86C9)
                        : const Color(0xFF94A3B8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          if (hasValidCoords)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF2A86C9).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.pin_drop_rounded,
                                    size: 11,
                                    color: Color(0xFF2A86C9),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "View Location on Map",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2A86C9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasValidCoords ? address : "Location not available",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasValidCoords
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      if (hasValidCoords && lat != null && lng != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Coordinates: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsImageWidget(
    String? imageUrl,
    String? imageId,
    String staffName,
  ) {
    final primaryUrl =
        DriveImageHelper.getDisplayableImageUrl(imageUrl, imageId: imageId);
    final fallbackUrl =
        DriveImageHelper.getFallbackThumbnailUrl(imageUrl, imageId: imageId);

    if (primaryUrl.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.no_photography_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "No login image available",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.black12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              primaryUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFF2A86C9),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Try secondary fallback URL if primary fails
                if (fallbackUrl.isNotEmpty && fallbackUrl != primaryUrl) {
                  return Image.network(
                    fallbackUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder(staffName);
                    },
                  );
                }
                return _buildImagePlaceholder(staffName);
              },
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: () => _openFullScreenImage(primaryUrl, fallbackUrl),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.fullscreen, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Zoom",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String staffName) {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFE2E8F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF2A86C9).withOpacity(0.2),
            child: Text(
              staffName.isNotEmpty ? staffName[0].toUpperCase() : "S",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A86C9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Image not loadable",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _openFullScreenImage(String primaryUrl, String fallbackUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text("Photo View"),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                primaryUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  if (fallbackUrl.isNotEmpty) {
                    return Image.network(
                      fallbackUrl,
                      fit: BoxFit.contain,
                    );
                  }
                  return const Icon(Icons.broken_image,
                      size: 60, color: Colors.white54);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListThumbnail(String? imageUrl, String? imageId, String name) {
    final primaryUrl =
        DriveImageHelper.getDisplayableImageUrl(imageUrl, imageId: imageId);
    final fallbackUrl =
        DriveImageHelper.getFallbackThumbnailUrl(imageUrl, imageId: imageId);

    if (primaryUrl.isEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF2A86C9).withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "S",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A86C9),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        height: 52,
        color: Colors.grey.shade200,
        child: Image.network(
          primaryUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2A86C9),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            if (fallbackUrl.isNotEmpty && fallbackUrl != primaryUrl) {
              return Image.network(
                fallbackUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF2A86C9).withOpacity(0.12),
                    alignment: Alignment.center,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "S",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A86C9),
                      ),
                    ),
                  );
                },
              );
            }
            return Container(
              color: const Color(0xFF2A86C9).withOpacity(0.12),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "S",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A86C9),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2A86C9),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Attendance List",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              "$_fromDate to $_toDate",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            tooltip: "Select Date Range",
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh",
            onPressed: _fetchAttendanceList,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search bar card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Date range picker chip bar
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDateRange(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Color(0xFF2A86C9),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$_fromDate  ➜  $_toDate",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A86C9).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${filtered.length} logs",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A86C9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Search field
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search staff name, location, or time...",
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = "");
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main list or states
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF2A86C9),
              onRefresh: _fetchAttendanceList,
              child: _buildBody(filtered),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<AttendanceRecord> list) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2A86C9)),
            SizedBox(height: 16),
            Text(
              "Loading attendance records...",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded,
                    size: 48, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A86C9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Try Again"),
                onPressed: _fetchAttendanceList,
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A86C9).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_rounded,
                  size: 56,
                  color: Color(0xFF2A86C9),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "No Attendance Records Found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "No attendance entries between $_fromDate and $_toDate.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2A86C9),
                  side: const BorderSide(color: Color(0xFF2A86C9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text("Change Date Range"),
                onPressed: () => _selectDateRange(context),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final record = list[index];
        return _buildAttendanceCard(record);
      },
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    final staffName = record.staffName?.isNotEmpty == true
        ? record.staffName!
        : _staffName;

    final coords = LocationHelper.parseCoordinates(
      record.loginLatitude,
      record.loginLongitude,
    );
    final hasValidCoords = coords.$1 != null && coords.$2 != null;
    final addressText = _getAddressText(record);

    final isLoggedOut = record.logoutTime != null &&
        record.logoutTime!.trim().isNotEmpty &&
        record.logoutTime != "null";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAttendanceDetails(record),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Staff Image, Name, and Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildListThumbnail(
                      record.loginImage,
                      record.loginImageId,
                      staffName,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staffName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Record #${record.id ?? '—'}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLoggedOut
                            ? const Color(0xFF10B981).withOpacity(0.12)
                            : const Color(0xFF3B82F6).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLoggedOut
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isLoggedOut ? "Completed" : "Logged In",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isLoggedOut
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Timing Rows
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeTile(
                        icon: Icons.login_rounded,
                        iconColor: const Color(0xFF10B981),
                        label: "Login Time",
                        timeText: _formatDateTime(record.loginTime),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimeTile(
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: "Logout Time",
                        timeText: isLoggedOut
                            ? _formatDateTime(record.logoutTime)
                            : "—",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Location row with View Location on Map option
                if (hasValidCoords)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _navigateToMapPage(
                        latitude: coords.$1!,
                        longitude: coords.$2!,
                        staffName: staffName,
                        loginTime: _formatDateTime(record.loginTime),
                        address: addressText,
                        locationUrl: record.locationUrl,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A86C9).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2A86C9).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 15,
                                  color: Color(0xFF2A86C9),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Location: $addressText",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A86C9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.pin_drop_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "View Location on Map",
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.location_off_outlined,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Location: Coordinates missing — Map marker disabled",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Action Row: View Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A86C9),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 15),
                    label: const Text(
                      "View",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _showAttendanceDetails(record),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String timeText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
