import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_provider.dart';

class WeatherText extends StatelessWidget {
  final double containerHeight;
  final double containerWidth;

  const WeatherText({
    super.key,
    required this.containerHeight,
    required this.containerWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return FittedBox(
          fit: BoxFit.contain,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: containerWidth * 0.005,
              vertical: containerHeight * 0.025,
            ),
            child: Text(
              weatherProvider.weatherForecastKeypoint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
