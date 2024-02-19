class BusIncident {
  String? dateUpdated;
  String? description;
  String? incidentID;
  String? incidentType;
  List<String>? routesAffected;

  BusIncident(
      {this.dateUpdated,
      this.description,
      this.incidentID,
      this.incidentType,
      this.routesAffected});

  BusIncident.fromJson(Map<String, dynamic> json) {
    dateUpdated = json['DateUpdated'];
    description = json['Description'];
    incidentID = json['IncidentID'];
    incidentType = json['IncidentType'];
    routesAffected = json['RoutesAffected'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DateUpdated'] = dateUpdated;
    data['Description'] = description;
    data['IncidentID'] = incidentID;
    data['IncidentType'] = incidentType;
    data['RoutesAffected'] = routesAffected;
    return data;
  }
}
