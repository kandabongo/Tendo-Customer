import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/property_booking_details.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_text_button.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyBookingDetailsPage extends StatelessWidget {
  const PropertyBookingDetailsPage(this.order, {this.paymentLink, Key? key})
    : super(key: key);

  final Order order;
  final String? paymentLink;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyBookingDetailsViewModel>.reactive(
      viewModelBuilder:
          () => PropertyBookingDetailsViewModel(
            context,
            order,
            paymentLink: paymentLink,
          ),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        final booking = model.order.bookingOrder;
        final property = booking?.property;

        return BasePage(
          title: "Booking Details".tr(),
          showAppBar: true,
          showLeadingAction: true,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(Sizes.paddingSizeDefault),
            child: VStack([
              // 1. Header Section: Property Info & Status
              _buildHeaderSection(context, model, property),
              UiSpacer.verticalSpace(),

              // 2. Reservation Details (Check-in/out, guests)
              if (booking != null)
                _buildReservationInfo(context, model, booking),
              UiSpacer.verticalSpace(),

              // 3. Verification Code (if applicable)
              if (model.canShowVerificationCode) ...[
                _buildVerificationCodeSection(context, model),
                UiSpacer.verticalSpace(),
              ],

              // 4. Host Info
              _buildHostInfo(context, model),
              UiSpacer.verticalSpace(),

              // 5. Payment Details
              _buildPaymentDetails(context, model, booking),
              UiSpacer.verticalSpace(space: 30),

              // 6. Action Buttons
              if (model.showPayButton)
                CustomButton(
                  title: "Pay Now".tr(),
                  onPressed: model.openPaymentLink,
                ).wFull(context),

              // Cancel Button? (We can check model.order.canCancel)
              Sizes.paddingSizeDefault.heightBox,
              if (model.order.canCancel)
                CustomTextButton(
                  loading: model.isBusy,
                  title: "Cancel Booking".tr(),
                  titleColor: Colors.red,
                  onPressed: model.processOrderCancel,
                ).box.border(color: Colors.red).roundedSM.make().wFull(context),

              20.heightBox,
            ]),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    PropertyBookingDetailsViewModel model,
    Property? property,
  ) {
    return VStack([
      // Property Image
      Stack(
        children: [
          CustomImage(
            imageUrl: property?.mainPhoto ?? "",
            width: double.infinity,
            height: 200,
            boxFit: BoxFit.cover,
          ).cornerRadius(Sizes.radiusDefault),
          // Status Badge
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  "${model.order.status}"
                      .allWordsCapitilize()
                      .text
                      .white
                      .bold
                      .xs
                      .make(),
            ),
          ),
        ],
      ),
      UiSpacer.verticalSpace(),

      // Property Name & Address
      InkWell(
        onTap: model.openPropertyDetails,
        child: VStack([
          (property?.name ?? "Property Name").text.xl2.semiBold
              .maxLines(2)
              .ellipsis
              .make(),
          UiSpacer.verticalSpace(space: 5),
          HStack([
            Icon(Feather.map_pin, size: 14, color: Colors.grey),
            UiSpacer.horizontalSpace(space: 5),
            (property?.address ?? "Address").text.sm
                .color(Colors.grey)
                .maxLines(2)
                .ellipsis
                .make()
                .expand(),
          ]),
        ]),
      ),
      UiSpacer.verticalSpace(),

      // Booking ID
      HStack([
            "${"Code".tr()}:".text.gray500.make(),
            UiSpacer.horizontalSpace(space: 5),
            "${model.order.code}".text.bold.make(),
          ])
          .p8()
          .box
          .color(context.canvasColor)
          .border(color: context.theme.dividerColor)
          .roundedSM
          .make(),
    ]);
  }

  Widget _buildReservationInfo(
    BuildContext context,
    PropertyBookingDetailsViewModel model,
    dynamic booking,
  ) {
    // Check-in/out display
    final checkIn = Jiffy.parse(
      "${booking.checkInDate.toString().split(" ")[0]} ${booking.checkInTime}",
    );
    final checkOut = Jiffy.parse(
      "${booking.checkOutDate.toString().split(" ")[0]} ${booking.checkOutTime}",
    );

    return Container(
      padding: EdgeInsets.all(Sizes.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(Sizes.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: VStack([
        // Dates Row
        HStack([
          _dateColumn("Check-in", checkIn),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ).px16(),
          _dateColumn("Check-out", checkOut),
        ], alignment: MainAxisAlignment.spaceAround).wFull(context),

        UiSpacer.divider().py12(),

        // Guests & Nights Row
        HStack([
          _infoItem(
            Feather.users,
            "Guests".tr(),
            "${booking.numberOfGuests} ${booking.numberOfGuests == 1 ? 'Guest' : 'Guests'}",
          ),
          Spacer(),
          _infoItem(
            Feather.moon,
            "Nights".tr(),
            "${booking.numberOfNights} ${booking.numberOfNights == 1 ? 'Night' : 'Nights'}",
          ),
        ]),
      ]),
    );
  }

  Widget _dateColumn(String label, Jiffy date) {
    return VStack([
      label.tr().text.xs.gray500.uppercase.make(),
      UiSpacer.verticalSpace(space: 4),
      date
          .format(pattern: "dd MMM")
          .text
          .xl
          .bold
          .color(AppColor.primaryColor)
          .make(),
      date.format(pattern: "h:mm a").text.sm.gray600.make(),
    ], crossAlignment: CrossAxisAlignment.start);
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return HStack([
      Icon(icon, size: 18, color: AppColor.primaryColor),
      UiSpacer.horizontalSpace(space: 8),
      VStack([label.tr().text.xs.gray500.make(), value.text.semiBold.make()]),
    ]);
  }

  Widget _buildVerificationCodeSection(
    BuildContext context,
    PropertyBookingDetailsViewModel model,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Sizes.paddingSizeDefault),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Sizes.radiusDefault),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.2)),
      ),
      child: VStack([
        HStack([
          Icon(Icons.shield_outlined, color: AppColor.primaryColor),
          UiSpacer.horizontalSpace(),
          "Verification Code"
              .tr()
              .text
              .semiBold
              .color(AppColor.primaryColor)
              .lg
              .make()
              .expand(),
          IconButton(
            icon: Icon(
              model.showVerificationCode ? Feather.eye_off : Feather.eye,
              color: AppColor.primaryColor,
            ),
            onPressed: model.toggleVerificationCode,
          ),
        ]),
        if (model.showVerificationCode)
          VStack([
            UiSpacer.verticalSpace(space: 10),
            model.order.verificationCode.text.xl4.bold
                .letterSpacing(3)
                .center
                .make()
                .centered(),
            UiSpacer.verticalSpace(space: 5),
            "Identify yourself to the host with this code"
                .tr()
                .text
                .xs
                .gray500
                .center
                .make()
                .centered(),
          ]),
      ]),
    );
  }

  Widget _buildHostInfo(
    BuildContext context,
    PropertyBookingDetailsViewModel model,
  ) {
    final vendor = model.order.vendor;
    return VStack([
      "Host".tr().text.lg.semiBold.make(),
      UiSpacer.verticalSpace(space: 10),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CustomImage(
          imageUrl: vendor?.logo ?? "",
          width: 50,
          height: 50,
          boxFit: BoxFit.cover,
        ).cornerRadius(50),
        title: (vendor?.name ?? "").text.semiBold.make(),
        subtitle:
            (vendor?.address ?? "").text.xs.gray500.maxLines(1).ellipsis.make(),
        trailing: HStack([
          // Call Button
          if (vendor?.phone != null)
            IconButton(
              icon: Icon(Feather.phone_call, color: AppColor.primaryColor),
              onPressed: model.callHost,
              style: IconButton.styleFrom(
                backgroundColor: AppColor.primaryColor.withOpacity(0.1),
              ),
            ),
          // We can add Chat button here later if needed
        ]),
      ),
    ]);
  }

  Widget _buildPaymentDetails(
    BuildContext context,
    PropertyBookingDetailsViewModel model,
    dynamic booking,
  ) {
    return VStack([
      "Payment Details".tr().text.lg.semiBold.make(),
      UiSpacer.verticalSpace(space: 10),
      Container(
        padding: EdgeInsets.all(Sizes.paddingSizeDefault),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(Sizes.radiusDefault),
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: VStack([
          if (booking != null) ...[
            _priceRow(
              "Base Price".tr(),
              "${AppStrings.currencySymbol} ${booking.basePrice}"
                  .currencyFormat(),
            ),
            UiSpacer.verticalSpace(space: 8),
            _priceRow("Nights".tr(), "x ${booking.numberOfNights}"),
            UiSpacer.divider().py8(),
          ],

          if (model.order.tax != null && model.order.tax! > 0) ...[
            _priceRow(
              "Tax".tr(),
              "${AppStrings.currencySymbol} ${model.order.tax}"
                  .currencyFormat(),
            ),
            UiSpacer.verticalSpace(space: 8),
          ],

          if (model.order.fees != null && model.order.fees!.isNotEmpty) ...[
            ...model.order.fees!.map((fee) {
              return VStack([
                _priceRow(
                  "${fee.name}".tr(),
                  "${AppStrings.currencySymbol} ${fee.amount}".currencyFormat(),
                ),
                UiSpacer.verticalSpace(space: 8),
              ]);
            }).toList(),
          ],

          // Total
          HStack([
            "Total Amount".tr().text.lg.bold.make(),
            Spacer(),
            "${AppStrings.currencySymbol} ${model.order.total}"
                .currencyFormat()
                .text
                .xl
                .bold
                .color(AppColor.primaryColor)
                .make(),
          ]),

          UiSpacer.verticalSpace(space: 8),
          UiSpacer.divider(),
          UiSpacer.verticalSpace(space: 8),

          HStack([
            "Payment Method".tr().text.sm.gray500.make(),
            Spacer(),
            "${model.order.paymentMethod?.name ?? 'Cash'}"
                .tr()
                .text
                .sm
                .semiBold
                .make(),
          ]),
          UiSpacer.verticalSpace(space: 5),

          HStack([
            "Status".tr().text.sm.gray500.make(),
            Spacer(),
            "${model.order.paymentStatus}"
                .tr()
                .allWordsCapitilize()
                .text
                .sm
                .color(
                  model.order.paymentStatus == "successful"
                      ? Colors.green
                      : Colors.orange,
                )
                .semiBold
                .make(),
          ]),
        ]),
      ),
    ]);
  }

  Widget _priceRow(String label, String value) {
    return HStack([
      label.text.gray600.make(),
      Spacer(),
      value.text.semiBold.make(),
    ]);
  }
}
