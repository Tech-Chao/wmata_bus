class BusStop {
  int? stopId;
  int? stopCode;
  String? stopName;
  String? stopDesc;
  double? stopLat;
  double? stopLon;
  String? zoneId;
  String? stopUrl;

  BusStop(
      {this.stopId,
      this.stopCode,
      this.stopName,
      this.stopDesc,
      this.stopLat,
      this.stopLon,
      this.zoneId,
      this.stopUrl});

  BusStop.fromJson(Map<String, dynamic> json) {
    stopId = json['stop_id'];
    stopCode = json['stop_code'];
    stopName = json['stop_name'];
    stopDesc = json['stop_desc'];
    stopLat = json['stop_lat'];
    stopLon = json['stop_lon'];
    zoneId = json['zone_id'];
    stopUrl = json['stop_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stop_id'] = stopId;
    data['stop_code'] = stopCode;
    data['stop_name'] = stopName;
    data['stop_desc'] = stopDesc;
    data['stop_lat'] = stopLat;
    data['stop_lon'] = stopLon;
    data['zone_id'] = zoneId;
    data['stop_url'] = stopUrl;
    return data;
  }
}
