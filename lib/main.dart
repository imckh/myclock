import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'layout_grid_test/app_layout.dart';

// import 'package:flutter_test_project/weather/all_weathers_scenes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [], // 这会隐藏状态栏和导航栏
  );
  runApp(DesktopLayoutApp());
  // runApp(ExampleApp());
}
