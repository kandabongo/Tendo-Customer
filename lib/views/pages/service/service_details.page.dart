import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/service_details.vm.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/qty_stepper.dart';
import 'package:fuodz/widgets/list_items/service_option.list_item.dart';
import 'package:fuodz/widgets/webviewer.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Service service;

  const ServiceDetailsPage(this.service, {Key? key}) : super(key: key);

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  int _currentImageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ServiceDetailsViewModel>.reactive(
      viewModelBuilder: () => ServiceDetailsViewModel(context, widget.service),
      onViewModelReady: (model) => model.getServiceDetails(),
      builder: (context, vm, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(vm),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: VStack(
                    [
                      _buildServiceHeader(),
                      _buildPriceSection(),
                      _buildServiceDetails(),
                      _buildServiceFeatures(),
                      if (vm.service.optionGroups?.isNotEmpty ?? false)
                        _buildServiceOptions(vm),
                      _buildVendorSection(vm),
                    ],
                    crossAlignment: CrossAxisAlignment.start,
                    spacing: Sizes.paddingSizeDefault,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBookButton(vm),
        );
      },
    );
  }

  Widget _buildSliverAppBar(ServiceDetailsViewModel vm) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () => vm.shareService(vm.service),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: widget.service.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.service.photos[index],
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                );
              },
            ),
            if (widget.service.photos.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      widget.service.photos.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentImageIndex == entry.key
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.service.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryColor.swatch.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.service.category!.name,
                  style: TextStyle(
                    color: context.primaryColor.swatch.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (widget.service.category != null) const SizedBox(width: 8),
            if (!widget.service.location)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.green[800]),
                    const SizedBox(width: 2),
                    Text(
                      'Off-site'.tr(),
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.green[800]),
                    const SizedBox(width: 2),
                    Text(
                      'On-location'.tr(),
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        Sizes.paddingSizeDefault.heightBox,
        Text(
          widget.service.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        // const SizedBox(height: 8),
        // Text(
        //   widget.service.description.replaceAll(
        //     RegExp(r'<[^>]*>'),
        //     '',
        //   ), // Remove HTML tags
        //   style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
        // ),
        //description
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${AppStrings.currentCurrencySymbol} ${(widget.service.sellPrice.convertCurrency)}'
                          .currencyFormat(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.service.discountPrice > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${AppStrings.currentCurrencySymbol} ${widget.service.price.convertCurrency}'
                            .currencyFormat(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.swatch.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.service.duration.toUpperCase(),
              style: TextStyle(
                color: AppColor.primaryColor.swatch.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return VStack(
      [
        "Details".tr().text.xl.bold.make(),
        // _buildDetailRow('Service ID', '#${widget.service.id}'),
        _buildDetailRow('Duration'.tr(), widget.service.duration),
        if (widget.service.category != null)
          _buildDetailRow('Category'.tr(), widget.service.category!.name),
        if (widget.service.subcategory != null)
          _buildDetailRow('Subcategory'.tr(), widget.service.subcategory!.name),
        // _buildDetailRow('Created', widget.service.formattedDate),
        if (widget.service.ageRestricted)
          _buildDetailRow('Age Restriction'.tr(), 'Yes'.tr()),
        if (widget.service.description_url != null)
          WebViewer(
            url: widget.service.description_url!,
            height: 0,
            isScrollable: false,
            showProgressBar: true,
            enableJavaScript: true,
            padding: EdgeInsets.symmetric(vertical: Sizes.paddingSizeDefault),
          ),
      ],
      crossAlignment: CrossAxisAlignment.start,
      spacing: Sizes.paddingSizeExtraSmall,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorSection(ServiceDetailsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.service.vendor.logo,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.business),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.vendor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColor.ratingColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.service.vendor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                widget.service.vendor.isOpen
                                    ? AppColor.openColor
                                    : AppColor.closeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.service.vendor.isOpen
                              ? 'Open'.tr()
                              : 'Closed'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                widget.service.vendor.isOpen
                                    ? AppColor.openColor.swatch.shade700
                                    : AppColor.closeColor.swatch.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  vm.openVendorPage();
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.service.vendor.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.service.vendor.pickup == 1)
                _buildVendorFeature(
                  HugeIcons.strokeRoundedOffice,
                  'On-site Service'.tr(),
                ),
              if (widget.service.vendor.delivery == 1)
                _buildVendorFeature(
                  HugeIcons.strokeRoundedLocation03,
                  'Off-site Service'.tr(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOptions(ServiceDetailsViewModel vm) {
    //options if any

    return VStack([
      UiSpacer.divider().py12(),
      //title
      "Additional Options".tr().text.xl.bold.make().py12(),
      ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: vm.service.optionGroups!.length,
        separatorBuilder: (_, __) => Sizes.paddingSizeDefault.heightBox,
        itemBuilder: (context, index) {
          final optionGroup = vm.service.optionGroups![index];
          //sublist
          return VStack([
            //title
            optionGroup.name.text.bold.make(),
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: optionGroup.options.length,
              itemBuilder: (context, index) {
                final option = optionGroup.options[index];
                return ServiceOptionListItem(
                  option: option,
                  optionGroup: optionGroup,
                  model: vm,
                );
              },
              separatorBuilder: (_, __) => Sizes.paddingSizeSmall.heightBox,
            ),
          ], spacing: Sizes.paddingSizeSmall);
        },
      ),
    ]);
  }

  Widget _buildVendorFeature(List<List<dynamic>> icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.swatch.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            size: 14,
            color: AppColor.primaryColor.swatch.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColor.primaryColor.swatch.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'Service Features'.tr().text.bold.lg.make(),
        Sizes.paddingSizeSmall.heightBox,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.service.location)
              _buildFeatureChip(Icons.location_on, 'On-site Service'.tr()),
            if (widget.service.isActive == 1)
              _buildFeatureChip(Icons.check_circle, 'Active Service'.tr()),
            _buildFeatureChip(Icons.schedule, 'Fixed Duration'.tr()),
            if (!widget.service.ageRestricted)
              _buildFeatureChip(Icons.family_restroom, 'All Ages'.tr()),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookButton(ServiceDetailsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: VStack([
          //hour selection
          if (!vm.service.isFixed)
            HStack([
              //
              "${vm.service.duration.capitalize()}"
                  .tr()
                  .text
                  .medium
                  .xl
                  .make()
                  .expand(),
              QtyStepper(
                defaultValue: 1,
                min: 1,
                max: 24,
                actionButtonColor: AppColor.primaryColor,
                disableInput: true,
                onChange: (value) {
                  vm.service.selectedQty = value;
                  vm.notifyListeners();
                },
              ),
            ]),

          //
          ElevatedButton(
            onPressed: vm.bookService,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor.swatch.shade600,
              foregroundColor: Utils.textColorByPrimaryColor(),
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.paddingSizeDefault,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusDefault),
              ),
              elevation: 0,
            ),
            child:
                vm.isBusy
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: BusyIndicator(),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedBook02,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Continue'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ]),
      ),
    );
  }
}
