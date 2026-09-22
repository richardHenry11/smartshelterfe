import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'config.dart';
import 'login_page.dart';

class SensorsPage extends StatefulWidget {
  final String username;

  const SensorsPage({super.key, required this.username});

  @override
  State<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const DashboardTab(),
      const LocationTab(),
      ProfileTab(username: widget.username),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      ),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  Widget _buildModernBottomNavBar() {
    final navItems = [
      (icon: Icons.dashboard_rounded, label: 'Dashboard'),
      (icon: Icons.location_on_rounded, label: 'Location'),
      (icon: Icons.person_rounded, label: 'Profile'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
              blurRadius: 15,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF152A55).withValues(alpha: 0.88),
                    const Color(0xFF0D1B36).withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 18 : 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF00E5FF)
                                      .withValues(alpha: 0.22),
                                  const Color(0xFF2A5298)
                                      .withValues(alpha: 0.30),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.45),
                                width: 1.2,
                              )
                            : Border.all(color: Colors.transparent, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? const Color(0xFF00E5FF)
                                : Colors.white.withValues(alpha: 0.55),
                            size: 22,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final List<IconData> kAvailableIcons = [
  Icons.thermostat_rounded,
  Icons.water_drop_rounded,
  Icons.air_rounded,
  Icons.light_mode_rounded,
  Icons.speed_rounded,
  Icons.bolt_rounded,
  Icons.battery_charging_full_rounded,
  Icons.sensors_rounded,
  Icons.local_fire_department_rounded,
  Icons.cloud_rounded,
  Icons.co2_rounded,
  Icons.grass_rounded,
];

final List<Color> kAvailableColors = [
  Colors.orangeAccent,
  Colors.lightBlueAccent,
  Colors.greenAccent,
  Colors.yellowAccent,
  Colors.purpleAccent,
  Colors.pinkAccent,
  Colors.tealAccent,
  Colors.redAccent,
];

class SensorMeta {
  final String key;
  final String title;
  final String unit;
  final int iconIndex;
  final int colorValue;
  final bool isDefault;

  const SensorMeta({
    required this.key,
    required this.title,
    required this.unit,
    required this.iconIndex,
    required this.colorValue,
    this.isDefault = false,
  });

  IconData get icon {
    if (iconIndex >= 0 && iconIndex < kAvailableIcons.length) {
      return kAvailableIcons[iconIndex];
    }
    return Icons.sensors_rounded;
  }

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'unit': unit,
    'iconIndex': iconIndex,
    'colorValue': colorValue,
    'isDefault': isDefault,
  };

  factory SensorMeta.fromJson(Map<String, dynamic> json) {
    return SensorMeta(
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      unit: json['unit'] ?? '',
      iconIndex: json['iconIndex'] ?? 0,
      colorValue: json['colorValue'] ?? 0xFFFFAB40,
      isDefault: json['isDefault'] ?? false,
    );
  }
}

final SensorMeta kSensorNH4 = SensorMeta(
  key: 'nh4',
  title: 'NH4',
  unit: 'ppm',
  iconIndex: 7,
  colorValue: 0xFF00E5FF,
  isDefault: true,
);

final SensorMeta kSensorO2 = SensorMeta(
  key: 'o2',
  title: 'O2',
  unit: '%',
  iconIndex: 2,
  colorValue: 0xFF00E676,
  isDefault: true,
);

final List<SensorMeta> defaultSensors = [
  kSensorNH4,
  kSensorO2,
  SensorMeta(
    key: 'temperature',
    title: 'Temperature',
    unit: '°C',
    iconIndex: 0,
    colorValue: 0xFFFFAB40,
    isDefault: true,
  ),
  SensorMeta(
    key: 'humidity',
    title: 'Humidity',
    unit: '%',
    iconIndex: 1,
    colorValue: 0xFF40C4FF,
    isDefault: true,
  ),
];

// ---------------- MODEL SHELTER / MULTI-TENANT ----------------
class ShelterData {
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final double geofenceRadius;

  ShelterData({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.geofenceRadius = 100.0,
  });

  factory ShelterData.fromJson(Map<String, dynamic> json) {
    return ShelterData(
      id: json['id']?.toString() ?? 'SHELTER-01',
      name: json['name']?.toString() ?? 'Shelter Site',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      geofenceRadius: json['geofence_radius'] != null
          ? (json['geofence_radius'] as num).toDouble()
          : 100.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'geofence_radius': geofenceRadius,
      };
}

// ---------------- DASHBOARD TAB ----------------
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  WebSocketChannel? channel;
  StreamSubscription? _wsSub;

  // Multi-Tenant / Multi-Shelter state
  String currentShelterId = 'SHELTER-01';
  List<ShelterData> availableShelters = [
    ShelterData(
      id: 'SHELTER-01',
      name: 'Shelter Site Alpha (Pusat)',
      latitude: -6.90240000,
      longitude: 107.61870000,
      geofenceRadius: 100,
    ),
    ShelterData(
      id: 'SHELTER-02',
      name: 'Shelter Site Beta (Cabang)',
      latitude: -6.91474400,
      longitude: 107.60981000,
      geofenceRadius: 150,
    ),
  ];

  // Dynamic Realtime sensor values: {"nh4": "1.2", "o2": "20.9", ...}
  Map<String, String> sensorValues = {};

  bool isPumpOn = false;
  bool isLightOn = false;
  bool isFanOn = false;

  // Dynamic sensors list (loaded from SharedPreferences)
  List<SensorMeta> sensors = [];
  String _selectedSensorKey = 'nh4';

  // Kustomisasi Nama & Deskripsi Aplikasi
  String appTitle = 'Sensor Dashboard';
  String appSubtitle = 'Live metrics from your smart shelter';

  // State untuk Line Chart
  List<FlSpot> historySpots = [];
  List<String> historyTimeLabels = [];
  List<String> historyFullDateLabels = [];
  bool isLoadingHistory = true;

  SensorMeta get selectedSensor {
    return sensors.firstWhere(
      (s) => s.key == _selectedSensorKey,
      orElse: () => sensors.isNotEmpty ? sensors[0] : kSensorNH4,
    );
  }

  SensorMeta get nh4Sensor =>
      sensors.firstWhere((s) => s.key == 'nh4', orElse: () => kSensorNH4);
  SensorMeta get o2Sensor =>
      sensors.firstWhere((s) => s.key == 'o2', orElse: () => kSensorO2);
  List<SensorMeta> get otherSensors =>
      sensors.where((s) => s.key != 'nh4' && s.key != 'o2').toList();

  @override
  void initState() {
    super.initState();
    _loadSensors();
    _loadAppCustomization();
    _loadShelters();
  }

