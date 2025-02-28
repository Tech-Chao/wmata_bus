// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';
// import 'package:wmata_bus/Model/rail_predictino.dart';
// import 'package:wmata_bus/Model/rail_station.dart';
// import 'package:wmata_bus/Providers/favorite_provider.dart';
// import 'package:wmata_bus/Utils/const_tool.dart';
// import 'package:wmata_bus/Utils/store_manager.dart';
// import 'package:wmata_bus/moudle/Services/api_services_new.dart';

// class RailArrivalPage extends StatefulWidget {
//   final RailStation railStation;
//   const RailArrivalPage({super.key, required this.railStation});

//   @override
//   State<RailArrivalPage> createState() => _RailArrivalPageState();
// }

// class _RailArrivalPageState extends State<RailArrivalPage> {
//   RailPrediction? prediction;
//   Timer? _timer;
//   ValueNotifier<int> remindSeconds = ValueNotifier<int>(60);
//   bool autoRefresh = true;
//   bool isLoading = false;
//   bool isFavorite = false;

//   // 横幅广告
//   BannerAd? _anchoredAdaptiveAd;
//   bool _isLoaded = false;
//   late Orientation _currentOrientation;

//   @override
//   void initState() {
//     super.initState();
//     fetchPredictions();
//     loadAutoRefresh();
//     _checkFavoriteStatus();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   loadAutoRefresh() async {
//     String? tempAutoRefresh = await StoreManager.get('autoRefresh');
//     autoRefresh = tempAutoRefresh != null && bool.parse(tempAutoRefresh);
//     if (autoRefresh) {
//       _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
//         if (remindSeconds.value > 0) {
//           setState(() {
//             remindSeconds.value -= 1;
//           });
//         }
//         if (mounted && !isLoading && remindSeconds.value == 0) {
//           fetchPredictions();
//         }
//       });
//     }
//   }

//   void _checkFavoriteStatus() async {
//     bool status = await context
//         .read<FavoriteProvder>()
//         .isFavoriteRailStation(widget.railStation);
//     if (mounted) {
//       setState(() {
//         isFavorite = status;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: Text(widget.railStation.name ?? "",
//               style: Theme.of(context).textTheme.headlineSmall),
//           actions: [
//             IconButton(
//               onPressed: () async {
//                 if (isFavorite) {
//                   context
//                       .read<FavoriteProvder>()
//                       .isFavoriteRailStation(widget.railStation);
//                 } else {
//                   await context
//                       .read<FavoriteProvder>()
//                       .addRailStationFavorite(widget.railStation);
//                 }
//                 setState(() {
//                   isFavorite = !isFavorite;
//                 });
//               },
//               icon: Icon(
//                 isFavorite ? Icons.favorite : Icons.favorite_border,
//                 color: isFavorite ? Colors.red : null,
//               ),
//             ),
//           ]),
//       body: Column(children: [
//         _getAdWidget(),
//         isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: ValueListenableBuilder<int>(
//                         valueListenable: remindSeconds,
//                         builder:
//                             (BuildContext context, int value, Widget? child) {
//                           String autoRefreshString = autoRefresh
//                               ? "There are $value seconds left for the next refresh"
//                               : "Automatic refresh is not enabled, please refresh manually";
//                           return Center(
//                             child: Text(autoRefreshString,
//                                 textAlign: TextAlign.center,
//                                 style: Theme.of(context).textTheme.titleSmall),
//                           );
//                         }),
//                   ),
//                   Container(
//                     width: double.infinity,
//                     color: Colors.grey[300], // Adding a grey background
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 10),
//                     child: Text(
//                       'NEXT TRAIN',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                   ),
//                   _buildArrivalTimeCard(prediction!),
//                 ],
//               ),
//       ]),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           fetchPredictions(); // Manually refresh data
//         },
//         tooltip: 'Refresh Data',
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }

//   fetchPredictions() async {
//     setState(() {
//       isLoading = true;
//     });
//     List<RailPrediction>? prediction = await APIService.getRailPredictions(
//         stationCodes: widget.railStation.lineCode ?? "");

