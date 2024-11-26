import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../globals.dart';
import '../utils/geo.dart';
import '../utils/network.dart';
import '../utils/secure.dart';

var logger = Logger();

Future<dynamic> getCaiyunWeather(
    {Position? pos, bool alert = true, int dailysteps = 1, int hourlysteps = 24}) async {
  var respose;
  if (pos == null) {
    await determinePosition().then(
          (position) async {
        logger.d('Data fetched successfully: $position');
        await getCaiyunWeatherHttp(position, alert, dailysteps, hourlysteps).then((resp) {
          respose = parseCaiyunResp(resp);
        });
      },
      onError: (error) {
        logger.d('Error: $error');
        return 'Error: $error';
      },
    );
  } else {
    await getCaiyunWeatherHttp(pos, alert, dailysteps, hourlysteps).then((resp) {
      respose = parseCaiyunResp(resp);
    });
    return respose;
  }
}

/// XXX_08h_20h 代表白天数据
/// XXX_20h_32h 代表夜晚数据
/// XXX 代表全天数据
///
String parseCaiyunResp(dynamic resp) {
  if (resp is Map) {
    if ('ok' == resp['status'] && resp.containsKey('result')) {
      var result = resp['result'];
      String summary = '';
      if (result.containsKey('forecast_keypoint')) {
        summary += result['forecast_keypoint'];
      }
      if (result.containsKey('alert')) {

      }
      if (result.containsKey('realtime')) {

      }
      if (result.containsKey('minutely')) {

      }
      if (result.containsKey('hourly')) {

      }
      if (result.containsKey('daily')) {

      }


      return summary;
    } else {
      return resp['error'];
    }
  }
  return 'API ERROR!';
}

class WeatherCondition {
/*
主要天气现象的优先级：降雪 > 降雨 > 雾 > 沙尘 > 浮尘 > 雾霾 > 大风 > 阴 > 多云 > 晴

| 天气现象   | 代码                  | 备注                                                                          |
| ------ | ------------------- | --------------------------------------------------------------------------- |
| 晴（白天）  | CLEAR_DAY           | cloudrate < 0.2                                                             |
| 晴（夜间）  | CLEAR_NIGHT         | cloudrate < 0.2                                                             |
| 多云（白天） | PARTLY_CLOUDY_DAY   | 0.8 >= cloudrate > 0.2                                                      |
| 多云（夜间） | PARTLY_CLOUDY_NIGHT | 0.8 >= cloudrate > 0.2                                                      |
| 阴      | CLOUDY              | cloudrate > 0.8                                                             |
| 轻度雾霾   | LIGHT_HAZE          | PM2.5 100~150                                                               |
| 中度雾霾   | MODERATE_HAZE       | PM2.5 150~200                                                               |
| 重度雾霾   | HEAVY_HAZE          | PM2.5 > 200                                                                 |
| 小雨     | LIGHT_RAIN          | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 中雨     | MODERATE_RAIN       | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 大雨     | HEAVY_RAIN          | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 暴雨     | STORM_RAIN          | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 雾      | FOG                 | 能见度低，湿度高，风速低，温度低                                                            |
| 小雪     | LIGHT_SNOW          | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 中雪     | MODERATE_SNOW       | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 大雪     | HEAVY_SNOW          | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 暴雪     | STORM_SNOW          | 见[降水强度](https://docs.caiyunapp.com/weather-api/v2/v2.6/tables/precip.html) |
| 浮尘     | DUST                | AQI > 150, PM10 > 150，湿度 < 30%，风速 < 6 m/s                                   |
| 沙尘     | SAND                | AQI > 150, PM10> 150，湿度 < 30%，风速 > 6 m/s                                    |
| 大风     | WIND                |                                                                             |
 */
  late String skyconCode;
  late String skyconDesc;
  late String icon;
  late String animation; // 或者存储为 Widget
  static var map;
  WeatherCondition(this.skyconCode, this.skyconDesc, this.icon, this.animation);

