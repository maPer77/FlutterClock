// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
// import 'dart:ffi';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  disabled,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.grey,
  _Element.disabled: Colors.grey[100],
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.grey,
  _Element.disabled: Colors.grey[900],
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

var colors;

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  IconData _icon;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final format = widget.model.is24HourFormat ? 24 : 12;
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);

    // define color with ambient temperature
    double tempCalc;
    if (_temperature.contains("°F")) {
      tempCalc = double.parse(_temperature.replaceAll("°F", ""));
      tempCalc = (tempCalc - 32) * 5 / 9;
    } else if (_temperature.contains("°C")) {
      tempCalc = double.parse(_temperature.replaceAll("°C", ""));
    }

    double _corHUE = tempCalc;
    if (tempCalc > 40) {
      _corHUE = 340;
    } else if (tempCalc < 0) {
      _corHUE = 200;
    } else {
      _corHUE = 190 - (190 / 40 * _corHUE) * 0.95;
    }

    Color _corHH = HSLColor.fromAHSL(0.85, _corHUE, 1, 0.50).toColor();
    Color _corMM = HSLColor.fromAHSL(0.70, _corHUE, 1, 0.65).toColor();
    Color _corSS = HSLColor.fromAHSL(0.55, _corHUE, 1, 0.80).toColor();

    // define icons for _condition
    if (_condition == "cloudy") {
      _icon = Icons.cloud;
    } else if (_condition == "foggy") {
      _icon = Icons.texture;
    } else if (_condition == "rainy") {
      _icon = Icons.grain;
    } else if (_condition == "snowy") {
      _icon = Icons.ac_unit;
    } else if (_condition == "sunny") {
      _icon = Icons.wb_sunny;
    } else if (_condition == "thunderstorm") {
      _icon = Icons.flash_on;
    } else if (_condition == "windy") {
      _icon = Icons.flag;
    }

    final weatherInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Transform.scale(
          scale: format == 12 ? 1.3 : 1,
          origin: Offset(0, -60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                hour.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 50,
                  color: colors[_Element.text],
                  fontWeight: FontWeight.w100,
                  height: 1,
                ),
              ),
              Text(
                minute.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 50,
                  color: colors[_Element.text],
                  fontWeight: FontWeight.w100,
                  height: 1,
                ),
              ),
              Text(
                second.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 50,
                  color: colors[_Element.text],
                  fontWeight: FontWeight.w100,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: format == 12 ? 1.3 : 1,
          origin: Offset(0, 52),
          child: Column(
            children: <Widget>[
              Icon(
                _icon,
                size: 60,
                color: colors[_Element.text],
              ),
              Text(
                _temperature,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: colors[_Element.text],
                ),
              ),
              Text(
                _temperatureRange,
                style: TextStyle(
                  fontSize: 8,
                  color: colors[_Element.text],
                ),
              ),
              Text(
                _condition[0].toUpperCase() + _condition.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors[_Element.text],
                ),
              ),
              Text(
                _location,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  color: colors[_Element.text],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.only(bottom: 20, left: 20, right: 5, top: 20),
      color: colors[_Element.background],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: constraints.maxHeight * ((format / 6) / 6),
                alignment: Alignment.center,
                child: clockBox(
                  time: hour,
                  width: constraints.maxHeight * ((format / 6) / 6),
                  height: constraints.maxHeight,
                  color: _corHH,
                  lineWrap: (format ~/ 6),
                  maximo: format,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 2, right: 2),
                width: constraints.maxHeight * (6 / 10),
                alignment: Alignment.center,
                child: clockBox(
                  time: minute,
                  width: constraints.maxHeight * (6 / 10),
                  height: constraints.maxHeight,
                  color: _corMM,
                  lineWrap: 6,
                  maximo: 60,
                ),
              ),
              Container(
                width: constraints.maxHeight * (4 / 15),
                alignment: Alignment.center,
                child: clockBox(
                  time: second,
                  width: constraints.maxHeight * (4 / 15),
                  height: constraints.maxHeight,
                  color: _corSS,
                  lineWrap: 4,
                  maximo: 60,
                ),
              ),
              Expanded(
                child: Container(
                  child: weatherInfo,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Wrap clockBox({
  String time,
  double width,
  double height,
  Color color,
  int lineWrap,
  int maximo,
}) {
  List list = List<Widget>();
  int current = int.parse(time);
  double margin = 2;
  double column = maximo / lineWrap;
  double squadSize = (height - (margin * (column - 1))) / column;

  for (var i = 1; i <= maximo; i++) {
    color = (i > current) ? colors[_Element.disabled] : color;
    color = (i == current + 1) ? Colors.transparent : color;

    list.add(Container(
      width: squadSize,
      height: squadSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: new BorderRadius.circular(5),
      ),
    ));
  }

  return Wrap(
    direction: Axis.vertical,
    spacing: margin,
    runSpacing: margin,
    verticalDirection: VerticalDirection.up,
    children: list,
  );
}
