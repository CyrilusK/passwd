import 'package:encrypt/encrypt.dart';

class Encryption {
  final IV iv;
  final Key key;

  Encryption(String password)
      : iv = IV.allZerosOfLength(16),
        key = Key.fromUtf8(password);

  String decrypt(String encrypted) {
    final encrypter = Encrypter(AES(key));
    Encrypted enBase64 = Encrypted.fromBase64(encrypted);
    final decrypted = encrypter.decrypt(enBase64, iv: iv);
    return decrypted;
  }

  String encrypt(String value) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(value, iv: iv);
    return encrypted.base64;
  }
}