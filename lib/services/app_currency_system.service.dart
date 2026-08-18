import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:singleton/singleton.dart';
import 'package:fuodz/models/currency.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/views/pages/profile/currency_selection.page.dart';
import 'package:fuodz/views/pages/splash.page.dart';
import 'package:velocity_x/velocity_x.dart';

class AppCurrencySystemService {
  static const String selectedCurrencyCodeKey = "selected_currency_code";

  /// Factory method that reuse same instance automatically
  factory AppCurrencySystemService() =>
      Singleton.lazy(() => AppCurrencySystemService._());

  /// Private constructor
  AppCurrencySystemService._() {}

  static late Map<String, dynamic> appExchangeRatesObject;

  init(Map<String, dynamic> exchangeRates) {
    //
    try {
      appExchangeRatesObject = exchangeRates;
      supportedCurrencies =
          (appExchangeRatesObject["currencies"] as List)
              .map((json) => Currency.fromJSON(json))
              .toList();
      final selectedCurrencyCode =
          LocalStorageService.prefs?.getString(selectedCurrencyCodeKey) ??
          AppStrings.currencyCode;
      _currency = supportedCurrencies.firstOrNullWhere(
        (currency) => currency.code == selectedCurrencyCode,
      );
    } catch (error) {
      debugPrint("Exchange rates failed:: $error");
    }
  }

  Currency? _currency;

  Currency? get currency => _currency;

  String get currentCurrencySymbol =>
      _currency?.symbol ?? AppStrings.currencySymbol;

  String get currentCurrencyCode => _currency?.code ?? AppStrings.currencyCode;

  List<Currency> supportedCurrencies = [];

  /// Convert amount from one currency to selected currency
  double convertToSelectedCurrency(double amount, {String? fromCurrency}) {
    if (_currency == null || appExchangeRatesObject.isEmpty) {
      return amount;
    }

    final baseCurrency = fromCurrency ?? AppStrings.currencyCode;
    final targetCurrency = _currency!.code;

    return _convertCurrency(amount, baseCurrency, targetCurrency);
  }

  /// Convert amount from selected currency to base currency
  double convertToBaseCurrency(double amount, {String? toCurrency}) {
    if (_currency == null || appExchangeRatesObject.isEmpty) {
      return amount;
    }

    final sourceCurrency = _currency!.code;
    final targetCurrency = toCurrency ?? AppStrings.currencyCode;

    return _convertCurrency(amount, sourceCurrency, targetCurrency);
  }

  /// Internal method to convert between any two currencies
  double _convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    // If same currency, no conversion needed
    if (fromCurrency == toCurrency) {
      return amount;
    }

    try {
      final conversionMatrix =
          appExchangeRatesObject["conversion_matrix"] as Map<String, dynamic>?;
      if (conversionMatrix == null) return amount;

      // Get the conversion rate from the matrix
      final fromCurrencyRates =
          conversionMatrix[fromCurrency] as Map<String, dynamic>?;
      if (fromCurrencyRates == null) return amount;

      final conversionData =
          fromCurrencyRates[toCurrency] as Map<String, dynamic>?;
      if (conversionData == null) return amount;

      // Check if conversion is available
      final isAvailable = conversionData["is_available"] as bool? ?? false;
      if (!isAvailable) return amount;

      // Get the conversion rate
      final rate = (conversionData["rate"] as num?)?.toDouble() ?? 1.0;

      // Convert the amount
      return amount * rate;
    } catch (e) {
      // Return original amount if conversion fails
      return amount;
    }
  }

  void initAppCurrencyChange() async {
    final context = AppService().navigatorKey.currentContext;
    if (context != null) {
      final selectedCurrency = await context.push((context) {
        return CurrencySelectionPage(currentCurrency: _currency);
      });

      //selectedCurrency != null
      if (selectedCurrency != null && selectedCurrency is Currency) {
        _saveSelectedCurrency(selectedCurrency);
      }
    }
  }

  _saveSelectedCurrency(Currency selectedCurrency) async {
    _currency = selectedCurrency;
    await LocalStorageService.prefs?.setString(
      selectedCurrencyCodeKey,
      selectedCurrency.code,
    );

    // Navigate to splash page to reload app settings
    final context = AppService().navigatorKey.currentContext;
    if (context != null) {
      context.nextAndRemoveUntilPage(SplashPage());
    }
  }
}

/// Extension for easy currency conversion
extension CurrencyConversion on double {
  /// Convert this amount to the currently selected currency (from base currency)
  double get convertCurrency =>
      AppCurrencySystemService().convertToSelectedCurrency(this);

  /// Convert this amount from a specific currency to the selected currency
  double convertFromCurrency(String fromCurrency) => AppCurrencySystemService()
      .convertToSelectedCurrency(this, fromCurrency: fromCurrency);

  /// Convert this amount from selected currency to base currency
  double get convertToBase =>
      AppCurrencySystemService().convertToBaseCurrency(this);

  /// Convert this amount from selected currency to a specific currency
  double convertToCurrency(String toCurrency) => AppCurrencySystemService()
      .convertToBaseCurrency(this, toCurrency: toCurrency);

  double convertIf(bool condition) {
    return condition ? this.convertCurrency : this;
  }
}
