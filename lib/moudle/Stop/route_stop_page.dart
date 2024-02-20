import 'dart:async';
import 'dart:io';

import 'package:wmata_bus/Model/bus_incident.dart';
import 'package:wmata_bus/Model/bus_prediction.dart';
import 'package:wmata_bus/Model/bus_route.dart';
import 'package:wmata_bus/Model/bus_route_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Providers/favorite_provider.dart';
import 'package:wmata_bus/Providers/stop_provider.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/Utils/store_manager.dart';
import 'package:wmata_bus/moudle/Services/api_services.dart';
import 'package:wmata_bus/moudle/Stop/View/route_stop_cell.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RouteStopPage extends StatefulWidget {
  final BusRoute route;
  final InnerBusStop? stop;
  const RouteStopPage({super.key, this.stop, required this.route});

  @override
  State<RouteStopPage> createState() => _RouteStopPageState();
}

class _RouteStopPageState extends State<RouteStopPage> {
  late BusRoute deepCopyRote;
  // 请求ing
  bool isLoading = false;
  BusRouteDetail? routeDetail;
  // 方向
  Direction? directionModel;
  // 方向
  bool direction = true;
  // 选中站点
  InnerBusStop? selectedStop;
  // 定时器
  Timer? _timer;

  String? alertMessage;

  bool autoRefresh = false;
  ValueNotifier<int> remindSeconds = ValueNotifier<int>(60);

  // late BusStopProvider yourProvider;

  //  滚动定位
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // 横幅广告
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void dispose() {
    // 取消定时器以避免内存泄漏
    _timer?.cancel();
    super.dispose();
  }

