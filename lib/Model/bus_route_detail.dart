import 'package:wmata_bus/Model/bus_stop.dart';

class BusRouteDetail {
  String? routeID;
  String? name;
  Direction? direction0;
  Direction? direction1;
  BusRouteDetail({this.name, this.routeID, this.direction0, this.direction1});

  BusRouteDetail.fromJson(Map<String, dynamic> json) {
    routeID = json['RouteID'];
    name = json['Name'];
    if (json['Direction0'] != null) {
      direction0 = Direction.fromJson(json['Direction0']);
    }
    if (json['Direction1'] != null) {
      direction1 = Direction.fromJson(json['Direction1']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RouteID'] = routeID;
    data['Name'] = name;
    data['Direction0'] = direction0?.toJson();
    data['Direction1'] = direction1?.toJson();
    return data;
  }
}

class Direction {
  String? directionNum;
  String? directionText;
  List<Shape>? shape;
  List<BusStop>? stops;
  String? tripHeadsign;

  Direction(
      {this.directionNum,
      this.directionText,
      this.shape,
      this.stops,
      this.tripHeadsign});

  Direction.fromJson(Map<String, dynamic> json) {
    directionNum = json['DirectionNum'];
    directionText = json['DirectionText'];
    if (json['Shape'] != null) {
      shape = <Shape>[];
      json['Shape'].forEach((v) {
        shape!.add(Shape.fromJson(v));
      });
    }
    if (json['Stops'] != null) {
      stops = <BusStop>[];
      json['Stops'].forEach((v) {
        stops!.add(BusStop.fromJson(v));
      });
    }
    tripHeadsign = json['TripHeadsign'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DirectionNum'] = directionNum;
    data['DirectionText'] = directionText;
    if (shape != null) {
      data['Shape'] = shape!.map((v) => v.toJson()).toList();
    }
    if (stops != null) {
      data['Stops'] = stops!.map((v) => v.toJson()).toList();
    }
    data['TripHeadsign'] = tripHeadsign;
    return data;
  }
}

class Shape {
  double? lat;
  double? lon;
  int? seqNum;

  Shape({this.lat, this.lon, this.seqNum});

  Shape.fromJson(Map<String, dynamic> json) {
    lat = json['Lat'];
    lon = json['Lon'];
    seqNum = json['SeqNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Lat'] = lat;
    data['Lon'] = lon;
    data['SeqNum'] = seqNum;
    return data;
  }
}
