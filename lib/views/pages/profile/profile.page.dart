import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/profile.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/cards/profile.card.dart';
import 'package:fuodz/widgets/menu_item.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      disposeViewModel: false,
      builder: (context, model, child) {
        return BasePage(
          allowTopSafeArea: true,
          body:
              VStack([
                //
                "Settings".tr().text.xl2.semiBold.make(),
                "Profile & App Settings".tr().text.lg.light.make(),

                //profile card
                ProfileCard(model).py12(),

                //menu
                VStack([
                  //
                  if (AppCurrencySystemService().supportedCurrencies.isNotEmpty)
                    MenuItem(
                      title: "Currency".tr(),
                      divider: false,
                      prefix: HugeIcon(
                        icon: HugeIcons.strokeRoundedMoneyExchange01,
                      ),
                      suffix:
                          AppCurrencySystemService().currentCurrencySymbol.text
                              .make(),
                      onPressed: () {
                        //
                        AppCurrencySystemService().initAppCurrencyChange();
                      },
                    ),

                  MenuItem(
                    title: "Language".tr(),
                    divider: false,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedGlobal),
                    onPressed: model.changeLanguage,
                  ),
                  MenuItem(
                    title: "Theme".tr(),
                    suffix: Text(
                      AdaptiveTheme.of(context).mode.name.tr().capitalized,
                    ),
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedReload),
                    onPressed: () {
                      AdaptiveTheme.of(context).toggleThemeMode();
                    },
                  ),

                  20.heightBox,
                  //
                  MenuItem(
                    title: "Notifications".tr(),
                    prefix: HugeIcon(
                      icon: HugeIcons.strokeRoundedNotification01,
                    ),
                    onPressed: model.openNotification,
                  ),

                  //
                  MenuItem(
                    title: "Rate & Review".tr(),
                    onPressed: model.openReviewApp,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedStar),
                  ),

                  //
                  MenuItem(
                    title: "Faqs".tr(),
                    onPressed: model.openFaqs,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedQuestion),
                  ),
                  //
                  MenuItem(
                    title: "Privacy Policy".tr(),
                    onPressed: model.openPrivacyPolicy,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedBook02),
                  ),
                  //
                  MenuItem(
                    title: "Terms & Conditions".tr(),
                    onPressed: model.openTerms,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedShield01),
                  ),
                  //START NEW LINKS
                  MenuItem(
                    title: "Refund Policy".tr(),
                    onPressed: model.openRefundPolicy,
                    prefix: HugeIcon(
                      icon: HugeIcons.strokeRoundedReturnRequest,
                    ),
                  ),
                  MenuItem(
                    title: "Cancellation Policy".tr(),
                    onPressed: model.openCancellationPolicy,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
                  ),
                  MenuItem(
                    title: "Delivery/Shipping Policy".tr(),
                    onPressed: model.openShippingPolicy,
                    prefix: HugeIcon(
                      icon: HugeIcons.strokeRoundedShoppingBag01,
                    ),
                  ),
                  //END NEW LINKS
                  //
                  MenuItem(
                    title: "Contact Us".tr(),
                    onPressed: model.openContactUs,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedMail01),
                  ),
                  //
                  MenuItem(
                    title: "Live Support".tr(),
                    onPressed: model.openLivesupport,
                    prefix: HugeIcon(icon: HugeIcons.strokeRoundedBubbleChat),
                  ),
                ]),
                model.appVersionInfo.text.sm.medium.gray400
                    .makeCentered()
                    .py20(),
                //
                UiSpacer.verticalSpace(space: context.percentHeight * 10),
              ]).p20().scrollVertical(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
