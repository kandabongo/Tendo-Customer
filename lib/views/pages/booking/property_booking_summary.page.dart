import 'package:flutter/material.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/property_booking_summary.vm.dart';
import 'package:fuodz/views/pages/booking/widgets/booking_guest_selection.bottomsheet.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:fuodz/widgets/html_link_text_span.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyBookingSummaryPage extends StatelessWidget {
  const PropertyBookingSummaryPage({
    required this.property,
    required this.selectedDateRange,
    required this.totalPrice,
    Key? key,
  }) : super(key: key);

  final Property property;
  final DateTimeRange selectedDateRange;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyBookingSummaryViewModel>.reactive(
      viewModelBuilder:
          () => PropertyBookingSummaryViewModel(
            context,
            property,
            selectedDateRange,
            totalPrice,
          ),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          title: "Confirm and pay".tr(),
          showAppBar: true,
          showLeadingAction: true,
          isLoading: model.isBusy,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(Sizes.paddingSizeDefault),
            child: VStack([
              // Property Summary Card
              HStack([
                CustomImage(
                  imageUrl: model.property.mainPhoto,
                  width: 100,
                  height: 100,
                  boxFit: BoxFit.cover,
                ).cornerRadius(Sizes.radiusSmall),
                UiSpacer.horizontalSpace(),
                VStack([
                  model.property.name.text.semiBold.maxLines(2).make(),
                  UiSpacer.verticalSpace(space: 5),
                  model.property.address.text.sm.gray500.maxLines(2).make(),
                  UiSpacer.verticalSpace(space: 5),
                  HStack([
                    Icon(Icons.star, size: 14, color: AppColor.ratingColor),
                    " ${model.property.rating}".text.sm.make(),
                    " (${model.property.reviewsCount} ${'reviews'.tr()})"
                        .text
                        .xs
                        .gray500
                        .make(),
                  ]),
                ], crossAlignment: CrossAxisAlignment.start).expand(),
              ], crossAlignment: CrossAxisAlignment.start),
              UiSpacer.divider(),

              // Trip Details Section
              "Your Trip".tr().text.xl.semiBold.make(),

              // Dates
              HStack([
                VStack([
                  "Dates".tr().text.semiBold.make(),
                  "${Jiffy.parseFromDateTime(model.selectedDateRange.start).format(pattern: 'MMM dd')} - ${Jiffy.parseFromDateTime(model.selectedDateRange.end).format(pattern: 'MMM dd')}"
                      .text
                      .gray500
                      .make(),
                ], crossAlignment: CrossAxisAlignment.start).expand(),
                TextButton(
                  onPressed: () => model.openBookingDateSelection(),
                  child: "Edit".tr().text.underline.make(),
                ),
              ]),

              // Guests
              HStack([
                VStack([
                  "Guests".tr().text.semiBold.make(),
                  "%s guests"
                      .tr()
                      .fill([model.adults + model.children + model.infants])
                      .text
                      .gray500
                      .make(),
                ], crossAlignment: CrossAxisAlignment.start).expand(),
                TextButton(
                  onPressed: () => _openGuestSelectionModal(context, model),
                  child: "Edit".tr().text.underline.make(),
                ),
              ]),
              UiSpacer.divider(),

              // Payment Method Section
              VStack([
                "Payment Method".tr().text.xl.semiBold.make(),
                if (model.paymentMethods.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(Sizes.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                          color:
                              context.isDarkMode
                                  ? Colors.black12
                                  : Colors.grey.shade200,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<PaymentMethod>(
                        value: model.selectedPaymentMethod,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColor.primaryColor,
                        ),
                        hint: "Select payment method".tr().text.make(),
                        items:
                            model.paymentMethods.map((method) {
                              return DropdownMenuItem<PaymentMethod>(
                                value: method,
                                child: HStack([
                                  CustomImage(
                                    imageUrl: method.photo,
                                    width: 28,
                                    height: 28,
                                    boxFit: BoxFit.contain,
                                  ),
                                  UiSpacer.horizontalSpace(),
                                  method.name.text.lg.medium.make(),
                                ]),
                              );
                            }).toList(),
                        onChanged: model.selectPaymentMethod,
                      ),
                    ),
                  )
                else
                  "Loading payment methods...".tr().text.sm.gray500.make(),
              ], spacing: Sizes.paddingSizeSmall),
              UiSpacer.divider(),

              // Price Details Section
              "Price Details".tr().text.xl.semiBold.make(),
              VStack([
                _buildPriceRow(
                  "${AppStrings.currencySymbol} ${model.property.price} x ${model.selectedDateRange.duration.inDays} ${'nights'.tr()}",
                  "${AppStrings.currencySymbol} ${model.subTotal}"
                      .currencyFormat(),
                ),
                // Fees
                if (model.totalFees > 0)
                  _buildPriceRow(
                    "Taxes & Fees".tr(),
                    "${AppStrings.currencySymbol} ${model.totalFees}"
                        .currencyFormat(),
                  ),
                10.heightBox,
                UiSpacer.divider(),
                10.heightBox,
                HStack([
                  "Total".tr().text.bold.xl.make(),
                  Spacer(),
                  "${AppStrings.currencySymbol} ${model.totalPrice}"
                      .currencyFormat()
                      .text
                      .bold
                      .xl2
                      .make(),
                ]),
              ]),
              30.heightBox,

              // Action Button
              CustomButton(
                title: "Confirm and Pay".tr(),
                loading: model.isBusy,
                onPressed: model.placeOrder,
              ).wFull(context).h(50),

              //by selecting the button, the user agrees to the terms and conditions
              Builder(
                builder: (context) {
                  String htmlContent = "<p>";
                  htmlContent +=
                      "${"By selecting the button, I agree to the".tr()} ";
                  htmlContent +=
                      "<a href='${Api.terms}'>${"terms and conditions".tr()}</a>";
                  htmlContent += " ${"and".tr()} ";
                  htmlContent +=
                      "<a href='${Api.privacyPolicy}'>${"Privacy Policy".tr()}</a>";
                  htmlContent += "</p>";

                  return RichText(
                    text: HtmlLinkTextSpan.build(
                      htmlContent,
                      defaultTextStyle: context.textTheme.bodyMedium?.copyWith(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                      ),
                      onLinkTap: (link) {
                        launchUrlString(link);
                      },
                    ),
                  );
                },
              ),
            ], spacing: Sizes.paddingSizeDefault),
          ),
        );
      },
    );
  }

  void _openGuestSelectionModal(
    BuildContext context,
    PropertyBookingSummaryViewModel model,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BookingGuestSelelctionBottomSheet(model);
      },
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return HStack([label.text.gray600.make().expand(), amount.text.make()]);
  }
}
