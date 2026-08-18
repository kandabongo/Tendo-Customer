import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/wallet.vm.dart';
import 'package:fuodz/views/pages/wallet/wallet.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class GojekWalletCard extends StatefulWidget {
  const GojekWalletCard({Key? key}) : super(key: key);

  @override
  State<GojekWalletCard> createState() => _GojekWalletCardState();
}

class _GojekWalletCardState extends State<GojekWalletCard>
    with WidgetsBindingObserver {
  late WalletViewModel mViewmodel;

  @override
  void initState() {
    super.initState();
    mViewmodel = WalletViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mViewmodel.initialise();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      mViewmodel.initialise();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gojek wallet usually has specific blue styling #0081A0
    final Color walletColor = context.primaryColor;
    final textColor = Utils.textColorByColor(walletColor);
    final textreverseColor = Utils.textColorByColor(textColor);

    return ViewModelBuilder<WalletViewModel>.reactive(
      viewModelBuilder: () => mViewmodel,
      builder: (context, vm, child) {
        return StreamBuilder(
          stream: AuthServices.listenToAuthState(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData ||
                (snapshot.data is bool && snapshot.data == false)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: walletColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Balance section
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: textColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (vm.isBusy)
                              const BusyIndicator()
                            else
                              Text(
                                "${AppStrings.currencySymbol} ${vm.wallet?.balance ?? 0.00}"
                                    .currencyFormat(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textreverseColor,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              "Tap for history".tr(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(
                                  0xFF00AA13,
                                ), // Gojek green text inside wallet card
                              ),
                            ),
                          ],
                        ),
                      ).onInkTap(() => context.nextPage(const WalletPage())),
                    ),
                    const SizedBox(width: 12),
                    // Action Buttons (Send, Top Up, Receive)
                    Expanded(
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (AppUISettings.allowWalletTransfer)
                            _WalletActionIcon(
                              icon: HugeIcons.strokeRoundedMoneySend01,
                              label: "Send".tr(),
                              onTap: vm.showWalletTransferEntry,
                              textColor: textColor,
                            ),
                          _WalletActionIcon(
                            icon: HugeIcons.strokeRoundedMoneyAdd01,
                            label: "Top Up".tr(),
                            onTap: vm.showAmountEntry,
                            textColor: textColor,
                          ),
                          if (AppUISettings.allowWalletTransfer)
                            _WalletActionIcon(
                              icon: HugeIcons.strokeRoundedMoneyReceive01,
                              label: "Receive".tr(),
                              onTap: vm.showMyWalletAddress,
                              textColor: textColor,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _WalletActionIcon extends StatelessWidget {
  const _WalletActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textColor,
    Key? key,
  }) : super(key: key);

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(icon: icon, color: textColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
