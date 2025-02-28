import 'package:wmata_bus/Model/bus_prediction_new.dart';
import 'package:wmata_bus/Model/bus_route_new.dart';

class BusStop {
  double? lat;
  double? lon;
  String? name;
  List<String>? routes;
  String? stopID;

  // 自己增加
  bool? direction;
  BusRouteNew? route;
  // 不保存
  bool isLoading = false;
  bool isSelected = false;
  List<BusPredictionNew>? predictions;

  BusStop({this.lat, this.lon, this.name, this.routes, this.stopID});

  BusStop.fromJson(Map<String, dynamic> json) {
    lat = json['Lat'];
    lon = json['Lon'];
    name = json['Name'];
    routes = json['Routes'].cast<String>();
    stopID = json['StopID'];

    //自己增加
    direction = json['direction'];
    if (json['route'] != null) {
      route = BusRouteNew.fromJson(json['route']);
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
    data['route'] = route;

    return data;
  }

  @override
  bool operator ==(Object other) =>
      other is BusStop &&
      stopID == other.stopID &&
      name == other.name &&
      route?.routeID == other.route?.routeID;
  @override
  int get hashCode => Object.hash(stopID, name, route?.routeID);
}
