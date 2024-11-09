import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../clock/my_one_clock.dart';

void main() {
  runApp(const DesktopLayoutApp());
}

class DesktopLayoutApp extends StatelessWidget {
  const DesktopLayoutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
        color: Colors.white,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return const DesktopLayout();
        });
  }
}

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        // 使用网络图片作为背景
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
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(color: Colors.red.withOpacity(0.5));
}

class Navigation extends StatelessWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(color: Colors.purple.withOpacity(0.5));
}

class Content extends StatelessWidget {
  const Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.green.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[AnalogClockExample(DateTime.now())],
        ),
      )
  );
}

class Aside extends StatelessWidget {
  const Aside({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.blue.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ...DigitalClockExample(DateTime.now())
          ],
        ),
      )
  );
}

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(color: Colors.deepPurple.withOpacity(0.5));
}