import 'dart:convert';
import 'dart:io';

import 'package:wmata_bus/Model/bus_route.dart';
import 'package:wmata_bus/Providers/route_provider.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/Utils/store_manager.dart';
import 'package:wmata_bus/moudle/Services/api_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MinePageView extends StatefulWidget {
  const MinePageView({super.key});

  @override
  State<StatefulWidget> createState() => _MinePageViewState();
}

class _MinePageViewState extends State<MinePageView> {
  bool _isOldVersion = false;

  bool autoRefresh = false;
  String? lastUpdateTime;
  // 邮件url地址
  late final Uri emailLaunchUri;
  bool loading = false;

  @override
  void initState() {
    emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'wuchaoyu122@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'DC Bus Tracker Feedback!',
      }),
    );
    getOldVersion();
    getAutoRefreshState();
    loadLastUpdateTime();
    super.initState();
  }

  getAutoRefreshState() async {
    String? res = await StoreManager.get("autoRefresh");
    var result = (res == true.toString());
    setState(() {
      autoRefresh = result;
    });
  }

  getOldVersion() async {
    String? res = await StoreManager.get("_isOldVersion");
    var result = (res == true.toString());
    setState(() {
      _isOldVersion = result;
    });
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // 发送邮件
  void sendEmail() => launchUrl(emailLaunchUri);

  loadLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tempLastUpdateTime = prefs.getString('last_update_time');
    if (tempLastUpdateTime != null) {
      setState(() {
        lastUpdateTime = tempLastUpdateTime;
      });
    }
  }

  fetchRemoteDatas(context) async {
    if (loading) {
      return;
    } else {
      setState(() {
        loading = true;
      });
      List<BusRoute>? temp = await APIService.updateRouteInfo();
      setState(() {
        loading = false;
      });
      if (temp != null && temp.isNotEmpty) {
        Provider.of<AppRouteProvider>(context, listen: false)
            .setBusRoutes(temp);

        SharedPreferences prefs = await SharedPreferences.getInstance();

        //   // Convert the data to a JSON string
        String newRoutes = json.encode(temp);

        //   // Save the JSON string to shared preferences
        await prefs.setString(ConstTool.kAllRouteskey, newRoutes);

        DateTime currentTime = DateTime.now();
        String currentTimeString = currentTime.toIso8601String();
        await prefs.setString('last_update_time', currentTimeString);
        setState(() {
          loading = false;
          lastUpdateTime = currentTimeString;
        });
      }
    }
  }

  // 更新車站数据
  Widget autoRefreshWidget(context) {
    return Container(
      color: Colors.white,
      child: ListTile(
          title: Text('Auto Refresh',
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text('Estimated arrival time refreshed every minute',
              style: Theme.of(context).textTheme.titleSmall),
          trailing: Switch(
              value: autoRefresh,
              onChanged: (bool value) {
                setState(() {
                  autoRefresh = value;
                });
                StoreManager.save("autoRefresh", value.toString());
              })),
    );
  }

  // 更新車站数据
  Widget updateWidget(context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () {
          fetchRemoteDatas(context);
        },
        title: Text('Update Service Data',
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
            'Last UpdateTime: ${lastUpdateTime != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(lastUpdateTime!)) : "None"}',
            style: Theme.of(context).textTheme.titleSmall),
        trailing: loading
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.keyboard_arrow_right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'DC Bus Tracker',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 10),
          children: [
            const SizedBox(height: 10),
            autoRefreshWidget(context),
            // const SizedBox(height: 10),
            // Container(
            //   color: Colors.white,
            //   child: ListTile(
            //     leading: Text(
            //       "Larger Font",
            //       style: Theme.of(context).textTheme.titleMedium,
            //     ),
            //     trailing: Switch(
            //       value: _isOldVersion,
            //       onChanged: (bool value) {
            //         setState(() {
            //           _isOldVersion = value;
            //           StoreManager.save("_isOldVersion", value.toString());
            //           showDialog(
            //               context: context,
            //               builder: (context) {
            //                 return AlertDialog(
            //                   title: Text(
            //                     "Tip",
            //                     style: Theme.of(context).textTheme.titleLarge,
            //                   ),
            //                   content: Text(
            //                       '"Larger Font" ${value ? "Enabled" : "Close"} is successful and will take effect after restarting. Do you want to exit immediately?',
            //                       style:
            //                           Theme.of(context).textTheme.titleLarge),
            //                   actions: [
            //                     TextButton(
            //                         onPressed: () {
            //                           Navigator.pop(context,
            //                               'CupertinoAlertDialog - Normal, cancel');
            //                         },
            //                         child: Text("Next Time",
            //                             style: Theme.of(context)
            //                                 .textTheme
            //                                 .titleLarge)),
            //                     TextButton(
            //                       onPressed: () async {
            //                         Navigator.pop(context,
            //                             'CupertinoAlertDialog - Normal, ok');
            //                         exit(0);
            //                       },
            //                       child: Text("Quit",
            //                           style: Theme.of(context)
            //                               .textTheme
            //                               .titleLarge
            //                               ?.copyWith(
            //                                   color: Theme.of(context)
            //                                       .primaryColor)),
            //                     )
            //                   ],
            //                 );
            //               });
            //         });
            //       },
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
            updateWidget(context),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: ListTile(
                onTap: sendEmail,
                leading: Text('Report Bug',
                    style: Theme.of(context).textTheme.titleMedium),
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
            ),
          ],
        ));
  }
}
