import 'package:flutter/material.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/requests/favourite.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';

class FavouriteVendorViewModel extends MyBaseViewModel {
  //
  FavouriteRequest favouriteRequest = FavouriteRequest();

  //
  FavouriteVendorViewModel(BuildContext context, Vendor vendor) {
    this.viewContext = context;
    this.vendor = vendor;
  }

  //
  removeFavourite() async {
    setBusy(true);
    //
    final apiResponse = await favouriteRequest.removeFavouriteVendor(
      vendor!.id,
    );

    //remove from list
    if (apiResponse.allGood) {
      vendor!.isFavourite = false;
    } else {
      toastError("${apiResponse.message}");
    }

    setBusy(false);
  }

  //
  addFavourite() async {
    setBusy(true);
    //
    final apiResponse = await favouriteRequest.makeFavouriteVendor(
      vendor!.id,
    );

    print("result ==> ${apiResponse.body}");
    //remove from list
    if (apiResponse.allGood) {
      vendor!.isFavourite = true;
    } else {
      toastError("${apiResponse.message}");
    }

    setBusy(false);
  }
}