//     if (mounted) {
//       setState(() {
//         isLoading = false;
//         this.prediction = prediction?.first;
//         remindSeconds.value = 60;
//       });
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _currentOrientation = MediaQuery.of(context).orientation;
//     _loadAd();
//   }

//   Future<void> _loadAd() async {
//     await _anchoredAdaptiveAd?.dispose();
//     setState(() {
//       _anchoredAdaptiveAd = null;
//       _isLoaded = false;
//     });

//     final AnchoredAdaptiveBannerAdSize? size =
//         await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
//             MediaQuery.of(context).size.width.truncate());

//     if (size == null) {
//       if (kDebugMode) {
//         print('Unable to get height of anchored banner.');
//       }
//       return;
//     }
//     String adUnitId;
//     if (kDebugMode) {
//       adUnitId = Platform.isAndroid
//           ? ConstTool.kAndroidDebugBannerId
//           : ConstTool.kiOSDebugBannerId;
//     } else {
//       adUnitId = Platform.isAndroid
//           ? ConstTool.kAndroidReleaseBannerId
//           : ConstTool.kiOSReleaseBannerId;
//     }
//     _anchoredAdaptiveAd = BannerAd(
//       adUnitId: adUnitId,
//       size: size,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) {
//           if (kDebugMode) {
//             print('$ad loaded: ${ad.responseInfo}');
//           }
//           setState(() {
//             // When the ad is loaded, get the ad size and use it to set
//             // the height of the ad container.
//             _anchoredAdaptiveAd = ad as BannerAd;
//             _isLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           if (kDebugMode) {
//             print('Anchored adaptive banner failedToLoad: $error');
//           }
//           ad.dispose();
//         },
//       ),
//     );
//     return _anchoredAdaptiveAd!.load();
//   }

//   Widget _getAdWidget() {
//     return OrientationBuilder(
//       builder: (context, orientation) {
//         if (_currentOrientation == orientation &&
//             _anchoredAdaptiveAd != null &&
//             _isLoaded) {
//           return Container(
//             color: Colors.green,
//             width: _anchoredAdaptiveAd!.size.width.toDouble(),
//             height: _anchoredAdaptiveAd!.size.height.toDouble(),
//             child: AdWidget(ad: _anchoredAdaptiveAd!),
//           );
//         }
//         // Reload the ad if the orientation changes.
//         if (_currentOrientation != orientation) {
//           _currentOrientation = orientation;
//           _loadAd();
//         }
//         return Container();
//       },
//     );
//   }

//   Widget _buildArrivalTimeCard(RailPrediction prediction) {
//     return Card(
//       color: Colors.white,
//       elevation: 0,
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (prediction.trains != null && prediction.trains!.isNotEmpty)
//               // firstLoop
//               _buildDirectionRow(
//                 widget.railStation.lineCode == 'DLS' ||
//                         widget.railStation.lineCode == 'MIA' ||
//                         widget.railStation.lineCode == 'PAL'
//                     ? 'Departing'
//                     : 'NORTHBOUND',
//                 prediction.trains?.first.min ?? "",
//                 prediction.trains?.last.min ?? "",
//               ),
//             const SizedBox(height: 8),

//             const Divider(),
//             const SizedBox(height: 8),
//             // secondLoop
//             _buildDirectionRow(
//               widget.railStation.lineCode == 'DLS' ||
//                       widget.railStation.lineCode == 'MIA' ||
//                       widget.railStation.lineCode == 'PAL'
//                   ? 'Arriving'
//                   : 'SOUTHBOUND',
//               prediction.trains?.first.min ?? "",
//               prediction.trains?.last.min ?? "",
//             ),
//             const SizedBox(height: 15),
//             Text(
//               '***** Times Are Currently Unavailable',
//               style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                     color: Colors.red[500],
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDirectionRow(String direction, String first, String second) {
//     return Row(
//       children: [
//         Text(
//           direction,
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black54,
//               ),
//         ),
//         const SizedBox(width: 20),
//         Expanded(
//           child: Row(
//             children: [
//               if (first != '') _buildTimeBox(first),
//               if (second != '') _buildTimeBox(second),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTimeBox(String time) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         time,
//         style: Theme.of(context).textTheme.titleSmall,
//       ),
//     );
//   }
// }
