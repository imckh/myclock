import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DioSingleton {
  // 私有的静态实例
  static final DioSingleton _instance = DioSingleton._internal();

  // 私有的 Dio 对象
  late Dio dio;

  // 私有的构造方法
  DioSingleton._internal() {
    dio = Dio();

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 在请求之前添加头
        // options.headers['custom-header'] = 'some-value';
        return handler.next(options); // 继续处理请求
      },
      onResponse: (response, handler) {
        // 在响应之后处理数据
        return handler.next(response); // 继续处理响应
      },
      onError: (err, handler) {
        // 处理错误
        return handler.next(err); // 继续处理错误
      },
    ));

    // 添加日志拦截器
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: true,
        filter: (options, args) {
          return true;
        }));
  }

  // 公共的工厂构造方法
  factory DioSingleton() {
    return _instance;
  }

  // 获取 Dio 对象的方法
  Dio getDio() {
    return dio;
  }
}

Future<dynamic> httpGet(String url, Map<String, dynamic> params) async {
  try {
    // 发送 GET 请求
    Response response = await DioSingleton().getDio().get(
      // Response response = await dio.get(
      url,
      queryParameters: params,
      options: Options(
        // contentType: Headers.acceptHeader,
        validateStatus: (int? status) {
          return status != null;
          // return status != null && status >= 200 && status < 300;
        }, // 自定义状态码验证逻辑
      ),
    );

    // 打印响应数据
    return response.data;
  } catch (e) {
    // 错误处理
    print('Error: $e');
    rethrow;
  }
}
