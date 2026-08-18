import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/requests/vendor_type.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/vendor/featured_vendors.page.dart';

class WelcomeViewModel extends MyBaseViewModel {
  //
  WelcomeViewModel(BuildContext context) {
    this.viewContext = context;
  }

  Widget? selectedPage;
  List<VendorType> vendorTypes = [];
  VendorTypeRequest vendorTypeRequest = VendorTypeRequest();
  bool showGrid = true;
  StreamSubscription? authStateSub;

  //true when the last vendor types fetch went out before the delivery
  //location was resolved - in that state an empty result doesn't mean
  //"no services", it means we haven't asked the server with a real
  //location yet, so the empty state view should stay hidden until the
  //location-triggered refetch (handleLocationStream) completes.
  bool isAwaitingLocation = true;

  //true only once we're confident there really are no services to show -
  //i.e. not busy, not still waiting on location, and the list is empty.
  bool get shouldShowEmptyVendorTypes =>
      !isBusy && !isAwaitingLocation && vendorTypes.isEmpty;

  //true while a shimmer/loading placeholder should show in place of vendor
  //types content - either an actual fetch in progress, or an empty result
  //that only means "no location yet" rather than "confirmed no services".
  bool get shouldShowVendorTypesLoading =>
      isBusy || (isAwaitingLocation && vendorTypes.isEmpty);

  //
  //
  Future<void> initialise({bool initial = true}) async {
    //
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }

    if (!initial) {
      pageKey = GlobalKey();
      notifyListeners();
    }

    if (initial) {
      await preloadDeliveryLocation();
      listenToAuth();
      handleLocationStream();
    }

    await getVendorTypes();
  }

  StreamSubscription? currentLocSub;
  handleLocationStream() async {
    //subscribed once from initialise(initial: true) only - this must not be
    //re-invoked on every location update, or each call stacks another live
    //listener on the static, app-lifetime location subject, a leak that
    //compounds with every reload/location change until the app OOMs.
    await currentLocSub?.cancel();

    //if there's no current address yet, the upcoming vendor types fetch
    //will go out without a location - flag that so an empty result reads
    //as "no location yet" rather than "confirmed no services".
    isAwaitingLocation = LocationService.currenctAddress == null;
    notifyListeners();

    currentLocSub = LocationService.currenctDeliveryAddressSubject.listen((
      event,
    ) async {
      await initialise(initial: false);
      isAwaitingLocation = false;
      notifyListeners();
    });
  }

  listenToAuth() {
    //subscribed once from initialise(initial: true) only - see
    //handleLocationStream for why re-subscribing on every call would leak.
    authStateSub?.cancel();
    authStateSub = AuthServices.listenToAuthState().listen((event) {
      genKey = GlobalKey();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    currentLocSub?.cancel();
    authStateSub?.cancel();
    super.dispose();
  }

  getVendorTypes() async {
    setBusy(true);
    try {
      vendorTypes = await vendorTypeRequest.index();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  openFeaturedVendors() async {
    Navigator.of(
      viewContext,
    ).push(MaterialPageRoute(builder: (context) => FeaturedVendorsPage()));
  }
}
