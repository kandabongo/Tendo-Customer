import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EmptyProduct extends StatelessWidget {
  const EmptyProduct({this.description, Key? key}) : super(key: key);
  final String? description;
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imageUrl: AppImages.noProduct,
      title: "No Product Found".tr(),
      description: description ?? "There seems to be no product".tr(),
    );
  }
}
