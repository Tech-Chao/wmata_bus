class RailPrediction {
  String? car;
  String? destination;
  String? destinationCode;
  String? destinationName;
  String? group;
  String? line;
  String? locationCode;
  String? locationName;
  String? min;

  RailPrediction(
      {this.car,
      this.destination,
      this.destinationCode,
      this.destinationName,
      this.group,
      this.line,
      this.locationCode,
      this.locationName,
      this.min});

  RailPrediction.fromJson(Map<String, dynamic> json) {
    car = json['Car'];
    destination = json['Destination'];
    destinationCode = json['DestinationCode'];
    destinationName = json['DestinationName'];
    group = json['Group'];
    line = json['Line'];
    locationCode = json['LocationCode'];
    locationName = json['LocationName'];
    min = json['Min'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Car'] = car;
    data['Destination'] = destination;
    data['DestinationCode'] = destinationCode;
    data['DestinationName'] = destinationName;
    data['Group'] = group;
    data['Line'] = line;
    data['LocationCode'] = locationCode;
    data['LocationName'] = locationName;
    data['Min'] = min;
    return data;
  }
}
