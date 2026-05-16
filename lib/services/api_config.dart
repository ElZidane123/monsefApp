// Ganti sesuai lingkungan:
// - Emulator Android  : http://10.0.2.2:3000
// - Device fisik      : http://192.168.x.x:3000  (IP LAN komputermu)
// - iOS Simulator     : http://localhost:3000
// - Web / Desktop     : http://localhost:3000

class ApiConfig {
  static const String baseUrl = 'http://192.168.101.8:3000';


  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}