import 'dart:convert';
import 'package:passwd/pages/auth/login_page.dart';
import 'package:passwd/pages/auth/signup_page.dart';

class Kuznechik {

  String xorFunc(String input1AsString, String input2AsString, {int inCode = 16}){
    BigInt input1AsInteger = BigInt.parse(input1AsString, radix: inCode);
    BigInt input2AsInteger = BigInt.parse(input2AsString, radix: inCode);
    BigInt result = input1AsInteger ^ input2AsInteger;
    String resultAsHex = result.toRadixString(16);
    resultAsHex = resultAsHex.toUpperCase();
    if (resultAsHex.length != input1AsString.length){
      for (int i = 0;i<=input1AsString.length - resultAsHex.length ;i++){
        resultAsHex = '0$resultAsHex';
      }
    }
    return resultAsHex;
  }
/* Пример:
void main(){
  print(xorFunc('101', '1110', inCode: 2)); //00B
}*/

  String convertBase(var num, {int toBase = 10, int fromBase = 10}) {
    int n;
    if (num is String) {
      n = int.parse(num, radix: fromBase);
    } else {
      n = num as int;
    }
    String alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    if (n < toBase) {
      return alphabet[n];
    } else {
      return convertBase(n ~/ toBase, toBase: toBase) + alphabet[n % toBase];
    }
  }
/* Пример:
void main(){
  print(convertBase('AC', fromBase: 16)); //172
}*/

  List<int> galuaCoef = [148, 32, 133, 16, 194, 192, 1, 251, 1, 192, 194, 16, 133, 32, 148, 1];
  List<int> galuaCoefReverse = [1, 148, 32, 133, 16, 194, 192, 1, 251, 1, 192, 194, 16, 133, 32, 148];
  List<int> galuaFields = [1, 2, 4, 8, 16, 32, 64, 128, 195, 69, 138, 215, 109, 218, 119, 238, 31, 62, 124, 248, 51, 102, 204, 91, 182, 175, 157, 249, 49, 98, 196, 75, 150, 239, 29, 58, 116, 232, 19, 38, 76, 152, 243, 37, 74, 148, 235, 21, 42, 84, 168, 147, 229, 9, 18, 36, 72, 144, 227, 5, 10, 20, 40, 80, 160, 131, 197, 73, 146, 231, 13, 26, 52, 104, 208, 99, 198, 79, 158, 255, 61, 122, 244, 43, 86, 172, 155, 245, 41, 82, 164, 139, 213, 105, 210, 103, 206, 95, 190, 191, 189, 185, 177, 161, 129, 193, 65, 130, 199, 77, 154, 247, 45, 90, 180, 171, 149, 233, 17, 34, 68, 136, 211, 101, 202, 87, 174, 159, 253, 57, 114, 228, 11, 22, 44, 88, 176, 163, 133, 201, 81, 162, 135, 205, 89, 178, 167, 141, 217, 113, 226, 7, 14, 28, 56, 112, 224, 3, 6, 12, 24, 48, 96, 192, 67, 134, 207, 93, 186, 183, 173, 153, 241, 33, 66, 132, 203, 85, 170, 151, 237, 25, 50, 100, 200, 83, 166, 143, 221, 121, 242, 39, 78, 156, 251, 53, 106, 212, 107, 214, 111, 222, 127, 254, 63, 126, 252, 59, 118, 236, 27, 54, 108, 216, 115, 230, 15, 30, 60, 120, 240, 35, 70, 140, 219, 117, 234, 23, 46, 92, 184, 179, 165, 137, 209, 97, 194, 71, 142, 223, 125, 250, 55, 110, 220, 123, 246, 47, 94, 188, 187, 181, 169, 145, 225, 1];

