import 'package:flutter/services.dart' show rootBundle;

Future<String> getToken() async {
  // 1. 读取私钥
  final privateKeyString =
  await rootBundle.loadString('assets/private_files/caiyun_token');
  final privateKeyContent = privateKeyString.trim();

  return privateKeyContent;
}