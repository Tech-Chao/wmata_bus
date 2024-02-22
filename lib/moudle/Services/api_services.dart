import 'dart:convert';
import 'dart:io';
import 'package:wmata_bus/Model/bus_incident.dart';
import 'package:wmata_bus/Model/bus_prediction.dart';
import 'package:wmata_bus/Model/bus_route.dart';
import 'package:flutter/foundation.dart';

class APIService {
  static String apiKey = "api_key";
  static String key = "6fa3d902831a42158962db3902df4ef3";

// https://api.wmata.com/Bus.svc/json/jRoutes
  static Future<List<BusRoute>?> updateRouteInfo() async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse('https://api.wmata.com/Bus.svc/json/jRoutes');
      var request = await httpClient.getUrl(uri);
      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> routeMaps =
            (data["Routes"] as List<dynamic>).cast<Map<String, dynamic>>();
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
      {required String routeId}) async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse(
          'https://api.wmata.com/Bus.svc/json/jRouteDetails?RouteID=$routeId');
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

  // https://api.wmata.com/Incidents.svc/json/BusIncidents[?Route]
  static Future<List<BusIncident>?> getBusIncidents(
      {required String routeId}) async {
    try {
      var httpClient = HttpClient();

      var uri = Uri.parse(
          'https://api.wmata.com/Incidents.svc/json/BusIncidents?Route=$routeId');
      var request = await httpClient.getUrl(uri);
      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> predictionMaps =
            (data["BusIncidents"] as List<dynamic>)
                .cast<Map<String, dynamic>>();
        List<BusIncident>? incidents =
            predictionMaps.map((e) => BusIncident.fromJson(e)).toList();
        return incidents;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error getRouteDirections: $error');
      return null;
    }
  }

  // https://api.wmata.com/NextBusService.svc/json/jPredictions[?StopID]
  static Future<List<BusPrediction>?> getpredictions(
      {required String stpid}) async {
    try {
      var httpClient = HttpClient();

      var uri = Uri.parse(
          'https://api.wmata.com/NextBusService.svc/json/jPredictions?StopID=$stpid');
      var request = await httpClient.getUrl(uri);
      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> predictionMaps =
            (data["Predictions"] as List<dynamic>).cast<Map<String, dynamic>>();
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
