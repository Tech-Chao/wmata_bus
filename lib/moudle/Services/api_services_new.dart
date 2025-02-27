import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/bus_incident.dart';
import 'package:wmata_bus/Model/bus_prediction_new.dart';
import 'package:wmata_bus/Model/bus_route_detail_new.dart';
import 'package:wmata_bus/Model/bus_route_new.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:wmata_bus/Model/rail_predictino.dart';

class APIService {
  static String apiKey = "api_key";
  static String key = "6fa3d902831a42158962db3902df4ef3";

// https://api.wmata.com/Bus.svc/json/jRoutes
  static Future<List<BusRouteNew>?> getBusroute() async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse('http://api.wmata.com/Bus.svc/json/jRoutes');
      var request = await httpClient.getUrl(uri);
      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        // Read response
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> routeMaps =
            (data["Routes"] as List<dynamic>).cast<Map<String, dynamic>>();
        List<BusRouteNew> routes =
            routeMaps.map((e) => BusRouteNew.fromJson(e)).toList();
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

  // http://api.wmata.com/Rail.svc/json/jStations
  static Future<List<RailStation>?> getRailStation() async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse('http://api.wmata.com/Rail.svc/json/jStations');
      var request = await httpClient.getUrl(uri);
      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> stationMaps =
            (data["Stations"] as List<dynamic>).cast<Map<String, dynamic>>();
        List<RailStation> stations =
            stationMaps.map((e) => RailStation.fromJson(e)).toList();
        return stations;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error getRailStation: $error');
      return null;
    }
  }

  // http://api.wmata.com/Bus.svc/json/jRouteDetails?RouteID=1a
  static Future<BusRouteDetailNew?> getRouteDetail(
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
        BusRouteDetailNew routeDetail = BusRouteDetailNew.fromJson(data);
        return routeDetail;
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

  static Future<List<RailStation>?> getRailStationIncidents() async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse('http://api.wmata.com/Incidents.svc/json/Incidents');
      var request = await httpClient.getUrl(uri);
      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> stationMaps =
            (data["Stations"] as List<dynamic>).cast<Map<String, dynamic>>();
        List<RailStation> stations =
            stationMaps.map((e) => RailStation.fromJson(e)).toList();
        return stations;
      } else {
        debugPrint('HTTP request failed with status ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error getRailStationInfo: $error');
      return null;
    }
  }

  // http://api.wmata.com/NextBusService.svc/json/jPredictions[?StopID]
  static Future<List<BusPredictionNew>?> getBusPredictions(
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
        List<BusPredictionNew>? predictions =
            predictionMaps.map((e) => BusPredictionNew.fromJson(e)).toList();
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

  // http://api.wmata.com/StationPrediction.svc/json/GetPrediction/{StationCodes}
  static Future<List<RailPrediction>?> getRailPredictions(
      {required String stationCodes}) async {
    try {
      var httpClient = HttpClient();
      var uri = Uri.parse(
          'http://api.wmata.com/StationPrediction.svc/json/GetPrediction/$stationCodes');
      var request = await httpClient.getUrl(uri);
      request.headers.add(apiKey, key);
      var response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        var responseBody = await utf8.decodeStream(response);
        Map<String, dynamic> data = json.decode(responseBody);
        List<Map<String, dynamic>> predictionMaps =
            (data["Trains"] as List<dynamic>).cast<Map<String, dynamic>>();
        List<RailPrediction>? predictions =
            predictionMaps.map((e) => RailPrediction.fromJson(e)).toList();
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
