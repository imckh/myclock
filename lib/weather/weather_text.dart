import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/geo.dart';
import 'caiyun_weather_utils.dart';

class WeatherText extends StatefulWidget {
  WeatherText();

  @override
  _WeatherTextState createState() => _WeatherTextState();
}

class _WeatherTextState extends State<WeatherText> {
  double? _textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getCaiyunWeather(pos: getPosistion(116.3176, 39.9760)),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Text(snapshot.data ?? 'No data');
        }
      },
    );
  }
}
