import 'package:wmata_bus/Model/bus_route.dart';
import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/rail_route.dart';

class AppRouteProvider extends ChangeNotifier {
  List<BusRoute>? _busRoutes;
  List<BusRoute>? get busRoutes => _busRoutes;

  List<RailRoute>? _railRoutes;
  List<RailRoute>? get railRoutes => _railRoutes;

  void setBusRoutes(List<BusRoute>? data) {
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
