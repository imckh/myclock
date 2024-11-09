import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';

Widget MainDigitalClock(DateTime dateTime) {
  return DigitalClock(
    showSeconds: true,
    datetime: dateTime,
    textScaleFactor: 1.3,
    isLive: true,
  )
}