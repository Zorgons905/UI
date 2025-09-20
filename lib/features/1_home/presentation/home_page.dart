import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dokie/core/widgets/calendar.dart';
import 'package:dokie/core/widgets/edit_task_bottom_sheet.dart';
import 'package:dokie/core/widgets/home_task_card.dart';
import 'package:dokie/core/widgets/tab_data.dart';
import 'package:dokie/features/1a_notification/presentation/notification_page.dart';
import 'package:dokie/features/2a_task/data/models/task.dart';
import 'package:dokie/features/2a_task/presentation/add_task_page.dart';
import 'package:dokie/localizations/locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late DateFormat month;
  late DateFormat year;
  late DateFormat day;
  late DateFormat dayNames;

  // Calendar height constants
  static const double _compactCalendarHeight = 125.0;
  static const double _expandedCalendarHeight = 275.0;
  static const double _headerHeight = 80.0;

  // Minimum scroll distance to ensure calendar can always be hidden
  static const double _minScrollableHeight = 300.0;

  // Calendar state variables
  late bool _calendarCompact;
  double _calendarHeight = _compactCalendarHeight;
  bool _showCalendar = true;
  double _scrollOffset = 0.0;
  bool isAppBarCollapsed = false;

  List<Task> _tasks = [];
  Map<int, String> _groupNames = {};
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();

  late AnimationController _animationController;

  final Map<String, List<Task>> _dummyTasks = {
    '2025-09-15': [
      Task(
        id: 1,
        taskName: 'Morning Meeting with Team',
        taskGroupId: 1,
        date: '2025-09-15',
        time: '09:00',
        progress: 100,
      ),
      Task(
        id: 16,
        taskName: 'Code Review Session Long Name That Should Wrap',
        taskGroupId: 1,
        date: '2025-09-15',
        time: '09:30',
        progress: 75,
      ),
      Task(
        id: 17,
        taskName: 'UI/UX Design Sprint',
        taskGroupId: 2,
        date: '2025-09-15',
        time: '10:00',
        progress: 50,
      ),
      Task(
        id: 18,
        taskName: 'Team Standup Meeting',
        taskGroupId: 1,
        date: '2025-09-15',
        time: '10:30',
        progress: 100,
      ),
      Task(
        id: 2,
        taskName: 'Database Optimization Task',
        taskGroupId: 2,
        date: '2025-09-15',
        time: '14:00',
        progress: 75,
      ),
      Task(
        id: 3,
        taskName: 'Client Presentation Preparation',
        taskGroupId: 3,
        date: '2025-09-15',
        time: '16:30',
        progress: 25,
      ),
      Task(
        id: 19,
        taskName: 'Documentation Update',
        taskGroupId: 4,
        date: '2025-09-15',
        time: '17:00',
        progress: 90,
      ),
      Task(
        id: 20,
        taskName: 'Performance Testing',
        taskGroupId: 2,
        date: '2025-09-15',
        time: '18:00',
        progress: 60,
      ),
    ],
    '2025-09-16': [
      Task(
        id: 6,
        taskName: 'Flutter Workshop',
        taskGroupId: 5,
        date: '2025-09-16',
        time: '09:30',
        progress: 0,
      ),
      Task(
        id: 7,
        taskName: 'API Integration Testing',
        taskGroupId: 2,
        date: '2025-09-16',
        time: '11:00',
        progress: 25,
      ),
      Task(
        id: 8,
        taskName: 'Weekly Report',
        taskGroupId: 4,
        date: '2025-09-16',
        time: '17:00',
        progress: 0,
      ),
    ],
    // ... data lainnya tetap sama
  };

  final List<TabData> _tabs = [
    TabData(
      icon: Icons.assignment_late_outlined,
      activeIcon: Icons.assignment_late,
      label: 'Expired',
      color: Color(0xFF8B7CF6),
    ),
    TabData(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'To Do',
      color: Color(0xFF8B7CF6),
    ),
    TabData(
      icon: Icons.assignment_turned_in_outlined,
      activeIcon: Icons.assignment_turned_in,
      label: 'Completed',
      color: Color(0xFF8B7CF6),
    ),
  ];

  int _selectedIndex = 1;

  @override
  void initState() {
    final locale = Intl.defaultLocale ?? "id_ID";

    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize calendar state
    _calendarCompact = true;
    _updateCalendarHeight();

    month = DateFormat('MMMM', locale);
    year = DateFormat('yyyy', locale);
    day = DateFormat('dd', locale);
    dayNames = DateFormat('EEE', locale);

    // Listener untuk scroll behavior
    _scrollController.addListener(_onScroll);
    _loadTasks();
  }

  void _updateCalendarHeight() {
    _calendarHeight =
        _calendarCompact ? _compactCalendarHeight : _expandedCalendarHeight;
  }

  void _onScroll() {
    final newScrollOffset = _scrollController.offset;
    final newShowCalendar = newScrollOffset <= 10; // Small tolerance
    final newIsAppBarCollapsed = newScrollOffset > 50;

    // Only update state if there's a meaningful change
    if (_scrollOffset != newScrollOffset ||
        _showCalendar != newShowCalendar ||
        isAppBarCollapsed != newIsAppBarCollapsed) {
      setState(() {
        _scrollOffset = newScrollOffset;
        _showCalendar = newShowCalendar;
        isAppBarCollapsed = newIsAppBarCollapsed;
      });
    }
  }

  // Method to get current space for calendar based on scroll position
  double get spaceForCalendarHeight {
    if (!_showCalendar) return 0.0;

    // Smooth transition based on scroll offset
    if (_scrollOffset <= 0) {
      return _calendarHeight;
    } else if (_scrollOffset < 50) {
      // Gradual reduction as user scrolls
      double progress = _scrollOffset / 50;
      return _calendarHeight * (1 - progress);
    } else {
      return 0.0;
    }
  }

  // Calculate minimum height needed to ensure scrollability
  double _calculateMinContentHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 200.0; // SliverAppBar expanded height
    final tabHeaderHeight = _headerHeight;
    final calendarHeight = _calendarHeight;
    final bottomNavHeight = 60.0; // Bottom navigation bar height

    // Minimum height needed to allow full calendar collapse
    final minRequiredHeight =
        screenHeight -
        appBarHeight -
        bottomNavHeight +
        calendarHeight +
        tabHeaderHeight +
        _minScrollableHeight;

    return minRequiredHeight;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Method untuk load tasks dari dummy data
  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(Duration(milliseconds: 500));

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final tasks = _dummyTasks[dateStr] ?? [];
      final groupNames = await _loadGroupNames();

      setState(() {
        _tasks = tasks;
        _groupNames = groupNames;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<int, String>> _loadGroupNames() async {
    return {
      1: "Development Team",
      2: "Code Review",
      3: "Design Team",
      4: "Management",
      5: "Learning & Development",
    };
  }

  Future<List<Task>> getTasksByDateRange(
    String startDate,
    String endDate,
  ) async {
    await Future.delayed(Duration(milliseconds: 200));
    List<Task> result = [];
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    for (
      DateTime date = start;
      date.isBefore(end.add(Duration(days: 1)));
      date = date.add(Duration(days: 1))
    ) {
      String dateStr = DateFormat('yyyy-MM-dd').format(date);
      if (_dummyTasks.containsKey(dateStr)) {
        result.addAll(_dummyTasks[dateStr]!);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      bottomNavigationBar: Container(height: 60),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics:
                AlwaysScrollableScrollPhysics(), // Ensure always scrollable
            slivers: <Widget>[
              _buildSliverAppBar(),
              _buildCalendarSpacer(),
              _buildStickyTabHeader(),
              _buildTaskContent(),
            ],
          ),
          _buildFloatingCalendar(),
          _buildBackToTopButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        backgroundColor: Color(0xFF7B6EF2),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBackToTopButton() {
    if (_scrollOffset < 200) return SizedBox.shrink();

    return Positioned(
      bottom: 30,
      left: 20,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: _scrollOffset >= 200 ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF7B6EF2),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Kembali ke Atas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80.0,
      backgroundColor:
          _scrollOffset > 0 ? Color(0xFF7B6EF2) : Colors.transparent,
      expandedHeight: 180.0,
      pinned: true,
      centerTitle: true,
      title: _buildTitle(),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildNotificationIcon(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Color(0xFF7B6EF2),
            borderRadius:
                _scrollOffset > 0
                    ? BorderRadius.zero
                    : BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
          ),
        ),
        collapseMode: CollapseMode.pin,
      ),
    );
  }

  Widget _buildCalendarSpacer() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: spaceForCalendarHeight,
        child: Container(), // Empty container as spacer
      ),
    );
  }

  Widget _buildStickyTabHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: ImprovedStickyHeaderDelegate(
        minHeight: _headerHeight,
        maxHeight: _headerHeight,
        isCollapsed: _scrollOffset > 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                _scrollOffset > 0
                    ? BorderRadius.zero
                    : BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
            boxShadow:
                _scrollOffset > 0
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                _tabs.asMap().entries.map((entry) {
                  int index = entry.key;
                  TabData tab = entry.value;
                  bool isActive = index == _selectedIndex;

                  return GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: isActive ? 20 : 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? tab.color : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            color: isActive ? Colors.white : Color(0xFF9CA3AF),
                            size: 24,
                          ),
                          AnimatedSize(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 200),
                              opacity: isActive ? 1.0 : 0.0,
                              child: Container(
                                width: isActive ? null : 0,
                                child:
                                    isActive
                                        ? Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Text(
                                            tab.label,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                        : SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskContent() {
    return SliverToBoxAdapter(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _calculateMinContentHeight(context),
        ),
        child:
            _isLoading
                ? Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF7B6EF2)),
                  ),
                )
                : _tasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Icon(Icons.task_alt, size: 48, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "No tasks for this day",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Task items
            ..._tasks
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: HomeTaskCard(
                      task: task,
                      onTap: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => EditTaskBottomSheet(task: task),
                        );

                        if (result != null) {
                          await _loadTasks();
                        }
                      },
                    ),
                  ),
                )
                .toList(),

            // Extra space to ensure scrollability
            Container(
              height: math.max(
                100,
                _calculateMinContentHeight(context) - (_tasks.length * 118.0),
              ),
              child:
                  _tasks.isEmpty
                      ? null
                      : Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Text(
                            "End of tasks",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCalendar() {
    return Positioned(
      top: math.max(100, 100 - (_scrollOffset * 0.5)), // Smooth movement
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity:
            _showCalendar ? math.max(0.0, 1.0 - (_scrollOffset / 100)) : 0.0,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _showCalendar ? 0 : -50, // Slide up when hiding
            0,
          ),
          child: Calendar(
            isHomePage: true,
            taskProvider: getTasksByDateRange,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
              _loadTasks();
            },
            onViewChanged: (isCompact) {
              setState(() {
                _calendarCompact = isCompact;
                _updateCalendarHeight();
              });
            },
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Widget _buildNotificationIcon() {
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child:
          !_showCalendar
              ? Row(
                key: const ValueKey("date"),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        dayNames.format(selectedDate).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                      AutoSizeText(
                        day.format(selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        minFontSize: 18,
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        month.format(selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        minFontSize: 16,
                      ),
                      AutoSizeText(
                        year.format(selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                    ],
                  ),
                ],
              )
              : Column(
                key: const ValueKey("greeting"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    context.formatString(LocaleData.hello, ["John"]),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: 16,
                  ),
                  AutoSizeText(
                    LocaleData.welcome.getString(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    minFontSize: 10,
                  ),
                ],
              ),
    );
  }
}

class ImprovedStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  final bool isCollapsed;

  ImprovedStickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    required this.isCollapsed,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(ImprovedStickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child ||
        isCollapsed != oldDelegate.isCollapsed;
  }
}
