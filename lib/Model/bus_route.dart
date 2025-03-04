class BusRoute {
  String? routeID;
  String? name;
  String? lineDescription;

  BusRoute({this.routeID, this.name, this.lineDescription});

  BusRoute.fromJson(Map<String, dynamic> json) {
    routeID = json['RouteID'];
    name = json['Name'];
    lineDescription = json['LineDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RouteID'] = routeID;
    data['Name'] = name;
    data['LineDescription'] = lineDescription;
    return data;
  }
}
