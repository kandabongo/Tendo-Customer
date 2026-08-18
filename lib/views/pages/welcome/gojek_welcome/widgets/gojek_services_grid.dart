import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/states/vendor_type.empty.dart';
import 'package:velocity_x/velocity_x.dart';

class GojekServicesGrid extends StatelessWidget {
  const GojekServicesGrid({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    //parent (GojekWelcomeView) already gates on shouldShowVendorTypesLoading,
    //so by the time this builds, vendorTypes.isEmpty only ever means
    //"confirmed no services" - never "still waiting on location".
    if (vm.vendorTypes.isEmpty) {
      return EmptyVendorTypes(
        onRetry: () => vm.initialise(initial: false),
      ).py20();
    }

    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Wrap(
          spacing: 0,
          runSpacing: 20, // Vertical spacing between rows
          children: List.generate(vm.vendorTypes.length, (index) {
            final vt = vm.vendorTypes[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 300),
              child: SlideAnimation(
                verticalOffset: 20.0,
                horizontalOffset: 0,
                child: FadeInAnimation(
                  child: SizedBox(
                    // strictly 4 items per row
                    width: (MediaQuery.of(context).size.width - 32) / 4,
                    child: _ServiceCircleItem(
                      vendorType: vt,
                      onTap:
                          () => NavigationService.pageSelected(
                            vt,
                            context: context,
                          ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ServiceCircleItem extends StatelessWidget {
  const _ServiceCircleItem({
    required this.vendorType,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final dynamic vendorType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = Vx.hexToColor(vendorType.color ?? "#000000");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: CustomImage(
              imageUrl: vendorType.logo,
              boxFit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vendorType.name ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ).px(2),
        ],
      ),
    );
  }
}
