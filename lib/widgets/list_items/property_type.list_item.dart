import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/property_type.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyTypeListItem extends StatelessWidget {
  const PropertyTypeListItem({
    required this.propertyType,
    required this.isSelected,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final PropertyType propertyType;
  final bool isSelected;
  final Function(PropertyType) onPressed;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? context.primaryColor : context.backgroundColor;
    final textColor = Utils.textColorByColor(bgColor);
    return HStack([
          CustomImage(
            imageUrl: propertyType.photo,
            width: 18,
            height: 18,
            color: textColor,
          ),
          10.widthBox,
          propertyType.name.text.size(13).color(textColor).semiBold.make(),
        ], crossAlignment: CrossAxisAlignment.center)
        .px(16)
        .py(10)
        .box
        .color(bgColor)
        .border(color: isSelected ? context.primaryColor : Vx.gray200, width: 1)
        .withRounded(value: Sizes.radiusLarge)
        .make()
        .onTap(() => onPressed(propertyType));
  }
}
