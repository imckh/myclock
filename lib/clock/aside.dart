
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_project/weather/weather_provider.dart';
import 'package:provider/provider.dart';

class AsideMonthDay extends StatelessWidget {
  const AsideMonthDay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue.withAlpha(0),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<WeatherProvider>(
              builder: (context, provider, child) {
                return ClipRect(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.currentMonth.toString(),
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.8,
                          color: Colors.white.withAlpha(80),
                          height: 1.0,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        provider.currentDay.toString(),
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.8,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}