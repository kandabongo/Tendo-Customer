/// SHARED RIDES — the two taxi ride types the customer can choose between.
enum RideType {
  private,
  shared,
}

extension RideTypeX on RideType {
  String get apiValue => this == RideType.shared ? "shared" : "private";

  String get label => this == RideType.shared ? "Shared Ride" : "Private Ride";

  String get description => this == RideType.shared
      ? "Share the trip with others going your way and pay less."
      : "Your own trip, direct to your destination.";
}
