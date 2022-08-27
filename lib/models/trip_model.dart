class Trip {
  String? id;
  String? pickupAddress;
  String? destinationAddress;
  double? pickupLatitude;
  double? pickupLongitude;
  double? destinationLatitude;
  double? destinationLongitude;
  double? distance;
  double? cost;
  bool? accepted;
  bool? started;
  bool? canceled;

  Trip({
    this.id,
    this.pickupAddress,
    this.destinationAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.distance,
    this.cost,
    this.accepted = false,
    this.started = false,
    this.canceled = false,
  });

  factory Trip.fromJson(Map<String, dynamic> data) => Trip(
        id: data['id'],
        pickupAddress: data['pickupAddress'],
        destinationAddress: data['destinationAddress'],
        pickupLatitude: data['pickupLatitude'],
        pickupLongitude: data['pickupLongitude'],
        destinationLatitude: data['destinationLatitude'],
        destinationLongitude: data['destinationLongitude'],
        distance: data['distance'],
        cost: data['cost'],
        accepted: data['accepted'],
        started: data['started'],
        canceled: data['canceled'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'distance': distance,
      'cost': cost,
      'accepted': accepted,
      'started': started,
      'canceled': canceled,
    };
  }
}