  loadAutoRefresh() async {
    String? tempAutoRefresh = await StoreManager.get('autoRefresh');
    setState(() {
      if (tempAutoRefresh == null) {
        autoRefresh = false;
      } else {
        autoRefresh = bool.parse(tempAutoRefresh);
      }
    });
    if (autoRefresh && selectedStop != null) {
      // 设置每分钟触发一次定时器
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (remindSeconds.value > 0) {
          remindSeconds.value -= 1;
        }
        if (mounted &&
            !isLoading &&
            selectedStop?.stopID != null &&
            remindSeconds.value == 0) {
          fetchPredictions(stop: selectedStop!);
        }
      });
    }
  }

  fetchBusIncidents(String routeId) async {
    List<BusIncident>? incidents =
        await APIService.getBusIncidents(routeId: routeId);
    if (incidents != null) {
      String temp = "";
      for (var element in incidents) {
        temp += element.description ?? "";
        temp += "\n";
      }
      setState(() {
        alertMessage = temp;
      });
    }
  }

  fetchRouteDetail(String routeId) async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic>? res =
        await APIService.getRouteDetail(routeId: routeId);

    setState(() {
      isLoading = false;
      if (res != null) {
        routeDetail = BusRouteDetail.fromJson(res);
        routeDetail?.direction0?.stops = routeDetail?.direction0?.stops!
            .where((element) => element.stopID != null && element.stopID != "0")
            .toList();
        routeDetail?.direction0?.stops?.asMap().forEach((index, value) {
          value.atIndex = index;
          // value.name = yourProvider.busStop
          //     ?.where((element) => value.stopID == element.stopCode.toString())
          //     .first
          //     .stopName;
        });
        routeDetail?.direction1?.stops = routeDetail?.direction1?.stops!
            .where((element) => element.stopID != null && element.stopID != "0")
            .toList();
        routeDetail?.direction1?.stops?.asMap().forEach((index, value) {
          value.atIndex = index;
          // value.name = yourProvider.busStop
          //     ?.where((element) => value.stopID == element.stopCode.toString())
          //     .first
          //     .stopName;
        });
        directionModel =
            direction ? routeDetail?.direction0 : routeDetail?.direction1;
      }
    });
    if (widget.stop != null) {
      selectedStop = directionModel?.stops?[widget.stop?.atIndex ?? 0];
      selectedStop?.isSelected = true;
      fetchPredictions(stop: selectedStop!);
    }
  }

  fetchPredictions({required InnerBusStop stop}) async {
    _timer?.cancel();
    setState(() {
      stop.isLoading = true;
    });
    List<BusPrediction>? predictions =
        await APIService.getpredictions(stpid: stop.stopID!);

    if (mounted) {
      setState(() {
        remindSeconds = ValueNotifier<int>(60);
        stop.isLoading = false;
        stop.predictions = predictions
            ?.where((element) =>
                element.directionNum == directionModel?.directionNum &&
                element.routeId == widget.route.routeId)
            .toList();
      });
    }
    if (autoRefresh && selectedStop != null) {
      // 设置每分钟触发一次定时器
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (mounted) {
          if (remindSeconds.value > 0) {
            remindSeconds.value -= 1;
          }
        }
        if (mounted &&
            !isLoading &&
            selectedStop != null &&
            remindSeconds.value == 0) {
          fetchPredictions(stop: selectedStop!);
        }
      });
    }
  }

  @override
  void initState() {
    // yourProvider = context.read<BusStopProvider>();

    deepCopyRote = BusRoute.fromJson(widget.route.toJson());
    if (widget.stop?.direction != null) {
      direction = widget.stop!.direction!;
    }
    // 路线详情
    fetchRouteDetail(deepCopyRote.routeId!);
    // 自动刷新
    loadAutoRefresh();
    // 请求路线告警
    fetchBusIncidents(deepCopyRote.routeId!);
    // Admob广告
    _loadAd();
    super.initState();
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
    String routeNavTitle = deepCopyRote.routeId ?? "";
    String? descriptionTitle =
        deepCopyRote.lineDescription ?? deepCopyRote.name!;
    String destinationName =
        "to ${direction ? routeDetail?.direction0?.directionText : routeDetail?.direction1?.directionText} TO ${direction ? routeDetail?.direction0?.tripHeadsign : routeDetail?.direction1?.tripHeadsign}";

    List<InnerBusStop> favorStops = context.watch<FavoriteProvder>().favorites;
    // // 遍历是否收藏
    if (directionModel?.stops != null) {
      for (var i = 0; i < directionModel!.stops!.length; i++) {
        InnerBusStop? tempStop = directionModel?.stops![i];
        if (favorStops.contains(tempStop)) {
          tempStop?.isFavorite = true;
        } else {
          tempStop?.isFavorite = false;
        }
      }
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(routeNavTitle,
                style: Theme.of(context).textTheme.headlineMedium),
            Text(descriptionTitle,
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  setState(() {
                    _timer?.cancel();
                    selectedStop?.isSelected = false;
                    selectedStop?.predictions = null;
                    selectedStop = null;
                    setState(() {
                      direction = !direction;
                      directionModel = direction
                          ? routeDetail?.direction0
                          : routeDetail?.direction1;
                    });
                    deepCopyRote = BusRoute.fromJson(widget.route.toJson());
                  });
                });
              },
              icon: const Icon(Icons.change_circle_outlined, size: 35))
        ],
      ),
      // No scheduled service today for the 29G
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : directionModel == null || directionModel!.stops!.isEmpty
              ? Center(
                  child: Text(
                      "No scheduled service today for the ${routeDetail?.routeId}",
                      style: Theme.of(context).textTheme.titleMedium))
              : SafeArea(
                  child: Column(
                    children: [
                      _getAdWidget(),
                      Text(destinationName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium),
                      ValueListenableBuilder<int>(
                          valueListenable: remindSeconds,
                          builder:
                              (BuildContext context, int value, Widget? child) {
                            String autoRefreshString = autoRefresh
                                ? "There are $value seconds left for the next refresh"
                                : "Automatic refresh is not enabled, please refresh manually";
                            return Text(autoRefreshString,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall);
                          }),
                      Expanded(
                        child: ScrollablePositionedList.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(), // 允许始终滚动
                          itemScrollController: itemScrollController,
                          itemPositionsListener: itemPositionsListener,
                          itemCount: directionModel?.stops?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            InnerBusStop? stop = directionModel?.stops?[index];
                            stop?.belongToRoute = deepCopyRote;

                            return GestureDetector(
                              onTap: () {
                                if (selectedStop != null &&
                                    selectedStop!.isLoading) {
                                  return;
                                }
                                selectedStop?.isSelected = false;
                                selectedStop?.predictions = null;
                                stop.isSelected = true;
                                selectedStop = stop;
                                fetchPredictions(stop: selectedStop!);
                              },
                              child: RouteStopCell(
                                stop: stop!,
                                addFavorite: () {
                                  if (stop.isFavorite) {
                                    // 移除
                                    context
                                        .read<FavoriteProvder>()
                                        .removeFavorite(selectedStop!);
                                  } else {
                                    // 收藏站点
                                    selectedStop?.direction = direction;
                                    context
                                        .read<FavoriteProvder>()
                                        .addFavorite(selectedStop!);
                                  }
                                  setState(() {
                                    stop.isFavorite = !stop.isFavorite;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: (alertMessage != null &&
              alertMessage!.replaceAll("\n", "").isNotEmpty)
          ? floatingButton(context)
          : null,
    );
  }

  Widget floatingButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    "Tip",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  content: Text(alertMessage!),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(
                            context, 'CupertinoAlertDialog - Normal, OK');
                      },
                      child: Text("OK",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: Theme.of(context).primaryColor)),
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.warning));
  }

  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });
    //  30天内五星好评去除广告
    String? haveFiveStarDate = await StoreManager.get("haveFiveStar");
    if (haveFiveStarDate != null && haveFiveStarDate != "0") {
      var date = DateTime.parse(haveFiveStarDate);
      var now = DateTime.now();
      var difference = now.difference(date);
      if (difference.inDays <= 3) {
        return;
      }
    }
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());
    if (size == null) {
      if (kDebugMode) {
        print('Unable to get height of anchored banner.');
      }
      return;
    }

    String adUnitId;
    if (kDebugMode) {
      adUnitId = Platform.isAndroid
          ? ConstTool.kAndroidDebugBannerId
          : ConstTool.kiOSDebugBannerId;
    } else {
      adUnitId = Platform.isAndroid
          ? ConstTool.kAndroidReleaseBannerId
          : ConstTool.kiOSReleaseBannerId;
    }
    _anchoredAdaptiveAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('$ad loaded: ${ad.responseInfo}');
          }
          if (!mounted) {
            return;
          }
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
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
