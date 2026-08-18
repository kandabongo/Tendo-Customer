import 'package:flutter/material.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/requests/product.request.dart';
import 'package:fuodz/requests/property.request.dart';
import 'package:fuodz/requests/service.request.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/views/pages/booking/property_details.page.dart';
import 'package:fuodz/views/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:fuodz/views/pages/product/product_details.page.dart';
import 'package:fuodz/views/pages/service/service_details.page.dart';
import 'package:fuodz/views/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class DeepLinkLoadingPage extends StatefulWidget {
  final String type; // 'vendor', 'product', 'service', 'property'
  final String id;

  const DeepLinkLoadingPage({Key? key, required this.type, required this.id})
    : super(key: key);

  @override
  _DeepLinkLoadingPageState createState() => _DeepLinkLoadingPageState();
}

class _DeepLinkLoadingPageState extends State<DeepLinkLoadingPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    try {
      await Future.delayed(
        Duration(milliseconds: 300),
      ); // Small delay for better UX

      switch (widget.type) {
        case 'vendor':
          await _loadVendor();
          break;
        case 'product':
          await _loadProduct();
          break;
        case 'service':
          await _loadService();
          break;
        case 'property':
          await _loadProperty();
          break;
        default:
          throw 'Unsupported deep link type:'.tr() + " ${widget.type}";
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadVendor() async {
    final vendorRequest = VendorRequest();
    final vendor = await vendorRequest.vendorDetails(int.parse(widget.id));

    if (mounted) {
      await Navigator.of(AppService().navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => VendorDetailsPage(vendor: vendor),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _loadProduct() async {
    final productRequest = ProductRequest();
    final product = await productRequest.productDetails(int.parse(widget.id));

    if (mounted) {
      if (!product.vendor.vendorType.slug.contains("commerce")) {
        await Navigator.of(AppService().navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
        Navigator.of(context).pop();
      } else {
        await Navigator.of(AppService().navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder:
                (context) =>
                    AmazonStyledCommerceProductDetailsPage(product: product),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _loadService() async {
    final serviceRequest = ServiceRequest();
    final service = await serviceRequest.serviceDetails(int.parse(widget.id));

    if (mounted) {
      await Navigator.of(AppService().navigatorKey.currentContext!).push(
        MaterialPageRoute(builder: (context) => ServiceDetailsPage(service)),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _loadProperty() async {
    final propertyRequest = PropertyRequest();
    final property = await propertyRequest.getPropertyDetails(
      int.parse(widget.id),
    );

    if (mounted) {
      await Navigator.of(AppService().navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => PropertyDetailsPage(property: property),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadAndNavigate();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loading".tr()),
        leading: IconButton(icon: Icon(Icons.close), onPressed: _goBack),
      ),
      body: _isLoading ? _buildLoadingView() : _buildErrorView(),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BusyIndicator(),
          SizedBox(height: 24),
          Text(
            "Loading %s details...".tr().fill(["${widget.type}"]),
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            "Please wait while we fetch the information.".tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.theme.colorScheme.error,
          ),
          SizedBox(height: 24),
          Text(
            ("Unable to load".tr() + " ${widget.type}"),
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            _errorMessage ??
                "Something went wrong while loading the information.".tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(onPressed: _goBack, child: Text("Go Back".tr())),
              SizedBox(width: 16),
              ElevatedButton(onPressed: _retry, child: Text("Retry".tr())),
            ],
          ),
        ],
      ),
    );
  }
}
