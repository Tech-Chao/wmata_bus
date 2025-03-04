import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wmata_bus/Model/bus_incident.dart';
import 'package:wmata_bus/Model/rail_predictino.dart';
import 'package:wmata_bus/Model/rail_route.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:wmata_bus/Providers/favorite_provider.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/Utils/store_manager.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wmata_bus/moudle/Services/api_services.dart';
import 'package:wmata_bus/moudle/Stop/View/rail_stop_cell.dart';
import 'package:wmata_bus/moudle/Stop/incident_page.dart';

class RailStopPage extends StatefulWidget {
  final RailRoute route;
  final RailStation? stop;
  const RailStopPage({super.key, required this.route, this.stop});

  @override
  State<RailStopPage> createState() => _RailStopPageState();
}

class _RailStopPageState extends State<RailStopPage> {
  bool isLoading = false;
  List<RailStation>? railStations;
  RailStation? selectedStop;
  Timer? _timer;
  String? alertMessage;
  bool autoRefresh = false;
  ValueNotifier<int> remindSeconds = ValueNotifier<int>(60);

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  List<BusIncident>? incidentList;

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  // 应用内评分
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await Future.wait([
      fetchRouteStations(),
      loadAutoRefresh(),
      _loadAd(),
      fetchRailIncidents()
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  Future<void> loadAutoRefresh() async {
    final tempAutoRefresh = await StoreManager.get('autoRefresh');

    setState(() {
      autoRefresh =
          tempAutoRefresh == null ? false : bool.parse(tempAutoRefresh);
    });

    if (autoRefresh && selectedStop != null) {
      _startRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remindSeconds.value > 0) {
        remindSeconds.value--;
      }
      if (mounted &&
          !isLoading &&
          selectedStop?.code != null &&
          remindSeconds.value == 0) {
        fetchRailPredictions(stop: selectedStop!);
      }
    });
  }

  void checkAppLaunchCountAndReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('launchCount') ?? 0;
    launchCount++;
    prefs.setInt('launchCount', launchCount);
    if (launchCount == 4) {
      requestAppReview();
    }
  }

  requestAppReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  Future<void> fetchRailIncidents() async {
    final incidents = await APIService.getRailIncidents();
    if (incidents == null || !mounted) return;

    setState(() => incidentList = incidents);
  }

  Future<void> fetchRouteStations() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<RailStation>? res = await APIService.getRailStationByLineCode(
          lineCode: widget.route.lineCode ?? "");
      res?.forEach((e) => e.route = widget.route);

      if (mounted) {
        setState(() {
          isLoading = false;
          railStations = res;
        });

        if (widget.stop != null) {
          final atIndex = railStations?.indexOf(widget.stop!);
          if (atIndex != null && atIndex >= 0) {
            Future.delayed(const Duration(milliseconds: 30), () {
              itemScrollController.jumpTo(index: atIndex);
              setState(() => _handleStationTap(railStations![atIndex]));
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchRailPredictions({required RailStation stop}) async {
    _timer?.cancel();

    setState(() {
      stop.isLoading = true;
    });

    try {
      List<RailPrediction>? predictions =
          await APIService.getRailPredictions(stationCodes: stop.code!);

      List<RailPrediction>? filteredPredictions = predictions
          ?.where((element) => element.line == widget.route.lineCode)
          .toList();
      if (mounted) {
        setState(() {
          remindSeconds.value = 60;
          stop.isLoading = false;
          stop.predictions = filteredPredictions;
          // 如果预测列表不为空，则请求应用评分
          if (filteredPredictions != null && filteredPredictions.isNotEmpty) {
            checkAppLaunchCountAndReview();
          }
        });
      }

      if (autoRefresh && selectedStop != null) {
        _startRefreshTimer();
      }
    } finally {
      if (mounted) {
        setState(() {
          stop.isLoading = false;
        });
      }
    }
  }

  Widget _getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_anchoredAdaptiveAd != null && _isLoaded) {
          return SizedBox(
            width: _anchoredAdaptiveAd!.size.width.toDouble(),
            height: _anchoredAdaptiveAd!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredAdaptiveAd!),
          );
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FavoriteProvder>();
    final favoriteStations = provider.railStationFavorites;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: _buildBody(context, favoriteStations),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (incidentList == null || incidentList!.isEmpty) {
      return null;
    }
    final filteredIncidents = incidentList!.where((element) =>
        element.linesAffected?.contains(widget.route.lineCode ?? "") ?? false);
    if (filteredIncidents.isEmpty) {
      return null;
    }

    incidentList = filteredIncidents.toList();
    return FloatingActionButton(
        onPressed: () => _showIncidentPageView(context),
        child: const Icon(Icons.warning));
  }

  void _showIncidentPageView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => IncidentPage(incidentList: incidentList!),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(widget.route.displayName ?? "",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)));
  } 

  Widget _buildBody(BuildContext context, List<RailStation> favoriteStations) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (railStations == null || railStations!.isEmpty) {
      return Center(
        child: Text(
          "No stations found for line ${widget.route.displayName}",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          _getAdWidget(),
          _buildRefreshStatus(context),
          _buildStationsList(context, favoriteStations),
        ],
      ),
    );
  }

  Widget _buildRefreshStatus(BuildContext context) {
    return Column(
      children: [
        // Text(
        //   widget.route.internalDestination2 ?? "",
        //   style: Theme.of(context).textTheme.titleSmall,
        // ),
        ValueListenableBuilder<int>(
            valueListenable: remindSeconds,
            builder: (context, value, child) {
              final message = autoRefresh
                  ? "Next refresh in $value seconds"
                  : "Auto-refresh disabled, Please refresh manually";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              );
            }),
      ],
    );
  }

  Widget _buildStationsList(
      BuildContext context, List<RailStation> favoriteStations) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemCount: railStations?.length ?? 0,
        itemBuilder: (context, index) {
          final station = railStations![index];
          return GestureDetector(
            onTap: () => _handleStationTap(station),
            child: RailStopCell(
              isFavorite: favoriteStations.contains(station),
              stop: station,
              atIndex: "${index + 1}",
              addFavorite: () => _handleFavorite(context, station),
            ),
          );
        },
      ),
    );
  }

  void _handleStationTap(RailStation station) {
    if (selectedStop?.isLoading ?? false) return;

    setState(() {
      selectedStop?.isSelected = false;
      selectedStop?.predictions = null;
      station.isSelected = true;
      selectedStop = station;
    });

    fetchRailPredictions(stop: station);
  }

  void _handleFavorite(BuildContext context, RailStation station) {
    final provider = context.read<FavoriteProvder>();
    bool isFavorite = provider.isFavoriteRailStation(station);

    setState(() {
      if (isFavorite) {
        provider.removeRailStationFavorite(station);
      } else {
        station.route = widget.route;
        provider.addRailStationFavorite(station);
      }
    });
  }

  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });

    String? haveFiveStarDate = await StoreManager.get("haveFiveStar");
    if (haveFiveStarDate != null && haveFiveStarDate != "0") {
      var date = DateTime.parse(haveFiveStarDate);
      var now = DateTime.now();
      if (now.difference(date).inDays <= 3) {
        return;
      }
    }

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      if (kDebugMode) {
        print('Unable to get height of anchored banner.');
      }
      return;
    }

    final adUnitId = kDebugMode
        ? Platform.isAndroid
            ? ConstTool.kAndroidDebugBannerId
            : ConstTool.kiOSDebugBannerId
        : Platform.isAndroid
            ? ConstTool.kAndroidReleaseBannerId
            : ConstTool.kiOSReleaseBannerId;

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('$ad loaded: ${ad.responseInfo}');
          }
          if (!mounted) return;
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (kDebugMode) {
            print('Anchored adaptive banner failedToLoad: $error');
          }
          ad.dispose();
        },
      ),
    );

    return _anchoredAdaptiveAd!.load();
  }
}