  static void _init() {
    if (map != null) {
      map['CLEAR_DAY'] = WeatherCondition('CLEAR_DAY', '晴（白天）', '', '');
      map['CLEAR_NIGHT'] = WeatherCondition('CLEAR_NIGHT', '晴（夜间）', '', '');
      map['PARTLY_CLOUDY_DAY'] = WeatherCondition('PARTLY_CLOUDY_DAY', '多云（白天）', '', '');
      map['PARTLY_CLOUDY_NIGHT'] = WeatherCondition('PARTLY_CLOUDY_NIGHT', '多云（夜间）', '', '');
      map['CLOUDY'] = WeatherCondition('CLOUDY', '阴', '', '');
      map['LIGHT_HAZE'] = WeatherCondition('LIGHT_HAZE', '轻度雾霾', '', '');
      map['MODERATE_HAZE'] = WeatherCondition('MODERATE_HAZE', '中度雾霾', '', '');
      map['HEAVY_HAZE'] = WeatherCondition('HEAVY_HAZE', '重度雾霾', '', '');
      map['LIGHT_RAIN'] = WeatherCondition('LIGHT_RAIN', '小雨', '', '');
      map['MODERATE_RAIN'] = WeatherCondition('MODERATE_RAIN', '中雨', '', '');
      map['HEAVY_RAIN'] = WeatherCondition('HEAVY_RAIN', '大雨', '', '');
      map['STORM_RAIN'] = WeatherCondition('STORM_RAIN', '暴雨', '', '');
      map['FOG'] = WeatherCondition('FOG', '雾', '', '');
      map['LIGHT_SNOW'] = WeatherCondition('LIGHT_SNOW', '小雪', '', '');
      map['MODERATE_SNOW'] = WeatherCondition('MODERATE_SNOW', '中雪', '', '');
      map['HEAVY_SNOW'] = WeatherCondition('HEAVY_SNOW', '大雪', '', '');
      map['STORM_SNOW'] = WeatherCondition('STORM_SNOW', '暴雪', '', '');
      map['DUST'] = WeatherCondition('DUST', '浮尘', '', '');
      map['SAND'] = WeatherCondition('SAND', '沙尘', '', '');
      map['WIND'] = WeatherCondition('WIND', '大风', '', '');
    }
  }

  static WeatherCondition getSkyCon(String skycon) {
    _init();
    return map[skycon];
  }
}



