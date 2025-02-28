import 'package:wmata_bus/Model/rail_predictino.dart';
import 'package:wmata_bus/Model/rail_route.dart';

class RailStation {
  Address? address;
  String? code;
  double? lat;
  String? lineCode1;
  String? lineCode2;
  String? lineCode3;
  String? lineCode4;
  double? lon;
  String? name;
  String? stationTogether1;
  String? stationTogether2;

  // 自增
  RailRoute? route;
  bool isSelected = false;
  bool isLoading = false;
  List<RailPrediction>? predictions;

  RailStation(
      {this.address,
      this.code,
      this.lat,
      this.lineCode1,
      this.lineCode2,
      this.lineCode3,
      this.lineCode4,
      this.lon,
      this.name,
      this.stationTogether1,
      this.stationTogether2,
      this.route});

  RailStation.fromJson(Map<String, dynamic> json) {
    address =
        json['Address'] != null ? Address.fromJson(json['Address']) : null;
    code = json['Code'];
    lat = json['Lat'];
    lineCode1 = json['LineCode1'];
    lineCode2 = json['LineCode2'];
    lineCode3 = json['LineCode3'];
    lineCode4 = json['LineCode4'];
    lon = json['Lon'];
    name = json['Name'];
    stationTogether1 = json['StationTogether1'];
    stationTogether2 = json['StationTogether2'];
    if (json['Route'] != null) {
      route = RailRoute.fromJson(json['Route']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (address != null) {
      data['Address'] = address!.toJson();
    }
    data['Code'] = code;
    data['Lat'] = lat;
    data['LineCode1'] = lineCode1;
    data['LineCode2'] = lineCode2;
    data['LineCode3'] = lineCode3;
    data['LineCode4'] = lineCode4;
    data['Lon'] = lon;
    data['Name'] = name;
    data['StationTogether1'] = stationTogether1;
    data['StationTogether2'] = stationTogether2;
    if (route != null) {
      data['Route'] = route!.toJson();
    }
    return data;
  }

  @override
  bool operator ==(Object other) =>
      other is RailStation &&
      code == other.code &&
      name == other.name &&
      route?.lineCode == other.route?.lineCode;
      
  @override
  int get hashCode => Object.hash(code, name, route?.lineCode);
}

class Address {
  String? city;
  String? state;
  String? street;
  String? zip;

  Address({this.city, this.state, this.street, this.zip});

  Address.fromJson(Map<String, dynamic> json) {
    city = json['City'];
    state = json['State'];
    street = json['Street'];
    zip = json['Zip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['City'] = city;
    data['State'] = state;
    data['Street'] = street;
    data['Zip'] = zip;
    return data;
  }
}
