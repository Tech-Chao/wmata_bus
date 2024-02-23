class BusPrediction {
  String? tripId;
  String? startTime;
  String? routeId;
  int? directionId;
  int? departureTime;
  int? arrivalTime;
  String? stopId;
  int? waitInSecs;
  int? waitinMins;
  String? vehicleId;
  String? headsign;
  String? routeShortName;
  String? destinationStopId;

  BusPrediction(
      {this.tripId,
      this.startTime,
      this.routeId,
      this.directionId,
      this.departureTime,
      this.arrivalTime,
      this.stopId,
      this.waitInSecs,
      this.waitinMins,
      this.vehicleId,
      this.headsign,
      this.routeShortName,
      this.destinationStopId});

  BusPrediction.fromJson(Map<String, dynamic> json) {
    tripId = json['tripId'];
    startTime = json['startTime'];
    routeId = json['routeId'];
    directionId = json['directionId'];
    departureTime = json['departureTime'];
    arrivalTime = json['arrivalTime'];
    stopId = json['stopId'];
    waitInSecs = json['waitInSecs'];
    waitinMins = json['waitinMins'];
    vehicleId = json['vehicleId'];
    headsign = json['headsign'];
    routeShortName = json['routeShortName'];
    destinationStopId = json['destinationStopId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tripId'] = tripId;
    data['startTime'] = startTime;
    data['routeId'] = routeId;
    data['directionId'] = directionId;
    data['departureTime'] = departureTime;
    data['arrivalTime'] = arrivalTime;
    data['stopId'] = stopId;
    data['waitInSecs'] = waitInSecs;
    data['waitinMins'] = waitinMins;
    data['vehicleId'] = vehicleId;
    data['headsign'] = headsign;
    data['routeShortName'] = routeShortName;
    data['destinationStopId'] = destinationStopId;
    return data;
  }
}
