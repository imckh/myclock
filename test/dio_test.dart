import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_project/globals.dart';

void main() {
  dio.interceptors.add(
    LogInterceptor(
      logPrint: (o) => print(o.toString()),
    ),
  );

  Future<void> request() async {
    print('request');
    await dio.get<String>('https://httpbin.org/get').then((r) {
      print(r.data);
    }).onError((e, r) {
      print(e);
    }).whenComplete(() => print('request end'));
  }

  Future<void> request2() async {
    print('request');
    try {
      final response = await dio.get<String>('https://httpbin.org/get');
      print(response.data);
    } catch (e) {
      print(e);
    } finally {
      print('request end');
    }
  }

  test('一个极简的示例', () async {
    print("object");
    await request().whenComplete(() => print('无论成功与否，我都会被执行'));
  });

  Future<String> generateJWT() async {
    // 1. 读取私钥
    final privateKeyString =
    await rootBundle.loadString('assets/private_files/ed25519-private.pem');
    final privateKeyContent = privateKeyString
        .split('\n') // 按行分割
        .where((line) =>
    !line.startsWith('-----BEGIN PRIVATE KEY-----') && // 过滤头部
        !line.startsWith('-----END PRIVATE KEY-----')) // 过滤尾部
        .join(); // 将剩下的内容合并
    final privateKeyBytes = utf8.encode(privateKeyContent);

    // 2. 设置签发时间和过期时间
    final iat = DateTime
        .now()
        .subtract(Duration(seconds: 30))
        .millisecondsSinceEpoch ~/ 1000;
    final exp = DateTime
        .now()
        .add(Duration(hours: 24))
        .millisecondsSinceEpoch ~/ 1000;

    // 3. 创建 JWT 的 Header 和 Payload
    final jwt = JWT(
      {
        'sub': QWeatherVariables.payloadSub,
        'iat': iat,
        'exp': exp,
      },
      header: {
        'alg': JWTAlgorithm.EdDSA.name,
        'kid': QWeatherVariables.headerKid,
      },
    );

    // 4. 使用 EdDSA 签名并生成 Token
    final token = jwt.sign(EdDSAPrivateKey(privateKeyBytes),
        algorithm: JWTAlgorithm.EdDSA);

    return token;
  }

  Future<String> qweatherRequest(String url, String jwt_token, Map<String, dynamic> params) async {
    // 创建一个 Dio 实例

    // 设置请求选项
    final Map<String, String> headers = {
      'Authorization': 'Bearer $jwt_token',
    };

    try {
      // 发送 GET 请求
      Response response = await dio.get(
        url,
        queryParameters: params,
        options: Options(
          headers: headers,
          responseType: ResponseType.plain,
          validateStatus: (status) => status! < 500, // 自定义状态码验证逻辑
        ),
      );

      // 打印响应数据
      return response.data;
    } catch (e) {
      // 错误处理
      print('Error: $e');
      throw e;
    }
  }

  // 初始化 Flutter 的绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  test('jwt测试', () async {
    await generateJWT().then((token) async {
      final Map<String, dynamic> queryParameters = {
        'location': '101010100',
      };
      print('JWT: $token');
      await qweatherRequest(QWeatherVariables.weatherNowUrl, token, queryParameters).then((response) {
        print(response);
      });
    });
  });
}