  linearTransformation(var num, {move = 'straight'}){
    int numIfNull = 257;
    for (int i = 0; i<16; i++){
      List<int> coefs = [];
      List<int> nums = [];
      for (int j = 0; j < galuaCoef.length; j++) {
        if (move == 'reverse') {
          coefs.add(galuaFields.indexOf(galuaCoefReverse[galuaCoefReverse.length - j - 1]));
        } else {
          coefs.add(galuaFields.indexOf(galuaCoef[galuaCoef.length - j - 1]));
        }

        if (j * 2 + 2 <= num.length) {
          String numSlice = num.substring(j * 2, j * 2 + 2);
          if (int.parse(convertBase(numSlice, fromBase: 16)) == 0) {
            nums.add(numIfNull);
          } else {
            nums.add(galuaFields.indexOf(int.parse(convertBase(numSlice, fromBase: 16))));
          }
        } else {
          nums.add(numIfNull);
        }
      }

      List<int> galua = [];

      for (var j = 0; j < galuaCoef.length; j++) {
        if (nums[j] != numIfNull) {
          if (nums[j] + coefs[j] <= 255) {
            galua.add(galuaFields[nums[j] + coefs[j]]);
          } else {
            galua.add(galuaFields[(nums[j] + coefs[j]) % 255]);
          }
        }
      }

      int galuaNum = galua[0];
      if (galua.length != 1) {
        for (int j = 0; j < galua.length - 1; j++) {
          galuaNum = int.parse(xorFunc(galuaNum.toString(), (galua[j + 1]).toString(), inCode: 10), radix: 16) % 256;
        }
      }
      String result = (galuaNum.toRadixString(16)).toString();
      if (result.length == 1) {
        result = '0$result';
      }
      if (move == 'reverse') {
        num = result + num.substring(0, num.length - 2);
      } else {
        num = num.substring(2) + result;
      }
    }
    return num;
  }
/* Пример:
void main(){
  print(linearTransformation('020000000000000000000000000000010')); //0969ee383046e6c3e0b4e8a3d65d701ef
}*/

  List<int> nonlinearCoef = [252, 238, 221, 17, 207, 110, 49, 22, 251, 196, 250, 218, 35, 197, 4, 77, 233, 119, 240, 219, 147, 46, 153, 186, 23, 54, 241, 187, 20, 205, 95, 193, 249, 24, 101, 90, 226, 92, 239, 33, 129, 28, 60, 66, 139, 1, 142, 79, 5, 132, 2, 174, 227, 106, 143, 160, 6, 11, 237, 152, 127, 212, 211, 31, 235, 52, 44, 81, 234, 200, 72, 171, 242, 42, 104, 162, 253, 58, 206, 204, 181, 112, 14, 86, 8, 12, 118, 18, 191, 114, 19, 71, 156, 183, 93, 135, 21, 161, 150, 41, 16, 123, 154, 199, 243, 145, 120, 111, 157, 158, 178, 177, 50, 117, 25, 61, 255, 53, 138, 126, 109, 84, 198, 128, 195, 189, 13, 87, 223, 245, 36, 169, 62, 168, 67, 201, 215, 121, 214, 246, 124, 34, 185, 3, 224, 15, 236, 222, 122, 148, 176, 188, 220, 232, 40, 80, 78, 51, 10, 74, 167, 151, 96, 115, 30, 0, 98, 68, 26, 184, 56, 130, 100, 159, 38, 65, 173, 69, 70, 146, 39, 94, 85, 47, 140, 163, 165, 125, 105, 213, 149, 59, 7, 88, 179, 64, 134, 172, 29, 247, 48, 55, 107, 228, 136, 217, 231, 137, 225, 27, 131, 73, 76, 63, 248, 254, 141, 83, 170, 144, 202, 216, 133, 97, 32, 113, 103, 164, 45, 43, 9, 91, 203, 155, 37, 208, 190, 229, 108, 82, 89, 166, 116, 210, 230, 244, 180, 192, 209, 102, 175, 194, 57, 75, 99, 182];
  List<int> nonlinearCoefReverse = [165, 45, 50, 143, 14, 48, 56, 192, 84, 230, 158, 57, 85, 126, 82, 145, 100, 3, 87, 90, 28, 96, 7, 24, 33, 114, 168, 209, 41, 198, 164, 63, 224, 39, 141, 12, 130, 234, 174, 180, 154, 99, 73, 229, 66, 228, 21, 183, 200, 6, 112, 157, 65, 117, 25, 201, 170, 252, 77, 191, 42, 115, 132, 213, 195, 175, 43, 134, 167, 177, 178, 91, 70, 211, 159, 253, 212, 15, 156, 47, 155, 67, 239, 217, 121, 182, 83, 127, 193, 240, 35, 231, 37, 94, 181, 30, 162, 223, 166, 254, 172, 34, 249, 226, 74, 188, 53, 202, 238, 120, 5, 107, 81, 225, 89, 163, 242, 113, 86, 17, 106, 137, 148, 101, 140, 187, 119, 60, 123, 40, 171, 210, 49, 222, 196, 95, 204, 207, 118, 44, 184, 216, 46, 54, 219, 105, 179, 20, 149, 190, 98, 161, 59, 22, 102, 233, 92, 108, 109, 173, 55, 97, 75, 185, 227, 186, 241, 160, 133, 131, 218, 71, 197, 176, 51, 250, 150, 111, 110, 194, 246, 80, 255, 93, 169, 142, 23, 27, 151, 125, 236, 88, 247, 31, 251, 124, 9, 13, 122, 103, 69, 135, 220, 232, 79, 29, 78, 4, 235, 248, 243, 62, 61, 189, 138, 136, 221, 205, 11, 19, 152, 2, 147, 128, 144, 208, 36, 52, 203, 237, 244, 206, 153, 16, 68, 64, 146, 58, 1, 38, 18, 26, 72, 104, 245, 129, 139, 199, 214, 32, 10, 8, 0, 76, 215, 116];

