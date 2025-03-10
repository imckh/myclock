import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lunar/calendar/Holiday.dart';
import 'package:lunar/calendar/Solar.dart';
import 'package:lunar/calendar/util/HolidayUtil.dart';
import 'package:provider/provider.dart';
import '../providers/time_provider.dart';

class MainDigitalClock extends StatefulWidget {
  final DateTime dateTime;

  MainDigitalClock({required this.dateTime});

  @override
  _MainDigitalClockState createState() => _MainDigitalClockState();
}

class _MainDigitalClockState extends State<MainDigitalClock> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.05,
            vertical: constraints.maxHeight * 0.05,
          ),
          child: Consumer<TimeProvider>(
            builder: (context, timeProvider, child) {
              return FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: Text(
                  timeProvider.timeString,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class MainZhDate extends StatefulWidget {
  final Color? textColor;
  double? textSize = 20.0;

  MainZhDate({this.textColor, this.textSize});

  @override
  _MainZhDateState createState() => _MainZhDateState();
}

class _MainZhDateState extends State<MainZhDate> {
  DateTime _dateTime = DateTime.now();
  String curLunarFestivals = ' ';

  @override
  void initState() {
    super.initState();
    // 每秒更新一次时间
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _dateTime = DateTime.now();
        int curYear = _dateTime.year;
        int curMon = _dateTime.month;
        int curDay = _dateTime.day;
        int curHour = _dateTime.hour;
        int curMin = _dateTime.minute;
        int curSec = _dateTime.second;

        Solar solar =
            Solar.fromYmdHms(curYear, curMon, curDay, curHour, curMin, curSec);
        // 周几
        String weekStr = solar.getWeekInChinese();
        // 农历日期
        String lunarDate = solar.getLunar().toString().substring(5);
        // 下周节日
        Set<String> festivals = {};
        List<DateTime> nextWeekDates = getNextWeekDates(_dateTime);
        for (int i = 0; i < nextWeekDates.length; i++) {
          Holiday? holiday = HolidayUtil.getHolidayByYmd(nextWeekDates[i].year,
              nextWeekDates[i].month, nextWeekDates[i].day);
          if (holiday != null) {
            festivals.add(holiday.getName());
          }
          festivals.addAll(Solar.fromYmd(nextWeekDates[i].year,
                  nextWeekDates[i].month, nextWeekDates[i].day)
              .getFestivals());
        }
        curLunarFestivals =
            "周$weekStr 农历：$lunarDate 近期节日：[${festivals.join(", ")}]";
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // 清理定时器
  }

  List<DateTime> getNextWeekDates(DateTime today) {
    List<DateTime> dates = [];
    for (int i = 1; i <= 14; i++) {
      // 计算从今天开始的第 i 天的日期
      DateTime nextDay = today.add(Duration(days: i));
      dates.add(nextDay);
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain, // 使文本适应容器大小
      child: Text(
        curLunarFestivals,
        style: TextStyle(
          color: widget.textColor,
          fontSize: widget.textSize, // 使用提供的字体大小
        ),
        softWrap: true, // 允许文本换行
      ),
    );
  }
}
