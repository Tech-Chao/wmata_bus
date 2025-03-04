import 'package:wmata_bus/Model/bus_route_new.dart';
import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/rail_route.dart';

class AppRouteProvider extends ChangeNotifier {
  List<BusRouteNew>? _busRoutes;
  List<BusRouteNew>? get busRoutes => _busRoutes;

  List<RailRoute>? _railRoutes;
  List<RailRoute>? get railRoutes => _railRoutes;

  void setBusRoutes(List<BusRouteNew>? data) {
    _busRoutes = data
        ?.where((e) =>
            e.routeID != null &&
            !(e.routeID!.contains("*") || e.routeID!.contains("/")))
        .toList();
    notifyListeners();
  }

  void setRailRoutes(List<RailRoute>? data) {
    _railRoutes = data;
    notifyListeners();
  }
}
