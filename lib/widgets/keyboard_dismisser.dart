import 'package:flutter/material.dart';

/// Gestures that can trigger a keyboard dismissal.
enum GestureType {
  onTap,
  onPanUpdateDownDirection,
  onPanUpdateUpDirection,
}

/// Hides the keyboard when the given gesture is performed outside of it.
///
/// Drop-in replacement for the `keyboard_dismisser` package.
class KeyboardDismisser extends StatelessWidget {
  final Widget child;
  final GestureType gestureType;

  const KeyboardDismisser({
    Key? key,
    required this.child,
    this.gestureType = GestureType.onTap,
  }) : super(key: key);

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (gestureType) {
      case GestureType.onPanUpdateDownDirection:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            if (details.delta.dy > 0) _dismissKeyboard(context);
          },
          child: child,
        );
      case GestureType.onPanUpdateUpDirection:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            if (details.delta.dy < 0) _dismissKeyboard(context);
          },
          child: child,
        );
      case GestureType.onTap:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _dismissKeyboard(context),
          child: child,
        );
    }
  }
}
