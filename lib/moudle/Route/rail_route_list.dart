import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmata_bus/Model/rail_route.dart';
import 'package:wmata_bus/Providers/route_provider.dart';
import 'package:wmata_bus/moudle/Route/View/rail_route_cell.dart';
import 'package:wmata_bus/moudle/Stop/rail_stop_page.dart';

class RailRouteList extends StatefulWidget {
  final String? searchKeyword;
  const RailRouteList({super.key, this.searchKeyword});

  @override
  State<RailRouteList> createState() => _RailRouteListState();
}

class _RailRouteListState extends State<RailRouteList> {
  List<RailRoute>? filterStations;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppRouteProvider>(
      builder: (context, appRouteProvider, child) {
        List<RailRoute>? railRoutes = appRouteProvider.railRoutes;

        filterStations = railRoutes
            ?.where((e) =>
                e.lineCode?.toLowerCase().contains(
                    widget.searchKeyword?.toLowerCase().trim() ?? '') ??
                false)
            .toList();

        return (filterStations == null || filterStations!.isEmpty)
            ? Center(
                child: Text("No data",
                    style: Theme.of(context).textTheme.titleLarge))
            : ListView.builder(
                itemCount: filterStations?.length,
                itemBuilder: (BuildContext context, int index) {
                  RailRoute railRoute = filterStations![index];
                  return GestureDetector(
                      onTap: () {
                        // 跳转详情页
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return RailStopPage(route: railRoute);
                        }));
                      },
                      child: RailRouteCell(railRoute: railRoute));
                },
              );
      },
    );
  }
}
