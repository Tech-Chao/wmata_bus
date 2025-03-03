import 'package:flutter/material.dart';
import 'package:wmata_bus/moudle/Route/bus_route_list.dart';
import 'package:wmata_bus/moudle/Route/rail_route_list.dart';

class RouteListPage extends StatefulWidget {
  const RouteListPage({Key? key}) : super(key: key);

  @override
  State<RouteListPage> createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'Bus',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
            ),
            Tab(
              child: Text(
                'Rail',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
            ),
          ],
        ),
        title: searchInputWidget(context),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BusRouteList(searchKeyword: _controller.text),
          RailRouteList(searchKeyword: _controller.text),
        ],
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
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: TextField(
        controller: _controller,
        // autofocus: true,
        style: Theme.of(context).textTheme.bodyMedium,
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
          hintText: 'Please enter keywords to search',
          // hintMaxLines: 1,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          suffixIcon: IconButton(
            onPressed: _controller.clear,
            icon: Icon(
              Icons.clear,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
