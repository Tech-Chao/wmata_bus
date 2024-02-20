import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/bus_stop.dart';

class BusStopProvider extends ChangeNotifier {
  List<BusStop>? _busStop;
  List<BusStop>? get busStop => _busStop;

  void setBusStops(List<BusStop>? data) {
    _busStop = data;
    notifyListeners();
  }
}
