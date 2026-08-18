import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/utils/utils.dart';

class ArrowIndicator extends StatelessWidget {
  const ArrowIndicator({this.size, this.color, this.leading = false, Key? key})
    : super(key: key);

  final double? size;
  final Color? color;
  final bool leading;
  @override
  Widget build(BuildContext context) {
    IconData? iconData;
    if (leading) {
      iconData =
          !Utils.isArabic
              ? FlutterIcons.chevron_left_fea
              : FlutterIcons.chevron_right_fea;
    } else {
      iconData =
          Utils.isArabic
              ? FlutterIcons.chevron_left_fea
              : FlutterIcons.chevron_right_fea;
    }
    return Icon(iconData, size: size ?? 32, color: color);
  }
}
