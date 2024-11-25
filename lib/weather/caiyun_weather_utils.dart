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

String parseCaiyunResp(dynamic resp) {
  if (resp is Map) {
    return 'map';
  }
  return '';
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
  await httpGet(url, params).then((response) {
    logger.d(response);
    resp = response;
  }).catchError((error) {
    print('发生错误: $error');
  });
  return resp;
}
