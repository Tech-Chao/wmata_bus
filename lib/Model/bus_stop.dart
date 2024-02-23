import 'package:wmata_bus/Model/bus_prediction.dart';
import 'package:wmata_bus/Model/bus_route.dart';

class BusStop {
  int? stopSequence;
  String? stopId;
  String? stopCode;
  String? stopName;
  String? agencyId;
  String? stopLat;
  String? stopLon;
  String? parentStation;

  // 自己增加
  int? atIndex;
  bool isLoading = false;
  bool isFavorite = false;
  bool isSelected = false;
  bool? direction;
  BusRoute? belongToRoute;
  List<BusPrediction>? predictions;

  BusStop(
      {this.stopSequence,
      this.stopId,
      this.stopCode,
      this.stopName,
      this.agencyId,
      this.stopLat,
      this.stopLon,
      this.parentStation});

  BusStop.fromJson(Map<String, dynamic> json) {
    stopSequence = json['stop_sequence'];
    stopId = json['stop_id'];
    stopCode = json['stop_code'];
    stopName = json['stop_name'];
    agencyId = json['agency_id'];
    stopLat = json['stop_lat'];
    stopLon = json['stop_lon'];
    parentStation = json['parent_station'];

    //自己增加
    direction = json['direction'];
    if (json['belongTo'] != null) {
      belongToRoute = BusRoute.fromJson(json['belongTo']);
    }
    atIndex = json['atIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stop_sequence'] = stopSequence;
    data['stop_id'] = stopId;
    data['stop_code'] = stopCode;
    data['stop_name'] = stopName;
    data['agency_id'] = agencyId;
    data['stop_lat'] = stopLat;
    data['stop_lon'] = stopLon;
    data['parent_station'] = parentStation;

    data['direction'] = direction;
    data['belongTo'] = belongToRoute?.toJson();
    data['atIndex'] = atIndex;

    return data;
  }

  @override
  bool operator ==(Object other) =>
      other is BusStop && stopId == other.stopId && stopName == other.stopName;
  @override
  int get hashCode => Object.hash(stopId, stopName);
}
