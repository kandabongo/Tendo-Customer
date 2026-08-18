import 'package:flutter/material.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/requests/favourite.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/views/pages/auth/login.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/models/property.dart';

class PropertyFavIcon extends StatefulWidget {
  const PropertyFavIcon(this.property, {Key? key}) : super(key: key);
  final Property property;

  @override
  State<PropertyFavIcon> createState() => _PropertyFavIconState();
}

class _PropertyFavIconState extends State<PropertyFavIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleFavourite();
      },
      child:
          (_isFavouriteLoading
                  ? BusyIndicator(color: Colors.white).wh(20, 20)
                  : Icon(
                    widget.property.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        widget.property.isFavourite ? Colors.red : Colors.white,
                    size: 24,
                  ))
              .p(8)
              .box
              .color(Colors.black.withOpacity(0.3))
              .clip(Clip.antiAlias)
              .roundedFull
              .make(),
    );
  }

  //
  bool _isFavouriteLoading = false;
  _toggleFavourite() async {
    if (!AuthServices.isLoggedIn) {
      context.nextPage(LoginPage());
      return;
    }

    int propertyId = widget.property.id;
    _isFavouriteLoading = true;
    setState(() {});
    ApiResponse? response;
    if (widget.property.isFavourite) {
      response = await FavouriteRequest().removeFavouriteProperty(propertyId);
    } else {
      response = await FavouriteRequest().makeFavouriteProperty(propertyId);
    }
    if (response.allGood) {
      widget.property.isFavourite = !widget.property.isFavourite;
    }
    _isFavouriteLoading = false;
    setState(() {});
  }
}
