import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Empty state shown on the home screen when no vendor types/services are
/// available for the customer's current location. Custom-built (not the
/// generic EmptyState) to match the softer, tinted-illustration look used by
/// the Gojek-style home screen.
class EmptyVendorTypes extends StatelessWidget {
  const EmptyVendorTypes({this.showDescription = true, this.onRetry, Key? key})
    : super(key: key);

  final bool showDescription;

  /// Optional retry callback - shows a "Try again" chip when provided.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    //driven off brightness rather than colorScheme.onSurface - the app's
    //light/dark ThemeData only hardcodes text color via blackTextTheme /
    //whiteTextTheme (see AppTheme), so onSurface isn't a reliable source
    //of a correctly-contrasting color in dark mode here.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final descriptionColor = isDark ? Colors.white70 : Colors.black54;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EmptyIllustration(primary: primary),
            const SizedBox(height: 20),
            Text(
              "No Services Nearby".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: titleColor,
                height: 1.3,
              ),
            ),
            if (showDescription) ...[
              const SizedBox(height: 8),
              Text(
                "We couldn't find any services for your current location yet"
                    .tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: descriptionColor,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              _RetryChip(color: primary, onTap: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          //outer soft ring
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.06),
            ),
          ),
          //inner tinted badge
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.12),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingBag01,
                color: primary,
                size: 30,
              ),
            ),
          ),
          //location-pin accent badge, overlapping the corner
          Positioned(
            right: -2,
            bottom: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedLocation01,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryChip extends StatelessWidget {
  const _RetryChip({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                "Try Again".tr(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
