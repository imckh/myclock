import 'package:flutter/foundation.dart';
import 'dart:async';
import '../utils/geo.dart';
import 'caiyun_weather_utils.dart';
import 'package:geolocator/geolocator.dart';

class WeatherProvider with ChangeNotifier {
  String _weatherForecastKeypoint = 'Loading...';
  String _weatherSkycon = 'Loading...';
  Timer? _timer;

  int _currentMonth = DateTime.now().month;
  int _currentDay = DateTime.now().day;
  Timer? _dateTimer;

  String get weatherForecastKeypoint => _weatherForecastKeypoint;
  String get weatherSkycon => _weatherSkycon;
  int get currentMonth => _currentMonth;
  int get currentDay => _currentDay;

  WeatherProvider() {
    _updateWeather();
    // 设置定时器，每120分钟更新一次天气数据
    _timer = Timer.periodic(const Duration(minutes: 120), (timer) {
      _updateWeather();
    });
    _initDateTimer();
  }

  Future<void> _updateWeather() async {
    try {
      Position position;
      try {
        position = await determinePosition();
      } catch (e) {
        // 如果获取位置失败，使用默认坐标
        position = Position(
          longitude: 116.202167,
          latitude: 40.047986,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      final weather = await getCaiyunWeather(
          pos: getPosistion(position.longitude, position.latitude));
      _weatherForecastKeypoint = parseCaiyunResp(weather);
      _weatherSkycon = realtimeSkyCon(weather);
      notifyListeners();
    } catch (e) {
      _weatherForecastKeypoint = 'Error: $e';
      _weatherSkycon = 'Error: $e';
      notifyListeners();
    }
  }

  String realtimeSkyCon(dynamic resp) {
    if (resp is Map) {
      if ('ok' == resp['status'] && resp.containsKey('result')) {
        var result = resp['result'];
        if (result.containsKey('realtime')) {
          return result['realtime']['skycon'];
        }
      } else {
        return resp['error'];
      }
    }
    return 'API ERROR!';
  }

  String parseCaiyunResp(dynamic resp) {
    if (resp is Map) {
      if ('ok' == resp['status'] && resp.containsKey('result')) {
        var result = resp['result'];
        String summary = '';
        if (result.containsKey('forecast_keypoint')) {
          summary += result['forecast_keypoint'];
        }
        if (result.containsKey('alert')) {}
        if (result.containsKey('realtime')) {}
        if (result.containsKey('minutely')) {}
        if (result.containsKey('hourly')) {}
        if (result.containsKey('daily')) {}
        return summary;
      } else {
        return resp['error'];
      }
    }
    return 'API ERROR!';
  }

  void _initDateTimer() {
    // 计算到下一天0点的时间
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    // 设置定时器，在下一个0点更新日期
    Timer(duration, () {
      _updateDate();
      // 设置每天0点更新
      _dateTimer?.cancel(); // 确保没有多余的定时器
      _dateTimer = Timer.periodic(const Duration(days: 1), (_) {
        final currentTime = DateTime.now();
        // 确保在0点附近才更新
        if (currentTime.hour == 0 && currentTime.minute == 0) {
          _updateDate();
        }
      });
    });
  }

  void _updateDate() {
    final now = DateTime.now();
    _currentMonth = now.month;
    _currentDay = now.day;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dateTimer?.cancel();
    super.dispose();
  }
}
