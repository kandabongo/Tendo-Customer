import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class CustomRoundedLeading extends StatelessWidget {
  const CustomRoundedLeading({
    this.size,
    this.color,
    this.padding,
    this.bgColor,
    this.margin,
    Key? key,
  }) : super(key: key);

  final double? size;
  final Color? color;
  final Color? bgColor;
  final double? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 6),
      padding: EdgeInsets.all(padding ?? 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor ?? AppColor.primaryColor,
      ),
      child: HugeIcon(
        icon:
            Utils.isArabic
                ? HugeIcons.strokeRoundedArrowRight01
                : HugeIcons.strokeRoundedArrowLeft01,
        size: size ?? 24,
        color: color ?? Utils.textColorByTheme(),
      ).onInkTap(() {
        context.pop();
      }),
    );
  }
}
