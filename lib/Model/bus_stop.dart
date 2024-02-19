

import 'package:wmata_bus/Model/bus_prediction.dart';
import 'package:wmata_bus/Model/bus_route.dart';

class BusStop {
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

  BusStop({this.lat, this.lon, this.name, this.routes, this.stopID});

  BusStop.fromJson(Map<String, dynamic> json) {
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
      other is BusStop && stopID == other.stopID && name == other.name;
  @override
  int get hashCode => Object.hash(stopID, name);
}
