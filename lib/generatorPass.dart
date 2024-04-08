import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

String generatePassword(String website, String masterPassword) {
  const salt = '50v;@z[d';
  List<String> dictionary = [
    'mecheniy', 'napudrit', 'viezd', 'pribit', 'tushenka', 'zagorod', 'ognebur', 'vpolzti', 'skvoz', 'upir'
  ];

  // Шаг 2: Добавляем мастер-пароль в зашифрованном виде
  String encryptedMasterPassword = md5.convert(utf8.encode(masterPassword)).toString();

  // Шаг 3: Добавляем случайное слово из словаря
  Random random = Random();
  String secretWord = dictionary[random.nextInt(dictionary.length)];

  // Шаг 1 и 4: Объединяем адрес сайта, зашифрованный мастер-пароль, секретное слово и соль
  String combinedString = secretWord + encryptedMasterPassword + website + salt;

  return capitalizeRandom(combinedString);
}

String capitalizeRandom(String input) {
  double probability = 0.4333;
  Random random = Random();
  StringBuffer result = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    if (random.nextDouble() < probability) {
      result.write(input[i].toUpperCase());
    } else {
      result.write(input[i]);
    }
  }
  return result.toString();
}
