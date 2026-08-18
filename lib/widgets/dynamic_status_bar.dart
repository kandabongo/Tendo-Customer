import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicStatusBar extends StatelessWidget {
  final Widget child;
  // final int currentIndex;
  final Color baseColor;

  const DynamicStatusBar({
    Key? key,
    required this.child,
    // required this.currentIndex,
    required this.baseColor,
  }) : super(key: key);

  Brightness _getTextBrightness(Color background) {
    return ThemeData.estimateBrightnessForColor(background);
  }

  SystemUiOverlayStyle _getOverlayStyle(BuildContext context) {
    final brightness = _getTextBrightness(baseColor);
    return SystemUiOverlayStyle(
      statusBarColor: baseColor,
      statusBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: brightness, // for iOS
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getOverlayStyle(context),
      child: child,
    );
  }
}
