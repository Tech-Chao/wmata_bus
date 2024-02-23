import 'package:wmata_bus/Model/bus_stop.dart';

class BusRouteDetail {
  String? routeId;
  String? agencyId;
  String? routeShortName;
  String? routeLongName;
  String? routeDesc;
  String? routeType;
  String? routeUrl;
  String? routeColor;
  String? routeTextColor;
  List<Direction>? directions;

  BusRouteDetail(
      {this.routeId,
      this.agencyId,
      this.routeShortName,
      this.routeLongName,
      this.routeDesc,
      this.routeType,
      this.routeUrl,
      this.routeColor,
      this.routeTextColor,
      this.directions});

  BusRouteDetail.fromJson(Map<String, dynamic> json) {
    routeId = json['route_id'];
    agencyId = json['agency_id'];
    routeShortName = json['route_short_name'];
    routeLongName = json['route_long_name'];
    routeDesc = json['route_desc'];
    routeType = json['route_type'];
    routeUrl = json['route_url'];
    routeColor = json['route_color'];
    routeTextColor = json['route_text_color'];
    if (json['directions'] != null) {
      directions = <Direction>[];
      json['directions'].forEach((v) {
        directions!.add(Direction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['route_id'] = routeId;
    data['agency_id'] = agencyId;
    data['route_short_name'] = routeShortName;
    data['route_long_name'] = routeLongName;
    data['route_desc'] = routeDesc;
    data['route_type'] = routeType;
    data['route_url'] = routeUrl;
    data['route_color'] = routeColor;
    data['route_text_color'] = routeTextColor;
    if (directions != null) {
      data['directions'] = directions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Direction {
  String? directionId;
  String? tripHeadsign;
  List<BusStop>? stops;

  Direction({this.directionId, this.tripHeadsign, this.stops});

  Direction.fromJson(Map<String, dynamic> json) {
    directionId = json['direction_id'];
    tripHeadsign = json['trip_headsign'];
    if (json['stops'] != null) {
      stops = <BusStop>[];
      json['stops'].forEach((v) {
        stops!.add(BusStop.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['direction_id'] = directionId;
    data['trip_headsign'] = tripHeadsign;
    if (stops != null) {
      data['stops'] = stops!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
