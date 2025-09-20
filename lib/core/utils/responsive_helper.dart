import 'package:dokie/core/utils/dimensions/calendar_dimensions.dart';
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static CalendarDimensions getCalendarDimensions(
    BuildContext context,
    bool isCompactView,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return CalendarDimensions(
        maxWidth: screenWidth * 0.9,
        padding: const EdgeInsets.all(8),
        fontSize: 12,
        headerFontSize: 18,
        iconSize: 24,
        dayNameFontSize: 10,
      );
    } else if (isTablet(context)) {
      return CalendarDimensions(
        maxWidth: screenWidth * 0.7,
        padding: const EdgeInsets.all(12),
        fontSize: 14,
        headerFontSize: 20,
        iconSize: 28,
        dayNameFontSize: 11,
      );
    } else {
      return CalendarDimensions(
        maxWidth: 450,
        padding: const EdgeInsets.all(16),
        fontSize: 16,
        headerFontSize: 22,
        iconSize: 30,
        dayNameFontSize: 12,
      );
    }
  }
}
