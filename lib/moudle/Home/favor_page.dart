import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:wmata_bus/Providers/favorite_provider.dart';
import 'package:wmata_bus/Utils/app_lifecycle_reactor.dart';
import 'package:wmata_bus/Utils/app_open_ad_manager.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/moudle/Home/view/bus_favor_cell.dart';
import 'package:wmata_bus/moudle/Home/view/rail_favor_cell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wmata_bus/moudle/Stop/bus_stop_page.dart';
import 'package:wmata_bus/moudle/Stop/rail_stop_page.dart';

class FavoritePage extends StatefulWidget {
  final Function(int) onMyTap;
  const FavoritePage({super.key, required this.onMyTap});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // IDFA获取授权
  String authStatus = 'Unknown';
  // 应用内评分
  final InAppReview inAppReview = InAppReview.instance;
  // 横幅广告
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  late Orientation _currentOrientation;
  // 开屏广告
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkAppLaunchCountAndReview());

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
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

  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    if (kDebugMode) {
      print("UUID: $uuid");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadAd();
  }

  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });
    
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

  Widget _getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation == orientation &&
            _anchoredAdaptiveAd != null &&
            _isLoaded) {
          return Container(
            color: Colors.green,
            width: _anchoredAdaptiveAd!.size.width.toDouble(),
            height: _anchoredAdaptiveAd!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredAdaptiveAd!),
          );
        }
        // Reload the ad if the orientation changes.
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd();
        }
        return Container();
      },
    );
  }

  Widget emptyViewWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No bookmarked stops.",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ElevatedButton(
              onPressed: () {
                // 切換Tab
                widget.onMyTap(1);
              },
              child: Text("Add Stop",
                  style: Theme.of(context).textTheme.headlineSmall))
        ],
      ),
    );
  }

  Widget mainBodyWidget(List<dynamic> favorites) {
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
            onTap: () {
              // 跳转详情页 child: RouteCell(route: null),
              if (favorites[index] is BusStop) {
                BusStop stop = favorites[index];
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return BusStopPage(
                    route: stop.route,
                    stop: stop,
                  );
                }));
              } else {
                RailStation stop = favorites[index];
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return RailStopPage(
                    route: stop.route!,
                    stop: stop,
                  );
                }));
              }
            },
            child: favorites[index] is BusStop
                ? BusFavorCell(stop: favorites[index])
                : RailFavorCell(stop: favorites[index]));
      },
    );
  }

  // final List<BusFavoriteModel> favoriteStops;
  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvder>(
      builder: (context, favoriteProvder, child) {
        List<dynamic> favorites = [];
        favorites.addAll(favoriteProvder.busFavorites);
        favorites.addAll(favoriteProvder.railStationFavorites);
        return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
                title: Text(
              "DC Bus Tracker",
              style: Theme.of(context).textTheme.headlineSmall,
            )),
            floatingActionButton: favoriteProvder.busFavorites.isEmpty &&
                    favoriteProvder.railStationFavorites.isEmpty
                ? null
                : floatingButton(context),
            body: Column(
              children: [
                _getAdWidget(),
                favoriteProvder.busFavorites.isEmpty &&
                        favoriteProvder.railStationFavorites.isEmpty
                    ? Expanded(child: emptyViewWidget())
                    : Expanded(child: mainBodyWidget(favorites)),
              ],
            ));
      },
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
                  content: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: "Clear favorites?",
                          style: Theme.of(context).textTheme.titleMedium),
                    ]),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(
                              context, 'CupertinoAlertDialog - Normal, cancel');
                        },
                        child: Text("Cancel",
                            style: Theme.of(context).textTheme.titleLarge)),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(
                            context, 'CupertinoAlertDialog - Normal, ok');
                        context.read<FavoriteProvder>().clearFavorites();
                      },
                      child: Text("Delete",
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
        tooltip: '清除數據',
        child: const Icon(Icons.delete_forever_sharp));
  }
}
