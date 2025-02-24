import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_project/globals.dart';
import 'package:flutter_test_project/utils/network.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  Future<void> request() async {
    print('request');
    await DioSingleton()
        .getDio()
        .get<String>('https://httpbin.org/get')
        .then((r) {
      print(r.data);
    }).onError((e, r) {
      print(e);
    }).whenComplete(() => print('request end'));
  }

  Future<void> request2() async {
    print('request');
    try {
      final response =
          await DioSingleton().getDio().get<String>('https://httpbin.org/get');
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

  Future<String> getToken() async {
    // 1. 读取私钥
    final privateKeyString =
        await rootBundle.loadString('assets/private_files/caiyun_token');
    final privateKeyContent = privateKeyString.trim();

    return privateKeyContent;
  }

  Future<String> getLocation() async {
    String defaultLoc = '116.3176,39.9760';
    try {
      // 请求位置权限
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return defaultLoc;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            "Location permissions are permanently denied, we cannot request permissions.");
        return defaultLoc;
      }

      // 获取当前位置
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return "${position.longitude},${position.latitude}";
    } catch (e) {
      // return 'Failed to get location: $e';
      print('Failed to get location: $e');
      return defaultLoc;
    }
  }

  // 初始化 Flutter 的绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  test('jwt测试', () async {
    await getToken().then((token) async {
      print('token: $token');
      final Map<String, dynamic> queryParameters = {
        'alert': 'true',
        'dailysteps': '2',
        'hourlysteps': '24',
        'token': token
      };
      String location = await getLocation();
      String url =
          "${CaiyunVariables.host}/$location/${CaiyunVariables.weather}";
      url = "httpbin.org";
      String path = "get";
      await httpGet("$url/$path", {}).then((response) {
        print(response);
      });
      // await caiyunGet(url, path, {}).then((response) {
      //   print(response);
      // });
      // APIService apiservice = APIService();
      // await apiservice.getRequest("http://httpbin.org/get").then((response) {
      //   print(response);
      // });
    });
  });

  Future<String> httpget(
      String urlStr, String path, Map<String, dynamic> params) async {
    try {
      var url = Uri.https(urlStr, path);
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response header: ${response.headers}');

      return response.body;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<dynamic> dioget2(String url, Map<String, dynamic> params) async {
    try {
      var dio = Dio();
      dio.interceptors.add(LogInterceptor());
      Response response = await dio.get(
        url,
        queryParameters: params,
        options: Options(
          validateStatus: (int? status) {
            return status != null;
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> dioget(String url, Map<String, dynamic> params) async {
    try {
      var dio = Dio();
      dio.interceptors.add(LogInterceptor());
      Response response = await dio.get(
        url,
        queryParameters: params,
        options: Options(
          validateStatus: (int? status) {
            return status != null;
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // final dioAdapter = DioAdapter(dio: dio);
  test('network test', () async {
    // http package
    // String url = "httpbin.org";
    // String path = "get";
    // await httpget(url, path, {}).then((response) {
    //   print(response);
    // });

    // dio package
    await httpGet("http://httpbin.org/get", {}).then((response) {
      print(response);
    });

    // dio package
    // await dioget2("http://httpbin.org/get", {}).then((response) {
    //   print(response);
    // });
  });
}
