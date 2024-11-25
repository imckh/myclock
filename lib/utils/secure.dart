import 'package:flutter/services.dart' show rootBundle;

Future<String> getFileStr(String path) async {
  // 1. 读取私钥
  final privateKeyString =
  await rootBundle.loadString(path);
  final privateKeyContent = privateKeyString.trim();

  return privateKeyContent;
}