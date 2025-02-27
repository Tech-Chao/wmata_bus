import 'package:flutter/foundation.dart';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Utils/favorite_storer.dart';

class FavoriteProvder with ChangeNotifier, DiagnosticableTreeMixin {
  List<BusStop> _favorites = [];
  List<BusStop> get favorites => _favorites;

  setFavoriteStops(List<BusStop> localFavorites) {
    _favorites = localFavorites;
    notifyListeners();
  }

  // 新增收藏
  addFavorite(BusStop model) {
    _favorites.insert(0, model);
    FavoriteStorer.addFavoriteBusStops(model);
    notifyListeners();
  }

  // 移除某个收藏
  removeFavorite(BusStop model) {
    // 当前数据源修改
    for (var i = 0; i < _favorites.length; i++) {
      BusStop innerFavorite = _favorites[i];
      if (innerFavorite.stopID == model.stopID) {
        _favorites.removeAt(i);
        break;
      }
    }
    FavoriteStorer.removeFavoriteBusStop(model);
    notifyListeners();
  }

  clearFavorites() {
    _favorites.clear();
    FavoriteStorer.clear();
    notifyListeners();
  }
}
