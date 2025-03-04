import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_test_project/clock/aside.dart';
import 'package:flutter_test_project/utils/network.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../weather/weather_provider.dart';
import '../providers/time_provider.dart';

import '../clock/main_clock.dart';
import '../weather/weather_scene.dart';
import '../weather/weather_text.dart';

void main() {
  runApp(const DesktopLayoutApp());
}

class DesktopLayoutApp extends StatelessWidget {
  const DesktopLayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => TimeProvider()),
      ],
      child: MaterialApp(
        color: Colors.black,
        debugShowCheckedModeBanner: false,
        title: 'Desktop Layout',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
          ),
        ),
        home: Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: const DesktopLayout(),
          ),
        ),
      ),
    );
  }
}

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        // image: DecorationImage(
        //   image: AssetImage('assets/1.jpeg'), // 替换为你的图片链接
        //   fit: BoxFit.cover, // 图片填充方式
        // ),
      ),
      child: LayoutGrid(
        areas: '''
          header header  header
          nav    content aside
          footer footer  footer
        ''',
        // A number of extension methods are provided for concise track sizing
        columnSizes: [152.px, 1.fr, 152.px],
        // columnSizes: [152.px, 1.fr, 152.px],
        rowSizes: [
          112.px,
          1.fr,
          64.px,
        ],
        children: [
          const Header().inGridArea('header'),
          const Navigation().inGridArea('nav'),
          const Content().inGridArea('content'),
          const Aside().inGridArea('aside'),
          const Footer().inGridArea('footer'),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Container(
          color: Colors.red.withAlpha(0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return WeatherText(
                containerHeight: constraints.maxHeight,
                containerWidth: constraints.maxWidth,
              );
            },
          ),
        ),
      );
}

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
      return WeatherCondition.getSkyConWidget(weatherProvider.weatherSkycon);
    });
  }
}

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.green.withAlpha(0),
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: MainDigitalClock(dateTime: DateTime.now()));
}

class Aside extends StatelessWidget {
  const Aside({super.key});

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: AsideMonthDay(),
      );
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withAlpha(0), // 添加半透明白色背景
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // 获取父空间的宽度和高度
          double parentWidth = constraints.maxWidth;
          double parentHeight = constraints.maxHeight;

          return Center(
              child: MainZhDate(
            textColor: Colors.white70,
            textSize: parentHeight, // 初始字体大小
          ));
        },
      ),
    );
  }
}
