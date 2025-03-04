import 'dart:convert';

import 'package:wmata_bus/Model/bus_route.dart';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Model/rail_route.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:wmata_bus/Providers/favorite_provider.dart';
import 'package:wmata_bus/Providers/route_provider.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/Utils/favorite_storer.dart';
import 'package:wmata_bus/moudle/Tab/tab_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob initialization error: $e');
  }
  // 异步加载本地公交数据JSON
  List<BusRoute>? routes = await loadRouteData();

  List<RailRoute>? railRoutes = await loadRailRoutesData();

  List<BusStop> favoriteStops = await FavoriteStorer.getFavoriteBusStops();
  List<RailStation> favoriteStations = await FavoriteStorer.getFavoriteRailStations();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (context) => AppRouteProvider()
          ..setBusRoutes(routes)
          ..setRailRoutes(railRoutes)),
    ChangeNotifierProvider(
        create: (context) => FavoriteProvder()
          ..setBusFavoriteStops(favoriteStops)
          ..setRailStationFavorites(favoriteStations)),
    // ChangeNotifierProvider(
    //     create: (context) => BusStopProvider()..setBusStops(stops)),
  ], child: const MyApp()));
}

const defaultTextThemeData = TextTheme(
  headlineLarge: TextStyle(
      fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white),
  headlineMedium: TextStyle(
      fontSize: 19.0, fontWeight: FontWeight.bold, color: Colors.white),
  headlineSmall: TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
  titleLarge: TextStyle(fontSize: 20.0),
  titleMedium: TextStyle(fontSize: 18.0, color: Color(0xff333333)),
  titleSmall: TextStyle(fontSize: 14.0, color: Color(0xff333333)),
);

const olderTextThemeData = TextTheme(
  headlineLarge: TextStyle(
      fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
  headlineMedium: TextStyle(
      fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
  headlineSmall: TextStyle(
      fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
  titleLarge: TextStyle(fontSize: 30.0),
  titleMedium: TextStyle(fontSize: 26.0, color: Color(0xff333333)),
  titleSmall: TextStyle(fontSize: 20.0, color: Color(0xff333333)),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'DC Bus Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xff008457),
            primarySwatch: createMaterialColor(const Color(0xff008457)),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff008457),
              brightness: Brightness.light,
            ),
            navigationBarTheme: const NavigationBarThemeData(
                backgroundColor: Color(0xff008457)),
            appBarTheme: const AppBarTheme(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xff008457)),
            buttonTheme: const ButtonThemeData(
                buttonColor: Colors.white, highlightColor: Color(0xff2668AF)),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff008457))),
            textTheme: defaultTextThemeData,
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xff008457))),
        home: const MyTabPage());
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

// 读取本地数据
Future<List<BusRoute>?> loadRouteData() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prefsData = prefs.getString(ConstTool.kAllRouteskey);
    if (prefsData != null) {
      List<Map<String, dynamic>> jsonMaps =
          json.decode(prefsData).cast<Map<String, dynamic>>() ?? [];
      List<BusRoute>? routes =
          jsonMaps.map((e) => BusRoute.fromJson(e)).toList();
      return routes;
    }

    // 如果不存在则从 assets 中加载
    String jsonString = await rootBundle.loadString('assets/bus_routes.json');
    List<dynamic> routeMaps = json.decode(jsonString);
    List<BusRoute>? routes =
        routeMaps.map((dynamic e) => BusRoute.fromJson(e)).toList();
    return routes;
  } catch (error) {
    debugPrint('Error loading local JSON: $error');
    return [];
  }
}

Future<List<RailRoute>?> loadRailRoutesData() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prefsData = prefs.getString(ConstTool.kAllRailRouteskey);
    if (prefsData != null) {
      List<Map<String, dynamic>> jsonMaps =
          json.decode(prefsData).cast<Map<String, dynamic>>() ?? [];
      List<RailRoute>? routes =
          jsonMaps.map((e) => RailRoute.fromJson(e)).toList();
      return routes;
    }

    // 如果不存在则从 assets 中加载
    String jsonString = await rootBundle.loadString('assets/rail_routes.json');
    List<dynamic> routeMaps = json.decode(jsonString);
    List<RailRoute>? routes =
        routeMaps.map((dynamic e) => RailRoute.fromJson(e)).toList();
    return routes;
  } catch (error) {
    debugPrint('Error loading local rail routes JSON: $error');
    return [];
  }
}