Future<dynamic> getCaiyunWeatherHttp(Position position, bool alert, int dailysteps, int hourlysteps) async {
  var token = await getFileStr('assets/private_files/caiyun_token');
  var url = CaiyunVariables.getPositionUrl(token, position);
  var params = {
    "alert": alert,
    "dailysteps": dailysteps,
    "hourlysteps": hourlysteps,
  };
  var resp;
  // await httpGet(url, params).then((response) {
  //   logger.d(response);
  //   resp = response;
  // }).catchError((error) {
  //   print('发生错误: $error');
  // });
  String example = '''
{
  "status": "ok",
  "api_version": "v2.6",
  "api_status": "active",
  "lang": "zh_CN",
  "unit": "metric",
  "tzshift": 28800,
  "timezone": "Asia/Shanghai",
  "server_time": 1732610336,
  "location": [
    40.047986,
    116.202167
  ],
  "result": {
    "realtime": {
      "status": "ok",
      "temperature": 1.68,
      "humidity": 0.34,
      "cloudrate": 0.39,
      "skycon": "PARTLY_CLOUDY_DAY",
      "visibility": 19.69,
      "dswrf": 167.5,
      "wind": {
        "speed": 24.73,
        "direction": 312.27
      },
      "pressure": 100329.18,
      "apparent_temperature": -4.9,
      "precipitation": {
        "local": {
          "status": "ok",
          "datasource": "radar",
          "intensity": 0
        },
        "nearest": {
          "status": "ok",
          "distance": 10000,
          "intensity": 0
        }
      },
      "air_quality": {
        "pm25": 3,
        "pm10": 12,
        "o3": 57,
        "so2": 3,
        "no2": 8,
        "co": 0.2,
        "aqi": {
          "chn": 18,
          "usa": 12
        },
        "description": {
          "chn": "优",
          "usa": "优"
        }
      },
      "life_index": {
        "ultraviolet": {
          "index": 0,
          "desc": "无"
        },
        "comfort": {
          "index": 12,
          "desc": "湿冷"
        }
      }
    },
    "hourly": {
      "status": "ok",
      "description": "多云转晴，明天上午9点钟后多云",
      "precipitation": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": 0,
          "probability": 0
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": 0,
          "probability": 0
        }
      ],
      "temperature": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": 1.68
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": 0.42
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": -0.34
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": -1.1
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": -1.86
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": -2.39
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": -2.9
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": -3.2
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": -3.53
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": -3.86
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": -4.18
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": -4.27
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": -4.36
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": -4.45
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": -4.38
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": -4.31
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": -4.24
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": -2.62
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": -0.99
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": 0.63
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": 1.89
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": 3.18
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": 4.42
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": 3.46
        }
      ],
      "apparent_temperature": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": -4.9
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": -5.4
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": -6.5
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": -6.8
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": -7.9
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": -8.8
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": -9.4
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": -10.2
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": -11
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": -11.8
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": -12.2
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": -12.8
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": -13.1
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": -14.1
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": -12
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": -10.4
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": -12
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": -11
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": -9.8
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": -8
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": -5.3
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": -3.5
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": -2.3
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": -3.6
        }
      ],
      "wind": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "speed": 24.73,
          "direction": 312.27
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "speed": 18.91,
          "direction": 317.18
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "speed": 20.61,
          "direction": 307.17
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "speed": 17.8,
          "direction": 306.35
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "speed": 19.4,
          "direction": 315.42
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "speed": 21.06,
          "direction": 315.93
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "speed": 21.29,
          "direction": 315.32
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "speed": 24.48,
          "direction": 319.17
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "speed": 26.96,
          "direction": 324.14
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "speed": 29.07,
          "direction": 323.65
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "speed": 29.9,
          "direction": 324.09
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "speed": 32.66,
          "direction": 316.85
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "speed": 33.42,
          "direction": 315.86
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "speed": 38.69,
          "direction": 321.91
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "speed": 27.19,
          "direction": 307.83
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "speed": 18.62,
          "direction": 294.14
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "speed": 28.04,
          "direction": 316.46
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "speed": 32.11,
          "direction": 320.06
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "speed": 35.08,
          "direction": 317.48
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "speed": 34.7,
          "direction": 315.42
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "speed": 26.97,
          "direction": 306.55
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "speed": 24.64,
          "direction": 303.53
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "speed": 25.37,
          "direction": 296.49
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "speed": 27.19,
          "direction": 308.2
        }
      ],
      "humidity": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": 0.34
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": 0.2
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": 0.21
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": 0.19
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": 0.2
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": 0.19
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": 0.2
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": 0.21
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": 0.22
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": 0.22
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": 0.22
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": 0.23
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": 0.23
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": 0.23
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": 0.21
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": 0.21
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": 0.21
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": 0.21
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": 0.2
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": 0.21
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": 0.22
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": 0.24
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": 0.24
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": 0.26
        }
      ],
      "cloudrate": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": 0.39
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": 0.11
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": 0.14
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": 0.48
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": 0.63
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": 0.63
        }
      ],
      "skycon": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": "PARTLY_CLOUDY_DAY"
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": "WIND"
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": "WIND"
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": "WIND"
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": "CLEAR_NIGHT"
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": "CLEAR_DAY"
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": "CLEAR_DAY"
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": "CLEAR_DAY"
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": "WIND"
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": "WIND"
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": "CLEAR_DAY"
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": "PARTLY_CLOUDY_DAY"
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": "PARTLY_CLOUDY_DAY"
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": "PARTLY_CLOUDY_DAY"
        }
      ],
      "pressure": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": 100329.18
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": 100302.084
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": 100334.044
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": 100286.593
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": 100333.584
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": 100391.403
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": 100421.545
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": 100461.618
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": 100463.349
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": 100445.94
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": 100455.138
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": 100437.77
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": 100412.298
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": 100335.211
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": 100346.157
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": 100402.653
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": 100410.367
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": 100348.444
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": 100324.628
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": 100338.666
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": 100208.988
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": 100081.534
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": 99997.651
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": 99950.878
        }
      ],
      "visibility": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": 19.68
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": 19.65
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": 19.63
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": 19.63
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": 19.64
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": 19.64
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": 19.64
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": 19.65
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": 19.65
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": 19.65
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": 19.66
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": 19.66
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": 19.68
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": 19.69
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": 19.69
        }
      ],
      "dswrf": [
        {
          "datetime": "2024-11-26T16:00+08:00",
          "value": 167.48
        },
        {
          "datetime": "2024-11-26T17:00+08:00",
          "value": 125.628
        },
        {
          "datetime": "2024-11-26T18:00+08:00",
          "value": 99.711
        },
        {
          "datetime": "2024-11-26T19:00+08:00",
          "value": 83.727
        },
        {
          "datetime": "2024-11-26T20:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T21:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T22:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-26T23:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T00:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T01:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T02:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T03:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T04:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T05:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T06:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T07:00+08:00",
          "value": 0
        },
        {
          "datetime": "2024-11-27T08:00+08:00",
          "value": 157.405
        },
        {
          "datetime": "2024-11-27T09:00+08:00",
          "value": 233.298
        },
        {
          "datetime": "2024-11-27T10:00+08:00",
          "value": 296.22
        },
        {
          "datetime": "2024-11-27T11:00+08:00",
          "value": 342.194
        },
        {
          "datetime": "2024-11-27T12:00+08:00",
          "value": 370.158
        },
        {
          "datetime": "2024-11-27T13:00+08:00",
          "value": 378.186
        },
        {
          "datetime": "2024-11-27T14:00+08:00",
          "value": 312.228
        },
        {
          "datetime": "2024-11-27T15:00+08:00",
          "value": 238.336
        }
      ],
      "air_quality": {
        "aqi": [
          {
            "datetime": "2024-11-26T16:00+08:00",
            "value": {
              "chn": 18,
              "usa": 12
            }
          },
          {
            "datetime": "2024-11-26T17:00+08:00",
            "value": {
              "chn": 29,
              "usa": 18
            }
          },
          {
            "datetime": "2024-11-26T18:00+08:00",
            "value": {
              "chn": 32,
              "usa": 22
            }
          },
          {
            "datetime": "2024-11-26T19:00+08:00",
            "value": {
              "chn": 35,
              "usa": 22
            }
          },
          {
            "datetime": "2024-11-26T20:00+08:00",
            "value": {
              "chn": 36,
              "usa": 22
            }
          },
          {
            "datetime": "2024-11-26T21:00+08:00",
            "value": {
              "chn": 38,
              "usa": 26
            }
          },
          {
            "datetime": "2024-11-26T22:00+08:00",
            "value": {
              "chn": 39,
              "usa": 26
            }
          },
          {
            "datetime": "2024-11-26T23:00+08:00",
            "value": {
              "chn": 39,
              "usa": 26
            }
          },
          {
            "datetime": "2024-11-27T00:00+08:00",
            "value": {
              "chn": 39,
              "usa": 26
            }
          },
          {
            "datetime": "2024-11-27T01:00+08:00",
            "value": {
              "chn": 38,
              "usa": 22
            }
          },
          {
            "datetime": "2024-11-27T02:00+08:00",
            "value": {
              "chn": 38,
              "usa": 22
            }
          },
          {
            "datetime": "2024-11-27T03:00+08:00",
            "value": {
              "chn": 37,
              "usa": 22
            }
          },
          {
            "datetime": "2024-11-27T04:00+08:00",
            "value": {
              "chn": 37,
              "usa": 18
            }
          },
          {
            "datetime": "2024-11-27T05:00+08:00",
            "value": {
              "chn": 37,
              "usa": 18
            }
          },
          {
            "datetime": "2024-11-27T06:00+08:00",
            "value": {
              "chn": 37,
              "usa": 18
            }
          },
          {
            "datetime": "2024-11-27T07:00+08:00",
            "value": {
              "chn": 37,
              "usa": 14
            }
          },
          {
            "datetime": "2024-11-27T08:00+08:00",
            "value": {
              "chn": 38,
              "usa": 14
            }
          },
          {
            "datetime": "2024-11-27T09:00+08:00",
            "value": {
              "chn": 39,
              "usa": 14
            }
          },
          {
            "datetime": "2024-11-27T10:00+08:00",
            "value": {
              "chn": 41,
              "usa": 14
            }
          },
          {
            "datetime": "2024-11-27T11:00+08:00",
            "value": {
              "chn": 43,
              "usa": 14
            }
          },
          {
            "datetime": "2024-11-27T12:00+08:00",
            "value": {
              "chn": 46,
              "usa": 14
            }
          },
          {
            "datetime": "2024-11-27T13:00+08:00",
            "value": {
              "chn": 48,
              "usa": 18
            }
          },
          {
            "datetime": "2024-11-27T14:00+08:00",
            "value": {
              "chn": 49,
              "usa": 18
            }
          },
          {
            "datetime": "2024-11-27T15:00+08:00",
            "value": {
              "chn": 50,
              "usa": 22
            }
          }
        ],
        "pm25": [
          {
            "datetime": "2024-11-26T16:00+08:00",
            "value": 3
          },
          {
            "datetime": "2024-11-26T17:00+08:00",
            "value": 4
          },
          {
            "datetime": "2024-11-26T18:00+08:00",
            "value": 5
          },
          {
            "datetime": "2024-11-26T19:00+08:00",
            "value": 5
          },
          {
            "datetime": "2024-11-26T20:00+08:00",
            "value": 5
          },
          {
            "datetime": "2024-11-26T21:00+08:00",
            "value": 6
          },
          {
            "datetime": "2024-11-26T22:00+08:00",
            "value": 6
          },
          {
            "datetime": "2024-11-26T23:00+08:00",
            "value": 6
          },
          {
            "datetime": "2024-11-27T00:00+08:00",
            "value": 6
          },
          {
            "datetime": "2024-11-27T01:00+08:00",
            "value": 5
          },
          {
            "datetime": "2024-11-27T02:00+08:00",
            "value": 5
          },
          {
            "datetime": "2024-11-27T03:00+08:00",
            "value": 5
          },
          {
            "datetime": "2024-11-27T04:00+08:00",
            "value": 4
          },
          {
            "datetime": "2024-11-27T05:00+08:00",
            "value": 4
          },
          {
            "datetime": "2024-11-27T06:00+08:00",
            "value": 4
          },
          {
            "datetime": "2024-11-27T07:00+08:00",
            "value": 3
          },
          {
            "datetime": "2024-11-27T08:00+08:00",
            "value": 3
          },
          {
            "datetime": "2024-11-27T09:00+08:00",
            "value": 3
          },
          {
            "datetime": "2024-11-27T10:00+08:00",
            "value": 3
          },
          {
            "datetime": "2024-11-27T11:00+08:00",
            "value": 3
          },
          {
            "datetime": "2024-11-27T12:00+08:00",
            "value": 3
          },
          {
            "datetime": "2024-11-27T13:00+08:00",
            "value": 4
          },
          {
            "datetime": "2024-11-27T14:00+08:00",
            "value": 4
          },
          {
            "datetime": "2024-11-27T15:00+08:00",
            "value": 5
          }
        ]
      }
    },
    "daily": {
      "status": "ok",
      "astro": [
        {
          "date": "2024-11-26T00:00+08:00",
          "sunrise": {
            "time": "07:12"
          },
          "sunset": {
            "time": "16:52"
          }
        }
      ],
      "precipitation_08h_20h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 0,
          "min": 0,
          "avg": 0,
          "probability": 0
        }
      ],
      "precipitation_20h_32h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 0,
          "min": 0,
          "avg": 0,
          "probability": 0
        }
      ],
      "precipitation": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 0,
          "min": 0,
          "avg": 0,
          "probability": 0
        }
      ],
      "temperature": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 3.17,
          "min": -3.2,
          "avg": -1.21
        }
      ],
      "temperature_08h_20h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 3.17,
          "min": -1.95,
          "avg": 0.72
        }
      ],
      "temperature_20h_32h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": -1.1,
          "min": -4.45,
          "avg": -3.37
        }
      ],
      "wind": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": {
            "speed": 32.19,
            "direction": 317.08
          },
          "min": {
            "speed": 17.8,
            "direction": 306.35
          },
          "avg": {
            "speed": 24.24,
            "direction": 316.58
          }
        }
      ],
      "wind_08h_20h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": {
            "speed": 24.73,
            "direction": 312.27
          },
          "min": {
            "speed": 18.91,
            "direction": 317.18
          },
          "avg": {
            "speed": 22.02,
            "direction": 315.97
          }
        }
      ],
      "wind_20h_32h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": {
            "speed": 38.69,
            "direction": 321.91
          },
          "min": {
            "speed": 17.8,
            "direction": 306.35
          },
          "avg": {
            "speed": 26.83,
            "direction": 317.84
          }
        }
      ],
      "humidity": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 0.34,
          "min": 0.19,
          "avg": 0.22
        }
      ],
      "cloudrate": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 1,
          "min": 0,
          "avg": 0.06
        }
      ],
      "pressure": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 100976.02,
          "min": 100286.59,
          "avg": 100357.51
        }
      ],
      "visibility": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 24.14,
          "min": 19.63,
          "avg": 19.66
        }
      ],
      "dswrf": [
        {
          "date": "2024-11-26T00:00+08:00",
          "max": 345.2,
          "min": 0,
          "avg": 59.6
        }
      ],
      "air_quality": {
        "aqi": [
          {
            "date": "2024-11-26T00:00+08:00",
            "max": {
              "chn": 39,
              "usa": 26
            },
            "avg": {
              "chn": 33,
              "usa": 22
            },
            "min": {
              "chn": 18,
              "usa": 12
            }
          }
        ],
        "pm25": [
          {
            "date": "2024-11-26T00:00+08:00",
            "max": 6,
            "avg": 5,
            "min": 3
          }
        ]
      },
      "skycon": [
        {
          "date": "2024-11-26T00:00+08:00",
          "value": "CLEAR_DAY"
        }
      ],
      "skycon_08h_20h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "value": "PARTLY_CLOUDY_DAY"
        }
      ],
      "skycon_20h_32h": [
        {
          "date": "2024-11-26T00:00+08:00",
          "value": "CLEAR_NIGHT"
        }
      ],
      "life_index": {
        "ultraviolet": [
          {
            "date": "2024-11-26T00:00+08:00",
            "index": "1",
            "desc": "最弱"
          }
        ],
        "carWashing": [
          {
            "date": "2024-11-26T00:00+08:00",
            "index": "1",
            "desc": "适宜"
          }
        ],
        "dressing": [
          {
            "date": "2024-11-26T00:00+08:00",
            "index": "8",
            "desc": "极冷"
          }
        ],
        "comfort": [
          {
            "date": "2024-11-26T00:00+08:00",
            "index": "12",
            "desc": "湿冷"
          }
        ],
        "coldRisk": [
          {
            "date": "2024-11-26T00:00+08:00",
            "index": "3",
            "desc": "易发"
          }
        ]
      }
    },
    "primary": 0,
    "forecast_keypoint": "多云转晴，明天上午9点钟后多云"
  }
}
  ''';
  resp = jsonDecode(example);;
  return resp;
}
