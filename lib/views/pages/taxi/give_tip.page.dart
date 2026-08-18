import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class GiveTipPage extends StatefulWidget {
  const GiveTipPage({this.tip, super.key});

  final double? tip;

  @override
  State<GiveTipPage> createState() => _GiveTipPageState();
}

class _GiveTipPageState extends State<GiveTipPage> {
  final List<double> _presetAmounts = [1.0, 2.0, 5.0, 10.0];
  double? _selectedPreset;
  final TextEditingController _customTEC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _useCustom = false;
  String get _currencySymbol => AppStrings.currencySymbol;

  @override
  void initState() {
    super.initState();
    if (widget.tip != null && widget.tip! > 0) {
      if (_presetAmounts.contains(widget.tip)) {
        _selectedPreset = widget.tip;
      } else {
        _useCustom = true;
        _customTEC.text = widget.tip!.toString();
      }
    }
  }

  double get _effectiveAmount {
    if (_useCustom) {
      return double.tryParse(_customTEC.text) ?? 0.0;
    }
    return _selectedPreset ?? 0.0;
  }

  void _selectPreset(double amount) {
    setState(() {
      _selectedPreset = amount;
      _useCustom = false;
      _customTEC.clear();
    });
  }

  void _onCustomChanged(String value) {
    setState(() {
      _useCustom = value.isNotEmpty;
      _selectedPreset = null;
    });
  }

  void _submit() {
    final amount = _effectiveAmount;
    if (amount <= 0) {
      Navigator.pop(context, null);
      return;
    }
    Navigator.pop(context, amount.toString());
  }

  @override
  void dispose() {
    _customTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Give Tip".tr(),
      elevation: 0.5,
      body: Form(
        key: _formKey,
        child:
            VStack(
              [
                // Header icon + description
                VStack([
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedTips,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ).centered(),
                  UiSpacer.verticalSpace(space: 8),
                  "Show your appreciation for great service by tipping your driver."
                      .tr()
                      .text
                      .center
                      .gray500
                      .make()
                      .centered(),
                ]).py(8),

                UiSpacer.divider(),

                // Preset tip amounts
                "Select an amount".tr().text.sm.gray500.make(),
                UiSpacer.verticalSpace(space: 8),
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.6,
                  children:
                      _presetAmounts.map((amount) {
                        final isSelected =
                            _selectedPreset == amount && !_useCustom;
                        return GestureDetector(
                          onTap: () => _selectPreset(amount),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child:
                                "$_currencySymbol${amount.toStringAsFixed(0)}"
                                    .text
                                    .semiBold
                                    .color(
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    )
                                    .make(),
                          ),
                        );
                      }).toList(),
                ),

                UiSpacer.verticalSpace(space: 4),

                // Custom amount
                VStack([
                  "Or enter a custom amount".tr().text.sm.gray500.make(),
                  8.heightBox,
                  TextFormField(
                    controller: _customTEC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: _onCustomChanged,
                    decoration: InputDecoration(
                      hintText: "0.00",
                      prefixText: "$_currencySymbol ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              _useCustom
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                          width: _useCustom ? 1.5 : 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ]),
                UiSpacer.divider(),

                // Summary
                if (_effectiveAmount > 0)
                  HStack([
                    "You are tipping".tr().text.make(),
                    Spacer(),
                    "$_currencySymbol ${_effectiveAmount.toStringAsFixed(2)}"
                        .text
                        .semiBold
                        .xl
                        .color(Theme.of(context).colorScheme.primary)
                        .make(),
                  ]).py(4),

                // Actions
                VStack([
                  CustomButton(
                    title:
                        _effectiveAmount > 0
                            ? "${"Tip".tr()} $_currencySymbol ${_effectiveAmount.toStringAsFixed(2)}"
                            : "Skip".tr(),
                    isFixedHeight: true,
                    onPressed: _submit,
                  ).h(Vx.dp56).wFull(context),
                  //
                  if (_effectiveAmount > 0)
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: "Skip".tr().text.gray500.make(),
                    ).wFull(context),
                ], spacing: 4),
              ],
              crossAlignment: CrossAxisAlignment.start,
              alignment: MainAxisAlignment.start,
              spacing: 10,
            ).p20().scrollVertical(),
      ),
    );
  }
}
