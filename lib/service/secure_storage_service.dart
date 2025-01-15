import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Default constructor
  SecureStorageService();

  // Write data to secure storage
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read data from secure storage
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete a specific key from secure storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Delete all keys from secure storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
