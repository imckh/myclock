import 'package:geolocator/geolocator.dart';

class QWeatherVariables {
  // jwt
  // alg 签名算法，请设置为EdDSA
  static String headerAlg = 'EdDSA';

  // kid 凭据ID，你可以在控制台-项目管理中查看
  static String headerKid = 'KMGTPN7XB6';

  // sub 签发主体，这个值是凭据的项目ID，项目ID在控制台-项目管理中查看
  static String payloadSub = headerKid;
  static String cityLookUp = 'https://geoapi.qweather.com/v2/city/lookup';
  static String weather24h = 'https://devapi.qweather.com/v7/weather/24h';
}

class CaiyunVariables {
  static String host = 'https://api.caiyunapp.com/v2.6';
  // static String host = 'https://www.github.com/v2.6';
  static String realtime = 'realtime';
  static String minutely = 'minutely';
  static String daily = 'daily';
  static String dailysteps = 'dailysteps';

  // 支持打包 realtime, minutely, hourly, daily 及 alert 数据
  static String weather = 'weather';

  static String getPositionUrl(String token, Position pos) {
    // pos.longitude 经度
    // pos.latitude 纬度
    return '${host}/${token}X/${pos.longitude},${pos.latitude}/${realtime}';
    // return 'https://httpbin.org/get';
  }
}