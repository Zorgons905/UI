import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  final Function(String)? onTimeChanged;
  final String? initialTime; // Format: "13:45" atau "01:45 PM"

  const Clock({Key? key, this.onTimeChanged, this.initialTime})
    : super(key: key);

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  int _hour24 = 0;
  int _minute = 0;
  bool _is24HourFormat = true;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _setDefaultTime();
    _initializeFromInitialTime();
    _initializeControllers();
  }

  void _setDefaultTime() {
    final now = DateTime.now();
    if (widget.initialTime == null) {
      _is24HourFormat = true;
      _hour24 = now.hour;
      _minute = now.minute;
    }
  }

  void _initializeFromInitialTime() {
    if (widget.initialTime != null) {
      String time = widget.initialTime!;
      if (time.contains('AM') || time.contains('PM')) {
        _is24HourFormat = false;
        bool isAM = time.contains('AM');
        List<String> parts = time.split(' ')[0].split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        // Konversi ke format 24 jam
        if (hour == 12 && isAM) {
          _hour24 = 0;
        } else if (hour == 12 && !isAM) {
          _hour24 = 12;
        } else if (!isAM) {
          _hour24 = hour + 12;
        } else {
          _hour24 = hour;
        }
        _minute = minute;
      } else {
        _is24HourFormat = true;
        List<String> parts = time.split(':');
        _hour24 = int.parse(parts[0]);
        _minute = int.parse(parts[1]);
      }
    }
  }

  void _initializeControllers() {
    int hourIndex;
    if (_is24HourFormat) {
      hourIndex = _hour24;
    } else {
      hourIndex = displayHour - 1;
    }

    _hourController = FixedExtentScrollController(initialItem: hourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  int get displayHour {
    if (_is24HourFormat) return _hour24;
    int h = _hour24 % 12;
    return h == 0 ? 12 : h;
  }

  bool get isAM => _hour24 < 12;

  String get _formattedTime {
    if (_is24HourFormat) {
      return "${_hour24.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}";
    } else {
      return "${displayHour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')} ${isAM ? 'AM' : 'PM'}";
    }
  }

  void _updateTime() {
    widget.onTimeChanged?.call(_formattedTime);
  }

  void _toggle24HourFormat() {
    setState(() {
      _isToggling = true;
      _is24HourFormat = !_is24HourFormat;

      int newHourIndex;
      if (_is24HourFormat) {
        newHourIndex = _hour24;
      } else {
        newHourIndex = displayHour - 1;
      }
      _hourController.jumpToItem(newHourIndex);

      Future.delayed(Duration(milliseconds: 100), () {
        _isToggling = false;
      });

      _updateTime();
    });
  }

  void _toggleAMPM(bool am) {
    if (!_is24HourFormat) {
      setState(() {
        if (am && _hour24 >= 12) {
          _hour24 -= 12;
        } else if (!am && _hour24 < 12) {
          _hour24 += 12;
        }

        _hourController.jumpToItem(displayHour - 1);

        _updateTime();
      });
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggle24HourFormat,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      margin: EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color:
                                _is24HourFormat
                                    ? Color(0xFF6B46C1)
                                    : Colors.grey,
                            width: 10,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '24',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _is24HourFormat
                                      ? Color(0xFF6B46C1)
                                      : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            'H',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _is24HourFormat
                                      ? Color(0xFF6B46C1)
                                      : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    if (!_is24HourFormat)
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAMPMButton(
                              'AM',
                              isAM,
                              () => _toggleAMPM(true),
                            ),
                            const SizedBox(width: 20),
                            _buildAMPMButton(
                              'PM',
                              !isAM,
                              () => _toggleAMPM(false),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(height: 40),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF6B46C1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF6B46C1),
                            width: 15,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: ListWheelScrollView(
                                  controller: _hourController,
                                  itemExtent: 50,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    if (_isToggling) {
                                      return;
                                    }
                                    setState(() {
                                      if (_is24HourFormat) {
                                        _hour24 = index;
                                      } else {
                                        int displayH = index + 1;
                                        if (displayH == 12) {
                                          _hour24 = isAM ? 0 : 12;
                                        } else {
                                          _hour24 =
                                              isAM ? displayH : displayH + 12;
                                        }
                                      }
                                      _updateTime();
                                    });
                                  },
                                  children: List.generate(
                                    _is24HourFormat ? 24 : 12,
                                    (index) {
                                      int display =
                                          _is24HourFormat ? index : index + 1;
                                      bool isSelected;
                                      if (_is24HourFormat) {
                                        isSelected = index == _hour24;
                                      } else {
                                        isSelected = display == displayHour;
                                      }

                                      return Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Text(
                                          display.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Color(0x32FFFFFF),
                                            fontSize: isSelected ? 40 : 30,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              Container(
                                width: 20,
                                alignment: Alignment.center,
                                child: const Text(
                                  ':',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: ListWheelScrollView(
                                  controller: _minuteController,
                                  itemExtent: 50,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      _minute = index;
                                      _updateTime();
                                    });
                                  },
                                  children: List.generate(60, (index) {
                                    final isSelected = index == _minute;
                                    return Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        index.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Color(0x32FFFFFF),
                                          fontSize: isSelected ? 40 : 30,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAMPMButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Color(0xFF6B46C1) : Colors.grey,
              width: 10,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Color(0xFF6B46C1) : Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
