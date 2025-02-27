import 'package:wmata_bus/Model/bus_prediction_new.dart';

class BusStop {
  double? lat;
  double? lon;
  String? name;
  List<String>? routes;
  String? stopID;

  // 自己增加
  bool? direction;
  String? routeID;
  // 不保存
  bool isLoading = false;
  bool isFavorite = false;
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
    routeID = json['routeID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Lat'] = lat;
    data['Lon'] = lon;
    data['Name'] = name;
    data['Routes'] = routes;
    data['StopID'] = stopID;

    data['direction'] = direction;
    data['routeID'] = routeID;

    return data;
  }

  @override
  bool operator ==(Object other) =>
      other is BusStop && stopID == other.stopID && name == other.name;
  @override
  int get hashCode => Object.hash(stopID, name);
}
