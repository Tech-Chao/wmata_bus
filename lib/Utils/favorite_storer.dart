import 'dart:convert';

import 'package:wmata_bus/Model/bus_route_detail.dart';

import 'package:wmata_bus/Utils/store_manager.dart';

const kFavoriteRoutes = "kFavoriteRoutes";

class FavoriteStorer {
  /// 收藏站点
  static Future<List<InnerBusStop>> getFavoriteStops() async {
    String? jsonString = await StoreManager.get(kFavoriteRoutes);
    if (jsonString == null) {
      return <InnerBusStop>[];
    }
    List<Map<String, dynamic>> res =
        List<Map<String, dynamic>>.from(json.decode(jsonString));
    List<InnerBusStop> stops =
        res.map((e) => InnerBusStop.fromJson(e)).toList();
    return stops;
  }

  // 存放收藏站点
  static Future<List<InnerBusStop>> addFavoriteStops(
      InnerBusStop addStop) async {
    List<InnerBusStop> favorStops = await FavoriteStorer.getFavoriteStops();
    if (addStop.stopID == null) {
      return favorStops;
    }
    favorStops.insert(0, addStop);
    String jsonString = json.encode(favorStops);
    StoreManager.save(kFavoriteRoutes, jsonString);
    return favorStops;
  }

  static Future<List<InnerBusStop>> removeFavoriteStop(
      InnerBusStop removeStop) async {
    List<InnerBusStop> favorStops = await FavoriteStorer.getFavoriteStops();
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
