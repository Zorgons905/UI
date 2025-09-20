import 'package:dokie/core/widgets/shared_widgets.dart';
import 'package:dokie/core/widgets/stop_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class TimerControlButtons extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const TimerControlButtons({
    super.key,
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onStop,
  });

  @override
  State<TimerControlButtons> createState() => _TimerControlButtonsState();
}

class _TimerControlButtonsState extends State<TimerControlButtons> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildShadowedButton(
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(
                widget.isRunning ? LucideIcons.pause : LucideIcons.play,
              ),
              onPressed: () {
                if (widget.isRunning) {
                  widget.onPause();
                } else {
                  widget.onStart();
                  setState(() {
                    _started = true;
                  });
                }
              },
            ),
          ),
        ),

        SizedBox(width: 16),

        buildShadowedButton(
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(LucideIcons.square, color: Colors.red),

              onPressed:
                  !_started
                      ? null
                      : () async {
                        final confirmed = await stopConfirmationDialog(
                          context: context,
                        );

                        if (confirmed) {
                          widget.onStop();

                          setState(() {
                            _started = false;
                          });
                        }
                      },
            ),
          ),
        ),
      ],
    );
  }
}
