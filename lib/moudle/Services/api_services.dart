import 'dart:convert';
import 'dart:io';
import 'package:wmata_bus/Model/bus_prediction.dart';
import 'package:wmata_bus/Model/bus_route.dart';
import 'package:flutter/foundation.dart';
import 'package:wmata_bus/Model/bus_stop.dart';

class APIService {
  static String apiKey = "api_key";
  static String key = "6fa3d902831a42158962db3902df4ef3";

// https://www.ctabustracker.com/bustime/api/v2/getroutes??format=json&key=$key
  static Future<List<BusRoute>?> updateRouteInfo() async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse(
          'https://www.ctabustracker.com/bustime/api/v2/getroutes?format=json&key=$key');
      var request = await httpClient.getUrl(uri);

      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> routeMaps =
            (data["bustime-response"]["routes"] as List<dynamic>)
                .cast<Map<String, dynamic>>();
        List<BusRoute> routes =
            routeMaps.map((e) => BusRoute.fromJson(e)).toList();
        return routes;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error updateRouteInfo: $error');
      return null;
    }
  }

  // https://api.wmata.com/Bus.svc/json/jRouteDetails[?RouteID][&Date]
  static Future<Map<String, dynamic>?> getRouteDetail(
      {required String routeID}) async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse(
          'https://api.wmata.com/Bus.svc/json/jRouteDetails?RouteID=$routeID');
      var request = await httpClient.getUrl(uri);

      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        return data;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error getRouteDirections: $error');
      return null;
    }
  }

// http://ctabustracker.com/bustime/api/v2/getdirections?key=89dj2he89d8j3j3ksjhdue93j&format=json
  static Future<List<Map<String, String>>?> getRouteDirections(
      {required String rt}) async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse(
          'https://www.ctabustracker.com/bustime/api/v2/getdirections?format=json&key=$key&rt=$rt');
      var request = await httpClient.getUrl(uri);

      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, String>> directions = List<Map<String, String>>.from(
          (data["bustime-response"]["directions"] as List).map((item) =>
              Map<String, String>.from(item.map((key, value) =>
                  MapEntry<String, String>(key as String, value as String)))),
        );
        return directions;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error getRouteDirections: $error');
      return null;
    }
  }

  // https://www.ctabustracker.com/bustime/api/v1/getstops?key=89dj2he89d8j3j3ksjhdue93j&rt=20&dir=East%20Bound
  static Future<List<BusStop>?> getStops(
      {required String rt, required String dir}) async {
    try {
      var httpClient = HttpClient();

      var uri = Uri.parse(
          'https://ctabustracker.com/bustime/api/v2/getstops?key=$key&rt=$rt&dir=$dir&format=json');
      var request = await httpClient.getUrl(uri);

      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> stopMaps =
            (data["bustime-response"]["stops"] as List<dynamic>)
                .cast<Map<String, dynamic>>();
        List<BusStop>? stops =
            stopMaps.map((e) => BusStop.fromJson(e)).toList();
        return stops;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error getRouteDirections: $error');
      return null;
    }
  }

  // https://www.ctabustracker.com/bustime/api/v1/getpredictions?key=89dj2he89d8j3j3ksjhdue93j&rt=20&stpid=456
  static Future<List<BusPrediction>?> getpredictions(
      {required String rt, required String stpid}) async {
    try {
      var httpClient = HttpClient();

      var uri = Uri.parse(
          'https://ctabustracker.com/bustime/api/v2/getpredictions?key=$key&rt=$rt&stpid=$stpid&format=json');
      var request = await httpClient.getUrl(uri);

      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);

        if (data["bustime-response"]["prd"] == null) {
          return [];
        }
        List<Map<String, dynamic>> predictionMaps =
            (data["bustime-response"]["prd"] as List<dynamic>)
                .cast<Map<String, dynamic>>();
        List<BusPrediction>? predictions =
            predictionMaps.map((e) => BusPrediction.fromJson(e)).toList();
        return predictions;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error getRouteDirections: $error');
      return null;
    }
  }
}
