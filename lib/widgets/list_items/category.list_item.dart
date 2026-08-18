import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    required this.category,
    required this.onPressed,
    this.maxLine = true,
    this.h,
    this.inverted = false,
    this.textColor,
    this.lines = 1,
    Key? key,
  }) : super(key: key);

  final Function(Category) onPressed;
  final Category category;
  final bool maxLine;
  final double? h;
  final bool inverted;
  final Color? textColor;
  final int lines;
  @override
  Widget build(BuildContext context) {
    Widget child = 5.heightBox;
    if (inverted) {
      Color bgColor = Vx.hexToColor(category.color);
      Color mTextColor = Utils.textColorByColor(bgColor);
      child = _buildCategoryViewBase(
        maxLine,
        inverted,
        textColor ?? mTextColor,
      );
      child = child.p(8).box.roundedSM.color(bgColor).make();
    } else {
      Color mTextColor = Utils.textColorByColor(Colors.transparent);
      child = _buildCategoryViewBase(
        maxLine,
        inverted,
        textColor ?? mTextColor,
      );
    }

    //
    if (maxLine || h != null) {
      double _width = (AppStrings.categoryImageWidth * 1.8);
      _width += AppStrings.categoryTextSize;
      double _height = (AppStrings.categoryImageHeight * 1.8);
      _height += AppStrings.categoryImageHeight;
      if (h != null) {
        _height = h!;
      }
      child =
          child
              .w(_width)
              .h(_height)
              .onInkTap(() => this.onPressed(this.category))
              .px4();
    } else {
      child = child.onInkTap(() => this.onPressed(this.category)).px4();
    }
    return child;
  }

  //
  Widget _buildCategoryViewBase(bool maxLine, bool inverted, Color textColor) {
    Widget nameView = category.name.text
        .size(AppStrings.categoryTextSize)
        .wrapWords(true)
        .center
        .color(textColor)
        .make()
        .py(1);
    if (maxLine) {
      nameView = category.name.text
          .minFontSize(AppStrings.categoryTextSize)
          .size(AppStrings.categoryTextSize)
          .center
          .color(textColor)
          .maxLines(lines)
          .ellipsis
          .make()
          .py(1);
    }
    return Container(
      width: AppStrings.categoryImageWidth,
      child: VStack(
        [
          //
          CustomImage(
                imageUrl: category.imageUrl,
                boxFit: BoxFit.fill,
                width: AppStrings.categoryImageWidth * (inverted ? 0.75 : 1),
                height: AppStrings.categoryImageHeight * (inverted ? 0.75 : 1),
              ).box.roundedSM
              .clip(Clip.antiAlias)
              .color(
                inverted ? Colors.transparent : Vx.hexToColor(category.color),
              )
              .make()
              .py2(),

          //
          nameView,
        ],
        crossAlignment: CrossAxisAlignment.center,
        alignment: MainAxisAlignment.start,
      ),
    );
  }
}
