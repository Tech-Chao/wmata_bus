class RailRoute {
  String? displayName;
  String? endStationCode;
  String? internalDestination1;
  String? internalDestination2;
  String? lineCode;
  String? startStationCode;

  RailRoute(
      {this.displayName,
      this.endStationCode,
      this.internalDestination1,
      this.internalDestination2,
      this.lineCode,
      this.startStationCode});

  RailRoute.fromJson(Map<String, dynamic> json) {
    displayName = json['DisplayName'];
    endStationCode = json['EndStationCode'];
    internalDestination1 = json['InternalDestination1'];
    internalDestination2 = json['InternalDestination2'];
    lineCode = json['LineCode'];
    startStationCode = json['StartStationCode'];
  }

  Map<String, dynamic> toJson() {
    // ignore: prefer_collection_literals
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['DisplayName'] = displayName;
    data['EndStationCode'] = endStationCode;
    data['InternalDestination1'] = internalDestination1;
    data['InternalDestination2'] = internalDestination2;
    data['LineCode'] = lineCode;
    data['StartStationCode'] = startStationCode;
    return data;
  }
}
