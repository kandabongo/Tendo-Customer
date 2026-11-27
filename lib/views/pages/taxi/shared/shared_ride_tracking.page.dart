import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/shared_ride_tracking.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_text_button.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
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

              // status + driver card + cancel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: VStack([
                    _statusBanner(context, vm),
                    if (vm.driver != null) _driverCard(context, vm),
                    if (vm.canCancel) _cancelButton(context, vm),
                  ], spacing: 8).p12(),
                ),
              ),

              // completion bill + rating overlay
              if (vm.isCompleted && !vm.ratingSubmitted)
                _completionOverlay(context, vm),
            ],
          ),
        );
      },
    );
  }

  Widget _cancelButton(BuildContext context, SharedRideTrackingViewModel vm) {
    return CustomButton(
      title: "Cancel ride".tr(),
      color: Colors.red.shade50,
      titleStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.w600,
      ),
      loading: vm.cancelling,
      onPressed: vm.cancelTrip,
    ).wFull(context);
  }

  // ---- completion: bill + rate the driver ------------------------------
  Widget _completionOverlay(BuildContext context, SharedRideTrackingViewModel vm) {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: _SharedCompletionSheet(vm: vm),
      ),
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

/// Completion bill + rate-the-driver sheet, shown when the customer's shared
/// leg is dropped / the trip completed. Reuses the existing rateDriver endpoint
/// via the view model; it never runs any payment itself (the fare was settled
/// server-side on completion).
class _SharedCompletionSheet extends StatefulWidget {
  const _SharedCompletionSheet({required this.vm, Key? key}) : super(key: key);
  final SharedRideTrackingViewModel vm;

  @override
  State<_SharedCompletionSheet> createState() => _SharedCompletionSheetState();
}

class _SharedCompletionSheetState extends State<_SharedCompletionSheet> {
  double _stars = 5;
  final TextEditingController _review = TextEditingController();

  @override
  void dispose() {
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final driver = vm.driver;
    final fare = vm.fareAmount;
    final content = VStack([
      HStack([
        "Trip completed".tr().text.xl2.semiBold.make().expand(),
        Icon(Icons.check_circle, color: Colors.green, size: 28),
      ]),
      UiDivider(),
      // fare / bill
      if (driver != null)
        HStack([
          CustomImage(imageUrl: driver.photo ?? "")
              .wh(44, 44)
              .box
              .roundedFull
              .clip(Clip.antiAlias)
              .make(),
          VStack([
            (driver.name ?? "Driver".tr()).text.semiBold.make(),
            if ((driver.vehicle?.summary ?? "").isNotEmpty)
              driver.vehicle!.summary.text.sm.gray600.make(),
          ], spacing: 2).px10().expand(),
        ]).py8(),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: HStack([
          "Fare".tr().text.lg.make().expand(),
          "${AppStrings.currencySymbol} ${fare.toStringAsFixed(2)}"
              .text
              .xl2
              .bold
              .color(AppColor.primaryColor)
              .make(),
        ]),
      ),
      UiSpacer.vSpace(14),
      "Rate your driver".tr().text.lg.semiBold.makeCentered(),
      RatingBar.builder(
        initialRating: 5,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: 34,
        itemBuilder: (context, _) =>
            Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: (r) => _stars = r,
      ).centered().py8(),
      CustomTextFormField(
        hintText: "Add a review (optional)".tr(),
        textEditingController: _review,
        minLines: 2,
        maxLines: 4,
      ),
      UiSpacer.vSpace(12),
      CustomButton(
        title: "Submit".tr(),
        loading: vm.submittingRating,
        onPressed: () async {
          await vm.submitRating(_stars, _review.text.trim());
          if (vm.ratingSubmitted) vm.finishAfterRating();
        },
      ).wFull(context),
      CustomTextButton(
        title: "Skip".tr(),
        onPressed: vm.finishAfterRating,
      ).wFull(context),
    ], spacing: 8);

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(20), child: content),
      ),
    );
  }
}

/// Simple full-width divider used in the completion sheet.
class UiDivider extends StatelessWidget {
  const UiDivider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Divider(color: Colors.grey.shade300, height: 16);
}
