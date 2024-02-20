import 'package:wmata_bus/Model/bus_route.dart';
import 'package:wmata_bus/Providers/route_provider.dart';
import 'package:wmata_bus/moudle/Route/View/route_cell.dart';
import 'package:wmata_bus/moudle/Stop/route_stop_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteListPage extends StatefulWidget {
  const RouteListPage({super.key});

  @override
  State<RouteListPage> createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  final TextEditingController _controller = TextEditingController();

  List<BusRoute> originRoutes = [];
  List<BusRoute> filterRoutes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 20,
        centerTitle: false,
        title: searchInputWidget(context),
      ),
      body: Consumer<AppRouteProvider>(
        builder: (context, appRouteProvider, child) {
          List<BusRoute>? routes = appRouteProvider.busRoutes;

          filterRoutes = routes!
              .where((e) =>
                  e.routeId!
                      .toLowerCase()
                      .contains(_controller.text.toLowerCase().trim()) ||
                  e.routeLongName!
                      .toLowerCase()
                      .contains(_controller.text.toLowerCase().trim()))
              .toList();

          return filterRoutes.isEmpty
              ? Center(
                  child: Text("No data",
                      style: Theme.of(context).textTheme.titleLarge))
              : ListView.builder(
                  itemCount: filterRoutes.length,
                  itemBuilder: (BuildContext context, int index) {
                    BusRoute route = filterRoutes[index];
                    return GestureDetector(
                      onTap: () {
                        // 跳转详情页
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return RouteStopPage(route: route);
                        }));
                      },
                      child: RouteCell(
                          titile: route.routeId!,
                          subtitle: route.routeLongName ?? "",
                          routeColor: route.routeColor ?? ""),
                    );
                  },
                );
        },
      ),
    );
  }

  Widget searchInputWidget(BuildContext context) {
    _controller.addListener(() {
      setState(() {});
    });

    OutlineInputBorder outlineInputBorder = const OutlineInputBorder(
      gapPadding: 0,
      borderSide: BorderSide(color: Color(0xFFF5F7FA)),
    );
    return Container(
      height: 45,
      // margin: EdgeInsets.only(15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: TextField(
        controller: _controller,
        // autofocus: true,
        style: Theme.of(context).textTheme.titleLarge,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: 30,
            color: Colors.grey[400],
          ),
          isCollapsed: true,
          contentPadding: const EdgeInsets.only(top: 0, bottom: 0),
          border: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          disabledBorder: outlineInputBorder,
          focusedErrorBorder: outlineInputBorder,
          errorBorder: outlineInputBorder,
          hintText: 'Please enter the Enter a bus route',
          hintMaxLines: 1,
          hintStyle: Theme.of(context).textTheme.titleMedium,
          suffixIcon: IconButton(
            onPressed: _controller.clear,
            icon: Icon(
              Icons.clear,
              size: 30,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
