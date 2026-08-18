import 'package:flutter/material.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/search.vm.dart';
import 'package:fuodz/views/pages/search/widget/search_type.tag.dart';
// import 'package:fuodz/widgets/cards/custom.visibility.dart';
// import 'package:fuodz/widgets/toogle_grid_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorSearchHeaderview extends StatefulWidget {
  const VendorSearchHeaderview(
    this.model, {
    this.showProducts = false,
    this.showVendors = false,
    this.showProviders = false,
    this.showServices = false,
    this.padding = 12.0,
    this.defaultIndex,
    Key? key,
  }) : super(key: key);

  final SearchViewModel model;
  final bool showVendors;
  final bool showProviders;
  final bool showProducts;
  final bool showServices;
  final double padding;
  final int? defaultIndex;

  @override
  State<VendorSearchHeaderview> createState() => _VendorSearchHeaderviewState();
}

class _VendorSearchHeaderviewState extends State<VendorSearchHeaderview> {
  @override
  void initState() {
    super.initState();
    //
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.defaultIndex != null) {
        widget.model.setSlectedTag(widget.defaultIndex!);
      }
    });
  }

  //
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        if (widget.showServices)
          SearchTypeTag(
            title: "Services".tr(),
            onPressed: () => widget.model.setSlectedTag(3),
            selected: widget.model.selectTagId == 3,
          ),

        if (widget.showProducts)
          SearchTypeTag(
            title: "Products".tr(),
            onPressed: () => widget.model.setSlectedTag(2),
            selected: widget.model.selectTagId == 2,
          ),

        // vendors
        if (widget.showVendors)
          SearchTypeTag(
            title: "Vendors".tr(),
            onPressed: () => widget.model.setSlectedTag(1),
            selected: widget.model.selectTagId == 1,
          ),

        //providers
        if (widget.showProviders)
          SearchTypeTag(
            title: "Providers".tr(),
            onPressed: () => widget.model.setSlectedTag(1),
            selected: widget.model.selectTagId == 1,
          ),

        UiSpacer.horizontalSpace().expand(),
        // //toggle show grid or listview
        // CustomVisibilty(
        //   visible:
        //       widget.model.selectTagId == 2 || widget.model.selectTagId == 3,
        //   child: ToogleGridViewIcon(
        //     showGrid: widget.model.showGrid,
        //     onchange: widget.model.toggleShowGird,
        //   ),
        // ),
      ],
    ).py(widget.padding);
  }
}
