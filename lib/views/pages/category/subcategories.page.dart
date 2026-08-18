import 'package:flutter/material.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/view_models/vendor/sub_categories.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/states/loading_indicator.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/widgets/cart_page_action.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fuodz/views/pages/category/widgets/subcategory_items.view.dart';
import 'package:velocity_x/velocity_x.dart';

class SubcategoriesPage extends StatelessWidget {
  const SubcategoriesPage({required this.category, Key? key}) : super(key: key);

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubcategoriesViewModel>.reactive(
      viewModelBuilder: () => SubcategoriesViewModel(context, category),
      onViewModelReady: (vm) => vm.initialise(),
      onDispose: (vm) => vm.searchKeywordStream.close(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showCart: !vm.showSearch,
          showLeadingAction: true,
          customAppbar:
              vm.showSearch
                  ? _buildSearchAppBar(context, vm)
                  : _buildNormalAppBar(context, vm),
          body: LoadingIndicator(
            loading: vm.isBusy,
            child: DefaultTabController(
              length: vm.subcategories.length,
              child: VStack([
                //tab bar
                TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: context.primaryColor,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: context.textTheme.bodyMedium,
                  tabs: [
                    ...vm.subcategories.map((sub) {
                      return Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: sub.name.text.make(),
                        ),
                      );
                    }).toList(),
                  ],
                ).p12(),

                //tab preview
                TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...vm.subcategories.map((sub) {
                      return SubcategoryItemsView(
                        category: category,
                        subcategory: sub,
                        //search stream
                        searchStream: vm.searchKeywordStream.stream,
                      );
                    }).toList(),
                  ],
                ).expand(),
              ]),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
    BuildContext context,
    SubcategoriesViewModel vm,
  ) {
    final textColor = Utils.textColorByPrimaryColor();
    return AppBar(
      backgroundColor: context.primaryColor,
      elevation: 0,
      title: category.name.text.white.make(),
      leading: IconButton(
        icon: Icon(
          !Utils.isArabic
              ? FlutterIcons.arrow_left_fea
              : FlutterIcons.arrow_right_fea,
          color: textColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(FlutterIcons.search_fea, size: 20, color: Colors.white),
          onPressed: vm.toggleSearch,
        ),
        PageCartAction(color: textColor),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar(
    BuildContext context,
    SubcategoriesViewModel vm,
  ) {
    final textColor = Utils.textColorByPrimaryColor();
    return AppBar(
      backgroundColor: context.primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(FlutterIcons.close_ant, size: 20, color: textColor),
        onPressed: vm.toggleSearch,
      ),
      title: TextField(
        controller: vm.searchTEC,
        onSubmitted: vm.onKeywordChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search...".tr(),
          border: InputBorder.none,
          hintStyle: context.textTheme.bodyLarge?.copyWith(color: textColor),
        ),
        style: context.textTheme.bodyLarge?.copyWith(color: textColor),
      ),
    );
  }
}
