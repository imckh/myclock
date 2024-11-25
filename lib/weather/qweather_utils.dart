import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../globals.dart';
import '../utils/geo.dart';
import '../utils/network.dart';
import '../utils/secure.dart';

var logger = Logger();

Future<dynamic> qWeatherCityLookup({Position? pos}) async {
  return qWeatherPos(QWeatherVariables.cityLookUp, pos: pos);
}

Future<dynamic> qWeatherWeather24h({Position? pos}) async {
  var resp = qWeatherPos(QWeatherVariables.weather24h, pos: pos);
  return resp.toString();
}

Future<dynamic> qWeatherPos(String url, {Position? pos}) async {
  var respose;
  if (pos == null) {
    await determinePosition().then((position) async {
        logger.d('Data fetched successfully: $position');
        await getQWeatherRequest(url, position).then((resp) {
          respose = resp;
        });
      },
      onError: (error) {
        logger.d('Error: $error');
        return 'Error: $error';
      },
    );
  } else {
    await getQWeatherRequest(url, pos).then((resp) {
      respose = resp;
    });
    return respose;
  }
}

Future<dynamic> getQWeatherRequest(String url, Position position) async {
  var token = await getFileStr('assets/private_files/hefeng_token');
  var params = {
    "location": "${position.longitude},${position.latitude}",
    "key": token
  };
  var resp;
  await httpGet(url, params).then((response) {
    logger.d(response);
    resp = response;
  }).catchError((error) {
    print('发生错误: $error');
  });
  return resp;
}


