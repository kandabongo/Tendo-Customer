import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:fuodz/models/shared_trip_status.dart';
import 'package:fuodz/requests/shared_ride.request.dart';

/// SHARED RIDES (customer) — tracks the dispatch outcome for a booked trip.
///
/// The backend is the source of truth: this POLLS `/status` on an interval
/// (so the customer is updated even if a push is missed), and a push or an app
/// resume simply triggers an immediate extra poll. It never infers assignment
/// locally. Stops polling once the outcome is terminal.
class SharedStatusService with WidgetsBindingObserver {
  static final SharedStatusService _instance = SharedStatusService._();
  factory SharedStatusService() => _instance;
  SharedStatusService._();

  final SharedRideRequest _request = SharedRideRequest();
  Timer? _timer;
  int? _tripId;
  void Function(SharedTripStatus)? _onUpdate;
  bool _observing = false;

  /// Begin tracking a booked trip. [onUpdate] fires on every poll.
  void track(int tripId, void Function(SharedTripStatus) onUpdate) {
    stop();
    _tripId = tripId;
    _onUpdate = onUpdate;
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    refresh(); // immediate
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => refresh());
  }

  /// One-off backend poll (also called by push + resume).
  Future<void> refresh() async {
    final tripId = _tripId;
    if (tripId == null) return;
    final status = await _request.tripStatus(tripId);
    _onUpdate?.call(status);
    if (status.isTerminal) {
      _stopTimerOnly();
    }
  }

  /// A push arrived — nudge an immediate poll if it concerns our trip.
  void onPush(Map? data) {
    if (data == null) return;
    final type = "${data['type']}";
    if (type.startsWith('shared_trip_')) {
      refresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh(); // recover a missed update
    }
  }

  void _stopTimerOnly() {
    _timer?.cancel();
    _timer = null;
  }

  void stop() {
    _stopTimerOnly();
    _tripId = null;
    _onUpdate = null;
  }
}
