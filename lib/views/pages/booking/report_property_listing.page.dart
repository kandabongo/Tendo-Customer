import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/property_report_reason.dart';
import 'package:fuodz/view_models/report_property_listing.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ReportPropertyListingPage extends StatelessWidget {
  const ReportPropertyListingPage({required this.property, Key? key})
    : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportPropertyListingViewModel>.reactive(
      viewModelBuilder: () => ReportPropertyListingViewModel(context, property),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          title: "Report this listing".tr(),
          showAppBar: true,
          showLeadingAction: true,
          isLoading: model.isBusy,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.paddingSizeDefault),
            child: VStack([
              VStack([
                "Why are you reporting this listing?"
                    .tr()
                    .text
                    .lg
                    .semiBold
                    .make(),

                "This will not be shared with the host."
                    .tr()
                    .text
                    .gray500
                    .make(),
              ]),

              // Reason Dropdown/Selection
              if (model.reportReasons.isNotEmpty) ...[
                VStack([
                  "Reason".tr().text.semiBold.make(),
                  DropdownButtonFormField<PropertyReportReason>(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Sizes.radiusSmall),
                      ),
                    ),
                    value: model.selectedReason,
                    items:
                        model.reportReasons.map((PropertyReportReason value) {
                          return DropdownMenuItem<PropertyReportReason>(
                            value: value,
                            child: Text(value.reason),
                          );
                        }).toList(),
                    onChanged: model.onReasonSelected,
                    hint: Text("Select a reason".tr()),
                  ),
                ], spacing: Sizes.paddingSizeSmall),
              ],

              // Or custom reason if "Other" or manual entry needed (optional)
              if (model.selectedReason == "Other" ||
                  model.reportReasons.isEmpty)
                CustomTextFormField(
                  labelText: "Reason".tr(),
                  textEditingController: model.reasonController,
                ),

              CustomTextFormField(
                labelText: "Details".tr(),
                textEditingController: model.detailsController,
                maxLines: 5,
              ),

              CustomButton(
                title: "Submit Report".tr(),
                loading: model.isBusy,
                onPressed: model.submitReport,
              ).wFull(context),
            ], spacing: Sizes.paddingSizeDefault),
          ),
        );
      },
    );
  }
}
