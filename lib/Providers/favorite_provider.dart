import 'package:flutter/foundation.dart';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:wmata_bus/Utils/favorite_storer.dart';

class FavoriteProvder with ChangeNotifier, DiagnosticableTreeMixin {
  List<BusStop> _busFavorites = [];
  List<BusStop> get busFavorites => _busFavorites;

  final List<RailStation> _railStationFavorites = [];
  List<RailStation> get railStationFavorites => _railStationFavorites;

// 设置公交收藏
  setBusFavoriteStops(List<BusStop> localFavorites) {
    _busFavorites = localFavorites;
    notifyListeners();
  }

  setRailStationFavorites(List<RailStation> localFavorites) {
    _railStationFavorites.addAll(localFavorites);
    notifyListeners();
  }

  // 新增收藏
  addBusFavorite(BusStop model) {
    _busFavorites.insert(0, model);
    FavoriteStorer.addFavoriteBusStops(model);
    notifyListeners();
  }

  // 是否收藏站点
  bool isFavoriteBus(BusStop stop) {
    return _busFavorites.contains(stop);
  }

  bool isFavoriteRailStation(RailStation station) {
    return _railStationFavorites.contains(station);
  }

  // 新增收藏
  addRailStationFavorite(RailStation station) {
    _railStationFavorites.insert(0, station);
    FavoriteStorer.addFavoriteRailStations(station);
    notifyListeners();
  }

  removeRailStationFavorite(RailStation station) {
    _railStationFavorites.remove(station);
    FavoriteStorer.removeFavoriteRailStation(station);
    notifyListeners();
  }

  // 移除某个收藏
  removeBusFavorite(BusStop model) {
    // 当前数据源修改
    for (var i = 0; i < _busFavorites.length; i++) {
      BusStop innerFavorite = _busFavorites[i];
      if (innerFavorite.stopID == model.stopID) {
        _busFavorites.removeAt(i);
        break;
      }
    }
    FavoriteStorer.removeFavoriteBusStop(model);
    notifyListeners();
  }

  clearFavorites() {
    _busFavorites.clear();
    FavoriteStorer.clear();
    notifyListeners();
  }
}
