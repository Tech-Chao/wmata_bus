class BusIncident {
  String? dateUpdated;
  String? description;
  String? incidentID;
  String? incidentType;
  List<String>? routesAffected;
  String? linesAffected;

  BusIncident(
      {this.dateUpdated,
      this.description,
      this.incidentID,
      this.incidentType,
      this.routesAffected,
      this.linesAffected});

  BusIncident.fromJson(Map<String, dynamic> json) {
    dateUpdated = json['DateUpdated'];
    description = json['Description'];
    incidentID = json['IncidentID'];
    incidentType = json['IncidentType'];
    if (json['RoutesAffected'] != null) {
      routesAffected = json['RoutesAffected'].cast<String>();
    }
    linesAffected = json['LinesAffected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DateUpdated'] = dateUpdated;
    data['Description'] = description;
    data['IncidentID'] = incidentID;
    data['IncidentType'] = incidentType;
    data['RoutesAffected'] = routesAffected;
    data['LinesAffected'] = linesAffected;
    return data;
  }
}
