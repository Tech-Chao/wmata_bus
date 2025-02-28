import 'package:wmata_bus/moudle/Home/favor_page.dart';
import 'package:wmata_bus/moudle/My/mine_page.dart';
import 'package:wmata_bus/moudle/Route/route_list_page.dart';
import 'package:flutter/material.dart';

class MyTabPage extends StatefulWidget {
  const MyTabPage({Key? key}) : super(key: key);

  @override
  State<MyTabPage> createState() => _MyTabPageState();
}

class _MyTabPageState extends State<MyTabPage> {
  final List<BottomNavigationBarItem> bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite_border),
      activeIcon: Icon(Icons.favorite),
      label: "Home",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search_sharp),
      activeIcon: Icon(Icons.search_rounded),
      label: "Search",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.more_horiz_outlined),
      activeIcon: Icon(Icons.more_horiz),
      label: "More",
    ),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      FavoritePage(onMyTap: _changePage),
      const RouteListPage(),
      const MinePageView()
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        items: bottomNavItems,
        unselectedFontSize: 15,
        selectedFontSize: 18,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        currentIndex: currentIndex,
        // type: BottomNavigationBarType.shifting,
        onTap: (index) => _changePage(index),
      ),
      body: IndexedStack(index: currentIndex, children: pages),
    );
  }

  void _changePage(int index) {
    /*如果点击的导航项不是当前项  切换 */
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }
}
