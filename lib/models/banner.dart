import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/vendor.dart';

class Banner {
  int? id;
  String? name;
  String? link;
  String? imageUrl;
  Category? category;
  Vendor? vendor;
  String? title, description, ctaTitle;

  Banner();

  factory Banner.fromJSON(dynamic json) {
    final banner = Banner();
    banner.id = json["id"];
    banner.name = json["name"];
    banner.link = json["link"];
    banner.imageUrl = json["photo"];

    //load category if included
    if (json["category"] != null) {
      banner.category = Category.fromJson(json["category"]);
    }
    if (json["vendor"] != null) {
      banner.vendor = Vendor.fromJson(json["vendor"]);
    }

    //customization
    banner.title = json["title"];
    banner.description = json["description"];
    banner.ctaTitle = json["cta_button_title"];
    return banner;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "link": link,
    "photo": imageUrl,
    "category": category?.toJson(),
    "vendor": vendor?.toJson(),
    "title": title,
    "description": description,
    "cta_button_title": ctaTitle,
  };
}
