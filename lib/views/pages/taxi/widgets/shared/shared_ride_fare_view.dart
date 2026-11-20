import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/shared_ride.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// SHARED RIDES — transparent per-passenger fare breakdown. Shows the customer
/// exactly what THEY pay for their own segment; detours and other passengers
/// never appear here.
class SharedRideFareView extends StatelessWidget {
  const SharedRideFareView({required this.fare, this.pooled = false, Key? key})
      : super(key: key);

  final SharedRideFare fare;
  final bool pooled;

  String _money(double v) => "${AppStrings.currencySymbol}${v.toStringAsFixed(2)}";

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.tr(),
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, size: 18),
              const SizedBox(width: 6),
              Text("Your fare".tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (pooled)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("Shared".tr(),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.green)),
                ),
            ],
          ),
          const Divider(),
          _row("Base fare", _money(fare.baseFare)),
          _row(
              "Distance (${fare.directDistance.toStringAsFixed(1)} km)",
              _money(fare.distanceFare)),
          _row("Time (${fare.directMinutes.toStringAsFixed(0)} min)",
              _money(fare.timeFare)),
          if (fare.poolingDiscount > 0)
            _row("Pooling discount", "- ${_money(fare.poolingDiscount)}",
                color: Colors.green),
          const Divider(),
          _row("Total you pay", _money(fare.passengerFare), bold: true),
          const SizedBox(height: 4),
          Text(
            "You only pay for your own trip — never for detours or other passengers."
                .tr(),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
