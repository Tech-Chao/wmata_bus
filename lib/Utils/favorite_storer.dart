import 'dart:convert';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Utils/store_manager.dart';

const kFavoriteRoutes = "kFavoriteRoutes";

class FavoriteStorer {
  /// 收藏站点
  static Future<List<BusStop>> getFavoriteBusStops() async {
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
  static Future<List<BusStop>> addFavoriteBusStops(BusStop addStop) async {
    List<BusStop> favorStops = await FavoriteStorer.getFavoriteBusStops();
    if (addStop.stopID == null) {
      return favorStops;
    }
    favorStops.insert(0, addStop);
    String jsonString = json.encode(favorStops);
    StoreManager.save(kFavoriteRoutes, jsonString);
    return favorStops;
  }

  static Future<List<BusStop>> removeFavoriteBusStop(BusStop removeStop) async {
      List<BusStop> favorStops = await FavoriteStorer.getFavoriteBusStops();
    for (var stop in favorStops) {
      if (removeStop.stopID == stop.stopID) {
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