  nonlinearTransformation(var num, {move = 'straight'}){
    for (int i = 0; i < 16; i++){
      List<int> nonlinearTable;
      if (move == 'reverse'){
        nonlinearTable = nonlinearCoefReverse;
      }else{
        nonlinearTable = nonlinearCoef;
      }
      String numForReplace = num.substring(i * 2, i * 2 + 2);
      String convertNum = convertBase(numForReplace, toBase: 10, fromBase: 16);
      numForReplace = convertBase(nonlinearTable[int.parse(convertNum)], toBase: 16, fromBase: 10);
      if (numForReplace.length == 1){
        numForReplace = '0$numForReplace';
      }
      num = num.substring(0, i * 2) + numForReplace + num.substring(i * 2 + 2);
    }
    return num;
  }
/*Пример:
void main(){
  print(nonlinearTransformation('76F2D199239F365D479495A0C9DC3BE6', move : 'reverse'));//5648F8160CAD195E5B95BE378798BFF4
}*/
  String utf8ToHex(String text) {
    List<int> bytes = utf8.encode(text);
    String hexText = bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
    return hexText;
  }
/*Пример:
void main(){
  print(utf8ToHex("hello"));//68656c6c6f
}*/
  String transformKey(String key) {
    List<int> bytes = utf8.encode(key);
    String keyHex = bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
    int count = 64 - keyHex.length % 64;
    while (keyHex.length < 64) {
      keyHex += keyHex;
    }
    return keyHex.substring(0, 64);
  }
/*Пример:
void main(){
  print(transformKey("7766554433221100FFEEDDCCBBAA9988EFCDAB89674523011032547698BADCFE"));//3737363635353434333332323131303046464545444443434242414139393838
}*/
  String hexToUtf8(String text) {
    text = text.replaceAll('00', '');
    List<int> bytes = List.generate(text.length ~/ 2, (index) => int.parse(text.substring(index * 2, index * 2 + 2), radix: 16));
    String utf8Text = utf8.decode(bytes);
    return utf8Text;
  }
/*Пример:
void main(){
  print(hexToUtf8("3737363635353434333332323131303046464545444443434242414139393838"));//7766554433221100FFEEDDCCBBAA9988
}*/
  List<String> getKeys() {
    String key = LoginPage.sharedData.isNotEmpty ? LoginPage.sharedData : RegisterPage.sharedData;
    if (key.isEmpty) {
      print("[DEBUG] - Invalid key for decryption");
      return [];
    }
    key = transformKey(key);
    List<String> C = []; // константы
    List<List<String>> F = []; // ячейки Фейстеля
    List<String> K = [key.substring(0, key.length ~/ 2), key.substring(key.length ~/ 2)];

    for (var i = 0; i < 32; i++) {
      String hex = (i+1).toRadixString(16);
      if (hex.length == 1) {
        C.add(linearTransformation('0${hex}000000000000000000000000000000').toUpperCase());
      } else {
        C.add(linearTransformation('${hex}000000000000000000000000000000').toUpperCase());
      }
    }

    F.add([K[1], xorFunc(linearTransformation(nonlinearTransformation(xorFunc(K[0], C[0]))), K[1])]);

    for (int i = 0; i < 32; i++) {
      K = [F[i][1], xorFunc(linearTransformation(nonlinearTransformation(xorFunc(F[i][0], C[i]))), F[i][1])];
      F.add(K);
    }
    K = [key.substring(0, key.length ~/ 2), key.substring(key.length ~/ 2)];
    for (int i = 0; i < F.length; i++) {
      if ((i + 1) % 8 == 0) {
        K.add(F[i][0]);
        K.add(F[i][1]);
      }
    }
    return K;
  }
/*Пример:
void main(){
  print(getKeys("123"));//[31323331323331323331323331323331, 32333132333132333132333132333132, 21930678FA4DE35F5B3A864DD4C05622, 6CC0820702407CBC97FEB0004B17AEDE, 4B934C3CC2AA4DE593DFCD4149FB522E, 34AEF6B203FCE475AFEEF40411DB4580, 964F0804CB6FD73A2F144CCC4F041FD5, 23EBCBCE21C8A444AB58BA5B03BFAC37, 796F61330768CC43FC4F0352266D4D98, 0304EDE60F8A2B9A4BAE703AE07684FE]
}*/

