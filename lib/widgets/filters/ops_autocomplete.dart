import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fuodz/models/address.dart';
import 'package:fuodz/view_models/ops_map.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OPSAutocompleteTextField extends StatelessWidget {
  const OPSAutocompleteTextField({
    required this.onselected,
    this.textEditingController,
    this.inputDecoration,
    this.onSubmitted,
    required this.debounceTime,
    this.fetchPlaceDetails = true,
    Key? key,
  }) : super(key: key);

  final Function(Address) onselected;
  final TextEditingController? textEditingController;
  final InputDecoration? inputDecoration;
  final Function(String)? onSubmitted;
  final int debounceTime;
  final bool fetchPlaceDetails;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OPSMapViewModel>.reactive(
      viewModelBuilder: () => OPSMapViewModel(context),
      builder: (ctx, vm, child) {
        return TypeAheadField<Address>(
          controller: textEditingController ?? vm.searchTEC,
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onFieldSubmitted: onSubmitted,
              decoration:
                  inputDecoration ??
                  InputDecoration(hintText: 'Search address'.tr()),
            );
          },

          //0.9 seconds
          debounceDuration: Duration(milliseconds: debounceTime),
          suggestionsCallback: (keyword) async {
            return await vm.fetchPlaces(keyword);
          },
          retainOnLoading: true,
          emptyBuilder: (ctx) {
            return "No Address found".tr().text.make().p12();
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: "${suggestion.addressLine}".text.base.semiBold.make(),
              subtitle: "${suggestion.adminArea}".text.sm.make(),
            );
          },

          onSelected: (address) async {
            if (fetchPlaceDetails) {
              final mAddress = await vm.fetchPlaceDetails(address);
              this.onselected(mAddress);
            } else {
              this.onselected(address);
            }
          },
        );
      },
    );
  }
}
