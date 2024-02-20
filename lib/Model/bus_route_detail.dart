import 'package:wmata_bus/Model/bus_prediction.dart';
import 'package:wmata_bus/Model/bus_route.dart';

class BusRouteDetail {
  String? routeId;
  String? name;
  Direction? direction0;
  Direction? direction1;
  BusRouteDetail({this.name, this.routeId, this.direction0, this.direction1});

  BusRouteDetail.fromJson(Map<String, dynamic> json) {
    routeId = json['RouteID'];
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
    data['RouteID'] = routeId;
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
  List<InnerBusStop>? stops;
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
      stops = <InnerBusStop>[];
      json['Stops'].forEach((v) {
        stops!.add(InnerBusStop.fromJson(v));
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

class InnerBusStop {
  double? lat;
  double? lon;
  String? name;
  List<String>? routes;
  String? stopID;

  // 自己增加
  int? atIndex;
  bool isLoading = false;
  bool isFavorite = false;
  bool isSelected = false;
  bool? direction;
  BusRoute? belongToRoute;
  List<BusPrediction>? predictions;

  InnerBusStop({this.lat, this.lon, this.name, this.routes, this.stopID});

  InnerBusStop.fromJson(Map<String, dynamic> json) {
    lat = json['Lat'];
    lon = json['Lon'];
    name = json['Name'];
    routes = json['Routes'].cast<String>();
    stopID = json['StopID'];

    direction = json['direction'];
    if (json['belongTo'] != null) {
      belongToRoute = BusRoute.fromJson(json['belongTo']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Lat'] = lat;
    data['Lon'] = lon;
    data['Name'] = name;
    data['Routes'] = routes;
    data['StopID'] = stopID;

    data['direction'] = direction;
    data['belongTo'] = belongToRoute?.toJson();
    return data;
  }

  @override
  bool operator ==(Object other) =>
      other is InnerBusStop && stopID == other.stopID && name == other.name;
  @override
  int get hashCode => Object.hash(stopID, name);
}
