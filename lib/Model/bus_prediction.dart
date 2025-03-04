class BusPrediction {
  String? directionNum;
  String? directionText;
  int? minutes;
  String? routeID;
  String? tripID;
  String? vehicleID;

  BusPrediction({this.directionNum,
      this.directionText,
      this.minutes,
      this.routeID,
      this.tripID,
      this.vehicleID});

  BusPrediction.fromJson(Map<String, dynamic> json) {
    directionNum = json['DirectionNum'];
    directionText = json['DirectionText'];
    minutes = json['Minutes'];
    routeID = json['RouteID'];
    tripID = json['TripID'];
    vehicleID = json['VehicleID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DirectionNum'] = directionNum;
    data['DirectionText'] = directionText;
    data['Minutes'] = minutes;
    data['RouteID'] = routeID;
    data['TripID'] = tripID;
    data['VehicleID'] = vehicleID;
    return data;
  }
}
