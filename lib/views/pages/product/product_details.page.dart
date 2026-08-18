import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/product_details.vm.dart';
import 'package:fuodz/views/pages/product/widgets/product_details.header.dart';
import 'package:fuodz/views/pages/product/widgets/product_details_cart.bottom_sheet.dart';
import 'package:fuodz/views/pages/product/widgets/product_option_group.dart';
import 'package:fuodz/views/pages/product/widgets/product_options.header.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/share.btn.dart';
import 'package:fuodz/widgets/cart_page_action.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/states/loading_indicator.dart';
import 'package:fuodz/widgets/webviewer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailsPage extends StatefulWidget {
  ProductDetailsPage({
    required this.product,
    Key? key,
  }) : super(key: key);

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentIndex = 0;

  //
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductDetailsViewModel>.reactive(
      viewModelBuilder: () => ProductDetailsViewModel(context, widget.product),
      onViewModelReady: (model) => model.getProductDetails(),
      builder: (context, model, child) {
        return BasePage(
          title: model.product.name,
          showAppBar: true,
          showLeadingAction: true,
          elevation: 0,
          appBarColor: AppColor.faintBgColor,
          appBarItemColor: AppColor.primaryColor,
          showCart: true,
          actions: [
            SizedBox(
              width: 50,
              height: 50,
              child: FittedBox(
                child: ShareButton(
                  model: model,
                ),
              ),
            ),
            UiSpacer.hSpace(10),
            PageCartAction(),
          ],
          body: CustomScrollView(
            slivers: [
              //product image
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: context.percentHeight * 30,
                        viewportFraction: 1,
                        autoPlay: true,
                        onPageChanged: (index, reason) {
                          setState(() => currentIndex = index);
                        },
                      ),
                      items: model.product.photos.map((photoPath) {
                        return Container(
                          child: CustomImage(
                            imageUrl: photoPath,
                            boxFit: BoxFit.contain,
                            canZoom: true,
                          ),
                        );
                      }).toList(),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: AnimatedSmoothIndicator(
                        activeIndex: currentIndex,
                        count: model.product.photos.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 10,
                          activeDotColor: AppColor.primaryColor,
                          dotColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ).box.color(AppColor.faintBgColor).make(),
              ),

              SliverToBoxAdapter(
                child: VStack(
                  [
                    //product header
                    ProductDetailsHeader(product: model.product),
                    //product description
                    UiSpacer.divider(height: 1, thickness: 2).py12(),
                    WebViewer(
                      url: model.product.description_url,
                      height: 50, // Fixed height
                      isScrollable: false, // Disable scrolling within WebView
                      showProgressBar: true,
                      enableJavaScript: true,
                    ),
                    UiSpacer.divider(height: 1, thickness: 2).py12(),

                    //options header
                    Visibility(
                      visible: model.product.optionGroups.isNotEmpty,
                      child: LoadingIndicator(
                        loading: model.busy(model.product),
                        child: VStack(
                          [
                            ProductOptionsHeader(
                              description:
                                  "Select options to add them to the product/service"
                                      .tr(),
                            ),

                            //options
                            VStack(
                              [
                                ...buildProductOptions(model),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    //more from vendor
                    OutlinedButton(
                      onPressed: model.openVendorPage,
                      child: "View more from"
                          .tr()
                          .richText
                          .color(Utils.primaryOrTheme)
                          .sm
                          .withTextSpanChildren(
                            [
                              " ${model.product.vendor.name}"
                                  .textSpan
                                  .semiBold
                                  .color(Utils.primaryOrTheme)
                                  .make(),
                            ],
                          )
                          .make()
                          .py12(),
                    ).centered().py16(),
                  ],
                )
                    .pOnly(bottom: context.percentHeight * 30)
                    .box
                    .outerShadow3Xl
                    .color(context.theme.colorScheme.surface)
                    .topRounded(value: Sizes.radiusExtraLarge)
                    .clip(Clip.antiAlias)
                    .make(),
              ),
            ],
          ).box.color(AppColor.faintBgColor).make(),
          bottomSheet: ProductDetailsCartBottomSheet(model: model),
        );
      },
    );
  }

  //
  buildProductOptions(model) {
    return model.product.optionGroups.map((OptionGroup optionGroup) {
      return ProductOptionGroup(optionGroup: optionGroup, model: model)
          .pOnly(bottom: Vx.dp12);
    }).toList();
  }
}
