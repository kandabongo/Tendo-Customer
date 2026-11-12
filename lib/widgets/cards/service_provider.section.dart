import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceProviderSection extends StatelessWidget {
  const ServiceProviderSection({
    required this.service,
    super.key,
  });
  //
  final Service service;

  //
  @override
  Widget build(BuildContext context) {
    final vendor = service.vendor;
    // Canonical catalogue service with no assigned provider yet.
    if (vendor == null) {
      return VStack(
        [
          "Provider".tr().text.medium.xl.make(),
          "A verified provider will be assigned after you request this service."
              .tr()
              .text
              .light
              .sm
              .make(),
        ],
        spacing: 6,
      );
    }
    return VStack(
      [
        "Provider".tr().text.medium.xl.make(),
        HStack(
          [
            //provider logo
            CustomImage(
              imageUrl: vendor.logo,
              width: 50,
              height: 50,
            ).box.roundedSM.clip(Clip.antiAlias).make(),
            //provider details
            VStack(
              [
                vendor.name.text.semiBold.lg.make(),
                "${vendor.phone}".text.medium.sm.make(),
                "${vendor.address}".text.light.sm.maxLines(1).make(),
              ],
            ).px12().expand(),
          ],
        )
            .box
            .p8
            .color(context.theme.colorScheme.surface)
            .roundedSM
            .make()
            .onInkTap(
          () {
            Navigator.of(context).pushNamed(
              AppRoutes.vendorDetails,
              arguments: vendor,
            );
          },
        ),
      ],
      spacing: 6,
    );
  }
}
