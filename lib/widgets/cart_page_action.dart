import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_ui_settings.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/cart/cart.page.dart';
import 'package:velocity_x/velocity_x.dart';

class PageCartAction extends StatefulWidget {
  const PageCartAction({
    this.color,
    this.textColor,
    this.fontSize = 13,
    this.iconSize = 26,
    this.badgeSize = 20,
    this.padding = 5,
    Key? key,
  }) : super(key: key);
  final Color? color;
  final Color? textColor;
  final double badgeSize;
  final double iconSize;
  final double fontSize;
  final double padding;

  @override
  _PageCartActionState createState() => _PageCartActionState();
}

class _PageCartActionState extends State<PageCartAction> {
  @override
  void initState() {
    super.initState();
    CartServices.getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return !AppUISettings.showCart
        ? UiSpacer.emptySpace()
        : StreamBuilder(
            stream: CartServices.cartItemsCountStream.stream,
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Color? textColor = widget.textColor;
              if (textColor == null) {
                textColor = AppColor.primaryColor;
                textColor = Utils.textColorByColor(textColor);
              }
              return Icon(
                FlutterIcons.shopping_bag_fea,
                color: textColor,
                size: widget.iconSize,
              )
                  .p(widget.padding)
                  .badge(
                    count: snapshot.data,
                    size: widget.badgeSize,
                    // color: widget.color ?? AppColor.primaryColor,
                    color: AppColor.primaryColor,
                    textStyle: context.textTheme.bodyLarge?.copyWith(
                      fontSize: widget.fontSize,
                      color: textColor,
                    ),
                  )
                  .centered()
                  .box
                  .p3
                  // .make()
                  .color(context.primaryColor)
                  .roundedFull
                  .make()
                  .onInkTap(
                () async {
                  //
                  context.nextPage(CartPage());
                },
              ).pOnly(
                right: Utils.isArabic ? 0 : widget.padding,
                left: Utils.isArabic ? widget.padding : 0,
              );
            },
          );
  }
}
