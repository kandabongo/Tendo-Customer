import 'package:flutter/material.dart';
import 'package:fuodz/view_models/wallet.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_easy_refresh_view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/finance/wallet_management.view.dart';
import 'package:fuodz/widgets/list_items/wallet_transaction.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with WidgetsBindingObserver {
  //
  WalletViewModel? vm;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm?.initialise();
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    vm ??= WalletViewModel(context);

    //
    return BasePage(
      title: "Wallet".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: ViewModelBuilder<WalletViewModel>.reactive(
        viewModelBuilder: () => vm!,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return CustomEasyRefreshView(
            refreshOnStart: false,
            onRefresh: () => vm.loadWalletData(),
            onLoad: () => vm.getWalletTransactions(initialLoading: false),
            dataset: [],
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            separator: 0.heightBox,
            loading: vm.isBusy,
            child: SingleChildScrollView(
              child: VStack(
                [
                  //
                  WalletManagementView(
                    viewmodel: vm,
                    breif: false,
                  ),

                  //transactions list
                  VStack(
                    [
                      "Wallet Transactions".tr().text.bold.xl.make(),
                      CustomListView(
                        noScrollPhysics: true,
                        isLoading: vm.busy(vm.walletTransactions),
                        dataSet: vm.walletTransactions,
                        itemBuilder: (context, index) {
                          return WalletTransactionListItem(
                              vm.walletTransactions[index]);
                        },
                        separatorBuilder: (_, __) => 10.heightBox,
                      ),
                    ],
                    spacing: 10,
                  ).px20(),
                ],
                spacing: 10,
              ),
            ),
          );
        },
      ),
    );
  }
}
