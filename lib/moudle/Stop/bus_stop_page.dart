import 'dart:async';
import 'dart:io';

import 'package:wmata_bus/Model/bus_incident.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wmata_bus/Model/bus_prediction_new.dart';
import 'package:wmata_bus/Model/bus_route_new.dart';
import 'package:wmata_bus/Providers/favorite_provider.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/Utils/store_manager.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wmata_bus/moudle/Services/api_services_new.dart';
import 'package:wmata_bus/moudle/Stop/View/bus_stop_cell.dart';
import 'package:wmata_bus/Model/bus_route_detail_new.dart';
import 'package:wmata_bus/Model/bus_stop.dart';

class BusStopPage extends StatefulWidget {
  final BusRouteNew? route;
  final BusStop? stop;
  const BusStopPage({super.key, required this.route, this.stop});

  @override
  State<BusStopPage> createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  // 请求ing
  bool isLoading = false;
  // 路线详情
  BusRouteDetailNew? routeDetail;
  // 方向
  bool direction = true;
  // 选中站点
  BusStop? selectedStop;
  // 定时器
  Timer? _timer;

  String? alertMessage;

  bool autoRefresh = false;
  ValueNotifier<int> remindSeconds = ValueNotifier<int>(60);

  //  滚动定位
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // 横幅广告
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void initState() {
    // 路线详情
    fetchRouteDetail(widget.route?.routeID ?? "");
    // 自动刷新
    loadAutoRefresh();
    // 请求路线告警
    fetchBusIncidents(widget.route?.routeID ?? "");
    // Admob广告
    _loadAd();
    super.initState();
  }

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
        if (remindSeconds.value > 0 && selectedStop != null) {
          remindSeconds.value -= 1;
        }
        if (mounted && !isLoading && remindSeconds.value == 0) {
          fetchPredictions();
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
      if (mounted) {
        setState(() {
          alertMessage = temp;
        });
      }
    }
  }

  fetchRouteDetail(String routeId) async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    BusRouteDetailNew? res = await APIService.getRouteDetail(routeId: routeId);

    res?.direction0?.stops?.forEach((e) {
      e.route = widget.route;
    });
    res?.direction1?.stops?.forEach((e) {
      e.route = widget.route;
    });

    setState(() {
      isLoading = false;
      if (res != null) {
        routeDetail = res;
      }
    });
    if (widget.stop != null) {
      setState(() {
        direction = widget.stop!.direction ?? true;
      });

      Direction? directionModel =
          direction ? routeDetail?.direction0 : routeDetail?.direction1;
      int? atIndex = directionModel?.stops?.indexOf(widget.stop!);

      if (atIndex != null && atIndex >= 0) {
        Future.delayed(const Duration(milliseconds: 300), () {
          itemScrollController.jumpTo(index: atIndex);
          ontapStopCell(widget.stop!);
        });
      }
    }
  }

  fetchPredictions() async {
    if (selectedStop == null) {
      return;
    }
    setState(() {
      selectedStop?.isLoading = true;
    });
    List<BusPredictionNew>? predictions =
        await APIService.getBusPredictions(stpid: selectedStop!.stopID!);
    List<BusPredictionNew>? pfilterRedictions = predictions
        ?.where((element) => element.routeID == widget.route?.routeID)
        .toList();
    if (pfilterRedictions != null && pfilterRedictions.isNotEmpty) {
      pfilterRedictions.sort((p1, p2) => p1.minutes!.compareTo(p2.minutes!));
    }
    if (mounted) {
      setState(() {
        remindSeconds = ValueNotifier<int>(60);
        selectedStop?.isLoading = false;
        selectedStop?.predictions = pfilterRedictions;
      });
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

  ontapStopCell(BusStop stop) {
    if (selectedStop!.isLoading) {
      return;
    }

    selectedStop?.isSelected = false;
    selectedStop?.predictions = null;

    stop.isSelected = true;
    selectedStop = stop;

    fetchPredictions();
  }

  @override
  Widget build(BuildContext context) {
    String routeNavTitle = widget.route?.routeID ?? "";
    String? descriptionTitle = widget.route?.name ?? "";

    descriptionTitle = descriptionTitle.split(' - ').sublist(1).join(' - ');

    Direction? directionModel =
        direction ? routeDetail?.direction0 : routeDetail?.direction1;
    String? destinationName = "${directionModel?.tripHeadsign}";

    List<BusStop> favorStops = context.watch<FavoriteProvder>().busFavorites;

    String? directionId = routeDetail?.direction0?.directionText;
    String? directionId1 = routeDetail?.direction1?.directionText;
    List<String>? directionNames = [];
    if (directionId != null) {
      directionNames.add(directionId);
    }
    if (directionId1 != null) {
      directionNames.add(directionId1);
    }

    Map<String, Widget>? segmentedWidgets = {
      for (var e in directionNames)
        e: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              e,
              style: TextStyle(
                  color: directionModel?.directionText == e
                      ? CupertinoColors.white
                      : CupertinoColors.black),
            ))
    };

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
      )),
      // No scheduled service today for the 29G
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : directionModel == null ||
                  directionModel.stops == null ||
                  directionModel.stops!.isEmpty
              ? Center(
                  child: Text(
                      "No scheduled service today for the ${routeDetail?.routeID}",
                      style: Theme.of(context).textTheme.titleMedium))
              : SafeArea(
                  child: Column(
                    children: [
                      _getAdWidget(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: segmentedWidgets.length > 1
                            ? CupertinoSlidingSegmentedControl<String>(
                                thumbColor: const Color(0xff333333),
                                //子标
                                children: segmentedWidgets,
                                //当前选中的索引
                                groupValue: directionModel.directionText,
                                //点击回调
                                onValueChanged: (String? value) {
                                  setState(() {
                                    if (directionModel?.directionText !=
                                        value) {
                                      direction = !direction;
                                      directionModel = direction
                                          ? routeDetail?.direction1
                                          : routeDetail?.direction0;
                                    }
                                  });
                                },
                              )
                            : Text(directionModel.directionText ?? "",
                                style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Text('TO $destinationName',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium),
                      ValueListenableBuilder<int>(
                          valueListenable: remindSeconds,
                          builder:
                              (BuildContext context, int value, Widget? child) {
                            String autoRefreshString = autoRefresh
                                ? "There are $value seconds left for the next refresh"
                                : "Automatic refresh is not enabled, please refresh manually";
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(autoRefreshString,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            );
                          }),
                      Expanded(
                        child: ScrollablePositionedList.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(), // 允许始终滚动
                          itemScrollController: itemScrollController,
                          itemPositionsListener: itemPositionsListener,
                          itemCount: directionModel?.stops?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            BusStop? stop = directionModel?.stops?[index];

                            return GestureDetector(
                              onTap: () {
                                ontapStopCell(stop);
                              },
                              child: RouteStopCell(
                                isFavorite: favorStops.contains(stop),
                                stop: stop!,
                                atIndex: "${index + 1}",
                                addFavorite: () {
                                  if (favorStops.contains(stop)) {
                                    // 移除
                                    context
                                        .read<FavoriteProvder>()
                                        .removeBusFavorite(selectedStop!);
                                  } else {
                                    // 收藏站点
                                    selectedStop?.direction = direction;
                                    context
                                        .read<FavoriteProvder>()
                                        .addBusFavorite(selectedStop!);
                                  }
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
