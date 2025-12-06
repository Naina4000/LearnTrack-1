// lib/screens/teacher_portal.dart

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

import '../models/class_session.dart';
import '../services/firebase_service.dart';

class TeacherPortal extends StatefulWidget {
  const TeacherPortal({super.key});

  @override
  State<TeacherPortal> createState() => _TeacherPortalState();
}

class _TeacherPortalState extends State<TeacherPortal> {
  final FirebaseService _firebaseService = FirebaseService();
  final NetworkInfo _networkInfo = NetworkInfo();

  static const platform = MethodChannel("learntrack/hotspot");

  String wifiStatus = "Checking...";
  bool hotspotReady = false;
  String ssid = "Unknown";
  bool checking = false;

  // 🔥 ACTIVE CLASS STATE
  bool hasActiveClass = false;
  String? activeSessionId;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _checkActiveClass();
  }

  Future<void> _checkPermissions() async {
    await Permission.location.request();
    await Permission.nearbyWifiDevices.request();
    await _checkConnectivityStatus();
  }

  Future<bool> _isHotspotEnabled() async {
    try {
      final result = await platform.invokeMethod("isHotspotEnabled");
      return result == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _checkActiveClass() async {
    final active = await _firebaseService.getActiveSession();

    if (active != null) {
      setState(() {
        hasActiveClass = true;
        activeSessionId = active.id;
      });
    } else {
      setState(() {
        hasActiveClass = false;
        activeSessionId = null;
      });
    }
  }

  Future<void> _checkConnectivityStatus() async {
    setState(() {
      checking = true;
      wifiStatus = "Checking...";
      hotspotReady = false;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    String? wifiName;

    try {
      wifiName = await _networkInfo.getWifiName();
    } catch (_) {
      wifiName = null;
    }

    bool hotspotEnabled = await _isHotspotEnabled();

    setState(() {
      ssid = (wifiName == null || wifiName.isEmpty) ? "HOTSPOT" : wifiName;

      if (hotspotEnabled) {
        wifiStatus = "Hotspot Active";
        hotspotReady = true;
      } else if (connectivityResult == ConnectivityResult.wifi && wifiName != null) {
        wifiStatus = "Connected to Wi-Fi: $ssid (Turn ON Hotspot)";
        hotspotReady = false;
      } else {
        wifiStatus = "Hotspot OFF";
        hotspotReady = false;
      }

      checking = false;
    });
  }

  Future<void> _openHotspotSettings() async {
    const intent = AndroidIntent(action: 'android.settings.TETHER_SETTINGS');
    await intent.launch();
  }

  Future<void> _startClass() async {
    if (!hotspotReady) return;

    await _checkActiveClass();

    if (hasActiveClass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A class is already running! End it first.")),
      );
      return;
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(now);
    final formattedTime = DateFormat('hh:mm a').format(now);

    final session = ClassSession(
      teacherName: "Prof. Sharma",
      subject: "Network Fundamentals",
      date: formattedDate,
      startTime: formattedTime,
      ssid: ssid,
      endTime: null,
    );

    try {
      await _firebaseService.createClassSession(session);

      setState(() {
        hasActiveClass = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class session started!')),
      );

      _checkActiveClass();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start session: $e')),
      );
    }
  }

  Future<void> _endClass() async {
    if (activeSessionId == null) return;

    final now = DateTime.now();
    final endTime = DateFormat('hh:mm a').format(now);

    await _firebaseService.endClass(activeSessionId!, endTime);

    setState(() {
      hasActiveClass = false;
      activeSessionId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Class ended successfully!")),
    );
  }

  // ---------------- UI COMPONENTS ----------------

  Widget _enhancedStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Connection Status",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D3D3D),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                hotspotReady ? Icons.check_circle : Icons.info_outline,
                color: hotspotReady ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  wifiStatus,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.wifi, size: 20, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                "SSID: $ssid",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool large = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: large ? 55 : 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: onPressed != null ? 4 : 0,
          backgroundColor: onPressed != null ? Colors.white : Colors.white54,
          foregroundColor: Colors.indigoAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: large ? 24 : 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: large ? 17 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BUILD UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "LearnTrack - Teacher Portal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF536DFE),
              Color(0xFF8C9EFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Hotspot & Class Control",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Manage your hotspot and class sessions",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),
                checking
                    ? const LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      )
                    : const SizedBox(),

                const SizedBox(height: 16),
                _enhancedStatusCard(),

                const SizedBox(height: 22),

                _primaryButton(
                  label: "Refresh Connection Status",
                  icon: Icons.refresh,
                  onPressed: _checkConnectivityStatus,
                ),

                const SizedBox(height: 14),

                _primaryButton(
                  label: "Open Hotspot Settings",
                  icon: Icons.settings,
                  onPressed: _openHotspotSettings,
                ),

                const Spacer(),

                if (!hasActiveClass)
                  _primaryButton(
                    label: "Start Class",
                    icon: Icons.play_circle_fill,
                    onPressed: hotspotReady ? _startClass : null,
                    large: true,
                  ),

                if (hasActiveClass)
                  _primaryButton(
                    label: "End Class",
                    icon: Icons.stop_circle,
                    onPressed: _endClass,
                    large: true,
                  ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
