import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/assist_service_provider.dart';
import 'package:fuodz/view_models/assist_service_providers.vm.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';

/// ASSIST multi-service (customer app) — discover the providers offering a
/// canonical service (approved + active), with their price. Read-only; booking
/// the service dispatches the nearest approved provider.
class AssistServiceProvidersPage extends StatelessWidget {
  const AssistServiceProvidersPage({
    required this.serviceId,
    this.serviceName,
    Key? key,
  }) : super(key: key);

  final int serviceId;
  final String? serviceName;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AssistServiceProvidersViewModel>.reactive(
      viewModelBuilder: () =>
          AssistServiceProvidersViewModel(context, serviceId, serviceName: serviceName),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(serviceName ?? "Providers".tr()),
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.loadProviders(),
            child: vm.isBusy
                ? const Center(child: BusyIndicator())
                : vm.providers.isEmpty
                    ? _empty(context)
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 4),
                            child: Text(
                              "${vm.providers.length} ${'approved provider(s)'.tr()}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ),
                          ...vm.providers.map((p) => _providerCard(context, p)),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Center(child: Text("No approved providers for this service yet.".tr())),
      ],
    );
  }

  Widget _providerCard(BuildContext context, AssistServiceProvider p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColor.primaryColor.withOpacity(0.1),
              child: Text(
                p.vendorName.isNotEmpty ? p.vendorName[0].toUpperCase() : "?",
                style: TextStyle(
                    color: AppColor.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.vendorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (p.rating != null) ...[
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        Text(" ${p.rating!.toStringAsFixed(1)}  ",
                            style: const TextStyle(fontSize: 12)),
                      ],
                      if (p.distanceKm != null)
                        Text("${p.distanceKm!.toStringAsFixed(1)} km",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  if (!p.isAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text("Currently unavailable".tr(),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.orange)),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_priceLabel(p),
                    style: TextStyle(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold)),
                if (p.inspectionFee != null && p.inspectionFee! > 0)
                  Text(
                    "${'Inspection'.tr()} ${AppStrings.currencySymbol}${p.inspectionFee!.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _priceLabel(AssistServiceProvider p) {
    final cur = AppStrings.currencySymbol;
    switch (p.priceType) {
      case "range":
        return "$cur${(p.minPrice ?? 0).toStringAsFixed(0)}–${(p.maxPrice ?? 0).toStringAsFixed(0)}";
      case "quote":
        return "Quote".tr();
      default:
        return "$cur${p.price.toStringAsFixed(0)}";
    }
  }
}
