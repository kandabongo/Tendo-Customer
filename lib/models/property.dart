import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/property_review.dart';
import 'package:jiffy/jiffy.dart';
import 'property_type.dart';
import 'vendor.dart';
import 'property_amenity.dart';
import 'cancellation_policy.dart';
import 'property_fee.dart';

class Property {
  Property({
    required this.id,
    required this.vendorId,
    required this.propertyTypeId,
    required this.name,
    required this.basePrice,
    this.discountPrice,
    required this.slug,
    required this.description,
    this.propertyType,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
    required this.checkInTimeStart,
    required this.checkInTimeEnd,
    required this.checkOutTime,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    required this.beds,
    required this.squareMeters,
    required this.isActive,
    required this.isInstantBooking,
    required this.minimumNights,
    required this.maximumNights,
    required this.preparationTime,
    this.cancellationPolicyId,
    this.houseRules,
    this.createdAt,
    this.updatedAt,
    this.photos = const [],
    required this.mainPhoto,
    this.vendor,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.user_rated = false,
    this.amenities = const [],
    this.cancellationPolicy,
    this.activeFees = const [],
    this.isFavourite = false,
    this.shareable_link,
    this.deep_link,
    this.isHostResiding = false,
    this.topReviews = const [],
    this.availableFrom,
    this.availableTo,
    this.availableRanges = const [],
  });

