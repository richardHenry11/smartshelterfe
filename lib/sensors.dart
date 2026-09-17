import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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
                                  const Color(0xFF00E5FF).withValues(alpha: 0.22),
                                  const Color(0xFF2A5298).withValues(alpha: 0.30),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
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

// ---------------- DASHBOARD TAB ----------------
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  MqttServerClient? client;

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
    _connectMqtt();
  }

  Future<void> _loadAppCustomization() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        appTitle = prefs.getString('app_title') ?? 'Sensor Dashboard';
        appSubtitle = prefs.getString('app_subtitle') ??
            'Live metrics from your smart shelter';
      });
    }
  }

  Future<void> _saveAppCustomization(String title, String subtitle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_title', title);
    await prefs.setString('app_subtitle', subtitle);
    if (mounted) {
      setState(() {
        appTitle = title;
        appSubtitle = subtitle;
      });
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
        Uri.parse(
          'https://shelter.cbinstrument.com/sensor/history/$sensorType?limit=24',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> history = data['history'] ?? [];

        List<FlSpot> newSpots = [];
        List<String> newLabels = [];

        for (int i = 0; i < history.length; i++) {
          final item = history[i];
          final val = (item['value'] as num).toDouble();
          newSpots.add(FlSpot(i.toDouble(), val));

          String timeStr = '$i';
          if (item['created_at'] != null) {
            final rawDate = item['created_at'].toString().trim();
            try {
              // Server MySQL menyimpan waktu dalam UTC.
              // Tambahkan marker 'Z' (UTC) lalu konversi ke waktu lokal HP (.toLocal() -> WIB/WITA/WIT).
              DateTime dt;
              if (rawDate.endsWith('Z') || rawDate.contains('+')) {
                dt = DateTime.parse(rawDate).toLocal();
              } else {
                final isoStr = '${rawDate.replaceAll(' ', 'T')}Z';
                dt = DateTime.parse(isoStr).toLocal();
              }
              final hour = dt.hour.toString().padLeft(2, '0');
              final minute = dt.minute.toString().padLeft(2, '0');
              timeStr = '$hour:$minute';
            } catch (e) {
              if (rawDate.contains('T')) {
                timeStr = rawDate.split('T')[1].substring(0, 5);
              } else if (rawDate.contains(' ')) {
                timeStr = rawDate.split(' ')[1].substring(0, 5);
              } else {
                timeStr = rawDate;
              }
            }
          }
          newLabels.add(timeStr);
        }

        if (mounted) {
          setState(() {
            historySpots = newSpots;
            historyTimeLabels = newLabels;
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

  Future<void> _connectMqtt() async {
    client = MqttServerClient(
      'shelter.cbinstrument.com',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    client!.port = 1883;
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
          'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        )
        .startClean();
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } catch (e) {
      print('MQTT Connect Exception: $e');
      client!.disconnect();
      return;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      client!.subscribe('shelter/SHELTER-01/sensors', MqttQos.atLeastOnce);

      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        try {
          final data = jsonDecode(pt);
          if (data is Map<String, dynamic> && mounted) {
            setState(() {
              data.forEach((k, v) {
                sensorValues[k] = v.toString();
              });
            });
          }
        } catch (e) {
          print('JSON Parse Error: $e');
        }
      });
    } else {
      print('ERROR MQTT connection failed');
      client!.disconnect();
    }
  }

  void _publishCommand(String device, bool isOn) {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      final commandName = '${isOn ? "on" : "off"}_${device.toLowerCase()}';
      final jsonPayload = jsonEncode({"command": commandName});
      builder.addString(jsonPayload);
      client!.publishMessage(
        'shelter/SHELTER-01/command',
        MqttQos.atLeastOnce,
        builder.payload!,
      );
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
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
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
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
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
    client?.disconnect();
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
                      style: const TextStyle(fontSize: 15, color: Colors.white70),
                    ),
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
              Text(
                '${selectedSensor.title} History',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                tooltip: 'Refresh History',
                onPressed: () => _fetchHistory(selectedSensor.key),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(sensors.length, (idx) {
                final s = sensors[idx];
                final active = _selectedSensorKey == s.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    avatar: Icon(
                      s.icon,
                      size: 16,
                      color: active ? Colors.black87 : s.color,
                    ),
                    label: Text(s.title),
                    labelStyle: TextStyle(
                      color: active ? Colors.black87 : Colors.white,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    selected: active,
                    selectedColor: s.color,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: active
                          ? s.color
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedSensorKey = s.key);
                        _fetchHistory(s.key);
                      }
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
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
                          if (historySpots.isNotEmpty) {
                            final yValues = historySpots.map((s) => s.y).toList();
                            final minYVal = yValues.reduce((a, b) => a < b ? a : b);
                            final maxYVal = yValues.reduce((a, b) => a > b ? a : b);
                            final diff = maxYVal - minYVal;
                            final padding = diff > 0 ? diff * 0.2 : (maxYVal == 0 ? 1.0 : maxYVal.abs() * 0.2);
                            computedMinY = (minYVal - padding / 2).clamp(0, double.infinity);
                            computedMaxY = maxYVal + padding;
                          }

                          return LineChart(
                            LineChartData(
                              minY: computedMinY,
                              maxY: computedMaxY,
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
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
                                    reservedSize: 24,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 &&
                                          index < historyTimeLabels.length) {
                                        int step = (historyTimeLabels.length / 5)
                                            .ceil()
                                            .clamp(1, 10);
                                        if (index % step == 0 ||
                                            index == historyTimeLabels.length - 1) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
                                            child: Text(
                                              historyTimeLabels[index],
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
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
                              borderData: FlBorderData(show: false),
                              lineTouchData: LineTouchData(
                                handleBuiltInTouches: true,
                                touchTooltipData: LineTouchTooltipData(
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true,
                                  getTooltipColor: (touchedSpot) => const Color(0xFF37474F).withValues(alpha: 0.95),
                                  tooltipBorderRadius: BorderRadius.circular(10),
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  int idx = spot.x.toInt();
                                  String time =
                                      (idx >= 0 &&
                                          idx < historyTimeLabels.length)
                                      ? historyTimeLabels[idx]
                                      : '';
                                  return LineTooltipItem(
                                    '${spot.y} ${selectedSensor.unit}\n$time',
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
                              color: selectedSensor.color,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: selectedSensor.color.withValues(
                                  alpha: 0.3,
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
  double shelterLat = -6.951613312233824;
  double shelterLng = 107.53343065982726;
  double thresholdMeters = 150.0; // default 150 meter

  MqttServerClient? client;
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
    });
    _connectMqtt();
  }

  Future<void> _loadGeofenceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shelterLat = prefs.getDouble('shelter_lat') ?? -6.951613312233824;
      shelterLng = prefs.getDouble('shelter_lng') ?? 107.53343065982726;
      thresholdMeters = prefs.getDouble('shelter_radius_m') ?? 150.0;
    });
  }

  Future<void> _saveGeofenceSettings(double lat, double lng, double radiusM) async {
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
  }

  void _showEditGeofenceDialog() {
    final latController = TextEditingController(text: shelterLat.toString());
    final lngController = TextEditingController(text: shelterLng.toString());
    final radiusController = TextEditingController(text: thresholdMeters.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E3C72),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atur Shelter & Radius',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Latitude Shelter',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lngController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Longitude Shelter',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: radiusController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Radius Geofence (Meter)',
                    helperText: 'Contoh: 150 (150 m) atau 2000 (2 km)',
                    helperStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.radar_rounded, color: Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyanAccent,
                    side: const BorderSide(color: Colors.cyanAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      final pos = await Geolocator.getCurrentPosition(
                        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
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
                  label: const Text('Gunakan GPS HP Saat Ini', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final lat = double.tryParse(latController.text.trim());
                final lng = double.tryParse(lngController.text.trim());
                final radius = double.tryParse(radiusController.text.trim());

                if (lat == null || lng == null || radius == null || radius <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Format input koordinat atau radius tidak valid!')),
                  );
                  return;
                }

                _saveGeofenceSettings(lat, lng, radius);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pengaturan Shelter & Radius (${radius >= 1000 ? "${(radius / 1000).toStringAsFixed(1)} km" : "${radius.toStringAsFixed(0)} m"}) berhasil disimpan!'),
                  ),
                );
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectMqtt() async {
    client = MqttServerClient(
      'shelter.cbinstrument.com',
      'flutter_door_${DateTime.now().millisecondsSinceEpoch}',
    );
    client!.port = 1883;
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
          'flutter_door_${DateTime.now().millisecondsSinceEpoch}',
        )
        .startClean();
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
      if (mounted) {
        setState(() {
          isConnected =
              client!.connectionStatus?.state == MqttConnectionState.connected;
        });
      }
    } catch (e) {
      print('MQTT LocationTab connect error: $e');
    }
  }

  void _publishCommand(String command) {
    final payload = jsonEncode({'command': command});
    if (client != null &&
        client!.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      client!.publishMessage(
        'shelter/SHELTER-01/command',
        MqttQos.atLeastOnce,
        builder.payload!,
      );
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
      _positionStreamSubscription = Geolocator.getPositionStream(
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
    client?.disconnect();
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
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
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
                      isConnected ? 'MQTT Online' : 'Connecting...',
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
                          horizontal: 16,
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
                            Text(
                              currentDistanceKm != null
                                  ? 'Jarak: ${(currentDistanceKm! >= 1.0 ? "${currentDistanceKm!.toStringAsFixed(2)} km" : "${(currentDistanceKm! * 1000).toStringAsFixed(0)} meter")} dari Shelter'
                                  : 'Jarak: Belum terukur (Batas: $radiusLabel)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                        InkWell(
                          onTap: _showEditGeofenceDialog,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.cyanAccent,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 13,
                                  color: Colors.cyanAccent,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Atur',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                        'MQTT Command Terakhir:',
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
class ProfileTab extends StatelessWidget {
  final String username;

  const ProfileTab({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Administrator',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('username');

                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
