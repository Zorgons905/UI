import 'package:dokie/core/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:dokie/features/4_focus/presentation/add_focus.dart';
import 'package:dokie/features/4_focus/presentation/edit_focus.dart';

import '../domain/focus_timer_helper.dart';
import '../data/models/focus_timer.dart';
import '../../../core/widgets/focus_timer_card.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  List<FocusTimer> focusTimers = [];
  List<FocusTimer> displayedTimers = [];

  @override
  void initState() {
    super.initState();
    initFocusTimer();
  }

  void initFocusTimer() async {
    focusTimers = await FocusTimerHelper.getFocusTimer(orderBy: 'id ASC');
    setState(() {
      displayedTimers = focusTimers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xFF7B6EF2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Focus Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      backgroundColor: Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                displayedTimers.isEmpty
                    ? Center(
                      child: Text(
                        'Focus mode is still empty. Add a focus mode to set your time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: displayedTimers.length,
                      itemBuilder: (context, index) {
                        final timer = displayedTimers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Stack(
                            children: [
                              FocusModeCard(
                                title: timer.name,
                                focusTimeValue: timer.formattedFocusTimeValue,
                                breakTimeValue: timer.formattedBreakTimeValue,
                                sectionValue: timer.formattedSectionTimeValue,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => EditFocus(timer: timer),
                                        ),
                                      );
                                      if (result == true) {
                                        initFocusTimer();
                                      }
                                    } else if (value == 'delete') {
                                      final result =
                                          await deleteConfirmationDialog(
                                            context,
                                            null,
                                            null,
                                            timer,
                                            null,
                                          );
                                      if (result == true) {
                                        initFocusTimer();
                                      }
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: const Color.fromARGB(255, 1, 1, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0, right: 20.0),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFocus()),
                  );
                  if (result == true) {
                    initFocusTimer();
                  }
                },
                backgroundColor: Color(0xFF7B6EF2),
                shape: const CircleBorder(),
                child: Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
