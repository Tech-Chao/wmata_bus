import 'dart:convert';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Utils/store_manager.dart';

const kFavoriteRoutes = "kFavoriteRoutes";

class FavoriteStorer {
  /// 收藏站点
  static Future<List<BusStop>> getFavoriteStops() async {
    String? jsonString = await StoreManager.get(kFavoriteRoutes);
    if (jsonString == null) {
      return <BusStop>[];
    }
    List<Map<String, dynamic>> res =
        List<Map<String, dynamic>>.from(json.decode(jsonString));
    List<BusStop> stops = res.map((e) => BusStop.fromJson(e)).toList();
    return stops;
  }

  // 存放收藏站点
  static Future<List<BusStop>> addFavoriteStops(BusStop addStop) async {
    List<BusStop> favorStops = await FavoriteStorer.getFavoriteStops();
    if (addStop.stopId == null) {
      return favorStops;
    }
    favorStops.insert(0, addStop);
    String jsonString = json.encode(favorStops);
    StoreManager.save(kFavoriteRoutes, jsonString);
    return favorStops;
  }

  static Future<List<BusStop>> removeFavoriteStop(BusStop removeStop) async {
    List<BusStop> favorStops = await FavoriteStorer.getFavoriteStops();
    for (var stop in favorStops) {
      if (removeStop.stopId == stop.stopId) {
        favorStops.remove(stop);
        break;
      }
    }
    String jsonString = json.encode(favorStops);
    StoreManager.save(kFavoriteRoutes, jsonString);
    return favorStops;
  }

  static Future<bool> clear() async {
    return StoreManager.remove(kFavoriteRoutes);
  }
}
