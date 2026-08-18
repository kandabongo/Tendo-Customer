import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/notification/notifications.page.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/inputs/search_bar.input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class GojekHeader extends StatelessWidget {
  const GojekHeader({required this.vm, required this.onLocationTap, Key? key})
    : super(key: key);

  final WelcomeViewModel vm;
  final Future<void> Function() onLocationTap;

  @override
  Widget build(BuildContext context) {
    final textColor = Utils.textColorByPrimaryColor();

    return Container(
      decoration: BoxDecoration(color: AppColor.primaryColor),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: location  |  bell  |  avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Location pill
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onLocationTap,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: textColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FlutterIcons.location_pin_ent,
                              color: textColor,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Deliver To".tr(),
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                StreamBuilder<DeliveryAddress?>(
                                  stream:
                                      LocationService
                                          .currenctDeliveryAddressSubject,
                                  initialData: vm.deliveryaddress,
                                  builder: (_, snap) {
                                    String? address = snap.data?.address;
                                    address ??= "Select Location".tr();
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          FlutterIcons.chevron_down_ent,
                                          color: textColor,
                                          size: 12,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bell
                  _IconButton(
                    icon: SimpleLineIcons.bell,
                    onTap: () => context.nextPage(const NotificationsPage()),
                  ),
                  const SizedBox(width: 12),
                  // Avatar
                  StreamBuilder<dynamic>(
                    stream: AuthServices.listenToAuthState(),
                    initialData: false,
                    builder: (ctx, snap) {
                      if (snap.data is bool && snap.data == true) {
                        return CustomImage(
                              imageUrl: AuthServices.currentUser?.photo ?? "",
                            )
                            .wh(36, 36)
                            .box
                            .roundedFull
                            .clip(Clip.antiAlias)
                            .make()
                            .onInkTap(() => AppService().homePageIndex.add(3));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search bar
              SearchBarInput(
                onTap: () => AppService().homePageIndex.add(2),
                showFilter: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small icon button used in the header
class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap, Key? key})
    : super(key: key);

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Utils.textColorByPrimaryColor().withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
