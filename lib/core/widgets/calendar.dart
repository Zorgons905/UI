import 'package:dokie/core/utils/dimensions/calendar_dimensions.dart';
import 'package:dokie/core/utils/clippers.dart';
import 'package:dokie/core/widgets/line_assets.dart';
import 'package:dokie/features/2a_task/data/models/task.dart';
import 'package:dokie/features/2a_task/domain/task_helper.dart';

import '../utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum CalendarViewMode { day, month, year }

class Calendar extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final bool isHomePage;
  final Function(bool isCompactView)? onViewChanged;
  final Future<List<Task>> Function(String startDate, String endDate)?
  taskProvider;

  const Calendar({
    super.key,
    this.onDateSelected,
    required this.isHomePage,
    this.onViewChanged,
    this.taskProvider,
  });

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> with TickerProviderStateMixin {
  DateTime currentDate = DateTime.now();
  DateTime? nextDate;
  DateTime? selectedDate;
  bool isCompactView = true;
  int mainMonth = DateTime.now().month;
  int mainYear = DateTime.now().year;
  CalendarViewMode viewMode = CalendarViewMode.day;

  Set<String> _datesWithTasks = {};
  bool _isLoadingTasks = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late String locale;
  late DateFormat dayNameFormat;
  late DateFormat monthFormat;
  late DateFormat yearFormat;

  late bool isToday;
  late bool isSelected;

  bool _isAnimating = false;
  bool _isFlippingRight = true;
  int _pendingDirection = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

    _initializeCurrentDate();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          currentDate = nextDate!;
          nextDate = null;
          _isAnimating = false;
        });
        _flipController.reset();

        if (_pendingDirection != 0) {
          int direction = _pendingDirection;
          _pendingDirection = 0;
          _changeMonth(direction);
        }

        // Load tasks for new month
        if (viewMode == CalendarViewMode.day) {
          _loadTasksForCurrentView();
        }
      }
    });

    locale = Intl.defaultLocale ?? "id_ID";
    dayNameFormat = DateFormat('EEE', locale);
    monthFormat = DateFormat('MMMM', locale);
    yearFormat = DateFormat('yyyy', locale);

    _loadTasksForCurrentView();
  }

  Future<void> _loadTasksForCurrentView() async {
    if (_isLoadingTasks || viewMode != CalendarViewMode.day) return;

    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final days = _getCalendarDays(currentDate);
      final startDate = days.first;
      final endDate = days.last;

      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

      List<Task> tasks;

      if (widget.taskProvider != null) {
        tasks = await widget.taskProvider!(startDateStr, endDateStr);
      } else {
        tasks = await TaskHelper.getTasksByDateRange(startDateStr, endDateStr);
      }

      Set<String> datesWithTasks = {};
      for (Task task in tasks) {
        datesWithTasks.add(task.date);
      }

      setState(() {
        _datesWithTasks = datesWithTasks;
        _isLoadingTasks = false;
      });
    } catch (e) {
      debugPrint('Error loading tasks for calendar: $e');
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  // Check if a date has tasks
  bool _hasTasksForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _datesWithTasks.contains(dateStr);
  }

  // Inisialisasi currentDate untuk dimulai dari Minggu
  void _initializeCurrentDate() {
    DateTime now = DateTime.now();
    int daysFromSunday = now.weekday % 7; // Minggu = 0, Senin = 1, dst
    currentDate = now.subtract(Duration(days: daysFromSunday));
  }

  // Mendapatkan Minggu dari tanggal tertentu
  DateTime _getSundayOfWeek(DateTime date) {
    int daysFromSunday = date.weekday % 7;
    return date.subtract(Duration(days: daysFromSunday));
  }

  // Generate nama hari dengan urutan Minggu-Sabtu
  List<String> _getOrderedDayNames() {
    List<String> dayNames = [];
    // Urutan weekday: Minggu(7), Senin(1), Selasa(2), dst
    List<int> weekdayOrder = [7, 1, 2, 3, 4, 5, 6];

    for (int weekday in weekdayOrder) {
      DateTime date = DateTime.now();
      // Cari tanggal dengan weekday yang diinginkan
      while (date.weekday != weekday) {
        date = date.add(const Duration(days: 1));
      }
      String dayName = dayNameFormat.format(date).toUpperCase();
      if (dayName.length > 3) {
        dayName = dayName.substring(0, 3);
      }
      dayNames.add(dayName);
    }
    return dayNames;
  }

  // Get month names (3 letters) - only first 4 months for compact view
  List<String> _getMonthNames({bool onlyFirstFour = false}) {
    List<String> monthNames = [];
    int monthCount = onlyFirstFour ? 4 : 12;
    for (int i = 1; i <= monthCount; i++) {
      DateTime date = DateTime(DateTime.now().year, i, 1);
      String monthName = monthFormat.format(date).toUpperCase();
      if (monthName.length > 3) {
        monthName = monthName.substring(0, 3);
      }
      monthNames.add(monthName);
    }
    return monthNames;
  }

  // Get compact month names starting from selected month
  List<String> _getCompactMonthNames() {
    List<String> monthNames = [];
    int startMonth =
        (selectedDate?.month ?? DateTime.now().month) - 1; // 0-based

    for (int i = 0; i < 4; i++) {
      int monthIndex = (startMonth + i) % 12;
      DateTime date = DateTime(DateTime.now().year, monthIndex + 1, 1);
      String monthName = monthFormat.format(date).toUpperCase();
      if (monthName.length > 3) {
        monthName = monthName.substring(0, 3);
      }
      monthNames.add(monthName);
    }
    return monthNames;
  }

  // Get compact year range (3 years centered on selected year)
  List<int> _getCompactYearRange() {
    int currentYear = selectedDate?.year ?? DateTime.now().year;
    return [currentYear - 1, currentYear, currentYear + 1];
  }

  // Get year range (current year ± 4 years)
  List<int> _getYearRange() {
    int currentYear = selectedDate?.year ?? DateTime.now().year;
    List<int> years = [];
    for (int i = currentYear - 4; i <= currentYear + 4; i++) {
      years.add(i);
    }
    return years;
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _changeMonth(int direction) {
    if (_isAnimating) {
      _pendingDirection = direction;
      return;
    }

    setState(() {
      _isAnimating = true;
      _isFlippingRight = direction > 0;
    });

    if (viewMode == CalendarViewMode.day) {
      if (isCompactView) {
        DateTime candidate = currentDate.add(Duration(days: direction * 7));

        if (candidate.month == mainMonth) {
          nextDate = candidate;
        } else {
          if (direction > 0) {
            if (mainMonth == currentDate.month) {
              mainMonth = candidate.month;
              mainYear = candidate.year;
              nextDate = currentDate;
            }
          } else {
            if (mainMonth != currentDate.month) {
              mainMonth = candidate.month;
              mainYear = candidate.year;
              nextDate = currentDate;
            } else {
              nextDate = candidate;
            }
          }
        }
      } else {
        nextDate = DateTime(currentDate.year, currentDate.month + direction, 1);
      }
    } else if (viewMode == CalendarViewMode.month) {
      // Navigate years in month mode
      int newYear = mainYear + direction;
      nextDate = DateTime(newYear, 1, 1);
      mainYear = newYear;
    } else if (viewMode == CalendarViewMode.year) {
      // Navigate through year ranges (9 years at a time)
      int currentYear = selectedDate?.year ?? DateTime.now().year;
      int newYear = currentYear + (direction * 9);
      nextDate = DateTime(
        newYear,
        selectedDate?.month ?? 1,
        selectedDate?.day ?? 1,
      );
      selectedDate = DateTime(
        newYear,
        selectedDate?.month ?? 1,
        selectedDate?.day ?? 1,
      );
    }

    _flipController.forward();
  }

  void _toggleView() {
    setState(() {
      isCompactView = !isCompactView;
      DateTime referenceDate = selectedDate ?? DateTime.now();

      if (isCompactView) {
        currentDate = _getSundayOfWeek(referenceDate);
        mainMonth = referenceDate.month;
        mainYear = referenceDate.year;
      } else {
        currentDate = DateTime(referenceDate.year, referenceDate.month, 1);
        mainMonth = referenceDate.month;
        mainYear = referenceDate.year;
      }
    });

    if (widget.onViewChanged != null) {
      widget.onViewChanged!(isCompactView);
    }

    _loadTasksForCurrentView();
  }

  void _onDateTap(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    }
  }

  void _onMonthTap(int month) {
    DateTime newSelectedDate = DateTime(
      mainYear,
      month,
      selectedDate?.day ?? 1,
    );
    bool dateChanged =
        selectedDate == null ||
        selectedDate!.year != newSelectedDate.year ||
        selectedDate!.month != newSelectedDate.month ||
        selectedDate!.day != newSelectedDate.day;

    setState(() {
      selectedDate = newSelectedDate;
      mainMonth = month;
      currentDate = DateTime(mainYear, month, 1);
      viewMode = CalendarViewMode.day;
    });

    // Trigger onDateSelected callback if date actually changed
    if (dateChanged && widget.onDateSelected != null) {
      widget.onDateSelected!(selectedDate!);
    }

    _loadTasksForCurrentView();
  }

  void _onYearTap(int year) {
    DateTime newSelectedDate = DateTime(
      year,
      selectedDate?.month ?? 1,
      selectedDate?.day ?? 1,
    );
    bool dateChanged =
        selectedDate == null ||
        selectedDate!.year != newSelectedDate.year ||
        selectedDate!.month != newSelectedDate.month ||
        selectedDate!.day != newSelectedDate.day;

    setState(() {
      selectedDate = newSelectedDate;
      mainYear = year;
      currentDate = DateTime(year, selectedDate?.month ?? 1, 1);
      viewMode = CalendarViewMode.month;
    });

    // Trigger onDateSelected callback if date actually changed
    if (dateChanged && widget.onDateSelected != null) {
      widget.onDateSelected!(selectedDate!);
    }
  }

  void _onHeaderTap() {
    setState(() {
      if (viewMode == CalendarViewMode.day) {
        viewMode = CalendarViewMode.month;
      } else if (viewMode == CalendarViewMode.month) {
        viewMode = CalendarViewMode.year;
      }
      // Year mode stays in year mode when header is tapped
    });
  }

  List<DateTime> _getCalendarDays(DateTime date) {
    if (isCompactView) {
      // Compact view: 7 hari berturut-turut dari currentDate (yang sudah dimulai dari Minggu)
      return List.generate(7, (i) => currentDate.add(Duration(days: i)));
    } else {
      // Full view: Grid 6x7 dimulai dari Minggu
      final firstDay = DateTime(date.year, date.month, 1);
      final startDay = firstDay.weekday % 7; // 0=Minggu, 1=Senin, dst
      final startDate = firstDay.subtract(Duration(days: startDay));
      return List.generate(42, (i) => startDate.add(Duration(days: i)));
    }
  }

  Widget _buildMonthHeader(DateTime date, CalendarDimensions dimensions) {
    String headerText = '';
    String subHeaderText = '';

    switch (viewMode) {
      case CalendarViewMode.day:
        headerText =
            isCompactView
                ? monthFormat.format(DateTime(mainYear, mainMonth))
                : monthFormat.format(date);
        subHeaderText =
            isCompactView
                ? yearFormat.format(DateTime(mainYear, mainMonth))
                : yearFormat.format(date);
        break;
      case CalendarViewMode.month:
        headerText = 'Pilih Bulan';
        subHeaderText = yearFormat.format(DateTime(mainYear, 1));
        break;
      case CalendarViewMode.year:
        headerText = 'Pilih Bulan';
        subHeaderText = 'Pilih Tahun';
        break;
    }

    return ClipPath(
      clipper: MonthHeaderClipper(),

      child: Container(
        padding: EdgeInsets.all(5),
        color: Color(0xFF7B6EF2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: Icon(Icons.chevron_left, size: dimensions.iconSize),
              color: Colors.white,
            ),
            Expanded(
              child: GestureDetector(
                onTap: _onHeaderTap,
                child: Column(
                  children: [
                    AutoSizeText(
                      headerText,
                      style: TextStyle(
                        fontSize: dimensions.headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      minFontSize: 12,
                    ),
                    if (subHeaderText.isNotEmpty)
                      AutoSizeText(
                        subHeaderText,
                        style: TextStyle(
                          fontSize: dimensions.headerFontSize - 4,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: Icon(Icons.chevron_right, size: dimensions.iconSize),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCell(int monthIndex, CalendarDimensions dimensions) {
    int month;
    String monthName;

    if (isCompactView) {
      // For compact view, calculate actual month from starting month
      int startMonth =
          (selectedDate?.month ?? DateTime.now().month) - 1; // 0-based
      month = ((startMonth + monthIndex) % 12) + 1; // 1-based
      monthName = _getCompactMonthNames()[monthIndex];
    } else {
      // For full view, use direct index
      month = monthIndex + 1;
      monthName = _getMonthNames()[monthIndex];
    }

    final isCurrentMonth =
        month == DateTime.now().month && mainYear == DateTime.now().year;
    final isSelectedMonth =
        selectedDate != null &&
        month == selectedDate!.month &&
        mainYear == selectedDate!.year;

    return GestureDetector(
      onTap: () => _onMonthTap(month),
      child: Container(
        margin: EdgeInsets.all(isCompactView ? 2 : 4),
        decoration: BoxDecoration(
          color: isCurrentMonth ? const Color(0xFF7B6EF2) : Colors.transparent,
          border:
              isSelectedMonth && !isCurrentMonth
                  ? Border.all(color: const Color(0xFF7B6EF2), width: 1.5)
                  : null,
          borderRadius: BorderRadius.circular(isCompactView ? 10 : 8),
        ),
        child: Center(
          child: AutoSizeText(
            monthName,
            style: TextStyle(
              fontSize: dimensions.fontSize,
              color: isCurrentMonth ? Colors.white : Colors.black,
              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            minFontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildYearCell(int year, CalendarDimensions dimensions) {
    final isCurrentYear = year == DateTime.now().year;
    final isSelectedYear = selectedDate != null && year == selectedDate!.year;

    return GestureDetector(
      onTap: () => _onYearTap(year),
      child: Container(
        margin: EdgeInsets.all(isCompactView ? 2 : 4),
        decoration: BoxDecoration(
          color: isCurrentYear ? const Color(0xFF7B6EF2) : Colors.transparent,
          border:
              isSelectedYear && !isCurrentYear
                  ? Border.all(color: const Color(0xFF7B6EF2), width: 1.5)
                  : null,
          borderRadius: BorderRadius.circular(isCompactView ? 10 : 8),
        ),
        child: Center(
          child: AutoSizeText(
            year.toString(),
            style: TextStyle(
              fontSize: dimensions.fontSize,
              color: isCurrentYear ? Colors.white : Colors.black,
              fontWeight: isCurrentYear ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            minFontSize: 10,
          ),
        ),
      ),
    );
  }

  Color _getDayColor(int index) {
    // Minggu (index 0) dan Sabtu (index 6) bisa diberi warna merah jika diperlukan
    // if (index == 0 || index == 6) return Colors.red;
    return Colors.grey[600]!;
  }

  // Simplified task indicator - hanya satu garis bulat sederhana
  Widget _buildTaskIndicator(DateTime date) {
    if (!_hasTasksForDate(date)) return SizedBox(height: 4);

    return Container(
      margin: EdgeInsets.only(top: 2),
      height: 3,
      width: 18,
      decoration: BoxDecoration(
        color: isToday ? Colors.white : Color(0xFF7B6EF2),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    CalendarDimensions dimensions, {
    required bool isCurrentMonth,
    required bool isCompactView,
    required List<String>? dayNames,
    int? index,
  }) {
    isToday = DateUtils.isSameDay(day, DateTime.now());
    isSelected =
        selectedDate != null && DateUtils.isSameDay(day, selectedDate!);

    Color? textColor = (index != null) ? _getDayColor(index) : null;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onDateTap(day),
        child: Container(
          margin: EdgeInsets.all(isCompactView ? 2 : 1),
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF7B6EF2) : Colors.transparent,
            border:
                isSelected && !isToday
                    ? Border.all(color: const Color(0xFF7B6EF2), width: 1.5)
                    : null,
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.rectangle,
          ),
          child:
              isCompactView
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (dayNames != null && index != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: AutoSizeText(
                            dayNames[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: dimensions.dayNameFontSize,
                              color: isToday ? Colors.white : textColor,
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                        ),
                      AutoSizeText(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: dimensions.fontSize,
                          color:
                              isToday
                                  ? Colors.white
                                  : isCurrentMonth
                                  ? Colors.black
                                  : Colors.grey[400],
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                      _buildTaskIndicator(day),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: dimensions.fontSize,
                          color:
                              isToday
                                  ? Colors.white
                                  : isCurrentMonth
                                  ? Colors.black
                                  : Colors.grey[400],
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                      _buildTaskIndicator(day),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent(DateTime date, CalendarDimensions dimensions) {
    return Column(
      children: [
        _buildMonthHeader(date, dimensions),
        SizedBox(height: 5),
        Expanded(
          child: Container(
            color: Colors.white,
            child: _buildViewContent(date, dimensions),
          ),
        ),
      ],
    );
  }

  Widget _buildViewContent(DateTime date, CalendarDimensions dimensions) {
    switch (viewMode) {
      case CalendarViewMode.month:
        return isCompactView
            ? Row(
              children: List.generate(4, (index) {
                return Expanded(child: _buildMonthCell(index, dimensions));
              }),
            )
            : Column(
              children: List.generate(4, (rowIndex) {
                return Expanded(
                  child: Row(
                    children: List.generate(3, (colIndex) {
                      final monthIndex = rowIndex * 3 + colIndex;
                      return Expanded(
                        child: _buildMonthCell(monthIndex, dimensions),
                      );
                    }),
                  ),
                );
              }),
            );

      case CalendarViewMode.year:
        final years = _getYearRange();
        return isCompactView
            ? Row(
              children: List.generate(3, (index) {
                final years =
                    isCompactView ? _getCompactYearRange() : _getYearRange();
                int yearIndex = isCompactView ? index : index + 3;
                return Expanded(
                  child: _buildYearCell(years[yearIndex], dimensions),
                );
              }),
            )
            : Column(
              children: List.generate(3, (rowIndex) {
                return Expanded(
                  child: Row(
                    children: List.generate(3, (colIndex) {
                      final yearIndex = rowIndex * 3 + colIndex;
                      return Expanded(
                        child: _buildYearCell(years[yearIndex], dimensions),
                      );
                    }),
                  ),
                );
              }),
            );

      case CalendarViewMode.day:
        final days = _getCalendarDays(date);
        final localizedDayNames = _getOrderedDayNames();

        return Column(
          children: [
            if (!isCompactView)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children:
                      localizedDayNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        Color textColor = _getDayColor(index);

                        return Expanded(
                          child: Center(
                            child: AutoSizeText(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: dimensions.dayNameFontSize,
                                color: textColor,
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            if (isCompactView)
              Expanded(
                child: Row(
                  children:
                      days.asMap().entries.map((entry) {
                        final day = entry.value;
                        return _buildDayCell(
                          day,
                          dimensions,
                          isCurrentMonth:
                              isCompactView
                                  ? (day.month == mainMonth &&
                                      day.year == mainYear)
                                  : (day.month == date.month),
                          isCompactView: true,
                          dayNames: localizedDayNames,
                          index: entry.key,
                        );
                      }).toList(),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: List.generate(6, (rowIndex) {
                    return Expanded(
                      child: Row(
                        children: List.generate(7, (colIndex) {
                          final index = rowIndex * 7 + colIndex;
                          final day = days[index];
                          return _buildDayCell(
                            day,
                            dimensions,
                            isCurrentMonth: day.month == date.month,
                            isCompactView: false,
                            dayNames: null,
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
    }
  }

  int calculateCount(double maxWidth, double itemWidth, double gap) {
    return (maxWidth / (itemWidth + gap)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = ResponsiveHelper.getCalendarDimensions(
      context,
      isCompactView,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        double calendarHeight = isCompactView ? 200 : 360;

        int lineCount = calculateCount(dimensions.maxWidth, 15, 15);

        if (ResponsiveHelper.isMobile(context)) {
          calendarHeight = isCompactView ? 175 : 320;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Positioned(
                  top: -1.5,

                  child: DiagonalLineAssets(
                    count: lineCount - 1,
                    gap: 20,
                    width: 7.5,
                    height: 39,
                    color: Color.fromARGB(255, 26, 18, 56),
                  ),
                ),

                Column(
                  children: [
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 10,
                      ),
                      width: dimensions.maxWidth,
                      height: calendarHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(26),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (_isAnimating && nextDate != null)
                            _buildCalendarContent(
                              viewMode == CalendarViewMode.day
                                  ? nextDate!
                                  : currentDate,
                              dimensions,
                            ),

                          GestureDetector(
                            onPanEnd: (details) {
                              if (details.velocity.pixelsPerSecond.dx > 200) {
                                _changeMonth(-1);
                              } else if (details.velocity.pixelsPerSecond.dx <
                                  -200) {
                                _changeMonth(1);
                              }
                            },
                            child: AnimatedBuilder(
                              animation: _flipAnimation,
                              builder: (context, child) {
                                if (!_isAnimating) {
                                  return _buildCalendarContent(
                                    currentDate,
                                    dimensions,
                                  );
                                }
                                return ClipPath(
                                  clipper: TriangleClipper(
                                    progress: _flipAnimation.value,
                                    isFlippingRight: _isFlippingRight,
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: _buildCalendarContent(
                                    currentDate,
                                    dimensions,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleView,
                      child: ClipPath(
                        clipper: BookmarkClipper(isCompactView: isCompactView),
                        child: Container(
                          width: ResponsiveHelper.isMobile(context) ? 25 : 30,
                          height: ResponsiveHelper.isMobile(context) ? 30 : 35,
                          color: const Color(0xFF7B6EF2),
                          alignment: Alignment.topCenter,
                          child: Icon(
                            isCompactView
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: ResponsiveHelper.isMobile(context) ? 20 : 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  top: 20,
                  child: DotLineAssets(
                    count: lineCount,
                    gap: 12.5,
                    width: 15,
                    height: 10,
                    color: const Color(0xC6422E92),
                  ),
                ),

                Positioned(
                  top: 0,
                  child: VerticalLineAssets(
                    count: lineCount,
                    gap: 20,
                    height: 28,
                    width: 7.5,
                    color: Color(0xFF422E92),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
