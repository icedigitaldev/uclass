import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
          MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static int getCoursesGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 4;
    return 6;
  }

  static double getBottomSheetMaxWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? 600 : screenWidth;
  }

  static double getFixedBottomSheetMaxWidth() {
    return 400;
  }

  static Widget wrapWithMaxWidth(Widget child) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: child,
      ),
    );
  }
}