  String encrypt(String text) {
    List<String> K = getKeys();

    if (K.isEmpty) {
      throw StateError('Invalid key');
    }

    text = utf8ToHex(text);

    int count = 32 - text.length % 32;
    if (count != 0 && count != 32) {
      text += '0' * count;
    }
    List<String> textArray = [];
    for (int i = 0; i < text.length ~/ 32; i++) {
      textArray.add(text.substring(i * 32, i * 32 + 32));
    }

    List<String> textEncrypt = [];
    for (String j in textArray) {
      String textEncrypted = j;
      for (int i = 0; i < 9; i++) {
        textEncrypted = linearTransformation(nonlinearTransformation(xorFunc(textEncrypted, K[i] as String)));
      }
      textEncrypted = xorFunc(textEncrypted, K[9] as String);
      textEncrypt.add(textEncrypted);
    }
    return textEncrypt.join('');
  }

  String decrypt(String text) {
    List<String> K = getKeys();
    if (K.isEmpty) {
      throw StateError('Invalid key');
    }
    List<String> textArray = [];
    for (int i = 0; i < (text.length ~/ 32); i++) {
      textArray.add(text.substring(i * 32, i * 32 + 32));
    }

    List<String> textDecrypt = [];
    for (String j in textArray) {
      String textDecrypted = j;
      for (int i = 9; i > 0; i--) {
        textDecrypted = nonlinearTransformation(linearTransformation(xorFunc(textDecrypted, K[i]), move:'reverse'), move:'reverse');
      }
      textDecrypted = xorFunc(textDecrypted, K[0]);
      textDecrypt.add(textDecrypted);
    }
    return hexToUtf8(textDecrypt.join(''));
  }
}