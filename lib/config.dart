/// =============================================================================
/// KONFIGURASI TERPUSAT BACKEND
/// =============================================================================
/// Ubah HANYA file ini untuk berpindah antara:
///   - Koneksi LAN langsung ke backend (bypass nginx)  -> useDirectLan = true
///   - Koneksi via domain/reverse proxy (nginx)         -> useDirectLan = false
///
/// Catatan: saat useDirectLan = true, HP harus berada di jaringan WiFi yang
/// sama dengan server (LAN 192.168.1.x). Ini cara paling aman untuk uji coba
/// tanpa mengganggu konfigurasi nginx di server.
/// =============================================================================
class AppConfig {
  AppConfig._();

  /// Set `true` untuk konek LANGSUNG ke IP LAN backend (tanpa nginx).
  /// Set `false` untuk konek lewat domain reverse proxy.
  static const bool useDirectLan = false;

  // --- Opsi 1: LANGSUNG ke IP LAN server (bypass nginx) ---
  static const String lanHost = '192.168.1.76';
  static const int lanPort = 1104;

  // --- Opsi 2: Lewat domain / reverse proxy (nginx) ---
  static const String domainHost = 'shelter.cbinstrument.com';

  /// Host aktif sesuai mode yang dipilih.
  static String get host => useDirectLan ? lanHost : domainHost;

  /// Base URL HTTP (REST API).
  /// - LAN langsung: http://192.168.1.76:1104
  /// - Domain:       https://shelter.cbinstrument.com
  static String get httpBase =>
      useDirectLan ? 'http://$lanHost:$lanPort' : 'https://$domainHost';

  /// Base URL WebSocket.
  /// - LAN langsung: ws://192.168.1.76:1104
  /// - Domain:       wss://shelter.cbinstrument.com
  static String get wsBase =>
      useDirectLan ? 'ws://$lanHost:$lanPort' : 'wss://$domainHost';

  // --- Endpoint helper ---
  static Uri login() => Uri.parse('$httpBase/login');
  static Uri register() => Uri.parse('$httpBase/register');

  static Uri shelters({String? tenantId}) => Uri.parse(
    tenantId != null && tenantId.isNotEmpty
        ? '$httpBase/shelters?tenant_id=$tenantId'
        : '$httpBase/shelters',
  );

  static Uri updateShelter(String shelterId) =>
      Uri.parse('$httpBase/shelters/$shelterId');

  static Uri sensorHistory(
    String sensorType,
    String shelterId, {
    int limit = 24,
  }) => Uri.parse(
    '$httpBase/sensor/history/$sensorType?shelter_id=$shelterId&limit=$limit',
  );

  static Uri wsSensors(String shelterId) =>
      Uri.parse('$wsBase/ws/sensors/$shelterId');

  static Uri uploadAvatar() => Uri.parse('$httpBase/user/avatar');

  static Uri deleteAvatar(String username) =>
      Uri.parse('$httpBase/user/avatar?username=$username');

  static String avatarUrl(String path) =>
      path.startsWith('http') ? path : '$httpBase$path';
}