import 'package:wmata_bus/Model/bus_route.dart';
import 'package:flutter/material.dart';

class AppRouteProvider extends ChangeNotifier {
  List<BusRoute>? _busRoutes;
  List<BusRoute>? get busRoutes => _busRoutes;

  void setBusRoutes(List<BusRoute>? data) {
    _busRoutes = data
        ?.where((element) =>
            !element.routeId!.contains("*") && !element.routeId!.contains("/"))
        .toList();
    notifyListeners();
  }
}
