import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/property_details.vm.dart';
import 'package:fuodz/views/pages/booking/property_reviews.page.dart';
import 'package:fuodz/views/pages/booking/widgets/property_fav.icon.dart';
import 'package:fuodz/views/pages/booking/widgets/property_reservation_date.section.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/list_items/property_review.list_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyDetailsPage extends StatelessWidget {
  const PropertyDetailsPage({required this.property, Key? key})
    : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyDetailsViewModel>.reactive(
      viewModelBuilder: () => PropertyDetailsViewModel(context, property),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: false,
          backgroundColor: context.backgroundColor,
          isLoading: model.isBusy,
          body: CustomScrollView(
            slivers: [
              // Header Images
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _PropertyPhotosCarousel(
                    photos: model.property.photos,
                    height: 300,
                  ),
                ),
                leading:
                    IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ).box
                        .color(Colors.black.withOpacity(0.3))
                        .roundedFull
                        .make()
                        .p8(),
                actions: [
                  IconButton(
                        icon: Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          model.shareProperty(model.property);
                        },
                      ).box
                      .color(Colors.black.withOpacity(0.3))
                      .roundedFull
                      .make()
                      .p8(),
                  PropertyFavIcon(model.property),
                  UiSpacer.hSpace(8),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    // vertical: Sizes.paddingSizeDefault,
                    horizontal: Sizes.paddingSizeDefault,
                  ),
                  child: VStack([
                    // Title & Location
                    VStack(
                      [
                        model.property.name.text.xl2.bold.make(),
                        Sizes.paddingSizeExtraSmall.heightBox,
                        "${model.property.city}, ${model.property.country}"
                            .text
                            .gray700
                            .make(),
                        Sizes.paddingSizeSmall.heightBox,
                        if (model.property.reviewsCount > 0)
                          HStack([
                            Icon(Icons.star, size: 16, color: Colors.black),
                            " ${model.property.rating} • ".text.semiBold.make(),
                            //reviews count
                            "${model.property.reviewsCount} ${"reviews".tr()}"
                                .text
                                .gray500
                                .make(),
                          ])
                        else
                          "No reviews yet".tr().text.gray500.center.make(),
                      ],
                      crossAlignment: CrossAxisAlignment.center,
                      alignment: MainAxisAlignment.center,
                    ).wFull(context),

                    UiSpacer.divider(),

                    // Property Details (Beds/Baths)
                    HStack(
                      [
                        _detailItem(
                          Icons.group_outlined,
                          "${model.property.maxGuests} ${"guests".tr()}",
                        ),
                        _detailItem(
                          Icons.bedroom_child_outlined,
                          "${model.property.bedrooms} ${"bedrooms".tr()}",
                        ),
                        _detailItem(
                          Icons.bed_outlined,
                          "${model.property.beds} ${"beds".tr()}",
                        ),
                        _detailItem(
                          Icons.bathtub_outlined,
                          "${model.property.bathrooms} ${"baths".tr()}",
                        ),
                      ],
                      spacing: 10,
                      axisSize: MainAxisSize.max,
                      alignment: MainAxisAlignment.spaceBetween,
                    ),

                    UiSpacer.divider(),

                    // Description
                    VStack([
                      "About this place".tr().text.lg.bold.make(),
                      10.heightBox,
                      model.property.description.text.make(),
                    ]),

                    UiSpacer.divider(),

                    // Amenities
                    if (model.property.amenities.isNotEmpty)
                      VStack([
                        "What this place offers".tr().text.lg.bold.make(),
                        15.heightBox,
                        ...(model.showAllAmenities
                                ? model.property.amenities
                                : model.property.amenities.take(5))
                            .map((amenity) {
                              return HStack([
                                CustomImage(
                                  imageUrl: amenity.photo,
                                  width: 22,
                                  height: 22,
                                ),
                                Sizes.paddingSizeDefault.widthBox,
                                amenity.name.text.lg.make().expand(),
                              ]).pOnly(bottom: 10);
                            })
                            .toList(),
                        if (model.property.amenities.length > 5 &&
                            !model.showAllAmenities)
                          OutlinedButton(
                            onPressed: model.toggleShowAllAmenities,
                            child:
                                "Show all %s amenities"
                                    .tr()
                                    .fill([model.property.amenities.length])
                                    .text
                                    .make(),
                          ).wFull(context),
                      ]),
                    if (model.property.latitude.isNotEmpty &&
                        model.property.longitude.isNotEmpty) ...[
                      UiSpacer.divider(),
                      VStack([
                        "Where you'll be staying".tr().text.lg.bold.make(),
                        model.property.address.text.gray700.lg.make(),
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Builder(
                            builder: (context) {
                              //the marker show not be point directly on location. It should be more of a circle range, so only booked user get the correct location
                              return GoogleMap(
                                zoomControlsEnabled: false,
                                scrollGesturesEnabled: false,
                                zoomGesturesEnabled: false,
                                compassEnabled: false,
                                myLocationButtonEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  zoom: 16,
                                  target: LatLng(
                                    model.property.latitude.toDouble(),
                                    model.property.longitude.toDouble(),
                                  ),
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId("1"),
                                    position: LatLng(
                                      model.property.latitude.toDouble(),
                                      model.property.longitude.toDouble(),
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                      ], spacing: Sizes.paddingSizeExtraSmall),
                    ],

                    UiSpacer.divider(),

                    // Reviews Section
                    VStack([
                      HStack([
                        Icon(Icons.star, color: Colors.black, size: 24),
                        8.widthBox,
                        "${model.property.rating}".text.xl2.bold.make(),
                        " • ${model.property.reviewsCount} ${"reviews".tr()}"
                            .text
                            .xl2
                            .bold
                            .make(),
                      ]),
                      //Top reviews: use any horizontal scroll view with snap effect
                      HStack(
                            model.property.topReviews.map((review) {
                              return PropertyReviewListItem(review: review);
                            }).toList(),
                            spacing: Sizes.paddingSizeSmall,
                          )
                          .scrollHorizontal(
                            physics: const BouncingScrollPhysics(),
                          )
                          .wFull(context),

                      //show all reviews
                      OutlinedButton(
                        onPressed: () {
                          //go to reviews page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return PropertyReviewsPage(
                                  property: model.property,
                                );
                              },
                            ),
                          );
                        },
                        child: "Show all reviews".tr().text.make(),
                      ).wFull(context),
                    ], spacing: Sizes.paddingSizeSmall),

                    UiSpacer.divider(),

                    // Host Info
                    VStack([
                      // Host Info Placeholder
                      HStack([
                        //vendor logo
                        CustomImage(
                          imageUrl: model.property.vendor!.logo,
                          width: 50,
                          height: 50,
                        ).cornerRadius(50),
                        VStack([
                          model.property.isHostResiding
                              ? "Stay with %s"
                                  .tr()
                                  .fill([model.property.vendor!.name])
                                  .text
                                  .semiBold
                                  .make()
                              : "Hosted by %s"
                                  .tr()
                                  .fill([model.property.vendor!.name])
                                  .text
                                  .semiBold
                                  .make(),

                          //been hosting year
                          Builder(
                            builder: (context) {
                              final years = Jiffy.parseFromDateTime(
                                model.property.vendor!.createdAt,
                              ).diff(Jiffy.now(), unit: Unit.year);
                              final months = Jiffy.parseFromDateTime(
                                model.property.vendor!.createdAt,
                              ).diff(Jiffy.now(), unit: Unit.month);
                              if (years < 1 && months < 1) {
                                return "New host".tr().text.gray500.make();
                              }
                              if (years < 1) {
                                return "Been hosting for %s months"
                                    .tr()
                                    .fill([months])
                                    .text
                                    .gray500
                                    .make();
                              }

                              return "Been hosting for %s years"
                                  .tr()
                                  .fill([years])
                                  .text
                                  .gray500
                                  .make();
                            },
                          ),
                        ]).expand(),
                      ], spacing: Sizes.paddingSizeDefault),
                      // 20.heightBox,
                      // OutlinedButton(
                      //   onPressed: () => model.openChatWithHost(context),
                      //   child: "Contact Host".tr().text.make(),
                      // ).wFull(context),
                    ]),

                    UiSpacer.divider(),

                    // Things to know
                    VStack([
                      "Things you need to know".tr().text.lg.bold.make(),
                      VStack([
                        "House Rules".tr().text.semiBold.make(),
                        5.heightBox,
                        (model.property.houseRules ?? "No house rules")
                            .text
                            .gray500
                            .make(),
                      ]),
                      VStack([
                        "Cancellation Policy".tr().text.semiBold.make(),
                        5.heightBox,
                        (model.property.cancellationPolicy?.name ?? "Standard")
                            .text
                            .gray500
                            .make(),
                      ], crossAlignment: CrossAxisAlignment.start),
                      HStack([
                        VStack([
                          "Check-in".tr().text.semiBold.make(),
                          5.heightBox,
                          Jiffy.parseFromDateTime(
                            model.property.checkInTimeStartObj,
                          ).format(pattern: "hh:mm a").text.gray500.make(),
                        ]).expand(),
                        VStack([
                          "Check-out".tr().text.semiBold.make(),
                          5.heightBox,
                          Jiffy.parseFromDateTime(
                            model.property.checkOutTimeObj,
                          ).format(pattern: "hh:mm a").text.gray500.make(),
                        ]).expand(),
                      ], crossAlignment: CrossAxisAlignment.start),
                    ], spacing: Sizes.paddingSizeDefault),

                    UiSpacer.divider(),

                    // Report Listing
                    Center(
                      child: TextButton.icon(
                        onPressed: model.reportListing,
                        icon: Icon(Icons.flag_outlined, color: Colors.grey),
                        label:
                            "Report this listing"
                                .tr()
                                .text
                                .gray500
                                .underline
                                .make(),
                      ),
                    ),
                    30.heightBox,
                  ], spacing: Sizes.paddingSizeDefault),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(Sizes.paddingSizeDefault),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: HStack([
                //reservation date
                PropertyReservationDateSection(model).expand(),
                ElevatedButton(
                  onPressed: () {
                    if (!model.anyObjectsBusy) {
                      model.processBooking();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      model.anyObjectsBusy
                          ? BusyIndicator(
                            color: Utils.textColorByPrimaryColor(),
                          ).wh(20, 20)
                          : "Reserve".tr().text.white.bold.make(),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return VStack([
      Icon(icon, size: 24, color: Colors.grey),
      5.heightBox,
      text.text.sm.gray600.make(),
    ], crossAlignment: CrossAxisAlignment.center);
  }
}

class _PropertyPhotosCarousel extends StatefulWidget {
  const _PropertyPhotosCarousel({required this.photos, required this.height});

  final List<String> photos;
  final double height;

  @override
  State<_PropertyPhotosCarousel> createState() =>
      _PropertyPhotosCarouselState();
}

class _PropertyPhotosCarouselState extends State<_PropertyPhotosCarousel> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1,
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() => currentIndex = index);
            },
          ),
          items: widget.photos.map((photoPath) {
            return CustomImage(
              imageUrl: photoPath,
              boxFit: BoxFit.cover,
              width: double.infinity,
              canZoom: true,
            );
          }).toList(),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: AnimatedSmoothIndicator(
            activeIndex: currentIndex,
            count: widget.photos.length,
            effect: ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 10,
              activeDotColor: AppColor.primaryColor,
              dotColor: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }
}
