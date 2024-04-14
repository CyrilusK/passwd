import 'package:encrypt/encrypt.dart';
import 'package:passwd/pages/auth/login_page.dart';

class Encryption {
  static final IV iv = IV.allZerosOfLength(16);
  static final key = Key.fromUtf8(LoginPage.sharedData);

  String decrypt(String encrypted) {
    print("[DEBUG] - ${LoginPage.sharedData}");
    print("[DEBUG] - ${key}");
    final encrypter = Encrypter(AES(Key.fromUtf8(LoginPage.sharedData)));
    Encrypted enBase64 = Encrypted.fromBase64(encrypted);
    final decrypted = encrypter.decrypt(enBase64, iv: iv);
    return decrypted;
  }

  String encrypt(String value) {
    print("[DEBUG] - ${LoginPage.sharedData}");
    print("[DEBUG] - ${key}");
    final encrypter = Encrypter(AES(Key.fromUtf8(LoginPage.sharedData)));
    final encrypted = encrypter.encrypt(value, iv: iv);
    return encrypted.base64;
  }
}