class RailPrediction {
  List<Trains>? trains;

  RailPrediction({this.trains});

  RailPrediction.fromJson(Map<String, dynamic> json) {
    if (json['Trains'] != null) {
      trains = <Trains>[];
      json['Trains'].forEach((v) {
        trains!.add(Trains.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (trains != null) {
      data['Trains'] = trains!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Trains {
  String? car;
  String? destination;
  String? destinationCode;
  String? destinationName;
  String? group;
  String? line;
  String? locationCode;
  String? locationName;
  String? min;

  Trains(
      {this.car,
      this.destination,
      this.destinationCode,
      this.destinationName,
      this.group,
      this.line,
      this.locationCode,
      this.locationName,
      this.min});

  Trains.fromJson(Map<String, dynamic> json) {
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
