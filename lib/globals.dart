

import 'package:dio/dio.dart';

final Dio dio = Dio();

class QWeatherVariables {
  static String scheme= 'https://';
  static String weatherHost= 'devapi.qweather.com';
  static String geoHost= 'devapi.qweather.com';
  static String port= '443';
  static String path= '/v7/weather/7d';
  static String nowPath= '/v7/weather/now';
  static String apiUrl = '$scheme$weatherHost:$port';
  static String weatherNowUrl = '$scheme$weatherHost:$port$nowPath';

  // jwt
  // alg 签名算法，请设置为EdDSA
  static String headerAlg = 'EdDSA';
  // kid 凭据ID，你可以在控制台-项目管理中查看
  static String headerKid = 'TDPPQ6G5NM';
  // sub 签发主体，这个值是凭据的项目ID，项目ID在控制台-项目管理中查看
  static String payloadSub = headerKid;


}