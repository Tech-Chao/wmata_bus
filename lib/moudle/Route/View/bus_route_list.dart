import 'package:wmata_bus/Model/bus_route_new.dart';
import 'package:wmata_bus/Providers/route_provider.dart';
import 'package:wmata_bus/moudle/Route/View/route_cell.dart';
import 'package:wmata_bus/moudle/Stop/route_stop_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusRouteList extends StatefulWidget {
  final String searchKey;
  const BusRouteList({super.key, required this.searchKey});

  @override
  State<BusRouteList> createState() => _BusRouteListState();
}

class _BusRouteListState extends State<BusRouteList> {
  List<BusRouteNew> filterRoutes = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppRouteProvider>(
      builder: (context, appRouteProvider, child) {
        List<BusRouteNew>? routes = appRouteProvider.busRoutes;
        filterRoutes = routes!
            .where((e) =>
                e.routeID
                    ?.toLowerCase()
                    .contains(widget.searchKey.toLowerCase().trim()) ??
                false)
            .toList();

        return filterRoutes.isEmpty
            ? Center(
                child: Text("No data",
                    style: Theme.of(context).textTheme.titleLarge))
            : ListView.builder(
                itemCount: filterRoutes.length,
                itemBuilder: (BuildContext context, int index) {
                  BusRouteNew route = filterRoutes[index];
                  return GestureDetector(
                      onTap: () {
                        // 跳转详情页
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return RouteStopPage(routeID: route.routeID ?? "");
                        }));
                      },
                      child: BusRouteCell(
                          title: route.routeID ?? "",
                          subtitle: route.name ?? ""));
                },
              );
      },
    );
  }
}
