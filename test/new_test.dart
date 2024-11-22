import 'package:dio/dio.dart';
import 'package:flutter_test_project/utils/network.dart';
import 'package:http/http.dart' as http;

Future<dynamic> dioget(String url, Map<String, dynamic> params) async {
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
    throw e;
  }
}

void main() async {
  // var url = Uri.https('httpbin.org', 'put');
  // var response = await http.put(url, body: {});
  // print(response.statusCode);
  // print(response.body);
  // print('=======================');
  // url = Uri.https('httpbin.org', 'get');
  // response = await http.get(url);
  // print(response.statusCode);
  // print(response.body);

  // dio package
  // await dioget("http://httpbin.org/get", {}).then((response) {
  //   print(response);
  // });

  await httpGet("http://httpbin.org/get", {"1":  "dddd"}).then((response) {
    print(response);
  });
}
