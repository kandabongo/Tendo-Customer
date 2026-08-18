import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/login.view_model.dart';
import 'package:fuodz/views/pages/auth/login/email_login.view.dart';
import 'package:fuodz/views/pages/auth/login/otp_login.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CombinedLoginTypeView extends StatefulWidget {
  const CombinedLoginTypeView(this.model, {this.radius, Key? key})
    : super(key: key);

  final LoginViewModel model;
  final double? radius;

  @override
  State<CombinedLoginTypeView> createState() => _CombinedLoginTypeViewState();
}

class _CombinedLoginTypeViewState extends State<CombinedLoginTypeView> {
  bool useOTP = true;

  @override
  Widget build(BuildContext context) {
    return VStack([
      UiSpacer.vSpace(),
      CustomSlidingSegmentedControl<int>(
        isStretch: true,
        initialValue: 1,
        children: {1: Text("Phone Number".tr()), 2: Text("Email Address".tr())},
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(
            (widget.radius ?? Sizes.radiusDefault),
          ),
          border: Border.fromBorderSide(
            BorderSide(color: AppColor.primaryColor, width: 1.5),
          ),
        ),
        thumbDecoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(
            (widget.radius ?? Sizes.radiusDefault) * 0.60,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(.55),
              blurRadius: 5.0,
              spreadRadius: 1.2,
              offset: Offset(1.50, 1.50),
            ),
          ],
        ),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInToLinear,
        onValueChanged: (value) {
          setState(() {
            useOTP = value == 1;
          });
        },
      ).centered(),
      //
      useOTP ? OTPLoginView(widget.model) : EmailLoginView(widget.model),
    ]);
  }
}
