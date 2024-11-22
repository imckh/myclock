import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../globals.dart';
import '../utils/geo.dart';
import '../utils/network.dart';
import '../utils/secure.dart';

var logger = Logger();

Future<dynamic> getCaiyunWeather(
    {Position? pos, bool alert = true, int dailysteps = 1, int hourlysteps = 24}) async {
  if (pos == null) {
    await determinePosition().then(
          (position) async {
        logger.d('Data fetched successfully: $position');
        await getCaiyunWeatherHttp(position, alert, dailysteps, hourlysteps).then((resp) {
          return parseCaiyunResp(resp);
        });
      },
      onError: (error) {
        logger.d('Error: $error');
        return 'Error: $error';
      },
    );
  } else {
    await getCaiyunWeatherHttp(pos, alert, dailysteps, hourlysteps).then((resp) {
      return parseCaiyunResp(resp);
    });
  }
}

String parseCaiyunResp(dynamic resp) {
  if (resp is Map) {
    return 'map';
  }
  return '';
}

Future<dynamic> getCaiyunWeatherHttp(Position position, bool alert, int dailysteps, int hourlysteps) async {
  var url = CaiyunVariables.getPositionUrl(position);
  var params = {
    "alert": alert,
    "dailysteps": dailysteps,
    "hourlysteps": hourlysteps,
    "token": await getToken()
  };

  await httpGet(url, params).then((response) {
    logger.d(response);
    return response;
  }).catchError((error) {
    print('发生错误: $error');
  });
}
