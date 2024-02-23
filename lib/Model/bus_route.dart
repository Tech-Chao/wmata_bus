class BusRoute {
  String? routeId;
  String? agencyId;
  String? routeShortName;
  String? routeLongName;
  String? routeDesc;
  String? routeType;
  String? routeUrl;
  String? routeColor;
  String? routeTextColor;

  BusRoute(
      {this.routeId,
      this.agencyId,
      this.routeShortName,
      this.routeLongName,
      this.routeDesc,
      this.routeType,
      this.routeUrl,
      this.routeColor,
      this.routeTextColor});

  BusRoute.fromJson(Map<String, dynamic> json) {
    routeId = json['route_id'];
    agencyId = json['agency_id'];
    routeShortName = json['route_short_name'];
    routeLongName = json['route_long_name'];
    routeDesc = json['route_desc'];
    routeType = json['route_type'];
    routeUrl = json['route_url'];
    routeColor = json['route_color'];
    routeTextColor = json['route_text_color'];
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
    return data;
  }
}
