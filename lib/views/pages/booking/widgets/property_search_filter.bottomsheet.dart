import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/property_amenity.dart';
import 'package:fuodz/models/property_type.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/property_search.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_chip_group.dart';
import 'package:fuodz/widgets/filters/ops_autocomplete.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:jiffy/jiffy.dart';

class PropertySearchFilterBottomSheet extends StatefulWidget {
  final PropertySearchViewModel model;
  const PropertySearchFilterBottomSheet(this.model, {Key? key})
    : super(key: key);

  @override
  _PropertySearchFilterBottomSheetState createState() =>
      _PropertySearchFilterBottomSheetState();
}

class _PropertySearchFilterBottomSheetState
    extends State<PropertySearchFilterBottomSheet> {
  //
  RangeValues priceRange = RangeValues(0, 1000);
  int guests = 0;
  int bedrooms = 0;
  int beds = 0;
  int baths = 0;

  @override
  void initState() {
    super.initState();
    priceRange = RangeValues(
      widget.model.minPrice ?? 0,
      widget.model.maxPrice ?? 10000,
    );
    guests = widget.model.minGuests ?? 0;
    bedrooms = widget.model.minBedrooms ?? 0;
    beds = widget.model.minBeds ?? 0;
    baths = widget.model.minBathrooms ?? 0;
  }

  bool get canSearch {
    return (widget.model.searchTEC.text.isNotEmpty ||
            (widget.model.checkInDate != null &&
                widget.model.checkOutDate != null) ||
            guests > 0 ||
            bedrooms > 0 ||
            beds > 0 ||
            baths > 0 ||
            widget.model.selectedPropertyTypes.isNotEmpty ||
            widget.model.selectedAmenities.isNotEmpty ||
            priceRange.start > 0 ||
            priceRange.end < widget.model.filterMaxPrice) &&
        widget.model.selectedLocation != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: context.percentHeight * 50,
        maxHeight: context.percentHeight * 85,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.paddingSizeDefault,
        vertical: Sizes.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Sizes.radiusLarge),
          topRight: Radius.circular(Sizes.radiusLarge),
        ),
      ),
      child:
          VStack([
            // Header
            HStack([
              "Where?".tr().text.xl2.semiBold.make().expand(),
              "Clear all".tr().text.color(Colors.red).make().onInkTap(() {
                widget.model.resetFilters();
                setState(() {
                  priceRange = RangeValues(0, 10000);
                  guests = 0;
                  bedrooms = 0;
                  beds = 0;
                  baths = 0;
                });
              }),
            ]),
            UiSpacer.verticalSpace(),

            Expanded(
              child: SingleChildScrollView(
                child: VStack([
                  // Where Section
                  OPSAutocompleteTextField(
                    textEditingController: widget.model.searchTEC,
                    fetchPlaceDetails: false,
                    onSubmitted: (value) {
                      widget.model.onSearchSubmitted(value);
                      Navigator.pop(context);
                    },
                    onselected: (address) {
                      widget.model.onLocationSelected(address);
                    },
                    debounceTime: 800,
                    inputDecoration: InputDecoration(
                      hintText: "Search destinations".tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                    ),
                  ),

                  20.heightBox,
                  //radius slider: 0-100km
                  "Radius".tr().text.xl.bold.make(),
                  5.heightBox,
                  RangeSlider(
                    values: RangeValues(0, 100),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: AppColor.primaryColor,
                    inactiveColor: Colors.grey.withOpacity(0.3),
                    labels: RangeLabels("${0.round()}km", "${100.round()}km"),
                    onChanged: (RangeValues values) {
                      setState(() {
                        widget.model.searchRdius = values.start.round();
                      });
                    },
                  ),
                  20.heightBox,

                  // When Section
                  "When".tr().text.xl.bold.make(),
                  5.heightBox,
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HStack([
                      (widget.model.checkInDate != null &&
                              widget.model.checkOutDate != null)
                          ? "${Jiffy.parseFromDateTime(widget.model.checkInDate!).format(pattern: "MMM do")} - ${Jiffy.parseFromDateTime(widget.model.checkOutDate!).format(pattern: "MMM do")}"
                              .text
                              .make()
                              .expand()
                          : "Add dates".tr().text.gray500.make().expand(),
                      Icon(Icons.calendar_month, color: Colors.grey),
                    ]),
                  ).onInkTap(() async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      initialDateRange:
                          widget.model.checkInDate != null &&
                                  widget.model.checkOutDate != null
                              ? DateTimeRange(
                                start: widget.model.checkInDate!,
                                end: widget.model.checkOutDate!,
                              )
                              : null,
                    );
                    if (picked != null) {
                      setState(() {
                        widget.model.checkInDate = picked.start;
                        widget.model.checkOutDate = picked.end;
                      });
                    }
                  }),

                  UiSpacer.verticalSpace(),

                  // Who Section
                  "Who".tr().text.xl.bold.make(),
                  5.heightBox,
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: VStack([
                      _buildCounterRow("Guests", guests, (val) {
                        setState(() => guests = val);
                      }),
                      UiSpacer.verticalSpace(space: 10),
                      _buildCounterRow("Bedrooms", bedrooms, (val) {
                        setState(() => bedrooms = val);
                      }),
                      UiSpacer.verticalSpace(space: 10),
                      _buildCounterRow("Beds", beds, (val) {
                        setState(() => beds = val);
                      }),
                      UiSpacer.verticalSpace(space: 10),
                      _buildCounterRow("Baths", baths, (val) {
                        setState(() => baths = val);
                      }),
                    ]),
                  ),

                  UiSpacer.verticalSpace(),
                  Divider(),
                  UiSpacer.verticalSpace(),

                  // Property Type
                  "Property Type".tr().text.lg.semiBold.make(),
                  10.heightBox,
                  ValueListenableBuilder(
                    valueListenable: widget.model.propertyTypesNotifier,
                    builder: (context, value, child) {
                      return LoadingShimmer(
                        loading: widget.model.busy(
                          widget.model.fetchFilterData,
                        ),
                        child: CustomChipGroup<PropertyType, int>(
                          items: widget.model.propertyTypes,
                          labelBuilder: (type) => type.name,
                          valueBuilder: (type) => type.id,
                          selectedItems: widget.model.selectedPropertyTypes,
                          onChanged: (items) {
                            setState(() {
                              widget.model.selectedPropertyTypes = items;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  UiSpacer.verticalSpace(),

                  // Amenities
                  "Amenities".tr().text.lg.semiBold.make(),
                  UiSpacer.verticalSpace(space: 10),
                  ValueListenableBuilder(
                    valueListenable: widget.model.propertyAmenitiesNotifier,
                    builder: (context, value, child) {
                      return LoadingShimmer(
                        loading: widget.model.busy(
                          widget.model.fetchFilterData,
                        ),
                        child: CustomChipGroup<PropertyAmenity, int>(
                          items: widget.model.propertyAmenities,
                          labelBuilder: (amenity) => amenity.name,
                          valueBuilder: (amenity) => amenity.id,
                          selectedItems: widget.model.selectedAmenities,
                          onChanged: (items) {
                            setState(() {
                              widget.model.selectedAmenities = items;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  UiSpacer.verticalSpace(),

                  // Price Range
                  "Price Range".tr().text.lg.semiBold.make(),
                  UiSpacer.verticalSpace(space: 5),
                  RangeSlider(
                    values: priceRange,
                    min: widget.model.filterMinPrice,
                    max: widget.model.filterMaxPrice,
                    divisions: 100,
                    activeColor: AppColor.primaryColor,
                    inactiveColor: Colors.grey.withOpacity(0.3),
                    labels: RangeLabels(
                      "${priceRange.start.round()}",
                      "${priceRange.end.round()}+",
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        priceRange = values;
                      });
                    },
                  ),
                  HStack([
                    "${priceRange.start.round()}".text.make(),
                    Spacer(),
                    "${priceRange.end.round()}".text.make(),
                  ]),
                  UiSpacer.verticalSpace(),
                ]),
              ),
            ),

            // Apply Button
            CustomButton(
              title: "Search".tr(),
              onPressed:
                  canSearch
                      ? () {
                        widget.model.minPrice = priceRange.start;
                        widget.model.maxPrice = priceRange.end;
                        widget.model.minGuests = guests;
                        widget.model.minBedrooms = bedrooms;
                        widget.model.minBeds = beds;
                        widget.model.minBathrooms = baths;
                        widget.model.applyFilters();
                        Navigator.pop(context);
                      }
                      : null,
            ).wFull(context),
          ]).safeArea(),
    );
  }

  Widget _buildCounterRow(String title, int value, Function(int) onChanged) {
    return HStack([
      title.tr().text.lg.semiBold.make().expand(),
      HStack([
        // Decrease
        IconButton(
          onPressed: () {
            if (value > 0) {
              onChanged(value - 1);
            }
          },
          icon: Icon(Icons.remove_circle_outline, color: Colors.grey),
        ),
        // Value
        value.text.xl.bold.make().w(30).centered(),
        // Increase
        IconButton(
          onPressed: () {
            onChanged(value + 1);
          },
          icon: Icon(Icons.add_circle_outline, color: AppColor.primaryColor),
        ),
      ]),
    ]);
  }
}
