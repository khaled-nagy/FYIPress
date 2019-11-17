import 'package:encrypt/encrypt.dart' as encryptor;
import 'package:NewsBuzz/utility/constants.dart';

EncryptionUnit encrypt(String target, String timeStamp) {
  final key = encryptor.Key.fromUtf8(kSecretKey);
  final iv = encryptor.IV.fromLength(16);

  final encrypter =
      encryptor.Encrypter(encryptor.AES(key, mode: encryptor.AESMode.ecb));

  final encrypted = encrypter.encrypt(target, iv: iv);

  return EncryptionUnit(encrypted.base64, timeStamp);
}

EncryptionUnit getEnc(String timeStamp) {
  return encrypt(kBaseKey + timeStamp, timeStamp);
}

String decrypt(String target) {
  final key = encryptor.Key.fromUtf8(kSecretKey);
  final iv = encryptor.IV.fromLength(16);

  final encrypter =
      encryptor.Encrypter(encryptor.AES(key, mode: encryptor.AESMode.ecb));

  return encrypter.decrypt64(target, iv: iv);
}

class EncryptionUnit {
  String body;
  String timeStamp;

  EncryptionUnit(this.body, this.timeStamp);
}
