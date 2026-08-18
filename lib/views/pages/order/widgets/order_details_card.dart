import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderDetailsCard extends StatelessWidget {
  const OrderDetailsCard({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              context.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
