import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wmata_bus/Model/bus_incident.dart';
import 'package:wmata_bus/Model/bus_route.dart';
import 'package:wmata_bus/Providers/favorite_provider.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/Utils/store_manager.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wmata_bus/moudle/Services/api_services.dart';
import 'package:wmata_bus/moudle/Stop/View/bus_stop_cell.dart';
import 'package:wmata_bus/Model/bus_route_detail.dart';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/moudle/Stop/incident_page.dart';

class BusStopPage extends StatefulWidget {
  final BusRoute? route;
  final BusStop? stop;

  const BusStopPage({super.key, required this.route, this.stop});

  @override
  State<BusStopPage> createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  // State variables
  bool isLoading = false;
  BusRouteDetail? routeDetail;
  String? direction2;
  BusStop? selectedStop;
  Timer? _timer;
  List<BusIncident>? incidentList;
  bool autoRefresh = false;
  final ValueNotifier<int> remindSeconds = ValueNotifier<int>(60);
  // 应用内评分
  final InAppReview inAppReview = InAppReview.instance;

  // Scroll controllers
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // Ad related
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await Future.wait([
      _loadRouteDetail(),
      _loadAutoRefresh(),
      _loadBusIncidents(),
      _loadAd()
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  void checkAppLaunchCountAndReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('launchCount') ?? 0;
    launchCount++;
    prefs.setInt('launchCount', launchCount);
    if (launchCount == 5) {
      requestAppReview();
    }
  }

  requestAppReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  Future<void> _loadRouteDetail() async {
    if (widget.route?.routeID == null) return;
    await fetchRouteDetail(widget.route!.routeID!);
  }

  Future<void> _loadAutoRefresh() async {
    final tempAutoRefresh = await StoreManager.get('autoRefresh');

    setState(() {
      autoRefresh =
          tempAutoRefresh == null ? false : bool.parse(tempAutoRefresh);
    });

    if (autoRefresh) {
      _startRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remindSeconds.value > 0 && selectedStop != null) {
        remindSeconds.value--;
        if (mounted && !isLoading && remindSeconds.value == 0) {
          fetchPredictions();
        }
      }
    });
  }

  Future<void> _loadBusIncidents() async {
    if (widget.route?.routeID == null) return;
    await fetchBusIncidents(widget.route!.routeID!);
  }

  Future<void> fetchBusIncidents(String routeId) async {
    final incidents = await APIService.getBusIncidents(routeId: routeId);
    if (incidents == null || !mounted) return;

    setState(() => incidentList = incidents);
  }

  Future<void> fetchRouteDetail(String routeId) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final res = await APIService.getRouteDetail(routeId: routeId);
      if (res == null) return;

      _updateRouteStops(res);
      _handleInitialStop(res);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _updateRouteStops(BusRouteDetail res) {
    res.direction0?.stops?.forEach((e) => e.route = widget.route);
    res.direction1?.stops?.forEach((e) => e.route = widget.route);
    direction2 = res.direction0?.directionText;
    if (mounted) {
      setState(() => routeDetail = res);
    }
  }

  void _handleInitialStop(BusRouteDetail res) {
    if (widget.stop == null) return;

    setState(() {
      direction2 = widget.stop!.direction;
    });

    final directionModel = direction2 == res.direction0?.directionText
        ? res.direction0
        : res.direction1;
    final atIndex = directionModel?.stops?.indexOf(widget.stop!);

    if (atIndex != null && atIndex >= 0) {
      Future.delayed(const Duration(milliseconds: 30), () {
        itemScrollController.jumpTo(index: atIndex);
        setState(() => ontapStopCell(directionModel!.stops![atIndex]));
      });
    }
  }

  Future<void> fetchPredictions() async {
    if (selectedStop == null) return;

    setState(() => selectedStop?.isLoading = true);

    try {
      final predictions =
          await APIService.getBusPredictions(stpid: selectedStop!.stopID!);

      final directionModel =
          direction2 == routeDetail?.direction0?.directionText
              ? routeDetail?.direction0
              : routeDetail?.direction1;

      final filteredPredictions = predictions
          ?.where((element) =>
              element.routeID == widget.route?.routeID &&
              element.directionNum == directionModel?.directionNum)
          .toList();

      if (mounted) {
        setState(() {
          remindSeconds.value = 60;
          selectedStop?.isLoading = false;
          selectedStop?.predictions = filteredPredictions;
          // 如果预测列表不为空，则请求应用评分
          if (filteredPredictions != null && filteredPredictions.isNotEmpty) {
            checkAppLaunchCountAndReview();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          selectedStop?.isLoading = false;
          selectedStop?.predictions = null;
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

  void ontapStopCell(BusStop stop) {
    if (selectedStop?.isLoading ?? false) return;

    setState(() {
      selectedStop?.isSelected = false;
      selectedStop?.predictions = null;
      stop.isSelected = true;
      selectedStop = stop;
    });

    fetchPredictions();
  }

  @override
  Widget build(BuildContext context) {
    final routeNavTitle = widget.route?.routeID ?? "";
    final descriptionTitle =
        (widget.route?.name ?? "").split(' - ').sublist(1).join(' - ');

    final directionModel = direction2 == routeDetail?.direction0?.directionText
        ? routeDetail?.direction0
        : routeDetail?.direction1;
    final destinationName = directionModel?.tripHeadsign;

    final favorStops = context.watch<FavoriteProvder>().busFavorites;

    final directionNames = [
      routeDetail?.direction0?.directionText,
      routeDetail?.direction1?.directionText,
    ].whereType<String>().toList();

    final segmentedWidgets = Map.fromEntries(directionNames.map((e) => MapEntry(
        e,
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              e,
              style: TextStyle(
                  color: directionModel?.directionText == e
                      ? CupertinoColors.white
                      : CupertinoColors.black),
            )))));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context, routeNavTitle, descriptionTitle),
      body: _buildBody(context, directionModel, segmentedWidgets,
          destinationName, favorStops),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String title, String subtitle) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white)),
          Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white)),
        ],
      ),
      actions: const [SizedBox(width: 45)],
    );
  }

  Widget _buildBody(
      BuildContext context,
      Direction? directionModel,
      Map<String, Widget> segmentedWidgets,
      String? destinationName,
      List<BusStop> favorStops) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (directionModel?.stops == null ||
        directionModel?.stops!.isEmpty == true) {
      return Center(
          child: Text(
              "No scheduled service today for the ${routeDetail?.routeID}",
              style: Theme.of(context).textTheme.titleMedium));
    }

    return SafeArea(
      child: Column(
        children: [
          _getAdWidget(),
          _buildDirectionSelector(context, segmentedWidgets, directionModel),
          _buildDestinationHeader(context, destinationName),
          _buildRefreshStatus(context),
          _buildStopsList(context, directionModel, favorStops),
        ],
      ),
    );
  }

  Widget _buildDirectionSelector(BuildContext context,
      Map<String, Widget> segmentedWidgets, Direction? directionModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: segmentedWidgets.length > 1
          ? CupertinoSlidingSegmentedControl<String>(
              thumbColor: const Color(0xff333333),
              children: segmentedWidgets,
              groupValue: directionModel?.directionText,
              onValueChanged: (String? value) {
                if (directionModel?.directionText != value) {
                  setState(() {
                    direction2 = value;
                    directionModel =
                        value == routeDetail?.direction0?.directionText
                            ? routeDetail?.direction0
                            : routeDetail?.direction1;
                  });
                }
              },
            )
          : Text(directionModel?.directionText ?? "",
              style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildDestinationHeader(
      BuildContext context, String? destinationName) {
    return Text('TO $destinationName',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall);
  }

  Widget _buildRefreshStatus(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: remindSeconds,
        builder: (context, value, child) {
          final message = autoRefresh
              ? "Next refresh in $value seconds"
              : "Auto-refresh disabled, please refresh manually";

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          );
        });
  }

  Widget _buildStopsList(BuildContext context, Direction? directionModel,
      List<BusStop> favorStops) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemCount: directionModel?.stops?.length ?? 0,
        itemBuilder: (context, index) {
          final stop = directionModel?.stops?[index];
          if (stop == null) return Container();

          return GestureDetector(
            onTap: () => ontapStopCell(stop),
            child: RouteStopCell(
              isFavorite: favorStops.contains(stop),
              stop: stop,
              atIndex: "${index + 1}",
              addFavorite: () => _handleFavorite(context, stop, favorStops),
            ),
          );
        },
      ),
    );
  }

  void _handleFavorite(
      BuildContext context, BusStop stop, List<BusStop> favorStops) {
    if (favorStops.contains(stop)) {
      context.read<FavoriteProvder>().removeBusFavorite(selectedStop!);
    } else {
      selectedStop?.direction = direction2;
      context.read<FavoriteProvder>().addBusFavorite(selectedStop!);
    }
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (incidentList == null || incidentList!.isEmpty) {
      return null;
    }

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

  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });

    await _initializeAd();
  }

  Future<void> _initializeAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      if (kDebugMode) {
        print('Unable to get height of anchored banner.');
      }
      return;
    }

    final adUnitId = kDebugMode
        ? (Platform.isAndroid
            ? ConstTool.kAndroidDebugBannerId
            : ConstTool.kiOSDebugBannerId)
        : (Platform.isAndroid
            ? ConstTool.kAndroidReleaseBannerId
            : ConstTool.kiOSReleaseBannerId);

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: _handleAdLoaded,
        onAdFailedToLoad: _handleAdFailedToLoad,
      ),
    );

    return _anchoredAdaptiveAd!.load();
  }

  void _handleAdLoaded(Ad ad) {
    if (kDebugMode) {
      print('$ad loaded: ${ad.responseInfo}');
    }
    if (!mounted) return;

    setState(() {
      _anchoredAdaptiveAd = ad as BannerAd;
      _isLoaded = true;
    });
  }

  void _handleAdFailedToLoad(Ad ad, LoadAdError error) {
    if (kDebugMode) {
      print('Anchored adaptive banner failedToLoad: $error');
    }
    ad.dispose();
  }
}
