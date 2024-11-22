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
        filter: (options, args){
          return true;
        }
    )
    );
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

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('requesting');
    // do something befor e request is sent
    print("${options.method} | ${options.baseUrl}  | ${options.headers} | ${options.path} | ${options.uri} | ${options.data}");
    super.onRequest(options, handler); //add this line
  }

  @override
  void onError(DioError dioError, ErrorInterceptorHandler handler) {
    handler.next(dioError);
    print('done');
    // do something to error
    super.onError(dioError, handler); //add this line
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(response.statusCode);
    print('response');
    // do something before response
    super.onResponse(response, handler);//add this line
  }
}

class APIService {
  Dio? _dio;

  final baseUrl = "http://httpbin.org/get";

  APIService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 60),
      receiveTimeout: Duration(seconds: 60),
      // headers: {'accept': 'application/json', 'Content-Type': 'application/json'}
    ));

    initializeInterceptors();
  }

  Future<Response?> getRequest(String endPoint) async {
    Response? response;

    try {
      response = await _dio?.get(endPoint);
    } on DioError catch (e) {
      print(e.message);
      throw Exception(e.message);
    }

    return response;
  }

  Future<Response?> postRequest(String endPoint, Object o) async {
    Response? response;

    try {
      response = await _dio?.post(endPoint, data: o);
    } on DioError catch (e) {
      print(e.message);
      throw Exception(e.message);
    }

    return response;
  }

  initializeInterceptors() {
    _dio?.interceptors.add(ApiInterceptors());
  }
}


Future<dynamic> httpGet(String url, Map<String, dynamic> params) async {
  try {
    // var dio = Dio();
    // dio.interceptors.add(LogInterceptor());
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
    throw e;
  }
}

Future<String> caiyunGet(String urlStr, String path, Map<String, dynamic> params) async {
  try {
    // 发送 GET 请求
    var url = Uri.https(urlStr, path);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // 打印响应数据
    return response.body;
  } catch (e) {
    // 错误处理
    print('Error: $e');
    throw e;
  }
}