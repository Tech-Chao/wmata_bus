import 'package:wmata_bus/Model/bus_route_new.dart';
import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/rail_station.dart';

class AppRouteProvider extends ChangeNotifier {
  List<BusRouteNew>? _busRoutes;
  List<BusRouteNew>? get busRoutes => _busRoutes;

  List<RailStation>? _railStations;
  List<RailStation>? get railStations => _railStations;

  void setBusRoutes(List<BusRouteNew>? data) {
    _busRoutes = data;
    notifyListeners();
  }

  void setRailStations(List<RailStation>? data) {
    _railStations = data;
    notifyListeners();
  }
}
