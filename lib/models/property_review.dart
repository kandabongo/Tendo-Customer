class PropertyReview {
  int id;
  double rating;
  String? comment;
  DateTime createdAt;
  String userName;
  String userPhoto;
  DateTime userJoinDate;

  PropertyReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
    required this.userPhoto,
    required this.userJoinDate,
  });

  factory PropertyReview.fromJson(Map<String, dynamic> json) => PropertyReview(
    id: json["id"],
    rating: double.parse(json["rating"].toString()),
    comment: json["review"],
    createdAt: DateTime.parse(json["created_at"]),
    userName: json["user_name"],
    userPhoto: json["user_photo"],
    userJoinDate: DateTime.parse(json["user_join_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rating": rating,
    "review": comment,
    "created_at": createdAt.toIso8601String(),
    "user_name": userName,
    "user_photo": userPhoto,
    "user_join_date": userJoinDate.toIso8601String(),
  };
}
