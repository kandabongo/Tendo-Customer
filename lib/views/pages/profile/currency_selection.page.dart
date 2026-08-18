import 'package:flutter/material.dart';
import 'package:fuodz/models/currency.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CurrencySelectionPage extends StatefulWidget {
  final Currency? currentCurrency;

  const CurrencySelectionPage({Key? key, this.currentCurrency})
    : super(key: key);

  @override
  State<CurrencySelectionPage> createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  List<Currency> currencies = [];
  Currency? selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.currentCurrency;
    currencies = AppCurrencySystemService().supportedCurrencies;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Select Currency".tr(),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final isSelected = selectedCurrency?.code == currency.code;

          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: ListTile(
              trailing: currency.symbol.text.medium.xl.make(),
              title: VStack([
                currency.name.text.semiBold.lg.make(),
                currency.code.text.make(),
              ]),
              leading:
                  isSelected
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.circle_outlined),
              onTap: () {
                setState(() {
                  selectedCurrency = currency;
                });
                // Here you would typically save the selection
                // and return the result
                Navigator.pop(context, currency);
              },
            ),
          );
        },
      ),
    );
  }
}
