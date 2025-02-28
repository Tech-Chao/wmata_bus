import 'dart:convert';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:wmata_bus/Utils/store_manager.dart';

const kFavoriteRoutes = "kFavoriteRoutes";
const kFavoriteRailStations = "kFavoriteRailStations";

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

  /// 收藏站点
  static Future<List<RailStation>> getFavoriteRailStations() async {
    String? jsonString = await StoreManager.get(kFavoriteRailStations);
    if (jsonString == null) {
      return <RailStation>[];
    }
    List<Map<String, dynamic>> res =
        List<Map<String, dynamic>>.from(json.decode(jsonString));
    List<RailStation> stops = res.map((e) => RailStation.fromJson(e)).toList();
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

  static Future<List<RailStation>> addFavoriteRailStations(
      RailStation addStop) async {
    List<RailStation> favorStops =
        await FavoriteStorer.getFavoriteRailStations();
    if (addStop.code == null) {
      return favorStops;
    }
    favorStops.insert(0, addStop);
    String jsonString = json.encode(favorStops);
    StoreManager.save(kFavoriteRailStations, jsonString);
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

  static Future<List<RailStation>> removeFavoriteRailStation(
      RailStation removeStop) async {
    List<RailStation> favorStops =
        await FavoriteStorer.getFavoriteRailStations();
    for (var stop in favorStops) {
      if (removeStop.code == stop.code) {
        favorStops.remove(stop);
        break;
      }
    }
    String jsonString = json.encode(favorStops);
    StoreManager.save(kFavoriteRailStations, jsonString);
    return favorStops;
  }

  static Future<void> clear() async {
    StoreManager.remove(kFavoriteRoutes);
    StoreManager.remove(kFavoriteRailStations);
  }
}
