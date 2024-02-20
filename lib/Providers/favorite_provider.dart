import 'package:flutter/foundation.dart';
import 'package:wmata_bus/Model/bus_route_detail.dart';
import 'package:wmata_bus/Utils/favorite_storer.dart';

class FavoriteProvder with ChangeNotifier, DiagnosticableTreeMixin {
  List<InnerBusStop> _favorites = [];
  List<InnerBusStop> get favorites => _favorites;

  setFavoriteStops(List<InnerBusStop> localFavorites) {
    _favorites = localFavorites;
    notifyListeners();
  }

  // 新增收藏
  addFavorite(InnerBusStop model) {
    _favorites.insert(0, model);
    FavoriteStorer.addFavoriteStops(model);
    notifyListeners();
  }

  // 移除某个收藏
  removeFavorite(InnerBusStop model) {
    // 当前数据源修改
    for (var i = 0; i < _favorites.length; i++) {
      InnerBusStop innerFavorite = _favorites[i];
      if (innerFavorite.stopID == model.stopID) {
        _favorites.removeAt(i);
        break;
      }
    }
    FavoriteStorer.removeFavoriteStop(model);
    notifyListeners();
  }

  clearFavorites() {
    _favorites.clear();
    FavoriteStorer.clear();
    notifyListeners();
  }
}
