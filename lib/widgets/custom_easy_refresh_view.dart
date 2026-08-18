import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomEasyRefreshView extends StatelessWidget {
  const CustomEasyRefreshView({
    required this.onRefresh,
    this.dataset = const [],
    this.listView,
    this.child,
    this.refreshOnStart = false,
    this.loading = false,
    this.controller,
    this.onLoad,
    this.emptyView,
    this.loadingWidget,
    this.separator,
    this.padding,
    this.headerView,
    this.triggerAxis,
    super.key,
  });
  final bool refreshOnStart;
  final bool loading;
  final EasyRefreshController? controller;
  final List<dynamic> dataset;
  final Function onRefresh;
  final Function? onLoad;
  final Widget? emptyView;
  final Widget? loadingWidget;
  final Widget? separator;
  final List<Widget>? listView;
  final EdgeInsets? padding;
  final Widget? child;
  final Header? headerView;
  final Axis? triggerAxis;
  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      triggerAxis: triggerAxis,
      header: headerView ?? MaterialHeader(),
      controller: controller,
      refreshOnStart: refreshOnStart,
      onRefresh: () => onRefresh(),
      onLoad: onLoad != null ? () => onLoad!() : null,
      child: loading
          ? SingleChildScrollView(
              child: loadingWidget ?? LoadingShimmer(),
            )
          : (listView != null && dataset.isEmpty)
              ? (emptyView ?? Container())
              : child != null
                  ? child
                  : (listView != null && listView is List)
                      ? ListView.separated(
                          shrinkWrap: true,
                          padding: padding,
                          itemBuilder: (context, index) {
                            return listView![index];
                          },
                          separatorBuilder: (_, __) {
                            return separator ?? 0.heightBox;
                          },
                          itemCount: dataset.length,
                        )
                      : SingleChildScrollView(
                          child: Container(),
                        ),
    );
  }
}
