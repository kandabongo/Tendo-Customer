import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/view_models/favourite_vendor.vm.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class FavVendorTag extends StatelessWidget {
  const FavVendorTag(this.vendor, {Key? key}) : super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    //fav icon
    return ViewModelBuilder<FavouriteVendorViewModel>.reactive(
      viewModelBuilder: () => FavouriteVendorViewModel(context, vendor),
      builder: (context, model, child) {
        return model.isBusy
            ? BusyIndicator().wh(18, 18).p4()
            : Icon(
                model.vendor!.isFavourite
                    ? FlutterIcons.favorite_mdi
                    : FlutterIcons.favorite_border_mdi,
                size: 22,
                color: context.theme.primaryColor,
              ).p4().onTap(
                () {
                  !model.isAuthenticated()
                      ? model.openLogin()
                      : !model.vendor!.isFavourite
                          ? model.addFavourite()
                          : model.removeFavourite();
                },
              );
      },
    );
  }
}