  int id;
  int vendorId;
  int propertyTypeId;
  String name;
  String slug;
  String description;
  double basePrice;
  double? discountPrice;
  PropertyType? propertyType;
  String address;
  String latitude;
  String longitude;
  String city;
  String state;
  String country;
  String? postalCode;
  String checkInTimeStart;
  String checkInTimeEnd;
  String checkOutTime;
  int maxGuests;
  int bedrooms;
  int bathrooms;
  int beds;
  int squareMeters;
  bool isActive;
  bool isInstantBooking;
  int minimumNights;
  int maximumNights;
  int preparationTime;
  int? cancellationPolicyId;
  String? houseRules;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String> photos;
  String mainPhoto;
  Vendor? vendor;
  double rating;
  int reviewsCount;
  bool user_rated;
  List<PropertyAmenity> amenities;
  CancellationPolicy? cancellationPolicy;
  List<PropertyFee> activeFees;
  bool isFavourite;
  String? shareable_link;
  String? deep_link;
  bool isHostResiding;
  List<PropertyReview> topReviews;
  DateTime? availableFrom;
  DateTime? availableTo;
  List<DateTimeRange> availableRanges;

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json["id"],
    vendorId: json["vendor_id"],
    propertyTypeId: json["property_type_id"],
    name: json["name"],
    slug: json["slug"],
    basePrice: json["base_price"].toString().toDouble(),
    discountPrice: json["discount_price"].toString().toDoubleOrNull(),
    description: json["description"],
    propertyType:
        json["property_type"] == null
            ? null
            : PropertyType.fromJson(json["property_type"]),
    address: json["address"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postal_code"],
    checkInTimeStart: json["check_in_time_start"],
    checkInTimeEnd: json["check_in_time_end"],
    checkOutTime: json["check_out_time"],
    maxGuests: json["max_guests"],
    bedrooms: json["bedrooms"],
    bathrooms: json["bathrooms"],
    beds: json["beds"],
    squareMeters: json["square_meters"],
    isActive:
        json["is_active"] is bool
            ? json["is_active"]
            : (int.parse(json["is_active"].toString()) == 1),
    isInstantBooking:
        json["is_instant_booking"] is bool
            ? json["is_instant_booking"]
            : (int.parse(json["is_instant_booking"].toString()) == 1),
    minimumNights: json["minimum_nights"],
    maximumNights: json["maximum_nights"],
    preparationTime: json["preparation_time"],
    cancellationPolicyId: json["cancellation_policy_id"],
    houseRules: json["house_rules"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    photos:
        json["photos"] == null
            ? []
            : List<String>.from(json["photos"].map((x) => x)),
    mainPhoto: json["main_photo"],
    vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
    rating:
        double.parse(
          (json["rating"] ?? 0.0).toString(),
        ).toStringAsFixed(2).toDouble(),
    reviewsCount: int.parse((json["reviews_count"] ?? 0).toString()),
    user_rated:
        json["user_rated"] is bool
            ? json["user_rated"]
            : (int.parse(json["user_rated"].toString()) == 1),
    amenities:
        json["amenities"] == null
            ? []
            : List<PropertyAmenity>.from(
              json["amenities"].map((x) => PropertyAmenity.fromJson(x)),
            ),
    cancellationPolicy:
        json["cancellation_policy"] == null
            ? null
            : CancellationPolicy.fromJson(json["cancellation_policy"]),
    activeFees:
        json["active_fees"] == null
            ? []
            : List<PropertyFee>.from(
              json["active_fees"].map((x) => PropertyFee.fromJson(x)),
            ),
    isFavourite: json["is_favourite"] ?? false,
    shareable_link: json["shareable_link"],
    deep_link: json["deep_link"],
    isHostResiding:
        json["is_host_residing"] is bool
            ? json["is_host_residing"]
            : (int.parse((json["is_host_residing"] ?? 0).toString()) == 1),
    topReviews:
        json["topReviews"] == null
            ? []
            : List<PropertyReview>.from(
              json["topReviews"].map((x) => PropertyReview.fromJson(x)),
            ),
    availableFrom:
        json["available_from"] == null
            ? null
            : DateTime.parse(json["available_from"]),
    availableTo:
        json["available_to"] == null
            ? null
            : DateTime.parse(json["available_to"]),
    availableRanges:
        json["available_ranges"] == null
            ? []
            : List<DateTimeRange>.from(
              json["available_ranges"].map(
                (x) => DateTimeRange(
                  start: DateTime.parse(x["start"]),
                  end: DateTime.parse(x["end"]),
                ),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "property_type_id": propertyTypeId,
    "name": name,
    "base_price": basePrice,
    "discount_price": discountPrice,
    "slug": slug,
    "description": description,
    "property_type": propertyType?.toJson(),
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "check_in_time_start": checkInTimeStart,
    "check_in_time_end": checkInTimeEnd,
    "check_out_time": checkOutTime,
    "max_guests": maxGuests,
    "bedrooms": bedrooms,
    "bathrooms": bathrooms,
    "beds": beds,
    "square_meters": squareMeters,
    "is_active": isActive,
    "is_instant_booking": isInstantBooking,
    "minimum_nights": minimumNights,
    "maximum_nights": maximumNights,
    "preparation_time": preparationTime,
    "cancellation_policy_id": cancellationPolicyId,
    "house_rules": houseRules,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "photos": List<dynamic>.from(photos.map((x) => x)),
    "main_photo": mainPhoto,
    "vendor": vendor?.toJson(),
    "rating": rating,
    "reviews_count": reviewsCount,
    "user_rated": user_rated,
    "amenities": List<dynamic>.from(amenities.map((x) => x.toJson())),
    "cancellation_policy": cancellationPolicy?.toJson(),
    "active_fees": List<dynamic>.from(activeFees.map((x) => x.toJson())),
    "is_favourite": isFavourite,
    "shareable_link": shareable_link,
    "deep_link": deep_link,
    "is_host_residing": isHostResiding,
    "topReviews": List<dynamic>.from(topReviews.map((x) => x.toJson())),
    "available_from": availableFrom?.toIso8601String(),
    "available_to": availableTo?.toIso8601String(),
    "available_ranges":
        availableRanges
            .map(
              (e) => {
                "start":
                    e.start.toIso8601String().split("T")[0], //just date part
                "end": e.end.toIso8601String().split("T")[0],
              },
            )
            .toList(),
  };

  //Getters
  double get price =>
      (discountPrice != null && discountPrice! > 0)
          ? discountPrice!
          : basePrice;

  DateTime get checkInTimeStartObj =>
      Jiffy.parse(checkInTimeStart, pattern: "HH:mm:ss").dateTime;
  DateTime get checkInTimeEndObj =>
      Jiffy.parse(checkInTimeEnd, pattern: "HH:mm:ss").dateTime;
  DateTime get checkOutTimeObj =>
      Jiffy.parse(checkOutTime, pattern: "HH:mm:ss").dateTime;
}
