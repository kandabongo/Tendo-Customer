import 'package:flutter/material.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/models/property_report_Reason.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ReportPropertyListingViewModel extends MyBaseViewModel {
  ReportPropertyListingViewModel(BuildContext context, this.property) {
    this.viewContext = context;
  }

  final Property property;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  List<PropertyReportReason> reportReasons = [];
  PropertyReportReason? selectedReason;

  void initialise() {
    fetchReportReasons();
  }

  void fetchReportReasons() async {
    clearErrors();
    setBusy(true);
    try {
      final response = await HttpService().get(Api.propertyReportReasons);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        reportReasons =
            data.map((e) => PropertyReportReason.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching report reasons: $e");
      setError(error);
    }
    setBusy(false);
  }

  void onReasonSelected(PropertyReportReason? reason) {
    selectedReason = reason;
    reasonController.text = reason?.reason ?? "";
    notifyListeners();
  }

  void submitReport() async {
    if (selectedReason == null && reasonController.text.isEmpty) {
      toastError("Please select or enter a reason".tr());
      return;
    }
    if (detailsController.text.isEmpty) {
      toastError("Please enter details".tr());
      return;
    }

    setBusy(true);
    try {
      final response = await HttpService().post(Api.reportPropertyListing, {
        "property_id": property.id,
        "property_report_reason_id": selectedReason?.id,
        "details": detailsController.text,
      });
      ApiResponse apiResponse = ApiResponse.fromResponse(response);
      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Listing Reported Successfully".tr(),
          text: apiResponse.message,
        );
        setBusy(false);
        Navigator.pop(viewContext);
        return;
      } else {
        AlertService.error(title: "Error".tr(), text: apiResponse.message);
      }
    } catch (e) {
      print("Error reporting listing: $e");
      setError(e);
    }
    setBusy(false);
  }
}
