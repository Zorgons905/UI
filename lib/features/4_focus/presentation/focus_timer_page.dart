import 'dart:async';
import 'package:dokie/core/widgets/mode_card.dart';
import 'package:dokie/core/widgets/progress_steps.dart';
import 'package:dokie/core/widgets/shared_widgets.dart';
import 'package:dokie/core/widgets/timer_circle.dart';
import 'package:dokie/core/widgets/timer_control_buttons.dart';
import 'package:flutter/material.dart';

class FocusTimerPage extends StatefulWidget {
  final String focusModeTitle;
  final int focusDuration;
  final int breakDuration;
  final int totalSections;

  const FocusTimerPage({
    super.key,
    required this.focusModeTitle,
    required this.focusDuration,
    required this.breakDuration,
    required this.totalSections,
  });

  @override
  State<FocusTimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<FocusTimerPage> {
  late int focusDuration;
  late int breakDuration;
  late int remainingSeconds;
  late int currentSection;

  Timer? timer;
  bool isFocusMode = true;
  bool isRunning = false;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    focusDuration = widget.focusDuration * 60;
    breakDuration = widget.breakDuration * 60;
    remainingSeconds = focusDuration;
    currentSection = 0;
  }

  void startTimer() {
    if (timer != null) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer?.cancel();
        timer = null;

        if (isFocusMode) {
          if (currentSection >= widget.totalSections - 1) {
            setState(() {
              isRunning = false;
              isFinished = true;
            });
          } else {
            setState(() {
              isFocusMode = false;
              remainingSeconds = breakDuration;
              isRunning = true;
            });
            startTimer();
          }
        } else {
          setState(() {
            currentSection++;
            isFocusMode = true;
            remainingSeconds = focusDuration;
            isRunning = true;
          });
          startTimer();
        }
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    timer = null;

    setState(() {
      isRunning = false;
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
    setState(() {
      isRunning = false;
      isFocusMode = true;
      currentSection = 0;
      remainingSeconds = focusDuration;
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: isFinished ? _buildFinishBody() : _buildTimerBody());
  }

  Widget _buildTimerBody() {
    final progress =
        1 - remainingSeconds / (isFocusMode ? focusDuration : breakDuration);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 56),

          _appBar(),

          SizedBox(height: 24),

          ModeCard(
            isRunning: isRunning,
            isBreak: !isFocusMode,
            focusDurationMinutes: focusDuration ~/ 60,
            breakDurationMinutes: breakDuration ~/ 60,
            totalSections: widget.totalSections,
          ),

          SizedBox(height: 40),

          Flexible(
            fit: FlexFit.loose,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: Duration(seconds: 1),
              builder: (context, animatedProgress, child) {
                return TimerCircle(
                  progress: animatedProgress,
                  timeText: formatTime(remainingSeconds),
                  color: isFocusMode ? Colors.deepPurple : Colors.green,
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 64),
            child: ProgressSteps(
              currentStep: currentSection,
              totalSteps: widget.totalSections,
            ),
          ),

          SizedBox(height: 56),

          TimerControlButtons(
            isRunning: isRunning,
            onStart: startTimer,
            onPause: pauseTimer,
            onStop: stopTimer,
          ),

          SizedBox(height: 44),
        ],
      ),
    );
  }

  Widget _buildFinishBody() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 32),

          _appBar(),

          SizedBox(height: 48),

          Text(
            'Mission accomplished, and now\nthe trophy is yours. Well done!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 80),

          Image.asset('assets/images/focus_mode_complete.png', width: 300),

          SizedBox(height: 148),

          buildShadowedButton(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.restart_alt, size: 32),
                onPressed: _restartSession,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.chevron_left_rounded, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Text(
              widget.focusModeTitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _restartSession() {
    setState(() {
      isFinished = false;
      isRunning = false;
      isFocusMode = true;
      currentSection = 0;
      remainingSeconds = focusDuration;
    });
  }
}
