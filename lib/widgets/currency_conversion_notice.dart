import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CurrencyConversionNotice extends StatelessWidget {
  final double convertedAmount;
  final double originalAmount;
  final String? baseCurrency;
  final TextStyle? amountStyle;
  final TextStyle? noticeStyle;
  final EdgeInsets? padding;

  const CurrencyConversionNotice({
    Key? key,
    required this.convertedAmount,
    required this.originalAmount,
    this.baseCurrency,
    this.amountStyle,
    this.noticeStyle,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyService = AppCurrencySystemService();
    final currentSymbol = currencyService.currentCurrencySymbol;
    final baseSymbol =
        baseCurrency != null
            ? _getCurrencySymbol(baseCurrency!)
            : AppStrings.currencySymbol;
    final baseCurrencyCode = baseCurrency ?? AppStrings.currencyCode;

    return Container(
      padding: padding ?? EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: VStack([
        // Display converted amount
        "$currentSymbol${convertedAmount.toStringAsFixed(2)}".text
            .textStyle(amountStyle)
            .semiBold
            .lg
            .make(),

        5.heightBox,

        // Notice about actual charge
        "Note: Although the amount is displayed in %s, you will be charged %s in %s"
            .tr()
            .fill([
              "${currencyService.currentCurrencyCode}",
              "$baseSymbol ${originalAmount}".currencyFormat(),
              "$baseCurrencyCode",
            ])
            .text
            .textStyle(noticeStyle)
            .sm
            .color(Colors.grey.shade600)
            .make(),
      ]),
    );
  }

  String _getCurrencySymbol(String currencyCode) {
    // Get symbol from supported currencies or fallback to common symbols
    final currencyService = AppCurrencySystemService();
    final currency = currencyService.supportedCurrencies.firstWhere(
      (c) => c.code == currencyCode,
    );

    return currency.symbol;
  }
}