  Future<void> _loadShelters() async {
    final prefs = await SharedPreferences.getInstance();
    final savedShelterId = prefs.getString('current_shelter_id');
    final savedSheltersJson = prefs.getString('available_shelters');

    if (savedSheltersJson != null && savedSheltersJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(savedSheltersJson);
        final loaded = decoded.map((e) => ShelterData.fromJson(e)).toList();
        if (loaded.isNotEmpty && mounted) {
          setState(() {
            availableShelters = loaded;
          });
        }
      } catch (e) {
        print('Error decoding saved shelters: $e');
      }
    }

    String activeId = currentShelterId;
    if (savedShelterId != null &&
        availableShelters.any((s) => s.id == savedShelterId)) {
      activeId = savedShelterId;
    } else if (availableShelters.isNotEmpty) {
      activeId = availableShelters.first.id;
      await prefs.setString('current_shelter_id', activeId);
    }

    final activeShelter = availableShelters.firstWhere(
      (s) => s.id == activeId,
      orElse: () => ShelterData(id: activeId, name: activeId),
    );

    if (mounted) {
      setState(() {
        currentShelterId = activeId;
        appTitle = activeShelter.name;
      });
    }

    // Sambungkan WebSocket & fetch history sesuai shelter yang telah terpilih
    _connectWebSocket();
    _fetchHistory(selectedSensor.key);

