import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dokie/core/widgets/calendar.dart';
import 'package:dokie/core/widgets/edit_task_bottom_sheet.dart';
import 'package:dokie/core/widgets/home_task_card.dart';
import 'package:dokie/core/widgets/tab_data.dart';
import 'package:dokie/features/1a_notification/presentation/notification_page.dart';
import 'package:dokie/features/2a_task/data/models/task.dart';
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

  bool _calendarCompact = true;

  List<Task> _tasks = [];
  Map<int, String> _groupNames = {};
  bool _isLoading = true;

  // Variabel untuk tracking scroll state
  double _scrollOffset = 0.0;
  bool _showCalendar = true;
  bool _isAppBarCollapsed = false;
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
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    final locale = Intl.defaultLocale ?? "id_ID";
    month = DateFormat('MMMM', locale);
    year = DateFormat('yyyy', locale);
    day = DateFormat('dd', locale);
    dayNames = DateFormat('EEE', locale);

    // Listener untuk scroll behavior
    _scrollController.addListener(_onScroll);
    _loadTasks();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;

      // Calendar visibility logic - hide immediately on any scroll
      _showCalendar = _scrollOffset <= 0;

      // AppBar collapse state - collapse immediately on any scroll
      _isAppBarCollapsed = _scrollOffset > 0;
    });
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
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              _buildSliverAppBar(),
              _buildCalendarSpacer(),
              _buildStickyTabHeader(),
              _buildTaskListView(),
              // Tambah extra space 1 item height + space untuk tombol
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: math.max(
                    50.0,
                    MediaQuery.of(context).size.height * 0.15,
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingCalendar(),
          _buildBackToTopButton(),
        ],
      ),
    );
  }

  Widget _buildBackToTopButton() {
    // Tampilkan tombol hanya jika sudah scroll cukup jauh
    if (_scrollOffset < 200) return SizedBox.shrink();

    return Positioned(
      bottom: 30, // Di atas bottom navigation bar
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
      expandedHeight: 200.0,
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
    double calendarHeight =
        (_scrollOffset <= 0) ? (_calendarCompact ? 125.0 : 275.0) : 0.0;

    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: calendarHeight,
      ),
    );
  }

  Widget _buildStickyTabHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: ImprovedStickyHeaderDelegate(
        minHeight: 80.0,
        maxHeight: 80.0,
        isCollapsed: _scrollOffset > 0, // Langsung collapse ketika ada scroll
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

  Widget _buildTaskListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (_isLoading) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF7B6EF2)),
              ),
            );
          }

          if (_tasks.isEmpty) {
            double screenHeight = MediaQuery.of(context).size.height;
            double minHeight = screenHeight - 200;

            return Container(
              alignment: Alignment.topCenter,
              height: math.max(200, minHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

          if (index < _tasks.length) {
            final task = _tasks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
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
            );
          }

          // Tambahan spacer untuk memastikan scroll yang cukup
          double screenHeight = MediaQuery.of(context).size.height;
          double taskHeight =
              _tasks.length * 118.0; // ~100px per task + padding
          double minAdditionalHeight =
              screenHeight - 400; // Minimum additional space

          return Container(
            height: math.max(100, minAdditionalHeight - taskHeight),
          );
        },
        childCount:
            _isLoading || _tasks.isEmpty
                ? 1
                : _tasks.length + 1, // +1 untuk spacer
      ),
    );
  }

  Widget _buildFloatingCalendar() {
    // Calendar hanya muncul ketika tidak ada scroll sama sekali
    if (_scrollOffset > 0) return SizedBox.shrink();

    return Positioned(
      top: math.max(100 - _scrollOffset, 0),
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: (_scrollOffset <= 0) ? 1.0 : 0.0,
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
            });
          },
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
