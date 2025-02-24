import 'package:flutter/widgets.dart';
import 'package:weather_animation/weather_animation.dart';

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
  late Widget animation; // 或者存储为 Widget
  static Map<String, WeatherCondition> map = {};

  WeatherCondition(this.skyconCode, this.skyconDesc, this.icon, this.animation);

  static void _init() {
    if (map.isEmpty) {
      map['CLEAR_DAY'] = WeatherCondition('CLEAR_DAY', '晴（白天）', '', sunset);
      map['CLEAR_NIGHT'] = WeatherCondition('CLEAR_NIGHT', '晴（夜间）', '', sunset);
      map['PARTLY_CLOUDY_DAY'] =
          WeatherCondition('PARTLY_CLOUDY_DAY', '多云（白天）', '', cloudy);
      map['PARTLY_CLOUDY_NIGHT'] =
          WeatherCondition('PARTLY_CLOUDY_NIGHT', '多云（夜间）', '', cloudy);
      map['CLOUDY'] = WeatherCondition('CLOUDY', '阴', '', cloudy);
      map['LIGHT_HAZE'] = WeatherCondition('LIGHT_HAZE', '轻度雾霾', '', cloudy);
      map['MODERATE_HAZE'] =
          WeatherCondition('MODERATE_HAZE', '中度雾霾', '', cloudy);
      map['HEAVY_HAZE'] = WeatherCondition('HEAVY_HAZE', '重度雾霾', '', cloudy);
      map['LIGHT_RAIN'] =
          WeatherCondition('LIGHT_RAIN', '小雨', '', rainyOvercast);
      map['MODERATE_RAIN'] =
          WeatherCondition('MODERATE_RAIN', '中雨', '', rainyOvercast);
      map['HEAVY_RAIN'] =
          WeatherCondition('HEAVY_RAIN', '大雨', '', rainyOvercast);
      map['STORM_RAIN'] = WeatherCondition('STORM_RAIN', '暴雨', '', stormy);
      map['FOG'] = WeatherCondition('FOG', '雾', '', cloudy);
      map['LIGHT_SNOW'] = WeatherCondition('LIGHT_SNOW', '小雪', '', snowfall);
      map['MODERATE_SNOW'] =
          WeatherCondition('MODERATE_SNOW', '中雪', '', snowfall);
      map['HEAVY_SNOW'] = WeatherCondition('HEAVY_SNOW', '大雪', '', snowfall);
      map['STORM_SNOW'] = WeatherCondition('STORM_SNOW', '暴雪', '', snowfall);
      map['DUST'] = WeatherCondition('DUST', '浮尘', '', sunset);
      map['SAND'] = WeatherCondition('SAND', '沙尘', '', sunset);
      map['WIND'] = WeatherCondition('WIND', '大风', '', sunset);
    }
  }

  static Widget sunset = WrapperScene.weather(
    scene: WeatherScene.sunset,
    clip: Clip.none,
    colors: [],
  );
  // static Widget scorchingSun = WrapperScene.weather(
  //   scene: WeatherScene.scorchingSun,
  //   clip: Clip.none,
  // );
  // static Widget frosty = WrapperScene.weather(
  //   scene: WeatherScene.frosty,
  //   clip: Clip.none,
  // );
  static Widget stormy = WrapperScene.weather(
    scene: WeatherScene.stormy,
    clip: Clip.none,
    colors: [],
  );
  static Widget snowfall = WrapperScene.weather(
    scene: WeatherScene.snowfall,
    clip: Clip.none,
    colors: [],
  );
  static Widget rainyOvercast = WrapperScene.weather(
    scene: WeatherScene.rainyOvercast,
    clip: Clip.none,
    colors: [],
  );
  static Widget cloudy = WrapperScene(
    sizeCanvas: Size(350, 540),
    isLeftCornerGradient: true,
    colors: [],
    children: [
      CloudWidget(
        cloudConfig: CloudConfig(
            size: 250,
            color: const Color(0x65212121),
            icon: const IconData(0xf650, fontFamily: 'MaterialIcons'),
            widgetCloud: null,
            x: 20,
            y: 35,
            scaleBegin: 1,
            scaleEnd: 1.08,
            scaleCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
            slideX: 20,
            slideY: 0,
            slideDurMill: 3000,
            slideCurve: const Cubic(0.40, 0.00, 0.20, 1.00)),
      ),
      CloudWidget(
        cloudConfig: CloudConfig(
            size: 160,
            color: const Color(0x77212121),
            icon: const IconData(0xf650, fontFamily: 'MaterialIcons'),
            widgetCloud: null,
            x: 140,
            y: 130,
            scaleBegin: 1,
            scaleEnd: 1.1,
            scaleCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
            slideX: 20,
            slideY: 4,
            slideDurMill: 2000,
            slideCurve: const Cubic(0.40, 0.00, 0.20, 1.00)),
      ),
    ],
  );

  static Widget getSkyConWidget(String skycon) {
    _init();
    if (!map.containsKey(skycon)) {
      return sunset;
    }
    return map[skycon]!.animation;
  }
}