    _fetchSheltersFromApi();
  }

  Future<void> _fetchSheltersFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tenantId = prefs.getString('tenant_id');

      final response = await http
          .get(AppConfig.shelters(tenantId: tenantId))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['shelters'] ?? [];
        if (list.isNotEmpty && mounted) {
          final loaded = list.map((e) => ShelterData.fromJson(e)).toList();
          final activeShelter = loaded.firstWhere(
            (s) => s.id == currentShelterId,
            orElse: () => loaded.first,
          );

          setState(() {
            availableShelters = loaded;
            appTitle = activeShelter.name;
          });
          await prefs.setString('available_shelters', jsonEncode(list));

          // Jika shelter saat ini tidak ada di daftar tenant user, otomatis beralih ke shelter pertama milik tenant
          if (!loaded.any((s) => s.id == currentShelterId)) {
            _changeShelter(loaded.first.id);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _changeShelter(String newShelterId) async {
    if (newShelterId == currentShelterId) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_shelter_id', newShelterId);

    // Putuskan WebSocket lama; akan tersambung ulang ke shelter baru
    _disconnectWebSocket();

    // Cari koordinat shelter baru untuk update geofence otomatis
    final newShelter = availableShelters.firstWhere(
      (s) => s.id == newShelterId,
      orElse: () => ShelterData(id: newShelterId, name: newShelterId),
    );
    if (newShelter.latitude != null && newShelter.longitude != null) {
      await prefs.setDouble('shelter_lat', newShelter.latitude!);
      await prefs.setDouble('shelter_lng', newShelter.longitude!);
      await prefs.setDouble('shelter_radius', newShelter.geofenceRadius);
    }

    if (mounted) {
      setState(() {
        currentShelterId = newShelterId;
        appTitle = newShelter.name;
        sensorValues = {};
      });
      _connectWebSocket();
      _fetchHistory(selectedSensor.key);
    }
  }

  Future<void> _loadAppCustomization() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        appSubtitle =
            prefs.getString('app_subtitle') ??
            'Live metrics from your smart shelter';
      });
    }
  }

  Future<void> _saveAppCustomization(String title, String subtitle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_title', title);
    await prefs.setString('app_subtitle', subtitle);

    // Update nama shelter pada list shelter lokal
    final idx = availableShelters.indexWhere((s) => s.id == currentShelterId);
    if (idx != -1) {
      final old = availableShelters[idx];
      availableShelters[idx] = ShelterData(
        id: old.id,
        name: title,
        latitude: old.latitude,
        longitude: old.longitude,
        geofenceRadius: old.geofenceRadius,
      );
      await prefs.setString(
        'available_shelters',
        jsonEncode(availableShelters.map((s) => s.toJson()).toList()),
      );
    }

    if (mounted) {
      setState(() {
        appTitle = title;
        appSubtitle = subtitle;
      });
    }

    // Kirim HTTP PUT untuk update nama shelter ke database server MariaDB
    try {
      final response = await http
          .put(
            AppConfig.updateShelter(currentShelterId),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': title,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nama shelter berhasil diperbarui di database!',
            ),
            backgroundColor: Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal update database (HTTP ${response.statusCode}). Pastikan backend di server sudah di-build & restart.',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating shelter name to database: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal koneksi ke server: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadSensors() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedJson = prefs.getString('custom_sensors_list');
    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(savedJson);
        final loaded = decoded.map((e) => SensorMeta.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            sensors = loaded.isNotEmpty ? loaded : List.from(defaultSensors);
          });
        }
      } catch (e) {
        print('Error loading saved sensors: $e');
        if (mounted) setState(() => sensors = List.from(defaultSensors));
      }
    } else {
      if (mounted) setState(() => sensors = List.from(defaultSensors));
    }

    // Bersihkan sensor default lama yang sudah tidak digunakan (air_quality, light_level, soil_moisture)
    final legacyDefaultKeys = {'air_quality', 'light_level', 'soil_moisture'};
    sensors.removeWhere(
      (s) => s.isDefault && legacyDefaultKeys.contains(s.key),
    );

    // Pastikan NH4 dan O2 selalu ada dan menjadi sensor fix utama di posisi terdepan
    if (!sensors.any((s) => s.key == 'nh4')) {
      sensors.insert(0, kSensorNH4);
    }
    if (!sensors.any((s) => s.key == 'o2')) {
      sensors.insert(1, kSensorO2);
    }

    // Pastikan Temperature dan Humidity default tetap ada jika belum ada
    if (!sensors.any((s) => s.key == 'temperature')) {
      sensors.add(defaultSensors[2]);
    }
    if (!sensors.any((s) => s.key == 'humidity')) {
      sensors.add(defaultSensors[3]);
    }

    _saveSensors();

    if (sensors.isNotEmpty) {
      _fetchHistory(selectedSensor.key);
    }
  }

  Future<void> _saveSensors() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(sensors.map((e) => e.toJson()).toList());
    await prefs.setString('custom_sensors_list', encoded);
  }

  Future<void> _fetchHistory(String sensorType) async {
    setState(() => isLoadingHistory = true);
    try {
      final response = await http.get(
        AppConfig.sensorHistory(sensorType, currentShelterId, limit: 24),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> history = data['history'] ?? [];

        List<FlSpot> newSpots = [];
        List<String> newLabels = [];
        List<String> newFullLabels = [];

        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];

        for (int i = 0; i < history.length; i++) {
          final item = history[i];
          final val = (item['value'] as num).toDouble();
          newSpots.add(FlSpot(i.toDouble(), val));

          String timeStr = '$i';
          String fullDateStr = '$i';
          if (item['created_at'] != null) {
            final rawDate = item['created_at'].toString().trim();
            try {
              // Server MySQL menyimpan waktu dalam UTC atau WIB.
              DateTime dt;
              if (rawDate.endsWith('Z') || rawDate.contains('+')) {
                dt = DateTime.parse(rawDate).toLocal();
              } else {
                dt = DateTime.parse(rawDate.replaceAll(' ', 'T'));
              }
              final day = dt.day.toString().padLeft(2, '0');
              final monthStr = months[(dt.month - 1).clamp(0, 11)];
              final hour = dt.hour.toString().padLeft(2, '0');
              final minute = dt.minute.toString().padLeft(2, '0');
              timeStr = '$hour:$minute';
              fullDateStr = '$day $monthStr $hour:$minute';
            } catch (e) {
              if (rawDate.contains('T')) {
                timeStr = rawDate.split('T')[1].substring(0, 5);
              } else if (rawDate.contains(' ')) {
                timeStr = rawDate.split(' ')[1].substring(0, 5);
              } else {
                timeStr = rawDate;
              }
              fullDateStr = timeStr;
            }
          }
          newLabels.add(timeStr);
          newFullLabels.add(fullDateStr);
        }

        if (mounted) {
          setState(() {
            historySpots = newSpots;
            historyTimeLabels = newLabels;
            historyFullDateLabels = newFullLabels;
            isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoadingHistory = false);
      }
    } catch (e) {
      print('Error fetching $sensorType history: $e');
      if (mounted) setState(() => isLoadingHistory = false);
    }
  }

  Future<void> _connectWebSocket() async {
    _disconnectWebSocket();
    if (channel != null) return;
    try {
      channel = WebSocketChannel.connect(AppConfig.wsSensors(currentShelterId));
      await channel!.ready;

      _wsSub = channel!.stream.listen(
        (message) {
          try {
            final decoded = jsonDecode(message.toString());
            if (decoded is Map<String, dynamic> &&
                decoded['type'] == 'sensor' &&
                decoded['data'] is Map &&
                mounted) {
              final data = decoded['data'] as Map;
              setState(() {
                data.forEach((k, v) {
                  sensorValues[k.toString()] = v.toString();
                });
              });
            }
          } catch (e) {
            print('WS Parse Error: $e');
          }
        },
        onDone: () {
          _wsSub = null;
          channel = null;
          // Sambung ulang otomatis setelah 3 detik
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _connectWebSocket();
          });
        },
        onError: (e) {
          print('WS Error: $e');
        },
      );
    } catch (e) {
      print('WS Connect Exception: $e');
      channel = null;
    }
  }

  void _disconnectWebSocket() {
    _wsSub?.cancel();
    _wsSub = null;
    try {
      channel?.sink.close();
    } catch (_) {}
    channel = null;
  }

  void _publishCommand(String device, bool isOn) {
    if (channel == null) return;
    final commandName = '${isOn ? "on" : "off"}_${device.toLowerCase()}';
    final payload = jsonEncode({"type": "command", "command": commandName});
    try {
      channel!.sink.add(payload);
    } catch (e) {
      print('WS publish error: $e');
    }
  }

  void _showEditAppTitleDialog() {
    final titleCtrl = TextEditingController(text: appTitle);
    final subtitleCtrl = TextEditingController(text: appSubtitle);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3C72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.amberAccent),
              SizedBox(width: 8),
              Text(
                'Kustomisasi Aplikasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nama Aplikasi / Dashboard',
                    hintText: 'Contoh: Smart Shelter Monitoring',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subtitleCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Deskripsi Singkat',
                    hintText: 'Contoh: Live metrics from your smart shelter',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                titleCtrl.text = 'Sensor Dashboard';
                subtitleCtrl.text = 'Live metrics from your smart shelter';
              },
              child: const Text(
                'Reset Default',
                style: TextStyle(color: Colors.orangeAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final newTitle = titleCtrl.text.trim();
                final newSubtitle = subtitleCtrl.text.trim();
                if (newTitle.isNotEmpty) {
                  _saveAppCustomization(
                    newTitle,
                    newSubtitle.isNotEmpty
                        ? newSubtitle
                        : 'Live metrics from your smart shelter',
                  );
                }
                Navigator.pop(ctx);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShelterSelectorChip() {
    final activeShelter = availableShelters.firstWhere(
      (s) => s.id == currentShelterId,
      orElse: () => ShelterData(id: currentShelterId, name: currentShelterId),
    );

    // Hindari duplikasi jika nama shelter sudah mengandung ID
    final displayName = activeShelter.name.contains(activeShelter.id)
        ? activeShelter.name
        : '${activeShelter.name} (${activeShelter.id})';

    final hasMultipleShelters = availableShelters.length > 1;

    return InkWell(
      onTap: hasMultipleShelters ? _showShelterSelectorModal : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_city_rounded,
              size: 15,
              color: Color(0xFF00E5FF),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasMultipleShelters) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: Colors.white70,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showShelterSelectorModal() {
    if (availableShelters.length <= 1) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF1E3C72),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.location_city_rounded, color: Colors.cyanAccent),
                  SizedBox(width: 10),
                  Text(
                    'Pilih Smart Shelter / Site',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Data sensor real-time, grafik riwayat, dan kontrol aktuator otomatis terisolasi untuk site yang dipilih.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableShelters.length,
                  itemBuilder: (context, index) {
                    final s = availableShelters[index];
                    final isSelected = s.id == currentShelterId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.cyanAccent.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.cyanAccent
                              : Colors.white.withValues(alpha: 0.15),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(ctx);
                          _changeShelter(s.id);
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.cyanAccent.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.home_work_rounded,
                            color: isSelected
                                ? Colors.cyanAccent
                                : Colors.white70,
                          ),
                        ),
                        title: Text(
                          s.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'ID: ${s.id}${s.latitude != null ? " • Lat: ${s.latitude!.toStringAsFixed(4)}, Lng: ${s.longitude!.toStringAsFixed(4)}" : ""}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.cyanAccent,
                              )
                            : const Icon(
                                Icons.radio_button_unchecked_rounded,
                                color: Colors.white38,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSensorDialog() {
    final nameController = TextEditingController();
    final keyController = TextEditingController();
    final unitController = TextEditingController();
    int selectedIconIdx = 0;
    int selectedColorIdx = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E3C72),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  Icon(Icons.sensors_rounded, color: Colors.orangeAccent),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Sensor Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Sensor',
                        hintText: 'Contoh: Soil Moisture / CO2',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keyController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'MQTT Key (di JSON)',
                        hintText: 'Contoh: soil_moisture',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white38),
                        helperText:
                            'Harus sama persis dengan key JSON dari alat',
                        helperStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: unitController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Satuan / Unit',
                        hintText: 'Contoh: %, ppm, V, Pa',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Ikon:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(kAvailableIcons.length, (idx) {
                        final isChosen = selectedIconIdx == idx;
                        return InkWell(
                          onTap: () =>
                              setDialogState(() => selectedIconIdx = idx),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isChosen
                                    ? Colors.orangeAccent
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              kAvailableIcons[idx],
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Warna:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(kAvailableColors.length, (idx) {
                        final isChosen = selectedColorIdx == idx;
                        return InkWell(
                          onTap: () =>
                              setDialogState(() => selectedColorIdx = idx),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: kAvailableColors[idx],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChosen
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isChosen
                                ? const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Colors.black87,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAvailableColors[selectedColorIdx],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final key = keyController.text.trim().toLowerCase();
                    final unit = unitController.text.trim();

                    if (name.isEmpty || key.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nama dan MQTT Key tidak boleh kosong!',
                          ),
                        ),
                      );
                      return;
                    }

                    if (sensors.any((s) => s.key == key)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'MQTT Key sudah digunakan sensor lain!',
                          ),
                        ),
                      );
                      return;
                    }

                    final newSensor = SensorMeta(
                      key: key,
                      title: name,
                      unit: unit,
                      iconIndex: selectedIconIdx,
                      colorValue: kAvailableColors[selectedColorIdx].toARGB32(),
                      isDefault: false,
                    );

                    setState(() {
                      sensors.add(newSensor);
                    });
                    _saveSensors();
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Simpan Sensor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSensor(SensorMeta s) {
    if (s.key == 'nh4' || s.key == 'o2' || s.isDefault) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E3C72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Sensor "${s.title}"?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Sensor ${s.title} (${s.key}) akan dihapus dari dashboard Anda.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                sensors.removeWhere((item) => item.key == s.key);
                if (_selectedSensorKey == s.key) {
                  _selectedSensorKey = 'nh4';
                }
              });
              _saveSensors();
              _fetchHistory(_selectedSensorKey);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAddSensorCard() {
    return GestureDetector(
      onTap: _showAddSensorDialog,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tambah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nh4 = nh4Sensor;
    final o2 = o2Sensor;
    final nh4Val = sensorValues[nh4.key];
    final o2Val = sensorValues[o2.key];
    final others = otherSensors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appSubtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildShelterSelectorChip(),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _showEditAppTitleDialog,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                tooltip: 'Kustomisasi Nama & Deskripsi Aplikasi',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SECTION 1: PRIMARY FIXED SENSORS (HERO CARDS - NH4 & O2)
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PRIMARY SENSORS (FIXED)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LargeHeroSensorCard(
                  title: nh4.title,
                  value: nh4Val ?? '--',
                  unit: nh4.unit,
                  icon: nh4.icon,
                  color: nh4.color,
                  isSelected: _selectedSensorKey == nh4.key,
                  onTap: () {
                    setState(() => _selectedSensorKey = nh4.key);
                    _fetchHistory(nh4.key);
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: LargeHeroSensorCard(
                  title: o2.title,
                  value: o2Val ?? '--',
                  unit: o2.unit,
                  icon: o2.icon,
                  color: o2.color,
                  isSelected: _selectedSensorKey == o2.key,
                  onTap: () {
                    setState(() => _selectedSensorKey = o2.key);
                    _fetchHistory(o2.key);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // SECTION 2: OTHER PARAMETERS (COMPACT CARDS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'OTHER PARAMETERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Text(
                '${others.length} parameter',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            itemCount: others.length + 1,
            itemBuilder: (context, index) {
              if (index == others.length) {
                return _buildCompactAddSensorCard();
              }
              final s = others[index];
              final isSelected = _selectedSensorKey == s.key;
              final rawVal = sensorValues[s.key];

              return CompactSensorCard(
                title: s.title,
                value: rawVal ?? '--',
                unit: s.unit,
                icon: s.icon,
                color: s.color,
                isDefault: s.isDefault,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedSensorKey = s.key);
                  _fetchHistory(s.key);
                },
                onLongPress: s.isDefault ? null : () => _confirmDeleteSensor(s),
              );
            },
          ),

          const SizedBox(height: 32),
          const Text(
            'Control Panel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCommandSwitch('Pump', Icons.water_drop, isPumpOn, (val) {
                setState(() => isPumpOn = val);
                _publishCommand('pump', val);
              }),
              _buildCommandSwitch('Light', Icons.lightbulb, isLightOn, (val) {
                setState(() => isLightOn = val);
                _publishCommand('light', val);
              }),
              _buildCommandSwitch('Fan', Icons.air, isFanOn, (val) {
                setState(() => isFanOn = val);
                _publishCommand('fan', val);
              }),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${selectedSensor.title} History',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selectedSensor.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedSensor.color.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      selectedSensor.unit,
                      style: TextStyle(
                        color: selectedSensor.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                tooltip: 'Refresh History',
                onPressed: () => _fetchHistory(selectedSensor.key),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(sensors.length, (idx) {
                final s = sensors[idx];
                final active = _selectedSensorKey == s.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedSensorKey = s.key);
                      _fetchHistory(s.key);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? s.color
                            : const Color(0xFF152238).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? s.color
                              : Colors.white.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: s.color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            s.icon,
                            size: 16,
                            color: active ? Colors.black87 : s.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.title,
                            style: TextStyle(
                              color: active ? Colors.black87 : Colors.white,
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 270,
                padding: const EdgeInsets.fromLTRB(6, 18, 18, 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: isLoadingHistory
                    ? Center(
                        child: CircularProgressIndicator(
                          color: selectedSensor.color,
                        ),
                      )
                    : historySpots.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada data history di database',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          double? computedMinY;
                          double? computedMaxY;
                          double intervalY = 1.0;
                          if (historySpots.isNotEmpty) {
                            final yValues = historySpots
                                .map((s) => s.y)
                                .toList();
                            final minYVal = yValues.reduce(
                              (a, b) => a < b ? a : b,
                            );
                            final maxYVal = yValues.reduce(
                              (a, b) => a > b ? a : b,
                            );
                            final diff = maxYVal - minYVal;
                            final padding = diff > 0
                                ? diff * 0.2
                                : (maxYVal == 0 ? 1.0 : maxYVal.abs() * 0.2);
                            computedMinY = (minYVal - padding / 2).clamp(
                              0,
                              double.infinity,
                            );
                            computedMaxY = maxYVal + padding;
                            final span = computedMaxY - computedMinY;
                            intervalY = span > 0 ? (span / 4) : 1.0;
                          }

                          return LineChart(
                            LineChartData(
                              minY: computedMinY,
                              maxY: computedMaxY,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                drawHorizontalLine: true,
                                horizontalInterval: intervalY > 0
                                    ? intervalY
                                    : null,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  strokeWidth: 1,
                                  dashArray: [4, 4],
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 38,
                                    interval: intervalY > 0 ? intervalY : null,
                                    getTitlesWidget: (value, meta) {
                                      if (computedMinY != null &&
                                          value < (computedMinY - 0.001)) {
                                        return const SizedBox.shrink();
                                      }
                                      if (computedMaxY != null &&
                                          value > (computedMaxY + 0.001)) {
                                        return const SizedBox.shrink();
                                      }
                                      String text;
                                      if (value >= 100) {
                                        text = value.toStringAsFixed(0);
                                      } else if (value >= 10) {
                                        text = value.toStringAsFixed(0);
                                      } else {
                                        text = value.toStringAsFixed(1);
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6.0,
                                        ),
                                        child: Text(
                                          text,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 26,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 &&
                                          index < historyTimeLabels.length) {
                                        int step =
                                            (historyTimeLabels.length / 5)
                                                .ceil()
                                                .clamp(1, 10);
                                        if (index % step == 0 ||
                                            index ==
                                                historyTimeLabels.length - 1) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
                                            child: Text(
                                              historyTimeLabels[index],
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                  left: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                              ),
                              lineTouchData: LineTouchData(
                                handleBuiltInTouches: true,
                                touchTooltipData: LineTouchTooltipData(
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true,
                                  getTooltipColor: (touchedSpot) =>
                                      const Color(0xFF0F172A)
                                          .withValues(alpha: 0.95),
                                  tooltipBorderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      int idx = spot.x.toInt();
                                      String dateTime =
                                          (idx >= 0 &&
                                              idx <
                                                  historyFullDateLabels.length)
                                          ? historyFullDateLabels[idx]
                                          : ((idx >= 0 &&
                                                  idx <
                                                      historyTimeLabels.length)
                                              ? historyTimeLabels[idx]
                                              : '');
                                      String formattedVal =
                                          spot.y >= 10
                                              ? spot.y.toStringAsFixed(1)
                                              : spot.y.toStringAsFixed(2);
                                      return LineTooltipItem(
                                        '$formattedVal ${selectedSensor.unit}\n$dateTime',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: historySpots,
                                  isCurved: true,
                                  curveSmoothness: 0.35,
                                  color: selectedSensor.color,
                                  barWidth: 3.5,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: historySpots.length <= 25,
                                    getDotPainter: (
                                      spot,
                                      percent,
                                      barData,
                                      index,
                                    ) {
                                      return FlDotCirclePainter(
                                        radius: 3.5,
                                        color: selectedSensor.color,
                                        strokeWidth: 1.5,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        selectedSensor.color.withValues(
                                          alpha: 0.35,
                                        ),
                                        selectedSensor.color.withValues(
                                          alpha: 0.02,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildCommandSwitch(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: value ? Colors.greenAccent : Colors.white70,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.greenAccent,
        ),
      ],
    );
  }
}

class LargeHeroSensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const LargeHeroSensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [
                        color.withValues(alpha: 0.35),
                        color.withValues(alpha: 0.15),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? color
                    : Colors.white.withValues(alpha: 0.22),
                width: isSelected ? 2.2 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(icon, size: 22, color: color),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded, size: 10, color: color),
                          const SizedBox(width: 3),
                          Text(
                            'FIXED',
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompactSensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CompactSensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.isDefault = true,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? color
                    : Colors.white.withValues(alpha: 0.16),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (unit.isNotEmpty) ...[
                            const SizedBox(width: 2),
                            Text(
                              unit,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isDefault)
                  const Icon(Icons.more_vert, size: 14, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- LOCATION TAB ----------------
// ---------------- LOCATION TAB ----------------
class LocationTab extends StatefulWidget {
  const LocationTab({super.key});

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab> {
  // Titik Target Shelter & Radius (dapat diatur user)
  String currentShelterId = 'SHELTER-01';
  double shelterLat = -6.951613312233824;
  double shelterLng = 107.53343065982726;
  double thresholdMeters = 150.0; // default 150 meter

  WebSocketChannel? channel;
  StreamSubscription? _wsSub;
  bool isConnected = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  double? currentLat;
  double? currentLng;
  double? currentDistanceKm;
  bool isLocked = true; // true = merah (lock), false = hijau (unlock)
  bool isLoading = false;
  String? lastCommandSent;
  String statusMessage = 'Mengaktifkan pelacakan geofence otomatis...';

  @override
  void initState() {
    super.initState();
    _loadGeofenceSettings().then((_) {
      _startLiveGeofence();
      _connectWebSocket();
    });
  }

  Future<void> _loadGeofenceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString('current_shelter_id') ?? 'SHELTER-01';

    // 1. Tampilkan cache lokal terlebih dahulu agar UI instan
    setState(() {
      currentShelterId = activeId;
      shelterLat = prefs.getDouble('shelter_lat') ?? -6.902400;
      shelterLng = prefs.getDouble('shelter_lng') ?? 107.618700;
      thresholdMeters = prefs.getDouble('shelter_radius_m') ?? 100.0;
    });

    // 2. Ambil parameter TERBARU langsung dari database via API /shelters
    try {
      final tenantId = prefs.getString('tenant_id');
      final response = await http
          .get(AppConfig.shelters(tenantId: tenantId))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> shelters = data['shelters'] ?? [];
        final currentShelter = shelters.firstWhere(
          (s) => s['id'] == activeId,
          orElse: () => shelters.isNotEmpty ? shelters[0] : null,
        );

        if (currentShelter != null && mounted) {
          final dbLat = (currentShelter['latitude'] as num?)?.toDouble() ?? shelterLat;
          final dbLng = (currentShelter['longitude'] as num?)?.toDouble() ?? shelterLng;
          final dbRadius = (currentShelter['geofence_radius'] as num?)?.toDouble() ?? thresholdMeters;

          setState(() {
            shelterLat = dbLat;
            shelterLng = dbLng;
            thresholdMeters = dbRadius;
          });

          await prefs.setDouble('shelter_lat', dbLat);
          await prefs.setDouble('shelter_lng', dbLng);
          await prefs.setDouble('shelter_radius_m', dbRadius);

          if (currentLat != null && currentLng != null) {
            _evaluateLocation(currentLat!, currentLng!);
          }
        }
      }
    } catch (e) {
      debugPrint('Info: Menggunakan cache lokal geofence (server unreached): $e');
    }
  }

  Future<void> _saveGeofenceSettings(
    double lat,
    double lng,
    double radiusM,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('shelter_lat', lat);
    await prefs.setDouble('shelter_lng', lng);
    await prefs.setDouble('shelter_radius_m', radiusM);
    setState(() {
      shelterLat = lat;
      shelterLng = lng;
      thresholdMeters = radiusM;
    });
    if (currentLat != null && currentLng != null) {
      _evaluateLocation(currentLat!, currentLng!);
    }

    // Sinkronisasi permanen ke database MariaDB via HTTP PUT
    try {
      final response = await http
          .put(
            AppConfig.updateShelter(currentShelterId),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'latitude': lat,
              'longitude': lng,
              'geofence_radius': radiusM,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lokasi & radius shelter berhasil disimpan ke database!',
            ),
            backgroundColor: Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tersimpan di HP, gagal sinkron database (Status: ${response.statusCode})',
            ),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating shelter to database: $e');
    }
  }

  void _showEditGeofenceDialog() {
    final latController = TextEditingController(text: shelterLat.toString());
    final lngController = TextEditingController(text: shelterLng.toString());
    final radiusController = TextEditingController(
      text: thresholdMeters.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E3C72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atur Shelter & Radius',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tentukan koordinat titik shelter dan jarak batas radius untuk penguncian pintu otomatis.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: latController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Latitude Shelter',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lngController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Longitude Shelter',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: radiusController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Radius Geofence (Meter)',
                    helperText: 'Contoh: 150 (150 m) atau 2000 (2 km)',
                    helperStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.radar_rounded,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyanAccent,
                    side: const BorderSide(color: Colors.cyanAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final pos = await Geolocator.getCurrentPosition(
                        locationSettings: const LocationSettings(
                          accuracy: LocationAccuracy.high,
                        ),
                      );
                      setDialogState(() {
                        latController.text = pos.latitude.toString();
                        lngController.text = pos.longitude.toString();
                      });
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal membaca GPS HP: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text(
                    'Gunakan GPS HP Saat Ini',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final lat = double.tryParse(latController.text.trim());
                final lng = double.tryParse(lngController.text.trim());
                final radius = double.tryParse(radiusController.text.trim());

                if (lat == null ||
                    lng == null ||
                    radius == null ||
                    radius <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Format input koordinat atau radius tidak valid!',
                      ),
                    ),
                  );
                  return;
                }

                _saveGeofenceSettings(lat, lng, radius);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pengaturan Shelter & Radius (${radius >= 1000 ? "${(radius / 1000).toStringAsFixed(1)} km" : "${radius.toStringAsFixed(0)} m"}) berhasil disimpan!',
                    ),
                  ),
                );
              },
              child: const Text(
                'Simpan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectWebSocket() async {
    _disconnectWebSocket();
    if (channel != null) return;
    try {
      channel = WebSocketChannel.connect(AppConfig.wsSensors(currentShelterId));
      await channel!.ready;
      if (mounted) setState(() => isConnected = true);
      _wsSub = channel!.stream.listen(
        (_) {},
        onDone: () {
          _wsSub = null;
          channel = null;
          if (mounted) setState(() => isConnected = false);
        },
        onError: (e) {
          print('WS LocationTab error: $e');
        },
      );
    } catch (e) {
      print('WS LocationTab connect error: $e');
      if (mounted) setState(() => isConnected = false);
      channel = null;
    }
  }

  void _disconnectWebSocket() {
    _wsSub?.cancel();
    _wsSub = null;
    try {
      channel?.sink.close();
    } catch (_) {}
    channel = null;
    isConnected = false;
  }

  void _publishCommand(String command) {
    if (channel != null) {
      final payload = jsonEncode({'type': 'command', 'command': command});
      try {
        channel!.sink.add(payload);
      } catch (e) {
        print('WS publish error: $e');
      }
    }
    setState(() {
      lastCommandSent = command;
    });
  }

  void _evaluateLocation(double lat, double lng, {bool isSimulation = false}) {
    final distanceMeters = Geolocator.distanceBetween(
      lat,
      lng,
      shelterLat,
      shelterLng,
    );
    final distanceKm = distanceMeters / 1000.0;

    // Logika: >= 2 km -> Terkunci (Merah), < 2 km -> Terbuka (Hijau)
    final shouldLock = distanceMeters >= thresholdMeters;
    final command = shouldLock ? 'lock' : 'unlock';

    setState(() {
      currentLat = lat;
      currentLng = lng;
      currentDistanceKm = distanceKm;
      isLocked = shouldLock;
      statusMessage = isSimulation
          ? 'Mode Simulasi: Jarak ${distanceKm.toStringAsFixed(2)} km'
          : 'Geofence Aktif • Jarak: ${(distanceKm >= 1.0 ? "${distanceKm.toStringAsFixed(2)} km" : "${distanceMeters.toStringAsFixed(0)} meter")}';
    });

    _publishCommand(command);
  }

  Future<void> _startLiveGeofence() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Mengaktifkan pelacakan geofence otomatis...';
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            isLoading = false;
            statusMessage = 'Layanan GPS tidak aktif di HP Anda.';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              isLoading = false;
              statusMessage = 'Izin lokasi ditolak oleh pengguna.';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            isLoading = false;
            statusMessage =
                'Izin lokasi ditolak permanen. Aktifkan di Pengaturan HP.';
          });
        }
        return;
      }

      // Ambil posisi awal segera
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (mounted) {
        _evaluateLocation(position.latitude, position.longitude);
        setState(() => isLoading = false);
      }

      // Pasang live stream GPS agar selalu update saat user berpindah posisi
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5, // update setiap ada pergerakan 5 meter
            ),
          ).listen(
            (Position pos) {
              if (mounted) {
                _evaluateLocation(pos.latitude, pos.longitude);
              }
            },
            onError: (e) {
              if (mounted) {
                setState(() => statusMessage = 'Error stream GPS: $e');
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          statusMessage = 'Gagal membaca GPS: $e';
        });
      }
    }
  }

  /*
  void _simulateNear() {
    // Simulasi koordinat berjarak ~0.7 km dari shelter (-6.9460, 107.5334)
    _evaluateLocation(-6.946000, 107.533430, isSimulation: true);
  }

  void _simulateFar() {
    // Simulasi koordinat berjarak ~3.8 km dari shelter (-6.9200, 107.5334)
    _evaluateLocation(-6.920000, 107.533430, isSimulation: true);
  }
  */

  void _toggleManual() {
    final newLock = !isLocked;
    setState(() => isLocked = newLock);
    _publishCommand(newLock ? 'lock' : 'unlock');
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radiusLabel = thresholdMeters >= 1000
        ? '${(thresholdMeters / 1000.0).toStringAsFixed(1)} km'
        : '${thresholdMeters.toStringAsFixed(0)} meter';

    final doorColor = isLocked
        ? const Color(0xFFFF3B30)
        : const Color(0xFF00E676);
    final statusTitle = isLocked ? 'PINTU TERKUNCI' : 'PINTU TERBUKA (UNLOCK)';
    final statusSub = isLocked
        ? 'Jarak ≥ $radiusLabel dari Shelter. Pintu otomatis terkunci demi keamanan.'
        : 'Jarak < $radiusLabel dari Shelter. Pintu terbuka / siap diakses.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Geofence & Door',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kontrol pintu otomatis berbasis radius $radiusLabel',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'Target Site: $currentShelterId',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'WebSocket Online' : 'Connecting...',
                      style: TextStyle(
                        color: isConnected
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // HERO DOOR STATUS CARD
          GestureDetector(
            onTap: _toggleManual,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        doorColor.withValues(alpha: 0.35),
                        doorColor.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: doorColor, width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: doorColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: doorColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: doorColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLocked
                                      ? Icons.lock_rounded
                                      : Icons.lock_open_rounded,
                                  size: 13,
                                  color: doorColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isLocked
                                      ? 'STATUS: LOCKED'
                                      : 'STATUS: UNLOCKED',
                                  style: TextStyle(
                                    color: doorColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Tap untuk toggle manual',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // IKON PINTU BESAR
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: doorColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: doorColor.withValues(alpha: 0.6),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: doorColor.withValues(alpha: 0.25),
                              blurRadius: 25,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isLocked
                              ? Icons.meeting_room_rounded
                              : Icons.meeting_room_outlined,
                          size: 72,
                          color: doorColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: doorColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusSub,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.straighten_rounded,
                              size: 18,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                currentDistanceKm != null
                                    ? 'Jarak: ${(currentDistanceKm! >= 1.0 ? "${currentDistanceKm!.toStringAsFixed(2)} km" : "${(currentDistanceKm! * 1000).toStringAsFixed(0)} meter")} dari Shelter'
                                    : 'Jarak: Belum terukur (Batas: $radiusLabel)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // INFORMASI KOORDINAT & GEOFENCE
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.radar_rounded,
                              size: 18,
                              color: Colors.cyanAccent,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Parameter Geofencing',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // InkWell(
                        //   onTap: _showEditGeofenceDialog,
                        //   borderRadius: BorderRadius.circular(8),
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 8,
                        //       vertical: 4,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.cyanAccent.withValues(alpha: 0.2),
                        //       borderRadius: BorderRadius.circular(8),
                        //       border: Border.all(
                        //         color: Colors.cyanAccent,
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: const Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(
                        //           Icons.tune_rounded,
                        //           size: 13,
                        //           color: Colors.cyanAccent,
                        //         ),
                        //         SizedBox(width: 4),
                        //         Text(
                        //           'Atur',
                        //           style: TextStyle(
                        //             color: Colors.cyanAccent,
                        //             fontSize: 11,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Shelter Aktif:',
                      currentShelterId,
                      valColor: Colors.cyanAccent,
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      'Titik Shelter:',
                      'Lat: ${shelterLat.toStringAsFixed(6)}, Lng: ${shelterLng.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      'Posisi HP Anda:',
                      currentLat != null
                          ? 'Lat: ${currentLat!.toStringAsFixed(6)}, Lng: ${currentLng!.toStringAsFixed(6)}'
                          : 'Belum terdeteksi',
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      'Radius Geofence:',
                      '$radiusLabel (${thresholdMeters.toStringAsFixed(0)} meter)',
                    ),
                    if (lastCommandSent != null) ...[
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'Command Terakhir:',
                        '{"command": "$lastCommandSent"}',
                        valColor: doorColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /*
          // TOMBOL DETEKSI GPS HP (Otomatis Aktif dari Awal)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A5298),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: isLoading ? null : _startLiveGeofence,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                isLoading
                    ? 'Membaca Lokasi GPS...'
                    : 'Deteksi Lokasi GPS HP (Aktual)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          */

          // TOMBOL ATUR LOKASI SHELTER & GEOFENCE
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3C72),
                foregroundColor: Colors.cyanAccent,
                side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: _showEditGeofenceDialog,
              icon: const Icon(Icons.tune_rounded, color: Colors.cyanAccent),
              label: const Text(
                'Atur Lokasi Shelter & Geofence',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              statusMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          /*
          const SizedBox(height: 24),

          // BAGIAN UJI COBA SIMULASI
          const Row(
            children: [
              Icon(Icons.science_rounded, size: 18, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text(
                'UJI COBA CEPAT (SIMULATOR)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676)
                        .withValues(alpha: 0.2),
                    foregroundColor: const Color(0xFF00E676),
                    side: const BorderSide(
                      color: Color(0xFF00E676),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _simulateNear,
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Dekat (< 2 km)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Unlock (Hijau)',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30)
                        .withValues(alpha: 0.2),
                    foregroundColor: const Color(0xFFFF5252),
                    side: const BorderSide(
                      color: Color(0xFFFF5252),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _simulateFar,
                  icon: const Icon(Icons.lock_rounded, size: 18),
                  label: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jauh (≥ 2 km)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Lock (Merah)',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          */
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- PROFILE TAB ----------------
class ProfileTab extends StatefulWidget {
  final String username;

  const ProfileTab({super.key, required this.username});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _role = 'User';
  String _tenantId = '-';
  String _currentShelterId = 'SHELTER-01';
  String? _profileImagePath;
  String? _serverAvatarUrl;
  bool _isUploadingAvatar = false;
  List<ShelterData> _shelters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role') ?? 'User';
    final savedTenant = prefs.getString('tenant_id') ?? '-';
    final savedShelterId =
        prefs.getString('current_shelter_id') ?? 'SHELTER-01';
    final savedImagePath =
        prefs.getString('profile_image_${widget.username}');
    final savedServerAvatar =
        prefs.getString('profile_image_server_${widget.username}');

    List<ShelterData> loadedShelters = [];
    final savedSheltersJson = prefs.getString('available_shelters');
    if (savedSheltersJson != null && savedSheltersJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(savedSheltersJson);
        loadedShelters =
            decoded.map((e) => ShelterData.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error parsing cached shelters in profile: $e');
      }
    }

    if (mounted) {
      setState(() {
        _role = savedRole;
        _tenantId = savedTenant;
        _currentShelterId = savedShelterId;
        _profileImagePath = savedImagePath;
        _serverAvatarUrl = savedServerAvatar;
        _shelters = loadedShelters;
        _isLoading = false;
      });
    }

    // Ambil data shelter paling fresh dari database server
    _fetchFreshShelters(savedTenant);
  }

  Future<void> _fetchFreshShelters(String tenantId) async {
    try {
      final uri = AppConfig.shelters(
        tenantId: (tenantId.isNotEmpty && tenantId != '-') ? tenantId : null,
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['shelters'] != null) {
          final List<dynamic> list = data['shelters'];
          final updated =
              list.map((e) => ShelterData.fromJson(e)).toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('available_shelters', jsonEncode(list));
          if (mounted) {
            setState(() {
              _shelters = updated;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching fresh shelters in profile: $e');
    }
  }

  Future<void> _switchActiveShelter(ShelterData shelter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_shelter_id', shelter.id);
    if (shelter.latitude != null) {
      await prefs.setDouble('shelter_lat', shelter.latitude!);
    }
    if (shelter.longitude != null) {
      await prefs.setDouble('shelter_lng', shelter.longitude!);
    }
    await prefs.setDouble('shelter_radius_m', shelter.geofenceRadius);

    if (mounted) {
      setState(() {
        _currentShelterId = shelter.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Shelter aktif diubah ke: ${shelter.name} (${shelter.id})',
          ),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'profile_image_${widget.username}',
          pickedFile.path,
        );

        if (mounted) {
          setState(() {
            _profileImagePath = pickedFile.path;
            _isUploadingAvatar = true;
          });
        }

        // Upload ke database server MariaDB via backend API
        try {
          final req = http.MultipartRequest('POST', AppConfig.uploadAvatar());
          req.fields['username'] = widget.username;
          req.files.add(
            await http.MultipartFile.fromPath('avatar', pickedFile.path),
          );
          final streamed =
              await req.send().timeout(const Duration(seconds: 12));
          final res = await http.Response.fromStream(streamed);

          if (res.statusCode == 200) {
            final body = jsonDecode(res.body);
            if (body['foto_profile'] != null) {
              final remoteUrl = body['foto_profile'].toString();
              await prefs.setString(
                'profile_image_server_${widget.username}',
                remoteUrl,
              );
              if (mounted) {
                setState(() {
                  _serverAvatarUrl = remoteUrl;
                });
              }
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Foto profil berhasil diperbarui & tersimpan di server!',
                  ),
                  backgroundColor: Color(0xFF00C853),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            debugPrint('Server upload avatar status: ${res.statusCode}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Foto tersimpan lokal (Upload server: HTTP ${res.statusCode})',
                  ),
                  backgroundColor: Colors.orangeAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        } catch (uploadErr) {
          debugPrint('Upload avatar error: $uploadErr');
        } finally {
          if (mounted) {
            setState(() {
              _isUploadingAvatar = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_${widget.username}');
    await prefs.remove('profile_image_server_${widget.username}');

    if (mounted) {
      setState(() {
        _profileImagePath = null;
        _serverAvatarUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil dikembalikan ke default.'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Hapus di server database
    try {
      await http
          .delete(AppConfig.deleteAvatar(widget.username))
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('Delete avatar from server error: $e');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Ganti Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  title: const Text(
                    'Ambil Foto (Kamera)',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_profileImagePath != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _removeProfileImage();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun "${widget.username}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');

              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayRole = _role.isNotEmpty
        ? (_role.toLowerCase() == 'admin'
            ? 'Administrator'
            : _role[0].toUpperCase() + _role.substring(1))
        : 'User';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // --- KARTU PROFIL UTAMA (Glassmorphic) ---
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar dengan tombol kamera
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: () => _showImageSourceActionSheet(context),
                            child: Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(alpha: 0.6),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (_profileImagePath != null &&
                                        File(_profileImagePath!).existsSync())
                                      Image.file(
                                        File(_profileImagePath!),
                                        width: 108,
                                        height: 108,
                                        fit: BoxFit.cover,
                                      )
                                    else if (_serverAvatarUrl != null &&
                                        _serverAvatarUrl!.isNotEmpty)
                                      Image.network(
                                        AppConfig.avatarUrl(_serverAvatarUrl!),
                                        width: 108,
                                        height: 108,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF0072FF),
                                                Color(0xFF00C6FF),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF0072FF),
                                              Color(0xFF00C6FF),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    if (_isUploadingAvatar)
                                      Container(
                                        color: Colors.black45,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              color: Colors.cyanAccent,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Badge Camera Button
                          GestureDetector(
                            onTap: () => _showImageSourceActionSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0F172A),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Color(0xFF0A192F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Username
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Badge Role
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          displayRole,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.cyanAccent,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Tenant Info Chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.domain_rounded,
                            size: 15,
                            color: Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tenant ID: $_tenantId',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION SHELTER INFORMATION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.sensors_rounded,
                      color: Colors.cyanAccent,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'SHELTER TERHUBUNG',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _fetchFreshShelters(_tenantId),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.cyanAccent,
                    size: 20,
                  ),
                  tooltip: 'Segarkan data shelter',
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.cyanAccent,
                  ),
                ),
              )
            else if (_shelters.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white54,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada data shelter yang dimuat',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ..._shelters.map((shelter) {
                final isSelected = shelter.id == _currentShelterId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.12),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card Shelter
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.apartment_rounded,
                              color: isSelected
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white70,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shelter.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  shelter.id,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF00C853),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF00C853),
                                    size: 13,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Aktif',
                                    style: TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => _switchActiveShelter(shelter),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Pilih',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 10),

                      // Parameter Details (Koordinat & Radius)
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 15,
                                  color: Colors.cyanAccent,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    (shelter.latitude != null &&
                                            shelter.longitude != null)
                                        ? '${shelter.latitude!.toStringAsFixed(4)}, ${shelter.longitude!.toStringAsFixed(4)}'
                                        : 'Belum diatur',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.radar_rounded,
                                size: 15,
                                color: Colors.amberAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${shelter.geofenceRadius.toInt()} m',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // --- TOMBOL LOGOUT ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

