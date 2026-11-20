import 'package:flutter/material.dart';
import 'package:fuodz/enums/ride_type.enum.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// SHARED RIDES — Private vs Shared selection. Only shown when the backend has
/// Shared Rides enabled; otherwise the customer never sees it (private is the
/// default and only option).
class RideTypeSelector extends StatelessWidget {
  const RideTypeSelector({
    required this.selected,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final RideType selected;
  final ValueChanged<RideType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RideType.values.map((type) {
        final isSelected = type == selected;
        final color = Theme.of(context).colorScheme.primary;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.10) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withOpacity(0.4),
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        type == RideType.shared
                            ? Icons.groups_rounded
                            : Icons.person_rounded,
                        size: 18,
                        color: isSelected ? color : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          type.label.tr(),
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? color : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description.tr(),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
