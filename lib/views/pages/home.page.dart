import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/constants/app_upgrade_settings.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/views/pages/profile/profile.page.dart';
import 'package:fuodz/view_models/home.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';

import 'order/orders.page.dart';
import 'search/main_search.page.dart';
import 'welcome/widgets/cart.fab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;
  late HomeViewModel vm;
  @override
  void initState() {
    super.initState();
    //
    vm = HomeViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LocationService.currenctAddress == null) {
        LocationService.prepareLocationListener(true);
      }
      vm.initialise();

      // Handle any pending deep links after home page is loaded
      AppService().handlePendingDeepLink();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => vm,
        builder: (context, model, child) {
          return BasePage(
            // extendBodyBehindAppBar: false,
            backgroundColor: AppColor.faintBgColor,
            body: UpgradeAlert(
              showIgnore: !AppUpgradeSettings.forceUpgrade(),
              shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
              dialogStyle:
                  Platform.isIOS
                      ? UpgradeDialogStyle.cupertino
                      : UpgradeDialogStyle.material,
              upgrader: Upgrader(),
              child: PageView(
                controller: model.pageViewController,
                onPageChanged: model.onPageChanged,
                //disable swipe
                physics: NeverScrollableScrollPhysics(),
                children: [
                  model.homeView,
                  OrdersPage(),
                  MainSearchPage(),
                  ProfilePage(),
                ],
              ),
            ),
            fab: AppUISettings.showCart ? CartHomeFab(model) : null,
            fabLocation:
                AppUISettings.showCart
                    ? FloatingActionButtonLocation.centerDocked
                    : null,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: context.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, -2), // Negative Y offset for top shadow
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SafeArea(
                child: AnimatedBottomNavigationBar.builder(
                  itemCount: 4,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  blurEffect: false,
                  elevation: 0,
                  activeIndex: model.currentIndex,
                  onTap: model.onTabChange,
                  gapLocation: GapLocation.center,
                  notchSmoothness: NotchSmoothness.defaultEdge,
                  leftCornerRadius: 0,
                  rightCornerRadius: 0,
                  splashSpeedInMilliseconds: 10,
                  tabBuilder: (int index, bool isActive) {
                    final color =
                        isActive
                            ? AppColor.primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color;
                    List<String> titles = [
                      "Home".tr(),
                      "Orders".tr(),
                      "Search".tr(),
                      "Menu".tr(),
                    ];
                    List<List<List<dynamic>>> icons = [
                      HugeIcons.strokeRoundedHome03,
                      HugeIcons.strokeRoundedInboxUnread,
                      HugeIcons.strokeRoundedSearch01,
                      HugeIcons.strokeRoundedMenu08,
                    ];
                    //filled icons
                    List<List<List<dynamic>>> filledIcons = [
                      HugeIcons.strokeRoundedHome02,
                      HugeIcons.strokeRoundedInbox,
                      HugeIcons.strokeRoundedSearch02,
                      HugeIcons.strokeRoundedMenu03,
                    ];

                    Widget tab = Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: isActive ? filledIcons[index] : icons[index],
                          size: 22,
                          color: color,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.5),
                          child:
                              titles[index].text
                                  .scale(0.89)
                                  .fontWeight(
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  )
                                  .color(color)
                                  .make(),
                        ),
                      ],
                    );

                    //
                    return tab;
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
