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
    data['stop_id'] = this.stopId;
    data['stop_code'] = this.stopCode;
    data['stop_name'] = this.stopName;
    data['stop_desc'] = this.stopDesc;
    data['stop_lat'] = this.stopLat;
    data['stop_lon'] = this.stopLon;
    data['zone_id'] = this.zoneId;
    data['stop_url'] = this.stopUrl;
    return data;
  }
}
