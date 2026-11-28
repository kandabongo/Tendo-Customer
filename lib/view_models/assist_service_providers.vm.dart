import 'package:flutter/material.dart';
import 'package:fuodz/models/assist_service_provider.dart';
import 'package:fuodz/requests/assist_discovery.request.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';

/// ASSIST multi-service (customer app) — lists the providers that offer a
/// canonical service (approved + active), nearest-first when a location is known.
class AssistServiceProvidersViewModel extends MyBaseViewModel {
  AssistServiceProvidersViewModel(BuildContext context, this.serviceId,
      {this.serviceName}) {
    this.viewContext = context;
  }

  final int serviceId;
  final String? serviceName;

  final AssistDiscoveryRequest _request = AssistDiscoveryRequest();
  List<AssistServiceProvider> providers = [];

  void initialise() => loadProviders();

  Future<void> loadProviders() async {
    setBusy(true);
    try {
      double? lat, lng;
      try {
        lat = await LocationService.getFetchByLocationLat();
        lng = await LocationService.getFetchByLocationLng();
      } catch (_) {
        // location optional — the backend falls back to a rating sort
      }
      providers = await _request.providersForService(
        serviceId,
        latitude: lat,
        longitude: lng,
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
    notifyListeners();
  }
}
