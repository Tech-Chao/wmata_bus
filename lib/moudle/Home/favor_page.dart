import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:wmata_bus/Providers/favorite_provider.dart';
import 'package:wmata_bus/Utils/app_lifecycle_reactor.dart';
import 'package:wmata_bus/Utils/app_open_ad_manager.dart';
import 'package:wmata_bus/moudle/Home/view/bus_favor_cell.dart';
import 'package:wmata_bus/moudle/Home/view/rail_favor_cell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // 开屏广告
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
  }

  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 1000));
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
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white)))
        ],
      ),
    );
  }

  Widget mainBodyWidget(List<dynamic> favorites) {
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key(favorites[index].hashCode.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm Delete',
                      style: Theme.of(context).textTheme.titleLarge),
                  content: Text('Are you sure you want to delete this favorite?',
                      style: Theme.of(context).textTheme.titleMedium),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            final provider = context.read<FavoriteProvder>();
            if (favorites[index] is BusStop) {
              provider.removeBusFavorite(favorites[index]);
            } else {
              provider.removeRailStationFavorite(favorites[index]); 
            }
          },
          child: GestureDetector(
            onTap: () {
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
            onLongPress: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Delete',
                        style: Theme.of(context).textTheme.titleLarge),
                    content: Text('Are you sure you want to delete this favorite?',
                        style: Theme.of(context).textTheme.titleMedium),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                final provider = context.read<FavoriteProvder>();
                if (favorites[index] is BusStop) {
                  provider.removeBusFavorite(favorites[index]);
                } else {
                  provider.removeRailStationFavorite(favorites[index]);
                }
              }
            },
            child: favorites[index] is BusStop
                ? BusFavorCell(stop: favorites[index])
                : RailFavorCell(stop: favorites[index])
          ),
        );
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            )),
            floatingActionButton: favoriteProvder.busFavorites.isEmpty &&
                    favoriteProvder.railStationFavorites.isEmpty
                ? null
                : floatingButton(context),
            body: Column(
              children: [
                // _getAdWidget(),
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
        tooltip: 'Delete all favorites',
        child: const Icon(Icons.delete_forever_sharp));
  }
}
