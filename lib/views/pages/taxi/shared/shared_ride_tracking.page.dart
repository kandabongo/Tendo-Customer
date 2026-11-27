import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/view_models/shared_ride_tracking.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

/// SHARED RIDES (customer) — dedicated live-tracking screen.
///
/// Shows the live driver location, the customer's pickup/destination markers,
/// driver details, ETA, the current (server-authoritative) trip status, and an
/// aggregate co-rider progress line. Read-only: it never mutates trip state.
class SharedRideTrackingPage extends StatelessWidget {
  const SharedRideTrackingPage({required this.tripId, Key? key})
      : super(key: key);

  final int tripId;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SharedRideTrackingViewModel>.reactive(
      viewModelBuilder: () => SharedRideTrackingViewModel(context, tripId),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          title: "Shared Ride".tr(),
          showAppBar: true,
          showLeadingAction: true,
          isLoading: vm.isBusy && vm.status == null,
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: vm.initialCamera,
                  zoom: 14,
                ),
                padding: EdgeInsets.only(bottom: Vx.dp64 * 3.4),
                myLocationEnabled: true,
                markers: vm.mapMarkers,
                polylines: Set<Polyline>.of(vm.polylines.values),
                onMapCreated: vm.setMapController,
              ),

              // status + driver card
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: VStack([
                    _statusBanner(context, vm),
                    if (vm.driver != null) _driverCard(context, vm),
                  ], spacing: 8).p12(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBanner(BuildContext context, SharedRideTrackingViewModel vm) {
    return VStack([
      HStack([
        Icon(
          vm.status?.isNoDriver == true || vm.status?.isCancelled == true
              ? Icons.error_outline
              : Icons.navigation,
          color: AppColor.primaryColor,
          size: 20,
        ),
        vm.statusHeadline.text.lg.semiBold.make().px8().expand(),
        if (vm.etaMinutes != null && vm.status?.isSearching != true)
          "${vm.etaMinutes} min".text.bold.color(AppColor.primaryColor).make(),
      ]),
      if (vm.statusSubtitle.isNotEmpty)
        vm.statusSubtitle.text.sm.gray600.make().pOnly(top: 4),
      if (vm.coRidersSummary.isNotEmpty)
        vm.coRidersSummary.text.xs.gray500.make().pOnly(top: 4),
    ])
        .p12()
        .box
        .color(context.theme.colorScheme.surface)
        .roundedSM
        .outerShadow3Xl
        .make()
        .wFull(context);
  }

  Widget _driverCard(BuildContext context, SharedRideTrackingViewModel vm) {
    final d = vm.driver!;
    final vehicle = d.vehicle?.summary ?? "";
    return HStack([
      CustomImage(imageUrl: d.photo ?? "")
          .wh(Vx.dp56, Vx.dp56)
          .box
          .roundedFull
          .shadowXs
          .clip(Clip.antiAlias)
          .make(),
      VStack([
        (d.name ?? "Driver".tr()).text.lg.semiBold.make(),
        if (vehicle.isNotEmpty) vehicle.text.sm.gray600.make(),
        if (d.displayRating.isNotEmpty)
          HStack([
            Icon(Icons.star, size: 12, color: Colors.amber),
            d.displayRating.text.xs.gray600.make().px4(),
          ]).pOnly(top: 2),
      ], spacing: 2).px12().expand(),
      Visibility(
        visible: AppUISettings.canCallDriver && (d.phone ?? "").isNotEmpty,
        child: CustomButton(
          icon: FlutterIcons.phone_call_fea,
          iconColor: Colors.white,
          title: "",
          color: AppColor.primaryColor,
          shapeRadius: Vx.dp24,
          onPressed: vm.callDriver,
        ).wh(Vx.dp56, Vx.dp40),
      ),
    ])
        .p12()
        .box
        .color(context.theme.colorScheme.surface)
        .roundedSM
        .outerShadow3Xl
        .make()
        .wFull(context);
  }
}
