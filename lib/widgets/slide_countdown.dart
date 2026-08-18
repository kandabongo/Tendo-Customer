import 'dart:async';

import 'package:flutter/material.dart';

/// Separator shown between the time segments (hours : minutes : seconds).
enum SeparatorType { symbol, title }

/// Direction each digit slides in when it changes.
enum SlideDirection { up, down }

/// A countdown timer that renders its digits with a sliding transition.
///
/// Drop-in replacement for the `slide_countdown` package, covering the args
/// used across this app: [duration], [textStyle], [separatorType],
/// [slideDirection] and [onDone].
class SlideCountdown extends StatefulWidget {
  final Duration duration;
  final TextStyle? textStyle;
  final SeparatorType separatorType;
  final SlideDirection slideDirection;
  final VoidCallback? onDone;
  final Color? separatorColor;

  const SlideCountdown({
    Key? key,
    required this.duration,
    this.textStyle,
    this.separatorType = SeparatorType.symbol,
    this.slideDirection = SlideDirection.down,
    this.onDone,
    this.separatorColor,
  }) : super(key: key);

  @override
  State<SlideCountdown> createState() => _SlideCountdownState();
}

class _SlideCountdownState extends State<SlideCountdown> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SlideCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _remaining = widget.duration;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remaining <= Duration.zero) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = _remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
        widget.onDone?.call();
      } else {
        setState(() => _remaining = next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _separator => widget.separatorType == SeparatorType.symbol ? ':' : ' ';

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _remaining.inSeconds < 0 ? 0 : _remaining.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final segments = <String>[
      if (hours > 0) hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      seconds.toString().padLeft(2, '0'),
    ];

    final style = widget.textStyle ?? DefaultTextStyle.of(context).style;

    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        children.add(
          Text(
            _separator,
            style: style.copyWith(color: widget.separatorColor ?? style.color),
          ),
        );
      }
      children.add(_SlidingDigits(
        value: segments[i],
        style: style,
        slideDirection: widget.slideDirection,
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _SlidingDigits extends StatelessWidget {
  final String value;
  final TextStyle style;
  final SlideDirection slideDirection;

  const _SlidingDigits({
    required this.value,
    required this.style,
    required this.slideDirection,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = slideDirection == SlideDirection.up;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: Offset(0, isUp ? 1 : -1),
          end: Offset.zero,
        ).animate(animation);

        return ClipRect(
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      child: Text(
        value,
        key: ValueKey(value),
        style: style,
      ),
    );
  }
}
